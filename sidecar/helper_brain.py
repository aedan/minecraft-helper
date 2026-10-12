#!/usr/bin/env python3
"""Minecraft helper chat brain.

Tails the vanilla server log and turns the owner's addressed chat into helper actions:
  * high-confidence keyword orders map straight onto tool calls (no model needed);
  * everything else goes to an OpenAI-compatible model through a bounded agent loop
    (agent.py) that may only use the fixed tool set in tools.py.
Every action goes through the datapack's helper:api entry points over one persistent
RCON connection (rcon_client.py).
"""

from __future__ import annotations

import json
import os
import re
import struct
import sys
import time
import zlib
from pathlib import Path

from agent import Agent, OpenAIModel
from rcon_client import RconClient, reject_public_chat
from tools import Dispatcher, RAIL_TYPES, resolve_recipe

CHAT_RE = re.compile(
    r"\]: (?:\[Not Secure\] )?(?:\[CHAT\] )?<([^>]+)> (.+)$"
)
CHAT_RE_ALT = re.compile(
    r"\]: (?:\[Not Secure\] )?([A-Za-z0-9_]{1,16}): (.+)$"
)
CHAT_RE_ANY = re.compile(r"<([A-Za-z0-9_]{1,16})> (.+)$")
# Vanilla whisper /msg /tell /w — mannequin helpers cannot be whispered TO.
# IMPORTANT: MC 26.x never writes whispers to latest.log (confirmed empty across
# all logs + RCON msg test). Self-/msg is silent. Private path is datapack inbox:
#   /trigger tom
#   /function helper:w {m:"Tom, dig 400"}  (alias: helper:msg)
#   /trigger helper_cmd set 9  (same dialog)
# Keep these regexes for older jars / future logging; they match nothing on 26.3.
WHISPER_RE = re.compile(
    r"\]: (?:\[Not Secure\] )?(?:\[CHAT\] )?"
    r"([A-Za-z0-9_]{1,16}) whispers to ([A-Za-z0-9_]{1,16}): (.+)$"
)
WHISPER_RE_ALT = re.compile(
    r"\]: (?:\[Not Secure\] )?"
    r"([A-Za-z0-9_]{1,16}) -> ([A-Za-z0-9_]{1,16}): (.+)$"
)
# Wake signal when datapack helper:w runs (appears as System chat in log).
INBOX_WAKE_RE = re.compile(r"Running function helper:(?:w|msg)\b")

def env(name: str, default: str = "") -> str:
    return os.environ.get(name, default).strip()


def load_dotenv(path: Path) -> None:
    if not path.is_file():
        return
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, _, v = line.partition("=")
        os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))


# Public-chat guard and the persistent RCON client live in rcon_client.py.
Rcon = RconClient
_reject_public_chat = reject_public_chat


def parse_chat(line: str) -> tuple[str, str] | None:
    """Return (player, message) for public chat. Whispers use parse_line."""
    m = CHAT_RE.search(line)
    if m:
        return m.group(1), m.group(2)
    m = CHAT_RE_ANY.search(line)
    if m:
        return m.group(1), m.group(2)
    m = CHAT_RE_ALT.search(line)
    if m:
        name, msg = m.group(1), m.group(2)
        if name in {"Rcon", "Server", "Helper"}:
            return None
        return name, msg
    return None


def parse_line(line: str) -> tuple[str, str, bool] | None:
    """Return (player, message, is_whisper) or None.

    Whispers are the private order channel. Because the helper is a mannequin,
    owners whisper to themselves (or any name) with 'HelperName, order…'.
    """
    m = WHISPER_RE.search(line) or WHISPER_RE_ALT.search(line)
    if m:
        sender, _target, msg = m.group(1), m.group(2), m.group(3)
        if sender in {"Rcon", "Server", "Helper"}:
            return None
        return sender, msg, True
    parsed = parse_chat(line)
    if not parsed:
        return None
    return parsed[0], parsed[1], False


def _scan_entity_mca(path: Path) -> list[tuple[float, float, float]]:
    """Return Pos triples for chunks that contain a helper.active tag."""
    found: list[tuple[float, float, float]] = []
    try:
        data = path.read_bytes()
    except OSError:
        return found
    if len(data) < 8192:
        return found
    for i in range(1024):
        off = struct.unpack(">I", data[i * 4 : i * 4 + 4])[0]
        sector, count = off >> 8, off & 0xFF
        if sector == 0 or count == 0:
            continue
        start = sector * 4096
        if start + 5 > len(data):
            continue
        length = struct.unpack(">I", data[start : start + 4])[0]
        ctype = data[start + 4]
        payload = data[start + 5 : start + 4 + length]
        try:
            raw = zlib.decompress(payload) if ctype == 2 else payload
        except Exception:
            continue
        if b"helper.active" not in raw:
            continue
        p = 0
        while True:
            j = raw.find(b"\x00\x03Pos", p)
            if j < 0:
                break
            if j >= 1 and raw[j - 1] == 9 and j + 34 <= len(raw):
                etype = raw[j + 5]
                n = struct.unpack(">i", raw[j + 6 : j + 10])[0]
                if etype == 6 and n == 3:
                    x, y, z = struct.unpack(">ddd", raw[j + 10 : j + 34])
                    found.append((x, y, z))
            p = j + 1
    return found


def find_helper_on_disk(world: Path) -> tuple[float, float, float] | None:
    """Locate a saved helper in overworld/nether/end entity region files."""
    roots = [
        world / "dimensions/minecraft/overworld/entities",
        world / "dimensions/minecraft/the_nether/entities",
        world / "dimensions/minecraft/the_end/entities",
        world / "entities",
    ]
    hits: list[tuple[float, float, float]] = []
    for root in roots:
        if not root.is_dir():
            continue
        for mca in root.glob("r.*.*.mca"):
            hits.extend(_scan_entity_mca(mca))
    if not hits:
        return None
    # Prefer a later Pos in the same chunk (entity vs marker); last is fine.
    return hits[-1]


