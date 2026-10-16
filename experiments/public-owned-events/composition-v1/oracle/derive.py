#!/usr/bin/env python3
"""Source-derived complete stdout model for the frozen #53 composition trace.

This models the public consumer and observer from the pinned Bend source. It
does not invoke Bend, JS, Native, a generated program, or a runtime receipt.
"""
from __future__ import annotations

from dataclasses import dataclass, field
import argparse
import gzip
import hashlib
import json
from pathlib import Path


ACCESS = ("Value", "Counter", "Cargo:write")
SCENARIOS = (("Workshop", 1, 2), ("Garden", 3, 4))
LIVE_PRIMARY = "N(N(L(False),L(True)),N(L(True),L(True)))"
LIVE_FOREIGN = "L(False)"


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def show_list(values, render=str) -> str:
    return "[" + ", ".join(render(value) for value in values) + "]"


def show_bool(value: bool) -> str:
    return "True" if value else "False"


def show_payload(value: tuple[int, int]) -> str:
    first, second = value
    return f"N(L({first}),L({second}))"


def show_payloads(values) -> str:
    # The imported ordinary-v1 payload observer uses a recursive [] base and
    # semicolon join, rather than Base.List.show, for this public view.
    rendered = [show_payload(value) for value in values]
    return "[]" if not rendered else ";".join(rendered) + ";[]"


def show_log_rows(rows: list[tuple[int, tuple[int, int]]]) -> str:
    if not rows:
        return "[]"
    return ";".join(f"{ident}:{show_payload(payload)}" for ident, payload in rows) + ";[]"


@dataclass
class World:
    namespace: int
    primary: bool
    values: dict[int, int | None] = field(default_factory=dict)
    stamps: dict[int, tuple[int, int]] = field(default_factory=dict)
    counter: int = 100
    log_next: int = 1
    log_rows: list[tuple[int, tuple[int, int]]] = field(default_factory=list)
    events: list[int] = field(default_factory=list)
    clock: int = 0
    cursor: int = 0

    @classmethod
    def initialized(cls, namespace: int) -> "World":
        # Three successful reserve/activate pairs grow live from size 1 to 4.
        # The two initial component replacements consume clocks 1 and 2.
        return cls(
            namespace=namespace,
            primary=True,
            values={1: 10, 2: 20},
            stamps={1: (1, 1), 2: (2, 2)},
            clock=2,
        )

    @classmethod
    def empty_foreign(cls, namespace: int) -> "World":
        return cls(namespace=namespace, primary=False)

    def component_rows(self) -> str:
        parts = []
        for ident in (1, 2, 3, 4):
            value = self.values.get(ident)
            shown = "None" if value is None else f"Some({value})"
            added, changed = self.stamps.get(ident, (0, 0))
            parts.append(f"row{ident}={shown}@({added},{changed})")
        # composition-v1/observe.bend's rows_join appends a semicolon at each
        # recursive step, including after the last row.
        return ";".join(parts) + ";"

    def render(self) -> str:
        next_id = 4 if self.primary else 1
        high = 3 if self.primary else 0
        capacity = 4 if self.primary else 1
        depth = 2 if self.primary else 0
        live = LIVE_PRIMARY if self.primary else LIVE_FOREIGN
        regs = [f"(1,query-publisher,{show_list(ACCESS)})"] if self.primary else []
        sid = 2 if self.primary else 1
        return (
            f"world(ns={self.namespace},next={next_id},high={high},live={live},"
            f"capacity={capacity},depth={depth},column={{{self.component_rows()}}},"
            f"counter={self.counter},log(next={self.log_next},rows={show_log_rows(self.log_rows)}),"
            f"events={show_list(self.events)},pending=0,regs={show_list(regs)},"
            f"sid={sid},clock={self.clock})"
        )


@dataclass
class Host:
    world: World
    foreign: World
    cursor: int = 0

    @classmethod
    def initialized(cls, namespace: int, foreign_namespace: int) -> "Host":
        return cls(World.initialized(namespace), World.empty_foreign(foreign_namespace))

    def snapshot(self) -> str:
        registry = (
            f"registry(ns={self.world.namespace},id=1,name=query-publisher,"
            f"access={show_list(ACCESS)},cursor={self.cursor})"
        )
        return f"world:{self.world.render()}registry:{registry}foreign:{self.foreign.render()}"

    def call(self, delta: int, fail_value: int) -> str:
        world = self.world
        if world.namespace != self.world.namespace:
            raise AssertionError("ordinary call unexpectedly changed namespace")

        old_values = dict(world.values)
        old_stamps = dict(world.stamps)
        old_counter = world.counter
        captured: list[tuple[int, int]] = []
        output: list[int] = []
        failed_at: int | None = None

        # W.handles snapshots ascending live IDs. Required Value selection
        # skips the live entity 3, which has no Value owner.
        for ident in (1, 2, 3):
            old = world.values.get(ident)
            if old is None:
                continue
            world.clock += 1
            world.values[ident] = old + delta
            added, _ = world.stamps[ident]
            world.stamps[ident] = (added, world.clock)
            world.counter += 1
            captured.append((old, delta))
            if old == fail_value:
                failed_at = old
                break
            output.append(old)

        if failed_at is not None:
            # T.finish restores resource and component owners/stamps but keeps
            # the monotonic World clock. Staged payloads are returned in row
            # order and are never appended to Log or World.events.
            world.values = old_values
            world.stamps = old_stamps
            world.counter = old_counter
            output = []
            outcome = f"failed-at={failed_at}"
            recovered = captured
        else:
            for payload in captured:
                ident = world.log_next
                world.log_next += 1
                world.log_rows.append((ident, payload))
                world.events.append(ident)
            self.cursor = world.clock
            outcome = "success"
            recovered = []

        return (
            f"{outcome}:values={show_list(output)}:"
            f"recovered={show_payloads(recovered)}\n"
        )

    def foreign_call(self) -> str:
        # Sys.run rejects the primary system registration against the actual
        # WorldIO-created foreign namespace before invoking the runner.
        return f"refused:99:0:{self.cursor}\n"


