"""Static checks for the datapack plus small simulations of the logic that matters most.

Runs without Minecraft: references, JSON, macro arguments, generated files, mode precedence
(stay_at_base > protect_follow), stay gates on the API, and safe-spot selection.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
DP = ROOT / "datapack"
FN = DP / "data/helper/function"
sys.path.insert(0, str(ROOT / "tools"))
import datapack_gen  # noqa: E402
import pattern_palette as PP  # noqa: E402


def functions() -> dict[str, Path]:
    return {
        "helper:" + p.relative_to(FN).with_suffix("").as_posix(): p
        for p in FN.rglob("*.mcfunction")
    }


FUNCS = functions()
MACRO_ARG = re.compile(r"\$\((\w+)\)")
CALL = re.compile(r"function (helper:[\w/]+)(?:\s+(\{[^}]*\}|with \S+ \S+))?")


def lines(name: str) -> list[str]:
    return [l for l in FUNCS[name].read_text(encoding="utf-8").splitlines()]


def code(name: str) -> list[str]:
    return [l for l in lines(name) if l.strip() and not l.lstrip().startswith("#")]


def macro_params(name: str) -> set[str]:
    out: set[str] = set()
    for l in code(name):
        if l.startswith("$"):
            out |= set(MACRO_ARG.findall(l))
    return out


# --------------------------------------------------------------------------- static checks
def test_all_json_valid():
    bad = []
    for p in DP.rglob("*.json"):
        try:
            json.loads(p.read_text(encoding="utf-8"))
        except ValueError as e:
            bad.append(f"{p.relative_to(ROOT)}: {e}")
    try:
        json.loads((DP / "pack.mcmeta").read_text(encoding="utf-8"))
    except ValueError as e:
        bad.append(f"pack.mcmeta: {e}")
    assert not bad, bad


def test_function_references_exist():
    missing = []
    for name, p in FUNCS.items():
        for l in code(name):
            for callee, _ in CALL.findall(l):
                if callee not in FUNCS:
                    missing.append(f"{name} -> {callee}")
    for tag in (DP / "data/minecraft/tags/function").glob("*.json"):
        for v in json.loads(tag.read_text())["values"]:
            if v.startswith("helper:") and v not in FUNCS:
                missing.append(f"{tag.name} -> {v}")
    assert not missing, missing


def test_tag_references_exist():
    missing = []
    for name in FUNCS:
        for l in code(name):
            for kind, tag in re.findall(r"(type=)?#helper:([\w/]+)", l):
                folder = "entity_type" if kind else "block"
                if not (DP / f"data/helper/tags/{folder}/{tag}.json").is_file():
                    missing.append(f"{name}: #{tag} ({folder})")
    assert not missing, missing


def test_macro_lines_are_marked():
    """A $(arg) on a line without a leading $ is never substituted. (Dialog actions carry
    their own $(...) templates that the client fills in, so those are allowed.)"""
    bad = [f"{n}: {l[:80]}" for n in FUNCS for l in code(n)
           if "$(" in l and not l.startswith("$") and not l.startswith("dialog show")]
    assert not bad, bad


def test_literal_macro_calls_supply_every_argument():
    bad = []
    for name in FUNCS:
        for l in code(name):
            for callee, args in CALL.findall(l):
                if callee not in FUNCS or not args.startswith("{"):
                    continue
                given = set(re.findall(r"(\w+):", args))
                need = macro_params(callee)
                if need - given:
                    bad.append(f"{name} -> {callee} missing {sorted(need - given)}")
    assert not bad, bad


def test_load_creates_objectives_used():
    load = FUNCS["helper:load"].read_text()
    created = set(re.findall(r"scoreboard objectives add (\S+)", load))
    used = set()
    for name in FUNCS:
        for l in code(name):
            used |= set(re.findall(r"scoreboard players \w+ \S+ (helper_\w+|trust_level|tom)\b", l))
            used |= set(re.findall(r"if score \S+ (helper_\w+|trust_level)", l))
    assert not (used - created), sorted(used - created)
    assert {"trust_level", "tom", "helper_stay", "helper_pf", "helper_fall"} <= created


def test_generated_files_in_sync():
    assert datapack_gen.main(["--check"]) == 0


# --------------------------------------------------------------------------- api contract
API_PUBLIC = {
    "status": {"req"},
    "set_protect_follow": {"req", "on", "come_now"},
    "set_stay_at_base": {"req", "on"},
    "set_base": {"req"},
    "stop_work": {"req"},
    "gather": {"req", "resource", "replace"},
    "dig": {"req", "blocks", "keep", "store", "replace"},
    "rails": {"req", "action", "blocks", "rail_type", "replace"},
    "craft": {"req", "item", "count", "replace"},
    "smelt": {"req", "material", "replace"},
    "organize_scan": {"req", "scope"},
    "organize_apply": {"req", "scan_req"},
    "hunt": {"req", "target"},
    "raid": {"req", "replace"},
    "store_items": {"req", "replace"},
    "snapshot_slice": {"req", "length"},
    "stamp_pattern": {"req", "blocks"},
}


def test_api_public_functions_and_args():
    present = {n.split("/", 1)[1] for n in FUNCS if n.startswith("helper:api/") and "/internal/" not in n}
    assert present == set(API_PUBLIC)
    for fn, args in API_PUBLIC.items():
        assert macro_params(f"helper:api/{fn}") == args, fn


def test_api_functions_always_finish_with_result():
    """Every public API function starts with internal/begin and its last line ends via ok/fail
    (or a helper that ends in ok/fail), so the sidecar always reads a fresh result."""
    for fn in API_PUBLIC:
        c = code(f"helper:api/{fn}")
        assert c[0].startswith("$function helper:api/internal/begin"), fn
        assert re.search(r"api/internal/(ok|fail|expect|recall)\b", c[-1]), (fn, c[-1])
        # every early return reports a failure or success
        for l in c:
            if " return " in l or l.startswith("return"):
                assert re.search(r"return run function helper:api/internal/(fail|ok|expect|recall)", l), (fn, l)


@pytest.mark.parametrize("fn", ["gather", "dig", "rails", "craft", "hunt", "raid", "stamp_pattern"])
def test_movement_api_refuses_while_staying(fn):
    assert any("#api_stay helper_config matches 1" in l and "staying_at_base" in l for l in code(f"helper:api/{fn}"))


def test_come_now_refused_while_staying():
    c = code("helper:api/set_protect_follow")
    assert any("#api_a2 helper_config matches 1 if score #api_stay helper_config matches 1" in l and "staying_at_base" in l for l in c)


def test_organize_base_requires_stay_in_scan_and_apply():
    scan = code("helper:api/organize_scan")
    assert any("#api_a1 helper_config matches 2 if score #api_stay helper_config matches 0" in l and "not_staying" in l for l in scan)
    apply = code("helper:api/organize_apply")
    assert any("org{scope:2}" in l and "#api_stay helper_config matches 0" in l and "not_staying" in l for l in apply)


def test_organize_apply_checks_before_writing():
    c = code("helper:api/organize_apply")
    order = [i for i, l in enumerate(c) if "org_verify_loop" in l or "org_build_loop" in l or "org_write_loop" in l]
    assert [c[i].split(":")[-1] for i in order] == ["api/internal/org_verify_loop", "api/internal/org_build_loop", "api/internal/org_write_loop"]
    # failures of verify/build return before the write loop
    write_at = order[2]
    assert any("changed" in l for l in c[:write_at]) and any("bad_plan" in l for l in c[:write_at])
    entry = "\n".join(code("helper:api/internal/org_build_entry"))
    assert "matches 0..26" in entry and "matches 1..99" in entry and "[{Slot:$(s)b}]" in entry


# --------------------------------------------------------------------------- tick wiring
def test_helper_tick_protect_and_follow_gating():
    c = code("helper:helper_tick")
    joined = "\n".join(c)
    assert c.index("function helper:combat/apply_mode") < c.index("function helper:jobs/tick")
    defend = [l for l in c if "combat/defend_owner" in l]
    assert defend and all("#protect helper_config matches 1" in l or ("matches 0" in l and "helper_job matches 11" in l) for l in defend)
    assert "execute if score @s helper_mode matches 3 run scoreboard players set #stay_with helper_config 1" in joined
    fall = [l for l in c if "follow/fall_check" in l]
    assert fall and all("#stay_with helper_config matches 1" in l for l in fall)
    keep = [l for l in c if "follow/keep_up" in l]
    assert keep and all("#stay_with helper_config matches 1" in l for l in keep)
    # Jobs pause while defending, then resume.
    for l in c:
        if re.search(r"run function helper:jobs/(cut_trees|place_chest|raid_here|dig_straight|smelt_job|craft_job|lay_rails|clear_wall_torches|clear_rails|repair_rails)$", l):
            assert "#defending helper_config matches 0" in l, l
    assert "#protect helper_config matches 1 if score #owner_threat" in joined


# --------------------------------------------------------------------------- mini interpreter
class Sim:
    """Just enough mcfunction to run combat/apply_mode on one helper."""

    def __init__(self, scores: dict[str, int], job: int = 0):
        self.s = {("@s", k): v for k, v in scores.items()}
        self.s[("@s", "helper_job")] = job
        self.calls: list[str] = []

    def get(self, who, obj):
        return self.s.get((who, obj))

    @staticmethod
    def _match(v, rng):
        if v is None:
            return False
        lo, _, hi = rng.partition("..")
        if ".." not in rng:
            return v == int(rng)
        return (lo == "" or v >= int(lo)) and (hi == "" or v <= int(hi))

    def run(self, line: str):
        toks = line.split()
        if toks[0] == "execute":
            i = 1
            while toks[i] != "run":
                if toks[i] in ("if", "unless") and toks[i + 1] == "score" and toks[i + 4] == "matches":
                    ok = self._match(self.get(toks[i + 2], toks[i + 3]), toks[i + 5])
                    if ok != (toks[i] == "if"):
                        return
                    i += 6
                else:
                    raise NotImplementedError(line)
            return self.run(" ".join(toks[i + 1:]))
        if toks[:3] == ["scoreboard", "players", "set"]:
            who = toks[3]
            m = re.match(r"@s\[scores=\{(\w+)=(\d+)\}\]", who)
            if m:
                if self.get("@s", m.group(1)) != int(m.group(2)):
                    return
                who = "@s"
            self.s[(who, toks[4])] = int(toks[5])
            return
        if toks[0] == "function":
            self.calls.append(toks[1])
            if toks[1] == "helper:combat/stay_cancel_job":
                self.s[("@s", "helper_job")] = 0
            return
        raise NotImplementedError(line)

    def run_function(self, name):
        for l in code(name):
            self.run(l)
        return self


def apply_mode(**scores):
    job = scores.pop("job", 0)
    return Sim(scores, job).run_function("helper:combat/apply_mode")


@pytest.mark.parametrize("pf", [0, 1])
@pytest.mark.parametrize("mode", [1, 2, 3, 4])
def test_stay_at_base_overrides_protect_follow(pf, mode):
    sim = apply_mode(helper_stay=1, helper_pf=pf, helper_mode=mode)
    assert sim.get("@s", "helper_mode") == 1  # stay at base
    assert sim.get("#protect", "helper_config") == 0  # no protect reflex
    assert sim.get("@s", "helper_fall") == 0  # no fall recovery


def test_protect_follow_when_not_staying():
    sim = apply_mode(helper_stay=0, helper_pf=1, helper_mode=1)
    assert sim.get("@s", "helper_mode") == 3
    assert sim.get("#protect", "helper_config") == 1


def test_idle_when_both_off():
    sim = apply_mode(helper_stay=0, helper_pf=0, helper_mode=3)
    assert sim.get("@s", "helper_mode") == 4
    assert sim.get("#protect", "helper_config") == 0
    # legacy fetch survives with protect_follow off
    assert apply_mode(helper_stay=0, helper_pf=0, helper_mode=2).get("@s", "helper_mode") == 2


def test_legacy_helpers_migrate():
    s = apply_mode(helper_mode=1)  # stayed before upgrade
    assert (s.get("@s", "helper_stay"), s.get("@s", "helper_pf"), s.get("@s", "helper_mode")) == (1, 1, 1)
    s = apply_mode(helper_mode=3)
    assert (s.get("@s", "helper_stay"), s.get("@s", "helper_pf"), s.get("@s", "helper_mode")) == (0, 1, 3)
    s = apply_mode(helper_mode=2)
    assert (s.get("@s", "helper_stay"), s.get("@s", "helper_pf"), s.get("@s", "helper_mode")) == (0, 0, 2)


@pytest.mark.parametrize("job,cancel", [(5, True), (7, True), (8, True), (11, True), (12, True), (15, True),
                                        (6, False), (9, False), (10, False), (0, False)])
def test_roaming_jobs_dropped_at_base(job, cancel):
    sim = apply_mode(helper_stay=1, helper_pf=1, helper_mode=1, job=job)
    assert ("helper:combat/stay_cancel_job" in sim.calls) == cancel


def test_status_effective_mode_matches_precedence():
    snap = "\n".join(code("helper:api/internal/snap_helper"))
    assert 'if score @s helper_stay matches 1 run data modify storage helper:api status.mode set value "stay_at_base"' in snap
    assert 'unless score @s helper_stay matches 1 if score @s helper_pf matches 1 run data modify storage helper:api status.mode set value "protect_follow"' in snap


# --------------------------------------------------------------------------- safe spot
def floor(y=63, block="stone", r=4):
    return {(x, y, z): block for x in range(-r, r + 1) for z in range(-r, r + 1)}


def test_safe_spot_prefers_adjacent_same_level():
    assert datapack_gen.pick_safe_spot(floor(), (0, 64, 0)) == (1, 64, 0)


def test_safe_spot_skips_lava_and_void():
    w = floor()
    w[(1, 63, 0)] = "lava"
    del w[(-1, 63, 0)]  # void / hole
    w[(0, 64, 1)] = "stone"  # wall
    assert datapack_gen.pick_safe_spot(w, (0, 64, 0)) == (0, 64, -1)


def test_safe_spot_needs_two_air():
    w = floor()
    for dx, _, dz in datapack_gen.SAFE_SPOT_CANDIDATES[:12]:
        w[(dx, 65, dz)] = "stone"  # 1-high ceiling around owner
    w.update({(x, 64, z): "stone" for x in range(-4, 5) for z in range(-4, 5) if (x, z) != (0, 0)})
    # now the +1 layer (y=65) is solid too, so it falls to dy=-1 which is the stone floor: none
    assert datapack_gen.pick_safe_spot(w, (0, 64, 0)) is None


def test_safe_spot_climbs_one_up():
    w = floor()
    w.update({(x, 64, z): "stone" for x in range(-4, 5) for z in range(-4, 5) if (x, z) != (0, 0)})
    assert datapack_gen.pick_safe_spot(w, (0, 64, 0)) == (1, 65, 0)


def test_safe_spot_rejects_water_and_magma():
    w = floor(block="magma_block")
    w[(2, 63, 0)] = "stone"
    w[(2, 64, 0)] = "water"
    w[(-2, 63, 0)] = "stone"
    assert datapack_gen.pick_safe_spot(w, (0, 64, 0)) == (-2, 64, 0)


def test_safe_spot_is_deterministic_and_bounded():
    assert len(datapack_gen.SAFE_SPOT_CANDIDATES) == len(set(datapack_gen.SAFE_SPOT_CANDIDATES)) == 36
    text = (FN / "follow/safe_spot.mcfunction").read_text()
    assert text.count("run function helper:follow/safe_tp_here") == 36
    first = [l for l in text.splitlines() if l.startswith("execute")][0]
    assert "positioned ~1 ~0 ~0" in first


def test_org_scan_regions():
    for d in range(4):
        offs = datapack_gen.ahead_offsets(d)
        assert len(offs) == len(set(offs)) == 60
        assert (0, 0, 0) not in offs
    assert len(datapack_gen.base_offsets()) == 13 * 13 * 6
    # south (+z) looks at +z
    assert all(dz > 0 for _, _, dz in datapack_gen.ahead_offsets(0))
    assert all(dx < 0 for dx, _, _ in datapack_gen.ahead_offsets(1))



# --------------------------------------------------------------------------- tunnel patterns
CODE = {e: c for c, e in PP.CODES.items()}
RAIL = "minecraft:rail[shape={}]"


def build_tunnel(world, start, facing, length, offset=0, floor_holes=()):
    """Ideal 3-wide, 2-high tunnel along `facing`: stone shell, rail in the middle, a powered
    rail every 6th block, redstone torches on the left wall at head height every 6th
    (3 blocks out of phase), a floor torch-free plain segment otherwise."""
    for i in range(length):
        k = i + offset
        for y in PP.LEVELS:
            for x in PP.LATERAL:
                p = datapack_gen._cell_world(start, facing, x, y, i)
                solid = y in (-1, 2) or abs(x) == 2
                world[p] = "minecraft:stone" if solid else "minecraft:air"
        mid = datapack_gen._cell_world(start, facing, 0, 0, i)
        world[mid] = PP.abs_state(CODE[("minecraft:powered_rail", "along")] if k % 6 == 0 else CODE[("minecraft:rail", "along")], facing)
        if k % 6 == 3:
            world[datapack_gen._cell_world(start, facing, 1, 1, i)] = PP.abs_state(CODE[("minecraft:redstone_wall_torch", "R")], facing)
        if i in floor_holes:
            world[datapack_gen._cell_world(start, facing, 0, -1, i)] = "minecraft:air"
    return world


def dug_out(world, start, facing, length):
    """Interior dug, no rails/torches, no shell (the stamp fills the floor/walls)."""
    for i in range(length):
        for y in (0, 1):
            for x in (-1, 0, 1):
                world[datapack_gen._cell_world(start, facing, x, y, i)] = "minecraft:air"
    return world


def region(world, start, facing, frm, to):
    """Blocks in a stretch of tunnel; the stamp's filler counts as the same solid block."""
    return [(lambda b: "minecraft:stone" if b == PP.FILLER else b)(world.get(datapack_gen._cell_world(start, facing, x, y, i), "minecraft:air"))
            for i in range(frm, to) for y in PP.LEVELS for x in PP.LATERAL]


