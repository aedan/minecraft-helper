import json
import re
from collections import Counter

import pytest

import tools as T
from fakes import FakeGame
from rcon_client import RconError


def disp(game, **kw):
    return T.Dispatcher(rcon=game, owner="Jake", **kw)


def test_tool_set_is_small_and_well_formed():
    assert 8 <= len(T.TOOL_SPECS) <= 14
    for t in T.openai_tools():
        f = t["function"]
        assert re.fullmatch(r"[a-z_]+", f["name"]) and f["description"]
        assert f["parameters"]["additionalProperties"] is False
        json.dumps(t)
    assert not set(T.ROUTER_ONLY) & set(T.TOOL_NAMES)


@pytest.mark.parametrize("name,args,err", [
    ("nope", {}, "unknown tool"),
    ("gather", {}, "missing"),
    ("gather", {"resource": "dirt"}, "one of"),
    ("gather", {"resource": "iron", "x": 1}, "unexpected"),
    ("dig_tunnel", {"blocks": 0}, "between"),
    ("dig_tunnel", {"blocks": 2001}, "between"),
    ("dig_tunnel", {"blocks": "10"}, "integer"),
    ("dig_tunnel", {"blocks": True}, "integer"),
    ("set_stay_at_base", {"on": 1}, "true or false"),
    ("craft", {"item": "minecraft:diamond_block"}, "one of"),
    ("craft", {"item": "torch", "count": 65}, "between"),
    ("reply", {"text": ""}, "characters"),
    ("reply", {"text": "x" * 201}, "characters"),
    ("hunt_player", {"player": "a b"}, "invalid"),
    ("get_status", [], "object"),
])
def test_validation_rejects(name, args, err):
    with pytest.raises(T.ToolArgError, match=err):
        T.validate(name, args)


def test_bad_args_never_reach_the_server():
    g = FakeGame()
    r = disp(g).call("dig_tunnel", {"blocks": 99999})
    assert r["ok"] is False and r["error"] == "bad_args" and g.commands == []


def test_commands_map_one_to_one_onto_api():
    g = FakeGame()
    d = disp(g)
    d.call("gather", {"resource": "ancient_debris"})
    d.call("dig_tunnel", {"blocks": 40, "continue_tunnel": True})
    d.call("rails", {"action": "lay", "rail_type": "powered", "blocks": 100})
    d.call("rails", {"action": "clear_torches"})
    d.call("craft", {"item": "torch"})
    d.call("smelt", {"material": "gold", "replace": False})
    calls = [(fn, {k: v for k, v in a.items() if k != "req"}) for fn, a in g.api_calls if fn != "status"]
    assert calls == [
        ("gather", {"resource": 11, "replace": 1}),
        ("dig", {"blocks": 40, "keep": 1, "store": 0, "replace": 1}),
        ("rails", {"action": 1, "blocks": 100, "rail_type": 2, "replace": 1}),
        ("rails", {"action": 4, "blocks": 512, "rail_type": 0, "replace": 1}),
        ("craft", {"item": "minecraft:torch", "count": 4, "replace": 1}),
        ("smelt", {"material": 5, "replace": 0}),
    ]


def test_api_args_match_datapack_signatures():
    """Every api call the dispatcher makes passes exactly the macro args the function uses."""
    import sys
    from pathlib import Path
    root = Path(__file__).resolve().parents[2]
    sys.path.insert(0, str(root / "tests"))
    from test_datapack import API_PUBLIC  # noqa: E402
    g = FakeGame(stay=1)
    d = disp(g)
    for name, args in [("get_status", {}), ("set_protect_follow", {"on": True}), ("set_stay_at_base", {"on": True}),
                       ("set_base", {}), ("stop_work", {}), ("smelt", {"material": "iron"}),
                       ("store_items", {}), ("organize_chests", {"scope": "base"})]:
        d.call(name, args)
    g2 = FakeGame()
    g2.scan_pattern = _pattern()
    d2 = disp(g2, resolve_player=lambda n: n)
    for name, args in [("gather", {"resource": "wood"}), ("dig_tunnel", {"blocks": 5}), ("rails", {"action": "repair"}),
                       ("craft", {"item": "stick"}), ("hunt_player", {"player": "Bob"}), ("raid_here", {}),
                       ("snapshot_slice", {}), ("stamp_pattern", {"blocks": 3})]:
        d2.call(name, args)
    seen = {}
    for fn, a in g.api_calls + g2.api_calls:
        seen.setdefault(fn, set(a))
    for fn, keys in seen.items():
        assert keys == API_PUBLIC[fn], fn


