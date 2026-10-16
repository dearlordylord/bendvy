#!/usr/bin/env python3
"""Source-derived #55 physical lifecycle report model; never runs Bend."""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
from pathlib import Path
import sys


HERE = Path(__file__).resolve().parent
FIXTURE_COMMIT = "cbde916f450209d9e2c0565a6ec76b254572a818"
FIXTURE_LEAF = Path(
    "experiments/public-inspect/graph-stream-public-bridge-v1/"
    "feature-timing-v1/current-source-v1"
)
OLD_LEAF = Path(
    "experiments/public-inspect/graph-stream-public-bridge-v1/feature-timing-v1"
)
LOGICAL_LEAF = OLD_LEAF / "independent-oracle-v1"
LOGICAL_FILE = "expected-scale-1.stdout"
LOGICAL_SHA256 = "21111a66fe196fc3c9615eadc8a39648c3583a695b233fd3d78eda355693cd60"
LOGICAL_MODEL_SHA256 = "629111e7550d2f8a744b913594a52827c715575ce293f0f1cdec5490ab240b62"
LOGICAL_NOTES_SHA256 = "dcb7dd7898a27de1d73b99245b2ace74bce63510ab3d302bc5ef9d12448191d5"
PREDECESSOR_BYTES = 237711
PREDECESSOR_SHA256 = "e5c0f46f05fdaff62676c09dd89376e9a7ee67e58ef1e3a8159ad2edd9b0c1ee"
FREEZE_SHA256 = "b67b93e380cd65b35d8b1b6b56470077ede6182f39ea321e127c3eaf21ec294c"
JOIN_SHA256 = "f1e5d6cf64085d5caa61dfc2b31ec5778806e0bf9db3af01b54da1e208c85a17"
BASE_PATH = Path("/home/node/.bend/bend2/base.bend")
BASE_SHA256 = "c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661"


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def compact(value: object) -> str:
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


def tree(values: list[str]) -> str:
    if not values:
        raise ValueError("source fixture arrays are nonempty")
    if len(values) == 1:
        return f"L({values[0]})"
    if len(values) & (len(values) - 1):
        raise ValueError("source fixture array tree must have power-of-two size")
    middle = len(values) // 2
    return f"N({tree(values[:middle])},{tree(values[middle:])})"


def list_text(values: list[str]) -> str:
    return "[" + ",".join(values) + "]"


def base_list_show(values: list[str]) -> str:
    # Base.List.show emits comma-space separators; the fixture's custom
    # u32_list renderer above intentionally emits comma only.
    return "[" + ", ".join(values) + "]"


def u32_list(values: list[int]) -> str:
    return list_text([str(value) for value in values])


def component_text() -> str:
    # Base.Array.new(T, 4n, []) creates two vectors of T^3: eight leaves
    # per child and sixteen leaves total. Setup writes ids 1..3 at indexes
    # 0..2; all remaining leaves retain the empty list.
    cells = tree([u32_list([11, 12]), u32_list([21, 22]), u32_list([31, 32]), *(["[]"] * 13)])
    sibling = tree([u32_list([13, 14]), u32_list([23, 24]), u32_list([33, 34]), *(["[]"] * 13)])
    return cells + ";sibling=" + sibling


def graph_text() -> str:
    # setup.bend stages Link(1,2), Link(3,2), Parent(1,2), Parent(3,2).
    # Tx.finish reverses its reverse-accumulated command list once, preserving
    # that order; relation-graph appends successful edges and inverse sources.
    edges = [
        "1:Link:LinkedBy:ordinary:1>2",
        "1:Link:LinkedBy:ordinary:3>2",
        "2:Parent:Children:hierarchy:1>2",
        "2:Parent:Children:hierarchy:3>2",
    ]
    inverses = [
        "1:Link:LinkedBy:ordinary:2:[1, 3]",
        "2:Parent:Children:hierarchy:2:[1, 3]",
    ]
    return base_list_show(edges) + ";" + base_list_show(inverses)


