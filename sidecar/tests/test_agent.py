import json

import pytest

import tools as T
from agent import Agent, JsonProtocolError, ModelTurn, ToolsUnsupported, json_catalog, parse_json_turn
from fakes import FakeGame


class Script:
    """Fake model returning queued turns; records what it was shown."""

    def __init__(self, turns, reject_tools=False):
        self.turns = list(turns)
        self.reject_tools = reject_tools
        self.seen = []

    def complete(self, messages, tools, timeout):
        self.seen.append((json.loads(json.dumps(messages)), tools is not None))
        if tools and self.reject_tools:
            raise ToolsUnsupported("tools not supported")
        t = self.turns.pop(0)
        return t() if callable(t) else t


def call(name, args, i=0):
    return ModelTurn(tool_calls=[(f"c{i}", name, json.dumps(args))])


def run(model, game=None, **kw):
    game = game or FakeGame()
    said = []
    d = T.Dispatcher(rcon=game, owner="Jake", say=lambda o, t: said.append(t))
    out = Agent(model, **kw).run(d, "Tom", "dig 20 blocks")
    return out, said, game


def test_native_tool_then_reply():
    out, said, g = run(Script([call("dig_tunnel", {"blocks": 20}), call("reply", {"text": "Digging 20."}, 1)]))
    assert out.stop == "replied" and said == ["Digging 20."]
    assert [n for n, _a, _r in out.calls] == ["dig_tunnel", "reply"]
    assert g.job == 8


def test_only_first_tool_call_is_executed():
    turn = ModelTurn(tool_calls=[("a", "gather", '{"resource":"iron"}'), ("b", "stop_work", "{}")])
    model = Script([turn, call("reply", {"text": "ok"}, 1)])
    out, _said, g = run(model)
    assert [n for n, _a, _r in out.calls] == ["gather", "reply"]
    msgs = model.seen[1][0]
    assistant = [m for m in msgs if m["role"] == "assistant"][0]
    assert len(assistant["tool_calls"]) == 1  # transcript stays consistent
    assert msgs[-1]["role"] == "tool" and msgs[-1]["tool_call_id"] == "a"


def test_bad_args_are_returned_to_model():
    model = Script([call("dig_tunnel", {"blocks": 99999}), call("dig_tunnel", {"blocks": 2000}, 1), call("reply", {"text": "ok"}, 2)])
    out, _said, g = run(model)
    assert out.calls[0][2]["error"] == "bad_args"
    assert g.job == 8


def test_router_only_tools_not_callable_by_model():
    out, _said, g = run(Script([call("hunt_player", {"player": "Bob"}), call("reply", {"text": "no"}, 1)]))
    assert out.calls[0][2]["error"] == "bad_args" and g.job == 0


def test_action_limit():
    turns = [call("gather", {"resource": "iron"}, i) for i in range(10)]
    out, said, _g = run(Script(turns), max_actions=2, max_steps=10)
    assert out.stop == "max_actions"
    assert [r.get("error") for n, _a, r in out.calls if n == "gather"] == [None, None, "action_limit"]
    assert said  # owner still hears something


def test_step_limit():
    out, said, _g = run(Script([call("get_status", {}, i) for i in range(10)]), max_steps=3)
    assert out.stop == "max_steps" and len(said) == 1


def test_timeout():
    t = [0.0]

    def slow():
        t[0] += 15
        return call("get_status", {})

    out, said, _g = run(Script([slow, slow, slow]), timeout=20, clock=lambda: t[0])
    assert out.stop == "timeout" and said


def test_plain_text_in_native_mode_is_the_reply():
    out, said, _g = run(Script([ModelTurn(content="Sure thing.")]))
    assert out.stop == "replied" and said == ["Sure thing."]


def test_auto_switches_to_json_mode():
    model = Script([ModelTurn(content='{"tool":"stop_work","args":{}}'), ModelTurn(content='```json\n{"reply":"Stopped."}\n```')], reject_tools=True)
    out, said, g = run(model, game=FakeGame(job=5))
    assert out.mode == "json" and out.stop == "replied" and said == ["Stopped."] and g.job == 0
    assert "Answer with exactly ONE JSON object" in model.seen[-1][0][0]["content"]
    assert model.seen[-1][1] is False  # tools no longer sent


def test_json_mode_retry_once_then_give_up():
    model = Script([ModelTurn(content="I'll dig now!"), ModelTurn(content="still prose")])
    out, said, _g = run(model, mode="json")
    assert out.stop == "bad_output" and len(said) == 1


def test_json_mode_recovers_after_one_bad_answer():
    model = Script([ModelTurn(content="dig"), ModelTurn(content='{"reply":"ok"}')])
    out, said, _g = run(model, mode="json")
    assert out.stop == "replied" and said == ["ok"]


def test_model_exception_ends_cleanly():
    def boom():
        raise RuntimeError("500")

    out, said, _g = run(Script([boom]))
    assert out.stop == "model_error" and said


@pytest.mark.parametrize("text,kind", [
    ('{"tool":"get_status","args":{}}', "tool"),
    ('{"tool":"get_status"}', "tool"),
    ('{"reply":"hi"}', "reply"),
])
def test_parse_json_turn_ok(text, kind):
    assert parse_json_turn(text)[0] == kind


@pytest.mark.parametrize("text", ['{"tool":"x","args":[]}', '{"reply":""}', '[1]', 'sure {"reply":"x"}', '{"tool":"x","extra":1}', ""])
def test_parse_json_turn_strict(text):
    with pytest.raises(JsonProtocolError):
        parse_json_turn(text)


def test_catalog_lists_every_tool():
    cat = json_catalog()
    for name in T.TOOL_NAMES:
        assert f"- {name}(" in cat