def test_result_shape_and_observation():
    g = FakeGame()
    r = disp(g).call("gather", {"resource": "iron"})
    assert set(r) >= {"ok", "error", "message", "state"}
    assert r["ok"] is True and r["error"] is None and r["state"]["job"] == 5


def test_stay_precedence_reported():
    g = FakeGame(stay=1)
    d = disp(g)
    r = d.call("set_protect_follow", {"on": True, "come_now": True})
    assert r["ok"] is False and r["error"] == "staying_at_base"
    r = d.call("set_protect_follow", {"on": True})
    assert r["ok"] is True and r["error"] is None and r["code"] == "saved_overridden"
    assert r["state"]["mode"] == "stay_at_base"
    assert d.call("gather", {"resource": "wood"})["error"] == "staying_at_base"


def test_busy_without_replace():
    g = FakeGame(job=8)
    assert disp(g).call("gather", {"resource": "coal", "replace": False})["error"] == "busy"


def test_not_loaded_retries_once_after_loading():
    g = FakeGame(loaded=False)
    loads = []

    def ensure():
        loads.append(1)
        g.loaded = True
        return True

    r = disp(g, ensure_loaded=ensure).call("stop_work")
    assert r["ok"] and loads == [1]


def test_owner_offline():
    g = FakeGame()
    g.offline = True
    assert disp(g).call("stop_work")["error"] == "owner_offline"


def test_req_mismatch_is_datapack_error():
    class Stale(FakeGame):
        def _api(self, fn, a):
            super()._api(fn, a)
            self.result["req"] = -5

    assert disp(Stale()).call("stop_work")["error"] == "datapack_error"


def test_rcon_failure_is_structured():
    class Down:
        def cmd(self, c):
            raise RconError("down")

    r = T.Dispatcher(rcon=Down(), owner="Jake").call("stop_work")
    assert r == {"ok": False, "error": "rcon_error", "message": "Cannot reach the server: down", "state": {}}


def test_reply_uses_owner_only_say():
    said = []
    disp(FakeGame(), say=lambda o, t: said.append((o, t))).call("reply", {"text": "hi"})
    assert said == [("Jake", "hi")]


def test_bad_owner_name_rejected():
    with pytest.raises(ValueError):
        T.Dispatcher(rcon=FakeGame(), owner="@a")


def test_snbt_string_args_are_quoted():
    g = FakeGame()
    disp(g).call("craft", {"item": "crafting_table", "count": 2})
    cmd = [c for c in g.commands if "helper:api/craft" in c][0]
    assert cmd.startswith("execute as @a[name=Jake,limit=1] at @s run function helper:api/craft {req:")
    assert 'item:"minecraft:crafting_table"' in cmd


def _chest(x, items):
    return {"x": x, "y": 64, "z": 0, "half": 0, "facing": 4, "items": items}


def _count(chests):
    c = Counter()
    for ch in chests:
        for it in ch["items"]:
            c[it["id"]] += it["count"]
    return c


def test_organize_end_to_end_conserves():
    chests = [_chest(0, [{"Slot": 3, "id": "minecraft:dirt", "count": 20}, {"Slot": 7, "id": "minecraft:coal", "count": 5}]),
              _chest(2, [{"Slot": 0, "id": "minecraft:dirt", "count": 50}, {"Slot": 1, "id": "minecraft:coal", "count": 9}])]
    g = FakeGame(stay=1, chests=chests)
    before = _count(chests)
    r = disp(g).call("organize_chests", {"scope": "base"})
    assert r["ok"] and r["reason"] == "organized" and r["chests_found"] == 2 and r["sorted"] == 2
    assert _count(g.chests) == before


def test_organize_base_requires_stay():
    g = FakeGame(stay=0, chests=[_chest(0, [])])
    r = disp(g).call("organize_chests", {"scope": "base"})
    assert r["ok"] is False and r["reason"] == "not_staying" and r["error"] == "not_staying"


