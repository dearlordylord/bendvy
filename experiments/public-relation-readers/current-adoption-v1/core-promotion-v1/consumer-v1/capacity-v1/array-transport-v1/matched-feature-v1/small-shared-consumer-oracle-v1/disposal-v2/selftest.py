#!/usr/bin/env python3
"""Validate pinned source rules and the disposal-v2 epoch projection."""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

HERE = Path(__file__).resolve().parent
BASIS = json.loads((HERE / "SOURCE-BASIS.json").read_text())
PINS_PATH = HERE / BASIS["sourcePinManifest"]
PINS_BYTES = PINS_PATH.read_bytes()
PINS = json.loads(PINS_BYTES)


def import_from(path: Path, name: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


ORACLE = import_from(HERE / "generate_expected.py", "disposal_v2_oracle")
BASE = import_from(HERE.parent / "disposal-v1" / "generate_expected.py", "disposal_v1_oracle_for_test")


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def require(text: str, *needles: str) -> None:
    for needle in needles:
        assert needle in text, f"missing source rule: {needle}"


def source_text(source_root: Path, path: str) -> str:
    return (source_root / path).read_text()


def verify_source_pins(source_root: Path) -> None:
    assert BASIS["format"] == "bendvy-disposal-source-basis-v2"
    assert BASIS["runtimeOutputConsulted"] is False
    assert BASIS["foreignContextProvenance"] == (
        "trusted seeded W.Factory{2}; not ordinary WorldIO origin"
    )
    assert sha256(PINS_BYTES) == BASIS["sourcePinManifestSha256"]
    rows = BASIS["sources"]
    assert len(rows) == BASIS["sourcePinCount"] == 63
    assert len(PINS) == len(rows) == 63
    assert sorted(PINS) == [row["path"] for row in rows]
    for row in rows:
        pin = PINS[row["path"]]
        assert pin == {"bytes": row["bytes"], "sha256": row["sha256"]}
        raw = (source_root / row["path"]).read_bytes()
        assert len(raw) == row["bytes"], f"source size drift: {row['path']}"
        assert sha256(raw) == row["sha256"], f"source hash drift: {row['path']}"

    historical = BASIS["historicalModel"]
    base_generator = (HERE.parent / historical["generatorPath"].removeprefix("../")).read_bytes()
    base_expected = (HERE.parent / historical["expectedPath"].removeprefix("../")).read_bytes()
    assert sha256(base_generator) == historical["generatorSha256"]
    assert sha256(base_expected) == historical["expectedSha256"]

    stream_parameter = source_text(source_root, "src/ecs/ordinary-reader-stream-parameter.bend")
    event_runtime = source_text(source_root, "src/ecs/event-runtime.bend")
    event_stream = source_text(source_root, "src/ecs/event-stream.bend")
    event_notice = source_text(source_root, "src/ecs/event-notice-runtime.bend")
    failure_runtime = source_text(source_root, "src/ecs/relation-failure-runtime.bend")
    world = source_text(source_root, "src/ecs/world.bend")
    system = source_text(source_root, "src/ecs/system.bend")
    reader_system = source_text(source_root, "src/ecs/ordinary-reader-system.bend")
    combined = source_text(
        source_root,
        "experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/capacity-v1/array-transport-v1/matched-feature-v1/ordinary-combined-consumer.bend",
    )
    disposal = source_text(
        source_root,
        "experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/capacity-v1/array-transport-v1/matched-feature-v1/ordinary-disposal-consumer.bend",
    )

    # Registration allocates IDs but leaves the stream's initially empty
    # position list untouched. A and B therefore first create positions during
    # their respective prepare steps, rather than inheriting an init timestamp.
    require(
        event_stream,
        "Stream{domain,[],[],1,0n,0n,capacity,0n}",
        "case Stream{domain,batches,positions,+nextReader",
        "Stream{domain,batches,positions,(nextReader+1:U32)",
        "registered_checked(~S,~E,can_register(~S,~E,stream),stream,tick)",
    )
    require(
        stream_parameter,
        "Stream.registered(~S,~E,stream,tick)",
        "Stream.completed(~S,~E,stream,id,Nat.sub(tick,1n),False{})",
        "(EventOwner{facts,Route.Reader{namespace,id,registryId}},(EventView{reading},Nat.sub(tick,1n)))",
        "Stream.advance(~S,~E,stream,id,readThrough)",
        "Ev.activate(positions,readerId,tick)",
        "Ev.update(Ev.activate(positions,readerId,readThrough),readerId,readThrough,False{})",
    )
    require(
        event_stream,
        "case False{}:Ev.activate(positions,id,Nat.sub(tick,1n))",
        "case True{}:Ev.update(Ev.activate(positions,id,Nat.sub(tick,1n)),id,tick,False{})",
    )
    require(
        event_runtime,
        "case None{}: Position{id,0n,registered} <> positions",
        "case Some{_}: positions",
    )

    # The effective epoch is ingested into both relation-failure and route
    # state; then the same route tick is incremented after World.clock advances.
    # Successful after-processing ingests the resulting route tick once more.
    require(
        event_notice,
        "U32.to_nat(clock)",
        "Nat.max(1n,Nat.max(tick,Nat.max(failureTick,U32.to_nat(clock))))",
        "FailureRoute.collect(~S,~C,~R,~Notice.Notice<S,P>,~classify,world,tick,domains)",
        "Route.Runtime{world,State{typed,Failures{domains,positions,tick,start,boundary,capacity,nextReader}},tick}",
        "Route.Runtime{world,state,1n+tick}",
        "W.advance_clock(~S,~C,~R,~Notice.Notice<S,P>,world)",
        "ingest(~S,~C,~R,~P,~F,~H,~sync,~classify,tick,Route.Runtime{world,state,tick})",
    )
    require(failure_runtime, "Runtime{world,[],[],U32.to_nat(clock),0n,0n,65536n,1}")
    require(world, "World{namespace,1,0,Array.new(Bool,0n,False{}),1,0n,empty(Unit{}),resource,[],[],[],1,0}")
    require(world, "next_clock(U32.is_lt(clock,4294967295),clock)")
    require(
        system,
        "registry: Registry<S,C,R,E,Args,Error,Output,runner>,+nextCursor",
        "case Succeeded{world,output} Registry{namespace,id,name,access,_}: Completed{Registry{namespace,id,name,access,nextCursor}",
    )
    require(reader_system, "CallbackCompleted{output}", "W.clock(~S,~C,~R,~E,world)")

    # Relation prepare/commit uses the Failure.tick epoch directly, unlike the
    # double-subtracted event registration boundary.
    require(
        stream_parameter,
        "position=K.position_or(Ev.lookup(positions,readerId),readerId,tick)",
        "Ev.activate(positions,readerId,tick)",
        "+readThrough=tick",
        "Ev.update(Ev.activate(positions,readerId,readThrough),readerId,readThrough,False{})",
    )
    require(combined, "def setup() -> Setup:", "W.create(~Schema,~store_type(),~Unit,~event_type(),~empty_store,W.factory(),Unit{})")
    require(combined, "W.event_publish(~Schema,~store_type(),~Unit,~event_type(),world,")
    require(disposal, "Core.define_all(context,\"A\")", "Core.define_all(context,\"B\")", "Core.run_all(first,context,False{})", "Core.run_all(second,context,False{})")
    require(disposal, "W.Factory{2}", "foreign_context()")


def differences(left: Any, right: Any, path: str = "$") -> list[str]:
    if type(left) is not type(right):
        return [path]
    if isinstance(left, dict):
        if set(left) != set(right):
            return [path]
        out: list[str] = []
        for key in sorted(left):
            out.extend(differences(left[key], right[key], f"{path}.{key}"))
        return out
    if isinstance(left, list):
        if len(left) != len(right):
            return [path]
        out = []
        for index, (a, b) in enumerate(zip(left, right)):
            out.extend(differences(a, b, f"{path}[{index}]"))
        return out
    return [] if left == right else [path]


def verify_observation() -> None:
    old = BASE.expected_records()
    new = ORACLE.expected_records()
    expected_paths = [
        "$.contextAfterB.routeTick",
        "$.contextAfterB.shared.relationFailures.positions[0].cursor",
        "$.contextAfterB.shared.relationFailures.positions[0].registeredAt",
        "$.contextAfterB.shared.relationFailures.tick",
        "$.contextAfterB.shared.typed.stream.positions[0].cursor",
        "$.contextAfterB.shared.typed.stream.positions[0].registeredAt",
        "$.contextAfterB.shared.typed.stream.positions[1].cursor",
        "$.contextAfterB.shared.typed.stream.positions[1].registeredAt",
        "$.disposeA.after.routeTick",
        "$.disposeA.after.shared.relationFailures.tick",
        "$.disposeA.before.routeTick",
        "$.disposeA.before.shared.relationFailures.tick",
        "$.disposeA.before.shared.typed.stream.positions[0].cursor",
        "$.disposeA.before.shared.typed.stream.positions[1].cursor",
        "$.disposeB.after.routeTick",
        "$.disposeB.after.shared.relationFailures.tick",
        "$.disposeB.before.routeTick",
        "$.disposeB.before.shared.relationFailures.positions[0].cursor",
        "$.disposeB.before.shared.relationFailures.positions[0].registeredAt",
        "$.disposeB.before.shared.relationFailures.tick",
        "$.disposeB.before.shared.typed.stream.positions[0].cursor",
        "$.disposeB.before.shared.typed.stream.positions[0].registeredAt",
        "$.disposeB.before.shared.typed.stream.positions[1].cursor",
        "$.disposeB.before.shared.typed.stream.positions[1].registeredAt",
        "$.disposeB.provider.registry.cursor",
        "$.foreignRefusal.providerAfter.registry.cursor",
        "$.foreignRefusal.providerBefore.registry.cursor",
    ]
    assert differences(old, new) == expected_paths
    assert new["contextAfterB"] == new["disposeB"]["before"]

    a_before = new["disposeA"]["before"]
    assert (a_before["world"]["clock"], a_before["routeTick"], a_before["shared"]["relationFailures"]["tick"]) == (1, 2, 2)
    assert [(p["id"], p["cursor"], p["registeredAt"]) for p in a_before["shared"]["typed"]["stream"]["positions"]] == [(2, 1, 0), (1, 1, 0)]
    assert [(p["id"], p["cursor"], p["registeredAt"]) for p in a_before["shared"]["relationFailures"]["positions"]] == [(1, 1, 1)]
    assert new["disposeA"]["after"]["shared"]["typed"]["stream"]["positions"] == []
    assert new["disposeA"]["after"]["shared"]["relationFailures"]["positions"] == []

    b_before = new["contextAfterB"]
    assert (b_before["world"]["clock"], b_before["routeTick"], b_before["shared"]["relationFailures"]["tick"]) == (2, 3, 3)
    assert [(p["id"], p["cursor"], p["registeredAt"]) for p in b_before["shared"]["typed"]["stream"]["positions"]] == [(4, 2, 1), (3, 2, 1)]
    assert [(p["id"], p["cursor"], p["registeredAt"]) for p in b_before["shared"]["relationFailures"]["positions"]] == [(2, 2, 2)]
    assert new["disposeB"]["after"]["shared"]["typed"]["stream"]["positions"] == []
    assert new["disposeB"]["after"]["shared"]["relationFailures"]["positions"] == []
    assert new["disposeA"]["providerA"]["registry"]["cursor"] == 1
    assert new["disposeA"]["providerBBefore"]["registry"]["cursor"] == 0
    assert new["disposeA"]["providerBAfter"]["registry"]["cursor"] == 0
    assert new["disposeB"]["provider"]["registry"]["cursor"] == 2
    assert new["foreignRefusal"]["providerBefore"]["registry"]["cursor"] == 2
    assert new["foreignRefusal"]["providerAfter"]["registry"]["cursor"] == 2
    assert new["foreignRefusal"]["contextPreserved"] is True
    assert new["foreignRefusal"]["providerPreserved"] is True
    assert ORACLE.expected_bytes() == (HERE / "expected.stdout").read_bytes()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-root", type=Path, default=Path(BASIS["sourceSnapshotRoot"]))
    args = parser.parse_args()
    verify_source_pins(args.source_root)
    verify_observation()
    print("PASS: current 63-source pins, nested event epochs, failure/route/world clocks, and provider cursors")


if __name__ == "__main__":
    main()
