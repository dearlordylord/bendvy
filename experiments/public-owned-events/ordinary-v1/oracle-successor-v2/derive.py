#!/usr/bin/env python3
"""Source-derived serializer for the frozen #53 ordinary owned-event trace.

This models the public scenario and observers from the frozen source; it does
not invoke Bend, Node, Native, a generated artifact, or a runtime receipt.
"""
from __future__ import annotations

from dataclasses import dataclass, field
import argparse
from pathlib import Path
import gzip
import hashlib
import json

SCHEMAS = ("Workshop", "Garden")
ACTIONS = (
    "fast", "slow", "publish", "failed", "slow-retry", "abort",
    "next", "frame", "fast-after-frame", "skip", "frame", "frame",
    "foreign", "drain", "drain",
)
MARKERS = (90, 91)


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def show_list(items, render=str) -> str:
    return "[" + ", ".join(render(item) for item in items) + "]"


def show_bool(value: bool) -> str:
    # Pinned Base.Bool.show uses these constructor spellings.
    return "True" if value else "False"


def show_payload(pair: tuple[int, int]) -> str:
    left, right = pair
    return f"N(L({left}),L({right}))"


def show_payloads(pairs) -> str:
    values = list(pairs)
    if not values:
        return "[]"
    # observe.payload_rows recurses to the literal "[]" base case and each
    # predecessor adds "<head>;". Preserve that source-level terminator.
    return ";".join(show_payload(pair) for pair in values) + ";[]"


def payload_pair(seed: int) -> tuple[int, int]:
    return (seed, seed + 1)


@dataclass(frozen=True)
class Row:
    id: int
    payload: tuple[int, int]


@dataclass(frozen=True)
class Batch:
    tick: int
    values: tuple[int, ...]


@dataclass(frozen=True)
class Position:
    id: int
    cursor: int
    registered_at: int


@dataclass
class Args:
    fail: bool
    values: list[tuple[int, tuple[int, ...]]] = field(default_factory=list)
    scratch: list[int] = field(default_factory=list)


