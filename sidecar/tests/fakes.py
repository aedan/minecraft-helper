"""A fake RCON that emulates the helper:api contract (enough for dispatcher/agent tests)."""
from __future__ import annotations

import re

import organize
import snbt


def _snbt_dict(text: str) -> dict:
    return snbt.plain(snbt.loads(text))


class FakeGame:
    """Pretends to be the server: runs helper:api/<fn> calls with simple rules."""

    def __init__(self, owner="Jake", loaded=True, stay=0, pf=1, job=0, chests=None):
        self.owner = owner
        self.loaded = loaded
        self.stay, self.pf, self.job = stay, pf, job
        self.result = None
        self.status = None
        self.org = None
        self.chests = chests or []
        self.commands: list[str] = []
        self.api_calls: list[tuple[str, dict]] = []
        self.offline = False

    # RCON surface
    def cmd(self, command: str) -> str:
        self.commands.append(command)
        if command == "data remove storage helper:api result":
            self.result = None
            return ""
        if command == "data remove storage helper:api org":
            self.org = None
            return ""
        m = re.fullmatch(r"execute as @a\[name=(\w+),limit=1\] at @s run function helper:api/(\w+) (\{.*\})", command)
        if m:
            if self.offline or m.group(1) != self.owner:
                return ""
            args = _snbt_dict(m.group(3))
            self.api_calls.append((m.group(2), args))
            self._api(m.group(2), args)
            return ""
        if command.startswith("data get storage helper:api "):
            what = command.rsplit(" ", 1)[1]
            val = {"result": self.result, "status": self.status, "org": self.org}[what]
            if val is None:
                return "Found no elements matching " + what
            return f"Storage helper:api has the following contents: {snbt.dumps(val)}"
        if command == "data modify storage helper:api org.plans set value []":
            self.org["plans"] = []
            return ""
        if command.startswith("data modify storage helper:api org.plans append value "):
            self.org["plans"].append(snbt.plain(snbt.loads(command.split(" value ", 1)[1])))
            return ""
        return ""

    # api emulation
    def _res(self, req, tool, ok, code, msg="", **extra):
        self.result = {"req": req, "tool": tool, "ok": 1 if ok else 0, "code": code, "msg": msg or code, **extra}
        if ok:
            self.result["job"] = self.job

    def _api(self, fn, a):
        req = a["req"]
        if fn == "status":
            mode = "stay_at_base" if self.stay else "protect_follow" if self.pf else "idle"
            self.status = {"loaded": 1 if self.loaded else 0, "mode": mode, "stay": self.stay,
                           "protect_follow": self.pf, "protect": int(not self.stay and self.pf),
                           "job": self.job, "queue": [0, 0, 0]}
            return self._res(req, fn, True, "ok")
        if not self.loaded:
            return self._res(req, fn, False, "not_loaded")
        if fn == "set_stay_at_base":
            self.stay = a["on"]
            if a["on"]:
                self.job = 0
            return self._res(req, fn, True, "stay_on" if a["on"] else "stay_off")
        if fn == "set_protect_follow":
            if a["come_now"] and self.stay:
                return self._res(req, fn, False, "staying_at_base", "Stay-at-base is on.")
            self.pf = a["on"]
            return self._res(req, fn, True, "saved_overridden" if self.stay else "protect_follow_on")
        if fn == "stop_work":
            self.job = 0
            return self._res(req, fn, True, "stopped", "Work cancelled.")
        if fn in ("gather", "dig", "rails", "craft", "hunt", "raid") and self.stay:
            return self._res(req, fn, False, "staying_at_base", "Stay-at-base is on.")
        if fn in ("gather", "dig", "rails", "craft", "smelt", "raid", "store_items") and a.get("replace") == 0 and 5 <= self.job <= 15:
            return self._res(req, fn, False, "busy")
        jobs = {"gather": 5, "dig": 8, "craft": 10, "smelt": 9, "hunt": 11, "raid": 7, "store_items": 6}
        if fn == "rails":
            self.job = {1: 12, 2: 15, 3: 14, 4: 13}[a["action"]]
            return self._res(req, fn, True, "started", "Started rail work.")
        if fn in jobs:
            self.job = jobs[fn]
            return self._res(req, fn, True, "started", f"Started {fn}.")
        if fn == "set_base":
            return self._res(req, fn, True, "base_set")
        if fn == "organize_scan":
            if a["scope"] == 2 and not self.stay:
                return self._res(req, fn, False, "not_staying", "Organizing the base only works in stay-at-base mode.")
            self.org = {"req": req, "scope": a["scope"], "chests": [dict(c) for c in self.chests]}
            n = len(self.chests)
            return self._res(req, fn, True, "scanned" if n else "no_chests", chests_found=n)
        if fn == "organize_apply":
            if not self.org or self.org["req"] != a["scan_req"]:
                return self._res(req, fn, False, "stale")
            # mirror the datapack: rebuild every container from the snapshot
            snap = snbt.loads(snbt.dumps(self.org["chests"]))
            new = organize.apply_plan(snap, self.org["plans"])
            for c, items in zip(self.chests, new):
                c["items"] = snbt.plain(items)
            self.org = None
            return self._res(req, fn, True, "organized", chests_found=len(self.chests))
        raise AssertionError(f"unhandled api {fn}")
