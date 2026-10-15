#!/usr/bin/env python3
"""Source-derived current replacement counter for the omitted clear callback.

This reuses the selected clear-control finite state model after reproducing its
two historical goldens, then applies the current-source FailureView/reader-ID
mapping already checked by variant_model.py. No runtime output is an input.
"""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
VARIANT_DIR = HERE.parent
CURRENT = VARIANT_DIR.parent
ROOT = VARIANT_DIR.parents[4]
CLEAR_CONTROLS = ROOT / "experiments/public-relations/ordinary-reader-query-clear-controls-oracle-v1"
LEGACY_SCENARIO = ROOT / "experiments/public-relations/ordinary-reader-query-v1/mutation-composition-v1/controls-v1"
SOURCE_BASIS = HERE / "CLEAR-OMITTED-BASIS.json"

CALLBACK_OLD = "case P.Writable{_,_,Cap.Request{clear}}:clear(owner,source)"
CALLBACK_NEW = "case P.Writable{_,_,Cap.Request{_}}:(owner,A.Queued{})"


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def load_module_source(path: Path, name: str) -> dict:
    namespace: dict = {"__name__": name, "__file__": str(path)}
    exec(compile(path.read_bytes(), str(path), "exec"), namespace)
    return namespace


def source_without_imports(path: Path) -> str:
    return "\n".join(line for line in path.read_text().splitlines()
                     if not line.startswith("import ")) + "\n"


def entry_body(path: Path) -> str:
    text = source_without_imports(path)
    if "def main" not in text:
        raise AssertionError(f"entrypoint lacks main: {path}")
    return text.split("def main", 1)[1]


def current_paths() -> dict[str, Path]:
    replacement = CURRENT / "replacement-unrelate"
    legacy_clear = LEGACY_SCENARIO / "clear-omitted"
    return {
        "currentEntry": replacement / "entry-garden.bend",
        "currentFixture": replacement / "fixture.bend",
        "currentOperations": replacement / "operations.bend",
        "currentConsumer": replacement / "consumer.bend",
        "legacyEntry": legacy_clear / "entry-workshop.bend",
        "legacyFixture": legacy_clear / "fixture.bend",
        "legacyOperations": legacy_clear / "operations.bend",
        "legacyConsumer": legacy_clear / "consumer.bend",
        "delta": LEGACY_SCENARIO / "DELTA.json",
        "legacyModel": CLEAR_CONTROLS / "model.py.source",
        "legacyNormal": CLEAR_CONTROLS / "namespace-normal-expected.stdout",
        "legacyOmitted": CLEAR_CONTROLS / "clear-omitted-expected.stdout",
    }


def bind_current_identities(model: dict) -> None:
    """Use the already reviewed current-source identity mapping, no new IDs."""
    model["ROOT"] = ROOT
    # The current-source variant model uses this virtual top-level entry path
    # for the same import namespace emitted by the nested replacement entry.
    model["ENTRY"] = CURRENT / "entry-garden.bend"
    original_ctor = model["ctor"]

    def current_ctor(module: str, name: str, *fields: str) -> str:
        values = list(fields)
        if module == "internal/relation-failures/domains" and name == "Domain":
            if values and values[-1] == "[4]":
                values[-1] = "[1]"
        if module == "event-runtime" and name == "Position":
            if values and values[0] == "4":
                values[0] = "1"
        if module == "consumer" and name == "Snapshot":
            if len(values) != 12:
                raise AssertionError(f"legacy Snapshot shape changed ({len(values)} fields)")
            values.insert(8, "2")
        return original_ctor(module, name, *values)

    def current_registry(system_id: int, name: str, access: str, cursor: int) -> str:
        registry = original_ctor(
            "consumer", "RegistryView", "1", str(system_id), model["st"](name),
            model["ls"]([model["st"](access)]), str(cursor),
        )
        if name == "ParentFailures":
            return original_ctor("consumer", "FailureView", registry, "1")
        return registry

    model["ctor"] = current_ctor
    model["reg"] = current_registry
    model["ORIGINAL"] = current_ctor("relation-commands", "Original", "99")
    model["CYCLE"] = model["failure"](1, 2, "HierarchyCycle", 1, 2, "Parent")
    model["SELF"] = model["failure"](3, 3, "SelfRelationNotAllowed", 3, "Parent")
    model["MISSING"] = model["failure"](2, 99, "MissingTargetEntity", 2, 99, "Parent")


