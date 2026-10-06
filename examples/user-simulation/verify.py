#!/usr/bin/env python3
"""Check complete observed public-API JSON, including the approved divergence."""
import argparse
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
FOREIGN = "foreign-collision-reference"


def validate(actual):
    expected = json.loads((HERE / "expected.json").read_text())
    if actual.get("format") != expected["format"]:
        raise AssertionError("Observation format differs")
    observations = actual["checkpoints"]
    labels = [p["label"] for p in observations]
    if labels != [p["label"] for p in expected["checkpoints"]]:
        raise AssertionError("Checkpoint labels/order/count differ")
    for observed, reference in zip(observations, expected["checkpoints"]):
        if reference["label"] == FOREIGN:
            required = {"label": FOREIGN, "foreignId": 1, "localId": 1,
                        "ok": False, "error": "MissingEntity",
                        "queueUnchanged": True, "postBarrierUnchanged": True}
            if observed != required:
                raise AssertionError(f"Foreign-world divergence differs: {observed!r}")
        elif observed != reference:
            raise AssertionError(f"Full checkpoint mismatch at {reference['label']}:\n"
                                 f"expected={reference!r}\nobserved={observed!r}")
    return {"status": "PASS", "equalCheckpoints": 22,
            "approvedDivergences": 1, "completeCheckpoints": len(observations)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("observations", type=Path)
    args = parser.parse_args()
    print(json.dumps(validate(json.loads(args.observations.read_text()))))


if __name__ == "__main__":
    main()