def test_organize_no_chests_and_already_sorted():
    assert disp(FakeGame()).call("organize_chests", {"scope": "ahead"})["reason"] == "no_chests"
    g = FakeGame(chests=[_chest(0, [{"Slot": 0, "id": "minecraft:coal", "count": 5}])])
    r = disp(g).call("organize_chests", {"scope": "ahead"})
    assert r["ok"] and r["reason"] == "already_sorted"
    assert not any(fn == "organize_apply" for fn, _ in g.api_calls)


def _pattern(length=2, verified=1, palette=None):
    import pattern_palette as PP
    rail = next(c for c, e in PP.CODES.items() if e == ("minecraft:rail", "along"))
    pow_ = next(c for c, e in PP.CODES.items() if e == ("minecraft:powered_rail", "along"))
    torch = next(c for c, e in PP.CODES.items() if e == ("minecraft:redstone_wall_torch", "L"))
    sl = [1] * 5 + [1, 0, 0, 0, 1] + [1, 0, 0, 0, 1] + [1] * 5
    a, b = list(sl), list(sl)
    a[PP.cell_index(0, 0)] = rail
    b[PP.cell_index(0, 0)] = pow_
    b[PP.cell_index(-1, 1)] = torch
    return {"facing": 3, "width": 5, "height": 4, "length": length, "verified": verified,
            "origin": {"x": 0, "y": 64, "z": 0}, "palette": PP.PALETTE_VERSION if palette is None else palette,
            "cells": [a, b][:length]}


def test_snapshot_slice_summarizes_without_model_layout():
    g = FakeGame()
    g.scan_pattern = _pattern()
    r = disp(g).call("snapshot_slice", {})
    assert r["ok"] and r["pattern"]["length"] == 2 and r["pattern"]["facing"] == "east"
    assert r["pattern"]["counts"] == {"powered_rail": 1, "rail": 1, "redstone_wall_torch": 1}
    assert {"slice": 1, "x": -1, "y": 1, "block": "redstone_wall_torch facing left"} in r["pattern"]["features"]
    assert "2-block segment facing east" in r["message"]
    # the only arguments that reach the game are req and length
    assert [set(a) for fn, a in g.api_calls if fn == "snapshot_slice"] == [{"req", "length"}]


def test_snapshot_slice_bounds_and_errors():
    g = FakeGame()
    d = disp(g)
    assert d.call("snapshot_slice", {"length": 9})["error"] == "bad_args"
    assert d.call("snapshot_slice", {"cells": []})["error"] == "bad_args"  # model cannot supply layout
    assert d.call("snapshot_slice", {})["error"] == "no_pattern"
    g.scan_pattern = _pattern(palette=123)
    assert d.call("snapshot_slice", {"length": 2})["error"] == "datapack_error"


def test_stamp_pattern_bounds_and_results():
    g = FakeGame()
    d = disp(g)
    assert d.call("stamp_pattern", {"blocks": 0})["error"] == "bad_args"
    assert d.call("stamp_pattern", {"blocks": 65})["error"] == "bad_args"
    assert d.call("stamp_pattern", {"blocks": 10})["error"] == "no_pattern"
    g.scan_pattern = _pattern()
    d.call("snapshot_slice", {})
    r = d.call("stamp_pattern", {"blocks": 10})
    assert r["ok"] and r["placed"] == 12 and r["stopped_at"] == 0 and r["reason"] == "done"
    g.stamp_result = {"placed": 5, "removed": 1, "stopped_at": 4, "reason": "obstructed", "rotated": 1}
    r = d.call("stamp_pattern", {"blocks": 10})
    assert r["ok"] and r["code"] == "partial" and r["stopped_at"] == 4 and r["rotated"] is True
    assert "Stopped at block 4 (obstructed)" in r["message"]
    g.stamp_result = {"placed": 0, "removed": 0, "stopped_at": 1, "reason": "unloaded", "rotated": 0}
    r = d.call("stamp_pattern", {"blocks": 10})
    assert r["ok"] is False and r["error"] == "unloaded" and r["reason"] == "unloaded"
    g.stay = 1
    assert d.call("stamp_pattern", {"blocks": 3})["error"] == "staying_at_base"
