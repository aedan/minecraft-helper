"""Minimal SNBT reader/writer for `data get` output.

Numbers keep their type (Num), so dumps(loads(x)) is canonical and lossless enough to
compare items: two stacks are the same item exactly when their canonical dumps match
(ignoring Slot and count).
"""
from __future__ import annotations

import re
from dataclasses import dataclass

_SUFFIX = {"b": "b", "s": "s", "l": "L", "f": "f", "d": "d"}


@dataclass(frozen=True)
class Num:
    value: int | float
    kind: str  # "b" "s" "i" "L" "f" "d"

    def __int__(self) -> int:
        return int(self.value)

    def __float__(self) -> float:
        return float(self.value)


@dataclass(frozen=True)
class TypedArray:
    kind: str  # "B" "I" "L"
    values: tuple


class SnbtError(ValueError):
    pass


_NUM_RE = re.compile(
    r"[-+]?(?:\d+\.?\d*|\.\d+)(?:e[-+]?\d+)?[bslfdBSLFD]?(?=$|[\s,\]}:])"
)
_UNQUOTED = re.compile(r"[A-Za-z0-9_\-.+]+")


class _Parser:
    def __init__(self, text: str) -> None:
        self.s = text
        self.i = 0

    def ws(self) -> None:
        while self.i < len(self.s) and self.s[self.i].isspace():
            self.i += 1

    def peek(self) -> str:
        self.ws()
        return self.s[self.i] if self.i < len(self.s) else ""

    def expect(self, ch: str) -> None:
        if self.peek() != ch:
            raise SnbtError(f"expected {ch!r} at {self.i}: {self.s[self.i:self.i + 30]!r}")
        self.i += 1

    def value(self):
        c = self.peek()
        if c == "{":
            return self.compound()
        if c == "[":
            return self.list_()
        if c in "\"'":
            return self.string()
        return self.scalar()

    def compound(self) -> dict:
        self.expect("{")
        out: dict = {}
        if self.peek() == "}":
            self.i += 1
            return out
        while True:
            key = self.string() if self.peek() in "\"'" else self.bare()
            self.expect(":")
            out[key] = self.value()
            c = self.peek()
            if c == ",":
                self.i += 1
                continue
            self.expect("}")
            return out

    def list_(self):
        self.expect("[")
        if self.s[self.i:self.i + 2] in ("B;", "I;", "L;"):
            kind = self.s[self.i]
            self.i += 2
            vals = []
            if self.peek() != "]":
                while True:
                    v = self.scalar()
                    vals.append(int(v.value) if isinstance(v, Num) else v)
                    if self.peek() == ",":
                        self.i += 1
                        continue
                    break
            self.expect("]")
            return TypedArray(kind, tuple(vals))
        out = []
        if self.peek() == "]":
            self.i += 1
            return out
        while True:
            out.append(self.value())
            if self.peek() == ",":
                self.i += 1
                continue
            self.expect("]")
            return out

    def string(self) -> str:
        q = self.s[self.i]
        self.i += 1
        buf = []
        while self.i < len(self.s):
            ch = self.s[self.i]
            if ch == "\\":
                nxt = self.s[self.i + 1 : self.i + 2]
                buf.append({"n": "\n", "t": "\t"}.get(nxt, nxt))
                self.i += 2
                continue
            if ch == q:
                self.i += 1
                return "".join(buf)
            buf.append(ch)
            self.i += 1
        raise SnbtError("unterminated string")

    def bare(self) -> str:
        self.ws()
        m = _UNQUOTED.match(self.s, self.i)
        if not m:
            raise SnbtError(f"expected name at {self.i}: {self.s[self.i:self.i + 30]!r}")
        self.i = m.end()
        return m.group(0)

    def scalar(self):
        self.ws()
        m = _NUM_RE.match(self.s, self.i)
        if m:
            tok = m.group(0)
            self.i = m.end()
            suf = tok[-1].lower() if tok[-1].isalpha() else ""
            body = tok[:-1] if suf else tok
            if suf in ("f", "d") or (not suf and re.search(r"[.e]", body, re.I)):
                return Num(float(body), _SUFFIX.get(suf, "d"))
            if re.search(r"[.e]", body, re.I):
                raise SnbtError(f"bad integer {tok!r}")
            return Num(int(body), _SUFFIX.get(suf, "i"))
        word = self.bare()
        if word == "true":
            return Num(1, "b")
        if word == "false":
            return Num(0, "b")
        return word


def loads(text: str):
    p = _Parser(text)
    v = p.value()
    p.ws()
    if p.i != len(p.s):
        raise SnbtError(f"trailing data at {p.i}: {p.s[p.i:p.i + 30]!r}")
    return v


def _q(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n") + '"'


_SAFE_KEY = re.compile(r"[A-Za-z0-9_\-.+]+")


def dumps(v) -> str:
    """Canonical SNBT: sorted keys, quoted strings, explicit number types."""
    if isinstance(v, dict):
        items = []
        for k in sorted(v):
            key = k if _SAFE_KEY.fullmatch(k) else _q(k)
            items.append(f"{key}:{dumps(v[k])}")
        return "{" + ",".join(items) + "}"
    if isinstance(v, list):
        return "[" + ",".join(dumps(x) for x in v) + "]"
    if isinstance(v, TypedArray):
        return f"[{v.kind};" + ",".join(f"{x}{'b' if v.kind == 'B' else 'L' if v.kind == 'L' else ''}" for x in v.values) + "]"
    if isinstance(v, Num):
        if v.kind in ("f", "d"):
            return f"{float(v.value)!r}{v.kind}"
        return f"{int(v.value)}{'' if v.kind == 'i' else v.kind}"
    if isinstance(v, bool):
        return "1b" if v else "0b"
    if isinstance(v, int):
        return str(v)
    if isinstance(v, float):
        return f"{v!r}d"
    if isinstance(v, str):
        return _q(v)
    raise TypeError(f"cannot dump {type(v).__name__}")


def plain(v):
    """Convert to plain Python (Num -> int/float) for JSON results."""
    if isinstance(v, dict):
        return {k: plain(x) for k, x in v.items()}
    if isinstance(v, list):
        return [plain(x) for x in v]
    if isinstance(v, TypedArray):
        return list(v.values)
    if isinstance(v, Num):
        return v.value
    return v


_DATA_GET = re.compile(r"has the following (?:contents|block data|entity data):\s*(.*)\Z", re.S)


def from_data_get(output: str):
    """Parse the value out of a `data get ...` response. Returns None if nothing was found."""
    m = _DATA_GET.search(output or "")
    if not m:
        return None
    return loads(m.group(1).strip())
