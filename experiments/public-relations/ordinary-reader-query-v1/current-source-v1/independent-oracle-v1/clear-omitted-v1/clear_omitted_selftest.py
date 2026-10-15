#!/usr/bin/env python3
"""Offline revalidation for the current-source clear-omitted counter oracle."""
from __future__ import annotations

import gzip
import hashlib
import json
from pathlib import Path

import clear_omitted_model as model


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def require(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


def main() -> None:
    basis = model.check_source_and_mutation()
    raw = model.derive()
    expected_row = basis["currentCounterExpected"]
    expected_path = model.HERE / expected_row["path"]
    compressed_path = model.HERE / expected_row["gzipPath"]
    stored = expected_path.read_bytes()
    compressed = compressed_path.read_bytes()

    require(raw == stored, "stored counter stdout differs from the source model")
    require(gzip.decompress(compressed) == raw, "deterministic gzip differs from raw model bytes")
    require(len(raw) == expected_row["bytes"], "counter byte count differs from basis")
    require(sha(raw) == expected_row["sha256"], "counter raw hash differs from basis")
    require(sha(compressed) == expected_row["gzipSha256"], "counter gzip hash differs from basis")

    baseline = model.derive_current_baseline()
    baseline_row = basis["currentBaseline"]
    require(len(baseline) == baseline_row["bytes"], "current baseline byte count changed")
    require(sha(baseline) == baseline_row["sha256"], "current baseline raw hash changed")
    require(raw != baseline, "clear-omitted counter failed to distinguish current replacement baseline")
    model.check_identity_counts(raw)

    # The omitted callback leaves the selected relation edge in place across
    # the two clear operations, whereas the current replacement baseline clears it.
    require(raw.count(b"[2:Parent:Children:hierarchy:2>3]") >
            baseline.count(b"[2:Parent:Children:hierarchy:2>3]"),
            "counter did not retain the relation through the omitted clear callback")

    print("PASS current-source clear-omitted counter: 37 frozen sources, reached callback substitution, current IDs, full output differs from baseline")


if __name__ == "__main__":
    main()
