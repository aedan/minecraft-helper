"""Bounded agent loop: owner order -> one tool call at a time -> observe -> reply.

Limits (all configurable): at most MAX_STEPS model calls, at most MAX_ACTIONS state-changing
tool calls, one tool call per model turn (extras are dropped), and a wall-clock TIMEOUT.
Works with OpenAI-compatible servers with native tool calling, and falls back to a strict
JSON protocol for models/servers that do not support tools.
"""
from __future__ import annotations

import json
import re
import time
from dataclasses import dataclass, field
from typing import Any, Callable, Protocol

import tools as T

MAX_STEPS = 6
MAX_ACTIONS = 3
TIMEOUT = 20.0

SYSTEM = """You control {name}, a Minecraft helper bound to its owner {owner}. Turn the owner's order into tool calls.
Rules:
- One tool call at a time. You see each result before deciding the next.
- Do only what the owner asked. If the order is unclear or impossible, reply asking or explaining.
- Modes: protect_follow (follows and defends the owner) and stay_at_base (stays home, no following or protecting). stay_at_base overrides protect_follow.
  "come here"/"follow me" -> set_protect_follow on=true come_now=true. "stay home"/"guard the base" -> set_stay_at_base on=true. "stop" -> stop_work.
- Work tools only start a job; do not wait for it to finish.
- Every result has ok, error, message, state. If ok=false, fix the arguments once or reply with the reason. Never retry the same call unchanged.
- End with reply: one short plain sentence, no markdown.
- Use only the listed tools and arguments."""

JSON_PROTOCOL = """
You cannot call tools directly. Answer with exactly ONE JSON object and nothing else:
  {{"tool": "<name>", "args": {{...}}}}   to call a tool, or
  {{"reply": "<short message>"}}          to answer the owner and finish.
Tools (name: arguments):
{catalog}"""


# --------------------------------------------------------------------------- model adapters
@dataclass
class ModelTurn:
    content: str = ""
    tool_calls: list[tuple[str, str, str]] = field(default_factory=list)  # (id, name, json args)


class ToolsUnsupported(Exception):
    """The server rejected the `tools` parameter."""


class Model(Protocol):
    def complete(self, messages: list[dict], tools: list[dict] | None, timeout: float) -> ModelTurn: ...


class OpenAIModel:
    """Adapter for any OpenAI-compatible /chat/completions endpoint."""

    def __init__(self, client: Any, model: str, temperature: float = 0.1) -> None:
        self.client = client
        self.model = model
        self.temperature = temperature

    def complete(self, messages, tools, timeout):
        kw: dict = {"model": self.model, "messages": messages, "temperature": self.temperature, "timeout": timeout}
        if tools:
            kw["tools"] = tools
            kw["tool_choice"] = "auto"
        try:
            resp = self.client.chat.completions.create(**kw)
        except Exception as exc:  # openai.BadRequestError etc.
            text = str(exc).lower()
            if tools and any(w in text for w in ("tool", "function call", "function_call")) and (
                "support" in text or "invalid" in text or "unknown" in text or "400" in text
            ):
                raise ToolsUnsupported(str(exc)) from exc
            raise
        msg = resp.choices[0].message
        calls = [(tc.id or f"call_{i}", tc.function.name, tc.function.arguments or "{}") for i, tc in enumerate(msg.tool_calls or [])]
        return ModelTurn(content=(msg.content or "").strip(), tool_calls=calls)


# --------------------------------------------------------------------------- JSON fallback
class JsonProtocolError(ValueError):
    pass


_FENCE = re.compile(r"\A```(?:json)?\s*(.*?)\s*```\Z", re.S)


def parse_json_turn(text: str) -> tuple[str, Any]:
    """Strict: the whole message must be one JSON object (a ```json fence is tolerated).
    Returns ("tool", (name, args)) or ("reply", text)."""
    t = (text or "").strip()
    m = _FENCE.match(t)
    if m:
        t = m.group(1)
    try:
        obj = json.loads(t)
    except ValueError as e:
        raise JsonProtocolError(f"not valid JSON: {e}") from None
    if not isinstance(obj, dict):
        raise JsonProtocolError("must be a JSON object")
    if set(obj) == {"reply"} and isinstance(obj["reply"], str) and obj["reply"].strip():
        return "reply", obj["reply"].strip()
    if "tool" in obj and set(obj) <= {"tool", "args"} and isinstance(obj["tool"], str):
        args = obj.get("args", {})
        if not isinstance(args, dict):
            raise JsonProtocolError("args must be an object")
        return "tool", (obj["tool"], args)
    raise JsonProtocolError('use {"tool": ..., "args": {...}} or {"reply": ...}')


def json_catalog() -> str:
    lines = []
    for spec in T.TOOL_SPECS:
        props = spec["parameters"]["properties"]
        req = set(spec["parameters"]["required"])
        parts = []
        for k, p in props.items():
            ty = "|".join(p["enum"]) if "enum" in p else p["type"]
            if p.get("type") == "integer":
                ty += f" {p['minimum']}..{p['maximum']}"
            parts.append(f"{k}{'' if k in req else '?'}: {ty}")
        lines.append(f"- {spec['name']}({', '.join(parts)}): {spec['description']}")
    return "\n".join(lines)