def sanitize_name(name: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9_ ]", "", name).strip()
    return (cleaned[:24] or "Helper")


def player_selector(player: str) -> str:
    return f"@a[name={player},limit=1]"


KILL_TARGET_STOPWORDS = {
    "them", "it", "mobs", "hostile", "hostiles", "pillager", "pillagers",
    "animals", "cows", "pigs", "food", "me", "myself",
    "your", "you", "him", "her", "his", "hers", "their", "theirs",
    "someone", "everyone", "anybody", "somebody", "people", "players",
    "player", "friend", "friends", "creator", "owner", "master",
}



def parse_torch_clear_flags(text: str) -> tuple[int, int] | None:
    """Parse clear_walls/clear_floor from an owner order.

    Returns (clear_walls, clear_floor) as 0/1, or None if ambiguous (ask owner).
    Honors leave/keep/except/but not/don't touch vs wall/floor/center/all nouns.
    """
    t = text.lower().strip()

    leave_floor = bool(
        re.search(
            r"(?:leave|keep|except|but\s+not|don'?t\s+(?:touch|remove|break|clear)|"
            r"do\s+not\s+(?:touch|remove|break|clear)).{0,48}\b(?:floor|ground)s?\b"
            r"|(?:leave|keep)\s+(?:the\s+)?(?:floor|ground)(?:\s+(?:ones?|torches?))?"
            r"|(?:floor|ground)\s+(?:ones?|torches?)\s+(?:alone|untouched)",
            t,
        )
    )
    leave_wall = bool(
        re.search(
            r"(?:leave|keep|except|but\s+not|don'?t\s+(?:touch|remove|break|clear)|"
            r"do\s+not\s+(?:touch|remove|break|clear)).{0,48}\bwalls?\b"
            r"|(?:leave|keep)\s+(?:the\s+)?walls?(?:\s+(?:ones?|torches?))?"
            r"|walls?\s+(?:ones?|torches?)\s+(?:alone|untouched)",
            t,
        )
    )
    mention_wall = bool(re.search(r"\bwalls?\b", t))
    mention_floor = bool(re.search(r"\b(?:floor|ground|center)\b", t))
    has_all = bool(re.search(r"\b(?:all|every|entire)\b", t))

    cw: int | None = None
    cf: int | None = None

    # Explicit all with no leave exceptions → both (unless location noun narrows it)
    if has_all and not leave_floor and not leave_wall:
        if mention_wall and not mention_floor:
            cw, cf = 1, 0
        elif mention_floor and not mention_wall:
            cw, cf = 0, 1
        else:
            cw, cf = 1, 1

    # Location targets (without leave)
    if mention_wall and not leave_wall:
        if cw is None:
            cw = 1
        if not has_all and not mention_floor and not leave_floor:
            if cf is None:
                cf = 0
    if mention_floor and not leave_floor:
        if cf is None:
            cf = 1
        if not has_all and not mention_wall and not leave_wall:
            if cw is None:
                cw = 0

    # Exceptions override / imply the other side
    if leave_floor:
        cf = 0
        if cw is None:
            cw = 1
    if leave_wall:
        cw = 0
        if cf is None:
            cf = 1

    if cw is None and cf is None:
        return None  # e.g. bare "remove the torches" — ask
    if cw is None:
        cw = 0
    if cf is None:
        cf = 0
    if cw == 0 and cf == 0:
        return None
    return int(cw), int(cf)


