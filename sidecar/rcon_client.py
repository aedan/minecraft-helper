"""One persistent RCON connection for the helper sidecar.

- Connects and authenticates lazily, then reuses the socket for every command.
- Reads multi-packet responses completely: after each command it sends an invalid-type
  "sentinel" packet; vanilla answers it in order ("Unknown request ..."), so everything
  before that answer belongs to the command (responses over 4096 bytes are split).
- On a dropped connection it reconnects once and retries the command.
- A wrong password raises RconAuthError and is not retried for AUTH_COOLDOWN seconds, so a
  bad config never hammers the server.
- Refuses commands that would broadcast to public chat (`say`, bare `tellraw @a`).
"""
from __future__ import annotations

import re
import socket
import struct
import threading
import time
from typing import Callable

TYPE_RESPONSE = 0
TYPE_COMMAND = 2
TYPE_AUTH = 3
TYPE_SENTINEL = 200  # not a valid request type: the server echoes an error with our id
MAX_REQUEST_BYTES = 1446  # vanilla rejects longer command payloads
AUTH_COOLDOWN = 30.0


class RconError(Exception):
    """Connection or protocol failure (after one reconnect attempt)."""


class RconAuthError(RconError):
    """The server rejected the RCON password."""


class PublicChatRefused(RconError):
    """The command would have been visible to every player."""


_PUBLIC_CHAT_RE = re.compile(
    r"(?:^|[;])\s*say\b"
    r"|(?:^|[\s;])run\s+say\b"
    r"|tellraw\s+@a(?!\[)"
    r"|tellraw\s+@a\[limit\s*="
)


def reject_public_chat(command: str) -> str | None:
    """Return a reason if the command would show up in everyone's chat."""
    c = (command or "").strip()
    if c and _PUBLIC_CHAT_RE.search(c):
        return f"refused public chat RCON: {c[:120]}"
    return None


class RconClient:
    def __init__(
        self,
        host: str,
        port: int,
        password: str,
        timeout: float = 8.0,
        connect: Callable[..., socket.socket] = socket.create_connection,
        clock: Callable[[], float] = time.monotonic,
    ) -> None:
        self.host = host
        self.port = port
        self._password = password
        self.timeout = timeout
        self._connect = connect
        self._clock = clock
        self._sock: socket.socket | None = None
        self._lock = threading.Lock()
        self._next_id = 10
        self._auth_failed_at: float | None = None
        self.connects = 0  # for tests / diagnostics

    # ------------------------------------------------------------------ public
    def cmd(self, command: str) -> str:
        """Run one command and return its full text response.

        Public-chat commands are refused (returns "" and logs, like the old client).
        Raises RconAuthError on a bad password, RconError if the server is unreachable.
        """
        bad = reject_public_chat(command)
        if bad:
            print(bad, flush=True)
            return ""
        payload = command.encode("utf-8")
        if len(payload) > MAX_REQUEST_BYTES:
            raise RconError(f"command too long for RCON ({len(payload)} > {MAX_REQUEST_BYTES} bytes)")
        with self._lock:
            for attempt in (0, 1):
                try:
                    self._ensure_connected()
                    return self._exec(payload)
                except RconAuthError:
                    self._close()
                    raise
                except (OSError, EOFError, RconError) as exc:
                    self._close()
                    if attempt:
                        raise RconError(f"RCON failed after reconnect: {exc}") from exc
        raise AssertionError("unreachable")

    def close(self) -> None:
        with self._lock:
            self._close()

    # ------------------------------------------------------------------ internals
    def _ensure_connected(self) -> None:
        if self._sock is not None:
            return
        if self._auth_failed_at is not None and self._clock() - self._auth_failed_at < AUTH_COOLDOWN:
            raise RconAuthError("RCON password was rejected recently; not retrying yet")
        if not self._password:
            raise RconAuthError("no RCON password configured")
        sock = self._connect((self.host, self.port), self.timeout)
        sock.settimeout(self.timeout)
        self._sock = sock
        self.connects += 1
        ident = self._new_id()
        self._send(ident, TYPE_AUTH, self._password.encode("utf-8"))
        rid, _typ, _body = self._recv()
        if rid == -1:
            self._auth_failed_at = self._clock()
            raise RconAuthError("RCON password rejected")
        if rid != ident:
            raise RconError(f"unexpected auth reply id {rid}")
        self._auth_failed_at = None

    def _exec(self, payload: bytes) -> str:
        ident = self._new_id()
        sentinel = self._new_id()
        self._send(ident, TYPE_COMMAND, payload)
        self._send(sentinel, TYPE_SENTINEL, b"")
        parts: list[str] = []
        while True:
            rid, _typ, body = self._recv()
            if rid == sentinel:
                return "".join(parts)
            if rid == ident:
                parts.append(body.decode("utf-8", "replace"))
            elif rid == -1:
                raise RconAuthError("RCON session lost authentication")
            # anything else is a stale reply from an earlier, interrupted command: skip

    def _new_id(self) -> int:
        self._next_id = self._next_id + 1 if self._next_id < 2_000_000_000 else 10
        return self._next_id

    def _send(self, ident: int, typ: int, body: bytes) -> None:
        assert self._sock is not None
        pkt = struct.pack("<ii", ident, typ) + body + b"\x00\x00"
        self._sock.sendall(struct.pack("<i", len(pkt)) + pkt)

    def _recv_exact(self, n: int) -> bytes:
        assert self._sock is not None
        buf = b""
        while len(buf) < n:
            chunk = self._sock.recv(n - len(buf))
            if not chunk:
                raise EOFError("RCON connection closed")
            buf += chunk
        return buf

    def _recv(self) -> tuple[int, int, bytes]:
        (length,) = struct.unpack("<i", self._recv_exact(4))
        if length < 10 or length > 1 << 20:
            raise RconError(f"bad RCON packet length {length}")
        data = self._recv_exact(length)
        rid, typ = struct.unpack("<ii", data[:8])
        return rid, typ, data[8:-2]

    def _close(self) -> None:
        if self._sock is not None:
            try:
                self._sock.close()
            except OSError:
                pass
        self._sock = None
