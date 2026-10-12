"""Chest organizing planner (pure Python, no I/O).

Input: the container snapshot written by helper:api/organize_scan
  chests = [{x,y,z, half: 0 single/barrel | 1 left | 2 right, facing: 0 n 1 e 2 s 3 w 4 other,
             items: [{Slot, id, count, components?}, ...]}, ...]
Output: plans[i] = [{s: dest slot, f: source container, g: source slot, c: count}, ...] per
container, consumed by helper:api/organize_apply, which copies item f/g from the snapshot
(all components), sets Slot=s and count=c, and replaces the container's Items.

Guarantees (checked by verify_plan before anything is sent, and by the tests):
  * per-item totals are identical before and after (nothing created, nothing lost)
  * an entry's source is always an item with the same identity (id + components)
  * stacks never exceed the item's stack size; slots are 0..26 and unique per container
  * deterministic: the same snapshot always gives the same plan
Scopes:
  ahead (1): each unit (barrel, single chest, or both halves of a double chest) is sorted
             and compacted on its own; items never move between units.
  base  (2): everything in range is pooled and laid out in sorted order across units,
             starting each category in a fresh unit when there is room to spare.
"""
from __future__ import annotations

from dataclasses import dataclass

import snbt

SLOTS = 27
SCOPE_AHEAD = 1
SCOPE_BASE = 2

# Category order, carried over from the old storage-room labels.
CATEGORIES: list[tuple[str, tuple[str, ...]]] = [
    ("iron", ("iron_ingot", "raw_iron", "iron_ore", "deepslate_iron_ore", "iron_nugget", "iron_block", "raw_iron_block")),
    ("gold", ("gold_ingot", "raw_gold", "gold_ore", "deepslate_gold_ore", "nether_gold_ore", "gold_nugget", "gold_block", "raw_gold_block")),
    ("diamond", ("diamond", "diamond_ore", "deepslate_diamond_ore", "diamond_block")),
    ("netherite", ("netherite_ingot", "netherite_scrap", "ancient_debris", "netherite_block")),
    ("coal", ("coal", "charcoal", "coal_ore", "deepslate_coal_ore", "coal_block")),
    ("redstone", ("redstone", "redstone_ore", "deepslate_redstone_ore", "redstone_block", "redstone_torch", "repeater", "comparator")),
    ("lapis", ("lapis_lazuli", "lapis_ore", "deepslate_lapis_ore", "lapis_block")),
    ("emerald", ("emerald", "emerald_ore", "deepslate_emerald_ore", "emerald_block")),
    ("copper", ("copper_ingot", "raw_copper", "copper_ore", "deepslate_copper_ore", "copper_block", "raw_copper_block")),
    ("raw_food", ("beef", "porkchop", "chicken", "mutton", "rabbit", "cod", "salmon", "potato", "carrot", "wheat", "beetroot")),
    ("cooked", ("cooked_beef", "cooked_porkchop", "cooked_chicken", "cooked_mutton", "cooked_rabbit", "cooked_cod", "cooked_salmon", "baked_potato")),
    ("food", ("bread", "apple", "golden_apple", "golden_carrot", "melon_slice", "cookie", "pumpkin_pie", "sweet_berries", "glow_berries", "honey_bottle")),
]
_SUFFIX_CATEGORIES = [
    ("tools", ("_pickaxe", "_axe", "_shovel", "_hoe", "shears", "flint_and_steel", "fishing_rod")),
    ("weapons", ("_sword", "bow", "crossbow", "trident", "arrow", "mace")),
    ("armor", ("_helmet", "_chestplate", "_leggings", "_boots", "shield", "elytra")),
    ("blocks", ("_log", "_planks", "_wood", "stone", "cobblestone", "deepslate", "dirt", "sand", "gravel", "granite", "diorite", "andesite", "tuff", "netherrack", "glass", "_bricks", "brick")),
]
CATEGORY_NAMES = [c for c, _ in CATEGORIES] + [c for c, _ in _SUFFIX_CATEGORIES] + ["misc"]
_EXACT = {f"minecraft:{i}": n for n, ids in CATEGORIES for i in ids}


def category(item_id: str) -> int:
    if item_id in _EXACT:
        return CATEGORY_NAMES.index(_EXACT[item_id])
    short = item_id.split(":", 1)[-1]
    for name, pats in _SUFFIX_CATEGORIES:
        for p in pats:
            if (p.startswith("_") and short.endswith(p)) or short == p or (not p.startswith("_") and short.endswith("_" + p)):
                return CATEGORY_NAMES.index(name)
    return CATEGORY_NAMES.index("misc")


class PlanError(ValueError):
    pass


@dataclass
class Stack:
    container: int
    slot: int
    ident: str
    item_id: str
    count: int
    cap_hint: int | None


def identity(item: dict) -> str:
    """Everything except Slot and count, canonicalised."""
    rest = {k: v for k, v in item.items() if k not in ("Slot", "count")}
    return snbt.dumps(rest)


def _int(v) -> int:
    return int(v.value) if isinstance(v, snbt.Num) else int(v)


