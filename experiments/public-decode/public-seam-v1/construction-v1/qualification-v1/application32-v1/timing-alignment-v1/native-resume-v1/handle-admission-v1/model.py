#!/usr/bin/env python3
"""Independent source-derived expected stdout for handle-admission-v1.

This models the current typed consumer and ECS transition functions directly.
It intentionally has no runtime-output input.
"""

from __future__ import annotations

import gzip
import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parent


def raw_payload(name: str, cells: tuple[int, ...], target: str | None) -> str:
    raw_target = "null" if target is None else "handle:" + target
    raw_cells = ",".join(f"u32:{value}" for value in cells)
    return f"{{cells:[{raw_cells}],name:str:{name},target:{raw_target}}}"


def payload(name: str, cells: tuple[int, ...], target: str | None) -> str:
    values = "".join(f"{value}," for value in cells)
    target_text = "null" if target is None else target
    return f"{name}:{values}:{target_text}"


SEED_FIRST = payload("seed", (11, 12), "1:1")
SEED_SECOND = payload("seed", (21, 22), "2:1")
RESOURCE_FIRST = payload("resource", (100, 101), None)
RESOURCE_SECOND = payload("foreignresource", (300, 301), None)
INCOMING_OWN = payload("incoming", (41, 42, 43, 44), "1:1")
INCOMING_FOREIGN = payload("incoming", (41, 42, 43, 44), "2:1")
INCOMING_ZERO = payload("incoming", (41, 42, 43, 44), "1:0")
INCOMING_NULL = payload("incoming", (41, 42, 43, 44), None)

RAW_OWN = raw_payload("incoming", (41, 42, 43, 44), "1:1")
RAW_NULL = raw_payload("incoming", (41, 42, 43, 44), None)


def bool_array(text: str) -> str:
    return text


def row(index: int, value: str | None, added: int, changed: int) -> str:
    if value is None:
        raw = "none"
    elif value == SEED_FIRST:
        raw = raw_payload("seed", (11, 12), "1:1")
    elif value == SEED_SECOND:
        raw = raw_payload("seed", (21, 22), "2:1")
    else:
        raw = RAW_OWN
    return f"row{index}={raw};stamp:{added}:{changed};"


def world(
    namespace: int,
    next_id: int,
    high_water: int,
    live: str,
    capacity: int,
    depth: int,
    rows: str,
    resource: str,
    events: str,
    pending: int,
    clock: int,
) -> str:
    # Registration list is empty; next system ID remains the initial 1.
    return "/".join(
        (
            str(namespace),
            str(next_id),
            str(high_water),
            bool_array(live),
            str(capacity),
            str(depth),
            rows,
            resource,
            events,
            str(pending),
            "",
            "1",
            str(clock),
        )
    )


FOREIGN_WORLD = world(
    2,
    2,
    1,
    "01",
    2,
    1,
    row(1, SEED_SECOND, 1, 1),
    RESOURCE_SECOND,
    "",
    0,
    1,
)


def accepted_prefix(incoming: str, canonical: str, host: str = "accepted") -> str:
    return f"ok:{canonical}|{incoming}|host:{host}|"


def refused_prefix(checked: str, incoming: str, host: str) -> str:
    return f"{checked}|{incoming}|host:{host}|"