@pytest.mark.parametrize("facing", range(4))
def test_palette_round_trip_every_facing(facing):
    for code in PP.CODES:
        world = {(0, 0, 0): PP.abs_state(code, facing)}
        assert datapack_gen.sim_classify(world, (0, 0, 0), facing) == code


def test_palette_rotation_is_relative():
    left_torch = CODE[("minecraft:redstone_wall_torch", "L")]
    # facing south the left is east; facing west the left is south
    assert PP.abs_state(left_torch, 0).endswith("[facing=east]")
    assert PP.abs_state(left_torch, 1).endswith("[facing=south]")
    along = CODE[("minecraft:rail", "along")]
    assert PP.abs_state(along, 0) == PP.abs_state(along, 2) == RAIL.format("north_south")
    assert PP.abs_state(along, 1) == RAIL.format("east_west")
    asc = CODE[("minecraft:powered_rail", "asc_F")]
    assert [PP.abs_state(asc, f) for f in range(4)] == [f"minecraft:powered_rail[shape=ascending_{d}]" for d in PP.DIRS]
    # every code has a distinct state per facing
    for f in range(4):
        states = [PP.abs_state(c, f) for c in PP.CODES]
        assert len(states) == len(set(states))


def test_cell_layout_serialization():
    assert PP.WIDTH * PP.HEIGHT == 20
    assert [PP.cell_pos(PP.cell_index(x, y)) for y in PP.LEVELS for x in PP.LATERAL] == [(x, y) for y in PP.LEVELS for x in PP.LATERAL]
    read = (FN / "pattern/read_f0.mcfunction").read_text()
    # facing south: left is +x, behind is -z. Slice 0, x=+1 (left), y=0 -> ~1 ~0 ~-1, cell 8
    assert "execute positioned ~1 ~0 ~-1 store result storage helper:tmp pscan.slices[0][8] int 1 run function helper:pattern/classify_f0" in read
    assert read.count("run function helper:pattern/classify_f0") == PP.MAX_DEPTH * 20
    commit = (FN / "pattern/commit.mcfunction").read_text()
    assert f"pattern.palette set value {PP.PALETTE_VERSION}" in commit


