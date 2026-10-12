"""The helper's tool set: schemas, strict validation, and a dispatcher onto helper:api.

Every tool maps 1:1 onto a datapack entry point `helper:api/<fn>` (organize_chests uses the
scan + apply pair). The datapack re-checks everything (owner, helper loaded, mode, busy,
argument ranges) and writes `storage helper:api result {req, tool, ok, code, msg, ...}`;
the dispatcher reads it back, so the model sees exactly what the game decided.

Tool results are always: {"ok": bool, "error": str|None, "message": str, "state": {...}}
plus tool-specific fields (organize: chests_found, moved, sorted, reason).
"""
from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from typing import Any, Callable

import organize
import pattern_palette as PP
import snbt
from rcon_client import RconError

# --------------------------------------------------------------------------- vocab
RESOURCES = {  # gather resource -> helper_gtype
    "wood": 1, "coal": 2, "iron": 3, "copper": 4, "gold": 5, "redstone": 6, "lapis": 7,
    "diamond": 8, "emerald": 9, "quartz": 10, "ancient_debris": 11, "food": 12,
}
SMELT = {"coal": 2, "iron": 3, "copper": 4, "gold": 5, "ancient_debris": 11}
RAIL_ACTIONS = {"lay": 1, "repair": 2, "clear_bad": 3, "clear_torches": 4}
RAIL_TYPES = {"auto": 0, "rail": 1, "powered": 2, "detector": 3, "activator": 4}
ORGANIZE_SCOPES = {"ahead": 1, "base": 2}

# Craftable items: canonical name -> (item id, items per craft). The model may only pick
# from these names; aliases are resolved by resolve_recipe for keyword orders.
RECIPES: dict[str, tuple[str, int]] = {
    "stick": ("minecraft:stick", 4), "torch": ("minecraft:torch", 4),
    "crafting_table": ("minecraft:crafting_table", 1), "furnace": ("minecraft:furnace", 1),
    "chest": ("minecraft:chest", 1), "ladder": ("minecraft:ladder", 3),
    "oak_planks": ("minecraft:oak_planks", 4), "bread": ("minecraft:bread", 1),
    "bowl": ("minecraft:bowl", 4), "bucket": ("minecraft:bucket", 1),
    "shears": ("minecraft:shears", 1), "flint_and_steel": ("minecraft:flint_and_steel", 1),
    "shield": ("minecraft:shield", 1), "bow": ("minecraft:bow", 1), "arrow": ("minecraft:arrow", 4),
    "iron_ingot": ("minecraft:iron_ingot", 1), "gold_ingot": ("minecraft:gold_ingot", 1),
    "copper_ingot": ("minecraft:copper_ingot", 1), "iron_pickaxe": ("minecraft:iron_pickaxe", 1),
    "iron_sword": ("minecraft:iron_sword", 1), "iron_axe": ("minecraft:iron_axe", 1),
    "diamond_pickaxe": ("minecraft:diamond_pickaxe", 1), "diamond_sword": ("minecraft:diamond_sword", 1),
    "rail": ("minecraft:rail", 16), "powered_rail": ("minecraft:powered_rail", 6),
    "detector_rail": ("minecraft:detector_rail", 6), "activator_rail": ("minecraft:activator_rail", 6),
    "minecart": ("minecraft:minecart", 1), "oak_boat": ("minecraft:oak_boat", 1),
    "hopper": ("minecraft:hopper", 1), "piston": ("minecraft:piston", 1),
    "sticky_piston": ("minecraft:sticky_piston", 1), "observer": ("minecraft:observer", 1),
    "dispenser": ("minecraft:dispenser", 1), "dropper": ("minecraft:dropper", 1),
    "lever": ("minecraft:lever", 1), "redstone_torch": ("minecraft:redstone_torch", 1),
    "compass": ("minecraft:compass", 1), "clock": ("minecraft:clock", 1), "map": ("minecraft:map", 1),
    "book": ("minecraft:book", 1), "bookshelf": ("minecraft:bookshelf", 1), "anvil": ("minecraft:anvil", 1),
    "enchanting_table": ("minecraft:enchanting_table", 1), "ender_chest": ("minecraft:ender_chest", 1),
    "glass": ("minecraft:glass", 1), "glass_pane": ("minecraft:glass_pane", 16),
    "paper": ("minecraft:paper", 3), "sugar": ("minecraft:sugar", 1), "white_bed": ("minecraft:white_bed", 1),
    "campfire": ("minecraft:campfire", 1), "tnt": ("minecraft:tnt", 1), "slime_block": ("minecraft:slime_block", 1),
}
RECIPE_ALIASES = {
    "sticks": "stick", "torches": "torch", "ladders": "ladder", "planks": "oak_planks", "arrows": "arrow",
    "rails": "rail", "iron_rail": "rail", "iron_rails": "rail", "powered_rails": "powered_rail",
    "detector_rails": "detector_rail", "activator_rails": "activator_rail", "boat": "oak_boat",
    "bed": "white_bed", "table": "crafting_table", "workbench": "crafting_table",
}


