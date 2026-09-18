#!/usr/bin/env python3
"""Minecraft helper chat brain.

Tails the vanilla server log, sends addressed chat to an OpenAI-compatible
endpoint, and applies structured jobs over RCON.
"""

from __future__ import annotations

import json
import os
import re
import socket
import struct
import sys
import time
from pathlib import Path

CHAT_RE = re.compile(
    r"\]: (?:\[Not Secure\] )?(?:\[CHAT\] )?<([^>]+)> (.+)$"
)
# Some 26.x builds log chat without angle brackets.
CHAT_RE_ALT = re.compile(
    r"\]: (?:\[Not Secure\] )?([A-Za-z0-9_]{1,16}): (.+)$"
)

JOBS = {
    "come_here": 1,
    "stay_home": 2,
    "stop": 3,
    "set_base": 4,
    "cut_trees": 5,
    "place_chest": 6,
    "raid_here": 7,
    "gather": 5,
}

GTYPES = {
    "wood": 1,
    "logs": 1,
    "tree": 1,
    "coal": 2,
    "iron": 3,
    "copper": 4,
    "gold": 5,
    "redstone": 6,
    "lapis": 7,
    "diamond": 8,
    "diamonds": 8,
    "emerald": 9,
    "emeralds": 9,
    "quartz": 10,
    "debris": 11,
    "netherite": 11,
}

TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "come_here",
            "description": "Leave work and follow the owner. Use when they say come, follow, or come to me.",
            "parameters": {"type": "object", "properties": {}},
        },
    },
    {
        "type": "function",
        "function": {
            "name": "stay_home",
            "description": "Stay at the marked base and work or patrol there.",
            "parameters": {"type": "object", "properties": {}},
        },
    },
    {
        "type": "function",
        "function": {
            "name": "stop",
            "description": "Cancel queued jobs and wait where the helper is now.",
            "parameters": {"type": "object", "properties": {}},
        },
    },
    {
        "type": "function",
        "function": {
            "name": "set_base",
            "description": "Mark the owner's current position as home/base.",
            "parameters": {"type": "object", "properties": {}},
        },
    },
    {
        "type": "function",
        "function": {
            "name": "cut_trees",
            "description": "Cut trees and gather logs (full player inventory, then return to base).",
            "parameters": {"type": "object", "properties": {}},
        },
    },
    {
        "type": "function",
        "function": {
            "name": "gather",
            "description": "Search far (up to ~48 blocks, and underground for ores), mine with the right tool, and carry up to a full player inventory (36 stacks). Use for diamonds, redstone, coal, iron, gold, copper, lapis, emerald, quartz, ancient debris, or wood.",
            "parameters": {
                "type": "object",
                "properties": {
                    "resource": {
                        "type": "string",
                        "description": "wood, coal, iron, copper, gold, redstone, lapis, diamond, emerald, quartz, or debris",
                    }
                },
                "required": ["resource"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "place_chest",
            "description": "Build a labeled chest at base and store gathered items (e.g. wood).",
            "parameters": {
                "type": "object",
                "properties": {
                    "label": {
                        "type": "string",
                        "description": "Chest name, e.g. Wood",
                    }
                },
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "raid_here",
            "description": "Go to the owner's current location (the camp/tower they are pointing out) and kill pillagers, vindicators, evokers, ravagers, witches.",
            "parameters": {"type": "object", "properties": {}},
        },
    },
    {
        "type": "function",
        "function": {
            "name": "say",
            "description": "Short in-character reply to the owner (one sentence).",
            "parameters": {
                "type": "object",
                "properties": {
                    "text": {"type": "string"},
                },
                "required": ["text"],
            },
        },
    },
]

SYSTEM = """You are the brain of a named Minecraft helper (an armored companion bound to one player).
You only output tool calls. You do not control blocks yourself; the body runs skills.

Skills you can queue (they run in order):
- come_here: follow the owner like a wolf (teleport if far or stuck).
- stay_home: work/patrol at base.
- stop: cancel jobs, wait here.
- set_base: owner's current spot is home.
- cut_trees: fell trees and haul logs home (full inventory).
- gather: find and mine a resource (wood/coal/iron/copper/gold/redstone/lapis/diamond/emerald/quartz/debris). Searches tens of blocks out and digs down for ores. Carries 36 stacks like a player. Then return to base.
- place_chest: chest at base for whatever was gathered.
- raid_here: owner is showing you a pillager camp/tower; go there and kill raiders.
- say: brief confirmation.

If they chain tasks (cut trees then make a chest then stay), emit several tools in that order.
If they run away they want you with them — come_here.
Refuse impossible work (redstone computers, entire cities) with say.
Keep say to one short sentence in first person.
"""


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


class Rcon:
    def __init__(self, host: str, port: int, password: str) -> None:
        self.host = host
        self.port = port
        self.password = password

    def cmd(self, command: str) -> str:
        s = socket.create_connection((self.host, self.port), 8)
        try:
            def send(ident: int, typ: int, payload: str) -> None:
                body = struct.pack("<ii", ident, typ) + payload.encode("utf-8") + b"\x00\x00"
                s.sendall(struct.pack("<i", len(body)) + body)

            def recv() -> str:
                raw = s.recv(4)
                if not raw:
                    return ""
                (ln,) = struct.unpack("<i", raw)
                body = b""
                while len(body) < ln:
                    chunk = s.recv(ln - len(body))
                    if not chunk:
                        break
                    body += chunk
                return body[8:-2].decode("utf-8", "replace")

            send(1, 3, self.password)
            auth = recv()
            if auth is None:
                return ""
            send(2, 2, command)
            return recv()
        finally:
            s.close()


def parse_chat(line: str) -> tuple[str, str] | None:
    m = CHAT_RE.search(line)
    if m:
        return m.group(1), m.group(2)
    m = CHAT_RE_ALT.search(line)
    if m:
        name, msg = m.group(1), m.group(2)
        if name in {"Rcon", "Server", "Helper"}:
            return None
        return name, msg
    return None


def sanitize_name(name: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9_ ]", "", name).strip()
    return (cleaned[:24] or "Helper")


def player_selector(player: str) -> str:
    return f"@a[name={player},limit=1]"


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
        host = env("HELPER_RCON_HOST", "127.0.0.1")
        port = int(env("HELPER_RCON_PORT", "25575") or "25575")
        password = env("HELPER_RCON_PASSWORD")
        if not password:
            props = Path("/opt/minecraft/server.properties")
            if props.is_file():
                for line in props.read_text(encoding="utf-8").splitlines():
                    if line.startswith("rcon.password="):
                        password = line.split("=", 1)[1]
        self.rcon = Rcon(host, port, password)
        self.llm_base = env("HELPER_LLM_BASE_URL")
        self.llm_key = env("HELPER_LLM_API_KEY")
        self.llm_model = env("HELPER_LLM_MODEL")
        self.client = None
        if self.llm_base and self.llm_model:
            try:
                from openai import OpenAI

                self.client = OpenAI(
                    api_key=self.llm_key or "none",
                    base_url=self.llm_base,
                )
                print(f"LLM: {self.llm_model} @ {self.llm_base}", flush=True)
            except Exception as exc:
                print(f"LLM init failed, using keyword fallback: {exc}", flush=True)

    def save_names(self) -> None:
        self.names_path.parent.mkdir(parents=True, exist_ok=True)
        self.names_path.write_text(json.dumps(self.names, indent=2), encoding="utf-8")

    def helper_name(self, player: str) -> str:
        return self.names.get(player, self.default_name)

    def say(self, player: str, text: str) -> None:
        name = self.helper_name(player)
        safe = text.replace("\\", "").replace('"', "'")[:180]
        payload = json.dumps(
            [
                {"text": f"[{name}] ", "color": "aqua"},
                {"text": safe, "color": "white"},
            ]
        )
        self.rcon.cmd(f"tellraw {player_selector(player)} {payload}")

    def enqueue(self, player: str, job: str, interrupt: bool = False, gtype: int = 0) -> None:
        n = JOBS[job]
        sel = player_selector(player)
        self.rcon.cmd(f"scoreboard players set #gtype helper_config {gtype}")
        self.rcon.cmd(f"scoreboard players set #job helper_config {n}")
        fn = "helper:jobs/force" if interrupt else "helper:jobs/enqueue"
        self.rcon.cmd(f"execute as {sel} run function {fn}")

    def set_name(self, player: str, name: str) -> None:
        name = sanitize_name(name)
        self.names[player] = name
        self.save_names()
        sel = player_selector(player)
        self.rcon.cmd(
            "execute as @e[type=zombie,tag=helper.active] "
            f"if score @s helper_id = {sel} helper_id "
            f'run function helper:jobs/set_name {{name:"{name}"}}'
        )
        self.say(player, f"I am {name} now. Talk to me in chat.")

    def addressed(self, player: str, message: str) -> str | None:
        raw = message.strip()
        name = self.helper_name(player)
        low = raw.lower()
        nlow = name.lower()
        # "I name you Oak"
        m = re.match(r"(?:i )?name you ([A-Za-z0-9_ ]{1,24})\.?$", low)
        if m:
            return f"__name__:{m.group(1).strip()}"
        for prefix in (nlow + ",", nlow + ":", nlow + " ", "helper,", "helper:", "helper "):
            if low.startswith(prefix):
                return raw[len(prefix) :].strip()
        if low == nlow or low == "helper":
            return "yes?"
        return None

    def fallback(self, text: str) -> list[tuple[str, dict]]:
        t = text.lower()
        if t.startswith("__name__:"):
            return [("name", {"name": text.split(":", 1)[1]})]
        calls: list[tuple[str, dict]] = []
        if re.search(r"\b(stop|halt|wait|cancel)\b", t):
            calls.append(("stop", {}))
        if re.search(r"\b(come|follow|here|to me)\b", t):
            calls.append(("come_here", {}))
        if re.search(r"\b(stay|home|base)\b", t) and "come" not in t:
            if re.search(r"set (base|home)|this is (home|base)|make this", t):
                calls.append(("set_base", {}))
            else:
                calls.append(("stay_home", {}))
        g = None
        if re.search(r"\bdiamonds?\b", t):
            g = "diamond"
        elif re.search(r"\bredstone\b", t):
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
        elif re.search(r"\b(tree|trees|wood|chop|cut|log)\b", t):
            g = "wood"
        if g:
            calls.append(("gather", {"resource": g}))
        if re.search(r"\b(chest|store|storage)\b", t):
            calls.append(("place_chest", {"label": g or "Loot"}))
        if re.search(r"\b(pillager|raid|outpost|tower|kill them|encampment)\b", t):
            calls.append(("raid_here", {}))
        if not calls:
            calls.append(("say", {"text": "Say come here, stay home, or name me."}))
        return calls

    def llm(self, player: str, text: str) -> list[tuple[str, dict]]:
        if not self.client:
            return self.fallback(text)
        try:
            resp = self.client.chat.completions.create(
                model=self.llm_model,
                temperature=0.2,
                messages=[
                    {"role": "system", "content": SYSTEM},
                    {
                        "role": "user",
                        "content": (
                            f"Helper name: {self.helper_name(player)}\n"
                            f"Owner: {player}\n"
                            f"Order: {text}"
                        ),
                    },
                ],
                tools=TOOLS,
                tool_choice="auto",
            )
            msg = resp.choices[0].message
            calls: list[tuple[str, dict]] = []
            for tc in msg.tool_calls or []:
                args = {}
                try:
                    args = json.loads(tc.function.arguments or "{}")
                except json.JSONDecodeError:
                    args = {}
                calls.append((tc.function.name, args))
            if not calls and msg.content:
                calls.append(("say", {"text": msg.content.strip()[:180]}))
            return calls or self.fallback(text)
        except Exception as exc:
            print(f"LLM error: {exc}", flush=True)
            return self.fallback(text)

    def apply(self, player: str, calls: list[tuple[str, dict]]) -> None:
        said = False
        for name, args in calls:
            if name == "name":
                self.set_name(player, str(args.get("name", "Helper")))
                said = True
                continue
            if name == "say":
                self.say(player, str(args.get("text", "Okay.")))
                said = True
                continue
            if name == "gather":
                resource = str(args.get("resource", "wood")).lower()
                gtype = GTYPES.get(resource, 1)
                self.enqueue(player, "cut_trees", gtype=gtype)
                continue
            if name == "cut_trees":
                self.enqueue(player, "cut_trees", gtype=1)
                continue
            if name in JOBS:
                self.enqueue(player, name, interrupt=name in {"come_here", "stop"})
        if not said and calls:
            self.say(player, "On it.")

    def handle(self, player: str, message: str) -> None:
        body = self.addressed(player, message)
        if body is None:
            return
        print(f"order from {player}: {body}", flush=True)
        if body.startswith("__name__:"):
            self.set_name(player, body.split(":", 1)[1])
            return
        self.apply(player, self.llm(player, body))


def follow_log(path: Path):
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
                fh.seek(0, os.SEEK_END)


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
        brain.rcon.cmd(
            'tellraw @a [{"text":"[Helper] ","color":"aqua"},{"text":"Chat brain online. Name me with: I name you Oak","color":"gray"}]'
        )
    except Exception as exc:
        print(f"rcon hello failed: {exc}", flush=True)
    for line in follow_log(log_path):
        parsed = parse_chat(line)
        if not parsed:
            continue
        player, msg = parsed
        if player in {"Rcon", "Server"}:
            continue
        try:
            brain.handle(player, msg)
        except Exception as exc:
            print(f"handle error: {exc}", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