@pytest.mark.parametrize("facing", range(4))
def test_snapshot_detects_period_and_stamp_continues_in_phase(facing):
    w = build_tunnel({}, (0, 64, 0), facing, 40)
    origin = datapack_gen._cell_world((0, 64, 0), facing, 0, 0, 20)
    pat = datapack_gen.sim_snapshot(w, origin, facing)
    assert pat["length"] == 6 and pat["verified"]
    # wipe the rails/torches/shell ahead, then stamp 19 blocks from the same spot
    ideal = dict(w)
    for i in range(21, 40):
        for y in PP.LEVELS:
            for x in PP.LATERAL:
                w.pop(datapack_gen._cell_world((0, 64, 0), facing, x, y, i), None)
    dug_out(w, (0, 64, 0), facing, 40)
    res = datapack_gen.sim_stamp(w, origin, facing, pat, 19)
    assert res["ok"] and res["stopped_at"] == 0 and res["reason"] == "done"
    assert region(w, (0, 64, 0), facing, 21, 40) == region(ideal, (0, 64, 0), facing, 21, 40)


def test_stamp_after_helper_moved_along_line_keeps_phase():
    facing = 3
    w = build_tunnel({}, (0, 64, 0), facing, 30)
    pat = datapack_gen.sim_snapshot(w, (20, 64, 0), facing)
    ideal = build_tunnel({}, (0, 64, 0), facing, 60)
    dug_out(w, (0, 64, 0), facing, 60)
    w.update({k: v for k, v in build_tunnel({}, (0, 64, 0), facing, 30).items()})
    res = datapack_gen.sim_stamp(w, (29, 64, 0), facing, pat, 30)  # helper walked 9 blocks on
    assert res["ok"]
    assert region(w, (0, 64, 0), facing, 30, 60) == region(ideal, (0, 64, 0), facing, 30, 60)