def resolve_recipe(item: str) -> str | None:
    key = re.sub(r"[\s\-]+", "_", (item or "").lower().strip().replace("minecraft:", ""))
    key = RECIPE_ALIASES.get(key, key)
    return key if key in RECIPES else None


# --------------------------------------------------------------------------- schemas
def _obj(props: dict, required: list[str] | None = None) -> dict:
    return {"type": "object", "properties": props, "required": required or [], "additionalProperties": False}


_REPLACE = {"type": "boolean", "description": "Cancel the current job if busy (default true)."}

TOOL_SPECS: list[dict] = [
    {"name": "get_status", "description": "Read the helper's state: mode, job, queue, position, health, defending.",
     "parameters": _obj({})},
    {"name": "set_protect_follow", "description": "Turn protect-and-follow on/off (follows and defends the owner). come_now=true also brings the helper to the owner right away. Has no effect while stay_at_base is on.",
     "parameters": _obj({"on": {"type": "boolean"}, "come_now": {"type": "boolean", "description": "Teleport/walk to the owner now (needs on=true)."}}, ["on"])},
    {"name": "set_stay_at_base", "description": "Turn stay-at-base on/off. On: cancels work, goes home, no following or protecting; overrides protect_follow.",
     "parameters": _obj({"on": {"type": "boolean"}}, ["on"])},
    {"name": "set_base", "description": "Make the owner's current position the helper's base.",
     "parameters": _obj({})},
    {"name": "stop_work", "description": "Cancel the current job and queue. Modes are unchanged.",
     "parameters": _obj({})},
    {"name": "gather", "description": "Go mine/collect a resource near the owner (food = hunt animals).",
     "parameters": _obj({"resource": {"type": "string", "enum": list(RESOURCES)}, "replace": _REPLACE}, ["resource"])},
    {"name": "dig_tunnel", "description": "Dig a straight 2-high tunnel the way the owner is looking.",
     "parameters": _obj({"blocks": {"type": "integer", "minimum": 1, "maximum": 2000},
                         "continue_tunnel": {"type": "boolean", "description": "Continue the existing tunnel face instead of starting at the owner."},
                         "store_in_chest": {"type": "boolean", "description": "Put drops in a chest at the tunnel face."},
                         "replace": _REPLACE}, ["blocks"])},
    {"name": "rails", "description": "Rail work along the owner's look direction: lay (copies the nearby pattern), repair gaps, clear_bad (remove messed-up rails), clear_torches (remove wall/floor redstone torches).",
     "parameters": _obj({"action": {"type": "string", "enum": list(RAIL_ACTIONS)},
                         "blocks": {"type": "integer", "minimum": 1, "maximum": 10000, "description": "Max length; 10000 = until the tunnel ends. Default 512."},
                         "rail_type": {"type": "string", "enum": list(RAIL_TYPES), "description": "lay only; auto copies the pattern."},
                         "replace": _REPLACE}, ["action"])},
    {"name": "craft", "description": "Craft an item and bring it to the owner.",
     "parameters": _obj({"item": {"type": "string", "enum": list(RECIPES)},
                         "count": {"type": "integer", "minimum": 1, "maximum": 64, "description": "Items to deliver (default one craft's worth)."},
                         "replace": _REPLACE}, ["item"])},
    {"name": "smelt", "description": "Smelt ore at the base furnace (works while staying at base).",
     "parameters": _obj({"material": {"type": "string", "enum": list(SMELT)}, "replace": _REPLACE}, ["material"])},
    {"name": "organize_chests", "description": "Sort and stack chests/barrels. ahead = the containers right in front of the helper, each sorted on its own. base = all storage around the base, consolidated across chests; only works in stay_at_base mode.",
     "parameters": _obj({"scope": {"type": "string", "enum": list(ORGANIZE_SCOPES)}}, ["scope"])},
    {"name": "snapshot_slice", "description": "Capture the repeating tunnel segment behind the helper (rails, powered rails, torches, floor/walls), relative to its facing. Needed before stamp_pattern. You never describe the layout; the game reads it.",
     "parameters": _obj({"length": {"type": "integer", "minimum": 0, "maximum": PP.MAX_LENGTH, "description": "Segment length; 0 (default) = detect it."}})},
    {"name": "stamp_pattern", "description": "Repeat the captured segment forward from the helper (rotated to where it faces): fills floor/walls, then places rails and torches. Stops at undug or unloaded blocks.",
     "parameters": _obj({"blocks": {"type": "integer", "minimum": 1, "maximum": 64}}, ["blocks"])},
    {"name": "reply", "description": "Send your final short message to the owner and end your turn.",
     "parameters": _obj({"text": {"type": "string", "minLength": 1, "maxLength": 200}}, ["text"])},
]
TOOL_NAMES = [t["name"] for t in TOOL_SPECS]
_SPEC = {t["name"]: t for t in TOOL_SPECS}
# Not offered to the model; reachable only from explicit owner keyword commands.
ROUTER_ONLY = {
    "hunt_player": _obj({"player": {"type": "string", "pattern": r"^[A-Za-z0-9_]{3,16}$"}}, ["player"]),
    "raid_here": _obj({}),
    "store_items": _obj({}),
}
READ_ONLY = {"get_status", "reply", "snapshot_slice"}  # no world changes


