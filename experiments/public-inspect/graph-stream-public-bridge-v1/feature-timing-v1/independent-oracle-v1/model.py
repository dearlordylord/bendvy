#!/usr/bin/env python3
"""Independent logical oracle for the #55 matched feature lifecycle.

The model follows the frozen Bend source and its source-only TypeScript
reference.  It emits only ``app.run(count)``'s logical JSON.  The app's
``report``/physical route is deliberately outside this byte oracle: it keeps
runtime worlds, event batches, registrations, and stream positions whose
representations are backend-specific.

This file never invokes Bend, Node, a generated backend, or a historical
output.  ``write`` and ``check`` first rehash every path in SOURCE-BASIS.json.
"""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
from pathlib import Path
from typing import Any


HERE = Path(__file__).resolve().parent


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def basis() -> dict[str, Any]:
    return json.loads((HERE / "SOURCE-BASIS.json").read_bytes())


def check_sources() -> None:
    data = basis()
    for entry in data["sourceClosure"]:
        path = Path(entry["path"])
        if not path.is_file():
            raise AssertionError(f"missing pinned source: {path}")
        actual = sha256(path)
        expected = entry["sha256"]
        if actual != expected:
            raise AssertionError(f"source drift: {path}: {actual} != {expected}")


def compact(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"))


MODES = (
    "required_out",
    "optional_out",
    "present_out",
    "absent_out",
    "required_in",
    "optional_in",
    "present_in",
    "absent_in",
)


def selected_rows(relation: str, mode: str) -> list[dict[str, Any]]:
    """Rows from relation-query.bend over the three live seeded entities.

    setup.bend inserts 1->2 and 3->2 for both Link and Parent.  The query
    projection walks the live handles in numeric order and renders one cell
    for the selected relation requirement.
    """

    del relation  # Link and Parent have the same seeded graph.
    if mode == "required_out":
        return [
            {"id": 1, "cells": [{"target": 2}]},
            {"id": 3, "cells": [{"target": 2}]},
        ]
    if mode == "optional_out":
        return [
            {"id": 1, "cells": [{"target": 2}]},
            {"id": 2, "cells": [{"missing": True}]},
            {"id": 3, "cells": [{"target": 2}]},
        ]
    if mode == "present_out":
        return [{"id": 1, "cells": []}, {"id": 3, "cells": []}]
    if mode == "absent_out":
        return [{"id": 2, "cells": []}]
    if mode == "required_in":
        return [{"id": 2, "cells": [{"sources": [1, 3]}]}]
    if mode == "optional_in":
        return [
            {"id": 1, "cells": [{"missing": True}]},
            {"id": 2, "cells": [{"sources": [1, 3]}]},
            {"id": 3, "cells": [{"missing": True}]},
        ]
    if mode == "present_in":
        return [{"id": 2, "cells": []}]
    if mode == "absent_in":
        return [{"id": 1, "cells": []}, {"id": 3, "cells": []}]
    raise AssertionError(f"unknown relation mode: {mode}")


def check_result() -> dict[str, bool]:
    return {"called": True, "allowed": True, "ran": True}


def category_records(schema: str) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for relation in ("Link", "Parent"):
        for mode in MODES:
            rows = selected_rows(relation, mode)
            for passed in ("first", "second"):
                records.append(
                    {
                        "schema": schema,
                        "operation": "inspect",
                        "relation": relation,
                        "mode": mode,
                        "pass": passed,
                        "result": rows,
                    }
                )
            # Guard/schedule uses the same source declaration and a fresh
            # condition pass.  setup's seeded graph makes all eight expected
            # row-count predicates true, and Noop is registered/run twice.
            for passed in ("first", "second"):
                records.append(
                    {
                        "schema": schema,
                        "operation": "check-noop",
                        "relation": relation,
                        "mode": mode,
                        "pass": passed,
                        "result": check_result(),
                    }
                )
    return records


def relation_rows() -> list[dict[str, Any]]:
    """The four-cell optional composed relation query used by Union."""

    return [
        {
            "id": 1,
            "cells": [
                {"target": 2},
                {"missing": True},
                {"target": 2},
                {"missing": True},
            ],
        },
        {
            "id": 2,
            "cells": [
                {"missing": True},
                {"sources": [1, 3]},
                {"missing": True},
                {"sources": [1, 3]},
            ],
        },
        {
            "id": 3,
            "cells": [
                {"target": 2},
                {"missing": True},
                {"target": 2},
                {"missing": True},
            ],
        },
    ]


def parent_failure(schema: str) -> dict[str, Any]:
    """The rejected Parent 2->3 mutation published by setup.bend.

    The category driver runs through ``Read.map_world``/``Ev.with_world``;
    that synchronization drops the two retained Original notices and adds
    this relation failure to the event runtime before either fresh Union
    inspector runs.  Each fresh inspector uses an independent cursor at zero,
    while the registered reader starts after the warm run and sees the same
    later batch.
    """

    return {
        "relation": "Parent",
        "related": "Children",
        "kind": "hierarchy",
        "linked": True,
        "allowSelf": False,
        "ordered": True,
        "operation": "relate",
        "source": 2,
        "target": 3,
        "error": {
            "kind": "HierarchyCycle",
            "entity": 2,
            "target": 3,
            "relation": "Parent",
        },
    }


def machine_streams(schema: str) -> dict[str, Any]:
    # setup applies 4->7 and 10->11 after the warm reader.  The stream owner
    # is already positioned after the warm Original notices; the public Union
    # fresh frames observe both transition batches and the newly synchronized
    # Parent failure from cursor zero.  The later registered reader observes
    # the same Parent batch after its warm cursor.
    return {
        "flowTransitions": [{"from": 4, "to": 7}],
        "levelTransitions": [{"from": 10, "to": 11}],
        "flowLagged": False,
        "levelLagged": False,
        "parentFailures": [parent_failure(schema)],
        "parentLagged": False,
    }


def machine_result(schema: str) -> dict[str, Any]:
    streams = machine_streams(schema)
    return {
        "flow": 7,
        "level": 11,
        **streams,
        "rows": relation_rows(),
    }


def machine_records(schema: str) -> list[dict[str, Any]]:
    result = machine_result(schema)
    stream = {
        "flow": 7,
        "level": 11,
        **machine_streams(schema),
    }
    return [
        {
            "schema": schema,
            "operation": "machine-inspect",
            "pass": "first",
            "result": result,
        },
        {
            "schema": schema,
            "operation": "machine-inspect",
            "pass": "second",
            "result": result,
        },
        {
            "schema": schema,
            "operation": "machine-check-noop",
            "result": check_result(),
        },
        {
            "schema": schema,
            "operation": "registered-stream-read",
            "result": stream,
        },
    ]


def lifecycle() -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for schema in ("Workshop", "Garden"):
        records.extend(category_records(schema))
        records.extend(machine_records(schema))
    if len(records) != 136:
        raise AssertionError(f"expected 136 records, got {len(records)}")
    return records


def generate(count: int) -> bytes:
    if count not in (1, 2, 4):
        raise ValueError("the finite oracle exposes only scales 1, 2, and 4")
    payload = [lifecycle() for _ in range(count)]
    # The harness captures the app's textual result as stdout with the
    # repository's normal terminal LF convention.  There are no spaces in
    # Render.array/Render.quoted output.
    return (compact(payload) + "\n").encode("utf-8")


def output_paths(count: int) -> tuple[Path, Path, Path]:
    raw = HERE / f"expected-scale-{count}.stdout"
    parsed = HERE / f"expected-scale-{count}.json"
    zipped = HERE / f"expected-scale-{count}.stdout.gz"
    return raw, parsed, zipped


def write() -> dict[str, Any]:
    check_sources()
    outputs: dict[str, Any] = {}
    for count in (1, 2, 4):
        raw, parsed, zipped = output_paths(count)
        data = generate(count)
        raw.write_bytes(data)
        parsed.write_bytes(data)
        with zipped.open("wb") as stream:
            with gzip.GzipFile(fileobj=stream, mode="wb", mtime=0) as compressed:
                compressed.write(data)
        outputs[str(count)] = {
            "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest(),
            "gzipBytes": zipped.stat().st_size,
            "gzipSha256": sha256(zipped),
            "records": len(json.loads(data)),
            "recordsPerLifecycle": len(json.loads(data)[0]),
        }
    return outputs


def check() -> dict[str, Any]:
    check_sources()
    outputs: dict[str, Any] = {}
    for count in (1, 2, 4):
        raw, parsed, zipped = output_paths(count)
        expected = generate(count)
        if raw.read_bytes() != expected:
            raise AssertionError(f"raw oracle mismatch: {raw}")
        if parsed.read_bytes() != expected:
            raise AssertionError(f"JSON oracle mismatch: {parsed}")
        with gzip.open(zipped, "rb") as stream:
            if stream.read() != expected:
                raise AssertionError(f"gzip oracle mismatch: {zipped}")
        decoded = json.loads(expected)
        if len(decoded) != count or any(len(lifecycle) != 136 for lifecycle in decoded):
            raise AssertionError(f"record count mismatch at scale {count}")
        outputs[str(count)] = {
            "bytes": len(expected),
            "sha256": hashlib.sha256(expected).hexdigest(),
            "gzipBytes": zipped.stat().st_size,
            "gzipSha256": sha256(zipped),
        }
    return outputs


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("write", "check"))
    args = parser.parse_args()
    result = write() if args.command == "write" else check()
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()
