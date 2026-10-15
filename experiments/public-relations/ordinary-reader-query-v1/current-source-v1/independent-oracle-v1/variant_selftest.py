#!/usr/bin/env python3
"""Offline checks for the current-source replacement/SystemFailure models."""
from __future__ import annotations

import gzip
import hashlib
import json
from pathlib import Path

import variant_model as model


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main() -> None:
    model.check_current_sources()
    basis = json.loads(model.BASIS.read_text())
    require(basis["sourceFreeze"]["sourceClosureRows"] == 37,
            "basis must bind the full current-source closure")
    require(sha(model.FREEZE.read_bytes()) == basis["sourceFreeze"]["sha256"],
            "source freeze hash differs from variant basis")

    for name, cfg in model.CONFIG.items():
        model.check_source_relationships(name)
        legacy = model.check_legacy_model(name)
        old_basis = basis["scenarios"][name]["legacyInputs"]
        require(sha(legacy) == old_basis["golden"]["sha256"],
                f"{name}: source model did not reproduce its prior golden")

        raw = model.derive(name)
        expected = (model.HERE / cfg["expectedRaw"]).read_bytes()
        compressed = (model.HERE / cfg["expectedGzip"]).read_bytes()
        expected_basis = basis["scenarios"][name]["expected"]
        require(raw == expected, f"{name}: stored source-derived bytes differ")
        require(gzip.decompress(compressed) == raw,
                f"{name}: deterministic gzip does not decode to the model bytes")
        require(len(raw) == expected_basis["rawBytes"],
                f"{name}: raw byte count differs from basis")
        require(sha(raw) == expected_basis["rawSha256"],
                f"{name}: raw hash differs from basis")
        require(sha(compressed) == expected_basis["gzipSha256"],
                f"{name}: gzip hash differs from basis")
        model.identity_counts(name, raw)

    # The prior reached clear-omitted mutation removes this exact supplied
    # callback. It is applicable to the replacement operation source site,
    # but this packet intentionally does not derive a current-source mutant
    # golden or claim a current-source mutation kill.
    mutant = basis["reachedMutantApplicability"]
    delta_path = model.ROOT / mutant["priorDelta"]["path"]
    delta = json.loads(delta_path.read_text())
    require(sha(delta_path.read_bytes()) == mutant["priorDelta"]["sha256"],
            "prior clear-omitted mutation delta pin changed")
    require(delta["old"] == mutant["mutatedOperation"],
            "prior mutation source does not identify the documented clear callback")
    replacement_ops = (model.CURRENT / "replacement-unrelate" / "operations.bend").read_text()
    system_ops = (model.CURRENT / "system-failure" / "operations.bend").read_text()
    require(mutant["mutatedOperation"] in replacement_ops,
            "current replacement operation no longer contains the reached mutation site")
    require(mutant["mutatedOperation"] in system_ops,
            "current SystemFailure operation no longer contains the clear callback form")
    require(mutant["currentSourceMutantOracle"].startswith("NOT_DERIVED"),
            "do not imply a current-source mutant expected output")

    print("PASS current-source variant oracles: 37 source rows, two legacy baselines, source suffixes, identities")


if __name__ == "__main__":
    main()
