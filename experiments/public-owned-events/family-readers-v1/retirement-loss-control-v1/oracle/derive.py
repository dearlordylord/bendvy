#!/usr/bin/env python3
"""Pin the retirement-loss mutation and write its source-derived counter."""
from __future__ import annotations

import argparse
import gzip
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
SUCCESSOR = HERE.parents[1] / "oracle-successor-v2"
NORMAL_ORACLE = HERE.parents[1] / "oracle"
PRODUCER = Path("/workspace/formal-proofs/bendvy-worktrees/events53-ordinary")
MUTANT = Path("/workspace/formal-proofs/bendvy-worktrees/events53-family-reader-authority")
NORMAL_FREEZE = PRODUCER / "experiments/public-owned-events/family-readers-v1/SOURCE-FREEZE.json"
MUTANT_ROOT = (MUTANT / "experiments/public-owned-events/family-readers-v1/"
               "retirement-loss-control-v1")
MUTANT_FREEZE = MUTANT_ROOT / "SOURCE-FREEZE.json"
MUTANT_SOURCE = MUTANT_ROOT / "source"
MUTATION_PATCH = MUTANT_ROOT / "mutation.patch"
SOURCE_TAR = MUTANT_ROOT / "source.tar.gz"
BASIS_PATH = HERE / "SOURCE-BASIS.json"
EXPECTED_PATH = HERE / "expected.stdout"
GZIP_PATH = HERE / "expected.stdout.gz"

sys.path.insert(0, str(HERE))
sys.path.insert(1, str(SUCCESSOR))
sys.path.insert(2, str(NORMAL_ORACLE))
import counter_model


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def canonical_json(value) -> bytes:
    return (json.dumps(value, indent=2, sort_keys=True) + "\n").encode("utf-8")


def _relative(path: str, marker: str) -> str:
    if marker not in path:
        raise SystemExit(f"source path lacks expected root marker {marker}: {path}")
    return path.split(marker, 1)[1]


def current_basis() -> dict:
    normal_freeze_bytes = NORMAL_FREEZE.read_bytes()
    normal_freeze = json.loads(normal_freeze_bytes)
    normal_inventory = normal_freeze["sourceInventory"]
    normal_by_path = {
        _relative(path, "/events53-ordinary/"): digest
        for path, digest in normal_inventory.items()
    }

    mutant_freeze_bytes = MUTANT_FREEZE.read_bytes()
    mutant_freeze = json.loads(mutant_freeze_bytes)
    mutant_inventory = mutant_freeze["sourceInventory"]
    mutant_by_path = {
        _relative(path, "/retirement-loss-control-v1/source/"): digest
        for path, digest in mutant_inventory.items()
    }

    missing = sorted(set(normal_by_path) - set(mutant_by_path))
    changed = sorted(path for path in set(normal_by_path) & set(mutant_by_path)
                     if normal_by_path[path] != mutant_by_path[path])
    extra = sorted(set(mutant_by_path) - set(normal_by_path))
    if missing or changed != ["src/ecs/owned-event-log.bend"]:
        raise SystemExit(f"unexpected normal/mutant source join: missing={missing}, changed={changed}")
    if extra != [
            "experiments/public-owned-events/family-readers-v1/source-control.bend",
            "src/ecs/world-namespace.c",
            "src/ecs/world-namespace.js"]:
        raise SystemExit(f"unexpected extra mutant source members: {extra}")

    for path, expected in mutant_inventory.items():
        source_path = Path(path)
        if not source_path.is_file() or sha256(source_path.read_bytes()) != expected:
            raise SystemExit(f"mutant frozen source drift: {path}")

    normal_log_path = next(
        path for path in normal_inventory if path.endswith("/src/ecs/owned-event-log.bend"))
    normal_log = Path(normal_log_path)
    mutant_log = MUTANT_SOURCE / "src/ecs/owned-event-log.bend"
    if not mutant_log.is_file():
        raise SystemExit(f"mutant source member missing: {mutant_log}")
    normal_log_bytes = normal_log.read_bytes()
    mutant_log_bytes = mutant_log.read_bytes()
    old_arm = b"case False{}, (retained,retired):(retained,row <> retired)"
    new_arm = b"case False{}, (retained,retired):(retained,retired)"
    if normal_log_bytes.count(old_arm) != 1 or mutant_log_bytes != normal_log_bytes.replace(old_arm, new_arm, 1):
        raise SystemExit("retirement mutation is not the single pinned False-arm replacement")

    patch_bytes = MUTATION_PATCH.read_bytes()
    source_tar_bytes = SOURCE_TAR.read_bytes()
    normal_basis_bytes = (SUCCESSOR / "SOURCE-BASIS.json").read_bytes()
    normal_basis = json.loads(normal_basis_bytes)
    model_path = HERE / "counter_model.py"
    return {
        "schema": "bendvy-events53-family-readers-retirement-loss-counter-v1",
        "normalOracle": {
            "commit": "1a117f417",
            "basisPath": str(SUCCESSOR / "SOURCE-BASIS.json"),
            "basisSha256": sha256(normal_basis_bytes),
            "rawBytes": len((SUCCESSOR / "expected.stdout").read_bytes()),
            "rawSha256": sha256((SUCCESSOR / "expected.stdout").read_bytes()),
        },
        "mutation": {
            "commit": "66150ce05",
            "freezePath": str(MUTANT_FREEZE),
            "freezeSha256": sha256(mutant_freeze_bytes),
            "sourceCount": len(mutant_inventory),
            "sourceTarSha256": sha256(source_tar_bytes),
            "patchPath": str(MUTATION_PATCH),
            "patchSha256": sha256(patch_bytes),
            "changedMember": "src/ecs/owned-event-log.bend",
            "normalMemberSha256": normal_by_path["src/ecs/owned-event-log.bend"],
            "mutantMemberSha256": mutant_by_path["src/ecs/owned-event-log.bend"],
            "sourceJoin": {
                "normalMembers": len(normal_by_path),
                "commonUnchanged": len(set(normal_by_path) & set(mutant_by_path)) - len(changed),
                "changed": changed,
                "additionalMutantOnly": extra,
            },
            "effect": (
                "partitioned(False) preserves retained rows but returns the prior retired accumulator; "
                "the frame's owned-log state matches normal while every frame retirement receipt is empty. "
                "Shutdown uses drain and retains its actual receipt."
            ),
        },
        "normalSource": {
            "freezePath": str(NORMAL_FREEZE),
            "freezeSha256": sha256(normal_freeze_bytes),
            "sourceCount": len(normal_inventory),
        },
        "model": {
            "path": "counter_model.py",
            "sha256": sha256(model_path.read_bytes()),
            "usesCorrectedNormalStateModel": str(SUCCESSOR / "model.py"),
            "normalModelSha256": normal_basis["model"]["sha256"],
        },
        "derivation": {
            "runtimeOutputConsulted": False,
            "backendExecuted": False,
            "method": (
                "Run the corrected source-derived state transitions. At each actual frame call, "
                "apply the mutant's source-level empty retired-accumulator return while preserving "
                "the retained log, stream, journal and world state; render the complete two-schema trace."
            ),
            "affectedObservation": "the two frame return receipts only",
            "unaffectedObservation": "all complete snapshots, later state, and shutdown/drain receipts",
        },
    }


