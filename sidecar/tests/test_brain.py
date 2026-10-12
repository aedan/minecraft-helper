import helper_brain as hb


def brain():
    b = object.__new__(hb.Brain)
    b.names = {"Jake": "Tom"}
    b._cached_owner = "Jake"
    b.default_name = "Helper"
    return b


def tools_for(text):
    b = brain()
    return b.keyword_to_tools(text, b.keyword_orders(text))


def test_keyword_orders_become_valid_tool_calls():
    import tools as T
    cases = {
        "stay home": [("set_stay_at_base", {"on": True})],
        "stop": [("stop_work", {})],
        "wait here": [("stop_work", {}), ("set_protect_follow", {"on": False})],
        "come here": [("set_protect_follow", {"on": True, "come_now": True})],
        "dig 40 blocks": [("dig_tunnel", {"blocks": 40, "continue_tunnel": False, "store_in_chest": False})],
        "lay powered rails 100": [("rails", {"action": "lay", "rail_type": "powered", "blocks": 100})],
        "repair the rails": [("rails", {"action": "repair"})],
        "craft 8 torches": [("craft", {"item": "torch", "count": 8})],
        "smelt gold": [("smelt", {"material": "gold"})],
        "get me some diamonds": [("gather", {"resource": "diamond"})],
        "organize the chests": [("organize_chests", {"scope": "ahead"})],
        "sort the base storage": [("organize_chests", {"scope": "base"})],
        "kill Bob": [("hunt_player", {"player": "Bob"})],
    }
    for text, want in cases.items():
        got = tools_for(text)
        assert got == want, text
        for name, args in got:
            T.validate(name, args)


def test_unknown_craft_replies():
    assert tools_for("craft a spaceship")[0][0] == "reply"


def test_gather_and_store_does_not_cancel_gather():
    assert tools_for("get wood and put it in a chest") == [("gather", {"resource": "wood"})]


def test_public_chat_guard_still_exported():
    assert hb._reject_public_chat("say hi")
    assert hb._reject_public_chat('tellraw @a[name=Jake,limit=1] "x"') is None