def openai_tools() -> list[dict]:
    return [{"type": "function", "function": t} for t in TOOL_SPECS]


# --------------------------------------------------------------------------- validation
class ToolArgError(ValueError):
    pass


def validate(name: str, args: Any) -> dict:
    """Strict check against the schema: known tool, object args, no extra keys, exact types,
    enums and bounds. Returns args with defaults filled in."""
    schema = _SPEC[name]["parameters"] if name in _SPEC else ROUTER_ONLY.get(name)
    if schema is None:
        raise ToolArgError(f"unknown tool {name!r}; valid tools: {', '.join(TOOL_NAMES)}")
    if args is None:
        args = {}
    if not isinstance(args, dict):
        raise ToolArgError("arguments must be a JSON object")
    props = schema["properties"]
    extra = set(args) - set(props)
    if extra:
        raise ToolArgError(f"unexpected argument(s): {', '.join(sorted(extra))}")
    for req in schema["required"]:
        if req not in args:
            raise ToolArgError(f"missing required argument {req!r}")
    for k, v in args.items():
        p = props[k]
        t = p.get("type")
        if t == "boolean" and not isinstance(v, bool):
            raise ToolArgError(f"{k} must be true or false")
        if t == "integer":
            if isinstance(v, bool) or not isinstance(v, int):
                raise ToolArgError(f"{k} must be an integer")
            if not p.get("minimum", v) <= v <= p.get("maximum", v):
                raise ToolArgError(f"{k} must be between {p['minimum']} and {p['maximum']}")
        if t == "string":
            if not isinstance(v, str):
                raise ToolArgError(f"{k} must be a string")
            if "enum" in p and v not in p["enum"]:
                raise ToolArgError(f"{k} must be one of: {', '.join(p['enum'])}")
            if not p.get("minLength", 0) <= len(v) <= p.get("maxLength", 10**6):
                raise ToolArgError(f"{k} must be {p.get('minLength', 0)}..{p.get('maxLength')} characters")
            if "pattern" in p and not re.fullmatch(p["pattern"], v):
                raise ToolArgError(f"{k} has invalid characters")
    return dict(args)


# --------------------------------------------------------------------------- dispatcher
def _snbt_args(args: dict) -> str:
    parts = []
    for k, v in args.items():
        if isinstance(v, bool):
            parts.append(f"{k}:{int(v)}")
        elif isinstance(v, int):
            parts.append(f"{k}:{v}")
        else:
            parts.append(f"{k}:{json.dumps(str(v))}")
    return "{" + ",".join(parts) + "}"