def build_expected() -> bytes:
    return counter_model.derive_complete().encode("utf-8")


def _selftest() -> dict:
    basis = current_basis()
    if not BASIS_PATH.is_file():
        raise SystemExit("SOURCE-BASIS.json missing; run derive.py --write first")
    saved = json.loads(BASIS_PATH.read_bytes())
    if canonical_json(saved) != canonical_json(basis):
        raise SystemExit("source/model/mutation pins do not match SOURCE-BASIS.json")

    counter_model._selftest()
    raw = build_expected()
    compressed = gzip.compress(raw, mtime=0)
    if not EXPECTED_PATH.is_file() or EXPECTED_PATH.read_bytes() != raw:
        raise SystemExit("expected.stdout differs from source-derived retirement-loss counter")
    if not GZIP_PATH.is_file() or GZIP_PATH.read_bytes() != compressed:
        raise SystemExit("expected.stdout.gz is not deterministic gzip of exact counter bytes")
    if gzip.decompress(GZIP_PATH.read_bytes()) != raw:
        raise SystemExit("counter gzip does not decompress to exact raw bytes")
    return {
        "status": "SOURCE_DERIVED_RETIREMENT_LOSS_COUNTER_SELFTEST_PASS",
        "bytes": len(raw),
        "sha256": sha256(raw),
        "gzipBytes": len(compressed),
        "gzipSha256": sha256(compressed),
        "mutantSourceCount": basis["mutation"]["sourceCount"],
        "changedSourceMembers": basis["mutation"]["sourceJoin"]["changed"],
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    parser.add_argument("--selftest", action="store_true")
    args = parser.parse_args()
    if args.write:
        basis = current_basis()
        raw = build_expected()
        BASIS_PATH.write_bytes(canonical_json(basis))
        EXPECTED_PATH.write_bytes(raw)
        GZIP_PATH.write_bytes(gzip.compress(raw, mtime=0))
    if args.selftest:
        print(json.dumps(_selftest(), sort_keys=True))
        return 0
    if not args.write:
        parser.error("choose --write or --selftest")
    raw = EXPECTED_PATH.read_bytes()
    zipped = GZIP_PATH.read_bytes()
    print(json.dumps({"status": "SOURCE_DERIVED_RETIREMENT_LOSS_COUNTER_WRITTEN",
                      "bytes": len(raw), "sha256": sha256(raw),
                      "gzipBytes": len(zipped), "gzipSha256": sha256(zipped)},
                     sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
