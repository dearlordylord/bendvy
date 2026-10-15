"""Source-derived ordinary-reader oracle for the frozen current-source fixture.

This reuses the earlier finite normal-scenario model, after first checking that
it still reproduces its original golden.  The only model changes represent the
current source's distinct system registry identity and failure-reader identity,
and the newly observed nextReader field.  No candidate/runtime output is read.
"""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import sys


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SCENARIO = HERE.parent / "normal"
FREEZE = HERE.parent / "SOURCE-FREEZE.json"
BASE_MODEL = HERE / "base-model.py.source"
OLD_MODEL = ROOT / "experiments/public-relations/ordinary-reader-query-oracle-v1/model.py.source"
OLD_GOLDEN = ROOT / "experiments/public-relations/ordinary-reader-query-oracle-v1/workshop-expected.stdout"
EXPECTED = HERE / "normal-expected.stdout"
EXPECTED_GZIP = HERE / "normal-expected.stdout.gz"


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def load_base(entry: Path | None = None) -> dict:
    namespace: dict = {"__name__": "independent_frozen_model"}
    exec(compile(BASE_MODEL.read_bytes(), str(BASE_MODEL), "exec"), namespace)
    if entry is not None:
        namespace["ROOT"] = ROOT
        namespace["ENTRY"] = entry
    return namespace


def derive_legacy() -> bytes:
    namespace = load_base()
    return namespace["derive"]()


def derive_current() -> bytes:
    ns = load_base(SCENARIO)
    original_ctor = ns["ctor"]

    def current_ctor(module: str, name: str, *fields: str) -> str:
        values = list(fields)
        # The failure Runtime reader has its own allocator identity.  System
        # registry identity 4 remains the registry cursor/ownership identity.
        if module == "internal/relation-failures/domains" and name == "Domain":
            if values and values[-1] == "[4]":
                values[-1] = "[1]"
        if module == "event-runtime" and name == "Position":
            if values and values[0] == "4":
                values[0] = "1"
        if module == "consumer" and name == "Snapshot":
            if len(values) != 12:
                raise AssertionError(f"legacy Snapshot model shape changed: {len(values)}")
            values.insert(8, "2")
        return original_ctor(module, name, *values)

    def current_reg(i: int, name: str, access: str, cursor: int) -> str:
        registry = original_ctor(
            "consumer", "RegistryView", "1", str(i), ns["st"](name),
            ns["ls"]([ns["st"](access)]), str(cursor),
        )
        if name == "ParentFailures":
            return original_ctor("consumer", "FailureView", registry, "1")
        return registry

    ns["ctor"] = current_ctor
    ns["reg"] = current_reg
    # The prior model cached these constructor strings while it was imported,
    # before ROOT/ENTRY were rebound. Recompute them for the frozen current
    # entrypoint so module labels come from this source layout.
    ns["ORIGINAL"] = current_ctor("relation-commands", "Original", "99")
    ns["CYCLE"] = ns["failure"](1, 2, "HierarchyCycle", 1, 2, "Parent")
    ns["SELF"] = ns["failure"](3, 3, "SelfRelationNotAllowed", 3, "Parent")
    ns["MISSING"] = ns["failure"](2, 99, "MissingTargetEntity", 2, 99, "Parent")
    return ns["derive"]()


def check_source_binding() -> None:
    freeze = json.loads(FREEZE.read_text())
    rows = freeze["sourceClosure"]
    if len(freeze["sourceClosure"]) != 37:
        raise AssertionError("current source freeze must retain all 37 source rows")
    for row in rows:
        path = ROOT / row["path"]
        data = path.read_bytes()
        if len(data) != row["bytes"] or sha(data) != row["sha256"]:
            raise AssertionError(f"source pin mismatch: {row['path']}")
    model_bytes = BASE_MODEL.read_bytes()
    if sha(model_bytes) != "5d930f0cf5a6e98a7e3e05061cee413fb65c9764143be84198d1e6e91c589ec7":
        raise AssertionError("reused normal model source changed")
    if sha(OLD_MODEL.read_bytes()) != sha(model_bytes):
        raise AssertionError("copied baseline model differs from its pinned source")
    old = derive_legacy()
    if sha(old) != "0e61dbb4d63953254e186e6bfae7035abfb360a27eafc38a6702dc5d13b2d519":
        raise AssertionError("legacy model no longer reproduces its pinned golden")
    if old != OLD_GOLDEN.read_bytes():
        raise AssertionError("legacy model output differs from original golden")


def derive() -> bytes:
    check_source_binding()
    output = derive_current()
    # These assertions pin the distinction that motivated the current model:
    # the failure registry is 4, its independent reader is 1, and nextReader is 2.
    if b'consumer.FailureView{consumer.RegistryView{1, 4, "ParentFailures", ["Parent:read"]' not in output:
        raise AssertionError("failure view lost the current registry/reader identity split")
    if b"domains.Domain{" not in output or b"domains.DeclaredKey{2}" not in output:
        raise AssertionError("current failure-domain output is missing")
    if b"event-runtime.Position{1," not in output:
        raise AssertionError("failure event position does not use the independent reader id")
    if b"65536n, 2, consumer.RegistryView" not in output:
        raise AssertionError("snapshot nextReader did not retain the post-registration cursor")
    return output


def main() -> None:
    output = derive()
    if len(sys.argv) > 1 and sys.argv[1] == "--write":
        import gzip
        EXPECTED.write_bytes(output)
        EXPECTED_GZIP.write_bytes(gzip.compress(output, mtime=0))
    else:
        sys.stdout.buffer.write(output)


if __name__ == "__main__":
    main()
