#!/usr/bin/env python3
"""Focused offline selftest for the current normal-scenario oracle."""
from __future__ import annotations

import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

import model


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> None:
    model.check_source_binding()
    raw = model.derive()
    raw_path = model.EXPECTED
    gz_path = model.EXPECTED_GZIP
    basis = json.loads((model.HERE / "SOURCE-BASIS.json").read_text())
    require(raw_path.read_bytes() == raw, "stored raw expected output differs from source model")
    require(gzip.decompress(gz_path.read_bytes()) == raw, "compressed output does not decode to raw model bytes")
    require(len(raw) == basis["expected"]["rawBytes"], "raw output length differs from source basis")
    require(hashlib.sha256(raw).hexdigest() == basis["expected"]["rawSha256"],
            "raw output hash differs from source basis")
    require(hashlib.sha256(gz_path.read_bytes()).hexdigest() == basis["expected"]["gzipSha256"],
            "gzip output hash differs from source basis")

    # Observable source-derived identity facts. Registry id 4 and reader id 1
    # intentionally remain distinct; nextReader is the post-registration value.
    require(raw.count(b"consumer.FailureView{consumer.RegistryView{1, 4, \"ParentFailures\"") == 11,
            "all eleven snapshots must retain failure system id 4 and reader id 1")
    require(raw.count(b"event-runtime.Position{1,") == 2,
            "both active event positions must use reader id 1")
    require(raw.count(b", [1]}") == 2,
            "active failure domains must use reader id 1")
    require(raw.count(b"65536n, 2, consumer.RegistryView") == 11,
            "all snapshots must expose nextReader=2 after the one successful registration")

    # The operation script and executable scenario suffix are unchanged from
    # the original qualified normal fixture; only copied import/snapshot code
    # and the newly exposed source identities differ.
    current_consumer = model.SCENARIO / "consumer.bend"
    old_consumer = model.ROOT / "experiments/public-relations/ordinary-reader-query-v1/consumer.bend"
    current = current_consumer.read_text()
    old = old_consumer.read_text()
    marker = "def write_result"
    require(current[current.index(marker):] == old[old.index(marker):],
            "normal operation suffix changed from the prior fixture")
    suffix_hash = hashlib.sha256(current[current.index(marker):].encode()).hexdigest()
    require(suffix_hash == basis["selectedScenario"]["unchangedScenarioSuffixSha256"],
            "normal operation suffix hash differs from source basis")
    require(hashlib.sha256((model.SCENARIO / "operations.bend").read_bytes()).hexdigest()
            == "676479b47e07b8f0d631b56b9858cfd8ee47f178689be8fe7b71b65507606457",
            "normal operation module hash drifted")
    print("PASS current-source normal oracle: 37 source pins, legacy baseline, identities, operations")


if __name__ == "__main__":
    main()