def check_source_and_mutation() -> dict:
    # This function's full 37-row source check also validates the current entry,
    # fixture, operations, consumer, and all imported ECS modules.
    sys.path.insert(0, str(VARIANT_DIR))
    import variant_model

    variant_model.check_current_sources()
    variant_model.check_source_relationships("replacement")
    p = current_paths()
    basis = json.loads(SOURCE_BASIS.read_text())

    for key, row in basis["sourcePins"].items():
        path = ROOT / row["path"]
        data = path.read_bytes()
        if len(data) != row["bytes"] or sha(data) != row["sha256"]:
            raise AssertionError(f"source pin changed: {key}: {path}")

    delta = json.loads(p["delta"].read_text())
    location = basis["callbackMutation"]
    delta_pin = location["historicalDeltaSha256"]
    if sha(p["delta"].read_bytes()) != delta_pin:
        raise AssertionError("historical clear-omitted mutation delta changed")
    if delta["old"] != CALLBACK_OLD or delta["new"] != CALLBACK_NEW:
        raise AssertionError("historical mutation does not identify the supplied clear callback")

    legacy_source = p["legacyModel"].read_bytes()
    if sha(legacy_source) != basis["historicalModel"]["sha256"]:
        raise AssertionError("historical clear-controls model changed")
    historical = load_legacy_model()
    historical_normal = historical["derive"]()
    historical_omitted = historical["derive"](omitted=True)
    for name, raw in (("normal", historical_normal), ("clearOmitted", historical_omitted)):
        expected_path = p["legacyNormal"] if name == "normal" else p["legacyOmitted"]
        expected_row = basis["historicalOutputs"][name]
        expected = expected_path.read_bytes()
        if len(expected) != expected_row["bytes"] or sha(expected) != expected_row["sha256"]:
            raise AssertionError(f"historical {name} model output pin changed")
        if raw != expected:
            raise AssertionError(f"historical model no longer reproduces {name} output")

    current_ops = p["currentOperations"].read_text()
    if current_ops.count(CALLBACK_OLD) != 1:
        raise AssertionError("current replacement callback site is absent or ambiguous")
    lines = current_ops.splitlines()
    if lines[location["line"] - 1].strip() != CALLBACK_OLD:
        raise AssertionError("current callback is no longer at the pinned source line")
    synthetic_mutant = current_ops.replace(CALLBACK_OLD, CALLBACK_NEW, 1)
    mutant_hash = sha(synthetic_mutant.encode())
    expected_mutant_hash = location["syntheticCurrentOperationsSha256"]
    if mutant_hash != expected_mutant_hash:
        raise AssertionError("synthetic current-source mutation bytes changed")

    legacy_mutant_ops = source_without_imports(p["legacyOperations"])
    if "\n".join(line for line in synthetic_mutant.splitlines()
                   if not line.startswith("import ")) + "\n" != legacy_mutant_ops:
        raise AssertionError("current callback replacement differs from the selected reached mutation")
    if source_without_imports(p["currentFixture"]) != source_without_imports(p["legacyFixture"]):
        raise AssertionError("current replacement fixture differs beyond import relocation")
    current_suffix = p["currentConsumer"].read_text().split("def write_result", 1)[1]
    legacy_suffix = p["legacyConsumer"].read_text().split("def write_result", 1)[1]
    if current_suffix != legacy_suffix:
        raise AssertionError("current replacement execution suffix differs from reached control")
    if entry_body(p["currentEntry"]).replace("F.Garden", "F.Workshop") != entry_body(p["legacyEntry"]):
        raise AssertionError("current replacement entrypoint does not preserve the selected scenario call")

    consumer = p["currentConsumer"].read_text()
    # The consumer supplies the Clear operation twice; writer routes Clear to
    # clear_body, which reaches clear_live's supplied Request branch.
    if consumer.count("O.Clear{W.Handle{1,2}}") != 2:
        raise AssertionError("the replacement scenario no longer reaches two clear calls")
    if "case Clear{+source}:staged(" not in current_ops or "~clear_body(~S)" not in current_ops:
        raise AssertionError("writer no longer routes Clear through the callback body")
    if "case P.Targets{source,_}:clear_live(H,S,caps,owner,source)" not in current_ops:
        raise AssertionError("clear_body no longer reaches clear_live")

    return basis


def load_legacy_model() -> dict:
    path = current_paths()["legacyModel"]
    return load_module_source(path, "pinned_clear_controls_model")


def derive_current_counter() -> bytes:
    check_source_and_mutation()
    legacy = load_legacy_model()
    bind_current_identities(legacy)
    return legacy["derive"](omitted=True)


def derive_current_baseline() -> bytes:
    sys.path.insert(0, str(VARIANT_DIR))
    import variant_model
    return variant_model.derive("replacement")


def check_identity_counts(raw: bytes) -> None:
    snapshots = 17
    active = 2
    if raw.count(b"consumer.Snapshot{") != snapshots:
        raise AssertionError("counter has unexpected current-source snapshot count")
    if raw.count(b'consumer.FailureView{consumer.RegistryView{1, 4, "ParentFailures"') != snapshots:
        raise AssertionError("failure registry/reader identities are not split in every snapshot")
    if raw.count(b"event-runtime.Position{1,") != active:
        raise AssertionError("active Position does not use the current failure reader ID")
    if raw.count(b", [1]}") != active:
        raise AssertionError("active Domain membership does not use the current failure reader ID")
    if raw.count(b", 2, consumer.RegistryView") != snapshots:
        raise AssertionError("nextReader=2 is missing from a current-source snapshot")


def derive() -> bytes:
    raw = derive_current_counter()
    check_identity_counts(raw)
    return raw


if __name__ == "__main__":
    sys.stdout.buffer.write(derive())
