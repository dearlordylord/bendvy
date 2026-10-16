#!/usr/bin/env python3
"""Derive and self-check the source-only family-readers-v1 stdout oracle."""
from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = Path("/workspace/formal-proofs/bendvy")
PRODUCER = Path("/workspace/formal-proofs/bendvy-worktrees/events53-ordinary")
FIXTURE = PRODUCER / "experiments/public-owned-events/family-readers-v1"
FREEZE_PATH = FIXTURE / "SOURCE-FREEZE.json"
CHECK_PATH = FIXTURE / "SOURCE-CHECK.json"
BASIS_PATH = HERE / "SOURCE-BASIS.json"
EXPECTED_PATH = HERE / "expected.stdout"
GZIP_PATH = HERE / "expected.stdout.gz"

sys.path.insert(0, str(HERE))
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
    return {
        "schema": "bendvy-events53-family-readers-independent-oracle-v1",
        "producerCommit": "21ddb0860",
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
        "model": {
            "path": "model.py",
            "sha256": sha256((HERE / "model.py").read_bytes()),
        },
        "format": {
            "path": "format.py",
            "sha256": sha256((HERE / "format.py").read_bytes()),
            "formatOwnerCommit": "b6bb91a01",
        },
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
    output = model.derive_complete()
    return output.encode("utf-8")


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
        raise SystemExit("expected.stdout does not equal source-derived output")
    if not GZIP_PATH.is_file() or GZIP_PATH.read_bytes() != compressed:
        raise SystemExit("expected.stdout.gz does not equal deterministic gzip of raw output")
    if gzip.decompress(GZIP_PATH.read_bytes()) != raw:
        raise SystemExit("gzip golden does not decompress to exact raw bytes")
    return {
        "status": "SOURCE_DERIVED_ORACLE_SELFTEST_PASS",
        "bytes": len(raw),
        "sha256": sha256(raw),
        "gzipBytes": len(compressed),
        "gzipSha256": sha256(compressed),
        "sourceCount": len(basis["sourceInventory"]),
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
        "status": "SOURCE_DERIVED_ORACLE_WRITTEN",
        "bytes": len(raw),
        "sha256": sha256(raw),
        "gzipBytes": GZIP_PATH.stat().st_size,
        "gzipSha256": sha256(GZIP_PATH.read_bytes()),
    }, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
