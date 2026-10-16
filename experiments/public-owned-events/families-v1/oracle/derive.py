#!/usr/bin/env python3
"""Source-derived stdout oracle for the frozen #53 family-publisher trace.

This model is built from the pinned Bend entry, family routes, transaction
journal, and observer. It does not execute Bend, JS, Native, or candidate
outputs.
"""
from __future__ import annotations

import argparse
import gzip
import hashlib
import json
from dataclasses import dataclass, field
from pathlib import Path


ACCESS_PUBLISHER = ("Cargo:write", "Alerts:write", "Crates:write")
ACCESS_QUERY = (
    "Value",
    "Counter",
    "Cargo:write",
    "Alerts:write",
    "Crates:write",
)
SCHEMAS = (("Workshop", 1, 2), ("Garden", 3, 4))


def sha256(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def show_list(items, render=str) -> str:
    return "[" + ", ".join(render(item) for item in items) + "]"


def show_bool(value: bool) -> str:
    return "True" if value else "False"


def show_array(values: tuple[int, int]) -> str:
    return f"N(L({values[0]}),L({values[1]}))"


def show_matrix(value: tuple[tuple[int, int], tuple[int, int]]) -> str:
    left, right = value
    return f"N({show_array(left)},{show_array(right)})"


def show_payloads(values, render=show_array) -> str:
    # observe.bend's recursive list view ends in [] and uses semicolons.
    return "[]" if not values else ";".join(render(v) for v in values) + ";[]"


def show_log_rows(rows, render=show_array) -> str:
    body = ";".join(f"{ident}:{render(payload)}" for ident, payload in rows)
    return "[]" if not body else body + ";[]"


@dataclass
class EventLog:
    next_id: int = 1
    rows: list[tuple[int, object]] = field(default_factory=list)

    def append(self, payload: object) -> int:
        ident = self.next_id
        self.next_id += 1
        self.rows.append((ident, payload))
        return ident


@dataclass
class World:
    namespace: int
    primary: bool
    next_id: int = 1
    high_water: int = 0
    capacity: int = 1
    depth: int = 0
    live: list[bool] = field(default_factory=lambda: [False])
    values: dict[int, int] = field(default_factory=dict)
    stamps: dict[int, tuple[int, int]] = field(default_factory=dict)
    user: tuple[int, int] = (100, 101)
    cargo: EventLog = field(default_factory=EventLog)
    alerts: EventLog = field(default_factory=EventLog)
    crates: EventLog = field(default_factory=EventLog)
    events: list[tuple[str, int]] = field(default_factory=list)
    regs: list[tuple[int, str, tuple[str, ...]]] = field(default_factory=list)
    next_system_id: int = 1
    clock: int = 0

    @classmethod
    def created(cls, namespace: int, primary: bool) -> "World":
        return cls(namespace=namespace, primary=primary)

    def register(self, name: str, access: tuple[str, ...]) -> tuple[int, str, tuple[str, ...]]:
        ident = self.next_system_id
        self.next_system_id += 1
        meta = (ident, name, access)
        self.regs.insert(0, meta)
        return meta

    def reserve_activate(self) -> None:
        ident = self.next_id
        if ident >= self.capacity:
            old_capacity = self.capacity
            old_live = self.live
            self.capacity *= 2
            self.depth += 1
            self.live = old_live + [False] * old_capacity
        self.live[ident] = True
        self.next_id += 1
        self.high_water = ident

    def replace_value(self, ident: int, value: int) -> None:
        self.clock += 1
        if ident not in self.values:
            self.stamps[ident] = (self.clock, self.clock)
        else:
            added, _ = self.stamps[ident]
            self.stamps[ident] = (added, self.clock)
        self.values[ident] = value

    def publish_one(self, family: str, payload: object) -> None:
        log = {"Cargo": self.cargo, "Alerts": self.alerts, "Crates": self.crates}[family]
        ident = log.append(payload)
        self.events.append((family, ident))

    def live_tree(self) -> str:
        def build(bits: list[bool]) -> str:
            if len(bits) == 1:
                return f"L({show_bool(bits[0])})"
            middle = len(bits) // 2
            return f"N({build(bits[:middle])},{build(bits[middle:])})"

        return build(self.live)

    def column_rows(self) -> str:
        rows = []
        for ident in (1, 2, 3, 4):
            value = self.values.get(ident)
            shown = "None" if value is None else f"Some({value})"
            added, changed = self.stamps.get(ident, (0, 0))
            rows.append(f"row{ident}={shown}@({added},{changed})")
        # composition-v1 observer's rows_join places a semicolon after each row.
        return ";".join(rows) + ";"

    @staticmethod
    def event_text(event: tuple[str, int]) -> str:
        family, ident = event
        if family == "Cargo":
            return f"Pub(first=[{ident}],second=[])"
        if family == "Alerts":
            return f"Pub(first=[],second=[Pub(first=[{ident}],second=[])])"
        if family == "Crates":
            return f"Pub(first=[],second=[Pub(first=[],second=[{ident}])])"
        raise AssertionError(f"unknown publication family: {family}")

    def render(self) -> str:
        user = show_array(self.user)
        return (
            f"world(ns={self.namespace},next={self.next_id},high={self.high_water},"
            f"live={self.live_tree()},capacity={self.capacity},depth={self.depth},"
            f"column={{{self.column_rows()}}},user={user},"
            f"Cargo=log(next={self.cargo.next_id},rows={show_log_rows(self.cargo.rows)}),"
            f"Alerts=log(next={self.alerts.next_id},rows={show_log_rows(self.alerts.rows)}),"
            f"Crates=log(next={self.crates.next_id},rows={show_log_rows(self.crates.rows, show_matrix)}),"
            f"events={show_list(self.events, self.event_text)},pending=0,"
            f"regs={show_list(self.regs, render_meta)},sid={self.next_system_id},clock={self.clock})"
        )


def render_meta(meta: tuple[int, str, tuple[str, ...]]) -> str:
    ident, name, access = meta
    return f"({ident},{name},{show_list(access)})"


def render_registry(world: World, meta: tuple[int, str, tuple[str, ...]], cursor: int) -> str:
    ident, name, access = meta
    return (
        f"registry(ns={world.namespace},id={ident},name={name},"
        f"access={show_list(access)},cursor={cursor})"
    )


def render_publisher(world: World, meta: tuple[int, str, tuple[str, ...]]) -> str:
    ident, name, access = meta
    return (
        f"publisher(ns={world.namespace},id={ident},name={name},"
        f"access={show_list(access)},cursor=0)"
    )


def render_snapshot(
    world: World,
    registry: tuple[int, str, tuple[str, ...]],
    cursor: int,
    foreign: World,
    publisher: tuple[int, str, tuple[str, ...]],
) -> str:
    return (
        f"world:{world.render()}{render_registry(world, registry, cursor)}"
        f"foreign:{foreign.render()}{render_publisher(world, publisher)}"
    )


def emit_values(value: int, delta: int) -> list[tuple[str, object]]:
    # fixture.publish is literally A, B, A, C; this order is retained by the
    # Journal reverse-accumulate/reverse-on-finish adapter.
    return [
        ("Cargo", (value, delta)),
        ("Alerts", (value + 100, delta)),
        ("Cargo", (value + 1, delta)),
        ("Crates", ((value, delta), (value + 2, delta))),
    ]


def commit_events(world: World, emitted: list[tuple[str, object]]) -> None:
    for family, payload in emitted:
        world.publish_one(family, payload)


def recovery_text(recovered: list[tuple[str, object]]) -> str:
    by_family = {"Cargo": [], "Alerts": [], "Crates": []}
    for family, payload in recovered:
        by_family[family].append(payload)
    return (
        "recovery(Cargo="
        + show_payloads(by_family["Cargo"])
        + ",Alerts="
        + show_payloads(by_family["Alerts"])
        + ",Crates="
        + show_payloads(by_family["Crates"], show_matrix)
        + ")"
    )


def query_call(
    world: World,
    registry: tuple[int, str, tuple[str, ...]],
    foreign: World,
    publisher: tuple[int, str, tuple[str, ...]],
    cursor: int,
    delta: int,
    fail_value: int,
) -> tuple[str, int]:
    before_values = dict(world.values)
    before_stamps = dict(world.stamps)
    before_user = world.user
    output: list[int] = []
    emitted: list[tuple[str, object]] = []
    failed_at: int | None = None

    # World.handles returns ascending live handles. The required Value clause
    # skips the third live entity because it has no Value owner.
    for ident in (1, 2, 3):
        if not world.live[ident] or ident not in world.values:
            continue
        old = world.values[ident]
        world.replace_value(ident, old + delta)
        n = world.user[0]
        world.user = (n + 1, n + 2)
        emitted.extend(emit_values(old, delta))
        if old == fail_value:
            failed_at = old
            break
        output.append(old)

    if failed_at is None:
        commit_events(world, emitted)
        cursor = world.clock
        status = f"success:values={show_list(output)}:recovered={recovery_text([])}\n"
    else:
        # Tx.finish restores each replaced component and the resource. The
        # monotonic clock intentionally remains advanced, and the family
        # journal returns only its semantic-failure receipts.
        world.values = before_values
        world.stamps = before_stamps
        world.user = before_user
        status = (
            f"failed-at={failed_at}:values=[]:recovered={recovery_text(emitted)}\n"
        )

    return status, cursor


def primary_snapshot(
    world: World,
    query_meta: tuple[int, str, tuple[str, ...]],
    cursor: int,
    foreign: World,
    publisher_meta: tuple[int, str, tuple[str, ...]],
) -> str:
    return render_snapshot(world, query_meta, cursor, foreign, publisher_meta)


def schema_trace(namespace: int, foreign_namespace: int) -> str:
    world = World.created(namespace, primary=True)
    foreign = World.created(foreign_namespace, primary=False)

    publisher_meta = world.register("empty-world-publisher", ACCESS_PUBLISHER)
    # This source call runs the standalone publisher before any entity exists.
    text = (
        "empty-world-before:"
        + world.render()
        + "publisher:"
        + render_publisher(world, publisher_meta)
        + "empty-published:7:recovered=recovery(Cargo=[],Alerts=[],Crates=[])\n"
    )
    commit_events(world, emit_values(900, 7))
    text += (
        "empty-world-after:"
        + world.render()
        + "publisher:"
        + render_publisher(world, publisher_meta)
    )

    # Three reservations grow the live tree to four slots. The third is left
    # without a Value component; the two public replacements each advance the
    # source world clock once.
    for _ in range(3):
        world.reserve_activate()
    world.replace_value(1, 10)
    world.replace_value(2, 20)
    query_meta = world.register("family-query-publisher", ACCESS_QUERY)
    cursor = 0
    text += primary_snapshot(world, query_meta, cursor, foreign, publisher_meta)

    for delta, fail_value in ((1, 0), (10, 21), (2, 0)):
        status, cursor = query_call(
            world,
            query_meta,
            foreign,
            publisher_meta,
            cursor,
            delta,
            fail_value,
        )
        text += status
        text += primary_snapshot(world, query_meta, cursor, foreign, publisher_meta)

    # Sys.run performs namespace validation before invoking the registered body.
    text += f"refused:99:0:{cursor}\n"
    text += primary_snapshot(world, query_meta, cursor, foreign, publisher_meta)
    return text


def derive() -> bytes:
    # main.bend concatenates Garden immediately after the last Workshop
    # snapshot. IO.print contributes the one final LF after the whole string.
    return (
        "Workshop\n"
        + schema_trace(1, 2)
        + "Garden\n"
        + schema_trace(3, 4)
        + "\n"
    ).encode("utf-8")


def check_source_basis(source_root: Path, basis_path: Path) -> None:
    basis = json.loads(basis_path.read_text(encoding="utf-8"))
    root = source_root.resolve()
    freeze = (root / basis["producer"]["sourceFreezePath"]).read_bytes()
    assert sha256(freeze) == basis["producer"]["sourceFreezeSha256"]
    frozen = json.loads(freeze)
    assert frozen["sourcePins"] == basis["producer"]["absoluteSourcePins"]
    for relative, expected in basis["producer"]["sourceFiles"].items():
        assert sha256((root / relative).read_bytes()) == expected, relative
    for name, pin in basis["runtimeBasis"].items():
        assert sha256(Path(pin["path"]).read_bytes()) == pin["sha256"], name


def selftest(raw: bytes) -> None:
    text = raw.decode("utf-8")
    assert text.startswith("Workshop\nempty-world-before:world(ns=1,")
    assert "Garden\nempty-world-before:world(ns=3," in text
    assert text.count("empty-world-before:world(ns=") == 2
    assert text.count("empty-world-after:world(ns=") == 2
    assert text.count("world:world(ns=") == 10
    # The foreign world is projected alongside the five query snapshots per
    # schema; the two standalone publisher snapshots contain no foreign view.
    assert text.count("foreign:world(ns=") == 10
    assert text.count("empty-published:7:recovered=recovery(Cargo=[],Alerts=[],Crates=[])\n") == 2
    assert text.count("success:values=[10, 20]:recovered=recovery(Cargo=[],Alerts=[],Crates=[])\n") == 2
    assert text.count(
        "failed-at=21:values=[]:recovered=recovery(Cargo=N(L(11),L(10));N(L(12),L(10));N(L(21),L(10));N(L(22),L(10));[],Alerts=N(L(111),L(10));N(L(121),L(10));[],Crates=N(N(L(11),L(10)),N(L(13),L(10)));N(N(L(21),L(10)),N(L(23),L(10)));[])\n"
    ) == 2
    assert text.count("success:values=[11, 21]:recovered=recovery(Cargo=[],Alerts=[],Crates=[])\n") == 2
    assert text.count("refused:99:0:8\n") == 2
    assert "next=4,high=3,live=N(N(L(False),L(True)),N(L(True),L(True))),capacity=4,depth=2" in text
    assert "row1=Some(11)@(1,3);row2=Some(21)@(2,4);row3=None@(0,0);row4=None@(0,0);" in text
    assert "row1=Some(11)@(1,3);row2=Some(21)@(2,4);row3=None@(0,0);row4=None@(0,0);" in text
    assert "counter" not in text
    assert "user=N(L(102),L(103))" in text
    assert "user=N(L(104),L(105))" in text
    assert "clock=6" in text and "clock=8" in text
    assert "Cargo=log(next=11," in text
    assert "Alerts=log(next=6," in text
    assert "Crates=log(next=6," in text
    assert text.endswith("\n") and not text.endswith("\n\n")
    assert text.count("Garden\n") == 1

    # Independently check rollback/retry owner transitions, not only rendering.
    world = World.created(1, primary=True)
    foreign = World.created(2, primary=False)
    publisher_meta = world.register("empty-world-publisher", ACCESS_PUBLISHER)
    commit_events(world, emit_values(900, 7))
    for _ in range(3):
        world.reserve_activate()
    world.replace_value(1, 10)
    world.replace_value(2, 20)
    query_meta = world.register("family-query-publisher", ACCESS_QUERY)
    cursor = 0
    status, cursor = query_call(world, query_meta, foreign, publisher_meta, cursor, 1, 0)
    assert status.startswith("success:values=[10, 20]")
    assert (world.clock, world.user, cursor) == (4, (102, 103), 4)
    before = world.render()
    status, cursor = query_call(world, query_meta, foreign, publisher_meta, cursor, 10, 21)
    assert status.startswith("failed-at=21:values=[]:")
    assert (world.clock, world.user, cursor) == (6, (102, 103), 4)
    assert world.render().replace("clock=6)", "clock=4)") == before
    assert world.values == {1: 11, 2: 21}
    assert world.stamps == {1: (1, 3), 2: (2, 4)}
    assert [ident for ident, _ in world.cargo.rows] == [1, 2, 3, 4, 5, 6]
    assert [family for family, _ in world.events] == [
        "Cargo", "Alerts", "Cargo", "Crates",
        "Cargo", "Alerts", "Cargo", "Crates",
        "Cargo", "Alerts", "Cargo", "Crates",
    ]
    status, cursor = query_call(world, query_meta, foreign, publisher_meta, cursor, 2, 0)
    assert status.startswith("success:values=[11, 21]")
    assert (world.clock, world.user, cursor) == (8, (104, 105), 8)
    before_primary = world.render()
    before_foreign = foreign.render()
    assert f"refused:99:0:{cursor}\n" == "refused:99:0:8\n"
    assert world.render() == before_primary
    assert foreign.render() == before_foreign


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--selftest", action="store_true")
    parser.add_argument(
        "--source-root",
        type=Path,
        default=Path("/workspace/formal-proofs/bendvy-worktrees/events53-ordinary"),
        help="frozen producer worktree used to verify exact source pins",
    )
    args = parser.parse_args()
    out = Path(__file__).resolve().parent
    basis_path = out / "SOURCE-BASIS.json"
    check_source_basis(args.source_root, basis_path)
    raw = derive()
    selftest(raw)
    compressed = gzip.compress(raw, compresslevel=9, mtime=0)
    metadata = {
        "bytes": len(raw),
        "gzipSha256": sha256(compressed),
        "rawSha256": sha256(raw),
        "snapshotsPerSchema": 7,
        "schemas": 2,
    }
    expected_path = out / "expected.stdout"
    gzip_path = out / "expected.stdout.gz"
    metadata_path = out / "EXPECTED.json"
    if args.selftest:
        assert expected_path.read_bytes() == raw
        retained = gzip_path.read_bytes()
        assert retained == compressed
        assert gzip.decompress(retained) == raw
        assert json.loads(metadata_path.read_text(encoding="utf-8")) == metadata
        print(json.dumps({"selftest": "PASS", **metadata}, sort_keys=True))
        return
    expected_path.write_bytes(raw)
    gzip_path.write_bytes(compressed)
    metadata_path.write_text(
        json.dumps(metadata, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(json.dumps(metadata, sort_keys=True))


if __name__ == "__main__":
    main()