def event_texts() -> list[str]:
    failure = (
        "relationFailed:2:Parent:Children:hierarchy:relate:2:3:"
        "hierarchyCycle:2:3:Parent"
    )
    return ["user:31", "user:32", failure]


def registration_meta(reg_id: int, name: str, access: list[str]) -> str:
    return f"{reg_id}:{name}:{base_list_show(access)}"


def base_registrations() -> list[tuple[int, str, list[str]]]:
    return [(1, "Reader", ["FlowStream", "LevelStream", "ParentFailures"])]


def registry_text(reg_id: int, name: str, access: list[str], cursor: int) -> str:
    return f"Registry(1,{reg_id},{name},{base_list_show(access)},{cursor})"


def stream_text(position: int) -> str:
    return f"stream({base_list_show(['4:[4>7]'])},{base_list_show([f'1:{position}:3'])},0,0)"


def level_stream_text(position: int) -> str:
    return f"stream({base_list_show(['4:[10>11]'])},{base_list_show([f'1:{position}:3'])},0,0)"


def resources_text(position: int) -> str:
    owned = tree(["11", "12"])
    sibling = tree(["21", "22"])
    return (
        owned
        + ";sibling="
        + sibling
        + ";slot(7,next(9,False),4,True)"
        + ";slot(11,next(12,True),10,True)"
        + ";ran=0;"
        + stream_text(position)
        + ";"
        + level_stream_text(position)
    )


def dump_world(clock: int, registrations: list[tuple[int, str, list[str]]], next_system: int, machine_pos: int) -> str:
    live = tree(["False", "True", "True", "True", "False", "False", "False", "False"])
    store = component_text() + ";graph=" + graph_text()
    events = base_list_show(event_texts())
    regs = base_list_show([registration_meta(i, name, access) for i, name, access in registrations])
    return (
        f"world(1,5,4,{live},8,3,{store},{resources_text(machine_pos)},"
        f"events={events},pending=1,regs={regs},nextSystem={next_system},clock={clock})"
    )


def warm_stream_value() -> dict[str, object]:
    return {
        "flow": 4,
        "level": 10,
        "flowTransitions": [],
        "levelTransitions": [],
        "flowLagged": False,
        "levelLagged": False,
        "parentFailures": [],
        "parentLagged": False,
    }


def event_runtime_text(event_tick: int, position_cursor: int, world_clock: int, machine_pos: int,
                       registrations: list[tuple[int, str, list[str]]],
                       next_system: int) -> str:
    failure = (
        "relationFailed:2:Parent:Children:hierarchy:relate:2:3:"
        "hierarchyCycle:2:3:Parent"
    )
    batches = base_list_show([
        "1:" + base_list_show(["user:31", "user:32"]),
        "2:" + base_list_show([failure]),
    ])
    return (
        "EventRuntime(namespace=1,"
        + dump_world(world_clock, registrations, next_system, machine_pos)
        + f",batches={batches},positions=[1:{position_cursor}:0],"
        + f"nextReader=2,tick={event_tick},frameStart=0,boundary=0,capacity=65536,dropped=0)"
    )


def owner_text(event_tick: int, world_clock: int, machine_pos: int,
               registrations: list[tuple[int, str, list[str]]],
               next_system: int) -> dict[str, object]:
    position_cursor = event_tick if event_tick == 4 else 1
    return {
        "runtime": event_runtime_text(event_tick, position_cursor, world_clock, machine_pos,
                                      registrations, next_system),
        "reader": "1:1:1",
        "registry": "Registry(1,1,Reader,[FlowStream, LevelStream, ParentFailures],0)",
        "warmResult": warm_stream_value(),
    }