def read_stacks(chests: list[dict]) -> list[Stack]:
    out: list[Stack] = []
    for ci, ch in enumerate(chests):
        seen: set[int] = set()
        for it in ch.get("items") or []:
            slot = _int(it.get("Slot", -1))
            count = _int(it.get("count", 1))
            if not 0 <= slot < SLOTS or slot in seen:
                raise PlanError(f"container {ci}: bad or duplicate slot {slot}")
            if count < 1:
                raise PlanError(f"container {ci}: bad count {count}")
            seen.add(slot)
            comps = it.get("components") or {}
            mss = comps.get("minecraft:max_stack_size") if isinstance(comps, dict) else None
            out.append(Stack(ci, slot, identity(it), str(it.get("id", "")), count, _int(mss) if mss is not None else None))
    return out


# Items known to stack to 64 (vanilla). Anything else is only merged up to what it has
# been seen holding, unless a stack already proves 64.
KNOWN_64 = set(_EXACT) - {"minecraft:honey_bottle"}
KNOWN_64_SUFFIX = ("_log", "_planks", "_wood", "_ore", "_ingot", "_nugget", "_block", "_bricks", "_slab",
                   "_stairs", "_wool", "_concrete", "_terracotta", "_glass", "_sapling", "_leaves")
KNOWN_64_EXACT = {f"minecraft:{i}" for i in (
    "cobblestone", "stone", "dirt", "sand", "gravel", "deepslate", "cobbled_deepslate", "granite", "diorite",
    "andesite", "tuff", "netherrack", "glass", "stick", "torch", "string", "feather", "gunpowder", "bone",
    "bone_meal", "flint", "leather", "paper", "book", "rail", "powered_rail", "detector_rail", "activator_rail",
    "redstone_torch", "slime_ball", "arrow", "rotten_flesh", "spider_eye", "clay_ball", "brick", "quartz",
    "amethyst_shard", "obsidian", "ladder", "chest", "furnace", "crafting_table", "hopper",
    "wheat_seeds", "pumpkin", "melon", "sugar_cane", "cactus", "kelp", "glowstone_dust", "blaze_rod",
    "ender_eye", "prismarine_shard", "copper_ingot", "charcoal", "coal")}


def known_64(item_id: str) -> bool:
    return item_id in KNOWN_64 or item_id in KNOWN_64_EXACT or item_id.endswith(KNOWN_64_SUFFIX)


def stack_caps(stacks: list[Stack]) -> dict[str, int]:
    """Never larger than the real stack size: the max_stack_size component if present;
    64 for items known to stack to 64 or already seen above 16 (vanilla sizes are 1, 16,
    64); otherwise the largest stack seen (merging may be incomplete, never overfull)."""
    caps: dict[str, int] = {}
    for s in stacks:
        if s.cap_hint is not None:
            caps[s.ident] = s.cap_hint
            continue
        caps[s.ident] = max(caps.get(s.ident, 0), s.count)
    for s in stacks:
        if s.cap_hint is None and (caps[s.ident] > 16 or known_64(s.item_id)):
            caps[s.ident] = 64
    return caps


def units(chests: list[dict]) -> list[list[int]]:
    """Group containers into units; a double chest's slot order is right half then left."""
    pos = {(_int(c["x"]), _int(c["y"]), _int(c["z"])): i for i, c in enumerate(chests)}
    dirs = {0: (0, -1), 1: (1, 0), 2: (0, 1), 3: (-1, 0)}
    used: set[int] = set()
    out: list[list[int]] = []
    for i, c in enumerate(chests):
        if i in used:
            continue
        half, facing = _int(c.get("half", 0)), _int(c.get("facing", 4))
        if half in (1, 2) and facing in dirs:
            # left half: partner is clockwise of facing; right half: counter-clockwise
            d = dirs[(facing + 1) % 4] if half == 1 else dirs[(facing + 3) % 4]
            j = pos.get((_int(c["x"]) + d[0], _int(c["y"]), _int(c["z"]) + d[1]))
            if j is not None and j not in used and _int(chests[j].get("half", 0)) == 3 - half and _int(chests[j].get("facing", 4)) == facing:
                right, left = (i, j) if half == 2 else (j, i)
                out.append([right, left])
                used.update((i, j))
                continue
        out.append([i])
        used.add(i)
    return out


def _sorted_stacks(stacks: list[Stack], caps: dict[str, int]) -> list[tuple[str, int, Stack]]:
    """Merge by identity and split into full stacks, in sort order. Returns (ident, count, rep)."""
    total: dict[str, int] = {}
    rep: dict[str, Stack] = {}
    for s in stacks:
        total[s.ident] = total.get(s.ident, 0) + s.count
        r = rep.get(s.ident)
        if r is None or (s.container, s.slot) < (r.container, r.slot):
            rep[s.ident] = s
    out = []
    for ident in sorted(total, key=lambda k: (category(rep[k].item_id), rep[k].item_id, k)):
        n, cap = total[ident], caps[ident]
        while n > 0:
            c = min(n, cap)
            out.append((ident, c, rep[ident]))
            n -= c
    return out


