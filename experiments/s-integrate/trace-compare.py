#!/usr/bin/env python3
"""Strict E0–E10 public trace comparison; not an execution or proof gate alone."""
import argparse
import json
import pathlib
import sys

CHANNELS = (
    "rawReservations", "reads", "readerDiagnostics", "ownWrites", "snapshots",
    "dispatches", "auditEffects", "provisioning", "finalCounts", "tails",
)
LANES = {f"{schema}/{style}" for schema in ("Motion", "Health")
         for style in ("returned-owner", "regenerated-closure")}


def difference(expected, actual, path="$", differences=None):
    """Keep types, complete object fields, all array cells and sequence order."""
    if differences is None:
        differences = []
    if type(expected) is not type(actual):
        differences.append({"path": path, "expected": expected, "actual": actual})
    elif isinstance(expected, dict):
        for key in sorted(expected.keys() | actual.keys()):
            if key not in expected or key not in actual:
                differences.append({"path": f"{path}.{key}",
                                    "error": "unexpected field" if key not in expected else "missing field"})
            else:
                difference(expected[key], actual[key], f"{path}.{key}", differences)
    elif isinstance(expected, list):
        if len(expected) != len(actual):
            differences.append({"path": path, "expected_length": len(expected),
                                "actual_length": len(actual)})
        for index, (left, right) in enumerate(zip(expected, actual)):
            difference(left, right, f"{path}[{index}]", differences)
    elif expected != actual:
        differences.append({"path": path, "expected": expected, "actual": actual})
    return differences


def project(envelope):
    if envelope.get("defect") or envelope.get("differences"):
        raise ValueError("input contains recorded execution defects/differences")
    results = envelope["results"]
    lanes = {}
    for result in results:
        lane = result["lane"]
        if lane in lanes:
            raise ValueError(f"duplicate lane: {lane}")
        if lane != result["schema"] + "/" + result["style"]:
            raise ValueError(f"inconsistent lane identity: {lane}")
        lanes[lane] = {key: result[key] for key in CHANNELS}
    if lanes.keys() != LANES:
        raise ValueError(f"requires exactly four lanes; received {sorted(lanes)}")
    return lanes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("reference", type=pathlib.Path)
    parser.add_argument("observed", type=pathlib.Path)
    args = parser.parse_args()
    try:
        reference = project(json.loads(args.reference.read_text()))
        observed = project(json.loads(args.observed.read_text()))
        differences = difference(reference, observed)
    except (KeyError, ValueError, TypeError) as error:
        print(json.dumps({"status": "INCOMPLETE", "error": str(error)}))
        return 2
    print(json.dumps({"status": "DIFF" if differences else "MATCH",
                      "channels": CHANNELS, "lanes": sorted(LANES),
                      "differences": differences}, indent=2))
    return int(bool(differences))


if __name__ == "__main__":
    sys.exit(main())
