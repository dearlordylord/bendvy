#!/usr/bin/env python3
"""Render disposal observations against the current frozen source snapshot.

This model starts from the historical v1 fixture observations, then applies
only the source-derived current prepare/attempt epochs and successful read
cursors. Before-attempt ingestion installs the selected maximum epoch into the
route and relation-failure state; the attempt then advances the route again.
Event prepare passes routeTick - 1 to Stream.completed(False), which itself
subtracts one for a previously absent reader position.
"""
from __future__ import annotations

import copy
import importlib.util
import json
from pathlib import Path
from typing import Any

HERE = Path(__file__).resolve().parent
BASE_PATH = HERE.parent / "disposal-v1" / "generate_expected.py"
SPEC = importlib.util.spec_from_file_location("disposal_v1_oracle", BASE_PATH)
assert SPEC is not None and SPEC.loader is not None
BASE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BASE)


def compact(value: Any) -> str:
    return json.dumps(value, ensure_ascii=True, separators=(",", ":"))


def update_context(
    context: dict[str, Any], *, route_tick: int, failure_tick: int,
    event_cursor: int | None, event_registered_at: int,
    relation_cursor: int | None, relation_registered_at: int,
) -> None:
    context["routeTick"] = route_tick
    context["shared"]["relationFailures"]["tick"] = failure_tick
    event_positions = context["shared"]["typed"]["stream"]["positions"]
    if event_cursor is not None:
        assert [(p["id"], p["cursor"]) for p in event_positions] in (
            [(2, 0), (1, 0)], [(4, 1), (3, 1)]
        )
        for position in event_positions:
            position["cursor"] = event_cursor
            position["registeredAt"] = event_registered_at
    relation_positions = context["shared"]["relationFailures"]["positions"]
    if relation_cursor is not None:
        assert len(relation_positions) == 1
        relation_positions[0]["cursor"] = relation_cursor
        relation_positions[0]["registeredAt"] = relation_registered_at


def expected_records() -> dict[str, Any]:
    records = copy.deepcopy(BASE.expected_records())

    # Both event positions are absent after Stream.registered: it increments
    # nextReader but leaves positions unchanged. A's first prepare occurs at
    # route tick 2, so readThrough is 1 and the new position has regAt 0.
    for key in ("before", "after"):
        update_context(
            records["disposeA"][key], route_tick=2, failure_tick=2,
            event_cursor=1 if key == "before" else None,
            event_registered_at=0, relation_cursor=None,
            relation_registered_at=1,
        )

    # B's first prepare occurs at route tick 3. The double subtraction for a
    # new event position yields regAt 1; readThrough/cursors are 2. Relation
    # prepare uses the current failure epoch directly, also 2.
    update_context(
        records["contextAfterB"], route_tick=3, failure_tick=3,
        event_cursor=2, event_registered_at=1, relation_cursor=2,
        relation_registered_at=2,
    )
    if records["disposeB"]["before"] is not records["contextAfterB"]:
        update_context(
            records["disposeB"]["before"], route_tick=3, failure_tick=3,
            event_cursor=2, event_registered_at=1, relation_cursor=2,
            relation_registered_at=2,
        )
    update_context(
        records["disposeB"]["after"], route_tick=3, failure_tick=3,
        event_cursor=None, event_registered_at=1, relation_cursor=None,
        relation_registered_at=2,
    )

    # The tracked System cursor comes from the post-attempt World.clock.
    records["disposeB"]["provider"]["registry"]["cursor"] = 2
    for key in ("providerBefore", "providerAfter"):
        records["foreignRefusal"][key]["registry"]["cursor"] = 2

    assert records["contextAfterB"] == records["disposeB"]["before"]
    assert records["disposeA"]["before"]["world"]["clock"] == 1
    assert records["contextAfterB"]["world"]["clock"] == 2
    assert records["disposeA"]["before"]["shared"]["relationFailures"]["tick"] == 2
    assert records["contextAfterB"]["shared"]["relationFailures"]["tick"] == 3
    assert records["disposeA"]["providerA"]["registry"]["cursor"] == 1
    assert records["disposeB"]["provider"]["registry"]["cursor"] == 2
    return records


def expected_bytes() -> bytes:
    return (compact(expected_records()) + "\n").encode("ascii")


def main() -> None:
    print(compact(expected_records()))


if __name__ == "__main__":
    main()
