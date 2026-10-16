#!/usr/bin/env python3
"""Derive and self-check the corrected source-only family-reader stdout."""
from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE_ORACLE = HERE.parent / "oracle"
PRODUCER = Path("/workspace/formal-proofs/bendvy-worktrees/events53-ordinary")
FIXTURE = PRODUCER / "experiments/public-owned-events/family-readers-v1"
FREEZE_PATH = FIXTURE / "SOURCE-FREEZE.json"
CHECK_PATH = FIXTURE / "SOURCE-CHECK.json"
BASIS_PATH = HERE / "SOURCE-BASIS.json"
EXPECTED_PATH = HERE / "expected.stdout"
GZIP_PATH = HERE / "expected.stdout.gz"

sys.path.insert(0, str(HERE))
sys.path.insert(1, str(BASE_ORACLE))
import format as output_format
import model


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def canonical_json(value) -> bytes:
    return (json.dumps(value, indent=2, sort_keys=True) + "\n").encode("utf-8")


def current_basis() -> dict:
    freeze_bytes = FREEZE_PATH.read_bytes()
    freeze = json.loads(freeze_bytes)
    check_bytes = CHECK_PATH.read_bytes()
    source_inventory = freeze["sourceInventory"]
    missing = []
    changed = []
    for source_path, expected_sha in sorted(source_inventory.items()):
        path = Path(source_path)
        if not path.is_file():
            missing.append(source_path)
            continue
        if sha256(path.read_bytes()) != expected_sha:
            changed.append(source_path)
    if missing or changed:
        raise SystemExit(f"frozen source drift: missing={missing}, changed={changed}")

    base_model = BASE_ORACLE / "model.py"
    base_stdout = BASE_ORACLE / "expected.stdout"
    format_path = BASE_ORACLE / "format.py"
    return {
        "schema": "bendvy-events53-family-readers-independent-oracle-successor-v2",
        "producerCommit": "21ddb0860",
        "preservedPredecessor": {
            "commit": "53ce7a6d9",
            "modelPath": str(base_model),
            "modelSha256": sha256(base_model.read_bytes()),
            "normalOracleBytes": base_stdout.stat().st_size,
            "normalOracleSha256": sha256(base_stdout.read_bytes()),
        },
        "sourceFreeze": {
            "path": str(FREEZE_PATH),
            "sha256": sha256(freeze_bytes),
            "sourceCount": len(source_inventory),
            "entrypoint": freeze["entrypoint"],
        },
        "sourceCheck": {
            "path": str(CHECK_PATH),
            "sha256": sha256(check_bytes),
            "scope": "source-only concrete pure entry; no runtime output",
        },
        "sourceInventory": [
            {"path": path, "sha256": digest}
            for path, digest in sorted(source_inventory.items())
        ],
        "model": {"path": "model.py", "sha256": sha256((HERE / "model.py").read_bytes())},
        "format": {
            "path": str(format_path),
            "sha256": sha256(format_path.read_bytes()),
            "formatOwnerCommit": "b6bb91a01",
        },
        "sourceCorrections": [
            {
                "basis": "src/ecs/event-runtime.bend size/at_capacity",
                "effect": "Capacity compares the total number of values in batches; Cargo's two-value batch fills capacity two and retires the older batch at each applicable frame.",
            },
            {
                "basis": "src/ecs/event-runtime.bend reading/run_position",
                "effect": "Lag uses max(cursor,registeredAt) < droppedThrough; a missing position is read with registeredAt equal to the pre-call route tick.",
            },
            {
                "basis": "family-readers-v1/fixture.bend nested_at + ordinary-v1/payload.bend Payload.at",
                "effect": "Crates descends to the first crate then reads index zero, yielding scalar U32 900 while preserving marker values.",
            },
            {
                "basis": "src/ecs/event-stream.bend frame + src/ecs/event-runtime.bend frame/trim",
                "effect": "The public boundary is the prior frameStart; the held cursor minimum is an internal past-window cutoff.",
            },
            {
                "basis": "family-readers-v1/observe.bend snapshot_join + scenario.bend observed/disposal_observed + main.bend IO.print",
                "effect": "Snapshots and runtime observations add no delimiter; operation strings concatenate directly. The trace's final disposed-all LF is followed by IO.print's terminal LF.",
            },
            {
                "basis": "family-readers-v1/observe.bend stream + scenario.bend dispose_*",
                "effect": "Reader statuses are recomputed from the remaining positions at each post-disposal View.runtime observation.",
            },
        ],
        "derivation": {
            "runtimeOutputConsulted": False,
            "backendExecuted": False,
            "operationSource": str(FIXTURE / "scenario.bend"),
            "completeObserverSource": str(FIXTURE / "observe.bend"),
            "worldIoSource": str(PRODUCER / "src/ecs/world-io.bend"),
            "worldNamespaceSources": [
                str(PRODUCER / "src/ecs/world-namespace.c"),
                str(PRODUCER / "src/ecs/world-namespace.js"),
            ],
            "printBoundary": "main.bend passes Workshop/LF + Workshop trace + Garden/LF + Garden trace to one IO.print; each modeled trace ends with disposed-all/LF and IO.print appends exactly one terminal LF, so stdout ends with two LFs after the final disposed-all line.",
        },
    }