def physical_entries(records: list[dict[str, object]]) -> list[dict[str, object]]:
    result: list[dict[str, object]] = []
    current_schema: str | None = None
    registrations = base_registrations()
    next_system = 2
    world_clock = 6
    event_tick = 2  # warm Ev.run tick1, then the category map_world tick2

    for record in records:
        schema = str(record["schema"])
        if schema != current_schema:
            current_schema = schema
            registrations = base_registrations()
            next_system = 2
            world_clock = 6
            event_tick = 2
        operation = str(record["operation"])
        if operation in ("inspect", "check-noop"):
            if operation == "inspect":
                before = world_clock
                world_clock += 1
                instance = f"Active({world_clock},{before})"
                result.append({
                    "instance": instance,
                    "world": dump_world(world_clock, registrations, next_system, 3),
                })
            else:
                relation = str(record["relation"])
                mode = str(record["mode"])
                pass_name = str(record["pass"])
                name = f"{schema}/{relation}/{mode}/{pass_name}/Noop"
                reg_id = next_system
                next_system += 1
                registrations.insert(0, (reg_id, name, []))
                instance = registry_text(reg_id, name, [], world_clock)
                result.append({
                    "instance": instance,
                    "world": dump_world(world_clock, registrations, next_system, 3),
                })
            continue

        if operation == "machine-inspect":
            before = world_clock
            world_clock += 1
            result.append({
                "instance": f"Active({world_clock},{before})",
                "owner": owner_text(event_tick, world_clock, 3, registrations, next_system),
            })
            continue

        if operation == "machine-check-noop":
            event_tick += 1  # Read.map_world wraps this one condition callback.
            name = f"{schema}/FlowAndLinkNoop"
            reg_id = next_system
            next_system += 1
            registrations.insert(0, (reg_id, name, []))
            result.append({
                "instance": registry_text(reg_id, name, [], world_clock),
                "owner": owner_text(event_tick, world_clock, 3, registrations, next_system),
            })
            continue

        if operation == "registered-stream-read":
            # Ev.run starts at tick3, passes 4 through the run, and syncs its
            # one registered event cursor to4. Sys.run is untracked, so its
            # system Registry cursor remains0.
            event_tick += 1
            result.append({
                "instance": "ReturnedRegisteredReader",
                "owner": owner_text(event_tick, world_clock, 40, registrations, next_system),
            })
            continue

        raise AssertionError(f"unexpected operation: {operation}")

    if len(result) != 136:
        raise AssertionError(f"expected 136 physical observations, got {len(result)}")
    if world_clock != 40 or next_system != 35 or event_tick != 4:
        raise AssertionError((world_clock, next_system, event_tick))
    return result


def fixture_source_root(args: argparse.Namespace) -> Path:
    return Path(args.source_root).resolve()


def validate_sources(repo_root: Path) -> dict[str, object]:
    freeze_path = repo_root / FIXTURE_LEAF / "SOURCE-FREEZE.json"
    join_path = repo_root / FIXTURE_LEAF / "SOURCE-JOIN.json"
    freeze_bytes = freeze_path.read_bytes()
    join_bytes = join_path.read_bytes()
    if sha256(freeze_bytes) != FREEZE_SHA256:
        raise AssertionError("current fixture source freeze bytes changed")
    if sha256(join_bytes) != JOIN_SHA256:
        raise AssertionError("current fixture source join bytes changed")
    freeze = json.loads(freeze_bytes)
    inventory = freeze["sourceInventory"]
    if len(inventory) != 92:
        raise AssertionError(f"expected 92 source bodies, got {len(inventory)}")
    for rel, expected in inventory.items():
        actual = sha256((repo_root / rel).read_bytes())
        if actual != expected:
            raise AssertionError(f"fixture source changed: {rel}")

    join = json.loads(join_bytes)
    changes = join["files"]
    if len(changes) != 15 or sum(bool(item["importOnly"]) for item in changes) != 13:
        raise AssertionError("unexpected fixture source bridge shape")
    if set(join["bodyChanges"]) != {"dump.bend", "union.bend"}:
        raise AssertionError("unexpected semantic body deltas")
    base_bytes = BASE_PATH.read_bytes()
    if sha256(base_bytes) != BASE_SHA256:
        raise AssertionError("pinned Base source changed")
    return {
        "freezeSHA256": sha256(freeze_bytes),
        "joinSHA256": sha256(join_bytes),
        "sourceBodies": len(inventory),
        "fixtureCommit": FIXTURE_COMMIT,
        "runtimeBase": {
            "path": str(BASE_PATH),
            "sha256": sha256(base_bytes),
            "relevantDefinitions": {
                "Bool.show": "base.bend:2208-2213",
                "List.show": "base.bend:2226-2240",
                "Array.shape": "base.bend:70-73",
                "Array.size": "base.bend:2245-2255",
                "Array.new": "base.bend:2369-2374",
            },
        },
    }