# --------------------------------------------------------------------------- loop
@dataclass
class Outcome:
    replied: str | None = None
    calls: list[tuple[str, dict, dict]] = field(default_factory=list)
    stop: str = ""  # replied | max_steps | max_actions | timeout | model_error | bad_output
    mode: str = "native"


def _compact(result: dict) -> str:
    """Tool result for the model, trimmed so it stays small."""
    st = result.get("state") or {}
    keep = {k: st[k] for k in ("mode", "protect", "defending", "job_paused", "job", "queue", "loaded", "stay", "protect_follow") if k in st}
    out = {k: v for k, v in result.items() if k != "state"}
    out["state"] = keep
    return json.dumps(out, separators=(",", ":"))


class Agent:
    def __init__(
        self,
        model: Model,
        mode: str = "auto",  # auto | native | json
        max_steps: int = MAX_STEPS,
        max_actions: int = MAX_ACTIONS,
        timeout: float = TIMEOUT,
        clock: Callable[[], float] = time.monotonic,
    ) -> None:
        if mode not in ("auto", "native", "json"):
            raise ValueError(mode)
        self.model = model
        self.mode = mode
        self.max_steps = max_steps
        self.max_actions = max_actions
        self.timeout = timeout
        self.clock = clock
        self._native_ok = mode != "json"

    def run(self, dispatcher: T.Dispatcher, helper_name: str, order: str) -> Outcome:
        start = self.clock()
        out = Outcome(mode="native" if self._native_ok else "json")
        status = dispatcher.call("get_status")
        system = SYSTEM.format(name=helper_name, owner=dispatcher.owner)
        user = f"Order from {dispatcher.owner}: {order[:300]}\nCurrent state: {_compact(status)}"
        messages: list[dict] = [{"role": "system", "content": system}, {"role": "user", "content": user}]
        if not self._native_ok:
            messages[0]["content"] += JSON_PROTOCOL.format(catalog=json_catalog())
        actions = 0
        json_retry_used = False

        for _step in range(self.max_steps):
            left = self.timeout - (self.clock() - start)
            if left <= 0:
                out.stop = "timeout"
                break
            try:
                turn = self.model.complete(messages, T.openai_tools() if self._native_ok else None, left)
            except ToolsUnsupported:
                if self.mode == "native":
                    out.stop = "model_error"
                    break
                self._native_ok = False  # sticky for this process
                out.mode = "json"
                messages[0]["content"] += JSON_PROTOCOL.format(catalog=json_catalog())
                continue
            except Exception as exc:
                print(f"model error: {exc}", flush=True)
                out.stop = "model_error"
                break
            if self.clock() - start > self.timeout:
                out.stop = "timeout"
                break

            # ---- decode one action
            name: str | None = None
            args: Any = None
            call_id = None
            if self._native_ok and turn.tool_calls:
                call_id, name, raw = turn.tool_calls[0]  # one action at a time
                try:
                    args = json.loads(raw or "{}")
                except ValueError:
                    args = "<invalid json>"
                messages.append({"role": "assistant", "content": turn.content or None,
                                 "tool_calls": [{"id": call_id, "type": "function", "function": {"name": name, "arguments": raw or "{}"}}]})
            else:
                try:
                    kind, val = parse_json_turn(turn.content)
                except JsonProtocolError as e:
                    if self._native_ok and turn.content and not turn.content.lstrip().startswith(("{", "`")):
                        # native mode, plain text answer = final reply
                        kind, val = "reply", turn.content
                    elif not json_retry_used:
                        json_retry_used = True
                        messages.append({"role": "assistant", "content": turn.content})
                        messages.append({"role": "user", "content": f"Invalid answer ({e}). Reply with exactly one JSON object."})
                        continue
                    else:
                        out.stop = "bad_output"
                        break
                messages.append({"role": "assistant", "content": turn.content})
                if kind == "reply":
                    name, args = "reply", {"text": val[:200]}
                else:
                    name, args = val

            # ---- execute
            if name == "reply" or name in T.READ_ONLY or actions < self.max_actions:
                if name not in T.READ_ONLY and name in T.TOOL_NAMES:
                    actions += 1
                result = dispatcher.call(name, args) if name in T.TOOL_NAMES else {
                    "ok": False, "error": "bad_args", "message": f"unknown tool {name!r}", "state": {}}
            else:
                result = {"ok": False, "error": "action_limit", "message": "Too many actions for one order. Reply to the owner now.", "state": {}}
            out.calls.append((name, args if isinstance(args, dict) else {}, result))
            if call_id is not None:
                messages.append({"role": "tool", "tool_call_id": call_id, "content": _compact(result)})
            else:
                messages.append({"role": "user", "content": "Result: " + _compact(result)})
            if name == "reply" and result.get("ok"):
                out.replied = args["text"]
                out.stop = "replied"
                return out
            if result.get("error") == "action_limit":
                out.stop = "max_actions"
                break
        else:
            out.stop = "max_steps"

        if out.replied is None:
            # Always tell the owner something: the last tool message, or a generic note.
            last = next((r for n, _a, r in reversed(out.calls) if n != "get_status"), None)
            text = (last or {}).get("message") or "Sorry, I could not work that out. Try a simpler order."
            if out.stop == "timeout" and not last:
                text = "Sorry, I took too long to think. Try again."
            dispatcher.call("reply", {"text": text[:200]})
            out.replied = text[:200]
        return out