def test_stamp_rotates_to_new_facing():
    w = build_tunnel({}, (0, 64, 0), 3, 30)  # east
    pat = datapack_gen.sim_snapshot(w, (20, 64, 0), 3)
    start = (100, 64, 100)
    dug_out(w, start, 2, 25)  # a new tunnel going north
    res = datapack_gen.sim_stamp(w, datapack_gen._cell_world(start, 2, 0, 0, -1), 2, pat, 24)
    assert res["ok"]
    # same relative layout: compare with an ideal north tunnel whose phase starts where the stamp restarts
    stamped = datapack_gen.sim_snapshot(w, datapack_gen._cell_world(start, 2, 0, 0, 24), 2)
    assert stamped["length"] == 6 and sorted(map(tuple, stamped["cells"])) == sorted(map(tuple, pat["cells"]))
    torch = [v for k, v in w.items() if "wall_torch" in v and k[0] >= 99]
    assert torch and all(v.endswith("[facing=east]") for v in torch)  # left-wall torch points right = east when facing north


def test_stamp_fills_floor_and_stops_at_obstruction():
    facing = 0
    w = build_tunnel({}, (0, 64, 0), facing, 20)
    pat = datapack_gen.sim_snapshot(w, (0, 64, 18), facing)
    dug_out(w, (0, 64, 0), facing, 40)
    w[datapack_gen._cell_world((0, 64, 0), facing, 0, -1, 20)] = "minecraft:air"  # hole in the floor
    w[datapack_gen._cell_world((0, 64, 0), facing, -1, 1, 24)] = "minecraft:stone"  # undug block
    res = datapack_gen.sim_stamp(w, (0, 64, 18), facing, pat, 20)
    assert res["stopped_at"] == 6 and res["reason"] == "obstructed" and res["ok"]
    assert w[datapack_gen._cell_world((0, 64, 0), facing, 0, -1, 20)] == PP.FILLER
    assert "rail" not in w.get(datapack_gen._cell_world((0, 64, 0), facing, 0, 0, 25), "minecraft:air")  # nothing past the stop
    blocked = datapack_gen.sim_stamp(dict(w), (0, 64, 23), facing, pat, 5)
    assert blocked["ok"] is False and blocked["stopped_at"] == 1 and blocked["placed"] == 0