@dataclass
class Dispatcher:
    """Runs validated tool calls for one owner through helper:api over RCON."""

    rcon: Any
    owner: str
    say: Callable[[str, str], None] = lambda owner, text: None
    ensure_loaded: Callable[[], bool] = lambda: False
    resolve_player: Callable[[str], str | None] = lambda name: name
    req: int = 0
    log: list = field(default_factory=list)

    def __post_init__(self) -> None:
        if not re.fullmatch(r"[A-Za-z0-9_]{1,16}", self.owner or ""):
            raise ValueError(f"bad owner name {self.owner!r}")

    # ----- public
    def call(self, name: str, args: Any = None) -> dict:
        try:
            args = validate(name, args)
        except ToolArgError as e:
            return self._result(False, "bad_args", str(e))
        try:
            out = getattr(self, f"_t_{name}")(**args)
        except RconError as e:
            return self._result(False, "rcon_error", f"Cannot reach the server: {e}")
        self.log.append((name, args, out))
        return out

    # ----- api plumbing
    def api(self, fn: str, **args) -> dict:
        """Call helper:api/<fn> once and return the parsed result compound."""
        self.req = self.req % 2_000_000_000 + 1
        req = self.req
        self.rcon.cmd("data remove storage helper:api result")
        self.rcon.cmd(
            f"execute as @a[name={self.owner},limit=1] at @s run function helper:api/{fn} "
            + _snbt_args({"req": req, **args})
        )
        raw = self.rcon.cmd("data get storage helper:api result")
        res = snbt.from_data_get(raw)
        if res is None:
            return {"ok": 0, "code": "owner_offline", "msg": "The owner is not online (or the datapack is not loaded)."}
        res = snbt.plain(res)
        if res.get("req") != req:
            return {"ok": 0, "code": "datapack_error", "msg": "The datapack returned a result for a different request."}
        return res

    def api_retry_unloaded(self, fn: str, **args) -> dict:
        res = self.api(fn, **args)
        if res.get("code") == "not_loaded" and self.ensure_loaded():
            res = self.api(fn, **args)
        return res

    def status(self) -> dict:
        self.api("status")
        st = snbt.from_data_get(self.rcon.cmd("data get storage helper:api status"))
        return snbt.plain(st) if isinstance(st, dict) else {}

    def _result(self, ok: bool, error: str | None, message: str, state: dict | None = None, **extra) -> dict:
        out = {"ok": ok, "error": None if ok else error, "message": message, "state": state or {}}
        out.update(extra)
        return out

    def _act(self, fn: str, observe: bool = True, **args) -> dict:
        res = self.api_retry_unloaded(fn, **args)
        ok = bool(res.get("ok"))
        state = self.status() if observe else {}
        return self._result(ok, res.get("code"), str(res.get("msg", "")), state, code=res.get("code"))

    # ----- tools
    def _t_get_status(self) -> dict:
        st = self.status()
        if not st:
            return self._result(False, "owner_offline", "No status (owner offline or datapack missing).")
        return self._result(True, None, f"mode={st.get('mode')} job={st.get('job')}", st)

    def _t_set_protect_follow(self, on: bool, come_now: bool = False) -> dict:
        return self._act("set_protect_follow", on=on, come_now=come_now)

    def _t_set_stay_at_base(self, on: bool) -> dict:
        return self._act("set_stay_at_base", on=on)

    def _t_set_base(self) -> dict:
        return self._act("set_base")

    def _t_stop_work(self) -> dict:
        return self._act("stop_work")

    def _t_gather(self, resource: str, replace: bool = True) -> dict:
        return self._act("gather", resource=RESOURCES[resource], replace=replace)

    def _t_dig_tunnel(self, blocks: int, continue_tunnel: bool = False, store_in_chest: bool = False, replace: bool = True) -> dict:
        return self._act("dig", blocks=blocks, keep=continue_tunnel, store=store_in_chest, replace=replace)

    def _t_rails(self, action: str, blocks: int = 512, rail_type: str = "auto", replace: bool = True) -> dict:
        if rail_type != "auto" and action != "lay":
            return self._result(False, "bad_args", "rail_type only applies to action=lay.")
        return self._act("rails", action=RAIL_ACTIONS[action], blocks=blocks, rail_type=RAIL_TYPES[rail_type], replace=replace)

    def _t_craft(self, item: str, count: int | None = None, replace: bool = True) -> dict:
        item_id, per = RECIPES[item]
        return self._act("craft", item=item_id, count=count or per, replace=replace)

    def _t_smelt(self, material: str, replace: bool = True) -> dict:
        return self._act("smelt", material=SMELT[material], replace=replace)

    def read_pattern(self) -> dict | None:
        pat = snbt.from_data_get(self.rcon.cmd("data get storage helper:api pattern"))
        return snbt.plain(pat) if isinstance(pat, dict) else None

    def _t_snapshot_slice(self, length: int = 0) -> dict:
        res = self.api_retry_unloaded("snapshot_slice", length=length)
        if not res.get("ok"):
            return self._result(False, res.get("code"), str(res.get("msg", "")), self.status(), code=res.get("code"))
        pat = self.read_pattern()
        if not pat or pat.get("palette") != PP.PALETTE_VERSION:
            return self._result(False, "datapack_error", "Pattern palette does not match this sidecar; update both together.")
        summary = summarize_pattern(pat)
        return self._result(True, None, summary["text"], self.status(), code="captured", pattern=summary)

    def _t_stamp_pattern(self, blocks: int) -> dict:
        res = self.api_retry_unloaded("stamp_pattern", blocks=blocks)
        ok = bool(res.get("ok"))
        extra = {k: res.get(k) for k in ("placed", "removed", "stopped_at", "reason")}
        extra["rotated"] = bool(res.get("rotated"))
        msg = str(res.get("msg", ""))
        if ok:
            msg = f"Stamped {blocks if not extra['stopped_at'] else extra['stopped_at'] - 1} blocks: placed {extra['placed']}, removed {extra['removed']}."
            if extra["stopped_at"]:
                msg += f" Stopped at block {extra['stopped_at']} ({extra['reason']})."
        return self._result(ok, res.get("code"), msg, self.status(), code=res.get("code"), **extra)

    def _t_reply(self, text: str) -> dict:
        self.say(self.owner, text)
        return self._result(True, None, "sent")

    def _t_hunt_player(self, player: str) -> dict:
        target = self.resolve_player(player)
        if not target:
            return self._result(False, "offline", f"{player} is not online.")
        return self._act("hunt", target=target)

    def _t_raid_here(self) -> dict:
        return self._act("raid", replace=True)

    def _t_store_items(self) -> dict:
        return self._act("store_items", replace=True)

    def _t_organize_chests(self, scope: str) -> dict:
        def done(ok, reason, msg, found=0, moved=0, sorted_=0):
            return self._result(ok, None if ok else reason, msg, self.status(),
                                chests_found=found, moved=moved, sorted=sorted_, reason=reason)

        res = self.api_retry_unloaded("organize_scan", scope=ORGANIZE_SCOPES[scope])
        if not res.get("ok"):
            return done(False, res.get("code"), str(res.get("msg", "")))
        found = int(res.get("chests_found", 0))
        if found == 0:
            return done(True, "no_chests", str(res.get("msg", "")))
        scan_req = int(res["req"])
        org = snbt.from_data_get(self.rcon.cmd("data get storage helper:api org"))
        if not isinstance(org, dict) or snbt.plain(org.get("req")) != scan_req:
            return done(False, "datapack_error", "Could not read the container scan.", found)
        chests = org.get("chests") or []
        try:
            plans, stats = organize.plan(chests, ORGANIZE_SCOPES[scope])
        except organize.PlanError as e:
            return done(False, "plan_error", f"Did not touch anything: {e}", found)
        if stats["sorted"] == 0:
            self.rcon.cmd("data remove storage helper:api org")
            return done(True, "already_sorted", "Already organized; nothing to do.", found)
        self.rcon.cmd("data modify storage helper:api org.plans set value []")
        for entries in plans:
            self.rcon.cmd("data modify storage helper:api org.plans append value " + organize.plan_snbt(entries))
        res = self.api("organize_apply", scan_req=scan_req)
        if not res.get("ok"):
            return done(False, res.get("code"), str(res.get("msg", "")), found)
        return done(True, "organized", str(res.get("msg", "")), found, stats["moved"], stats["sorted"])


def summarize_pattern(pat: dict) -> dict:
    """Human/model-readable view of storage helper:api pattern (the model never edits it)."""
    cells = pat.get("cells") or []
    features = []
    counts: dict[str, int] = {}
    for d, sl in enumerate(cells):
        for c, code in enumerate(sl):
            if code >= PP.FIRST_CODE:
                x, y = PP.cell_pos(c)
                name = PP.describe(code)
                features.append({"slice": d, "x": x, "y": y, "block": name})
                key = name.split(" ")[0]
                counts[key] = counts.get(key, 0) + 1
    facing = PP.DIRS[pat.get("facing", 0) % 4]
    length = int(pat.get("length", len(cells)))
    parts = [f"{n} {k}" for k, n in sorted(counts.items())] or ["no rails or torches"]
    text = f"Captured a {length}-block segment facing {facing}: " + ", ".join(parts) + (
        "." if pat.get("verified") else " (only one period seen, not verified).")
    return {"facing": facing, "length": length, "verified": bool(pat.get("verified")),
            "counts": counts, "features": features[:40], "text": text}