@dataclass
class Host:
    schema: str
    namespace: int
    foreign_namespace: int
    log_next: int = 1
    rows: list[Row] = field(default_factory=list)
    events: list[int] = field(default_factory=list)
    batches: list[Batch] = field(default_factory=list)
    positions: list[Position] = field(default_factory=list)
    next_reader: int = 3
    tick: int = 0
    frame_start: int = 0
    boundary: int = 0
    capacity: int = 2
    dropped: int = 0
    fast_args: Args = field(default_factory=lambda: Args(False, [], [100, 101]))
    slow_args: Args = field(default_factory=lambda: Args(False, [], [200, 201]))

    def _position(self, reader_id: int) -> Position | None:
        return next((p for p in self.positions if p.id == reader_id), None)

    def _append_publication(self, seeds: tuple[int, ...]) -> None:
        ids = []
        for seed in seeds:
            ident = self.log_next
            self.log_next += 1
            self.rows.append(Row(ident, payload_pair(seed)))
            ids.append(ident)
        self.events.extend(ids)
        self.batches.append(Batch(self.tick, tuple(ids)))

    def _read(self, reader_id: int, fail: bool, args: Args) -> str:
        before = list(self.positions)
        old_tick = self.tick
        old_position = self._position(reader_id)
        cursor = 0 if old_position is None else old_position.cursor
        registered_at = old_tick if old_position is None else old_position.registered_at
        lagged = max(cursor, registered_at) < self.dropped
        selected = [
            ident
            for batch in self.batches
            if batch.tick > cursor
            for ident in batch.values
        ]
        args.fail = fail
        self.tick = old_tick + 1
        body_failed = False
        for ident in selected:
            row = next((r for r in self.rows if r.id == ident), None)
            if row is None:
                # The frozen source maps this to MissingPayload. The reached
                # scenario never hits it, but retaining the branch prevents the
                # model from silently fabricating an owner for an absent row.
                body_failed = True
                break
            args.values.append((row.payload[0], MARKERS))
            args.scratch[0] += 1
            # Read.fold_rows stops on the first semantic body failure. Thus the
            # reached failing slow read consumes only row 1 in its Args output.
            if fail:
                body_failed = True
                break
        if body_failed:
            # Read.run returns the affine Args but restores its pre-run reader
            # positions through reconciled/failed_positions.
            self.positions = before
            return f"failed:lagged={show_bool(lagged)}\n"

        if old_position is None:
            self.positions.insert(0, Position(reader_id, 0, old_tick))
        self.positions = [
            Position(p.id, self.tick, p.registered_at) if p.id == reader_id else p
            for p in self.positions
        ]
        return f"read:lagged={show_bool(lagged)}\n"

    def _frame(self) -> str:
        old_frame_start = self.frame_start
        retention_boundary = old_frame_start
        for position in self.positions:
            retention_boundary = min(retention_boundary, position.cursor)

        retained = []
        dropped = self.dropped
        for batch in self.batches:
            if batch.tick <= retention_boundary:
                dropped = max(dropped, batch.tick)
            else:
                retained.append(batch)

        while sum(len(batch.values) for batch in retained) > self.capacity:
            lost = retained.pop(0)
            dropped = max(dropped, lost.tick)

        self.frame_start = self.tick
        # EventRuntime.frame stores the prior frameStart in `boundary`. The
        # position-limited retention cutoff is passed only to past_window;
        # trim_result returns the Runtime boundary field unchanged.
        self.boundary = old_frame_start
        self.dropped = dropped
        self.batches = retained
        self.events = [ident for batch in retained for ident in batch.values]
        retained_ids = set(self.events)
        retired = [row for row in self.rows if row.id not in retained_ids]
        self.rows = [row for row in self.rows if row.id in retained_ids]
        return "retired:" + self._show_rows(retired) + "\n"

    @staticmethod
    def _show_rows(rows: list[Row]) -> str:
        if not rows:
            return "[]"
        # observe.rows uses the same recursive tail sentinel as payload_rows.
        return ";".join(f"{row.id}:{show_payload(row.payload)}" for row in rows) + ";[]"

    def _world(self, *, foreign: bool = False) -> str:
        if foreign:
            namespace = self.foreign_namespace
            log_next = 1
            rows: list[Row] = []
            events: list[int] = []
            registrations: list[str] = []
            next_system = 1
        else:
            namespace = self.namespace
            log_next = self.log_next
            rows = self.rows
            events = self.events
            registrations = [
                "(3,slow,[Cargo:read])",
                "(2,fast,[Cargo:read])",
                "(1,publisher,[Cargo:write])",
            ]
            next_system = 4
        resources = f"user=Unit,log(next={log_next},rows={self._show_rows(rows)})"
        return (
            f"world({namespace},1,0,L(False),1,0,store=Unit,{resources},"
            f"events={show_list(events)},pending=0,regs={show_list(registrations)},"
            f"sid={next_system},clock=0)"
        )

    def _reader_statuses(self) -> str:
        rendered = []
        for position in self.positions:
            unread = sum(
                len(batch.values) for batch in self.batches if batch.tick > position.cursor
            )
            lagged = max(position.cursor, position.registered_at) < self.dropped
            rendered.append(
                f"({position.id},{position.cursor},{position.registered_at},"
                f"{unread},{show_bool(lagged)})"
            )
        return show_list(rendered)

    def _runtime(self) -> str:
        batches = show_list(
            self.batches,
            lambda batch: f"({batch.tick},{show_list(batch.values)})",
        )
        positions = show_list(
            self.positions,
            lambda position: f"({position.id},{position.cursor},{position.registered_at})",
        )
        return (
            f"runtime(ns={self.namespace},batches={batches},positions={positions},"
            f"status={self._reader_statuses()},next={self.next_reader},tick={self.tick},"
            f"frameStart={self.frame_start},boundary={self.boundary},"
            f"capacity={self.capacity},dropped={self.dropped},{self._world()})"
        )

    @staticmethod
    def _show_args(args: Args) -> str:
        values = show_list(
            args.values,
            lambda value: f"({value[0]},{show_list(value[1])})",
        )
        return (
            f"args(fail={show_bool(args.fail)},values={values},"
            f"scratch={show_payload(tuple(args.scratch))})"
        )

    def snapshot(self, label: str) -> str:
        return (
            f"{label}|{self._runtime()}|foreign={self._world(foreign=True)}"
            f"|publisher=({self.namespace},1,publisher,[Cargo:write],0)"
            f"|fast=({self.namespace},1,2):({self.namespace},2,fast,[Cargo:read],0)"
            f"|slow=({self.namespace},2,3):({self.namespace},3,slow,[Cargo:read],0)"
            f"|fastArgs={self._show_args(self.fast_args)}"
            f"|slowArgs={self._show_args(self.slow_args)}"
        )

    def act(self, action: str) -> str:
        if action == "fast":
            return self._read(1, False, self.fast_args)
        if action == "slow":
            return self._read(2, False, self.slow_args)
        if action == "failed":
            return self._read(2, True, self.slow_args)
        if action == "slow-retry":
            return self._read(2, False, self.slow_args)
        if action in ("publish", "next", "abort"):
            seeds = {"publish": (10, 20), "next": (30,), "abort": (40, 50)}[action]
            self.tick += 1  # EventRuntime.with_world advances before Pub.run.
            if action == "abort":
                return "aborted:" + show_payloads(map(payload_pair, seeds)) + "\n"
            self._append_publication(seeds)
            return "committed:[]\n"
        if action == "frame":
            return self._frame()
        if action == "fast-after-frame":
            return self._read(1, False, self.fast_args)
        if action == "skip":
            self.positions = [
                Position(p.id, self.tick, p.registered_at) if p.id == 1 else p
                for p in self.positions
            ]
            return "skipped\n"
        if action == "foreign":
            return "refused:False:" + show_payloads([payload_pair(500)]) + "\n"
        if action == "drain":
            retired = list(self.rows)
            self.rows = []
            self.events = []
            self.batches = []
            return "retired:" + self._show_rows(retired) + "\n"
        raise AssertionError(f"unknown action: {action}")