def _place(seq, unit_list: list[list[int]], plans: list[list[dict]], group_categories: bool) -> None:
    slots = [(u, ci, s) for u, unit in enumerate(unit_list) for ci in unit for s in range(SLOTS)]
    unit_start = {}
    for idx, (u, _ci, _s) in enumerate(slots):
        unit_start.setdefault(u, idx)
    if len(seq) > len(slots):
        raise PlanError("items do not fit (should be impossible)")
    pos = 0
    prev_cat = None
    for k, (ident, count, rep) in enumerate(seq):
        cat = category(rep.item_id)
        if group_categories and prev_cat is not None and cat != prev_cat:
            u = slots[pos][0] if pos < len(slots) else None
            if u is not None and pos != unit_start[u]:
                nxt = next((unit_start[v] for v in range(u + 1, len(unit_list))), None)
                if nxt is not None and len(slots) - nxt >= len(seq) - k:
                    pos = nxt
        _u, ci, s = slots[pos]
        plans[ci].append({"s": s, "f": rep.container, "g": rep.slot, "c": count})
        pos += 1
        prev_cat = cat


def plan(chests: list[dict], scope: int) -> tuple[list[list[dict]], dict]:
    if scope not in (SCOPE_AHEAD, SCOPE_BASE):
        raise PlanError(f"bad scope {scope}")
    stacks = read_stacks(chests)
    caps = stack_caps(stacks)
    unit_list = units(chests)
    if scope == SCOPE_BASE:
        unit_list = sorted(unit_list, key=lambda u: tuple((-_int(chests[i]["y"]), _int(chests[i]["z"]), _int(chests[i]["x"])) for i in u[:1]))
    plans: list[list[dict]] = [[] for _ in chests]
    if scope == SCOPE_AHEAD:
        for unit in unit_list:
            members = set(unit)
            _place(_sorted_stacks([s for s in stacks if s.container in members], caps), [unit], plans, False)
    else:
        _place(_sorted_stacks(stacks, caps), unit_list, plans, True)
    stats = verify_plan(chests, plans, caps)
    return plans, stats


def verify_plan(chests: list[dict], plans: list[list[dict]], caps: dict[str, int] | None = None) -> dict:
    """Raise PlanError unless the plan conserves every item exactly. Returns stats:
    chests_found, moved (items that end up in a different container), sorted (containers
    whose contents change)."""
    stacks = read_stacks(chests)
    caps = caps or stack_caps(stacks)
    by_src = {(s.container, s.slot): s for s in stacks}
    if len(plans) != len(chests):
        raise PlanError("one plan per container required")
    before: dict[tuple[int, str], int] = {}
    after: dict[tuple[int, str], int] = {}
    for s in stacks:
        before[(s.container, s.ident)] = before.get((s.container, s.ident), 0) + s.count
    for d, entries in enumerate(plans):
        used: set[int] = set()
        for e in entries:
            s, f, g, c = (int(e[k]) for k in ("s", "f", "g", "c"))
            if not 0 <= s < SLOTS or s in used:
                raise PlanError(f"container {d}: bad or duplicate slot {s}")
            used.add(s)
            src = by_src.get((f, g))
            if src is None:
                raise PlanError(f"container {d}: source {f}/{g} does not exist")
            if not 1 <= c <= caps[src.ident]:
                raise PlanError(f"container {d}: count {c} outside 1..{caps[src.ident]}")
            after[(d, src.ident)] = after.get((d, src.ident), 0) + c
    tot_b: dict[str, int] = {}
    tot_a: dict[str, int] = {}
    for (_c, i), n in before.items():
        tot_b[i] = tot_b.get(i, 0) + n
    for (_c, i), n in after.items():
        tot_a[i] = tot_a.get(i, 0) + n
    if tot_b != tot_a:
        raise PlanError("plan does not conserve items")
    moved = sum(max(0, n - after.get(k, 0)) for k, n in before.items())
    changed = 0
    for d in range(len(chests)):
        old = sorted((s.slot, s.ident, s.count) for s in stacks if s.container == d)
        new = sorted((int(e["s"]), by_src[(int(e["f"]), int(e["g"]))].ident, int(e["c"])) for e in plans[d])
        changed += old != new
    return {"chests_found": len(chests), "moved": moved, "sorted": changed}


def apply_plan(chests: list[dict], plans: list[list[dict]]) -> list[list[dict]]:
    """Python model of helper:api/organize_apply: the Items each container ends with."""
    src = {(ci, _int(it["Slot"])): it for ci, ch in enumerate(chests) for it in ch.get("items") or []}
    out = []
    for entries in plans:
        items = []
        for e in entries:
            it = dict(src[(int(e["f"]), int(e["g"]))])
            it["Slot"] = snbt.Num(int(e["s"]), "b")
            it["count"] = snbt.Num(int(e["c"]), "i")
            items.append(it)
        out.append(items)
    return out


def plan_snbt(entries: list[dict]) -> str:
    return "[" + ",".join(f"{{s:{e['s']},f:{e['f']},g:{e['g']},c:{e['c']}}}" for e in entries) + "]"