class Brain:
    def __init__(self) -> None:
        self.default_name = env("HELPER_DEFAULT_NAME", "Helper")
        self.names_path = Path(env("HELPER_NAMES_PATH", "names.json"))
        self.names: dict[str, str] = {}
        if self.names_path.is_file():
            try:
                self.names = json.loads(self.names_path.read_text(encoding="utf-8"))
            except json.JSONDecodeError:
                self.names = {}
        self._cached_owner: str | None = None
        host = env("HELPER_RCON_HOST", "127.0.0.1")
        port = int(env("HELPER_RCON_PORT", "25575") or "25575")
        password = env("HELPER_RCON_PASSWORD")
        if not password:
            props = Path("/opt/minecraft/server.properties")
            if props.is_file():
                for line in props.read_text(encoding="utf-8").splitlines():
                    if line.startswith("rcon.password="):
                        password = line.split("=", 1)[1]
        self.rcon = RconClient(host, port, password)
        self.world = Path(env("HELPER_WORLD_PATH", "/opt/minecraft/world"))
        self._private_tip_at: dict[str, float] = {}
        self.llm_base = env("HELPER_LLM_BASE_URL")
        self.llm_key = env("HELPER_LLM_API_KEY")
        self.llm_model = env("HELPER_LLM_MODEL")
        # auto: use native tool calls, switch to strict JSON if the server rejects tools.
        tool_mode = (env("HELPER_LLM_TOOL_MODE", "auto") or "auto").lower()
        if tool_mode not in ("auto", "native", "json"):
            tool_mode = "auto"
        self.agent: Agent | None = None
        if self.llm_base and self.llm_model:
            try:
                from openai import OpenAI

                client = OpenAI(api_key=self.llm_key or "none", base_url=self.llm_base, max_retries=0)
                self.agent = Agent(
                    OpenAIModel(client, self.llm_model),
                    mode=tool_mode,
                    timeout=float(env("HELPER_LLM_TIMEOUT", "20") or "20"),
                )
                print(f"LLM: {self.llm_model} @ {self.llm_base} (tools: {tool_mode})", flush=True)
            except Exception as exc:
                print(f"LLM init failed, keyword orders only: {exc}", flush=True)

    def save_names(self) -> None:
        self.names_path.parent.mkdir(parents=True, exist_ok=True)
        self.names_path.write_text(json.dumps(self.names, indent=2), encoding="utf-8")

    def helper_name(self, player: str) -> str:
        # Single shared helper: prefer bound owner's chosen name, then any stored.
        owner = self._cached_owner
        if owner and self.names.get(owner):
            return self.names[owner]
        if self.names.get(player):
            return self.names[player]
        for v in self.names.values():
            if v:
                return v
        return self.default_name

    def is_owner(self, player: str) -> bool:
        """True if this player is the bound helper owner (tag or helper_id)."""
        if not player:
            return False
        tagged = (
            self.rcon.cmd(
                f"execute if entity @a[name={player},tag=helper.owner,limit=1]"
            )
            or ""
        )
        if "passed" in tagged.lower():
            self._cached_owner = player
            return True
        # Fallback: same helper_id as the active helper (bound companion).
        self.rcon.cmd("scoreboard players set #owner_probe helper_config 0")
        self.rcon.cmd(
            f"execute as @a[name={player},limit=1] if score @s helper_id matches 1.. "
            f"if score @s helper_id = @e[tag=helper.active,limit=1] helper_id run "
            f"scoreboard players set #owner_probe helper_config 1"
        )
        after = (
            self.rcon.cmd("scoreboard players get #owner_probe helper_config") or ""
        )
        m = re.search(r"has (-?\d+)", after)
        ok = bool(m and m.group(1) == "1")
        if ok:
            self._cached_owner = player
        return ok

    def resolve_online_player(self, name: str) -> str | None:
        """Case-insensitive match against the live /list player names."""
        want = (name or "").strip()
        if not want:
            return None
        exact = self.rcon.cmd(f"execute if entity @a[name={want},limit=1]") or ""
        if "passed" in exact.lower():
            return want
        out = self.rcon.cmd("list") or ""
        if ":" not in out:
            return None
        players = [p.strip() for p in out.split(":", 1)[1].split(",") if p.strip()]
        folded = want.casefold()
        for p in players:
            if p.casefold() == folded:
                return p
        return None

    def say(self, player: str, text: str) -> None:
        """Owner-only tellraw. Never use `say` or tellraw @a — public chat leak."""
        player = (player or "").strip()
        if not player or not re.fullmatch(r"[A-Za-z0-9_]{1,16}", player):
            print(f"say() refused — bad player {player!r}", flush=True)
            return
        name = self.helper_name(player)
        safe = text.replace("\\", "").replace('"', "'")[:180]
        payload = json.dumps(
            [
                {"text": f"[{name}] ", "color": "aqua"},
                {"text": safe, "color": "white"},
            ]
        )
        # Explicit name selector only — never @a / @p / @s from RCON console.
        self.rcon.cmd(f"tellraw @a[name={player},limit=1] {payload}")

    def helper_is_loaded(self) -> bool:
        out = (self.rcon.cmd("execute if entity @e[tag=helper.active]") or "").lower()
        return "passed" in out

    def ensure_helper_loaded(self) -> bool:
        if self.helper_is_loaded():
            return True
        pos = find_helper_on_disk(self.world)
        if pos is None:
            return False
        x, z = int(pos[0]), int(pos[2])
        print(f"loading helper chunk at {x},{z}", flush=True)
        self.rcon.cmd(f"execute in minecraft:overworld run forceload add {x} {z}")
        time.sleep(0.8)
        self.rcon.cmd("tag @e[type=minecraft:mannequin] add helper.active")
        return self.helper_is_loaded()

    def ensure_bound_name(self) -> None:
        """Re-apply names.json onto live helper + helper:bind. Fix within ~1s if wrong/empty/Helper."""
        name = None
        owner = self._cached_owner
        if owner and self.names.get(owner):
            name = self.names[owner]
        elif self.names:
            name = next((v for v in self.names.values() if v), None)
        if not name:
            return
        safe = sanitize_name(name).replace('"', "")
        self.rcon.cmd(f'data modify storage helper:bind name set value "{safe}"')
        cur = (self.rcon.cmd("execute as @e[tag=helper.active,limit=1] run data get entity @s CustomName") or "")
        # Match "tom" or {text:"tom"} forms; skip re-merge when already correct (avoids RCON spam)
        if safe in cur and "Helper" not in cur:
            return
        if f'"{safe}"' in cur and "Helper" not in cur:
            return
        # Datapack path (same-tick after summon/gear)
        self.rcon.cmd("execute as @e[tag=helper.active] run function helper:lifecycle/apply_bound_name")
        # Direct fallback — survives missing apply_bound_name or gear stomps
        self.rcon.cmd(
            f'execute as @e[tag=helper.active] run data modify entity @s CustomName set value {{text:"{safe}"}}'
        )
        self.rcon.cmd(
            f'execute as @e[tag=helper.active] run data merge entity @s {{CustomNameVisible:1b,hide_description:1b,description:{{text:""}},profile:{{name:"{safe}"}}}}'
        )
        self.rcon.cmd(
            f'execute as @e[tag=helper.active] run function helper:jobs/set_name {{name:"{safe}"}}'
        )
        print(f"ensure_bound_name fixed CustomName -> {safe} (was {cur!r})", flush=True)

    def set_name(self, player: str, name: str) -> None:
        # Rename is owner-only. Non-owners are ignored (silent).
        if not self.is_owner(player):
            print(f"rename denied for non-owner {player}", flush=True)
            return
        name = sanitize_name(name)
        # Persist under the owner key only; drop other players' rename entries.
        owner_key = self._cached_owner or player
        self.names = {owner_key: name}
        self.save_names()
        # Persist into datapack storage so respawn/reload/apply_bound_name work without chat rename
        safe = name.replace("\\", "").replace('"', "")
        self.rcon.cmd(f'data modify storage helper:bind name set value "{safe}"')
        sel = player_selector(player)
        pos = find_helper_on_disk(self.world)
        if pos is not None:
            x, z = int(pos[0]), int(pos[2])
            self.rcon.cmd(f"execute in minecraft:overworld run forceload add {x} {z}")
            time.sleep(0.5)
        self.rcon.cmd("tag @e[type=minecraft:mannequin] add helper.active")
        self.rcon.cmd(f"tag {sel} add helper.cmd")
        nbt = (
            f'{{CustomName:{{text:"{name}"}},CustomNameVisible:1b,'
            f'hide_description:1b,description:{{text:""}},profile:{{name:"{name}"}}}}'
        )
        self.rcon.cmd(f"execute as @e[tag=helper.active] run data merge entity @s {nbt}")
        self.rcon.cmd(
            f"execute as @e[tag=helper.active] run data modify entity @s CustomName set value {{text:\"{name}\"}}"
        )
        self.rcon.cmd(
            f'execute as @e[tag=helper.active] run function helper:jobs/set_name {{name:"{name}"}}'
        )
        self.rcon.cmd("tag @a remove helper.cmd")
        self.say(player, f"I am {name} now. Talk to me in chat.")
        print(f"named helper {name} for {player}", flush=True)


    def addressed(self, player: str, message: str) -> str | None:
        raw = message.strip()
        name = self.helper_name(player)
        low = raw.lower()
        nlow = name.lower()
        # "I name you Oak" / "your name is Oak" / "I'll call you Oak"
        m = re.match(
            r"(?:(?:i|i'll|i will) )?(?:name you|call you|rename you) ([A-Za-z0-9_ ]{1,24})\.?$",
            low,
        )
        if m:
            return f"__name__:{m.group(1).strip()}"
        m = re.match(r"(?:your name is|you are called) ([A-Za-z0-9_ ]{1,24})\.?$", low)
        if m:
            return f"__name__:{m.group(1).strip()}"
        names = {nlow, "helper", "sam", "jam"}
        names.update(n.lower() for n in self.names.values() if n)
        for n in sorted(names, key=len, reverse=True):
            if not n:
                continue
            for prefix in (n + ",", n + ":", n + " "):
                if low.startswith(prefix):
                    return raw[len(prefix) :].strip()
            if low == n:
                return "yes?"
        return None

    def keyword_orders(self, text: str) -> list[tuple[str, dict]]:
        """High-confidence orders. Used before the LLM so stay/come are never renamed."""
        t = text.lower().strip()
        if t.startswith("__name__:"):
            return [("name", {"name": text.split(":", 1)[1]})]
        m = re.match(
            r"(?:(?:i|i'll|i will) )?(?:name you|call you|rename you) ([A-Za-z0-9_ ]{1,24})\.?$",
            t,
        )
        if m:
            return [("name", {"name": m.group(1).strip()})]
        m = re.match(r"(?:your name is|you are called) ([A-Za-z0-9_ ]{1,24})\.?$", t)
        if m:
            return [("name", {"name": m.group(1).strip()})]
        calls: list[tuple[str, dict]] = []
        if re.search(r"\b(stay home|go home|patrol)\b", t):
            calls.append(("stay_home", {}))
            return calls
        if re.search(r"\b(stop|halt|wait|cancel)\b", t) or (
            re.search(r"\bstay\b", t) and not re.search(r"stay home|go home", t)
        ):
            calls.append(("stop", {}))
            return calls

        # Organize chests/barrels: "organize the chests", "sort the base storage".
        if re.search(r"\b(?:organi[sz]e|sort|tidy)\b.*\b(?:chests?|barrels?|storage|base|items)\b", t):
            scope = "base" if re.search(r"\b(?:base|storage|all)\b", t) else "ahead"
            calls.append(("organize", {"scope": scope}))
            return calls

        # Repair missing rails — must beat lay_rails (and not be confused with clear).
        if re.search(
            r"\b(?:repair|fix|replace|fill\s*(?:in)?)\b.*\b(?:rails?|tracks?)\b"
            r"|\b(?:rails?|tracks?)\b.*\b(?:repair|fix|missing|broken|gaps?)\b"
            r"|\bmissing\s+(?:rails?|tracks?)\b"
            r"|\bfill\s+in\s+(?:the\s+)?(?:missing\s+)?(?:rails?|tracks?)\b",
            t,
        ):
            args_r: dict = {}
            mlen = re.search(r"(\d{1,5})\s*(?:blocks?|meters?|m\b)", t)
            if mlen:
                args_r["blocks"] = int(mlen.group(1))
            elif re.search(r"\b(?:all\s+the\s+way|to\s+the\s+end|entire|until\s+end)\b", t):
                args_r["blocks"] = 10000
            calls.append(("repair_rails", args_r))
            return calls

        # Undo/clean messed rails — must beat lay_rails and torch clear.
        if re.search(
            r"\b(?:undo|clean\s*up|cleanup|strip)\b.*\b(?:bad|messed|wrong)?\s*(?:rails?|tracks?)\b"
            r"|\b(?:bad|messed|wrong)\s+(?:rails?|tracks?)\b"
            r"|\bundo\s+the\s+bad\s+rails?\b"
            r"|\bclean\s+up\s+the\s+messed\s+rails?\b"
            r"|\bremove\s+the\s+bad\s+(?:rails?|tracks?)\b",
            t,
        ):
            args_r: dict = {}
            m_n = re.search(r"\b(\d{1,4})\b", t)
            if m_n:
                args_r["blocks"] = max(1, min(int(m_n.group(1)), 10000))
            calls.append(("clear_rails", args_r))
            return calls
        # Remove/clean redstone torches — must beat gather(redstone) and dig.
        # Parse wall/floor targets + leave/keep exceptions into flags.
        if re.search(
            r"\b(?:remove|break|clear|clean(?:\s*up)?|take\s+down|get\s+rid\s+of)\b"
            r".*\b(?:redstone\s+)?torch(?:es)?\b"
            r"|\b(?:redstone\s+)?torch(?:es)?\b.*\b(?:wall|floor|ground|remove|break|clear|clean)\b"
            r"|\b(?:wall\s+torch(?:es)?|floor\s+torch(?:es)?|torch(?:es)?\s+from\s+the\s+walls?)\b",
            t,
        ):
            flags = parse_torch_clear_flags(t)
            if flags is None:
                calls.append(
                    (
                        "say",
                        {
                            "text": "Wall torches, floor torches, or all? Say leave floor if you want walls only."
                        },
                    )
                )
                return calls
            args_c: dict = {"clear_walls": flags[0], "clear_floor": flags[1]}
            m_n = re.search(r"\b(\d{1,4})\b", t)
            if m_n:
                args_c["blocks"] = max(1, min(int(m_n.group(1)), 10000))
            elif re.search(r"\b(?:all\s+the\s+way|to\s+the\s+end|entire\s+tunnel|whole\s+tunnel)\b", t):
                args_c["blocks"] = 10000
            calls.append(("clear_wall_torches", args_c))
            return calls
        m = re.search(
            r"\b(?:kill|attack|hunt|assassinate|slay)\s+([A-Za-z0-9_]{1,16})\b",
            text,
            re.I,
        )
        if m and m.group(1).lower() not in KILL_TARGET_STOPWORDS:
            calls.append(("kill_player", {"player": m.group(1)}))
            return calls
        # Dig / keep-digging / tunnel-for-N. Must beat a trailing chest/store clause
        # (that alone used to return place_chest and never dig). Rail/pattern orders
        # that merely mention a tunnel are left for the rail matcher below.
        has_rail = bool(re.search(r"\b(?:rails?|tracks?|lay(?:ing|ed)?|pattern)\b", t))
        has_dig = bool(re.search(r"\bdig(?:ging)?\b|\bmine\s+straight\b", t))
        has_tunnel = bool(re.search(r"\btunnels?\b", t))
        wants_dig = has_dig or (has_tunnel and not has_rail)
        if wants_dig:
            m_n = re.search(
                r"\b(?:dig(?:ging)?|tunnels?|mine\s+straight)(?:\s+\w+){0,10}?\s+(\d{1,4})\b",
                t,
            )
            if not m_n:
                m_n = re.search(r"\b(\d{1,4})\s+blocks?\b", t)
            if not m_n:
                m_n = re.search(r"\b(\d{1,4})\b", t)
            keep = bool(re.search(
                r"\b(?:further|continue|keep\s+digging|keep\s+going|from\s+here|another)\b",
                t,
            ))
            store = bool(re.search(
                r"\b(?:chests?|store|storage|save(?:\s+all)?)\b",
                t,
            ))
            if m_n or keep or has_dig:
                n = int(m_n.group(1)) if m_n else 64
                n = max(1, min(n, 2000))
                calls.append(("dig_straight", {"blocks": n, "keep": keep, "store": store}))
                return calls
        m = re.search(
            r"\b(?:keep\s+)?(?:lay+ing|lay|place|put)\s+(?:down\s+)?(?:the\s+)?"
            r"(?:(powered|detector|activator)\s+)?(?:rails?|tracks?)\b"
            r"|\b(?:rails?|tracks?)\s+down\b"
            r"|\b(?:keep\s+)?(?:lay+ing|lay|place)\b.*\b(?:rails?|tracks?)\b"
            r"|\b(?:rails?|tracks?)\b.*\b(?:tunnel|ahead|forward)\b"
            r"|\b(?:continue|copy|same|follow)\b.*\b(?:pattern|rails?|tracks?|side)\b"
            r"|\b(?:side\s+tracks?|same\s+as\s+I\s+was\s+doing|"
            r"keep\s+going\s+with\s+(?:rails?|tracks?))\b"
            r"|\b(?:continue|keep)\s+(?:the\s+)?(?:rail\s+)?pattern\b"
            r"|\bfollow\s+(?:my\s+|the\s+)?pattern\b"
            r"|\bkeep\s+(?:lay+ing|going)\b.*\b(?:rails?|tracks?|tunnel|pattern)\b"
            # finish/complete the tunnel in my pattern (no explicit lay/rails verbs)
            r"|\b(?:finish|complete)\s+(?:the\s+)?(?:tunnel|rails?|tracks?)\b"
            r".*\b(?:pattern|rails?|tracks?)\b"
            r"|\b(?:finish|complete)\s+(?:the\s+)?(?:tunnel|rails?|tracks?)\b.*"
            r"\b(?:in|with)\s+(?:my\s+|the\s+)?pattern\b"
            r"|\b(?:in|with)\s+(?:my\s+|the\s+)?pattern\b.*"
            r"\b(?:finish|complete|tunnel|rails?|tracks?)\b"
            r"|\bpattern\b.*\b(?:finish|complete)\s+(?:the\s+)?(?:tunnel|rails?|tracks?)\b",
            t,
        )
        if m:
            args: dict = {}
            # optional count; "all the way" / keep-laying without a number → until tunnel end
            until_end = bool(
                re.search(
                    r"\b(?:all\s+the\s+way|to\s+the\s+end|until\s+the\s+end|"
                    r"entire\s+tunnel|whole\s+tunnel|finish\s+(?:the\s+)?tunnel|"
                    r"rest\s+of\s+(?:the\s+)?tunnel|as\s+far\s+as|"
                    r"keep\s+going\s+until)\b",
                    t,
                )
            )
            keep_going = bool(
                re.search(
                    r"\b(?:keep\s+(?:lay+ing|going)|continue\s+(?:lay+ing|the\s+)?|"
                    r"follow(?:ing)?\s+(?:my\s+)?pattern|"
                    r"(?:in|with)\s+(?:my\s+|the\s+)?pattern|"
                    r"(?:finish|complete)\s+(?:the\s+)?(?:tunnel|rails?|tracks?))\b",
                    t,
                )
            )
            m_n = re.search(r"\b(\d{1,5})\b", t)
            if m_n:
                args["blocks"] = max(1, min(int(m_n.group(1)), 10000))
            elif until_end or keep_going:
                args["blocks"] = 10000
            rtype = "auto"
            if m.lastindex and m.group(1):
                rtype = m.group(1)
            elif re.search(r"\b(continue|pattern|same as|side tracks?|follow.*pattern|tracks?)\b", t):
                rtype = "auto"
            elif "powered" in t:
                rtype = "powered"
            elif "detector" in t:
                rtype = "detector"
            elif "activator" in t:
                rtype = "activator"
            args["rail_type"] = rtype
            calls.append(("lay_rails", args))
            return calls
        if re.match(r"craft\b", t):
            m = re.match(r"craft\s+(?:me\s+)?(?:(\d{1,3})\s+)?(.+)$", t)
            if m:
                count_s, item = m.group(1), m.group(2).strip(" .,!")
                args: dict = {"item": item}
                if count_s:
                    args["count"] = int(count_s)
                m2 = re.match(r"^(.+?)\s+(\d{1,3})$", item)
                if m2 and not count_s:
                    args["item"] = m2.group(1).strip()
                    args["count"] = int(m2.group(2))
                calls.append(("craft", args))
                return calls
        if re.search(r"\b(smelt|melt)\b", t):
            mat = ""
            m = re.search(r"\bsmelt\s+(?:some\s+)?([a-z_ ]+?)$", t)
            if m:
                mat = m.group(1).strip()
            if not mat:
                for key in ("iron", "gold", "copper", "debris", "ancient debris", "sand"):
                    if key in t:
                        mat = key
                        break
            if not mat:
                mat = "iron"
            mat = mat.replace("raw ", "").replace(" ore", "").strip()
            if mat in {"ancient debris", "netherite"}:
                mat = "debris"
            calls.append(("smelt", {"material": mat}))
            return calls
        if re.search(r"\b(bring|deliver|drop\s+off)\b", t):
            calls.append(("bring", {}))
            return calls
        # Explicit come-here ONLY. Bare "follow"/"here" must not steal work orders
        # like "follow my pattern and keep laying the tracks…".
        if "stay" not in t and (
            re.search(
                r"\b(?:come\s+here|come\s+to\s+(?:me|us)|come\s+over(?:\s+here)?|"
                r"come\s+back|follow\s+me|get\s+over\s+here)\b"
                r"|^(?:come|here|follow)[.!]?$",
                t,
            )
            or (
                re.search(r"\b(?:come|follow|here|to me)\b", t)
                and not re.search(
                    r"\b(rail|track|pattern|lay|dig|craft|smelt|mine|tunnel|"
                    r"kill|hunt|gather|chop|cut|organize|chest|build|place|put)\b",
                    t,
                )
            )
        ):
            calls.append(("come_here", {}))
            return calls
        if re.search(r"set (base|home)|this is (home|base)|make this", t):
            calls.append(("set_base", {}))
            return calls
        g = None
        if re.search(r"\bdiamonds?\b", t):
            g = "diamond"
        elif re.search(r"\bredstone\b", t) and not re.search(
            r"\b(?:torch|torches|wall|remove|break|clear|clean)\b", t
        ):
            g = "redstone"
        elif re.search(r"\bcoal\b", t):
            g = "coal"
        elif re.search(r"\biron\b", t):
            g = "iron"
        elif re.search(r"\bcopper\b", t):
            g = "copper"
        elif re.search(r"\bgold\b", t):
            g = "gold"
        elif re.search(r"\blapis\b", t):
            g = "lapis"
        elif re.search(r"\bemeralds?\b", t):
            g = "emerald"
        elif re.search(r"\bquartz\b", t):
            g = "quartz"
        elif re.search(r"\b(debris|ancient debris|netherite ore)\b", t):
            g = "debris"
        elif re.search(r"\b(meat|food|hunt|beef|pork|mutton|cow|pig|chicken|animal)\b", t):
            g = "food"
        elif re.search(r"\b(tree|trees|wood|chop|cut|log)\b", t):
            g = "wood"
        if g:
            calls.append(("gather", {"resource": g}))
        if re.search(r"\b(chest|store|storage)\b", t):
            calls.append(("place_chest", {"label": g or "Loot"}))
        if re.search(r"\b(pillager|raid|outpost|tower|kill them|encampment)\b", t):
            calls.append(("raid_here", {}))
        return calls

    # ------------------------------------------------------------------ tool routing
    def dispatcher(self, player: str) -> Dispatcher:
        return Dispatcher(
            rcon=self.rcon,
            owner=player,
            say=self.say,
            ensure_loaded=self.ensure_helper_loaded,
            resolve_player=self._resolve_hunt_target,
        )

    def _resolve_hunt_target(self, name: str) -> str | None:
        target = re.sub(r"[^A-Za-z0-9_]", "", name or "")[:16]
        if not target or target.lower() in KILL_TARGET_STOPWORDS:
            return None
        return self.resolve_online_player(target)

    def keyword_to_tools(self, text: str, calls: list[tuple[str, dict]]) -> list[tuple[str, dict]]:
        """Translate keyword_orders() output into validated tool calls."""
        out: list[tuple[str, dict]] = []
        t = (text or "").lower()
        for name, args in calls:
            if name == "stay_home":
                out.append(("set_stay_at_base", {"on": True}))
            elif name == "stop":
                out.append(("stop_work", {}))
                # "wait"/"stay" (not "stay home") = stop and wait here, not follow.
                if re.search(r"\b(?:wait|stay)\b", t):
                    out.append(("set_protect_follow", {"on": False}))
            elif name in ("come_here", "bring"):
                out.append(("set_protect_follow", {"on": True, "come_now": True}))
            elif name == "set_base":
                out.append(("set_base", {}))
            elif name == "gather":
                res = str(args.get("resource", "wood"))
                out.append(("gather", {"resource": "ancient_debris" if res == "debris" else res}))
            elif name == "dig_straight":
                out.append(("dig_tunnel", {"blocks": int(args.get("blocks", 64)),
                                           "continue_tunnel": bool(args.get("keep")),
                                           "store_in_chest": bool(args.get("store"))}))
            elif name == "lay_rails":
                rt = str(args.get("rail_type") or "auto")
                a = {"action": "lay", "rail_type": rt if rt in RAIL_TYPES else "auto"}
                if "blocks" in args:
                    a["blocks"] = int(args["blocks"])
                out.append(("rails", a))
            elif name in ("repair_rails", "clear_rails", "clear_wall_torches"):
                action = {"repair_rails": "repair", "clear_rails": "clear_bad", "clear_wall_torches": "clear_torches"}[name]
                a = {"action": action}
                if "blocks" in args:
                    a["blocks"] = int(args["blocks"])
                out.append(("rails", a))
            elif name == "craft":
                item = resolve_recipe(str(args.get("item", "")))
                if not item:
                    out.append(("reply", {"text": f"I don't know how to craft {str(args.get('item', 'that'))[:40]}."}))
                else:
                    a = {"item": item}
                    if args.get("count"):
                        a["count"] = max(1, min(int(args["count"]), 64))
                    out.append(("craft", a))
            elif name == "smelt":
                mat = str(args.get("material", "iron"))
                mat = {"debris": "ancient_debris", "netherite": "ancient_debris"}.get(mat, mat)
                if mat in ("iron", "copper", "gold", "coal", "ancient_debris"):
                    out.append(("smelt", {"material": mat}))
                else:
                    out.append(("reply", {"text": "I can smelt iron, copper, gold, coal or ancient debris."}))
            elif name == "organize":
                out.append(("organize_chests", {"scope": args.get("scope", "ahead")}))
            elif name == "kill_player":
                out.append(("hunt_player", {"player": str(args.get("player", ""))[:16]}))
            elif name == "place_chest":
                # The api has no queue: storing would cancel a job ordered in the same breath.
                if not out:
                    out.append(("store_items", {}))
            elif name == "raid_here":
                out.append(("raid_here", {}))
            elif name == "say":
                out.append(("reply", {"text": str(args.get("text", "Okay."))[:200]}))
        return out

    def run_tools(self, player: str, calls: list[tuple[str, dict]]) -> None:
        """Run keyword tool calls in order; stop at the first failure; tell the owner."""
        if calls and calls[0][0] == "hunt_player" and not self.is_owner(player):
            print(f"hunt denied for non-owner {player}", flush=True)
            return
        d = self.dispatcher(player)
        last_msg = ""
        for name, args in calls[:3]:
            res = d.call(name, args)
            print(f"tool {name} {args} -> ok={res.get('ok')} {res.get('error')} {res.get('message')!r}", flush=True)
            if name == "reply":
                return
            last_msg = str(res.get("message") or "")
            if not res.get("ok"):
                if res.get("error") not in ("owner_offline", "not_owner"):
                    self.say(player, last_msg or "I couldn't do that.")
                return
            if name == "organize_chests" and res.get("reason") == "organized":
                last_msg = f"Organized {res.get('sorted')} of {res.get('chests_found')} containers; moved {res.get('moved')} items."
        if last_msg:
            self.say(player, last_msg)

    def think(self, player: str, text: str) -> None:
        """Model path for orders that keyword_orders could not classify."""
        if self.agent is None:
            self.say(player, "Say come here, stay home, stop, dig 50, or name me.")
            return
        out = self.agent.run(self.dispatcher(player), self.helper_name(player), text)
        names = [n for n, _a, _r in out.calls]
        print(f"agent ({out.mode}) stop={out.stop} calls={names} reply={out.replied!r}", flush=True)

    def _inbox_pending(self) -> bool:
        out = (self.rcon.cmd("data get storage helper:inbox pending") or "").lower()
        return "1b" in out or out.rstrip().endswith("1") or ": 1" in out

    def _inbox_msg(self) -> str | None:
        out = self.rcon.cmd("data get storage helper:inbox msg") or ""
        # e.g. Storage helper:inbox has the following contents: "Tom, dig 400"
        m = re.search(r'contents:\s*"(.*)"\s*$', out)
        if m:
            # Unescape basic SNBT string escapes from data get
            s = m.group(1).replace(chr(92)+chr(92), chr(92)).replace(chr(92)+'"', '"')
            return s
        m = re.search(r"contents:\s*'(.*)'\s*$", out)
        if m:
            return m.group(1)
        return None

    def _inbox_players(self) -> list[str]:
        """Online players with helper.inbox_pending tag."""
        out = self.rcon.cmd("list") or ""
        if ":" not in out:
            return []
        names = [p.strip() for p in out.split(":", 1)[1].split(",") if p.strip()]
        found: list[str] = []
        for name in names:
            chk = (
                self.rcon.cmd(
                    f"execute if entity @a[name={name},tag=helper.inbox_pending,limit=1]"
                )
                or ""
            )
            if "passed" in chk.lower():
                found.append(name)
        return found

    def clear_inbox(self, player: str | None = None) -> None:
        self.rcon.cmd("data remove storage helper:inbox msg")
        self.rcon.cmd("data modify storage helper:inbox pending set value 0b")
        if player:
            self.rcon.cmd(f"tag @a[name={player},limit=1] remove helper.inbox_pending")
        else:
            self.rcon.cmd("tag @a remove helper.inbox_pending")


    def _maybe_private_tip(self, player: str) -> None:
        """Owner-only tellraw tip (never public say/@a). Reminds /trigger tom path."""
        if not player:
            return
        now = time.time()
        last = self._private_tip_at.get(player, 0.0)
        # At most once per 45 minutes per player — not spammy.
        if now - last < 45 * 60:
            return
        if not self.is_owner(player):
            return
        self._private_tip_at[player] = now
        name = self.helper_name(player)
        # say() → tellraw @a[name=owner] only. Rcon.cmd also refuses bare say/@a.
        self.say(
            player,
            f"for private (others can't see): /trigger tom   "
            f'or /function helper:w {{m:"{name}, …"}}   '
            f"— /msg is not logged on this server",
        )
        print(f"private-tip sent to {player}", flush=True)

    def poll_inbox(self) -> None:
        """Drain datapack private-order inbox (helper:w / dialog). Owner-only path."""
        if not self._inbox_pending():
            # Still clear stray tags if storage empty
            return
        msg = self._inbox_msg()
        players = self._inbox_players()
        if not msg:
            print("inbox pending but empty msg — clearing", flush=True)
            self.clear_inbox(players[0] if players else None)
            return
        if not players:
            # Fallback: bound owner or first stored name
            player = self._cached_owner or next(iter(self.names), None)
            if not player:
                print(f"inbox msg with no tagged player: {msg!r} — clearing", flush=True)
                self.clear_inbox()
                return
            players = [player]
        player = players[0]
        self.clear_inbox(player)
        print(f"inbox order from {player}: {msg}", flush=True)
        # Treat as whisper/private so prefix rules + owner-only replies apply.
        self.handle(player, msg, is_whisper=True)

    def handle(self, player: str, message: str, is_whisper: bool = False) -> None:
        body = self.addressed(player, message)
        # Private inbox / whispers still need HelperName, prefix — unless the whole
        # message is clearly an order verb (dig/craft/smelt/kill/come/stop/…).
        if body is None and is_whisper:
            low = message.strip().lower()
            if re.match(
                r"^(?:dig|craft|smelt|melt|kill|attack|hunt|come|follow|stop|stay|"
                r"bring|deliver|gather|cut|mine|tunnel|lay|place|remove|clear|clean|break|set\s+base|"
                r"keep|continue|pattern|track|finish|complete|organi[sz]e|sort|protect|guard)\b",
                low,
            ):
                body = message.strip()
        if body is None:
            return
        channel = "whisper" if is_whisper else "chat"
        print(f"order from {player} ({channel}): {body}", flush=True)
        if not is_whisper:
            try:
                self._maybe_private_tip(player)
            except Exception as exc:
                print(f"private-tip error: {exc}", flush=True)
        if body.startswith("__name__:"):
            self.set_name(player, body.split(":", 1)[1])
            return
        direct = self.keyword_orders(body)
        if direct:
            print(f"keyword order: {direct}", flush=True)
            if direct[0][0] == "name":
                self.set_name(player, str(direct[0][1].get("name", "Helper")))
                return
            self.run_tools(player, self.keyword_to_tools(body, direct))
            return
        self.think(player, body)