def test_stamp_is_idempotent():
    w = build_tunnel({}, (0, 64, 0), 1, 40)
    pat = datapack_gen.sim_snapshot(w, (-20, 64, 0), 1)
    again = datapack_gen.sim_stamp(dict(w), (-20, 64, 0), 1, pat, 19)
    assert again["placed"] == 0 and again["removed"] == 0


def test_no_period_and_explicit_length():
    w = build_tunnel({}, (0, 64, 0), 0, 8)  # only 8 blocks behind: auto needs 16
    assert datapack_gen.sim_snapshot(w, (0, 64, 8), 0) is None
    p = datapack_gen.sim_snapshot(w, (0, 64, 8), 0, length=6)
    assert p["length"] == 6 and p["verified"] is False


def test_pattern_api_gates_and_read_only_snapshot():
    stamp = code("helper:api/stamp_pattern")
    assert any("matches 1..64" in l and "bad_args" in l for l in stamp)
    assert any("pattern.cells[0]" in l and "no_pattern" in l for l in stamp)
    assert any("#api_job helper_config matches 0..4" in l and "busy" in l for l in stamp)
    snap = code("helper:api/snapshot_slice")
    assert any("matches 0..8" in l for l in snap)
    for n in FUNCS:
        if re.match(r"helper:pattern/(read_f\d|classify_f\d|snapshot|detect|try_|verify_two|commit)", n) or n == "helper:api/snapshot_slice":
            assert not any(re.search(r"\b(setblock|fill|clone)\b", l) for l in code(n)), n


def test_put_and_classify_tables_match_palette():
    for f in range(4):
        put = (FN / f"pattern/put_f{f}.mcfunction").read_text()
        cls = (FN / f"pattern/classify_f{f}.mcfunction").read_text()
        for c in PP.CODES:
            st = PP.abs_state(c, f)
            assert f'matches {c} run return run function helper:pattern/set {{b:"{st}"}}' in put
            assert f"if block ~ ~ ~ {st} run return {c}" in cls
