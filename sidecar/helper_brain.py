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
import zlib
from pathlib import Path

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

JOBS = {
    "come_here": 1,
    "stay_home": 2,
    "stop": 3,
    "set_base": 4,
    "cut_trees": 5,
    "place_chest": 6,
    "raid_here": 7,
    "gather": 5,
    "dig_straight": 8,
    "smelt": 9,
    "craft": 10,
    "hunt": 11,
    "lay_rails": 12,
    "clear_wall_torches": 13,
    "clear_rails": 14,
    "repair_rails": 15,
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
    "food": 12,
    "meat": 12,
    "beef": 12,
    "pork": 12,
    "chicken": 12,
    "mutton": 12,
    "hunt": 12,
    "animal": 12,
    "animals": 12,
    "cow": 12,
    "pig": 12,
}

# Common craftable items → (minecraft_id, count_per_craft, optional display).
# Brain crafts by giving the result after a come-to-owner deliver job.
# Unknown names are refused owner-only.
RECIPES: dict[str, tuple[str, int]] = {
    "stick": ("minecraft:stick", 4),
    "sticks": ("minecraft:stick", 4),
    "torch": ("minecraft:torch", 4),
    "torches": ("minecraft:torch", 4),
    "crafting table": ("minecraft:crafting_table", 1),
    "crafting_table": ("minecraft:crafting_table", 1),
    "furnace": ("minecraft:furnace", 1),
    "chest": ("minecraft:chest", 1),
    "ladder": ("minecraft:ladder", 3),
    "ladders": ("minecraft:ladder", 3),
    "oak planks": ("minecraft:oak_planks", 4),
    "planks": ("minecraft:oak_planks", 4),
    "oak_planks": ("minecraft:oak_planks", 4),
    "bread": ("minecraft:bread", 1),
    "bowl": ("minecraft:bowl", 4),
    "bucket": ("minecraft:bucket", 1),
    "shears": ("minecraft:shears", 1),
    "flint and steel": ("minecraft:flint_and_steel", 1),
    "flint_and_steel": ("minecraft:flint_and_steel", 1),
    "shield": ("minecraft:shield", 1),
    "bow": ("minecraft:bow", 1),
    "arrow": ("minecraft:arrow", 4),
    "arrows": ("minecraft:arrow", 4),
    "iron ingot": ("minecraft:iron_ingot", 1),
    "iron_ingot": ("minecraft:iron_ingot", 1),
    "gold ingot": ("minecraft:gold_ingot", 1),
    "gold_ingot": ("minecraft:gold_ingot", 1),
    "copper ingot": ("minecraft:copper_ingot", 1),
    "copper_ingot": ("minecraft:copper_ingot", 1),
    "iron pickaxe": ("minecraft:iron_pickaxe", 1),
    "iron_pickaxe": ("minecraft:iron_pickaxe", 1),
    "iron sword": ("minecraft:iron_sword", 1),
    "iron_sword": ("minecraft:iron_sword", 1),
    "iron axe": ("minecraft:iron_axe", 1),
    "iron_axe": ("minecraft:iron_axe", 1),
    "diamond pickaxe": ("minecraft:diamond_pickaxe", 1),
    "diamond_pickaxe": ("minecraft:diamond_pickaxe", 1),
    "diamond sword": ("minecraft:diamond_sword", 1),
    "diamond_sword": ("minecraft:diamond_sword", 1),
    "rail": ("minecraft:rail", 16),
    "rails": ("minecraft:rail", 16),
    "iron rail": ("minecraft:rail", 16),
    "iron rails": ("minecraft:rail", 16),
    "powered rail": ("minecraft:powered_rail", 6),
    "powered rails": ("minecraft:powered_rail", 6),
    "powered_rail": ("minecraft:powered_rail", 6),
    "detector rail": ("minecraft:detector_rail", 6),
    "detector rails": ("minecraft:detector_rail", 6),
    "activator rail": ("minecraft:activator_rail", 6),
    "activator rails": ("minecraft:activator_rail", 6),
    "minecart": ("minecraft:minecart", 1),
    "boat": ("minecraft:oak_boat", 1),
    "oak boat": ("minecraft:oak_boat", 1),
    "oak_boat": ("minecraft:oak_boat", 1),
    "hopper": ("minecraft:hopper", 1),
    "piston": ("minecraft:piston", 1),
    "sticky piston": ("minecraft:sticky_piston", 1),
    "sticky_piston": ("minecraft:sticky_piston", 1),
    "observer": ("minecraft:observer", 1),
    "dispenser": ("minecraft:dispenser", 1),
    "dropper": ("minecraft:dropper", 1),
    "lever": ("minecraft:lever", 1),
    "redstone torch": ("minecraft:redstone_torch", 1),
    "redstone_torch": ("minecraft:redstone_torch", 1),
    "compass": ("minecraft:compass", 1),
    "clock": ("minecraft:clock", 1),
    "map": ("minecraft:map", 1),
    "book": ("minecraft:book", 1),
    "bookshelf": ("minecraft:bookshelf", 1),
    "anvil": ("minecraft:anvil", 1),
    "enchanting table": ("minecraft:enchanting_table", 1),
    "enchanting_table": ("minecraft:enchanting_table", 1),
    "ender chest": ("minecraft:ender_chest", 1),
    "ender_chest": ("minecraft:ender_chest", 1),
    "glass": ("minecraft:glass", 1),
    "glass pane": ("minecraft:glass_pane", 16),
    "glass_pane": ("minecraft:glass_pane", 16),
    "paper": ("minecraft:paper", 3),
    "sugar": ("minecraft:sugar", 1),
    "bed": ("minecraft:white_bed", 1),
    "white bed": ("minecraft:white_bed", 1),
    "campfire": ("minecraft:campfire", 1),
    "tnt": ("minecraft:tnt", 1),
    "slime block": ("minecraft:slime_block", 1),
    "slime_block": ("minecraft:slime_block", 1),
}

TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "come_here",
            "description": "Leave work and come to the owner. ONLY when they explicitly say come here, come to me, come over, follow me, or bare come/here. NEVER for follow my pattern, keep laying, tracks, dig, craft, or other work.",
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
                        "description": "wood, coal, iron, copper, gold, redstone, lapis, diamond, emerald, quartz, debris, or food/meat",
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
            "name": "name",
            "description": "Rename the helper. Use when the owner says I name you X, your name is X, or call you X.",
            "parameters": {
                "type": "object",
                "properties": {"name": {"type": "string"}},
                "required": ["name"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "say",
            "description": "Short in-character reply to the owner (one sentence). Owner-only tellraw.",
            "parameters": {
                "type": "object",
                "properties": {
                    "text": {"type": "string"},
                },
                "required": ["text"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "craft",
            "description": "Craft a named item (any known craftable) and bring it to the owner. item is a plain name like stick, torch, rail, iron pickaxe.",
            "parameters": {
                "type": "object",
                "properties": {
                    "item": {"type": "string"},
                    "count": {"type": "integer", "description": "How many to deliver (default 1 stack worth of recipe output)"},
                },
                "required": ["item"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "dig_straight",
            "description": "Dig a straight 2-tall tunnel in the owner's look direction for N blocks.",
            "parameters": {
                "type": "object",
                "properties": {
                    "blocks": {"type": "integer", "description": "How many blocks forward to dig"},
                },
                "required": ["blocks"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "smelt",
            "description": "Return to base and smelt a named material (iron, gold, copper, debris, etc.).",
            "parameters": {
                "type": "object",
                "properties": {
                    "material": {"type": "string"},
                },
                "required": ["material"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "bring",
            "description": "Come to the owner now (deliver / come here with results).",
            "parameters": {"type": "object", "properties": {}},
        },
    },
    {
        "type": "function",
        "function": {
            "name": "lay_rails",
            "description": "Lay rails down a tunnel/path in the owner's look direction. Learns the owner's recent rail pattern (side lanes vs center, N normals then powered, redstone torch) and continues it. Use for lay rails, keep laying tracks, follow my pattern, finish the tunnel in my pattern, complete the tunnel with my pattern, continue pattern, same as I was doing, side tracks, rails down this tunnel, all the way to the end, entire tunnel. Phrases like all the way / to the end / entire tunnel mean keep going until the tunnel ends (blocks=10000), not a short default. NEVER use come_here for these. Optionally force powered/detector/activator.",
            "parameters": {
                "type": "object",
                "properties": {
                    "blocks": {"type": "integer", "description": "How many rails/steps to place. Default 512. Use 10000 (or omit with all-the-way phrasing) to continue until the tunnel naturally ends."},
                    "rail_type": {
                        "type": "string",
                        "description": "auto/pattern (default: learn from nearby rails), or rail/powered/detector/activator to force type",
                    },
                },
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "clear_wall_torches",
            "description": "Clear redstone torches along the tunnel per explicit targets/exceptions. Set clear_walls/clear_floor from the order (walls only, floor only, or both). Honor leave/keep/except/don't touch. NEVER dig or gather redstone ore for this.",
            "parameters": {
                "type": "object",
                "properties": {
                    "blocks": {"type": "integer", "description": "How far to walk clearing. Default 512. Use 10000 for all-the-way / entire tunnel."},
                    "clear_walls": {"type": "integer", "description": "1 to break redstone_wall_torch; 0 to leave walls."},
                    "clear_floor": {"type": "integer", "description": "1 to break floor redstone_torch; 0 to leave floor."},
                },
            },
        },
    },

    {
        "type": "function",
        "function": {
            "name": "clear_rails",
            "description": "Owner-only cleanup: strip bad/gappy rail work along look without destroying a good continuous dual-side sample. Phrases: undo the bad rails, clean up the messed rails, remove the bad tracks, strip the messed rails. Skips good sample; clears rails/powered/center floor redstone torches through the mess; stops if good pattern resumes. Does NOT restart laying.",
            "parameters": {
                "type": "object",
                "properties": {
                    "blocks": {"type": "integer", "description": "How far to walk cleaning. Default 256."},
                },
            },
        },
    },


    {
        "type": "function",
        "function": {
            "name": "repair_rails",
            "description": "Walk the tunnel from the owner and replace missing/broken minecart rails along the learned pattern (side vs center, powered spacing). Phrases: repair the tracks, fix the rails, replace missing rails/tracks, fill in the missing tracks. Uses setblock like other rail jobs (visual inventory). Does NOT strip good rails or clear rails. Prefer this over lay_rails when they want gaps fixed rather than extending the tip.",
            "parameters": {
                "type": "object",
                "properties": {
                    "blocks": {"type": "integer", "description": "Max blocks to walk while repairing. Default 512; 10000 = until end."},
                },
            },
        },
    },

    {
        "type": "function",
        "function": {
            "name": "kill_player",
            "description": "Hunt and kill a named online player. Journeys on foot/horse/boat; may tunnel. Never teleports onto them.",
            "parameters": {
                "type": "object",
                "properties": {
                    "player": {"type": "string", "description": "Exact player name"},
                },
                "required": ["player"],
            },
        },
    },
]

SYSTEM = """You are the brain of a named Minecraft helper (an armored companion bound to one player).
You only output tool calls. You do not control blocks yourself; the body runs skills.
All say replies are private (owner-only tellraw).

Skills you can queue (they run in order):
- come_here / bring: ONLY explicit come-here / follow me / come to me. Never for 'follow my pattern' or laying tracks (use lay_rails).
- stay_home: remain at base.
- stop: cancel jobs including hunts.
- set_base: owner's current spot is home.
- cut_trees / gather: mine resource or hunt animals for food, then return.
- place_chest: chest at base.
- raid_here: kill pillagers at owner's location.
- craft: craft an arbitrary known item (stick, torch, rail, tools, …) and bring it.
- dig_straight: dig straight N blocks in the owner's facing direction.
- clear_rails: undo/clean messed rails along look (skips good continuous sample; strips gappy bad stretch + center floor torches only). Does not restart laying.
- repair_rails: fix/replace missing rails along the existing track from where the owner stands (fill gaps). Prefer over lay_rails for "repair the tracks" / "fix the rails".
- clear_wall_torches: clear redstone torches per order — set clear_walls/clear_floor from targets and leave/keep/except. 'leave floor' → walls only; 'all torches' → both; 'floor but leave walls' → floor only. Never dig/gather for this.
- lay_rails: continue the owner's rail pattern down the tunnel (side lanes, powered spacing, torches). 'All the way' / 'to the end' / 'entire tunnel' / 'finish the tunnel in my pattern' / keep laying without a number → continue until tunnel ends (or owner stop). Default length is long; do not invent a short cap.
- smelt: return to base and smelt iron/gold/copper/debris/etc.
- kill_player: hunt a named online player. Journey on foot/horse/boat; may tunnel. NEVER teleport onto the victim.
- say: brief confirmation.

If they chain tasks, emit several tools in order.
Refuse impossible work with say.
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


# Hard ban: never broadcast helper/test traffic to all players.
# `say` and bare `tellraw @a` show up as public chat. Owner tips/acks must use
# tellraw @a[name=…] / @a[tag=helper.owner…] / @s only.
_PUBLIC_CHAT_RE = re.compile(
    r"(?:^|[;])say\b"  # bare say at start / after ;
    r"|(?:^|[\s;])run\s+say\b"  # execute … run say
    r"|tellraw\s+@a(?!\[)"  # tellraw @a without selector filters
    r"|tellraw\s+@a\[limit\s*="  # tellraw @a[limit=1] — not owner-bound
)


def _reject_public_chat(command: str) -> str | None:
    """Return a reason if command would be visible to everyone in chat."""
    c = (command or "").strip()
    if not c:
        return None
    if _PUBLIC_CHAT_RE.search(c):
        return f"refused public chat RCON: {c[:120]}"
    return None


class Rcon:
    def __init__(self, host: str, port: int, password: str) -> None:
        self.host = host
        self.port = port
        self.password = password

    def cmd(self, command: str) -> str:
        bad = _reject_public_chat(command)
        if bad:
            print(bad, flush=True)
            return ""
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
        self.rcon = Rcon(host, port, password)
        self.world = Path(env("HELPER_WORLD_PATH", "/opt/minecraft/world"))
        self._private_tip_at: dict[str, float] = {}
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

    def enqueue(self, player: str, job: str, interrupt: bool = False, gtype: int = 0) -> str:
        n = JOBS[job]
        sel = player_selector(player)
        # come_here must always reach the datapack (forceload + death→respawn).
        if job == "come_here":
            return self._come_here(player, sel)
        if not self.ensure_helper_loaded():
            self.say(player, "I cannot find your helper. Stand near it or spawn again.")
            return "cannot find"
        self.rcon.cmd(f"scoreboard players set #gtype helper_config {gtype}")
        self.rcon.cmd(f"scoreboard players set #job helper_config {n}")
        fn = "helper:jobs/force" if interrupt else "helper:jobs/enqueue"
        return self.rcon.cmd(f"execute as {sel} run function {fn}")

    def _helper_loaded(self) -> bool:
        out = self.rcon.cmd("execute if entity @e[tag=helper.active]")
        return bool(out) and "Test passed" in out or (out or "").startswith("True")

    def _come_here(self, player: str, sel: str) -> str:
        # Datapack owns forceload + death→respawn. Prefer cmd_here; fall back to bring_here.
        self.ensure_helper_loaded()
        out = self.rcon.cmd(f"execute as {sel} at @s run function helper:cmd_here")
        time.sleep(0.5)
        loaded = self.rcon.cmd("execute if entity @e[tag=helper.active]")
        if loaded and "passed" in loaded.lower():
            self.rcon.cmd(f"execute as {sel} at @s run tp @e[tag=helper.active] @s")
            self.rcon.cmd(
                "execute as @e[tag=helper.active] run scoreboard players set @s helper_mode 3"
            )
            # cmd_here already owner-tellraws; avoid duplicate chat when possible.
            return out or loaded
        # Give async recall a couple seconds (chunk load / respawn).
        for _ in range(6):
            time.sleep(0.5)
            loaded = self.rcon.cmd("execute if entity @e[tag=helper.active]")
            if loaded and "passed" in loaded.lower():
                self.rcon.cmd(f"execute as {sel} at @s run tp @e[tag=helper.active] @s")
                return loaded
        self.rcon.cmd(f"execute as {sel} at @s run function helper:jobs/bring_here")
        time.sleep(3.5)
        loaded = self.rcon.cmd("execute if entity @e[tag=helper.active]")
        if loaded and "passed" in loaded.lower():
            return loaded
        self.say(player, "Still looking for your helper — try /trigger helper_cmd set 7")
        return "cannot find"

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

    def fallback(self, text: str) -> list[tuple[str, dict]]:
        calls = self.keyword_orders(text)
        if not calls:
            t = (text or "").lower()
            if re.search(
                r"\b(?:rail|track|pattern|tunnel)\b",
                t,
            ) and re.search(
                r"\b(?:finish|complete|lay|keep|continue|follow|pattern)\b",
                t,
            ):
                calls.append(("lay_rails", {"blocks": 10000, "rail_type": "auto"}))
            else:
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

    def resolve_recipe(self, item: str) -> tuple[str, int] | None:
        key = re.sub(r"\s+", " ", item.lower().strip().replace("-", " "))
        key = key.replace("minecraft:", "")
        if key in RECIPES:
            return RECIPES[key]
        # underscored form
        uk = key.replace(" ", "_")
        if uk in RECIPES:
            return RECIPES[uk]
        # Also accept raw minecraft:id only when already in RECIPES values
        mid = key if key.startswith("minecraft:") else f"minecraft:{uk}"
        for iid, n in RECIPES.values():
            if iid == mid:
                return (iid, n)
        return None

    def start_dig(self, player: str, blocks: int, keep: bool = False, store: bool = False) -> str:
        blocks = max(1, min(int(blocks), 2000))
        sel = player_selector(player)
        if not self.ensure_helper_loaded():
            self.say(player, "I cannot find your helper.")
            return "cannot find"
        # #dig_keep 1: dig_start must not teleport onto the owner (further / keep digging).
        # #dig_store 1: deposit drops into a work-face chest, not the job-6 wood dump.
        self.rcon.cmd(f"scoreboard players set #dig helper_config {blocks}")
        self.rcon.cmd(f"scoreboard players set #dig_keep helper_config {1 if keep else 0}")
        self.rcon.cmd(f"scoreboard players set #dig_store helper_config {1 if store else 0}")
        print(f"dig_straight blocks={blocks} keep={int(bool(keep))} store={int(bool(store))} by {player}", flush=True)
        if keep and store:
            self.say(player, f"Continuing the tunnel for {blocks} blocks and putting drops in a chest.")
        elif keep:
            self.say(player, f"Continuing the tunnel for {blocks} blocks.")
        elif store:
            self.say(player, f"Digging {blocks} blocks and putting drops in a chest.")
        return self.rcon.cmd(f"execute as {sel} at @s run function helper:jobs/dig_start")

    def start_smelt(self, player: str, material: str) -> str:
        mat = material.lower().strip()
        gtype = GTYPES.get(mat, GTYPES.get(mat.replace(" ", "_"), 3))
        return self.enqueue(player, "smelt", interrupt=True, gtype=gtype)

    def start_craft(self, player: str, item: str, count: int | None = None) -> str:
        recipe = self.resolve_recipe(item)
        if not recipe:
            self.say(player, f"I don't know how to craft {item}.")
            return "unknown"
        item_id, per_craft = recipe
        # count = how many items to deliver
        n = int(count) if count else per_craft
        n = max(1, min(n, 64))
        sel = player_selector(player)
        if not self.ensure_helper_loaded():
            self.say(player, "I cannot find your helper.")
            return "cannot find"
        # storage helper:craft {item, count}
        safe_id = item_id.replace("\\", "").replace('"', "")
        self.rcon.cmd(
            f'data modify storage helper:craft item set value "{safe_id}"'
        )
        self.rcon.cmd(f"data modify storage helper:craft count set value {n}")
        self.rcon.cmd("scoreboard players set #job helper_config 10")
        self.rcon.cmd("scoreboard players set #gtype helper_config 0")
        out = self.rcon.cmd(f"execute as {sel} run function helper:jobs/force")
        self.say(player, f"Crafting {n}× {item_id.replace('minecraft:', '')} — coming to you.")
        return out



    def start_clear_rails(self, player: str, blocks: int | None = None) -> str:
        n = int(blocks) if blocks else 256
        n = max(1, min(n, 10000))
        sel = player_selector(player)
        if not self.ensure_helper_loaded():
            self.say(player, "I cannot find your helper.")
            return "cannot find"
        self.rcon.cmd(f"scoreboard players set #dig helper_config {n}")
        out = self.rcon.cmd(
            f"execute as {sel} at @s run function helper:jobs/clear_rails_start"
        )
        print(f"clear_rails {n} by {player}", flush=True)
        self.say(
            player,
            f"Cleaning messed rails up to {n} blocks along your look — skipping good continuous sample. Say stop to cancel. I will not restart laying.",
        )
        return out


    def start_repair_rails(self, player: str, blocks: int | None = None) -> str:
        n = int(blocks) if blocks else 512
        n = max(1, min(n, 10000))
        sel = player_selector(player)
        if not self.ensure_helper_loaded():
            self.say(player, "I cannot find your helper.")
            return "cannot find"
        self.rcon.cmd(f"scoreboard players set #dig helper_config {n}")
        out = self.rcon.cmd(
            f"execute as {sel} at @s run function helper:jobs/repair_rails_start"
        )
        print(f"repair_rails {n} by {player}", flush=True)
        self.say(
            player,
            f"Repairing missing rails up to {n} blocks from here — say stop to cancel.",
        )
        return out

    def start_clear_wall_torches(
        self,
        player: str,
        blocks: int | None = None,
        clear_walls: int | None = None,
        clear_floor: int | None = None,
    ) -> str:
        n = int(blocks) if blocks else 512
        n = max(1, min(n, 10000))
        if clear_walls is None and clear_floor is None:
            # Legacy LLM call with no flags — safer walls-only default
            cw, cf = 1, 0
        else:
            cw = 1 if clear_walls is None else (1 if int(clear_walls) else 0)
            cf = 0 if clear_floor is None else (1 if int(clear_floor) else 0)
        if cw == 0 and cf == 0:
            self.say(player, "Nothing to clear — say walls, floor, or all.")
            return "nothing"
        sel = player_selector(player)
        if not self.ensure_helper_loaded():
            self.say(player, "I cannot find your helper.")
            return "cannot find"
        self.rcon.cmd(f"scoreboard players set #dig helper_config {n}")
        self.rcon.cmd(f"scoreboard players set #clear_walls helper_config {cw}")
        self.rcon.cmd(f"scoreboard players set #clear_floor helper_config {cf}")
        out = self.rcon.cmd(
            f"execute as {sel} at @s run function helper:jobs/clear_wall_torches_start"
        )
        if cw and cf:
            summary = "Clearing all redstone torches (walls and floor)."
        elif cw:
            summary = "Clearing wall torches only; leaving floor."
        else:
            summary = "Clearing floor torches only; leaving walls."
        print(f"clear_torches walls={cw} floor={cf} n={n} by {player}", flush=True)
        self.say(player, summary)
        return out

    def start_lay_rails(self, player: str, blocks: int | None = None, rail_type: str = "") -> str:
        # 512 default; 10000 = continue until tunnel naturally ends (or owner stop)
        n = int(blocks) if blocks else 512
        n = max(1, min(n, 10000))
        sel = player_selector(player)
        if not self.ensure_helper_loaded():
            self.say(player, "I cannot find your helper.")
            return "cannot find"
        rtype = (rail_type or "").lower().strip().replace(" ", "_")
        type_map = {
            "": 0,
            "rail": 0,
            "rails": 0,
            "normal": 0,
            "iron": 0,
            "powered": 1,
            "powered_rail": 1,
            "powered_rails": 1,
            "detector": 2,
            "detector_rail": 2,
            "activator": 3,
            "activator_rail": 3,
        }
        # 0 means "auto-detect from nearby demo rails" — leave #brain_rail at 0
        brain_type = type_map.get(rtype, 0)
        # If caller explicitly said powered/etc, force; if plain "rail", also force normal (1 would be wrong)
        # Use #brain_rail: 0=auto, 10+gtype to force including normal (10=rail, 11=powered…)
        # auto/empty/plain rail → detect from nearby blocks; powered/detector/activator force
        if rtype in {"", "auto", "rail", "rails", "normal", "iron"}:
            self.rcon.cmd("scoreboard players set #brain_rail helper_config 0")
        else:
            force = 10 + brain_type
            self.rcon.cmd(f"scoreboard players set #brain_rail helper_config {force}")
        self.rcon.cmd(f"scoreboard players set #dig helper_config {n}")
        out = self.rcon.cmd(f"execute as {sel} at @s run function helper:jobs/rail_start")
        print(f"lay_rails {n} type={rtype or 'auto'} by {player}", flush=True)
        if n >= 5000:
            self.say(player, "Laying until the tunnel ends (or you tell me to stop).")
        elif blocks is None:
            self.say(player, f"Laying rails for up to {n} blocks — say stop when done.")
        # Pattern learn may find nothing — rail_start still forces job 12 with plain rails.
        # Never fall back to come_here; tell owner if RCON looks empty.
        low = (out or "").lower()
        if not out or "unknown function" in low or "incorrect" in low:
            self.say(player, "Starting rail lay (pattern fallback).")
            print(f"lay_rails fallback note for {player}: {out!r}", flush=True)
        return out

    def start_hunt(self, player: str, target: str) -> str:
        if not self.is_owner(player):
            print(f"hunt denied for non-owner {player}", flush=True)
            return "not_owner"
        target_raw = re.sub(r"[^A-Za-z0-9_]", "", target)[:16]
        if not target_raw or target_raw.lower() in KILL_TARGET_STOPWORDS:
            self.say(player, "Name a player to hunt.")
            return "bad"
        resolved = self.resolve_online_player(target_raw)
        if not resolved:
            self.say(player, f"{target_raw} is not online.")
            return "offline"
        target = resolved
        if target.lower() == player.lower():
            self.say(player, "I will not hunt you.")
            return "self"
        sel = player_selector(player)
        if not self.ensure_helper_loaded():
            self.say(player, "I cannot find your helper.")
            return "cannot find"
        self.rcon.cmd("tag @a remove helper.hunt_victim")
        self.rcon.cmd(f"tag @a[name={target},limit=1] add helper.hunt_victim")
        out = self.rcon.cmd(f"execute as {sel} run function helper:jobs/hunt_start")
        print(f"hunt {target} ordered by {player}", flush=True)
        return out


    def apply(self, player: str, calls: list[tuple[str, dict]], order: str = "") -> None:
        said = False
        failed = False
        for name, args in calls:
            if name == "name":
                if order and not re.search(
                    r"name you|call you|your name is|rename", order, re.I
                ):
                    continue
                self.set_name(player, str(args.get("name", "Helper")))
                said = True
                continue
            if name == "say":
                self.say(player, str(args.get("text", "Okay.")))
                said = True
                continue
            if name == "craft":
                out = self.start_craft(
                    player,
                    str(args.get("item", "")),
                    args.get("count"),
                )
                said = True
                if out in {"cannot find", "unknown"}:
                    failed = True
                continue
            if name == "dig_straight":
                out = self.start_dig(
                    player,
                    int(args.get("blocks", 16)),
                    keep=bool(args.get("keep")),
                    store=bool(args.get("store")),
                )
                if out == "cannot find":
                    failed = True
                continue
            if name == "clear_rails":
                out = self.start_clear_rails(player, args.get("blocks"))
                if out == "cannot find":
                    failed = True
                continue
            if name == "repair_rails":
                out = self.start_repair_rails(player, args.get("blocks"))
                if out == "cannot find":
                    failed = True
                continue
            if name == "clear_wall_torches":
                out = self.start_clear_wall_torches(
                    player,
                    args.get("blocks"),
                    args.get("clear_walls"),
                    args.get("clear_floor"),
                )
                if out == "cannot find":
                    failed = True
                continue
            if name == "lay_rails":
                out = self.start_lay_rails(
                    player,
                    args.get("blocks"),
                    str(args.get("rail_type", "")),
                )
                if out == "cannot find":
                    failed = True
                continue
            if name == "smelt":
                out = self.start_smelt(player, str(args.get("material", "iron")))
                continue
            if name == "bring":
                out = self.enqueue(player, "come_here", interrupt=True)
                continue
            if name == "kill_player":
                out = self.start_hunt(player, str(args.get("player", "")))
                said = True
                continue
            if name == "gather":
                resource = str(args.get("resource", "wood")).lower()
                gtype = GTYPES.get(resource, 1)
                out = self.enqueue(player, "cut_trees", gtype=gtype)
            elif name == "cut_trees":
                out = self.enqueue(player, "cut_trees", gtype=1)
            elif name in JOBS:
                out = self.enqueue(
                    player,
                    name,
                    interrupt=name in {"come_here", "stop", "stay_home", "smelt", "hunt"},
                )
            else:
                continue
            low_out = (out or "").lower()
            if "do not have a helper" in low_out or "cannot find" in low_out:
                failed = True
        if failed:
            return
        job_names = {n for n, _ in calls}
        if job_names & {"come_here", "stay_home", "stop", "bring", "kill_player", "craft"}:
            return
        if not said and calls:
            self.say(player, "On it.")

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
                r"keep|continue|pattern|track|finish|complete)\b",
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
            self.apply(player, direct, order=body)
            return
        self.apply(player, self.llm(player, body), order=body)


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