def schema_trace(schema: str, namespace: int, foreign_namespace: int) -> str:
    host = Host(schema, namespace, foreign_namespace)
    # F.start registers publisher, then fast and slow. It leaves system IDs
    # 1/2/3, reader IDs 1/2, and nextReader=3 before the initial snapshot.
    output = host.snapshot("initial")
    for action in ACTIONS:
        output += host.act(action)
        output += host.snapshot("step")
    return output


def derive() -> bytes:
    next_namespace = 1  # Both pinned namespace sidecars start at 1 per process.
    sections = ["Workshop\n"]
    for schema in SCHEMAS:
        world_namespace = next_namespace
        foreign_namespace = next_namespace + 1
        next_namespace += 2
        sections.append(schema_trace(schema, world_namespace, foreign_namespace))
        if schema == "Workshop":
            # main.printed concatenates the Garden header directly to the final
            # Workshop snapshot; preserve that exact frozen-source composition.
            sections.append("Garden\n")
    # Pinned IO.print JS and C sidecars each append exactly one terminal LF.
    return ("".join(sections) + "\n").encode("utf-8")


def selftest(raw: bytes) -> None:
    text = raw.decode("utf-8")
    assert text.startswith("Workshop\ninitial|runtime(ns=1,")
    assert "Garden\ninitial|runtime(ns=3," in text
    assert text.endswith("\n") and not text.endswith("\n\n")
    assert text.count("initial|") == 2
    assert text.count("step|") == 30
    assert text.count("retired:1:N(L(10),L(11));2:N(L(20),L(21));[]\n") == 2
    assert text.count("aborted:N(L(40),L(41));N(L(50),L(51));[]\n") == 2
    assert text.count("refused:False:N(L(500),L(501));[]\n") == 2
    assert text.count("read:lagged=True\n") == 2
    assert text.count("Garden\n") == 1
    assert text.count("Workshop\n") == 1
    assert text.count("tick=8,frameStart=8,boundary=7,capacity=2,dropped=3") == 2
    assert text.count("tick=8,frameStart=8,boundary=8,capacity=2,dropped=3") == 8

    # The public Runtime.boundary is the old frameStart. The smaller
    # reader-limited cutoff is local to retention and must not overwrite it.
    sample = Host("Workshop", 1, 2)
    sample.tick = 8
    sample.frame_start = 7
    sample.positions = [Position(1, 8, 0), Position(2, 5, 1)]
    sample.batches = [Batch(5, (1,)), Batch(6, (2,)), Batch(7, (3,)), Batch(8, (4,))]
    sample.capacity = 10
    sample._frame()
    assert sample.frame_start == 8
    assert sample.boundary == 7
    assert [batch.tick for batch in sample.batches] == [6, 7, 8]
    assert sample.dropped == 5


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--selftest", action="store_true", help="verify the frozen raw/gzip outputs")
    args = parser.parse_args()
    raw = derive()
    selftest(raw)
    out = Path(__file__).parent
    compressed = gzip.compress(raw, compresslevel=9, mtime=0)
    metadata = {
        "bytes": len(raw),
        "gzipSha256": digest(compressed),
        "rawSha256": digest(raw),
        "snapshots": 32,
    }
    expected_path = out / "expected.stdout"
    compressed_path = out / "expected.stdout.gz"
    metadata_path = out / "EXPECTED.json"
    if args.selftest:
        assert expected_path.read_bytes() == raw
        retained_gzip = compressed_path.read_bytes()
        assert retained_gzip == compressed
        assert gzip.decompress(retained_gzip) == raw
        assert json.loads(metadata_path.read_text()) == metadata
        print(json.dumps({"selftest": "PASS", **metadata}, sort_keys=True))
        return
    expected_path.write_bytes(raw)
    compressed_path.write_bytes(compressed)
    metadata_path.write_text(json.dumps(metadata, indent=2, sort_keys=True) + "\n")
    print(json.dumps(metadata, sort_keys=True))


if __name__ == "__main__":
    main()