def build_expected() -> bytes:
    return model.derive_complete().encode("utf-8")


def _selftest() -> dict:
    basis = current_basis()
    if not BASIS_PATH.is_file():
        raise SystemExit("SOURCE-BASIS.json missing; run derive.py --write first")
    saved_basis = json.loads(BASIS_PATH.read_bytes())
    if canonical_json(saved_basis) != canonical_json(basis):
        raise SystemExit("source/model/format pins do not match SOURCE-BASIS.json")

    model._selftest()
    raw = build_expected()
    compressed = gzip.compress(raw, mtime=0)
    if not EXPECTED_PATH.is_file() or EXPECTED_PATH.read_bytes() != raw:
        raise SystemExit("expected.stdout does not equal corrected source-derived output")
    if not GZIP_PATH.is_file() or GZIP_PATH.read_bytes() != compressed:
        raise SystemExit("expected.stdout.gz is not deterministic gzip of exact raw output")
    if gzip.decompress(GZIP_PATH.read_bytes()) != raw:
        raise SystemExit("gzip golden does not decompress to exact raw bytes")
    return {
        "status": "SOURCE_DERIVED_CORRECTED_ORACLE_SELFTEST_PASS",
        "bytes": len(raw),
        "sha256": sha256(raw),
        "gzipBytes": len(compressed),
        "gzipSha256": sha256(compressed),
        "sourceCount": len(basis["sourceInventory"]),
        "correctionCount": len(basis["sourceCorrections"]),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="write deterministic basis and golden")
    parser.add_argument("--selftest", action="store_true", help="verify pins and exact derived bytes")
    args = parser.parse_args()
    if args.write:
        basis = current_basis()
        raw = build_expected()
        compressed = gzip.compress(raw, mtime=0)
        BASIS_PATH.write_bytes(canonical_json(basis))
        EXPECTED_PATH.write_bytes(raw)
        GZIP_PATH.write_bytes(compressed)
    if args.selftest:
        print(json.dumps(_selftest(), sort_keys=True))
        return 0
    if not args.write:
        parser.error("choose --write or --selftest")
    raw = EXPECTED_PATH.read_bytes()
    print(json.dumps({
        "status": "SOURCE_DERIVED_CORRECTED_ORACLE_WRITTEN",
        "bytes": len(raw),
        "sha256": sha256(raw),
        "gzipBytes": GZIP_PATH.stat().st_size,
        "gzipSha256": sha256(GZIP_PATH.read_bytes()),
    }, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
