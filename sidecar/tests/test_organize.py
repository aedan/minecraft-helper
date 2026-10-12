import random
from collections import Counter

import pytest

import organize
import snbt

IDS = ["minecraft:cobblestone", "minecraft:iron_ingot", "minecraft:diamond", "minecraft:oak_log",
       "minecraft:ender_pearl", "minecraft:iron_sword", "minecraft:bread", "minecraft:coal", "minecraft:dirt"]
CAP = {"minecraft:ender_pearl": 16, "minecraft:iron_sword": 1}


def item(slot, iid, count, components=None):
    it = {"Slot": snbt.Num(slot, "b"), "id": iid, "count": snbt.Num(count, "i")}
    if components:
        it["components"] = components
    return it


def chest(x, y, z, items, half=0, facing=4):
    return {"x": snbt.Num(x, "i"), "y": snbt.Num(y, "i"), "z": snbt.Num(z, "i"),
            "half": snbt.Num(half, "i"), "facing": snbt.Num(facing, "i"), "items": items}


def totals(chests_items):
    c = Counter()
    for items in chests_items:
        for it in items:
            c[organize.identity(it)] += int(it["count"].value)
    return c


def random_world(rng, n):
    chests = []
    for i in range(n):
        slots = rng.sample(range(27), rng.randint(0, 27))
        items = []
        for s in slots:
            iid = rng.choice(IDS)
            cap = CAP.get(iid, 64)
            comps = None
            if iid == "minecraft:iron_sword" and rng.random() < 0.5:
                comps = {"minecraft:damage": snbt.Num(rng.randint(1, 3), "i")}
            if iid == "minecraft:diamond" and rng.random() < 0.2:
                comps = {"minecraft:custom_name": "Lucky"}
            items.append(item(s, iid, rng.randint(1, cap), comps))
        chests.append(chest(i * 2, 64, 0, items))
    return chests


@pytest.mark.parametrize("seed", range(40))
@pytest.mark.parametrize("scope", [organize.SCOPE_AHEAD, organize.SCOPE_BASE])
def test_random_conservation(seed, scope):
    rng = random.Random(seed)
    chests = random_world(rng, rng.randint(1, 8))
    plans, stats = organize.plan(chests, scope)
    after = organize.apply_plan(chests, plans)
    assert totals(c["items"] for c in chests) == totals(after)  # nothing created or lost
    for items in after:
        slots = [int(it["Slot"].value) for it in items]
        assert len(slots) == len(set(slots)) and all(0 <= s < 27 for s in slots)
        for it in items:
            assert int(it["count"].value) <= CAP.get(it["id"], 64)
    if scope == organize.SCOPE_AHEAD:  # never moves items between units
        for c, items in zip(chests, after):
            assert totals([c["items"]]) == totals([items])
    assert stats["chests_found"] == len(chests)


def test_deterministic():
    chests = random_world(random.Random(7), 5)
    assert organize.plan(chests, 2) == organize.plan(chests, 2)


def test_merges_and_sorts_single_chest():
    c = chest(0, 64, 0, [item(5, "minecraft:dirt", 10), item(3, "minecraft:iron_ingot", 5),
                         item(9, "minecraft:dirt", 60), item(1, "minecraft:iron_ingot", 7)])
    plans, stats = organize.plan([c], 1)
    after = organize.apply_plan([c], plans)[0]
    got = [(int(i["Slot"].value), i["id"], int(i["count"].value)) for i in after]
    assert got == [(0, "minecraft:iron_ingot", 12), (1, "minecraft:dirt", 64), (2, "minecraft:dirt", 6)]
    assert stats == {"chests_found": 1, "moved": 0, "sorted": 1}


def test_different_components_never_merge():
    c = chest(0, 64, 0, [item(0, "minecraft:diamond", 3), item(1, "minecraft:diamond", 4, {"minecraft:custom_name": "x"})])
    after = organize.apply_plan([c], organize.plan([c], 1)[0])[0]
    assert sorted(int(i["count"].value) for i in after) == [3, 4]


