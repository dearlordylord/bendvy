"""Independent #58 ordinary constructor/save oracle.

The values are derived from the frozen current Bend renderer and state flow.
No candidate backend output is read here.  The retained qualified model is
used only as a semantic cross-check for the unchanged Workshop/Garden report.
"""
from __future__ import annotations

import copy
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def entity(identifier: int, values: list[int], name: str = "Payload") -> dict:
    return {"id": identifier, "components": {name: values}}


def snapshot(changed: bool = False) -> dict:
    return {
        "version": 1,
        "nextEntity": 4,
        "entities": [
            entity(1, [11, 13] if changed else [7, 9]),
            entity(2, [17, 19]),
        ],
        "resources": {"Settings": [31, 33] if changed else [27, 29]},
    }


def array_column(rows: list[dict]) -> dict:
    # Col.ensure(empty, 2) grows the one-leaf column to ANode[ALeaf,ALeaf].
    # The saved observation provider then walks handles 1,2,3.
    return {
        "rows": rows + [{"id": 3, "components": {}}],
        "firstStamp": {"added": 0, "changed": 0},
        "secondStamp": {"added": 0, "changed": 0},
    }


def owner(namespace: int, changed: bool = False) -> dict:
    return {
        "namespace": namespace,
        "nextId": 4,
        "highWater": 3,
        "capacity": 4,
        "depth": 2,
        "handles": [
            {"namespace": namespace, "id": 1},
            {"namespace": namespace, "id": 2},
        ],
        "store": {
            "saved": array_column([
                entity(1, [11, 13] if changed else [7, 9]),
                entity(2, [17, 19]),
            ]),
            "transient": array_column([
                entity(1, [107, 109], "Scratch"),
                entity(2, [117, 119], "Scratch"),
            ]),
            "codec": {
                "ArrayValue": {"FiniteNumber": {}}
                if changed
                else {"Integer": {}}
            },
        },
        "resources": {
            "saved": [31, 33] if changed else [27, 29],
            "transient": [127, 129],
            "codec": (
                {"ArrayValue": {"LiteralValues": [31, 33]}}
                if changed
                else {"Nullable": {"ArrayValue": {"FiniteNumber": {}}}}
            ),
        },
        "events": [],
        "pendingCount": 0,
        "registrations": [],
        "nextSystemId": 1,
        "clock": 0,
    }


def validation(changed: bool = False) -> dict:
    def field(name: str, value: list[int]) -> dict:
        return {"name": name, "result": {"Accepted": value}}

    return {
        "entities": [
            {"id": 1, "fields": [field("Payload", [11, 13] if changed else [7, 9])]},
            {"id": 2, "fields": [field("Payload", [17, 19])]},
        ],
        "resources": [
            field("Settings", [31, 33] if changed else [27, 29])
        ],
    }


def first_validation() -> dict:
    value = validation(False)
    value["resources"][0]["result"] = {
        "Rejected": {
            "Invalid": {
                "path": "$[0]",
                "expected": "literal",
                "actual": 27,
            }
        }
    }
    return value


def metadata(changed: bool = False) -> dict:
    return {
        "component": {
            "ArrayValue": {"FiniteNumber": {}}
            if changed
            else {"Integer": {}}
        },
        "resource": (
            {"ArrayValue": {"LiteralValues": [31, 33]}}
            if changed
            else {"Nullable": {"ArrayValue": {"FiniteNumber": {}}}}
        ),
    }


def report(namespace: int) -> dict:
    return {
        "before": owner(namespace),
        "firstOwner": owner(namespace),
        "secondOwner": owner(namespace),
        "first": snapshot(False),
        "second": snapshot(False),
        "after": snapshot(True),
        "firstValidation": first_validation(),
        "afterValidation": validation(True),
        "gateMetadataBefore": metadata(False),
        "gateMetadataAfter": metadata(True),
        "owner": owner(namespace, True),
    }


def inventory() -> list[dict]:
    # ordinary-schema.product preserves left-to-right bare Entry values.  The
    # additive Classified constructor is handled by the Bend renderer but is
    # not reached by this component/resource schema.
    return [
        {"kind": "Component", "key": "Payload", "name": "Payload"},
        {"kind": "Component", "key": "Scratch", "name": "Scratch"},
        {"kind": "Resource", "key": "Settings", "name": "Settings"},
        {"kind": "Resource", "key": "ScratchSettings", "name": "ScratchSettings"},
    ]


def admission_column() -> dict:
    return {
        "values": {
            "ANode": [
                {"ALeaf": {"Some": [7, 9]}},
                {"ALeaf": None},
            ]
        },
        "stamps": [],
    }


def admission() -> dict:
    recipe = {
        "key": "Payload",
        "codec": {"ArrayValue": {"LiteralValues": [7, 9]}},
    }
    column = admission_column()
    return {
        "accepted": {
            "recipe": copy.deepcopy(recipe),
            "checked": {"Accepted": [7, 9]},
            "column": copy.deepcopy(column),
        },
        "rejected": {
            "recipe": copy.deepcopy(recipe),
            "checked": {
                "Rejected": {
                    "Invalid": {
                        "path": "$[0]",
                        "expected": "literal",
                        "actual": 11,
                    }
                }
            },
            "before": copy.deepcopy(column),
            "after": copy.deepcopy(column),
            "incoming": [11, 13],
        },
    }


def expected_object() -> dict:
    return {
        "scenario": {"Workshop": report(1), "Garden": report(2)},
        "ordinary": {"inventory": inventory(), "admission": admission()},
    }


def compact_bytes() -> bytes:
    # Format.raw and the consumer's IO.print are compact and append one LF.
    return (json.dumps(expected_object(), separators=(",", ":"), ensure_ascii=False) + "\n").encode("utf-8")


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def write_outputs() -> tuple[bytes, str]:
    data = compact_bytes()
    (HERE / "expected.stdout").write_bytes(data)
    with (HERE / "expected.stdout.gz").open("wb") as compressed:
        with gzip.GzipFile(filename="", mode="wb", fileobj=compressed, mtime=0) as stream:
            stream.write(data)
    (HERE / "expected.json").write_text(
        json.dumps(expected_object(), indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    return data, sha256(data)


def selfcheck() -> dict:
    data = compact_bytes()
    parsed = json.loads(data)
    assert parsed == expected_object()
    assert data.endswith(b"\n")
    assert data.count(b"\n") == 1
    return {"bytes": len(data), "sha256": sha256(data), "jsonRoundTrip": True}


if __name__ == "__main__":
    data, digest = write_outputs()
    print(json.dumps({"bytes": len(data), "sha256": digest}, sort_keys=True))