def logical_records(logical_path: Path) -> tuple[bytes, list[dict[str, object]]]:
    raw = logical_path.read_bytes()
    if sha256(raw) != LOGICAL_SHA256:
        raise AssertionError("pinned logical lifecycle artifact changed")
    if not raw.endswith(b"\n"):
        raise AssertionError("logical source oracle must include one terminal LF")
    wrapped = json.loads(raw)
    if len(wrapped) != 1 or len(wrapped[0]) != 136:
        raise AssertionError("pinned logical source model is not one complete 136-record lifecycle")
    records = wrapped[0]
    if records[0]["schema"] != "Workshop" or records[67]["schema"] != "Workshop":
        raise AssertionError("Workshop source record span changed")
    if records[68]["schema"] != "Garden" or records[-1]["schema"] != "Garden":
        raise AssertionError("Garden source record span changed")
    inner = raw[:-1][1:-1]
    if json.loads(inner) != records:
        raise AssertionError("failed to isolate the lifecycle array from the scale wrapper")
    return inner, records


def output_bytes(records_raw: bytes, records: list[dict[str, object]]) -> bytes:
    physical = physical_entries(records)
    rendered = compact(physical).encode("utf-8")
    return b'{"records":' + records_raw + b',"physical":' + rendered + b"}\n"


def deterministic_gzip(data: bytes) -> bytes:
    import io

    buffer = io.BytesIO()
    with gzip.GzipFile(fileobj=buffer, mode="wb", filename="", mtime=0) as stream:
        stream.write(data)
    return buffer.getvalue()


def write_basis(output: bytes, logical_raw: bytes, source_facts: dict[str, object]) -> None:
    derivation = HERE / "DERIVATION.md"
    predecessor = LOGICAL_LEAF.parent / "current-source-v1" / "independent-oracle-v1" / "expected.stdout"
    predecessor_raw = predecessor.read_bytes()
    if len(predecessor_raw) != PREDECESSOR_BYTES or sha256(predecessor_raw) != PREDECESSOR_SHA256:
        raise AssertionError("historical physical oracle v1 changed")
    basis = {
        "fixture": source_facts,
        "predecessor": {
            "path": str((FIXTURE_LEAF / "independent-oracle-v1" / "expected.stdout").as_posix()),
            "bytes": len(predecessor_raw),
            "sha256": sha256(predecessor_raw),
            "status": "preserved source-history; not overwritten by this Base-rendering correction",
        },
        "logicalReuse": {
            "path": str((LOGICAL_LEAF / LOGICAL_FILE).as_posix()),
            "sha256": sha256(logical_raw),
            "bytes": len(logical_raw),
            "modelPath": str((LOGICAL_LEAF / "model.py").as_posix()),
            "modelSHA256": LOGICAL_MODEL_SHA256,
            "notesPath": str((LOGICAL_LEAF / "MODEL-NOTES.md").as_posix()),
            "notesSHA256": LOGICAL_NOTES_SHA256,
            "scope": "records only; physical owner projection independently derived here",
        },
        "output": {
            "path": "expected.stdout",
            "bytes": len(output),
            "sha256": sha256(output),
            "gzipPath": "expected.stdout.gz",
            "gzipSHA256": sha256(deterministic_gzip(output)),
        },
        "derivation": {"path": "DERIVATION.md", "sha256": sha256(derivation.read_bytes())},
        "runtimeOutputAudit": {
            "consultedAfterModelGeneration": True,
            "role": "post-generation mismatch locator and full-byte/per-record equality audit; every correction is justified by pinned source definitions, not copied as model data",
            "path": "/tmp/bendvy55-current-physical-actual01/js/consumer.stdout",
            "bytes": 271299,
            "sha256": "83c78b0e9a8944516ca101b604468cee3af05a9509af0b64bc37bed8ac982b8a",
            "planPath": "/tmp/bendvy55-current-physical-actual01/js/plan.json",
            "planSHA256": "7a1f6de7d2a547085ca7fb85c043d3b64e57210e9af7312f5b4c57dac55afcdc",
            "receiptPath": "/tmp/bendvy55-current-physical-actual01/js/receipt.json",
            "receiptSHA256": "50fb5d405fc1129ac9ab19f3f9e55418d9bae325c61399508421a6ac6c6aaba7",
            "exactBytesAnd136PhysicalEntries": True,
        },
    }
    (HERE / "SOURCE-BASIS.json").write_text(json.dumps(basis, indent=2) + "\n", encoding="utf-8")


