import socket
import struct
import threading

import pytest

from rcon_client import AUTH_COOLDOWN, MAX_REQUEST_BYTES, RconAuthError, RconClient, RconError


def _pkt(rid, typ, body: bytes) -> bytes:
    data = struct.pack("<ii", rid, typ) + body + b"\x00\x00"
    return struct.pack("<i", len(data)) + data


class FakeServer:
    """Vanilla-like RCON: auth, 4096-byte fragments, 'Unknown request' for bad types."""

    def __init__(self, password="secret", responses=None, drop_after=None):
        self.password = password
        self.responses = responses or {}
        self.drop_after = drop_after  # close the connection after N commands
        self.sock = socket.socket()
        self.sock.bind(("127.0.0.1", 0))
        self.sock.listen()
        self.port = self.sock.getsockname()[1]
        self.accepts = 0
        self.commands = []
        threading.Thread(target=self._serve, daemon=True).start()

    def _read(self, c):
        hdr = b""
        while len(hdr) < 4:
            ch = c.recv(4 - len(hdr))
            if not ch:
                return None
            hdr += ch
        (n,) = struct.unpack("<i", hdr)
        buf = b""
        while len(buf) < n:
            ch = c.recv(n - len(buf))
            if not ch:
                return None
            buf += ch
        rid, typ = struct.unpack("<ii", buf[:8])
        return rid, typ, buf[8:-2]

    def _serve(self):
        while True:
            try:
                c, _ = self.sock.accept()
            except OSError:
                return
            self.accepts += 1
            threading.Thread(target=self._conn, args=(c,), daemon=True).start()

    def _conn(self, c):
        authed = False
        handled = 0
        with c:
            while True:
                p = self._read(c)
                if p is None:
                    return
                rid, typ, body = p
                if typ == 3:
                    authed = body.decode() == self.password
                    c.sendall(_pkt(rid if authed else -1, 2, b""))
                    continue
                if not authed:
                    c.sendall(_pkt(-1, 2, b""))
                    continue
                if typ == 2:
                    cmd = body.decode()
                    self.commands.append(cmd)
                    if self.drop_after is not None and handled >= self.drop_after:
                        self.drop_after = None
                        return  # simulate the server dropping us mid-command
                    handled += 1
                    out = self.responses.get(cmd, f"ran {cmd}").encode()
                    for i in range(0, max(len(out), 1), 4096):
                        c.sendall(_pkt(rid, 0, out[i:i + 4096]))
                else:
                    c.sendall(_pkt(rid, 0, f"Unknown request {typ:x}".encode()))

    def close(self):
        self.sock.close()


@pytest.fixture
def server():
    s = FakeServer(responses={"big": "x" * 10000})
    yield s
    s.close()


def test_persistent_connection(server):
    r = RconClient("127.0.0.1", server.port, "secret")
    assert r.cmd("list") == "ran list"
    assert r.cmd("time query day") == "ran time query day"
    assert server.accepts == 1 and r.connects == 1


def test_reads_fragmented_response(server):
    r = RconClient("127.0.0.1", server.port, "secret")
    assert r.cmd("big") == "x" * 10000
    assert r.cmd("after") == "ran after"  # stream stays in sync


def test_reconnects_once_after_drop():
    s = FakeServer(drop_after=1)
    try:
        r = RconClient("127.0.0.1", s.port, "secret", timeout=2)
        assert r.cmd("one") == "ran one"
        assert r.cmd("two") == "ran two"  # first attempt dropped, retried on a new socket
        assert s.accepts == 2
    finally:
        s.close()


def test_auth_failure_raises_and_cools_down():
    s = FakeServer(password="right")
    now = [100.0]
    try:
        r = RconClient("127.0.0.1", s.port, "wrong", clock=lambda: now[0])
        with pytest.raises(RconAuthError):
            r.cmd("list")
        with pytest.raises(RconAuthError):
            r.cmd("list")  # inside cooldown: no new connection
        assert s.accepts == 1
        now[0] += AUTH_COOLDOWN + 1
        with pytest.raises(RconAuthError):
            r.cmd("list")
        assert s.accepts == 2
    finally:
        s.close()


def test_no_password_is_auth_error():
    with pytest.raises(RconAuthError):
        RconClient("127.0.0.1", 1, "").cmd("list")


def test_unreachable_server_raises_rcon_error():
    sock = socket.socket()
    sock.bind(("127.0.0.1", 0))
    port = sock.getsockname()[1]
    sock.close()
    with pytest.raises(RconError):
        RconClient("127.0.0.1", port, "pw", timeout=1).cmd("list")


@pytest.mark.parametrize("cmd", ["say hi", "execute as @a run say hi", "tellraw @a {\"text\":\"x\"}", "tellraw @a[limit=1] \"x\""])
def test_public_chat_refused(server, cmd):
    r = RconClient("127.0.0.1", server.port, "secret")
    assert r.cmd(cmd) == ""
    assert server.commands == []


def test_owner_tellraw_allowed(server):
    r = RconClient("127.0.0.1", server.port, "secret")
    assert r.cmd('tellraw @a[name=Jake,limit=1] "hi"').startswith("ran")


def test_request_size_limit(server):
    r = RconClient("127.0.0.1", server.port, "secret")
    with pytest.raises(RconError):
        r.cmd("x" * (MAX_REQUEST_BYTES + 1))
