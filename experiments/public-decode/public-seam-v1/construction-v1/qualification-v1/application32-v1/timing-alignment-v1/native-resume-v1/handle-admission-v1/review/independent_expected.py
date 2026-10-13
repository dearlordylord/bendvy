#!/usr/bin/env python3
"""Independent source-derived 22-case handle-admission oracle.

This model is intentionally independent of Bend/runtime output.  It mirrors
only the current main.bend target matrix, decode-data HandleValue validation,
world reverse-pending/FIFO barrier, component lifecycle clock, and the
single-resource tx_replace semantics.  It is a review aid for model.py; it is
not a replacement for the owner's source freeze or execution receipt.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Literal

Target = Literal["2:1", "1:0", "1:1", "null"]


@dataclass(frozen=True)
class Payload:
    values: tuple[int, ...]
    name: str
    target: Target

    def typed(self) -> str:
        return f"{self.name}:{','.join(map(str, self.values))},:{self.target}"

    def raw(self) -> str:
        if self.target == "null":
            rendered_target = "null"
        else:
            rendered_target = f"handle:{self.target}"
        values = ",".join(f"u32:{value}" for value in self.values)
        return (
            f"{{cells:[{values}],name:str:{self.name},"
            f"target:{rendered_target}}}"
        )


SEED_FIRST = Payload((11, 12), "seed", "1:1")
SEED_FOREIGN = Payload((21, 22), "seed", "2:1")
RESOURCE_FIRST = Payload((100, 101), "resource", "null")
RESOURCE_FOREIGN = Payload((300, 301), "foreignresource", "null")


@dataclass(frozen=True)
class Row:
    value: Payload | None
    added: int = 0
    changed: int = 0


@dataclass(frozen=True)
class State:
    namespace: int
    next_id: int
    high_water: int
    live: str
    capacity: int
    depth: int
    rows: tuple[Row, ...]
    resource: Payload
    events: tuple[int, ...]
    pending: int
    next_system_id: int
    clock: int

    def snapshot(self) -> str:
        rendered_rows = "".join(
            row_text(index + 1, row) for index, row in enumerate(self.rows)
        )
        rendered_events = "".join(f"{event}," for event in self.events)
        # registration_text is empty: this fixture registers no systems.
        return "/".join(
            (
                str(self.namespace),
                str(self.next_id),
                str(self.high_water),
                self.live,
                str(self.capacity),
                str(self.depth),
                rendered_rows,
                self.resource.typed(),
                rendered_events,
                str(self.pending),
                "",
                str(self.next_system_id),
                str(self.clock),
            )
        )


def row_text(index: int, row: Row) -> str:
    rendered = "none;" if row.value is None else f"{row.value.raw()};"
    return f"row{index}={rendered}stamp:{row.added}:{row.changed};"


def initial_state() -> State:
    return State(
        namespace=1,
        next_id=2,
        high_water=1,
        live="01",
        capacity=2,
        depth=1,
        rows=(Row(SEED_FIRST, 1, 1),),
        resource=RESOURCE_FIRST,
        events=(77,),
        pending=0,
        next_system_id=1,
        clock=1,
    )


def foreign_state() -> State:
    return State(
        namespace=2,
        next_id=2,
        high_water=1,
        live="01",
        capacity=2,
        depth=1,
        rows=(Row(SEED_FOREIGN, 1, 1),),
        resource=RESOURCE_FOREIGN,
        events=(),
        pending=0,
        next_system_id=1,
        clock=1,
    )


def incoming(target: Target) -> Payload:
    return Payload((41, 42, 43, 44), "incoming", target)


def target_for(selector: int) -> Target:
    if selector in (0, 1, 2):
        return "2:1"
    if selector in (3, 4, 5):
        return "1:0"
    if selector == 10:
        return "null"
    return "1:1"


def operation_target_for(selector: int) -> Target:
    return "2:1" if selector == 9 else "1:1"


def route_for(selector: int) -> Literal["spawn", "insert", "resource"]:
    if selector in (0, 3, 6):
        return "spawn"
    if selector in (1, 4, 7, 9):
        return "insert"
    return "resource"


def validation_error(target: Target) -> str:
    # decode-data.bend renders D.Invalid as path:expected:raw(actual).
    return f"$.target:same-world handle:handle:{target}"


def state_for(selector: int, payload: Payload) -> State:
    """Return state after the second admission and the FIFO barrier."""
    base = initial_state()
    route = route_for(selector)
    if selector == 6 and route == "spawn":
        # Reservations happen before barrier; the first and second queued
        # spawn_apply closures then activate/populate IDs 2 and 3 in FIFO order.
        return State(
            namespace=1,
            next_id=4,
            high_water=3,
            live="0111",
            capacity=4,
            depth=2,
            rows=(
                Row(SEED_FIRST, 1, 1),
                Row(payload, 2, 2),
                Row(payload, 3, 3),
            ),
            resource=RESOURCE_FIRST,
            events=(77,),
            pending=0,
            next_system_id=1,
            clock=3,
        )
    if selector == 7 and route == "insert":
        # Both insert closures target ID1 and are applied after the marker.
        return State(
            namespace=1,
            next_id=2,
            high_water=1,
            live="01",
            capacity=2,
            depth=1,
            rows=(Row(payload, 1, 3),),
            resource=RESOURCE_FIRST,
            events=(77,),
            pending=0,
            next_system_id=1,
            clock=3,
        )
    if selector in (8, 10) and route == "resource":
        # Resource replacement is immediate inside the transaction.  The old
        # value is rollback-only undo state and is not retained in World.
        return State(
            namespace=1,
            next_id=2,
            high_water=1,
            live="01",
            capacity=2,
            depth=1,
            rows=(Row(SEED_FIRST, 1, 1),),
            resource=payload,
            events=(77,),
            pending=0,
            next_system_id=1,
            clock=1,
        )
    return base


def line_for(selector: int) -> str:
    payload = incoming(target_for(selector))
    route = route_for(selector)
    # HandleValue requires same namespace and positive id.  Selector 9 is
    # intentionally different: payload decodes, but Insert uses foreign 2:1.
    valid_payload = selector >= 6
    entity_refused = selector == 9 and route == "insert"
    if not valid_payload:
        checked = validation_error(payload.target)
        owner = f"{payload.typed()};"
        host = "not-attempted"
    else:
        checked = f"ok:{payload.raw()}"
        if entity_refused:
            owner = f"{payload.typed()};"
            host = "rejected:MissingEntity"
        else:
            owner = "none;"
            host = "accepted"
    return (
        f"{checked}|{owner}|host:{host}|{state_for(selector, payload).snapshot()}"
        f"|foreign:{foreign_state().snapshot()}|factory:3"
    )


def expected_lines() -> list[str]:
    first = [line_for(selector) for selector in range(11)]
    second = [line_for(selector) for selector in range(11)]
    assert first == second, "phantom schema must not alter formatter output"
    return first + second


def audit_rows(lines: Iterable[str]) -> None:
    rows = list(lines)
    assert len(rows) == 22
    assert rows[:11] == rows[11:]
    # Independent semantic checks on the state suffixes.
    assert "|1/2/1/01/2/1/" in rows[0]
    assert "|1/4/3/0111/4/2/" in rows[6]
    assert "stamp:1:3;" in rows[7]
    assert "/resource:100,101,:null/" in rows[7]
    assert "/incoming:41,42,43,44,:1:1/" in rows[8]
    assert "host:rejected:MissingEntity" in rows[9]
    assert "/incoming:41,42,43,44,:null/" in rows[10]


if __name__ == "__main__":
    output = expected_lines()
    audit_rows(output)
    print("\n".join(output))