def scenario(selector: int) -> str:
    """Derive one selector result, including the final post-barrier world."""
    own_row = row(1, SEED_FIRST, 1, 1)
    incoming_row = row(1, INCOMING_OWN, 1, 3)
    unchanged_world = world(
        1, 2, 1, "01", 2, 1, own_row, RESOURCE_FIRST, "77,", 0, 1
    )

    if selector <= 2:
        actual = "handle:2:1"
        incoming = INCOMING_FOREIGN
        checked = f"$.target:same-world handle:{actual}"
        first_world = unchanged_world
        output_incoming = incoming + ";"
        prefix = refused_prefix(checked, output_incoming, "not-attempted")
    elif selector <= 5:
        actual = "handle:1:0"
        incoming = INCOMING_ZERO
        checked = f"$.target:same-world handle:{actual}"
        first_world = unchanged_world
        output_incoming = incoming + ";"
        prefix = refused_prefix(checked, output_incoming, "not-attempted")
    elif selector == 6:
        # Two reserved spawns are queued around the event marker. FIFO drain
        # executes their activations/populations at ticks 2 then 3.
        rows = (
            row(1, SEED_FIRST, 1, 1)
            + row(2, INCOMING_OWN, 2, 2)
            + row(3, INCOMING_OWN, 3, 3)
        )
        first_world = world(1, 4, 3, "0111", 4, 2, rows, RESOURCE_FIRST, "77,", 0, 3)
        prefix = accepted_prefix("none;", RAW_OWN)
    elif selector == 7:
        first_world = world(1, 2, 1, "01", 2, 1, incoming_row, RESOURCE_FIRST, "77,", 0, 3)
        prefix = accepted_prefix("none;", RAW_OWN)
    elif selector == 8:
        first_world = world(1, 2, 1, "01", 2, 1, own_row, INCOMING_OWN, "77,", 0, 1)
        prefix = accepted_prefix("none;", RAW_OWN)
    elif selector == 9:
        checked = "ok:" + RAW_OWN
        output_incoming = INCOMING_OWN + ";"
        prefix = refused_prefix(checked, output_incoming, "rejected:MissingEntity")
        first_world = unchanged_world
    else:
        first_world = world(1, 2, 1, "01", 2, 1, own_row, INCOMING_NULL, "77,", 0, 1)
        prefix = accepted_prefix("none;", RAW_NULL)

    return prefix + first_world + "|foreign:" + FOREIGN_WORLD + "|factory:3"


def expected_stdout() -> bytes:
    # The consumer invokes each selector for two nominal schemas. Their
    # formatter exposes runtime namespaces/values but no nominal schema name.
    rows = [scenario(index) for index in range(11)]
    rows.extend(scenario(index) for index in range(11))
    return ("\n".join(rows) + "\n").encode("utf-8")


def main() -> None:
    stdout = expected_stdout()
    compressed = gzip.compress(stdout, compresslevel=9, mtime=0)
    (ROOT / "expected.stdout.gz").write_bytes(compressed)
    oracle = {
        "schema": "bendvy-handle-admission-independent-oracle-v1",
        "rows": 22,
        "selectorsPerSchema": 11,
        "runtimeOutputInputsUsed": False,
        "stdoutLength": len(stdout),
        "stdoutSha256": hashlib.sha256(stdout).hexdigest(),
        "gzipLength": len(compressed),
        "gzipSha256": hashlib.sha256(compressed).hexdigest(),
        "lineSha256": [
            hashlib.sha256(line).hexdigest()
            for line in stdout.rstrip(b"\n").split(b"\n")
        ],
        "rowsBySchema": {
            "First": [scenario(index) for index in range(11)],
            "Second": [scenario(index) for index in range(11)],
        },
        "sourceDerivedInvariants": {
            "seededWorldClock": 1,
            "markerEvents": [77],
            "pendingAfterRenderBarrier": 0,
            "factoryCursor": 3,
            "doubleSpawn": {
                "ids": [2, 3],
                "fifoOrder": ["spawn-2", "marker", "spawn-3"],
                "worldClock": 3,
                "live": "0111",
                "columnStamps": [[1, 1], [2, 2], [3, 3]],
            },
            "doubleInsert": {
                "fifoOrder": ["insert-1", "marker", "insert-2"],
                "worldClock": 3,
                "row1Stamp": [1, 3],
            },
            "resourceReplace": {
                "worldClock": 1,
                "retiredOwners": 0,
                "pendingAfterRenderBarrier": 0,
            },
        },
    }
    (ROOT / "ORACLES.json").write_text(
        json.dumps(oracle, sort_keys=True, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps({k: oracle[k] for k in ("rows", "stdoutLength", "stdoutSha256", "gzipLength", "gzipSha256")}, sort_keys=True))


if __name__ == "__main__":
    main()