def test_unknown_stack_size_never_overfilled():
    # Two stacks of 10 ender pearls: max seen is 10, so never merged beyond 10 (real cap 16).
    c = chest(0, 64, 0, [item(0, "minecraft:ender_pearl", 10), item(1, "minecraft:ender_pearl", 10)])
    after = organize.apply_plan([c], organize.plan([c], 1)[0])[0]
    assert all(int(i["count"].value) <= 10 for i in after)
    # explicit component wins
    c2 = chest(0, 64, 0, [item(0, "minecraft:stick", 3, {"minecraft:max_stack_size": snbt.Num(4, "i")}),
                          item(1, "minecraft:stick", 3, {"minecraft:max_stack_size": snbt.Num(4, "i")})])
    after2 = organize.apply_plan([c2], organize.plan([c2], 1)[0])[0]
    assert sorted(int(i["count"].value) for i in after2) == [2, 4]


def test_double_chest_is_one_unit_right_half_first():
    # Facing north (0): a left half's partner is clockwise = east (+x).
    left = chest(0, 64, 0, [item(0, "minecraft:dirt", 5)], half=1, facing=0)
    right = chest(1, 64, 0, [item(0, "minecraft:iron_ingot", 5)], half=2, facing=0)
    assert organize.units([left, right]) == [[1, 0]]
    plans, _ = organize.plan([left, right], 1)
    after = organize.apply_plan([left, right], plans)
    # iron (category first) lands in the right half (top of the double-chest GUI)
    assert [i["id"] for i in after[1]] == ["minecraft:iron_ingot", "minecraft:dirt"]
    assert after[0] == []


def test_unpaired_half_is_its_own_unit():
    lonely = chest(0, 64, 0, [], half=1, facing=0)
    other = chest(5, 64, 0, [], half=2, facing=0)
    assert organize.units([lonely, other]) == [[0], [1]]


def test_base_consolidates_across_chests():
    a = chest(0, 64, 0, [item(0, "minecraft:dirt", 30), item(1, "minecraft:iron_ingot", 3)])
    b = chest(2, 64, 0, [item(0, "minecraft:dirt", 30), item(4, "minecraft:iron_ingot", 3)])
    plans, stats = organize.plan([a, b], 2)
    after = organize.apply_plan([a, b], plans)
    assert [(i["id"], int(i["count"].value)) for i in after[0]] == [("minecraft:iron_ingot", 6)]
    assert [(i["id"], int(i["count"].value)) for i in after[1]] == [("minecraft:dirt", 60)]
    assert stats["moved"] == 33 and stats["sorted"] == 2


def test_full_chests_still_fit():
    items = [item(s, IDS[s % 3], 1) for s in range(27)]
    c = chest(0, 64, 0, items)
    plans, _ = organize.plan([c], 1)
    assert totals([items]) == totals(organize.apply_plan([c], plans))


@pytest.mark.parametrize("mutate,msg", [
    (lambda p: p[0].append(dict(p[0][0])), "duplicate"),
    (lambda p: p[0][0].update(c=p[0][0]["c"] + 1), "conserve"),
    (lambda p: p[0][0].update(s=27), "slot"),
    (lambda p: p[0][0].update(g=26), "source"),
    (lambda p: p[0][0].update(c=65), "count"),
])
def test_verify_rejects_bad_plans(mutate, msg):
    c = chest(0, 64, 0, [item(0, "minecraft:dirt", 5), item(1, "minecraft:coal", 5)])
    plans, _ = organize.plan([c], 1)
    mutate(plans)
    with pytest.raises(organize.PlanError):
        organize.verify_plan([c], plans)


def test_plan_command_fits_rcon_limit():
    items = [item(s, "minecraft:iron_sword", 1, {"minecraft:damage": snbt.Num(s, "i")}) for s in range(27)]
    chests = [chest(i, 64, 0, [dict(x) for x in items]) for i in range(24)]
    plans, _ = organize.plan(chests, 2)
    for p in plans:
        assert len(("data modify storage helper:api org.plans append value " + organize.plan_snbt(p)).encode()) < 1446