def schema_trace(namespace: int, foreign_namespace: int) -> str:
    host = Host.initialized(namespace, foreign_namespace)
    text = host.snapshot()
    for operation in ((1, 0), (10, 21), (2, 0)):
        text += host.call(*operation)
        text += host.snapshot()
    text += host.foreign_call()
    text += host.snapshot()
    return text


def derive() -> bytes:
    pieces = ["Workshop\n"]
    for index, (_schema, namespace, foreign_namespace) in enumerate(SCENARIOS):
        pieces.append(schema_trace(namespace, foreign_namespace))
        if index == 0:
            # main.bend concatenates Garden immediately after Workshop's last
            # snapshot; IO.print contributes the single final LF below.
            pieces.append("Garden\n")
    return ("".join(pieces) + "\n").encode("utf-8")


def check_source_basis(source_root: Path, basis_path: Path) -> None:
    basis = json.loads(basis_path.read_text(encoding="utf-8"))
    root = source_root.resolve()
    freeze_path = root / basis["producer"]["sourceFreezePath"]
    freeze = freeze_path.read_bytes()
    assert sha256(freeze) == basis["producer"]["sourceFreezeSha256"]
    assert json.loads(freeze)["sourcePins"] == basis["producer"]["absoluteSourcePins"]
    for relative, expected in basis["producer"]["sourceFiles"].items():
        actual = sha256((root / relative).read_bytes())
        assert actual == expected, f"source pin mismatch: {relative}"

    for name, pin in basis["runtimeBasis"].items():
        actual = sha256(Path(pin["path"]).read_bytes())
        assert actual == pin["sha256"], f"runtime basis mismatch: {name}"


def selftest(raw: bytes) -> None:
    text = raw.decode("utf-8")
    assert text.startswith("Workshop\nworld:world(ns=1,")
    assert "Garden\nworld:world(ns=3," in text
    assert text.count("world:world(ns=") == 10
    assert text.count("foreign:world(ns=") == 10
    assert text.count("success:values=[10, 20]:recovered=[]\n") == 2
    assert text.count("failed-at=21:values=[]:recovered=N(L(11),L(10));N(L(21),L(10));[]\n") == 2
    assert text.count("success:values=[11, 21]:recovered=[]\n") == 2
    assert text.count("refused:99:0:8\n") == 2
    assert text.count("counter=100,log(next=1,rows=[])") >= 10
    assert "clock=6)registry:registry(ns=1,id=1,name=query-publisher,access=[Value, Counter, Cargo:write],cursor=4)" in text
    assert text.count("events=[1, 2, 3, 4]") == 4
    assert text.endswith("\n") and not text.endswith("\n\n")
    assert text.count("Garden\n") == 1

    # Check model transition facts independently of serialized byte checks.
    first = Host.initialized(1, 2)
    assert "clock=2" in first.snapshot()
    assert first.call(1, 0).startswith("success:values=[10, 20]")
    assert (first.world.clock, first.world.counter, first.cursor) == (4, 102, 4)
    failed = first.call(10, 21)
    assert failed == "failed-at=21:values=[]:recovered=N(L(11),L(10));N(L(21),L(10));[]\n"
    assert (first.world.clock, first.world.counter, first.cursor) == (6, 102, 4)
    assert first.world.values == {1: 11, 2: 21}
    assert first.world.stamps == {1: (1, 3), 2: (2, 4)}
    assert first.world.events == [1, 2]
    assert first.world.log_next == 3
    assert [row_id for row_id, _ in first.world.log_rows] == [1, 2]
    assert first.call(2, 0).startswith("success:values=[11, 21]")
    assert (first.world.clock, first.world.counter, first.cursor) == (8, 104, 8)
    assert first.world.events == [1, 2, 3, 4]
    assert first.world.log_next == 5
    before_primary = first.world.render()
    before_foreign = first.foreign.render()
    assert first.foreign_call() == "refused:99:0:8\n"
    assert first.world.render() == before_primary
    assert first.foreign.render() == before_foreign


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
        "snapshots": 10,
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
    metadata_path.write_text(json.dumps(metadata, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps(metadata, sort_keys=True))


if __name__ == "__main__":
    main()