def check_selftest(output: bytes, records: list[dict[str, object]]) -> None:
    physical = json.loads(output)
    if list(physical) != ["records", "physical"]:
        raise AssertionError("report field order changed")
    if len(physical["records"]) != 136 or len(physical["physical"]) != 136:
        raise AssertionError("report does not contain 136 complete records/physical observations")
    if physical["records"] != records:
        raise AssertionError("physical report changed the logical lifecycle")
    if base_list_show(["a", "b"]) != "[a, b]" or list_text(["a", "b"]) != "[a,b]":
        raise AssertionError("Base List.show and fixture u32-list renderers must remain distinct")
    if component_text().count("L(") != 32:
        raise AssertionError("two Array.new(4n) components must retain sixteen leaves each")
    expected_live = tree(["False", "True", "True", "True", "False", "False", "False", "False"])
    if f"world(1,5,4,{expected_live},8,3," not in physical["physical"][0]["world"]:
        raise AssertionError("World growth/activation must retain its source-derived eight live leaves")
    schemas = [r["schema"] for r in physical["records"]]
    if schemas != ["Workshop"] * 68 + ["Garden"] * 68:
        raise AssertionError("schema order/count changed")
    # Independent invariants for the two clock domains and retained owners.
    p = physical["physical"]
    category_inspects = [x for x, rec in zip(p, records) if rec["operation"] == "inspect"]
    if len(category_inspects) != 64:
        raise AssertionError("expected 64 category fresh inspectors")
    if p[0]["instance"] != "Active(7,6)" or p[1]["instance"] != "Active(8,7)":
        raise AssertionError("first two category clock/instance pairs changed")
    expected_category_instances = [f"Active({clock},{clock - 1})" for clock in range(7, 39)]
    for start in (0, 68):
        actual_category_instances = [
            observation["instance"]
            for observation, record in zip(p[start:start + 64], records[start:start + 64])
            if record["operation"] == "inspect"
        ]
        if actual_category_instances != expected_category_instances:
            raise AssertionError("category inspection clocks must advance exactly once in source order")
    if 'nextSystem=3,clock=8)' not in p[2]["world"]:
        raise AssertionError("first category check must register system 2 at World clock8")
    if 'nextSystem=4,clock=8)' not in p[3]["world"]:
        raise AssertionError("second category check must register system 3 without advancing World clock")
    machine_records = [rec for rec in records if rec["operation"].startswith("machine-") or rec["operation"] == "registered-stream-read"]
    if len(machine_records) != 8:
        raise AssertionError("expected four machine records per schema")
    if sum(1 for x in p if x.get("instance") == "ReturnedRegisteredReader") != 2:
        raise AssertionError("expected one registered read per schema")
    final_owner = p[-1]["owner"]
    if 'positions=[1:4:0]' not in final_owner["runtime"] or "tick=4," not in final_owner["runtime"]:
        raise AssertionError("event runtime cursor/tick did not retain the source-derived successful run")
    if "clock=40)" not in final_owner["runtime"] or "[1:40:3]" not in final_owner["runtime"]:
        raise AssertionError("World clock or machine reader position changed")
    if final_owner["registry"] != "Registry(1,1,Reader,[FlowStream, LevelStream, ParentFailures],0)":
        raise AssertionError("untracked event reader must preserve Registry cursor0")
    if 'nextSystem=35,clock=40)' not in final_owner["runtime"]:
        raise AssertionError("final system-id/World clock state changed")
    if p[64]["instance"] != "Active(39,38)" or p[65]["instance"] != "Active(40,39)":
        raise AssertionError("two fresh Union inspections must each advance World once")
    if "positions=[1:1:0]" not in p[64]["owner"]["runtime"] or "tick=2," not in p[64]["owner"]["runtime"]:
        raise AssertionError("machine inspection must preserve event cursor1 at runtime tick2")
    if "positions=[1:1:0]" not in p[66]["owner"]["runtime"] or "tick=3," not in p[66]["owner"]["runtime"]:
        raise AssertionError("condition map must advance only the event tick before stream read")
    if "[1:40:3]" not in p[67]["owner"]["runtime"]:
        raise AssertionError("successful stream read must commit its machine cursor at World clock40")
    if "[4:[4>7]]" not in p[64]["owner"]["runtime"] or "[4:[10>11]]" not in p[64]["owner"]["runtime"]:
        raise AssertionError("machine queues must retain the setup transitions at tick4")
    expected_events = (
        "batches=[1:[user:31, user:32], 2:[relationFailed:2:Parent:Children:hierarchy:"
        "relate:2:3:hierarchyCycle:2:3:Parent]]"
    )
    if expected_events not in p[64]["owner"]["runtime"]:
        raise AssertionError("warm notices and later cycle failure must remain in separate event batches")
    if 'events=[user:31, user:32, relationFailed:2:Parent:Children:hierarchy:relate:2:3:hierarchyCycle:2:3:Parent]' not in p[0]["world"]:
        raise AssertionError("category World snapshot must retain the full World event log")
    if "pending=1" not in p[0]["world"] or "nextSystem=2,clock=7)" not in p[0]["world"]:
        raise AssertionError("initial category snapshot must preserve pending command and system allocation")
    if "graph=[1:Link:LinkedBy:ordinary:1>2, 1:Link:LinkedBy:ordinary:3>2, 2:Parent:Children:hierarchy:1>2, 2:Parent:Children:hierarchy:3>2]" not in p[0]["world"]:
        raise AssertionError("category snapshot must retain all accepted relation edges in setup order")
    if "slot(7,next(9,False),4,True)" not in p[0]["world"] or "slot(11,next(12,True),10,True)" not in p[0]["world"]:
        raise AssertionError("category snapshot must retain queued machine state and previous values")
    for group_start in (0, 68):
        group = p[group_start:group_start + 68]
        group_schema = records[group_start]["schema"]
        if any(record["schema"] != group_schema for record in records[group_start:group_start + 68]):
            raise AssertionError("schema physical lifecycle blocks must be independent and contiguous")
        if group[64]["instance"] != "Active(39,38)" or group[65]["instance"] != "Active(40,39)":
            raise AssertionError("each nominal schema starts a fresh World clock")
        if "nextSystem=35,clock=40)" not in group[67]["owner"]["runtime"]:
            raise AssertionError("each schema ends with the same independently scoped registration state")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=("write", "check", "selftest"), nargs="?", default="check")
    parser.add_argument(
        "--source-root",
        default="/workspace/formal-proofs/bendvy-worktrees/inspect55-current-lifecycle",
    )
    parser.add_argument(
        "--logical-oracle",
        default=str(HERE.parent.parent / "independent-oracle-v1" / LOGICAL_FILE),
    )
    args = parser.parse_args()

    try:
        source_facts = validate_sources(fixture_source_root(args))
        logical_path = Path(args.logical_oracle).resolve()
        records_raw, records = logical_records(logical_path)
        logical_model = logical_path.parent / "model.py"
        logical_notes = logical_path.parent / "MODEL-NOTES.md"
        if sha256(logical_model.read_bytes()) != LOGICAL_MODEL_SHA256:
            raise AssertionError("pinned logical source model changed")
        if sha256(logical_notes.read_bytes()) != LOGICAL_NOTES_SHA256:
            raise AssertionError("pinned logical model notes changed")
        output = output_bytes(records_raw, records)
        check_selftest(output, records)
        gz = deterministic_gzip(output)
        if args.mode == "write":
            (HERE / "expected.stdout").write_bytes(output)
            (HERE / "expected.stdout.gz").write_bytes(gz)
            write_basis(output, logical_path.read_bytes(), source_facts)
        else:
            expected = (HERE / "expected.stdout").read_bytes()
            expected_gz = (HERE / "expected.stdout.gz").read_bytes()
            if expected != output or expected_gz != gz:
                raise AssertionError("retained oracle differs from current source-derived model")
            basis = json.loads((HERE / "SOURCE-BASIS.json").read_text(encoding="utf-8"))
            if basis["output"]["sha256"] != sha256(output):
                raise AssertionError("source-basis output hash mismatch")
            if basis["output"]["gzipSHA256"] != sha256(gz):
                raise AssertionError("source-basis compressed output hash mismatch")
            if basis["fixture"] != source_facts:
                raise AssertionError("source-basis fixture binding mismatch")
            predecessor = LOGICAL_LEAF.parent / "current-source-v1" / "independent-oracle-v1" / "expected.stdout"
            predecessor_raw = predecessor.read_bytes()
            expected_predecessor = {
                "path": str((FIXTURE_LEAF / "independent-oracle-v1" / "expected.stdout").as_posix()),
                "bytes": len(predecessor_raw),
                "sha256": sha256(predecessor_raw),
                "status": "preserved source-history; not overwritten by this Base-rendering correction",
            }
            if expected_predecessor["bytes"] != PREDECESSOR_BYTES or expected_predecessor["sha256"] != PREDECESSOR_SHA256:
                raise AssertionError("historical physical oracle v1 changed")
            if basis["predecessor"] != expected_predecessor:
                raise AssertionError("source-basis predecessor binding mismatch")
            expected_logical = {
                "path": str((LOGICAL_LEAF / LOGICAL_FILE).as_posix()),
                "sha256": sha256(logical_path.read_bytes()),
                "bytes": len(logical_path.read_bytes()),
                "modelPath": str((LOGICAL_LEAF / "model.py").as_posix()),
                "modelSHA256": LOGICAL_MODEL_SHA256,
                "notesPath": str((LOGICAL_LEAF / "MODEL-NOTES.md").as_posix()),
                "notesSHA256": LOGICAL_NOTES_SHA256,
                "scope": "records only; physical owner projection independently derived here",
            }
            if basis["logicalReuse"] != expected_logical:
                raise AssertionError("source-basis logical-source binding mismatch")
            derivation_path = HERE / "DERIVATION.md"
            if basis["derivation"] != {"path": "DERIVATION.md", "sha256": sha256(derivation_path.read_bytes())}:
                raise AssertionError("source-basis derivation binding mismatch")
        print(json.dumps({"mode": args.mode, "records": 136, "bytes": len(output), "sha256": sha256(output), "sourceBodies": source_facts["sourceBodies"]}, sort_keys=True))
        return 0
    except Exception as error:  # offline evidence check, with a concise failure record
        print(f"independent physical oracle {args.mode} failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