def follow_log(path: Path):
    """Yield log lines; yield None on idle so callers can poll the private inbox."""
    path = Path(path)
    while not path.is_file():
        print(f"waiting for log {path}", flush=True)
        time.sleep(2)
    with path.open("r", encoding="utf-8", errors="replace") as fh:
        fh.seek(0, os.SEEK_END)
        inode = path.stat().st_ino
        while True:
            line = fh.readline()
            if line:
                yield line.rstrip("\n")
                continue
            yield None
            time.sleep(0.2)
            try:
                st = path.stat()
            except FileNotFoundError:
                time.sleep(1)
                continue
            if st.st_ino != inode or st.st_size < fh.tell():
                fh.close()
                while not path.is_file():
                    time.sleep(1)
                fh = path.open("r", encoding="utf-8", errors="replace")
                inode = path.stat().st_ino
                # New/rotated log: read from the start so we do not miss chat.
                fh.seek(0)


def main() -> int:
    for candidate in (
        Path("/opt/minecraft/helper-brain.env"),
        Path(__file__).resolve().parent / "helper-brain.env",
    ):
        load_dotenv(candidate)
    log_path = Path(env("HELPER_LOG_PATH", "/opt/minecraft/logs/latest.log"))
    brain = Brain()
    print(f"tailing {log_path}", flush=True)
    try:
        pos = find_helper_on_disk(brain.world)
        if pos is not None:
            x, z = int(pos[0]), int(pos[2])
            print(f"startup forceload helper at {x},{z}", flush=True)
            brain.rcon.cmd(f"execute in minecraft:overworld run forceload add {x} {z}")
            time.sleep(0.5)
            brain.rcon.cmd("execute as @e[tag=helper.active] at @s run forceload add ~ ~")
        # Stay quiet on startup (no @a spam). Suppress command/system chat leaks.
        try:
            brain.rcon.cmd("gamerule send_command_feedback false")
            brain.rcon.cmd("gamerule log_admin_commands false")
        except Exception as exc:
            print(f"quiet gamerule set failed: {exc}", flush=True)
        brain.ensure_bound_name()
        print("helper-brain online", flush=True)
    except Exception as exc:
        print(f"rcon hello failed: {exc}", flush=True)
    last_inbox = 0.0
    last_name_assert = 0.0
    for line in follow_log(log_path):
        now = time.time()
        wake = bool(line and INBOX_WAKE_RE.search(line))
        if wake or (now - last_inbox) >= 0.45:
            last_inbox = now
            try:
                brain.poll_inbox()
            except Exception as exc:
                print(f"inbox error: {exc}", flush=True)
        # Death/respawn: force name re-assert immediately (do not wait for 1s timer)
        if line and ("died:" in line or " suffocated " in line or " fell out of the world" in line) and (
            "Mannequin" in line or "Helper" in line or "tom" in line.lower()
        ):
            last_name_assert = 0.0
            try:
                brain.ensure_bound_name()
            except Exception as exc:
                print(f"post-death name assert error: {exc}", flush=True)

        if (now - last_name_assert) >= 1.0:
            last_name_assert = now
            try:
                brain.ensure_bound_name()
            except Exception as exc:
                print(f"name assert error: {exc}", flush=True)
        if not line:
            continue
        parsed = parse_line(line)
        if not parsed:
            continue
        player, msg, is_whisper = parsed
        if player in {"Rcon", "Server"}:
            continue
        try:
            brain.handle(player, msg, is_whisper=is_whisper)
        except Exception as exc:
            print(f"handle error: {exc}", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())


