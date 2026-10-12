import pytest

import snbt


def test_round_trip_and_types():
    text = '{a:1b,b:2s,c:3,d:4L,e:1.5f,f:2.0d,g:"x\\"y",h:[I;1,2],i:[],j:{"minecraft:custom_name":"n"},k:true}'
    v = snbt.loads(text)
    assert v["a"] == snbt.Num(1, "b") and v["d"] == snbt.Num(4, "L") and v["e"] == snbt.Num(1.5, "f")
    assert v["g"] == 'x"y' and v["k"] == snbt.Num(1, "b")
    assert snbt.loads(snbt.dumps(v)) == v
    assert snbt.dumps(snbt.loads(snbt.dumps(v))) == snbt.dumps(v)


def test_canonical_ignores_key_order_and_spacing():
    a = snbt.loads('{id: "minecraft:stone", components: {b: 1, a: 2}}')
    b = snbt.loads('{components:{a:2,b:1},id:"minecraft:stone"}')
    assert snbt.dumps(a) == snbt.dumps(b)


def test_types_distinguish_items():
    assert snbt.dumps(snbt.loads("{x:1b}")) != snbt.dumps(snbt.loads("{x:1}"))


def test_from_data_get():
    out = 'Storage helper:api has the following contents: {ok: 1b, code: "started"}'
    assert snbt.plain(snbt.from_data_get(out)) == {"ok": 1, "code": "started"}
    assert snbt.from_data_get("Found no elements matching result") is None
    block = "-12, 64, 30 has the following block data: {Items: []}"
    assert snbt.plain(snbt.from_data_get(block)) == {"Items": []}


def test_single_quoted_strings():
    assert snbt.loads("{a:'it\\'s \"ok\"'}") == {"a": "it's \"ok\""}


@pytest.mark.parametrize("bad", ["{a:1", "{a 1}", "[1,2", '{a:"x}', "{a:1} trailing"])
def test_rejects_malformed(bad):
    with pytest.raises(snbt.SnbtError):
        snbt.loads(bad)
