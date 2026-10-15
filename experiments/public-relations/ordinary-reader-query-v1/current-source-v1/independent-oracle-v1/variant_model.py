"""Source-derived current-source oracles for replacement and SystemFailure.

Each current result reuses the selected earlier finite model after checking its
legacy golden, then applies only the identity fields exposed by the frozen
current consumer: reader id 1 is distinct from failure-system registry id 4,
and nextReader is 2 after successful registration. No runtime outputs are read.
"""
from __future__ import annotations

import gzip
import hashlib
import json
import os
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
CURRENT = HERE.parent
FREEZE = CURRENT / "SOURCE-FREEZE.json"
BASIS = HERE / "VARIANT-SOURCE-BASIS.json"

CONFIG = {
    "replacement": {
        "scenario": "replacement-unrelate",
        "entry": "entry-garden.bend",
        "legacyModel": "experiments/public-relations/ordinary-reader-query-mutation-oracle-v1/model.py.source",
        "legacyModelSha256": "771d3dbdbf2420d590f832029e3af878b91d2f644a4ca162e61c771a4c2dd3b5",
        "legacyGolden": "experiments/public-relations/ordinary-reader-query-mutation-oracle-v1/workshop-expected.stdout",
        "legacyGoldenSha256": "1ce022e4998752e065c16c35934a6090fa9e019ccf05d6f6cf7b4f5ef6641b26",
        "legacyScenario": "experiments/public-relations/ordinary-reader-query-v1/mutation-composition-v1",
        "legacyEntry": "entry-workshop.bend",
        "legacyFixture": "experiments/public-relations/ordinary-reader-query-v1/mutation-composition-v1/fixture.bend",
        "legacyFixtureSha256": "e8f413e4add7fcdc2e09bd1d9367c0b153046d3599b435c3adbc47f2cddf85b3",
        "legacyOperations": "experiments/public-relations/ordinary-reader-query-v1/mutation-composition-v1/operations.bend",
        "legacyOperationsSha256": "2b64fbe65eb968aac8bdc5c046b556f10311e5758d9ef9e88debd80852accf86",
        "legacyConsumer": "experiments/public-relations/ordinary-reader-query-v1/mutation-composition-v1/consumer.bend",
        "legacyConsumerSha256": "b5aa3a508fd82ee1e67ca3db2636812d97415186a0b4a006f9120a07b46d9903",
        "suffixSha256": "d299edd8e104bfb7b5aba2fffccf9d774bf1aa2bc28625a57287871eaf4d1788",
        "currentFixtureSha256": "f00d8efcda945533b737a1c320da550f50d69153e8b38480be10e20abb63fd49",
        "currentOperationsSha256": "87c0798be55e4cec277b76f2a1e885f5e051faac32365e52b3e67a9252261706",
        "currentConsumerSha256": "c53022cfd51977f377c912834dd5df60ed95cec85d4a2d36b6ead1077521e619",
        "expectedRaw": "replacement-expected.stdout",
        "expectedGzip": "replacement-expected.stdout.gz",
        "snapshotCount": 17,
        "activeReaderSnapshots": 2,
    },
    "system-failure": {
        "scenario": "system-failure",
        "entry": "entry-garden.bend",
        "legacyModel": "experiments/public-relations/ordinary-reader-query-system-failure-oracle-v1/model.py.source",
        "legacyModelSha256": "79cbb826fef3228a480c82f7b2a55b744f33c1e46a111d9089bebf02f800af48",
        "legacyGolden": "experiments/public-relations/ordinary-reader-query-system-failure-oracle-v1/workshop-expected.stdout",
        "legacyGoldenSha256": "34006c516f9583846dc1b671046f08af4ac69d252ac3237c80acb61c9d6881cf",
        "legacyScenario": "experiments/public-relations/ordinary-reader-query-v1/system-failure-v1",
        "legacyEntry": "entry-workshop.bend",
        "legacyFixture": "experiments/public-relations/ordinary-reader-query-v1/mutation-composition-v1/fixture.bend",
        "legacyFixtureSha256": "e8f413e4add7fcdc2e09bd1d9367c0b153046d3599b435c3adbc47f2cddf85b3",
        "legacyOperations": "experiments/public-relations/ordinary-reader-query-v1/system-failure-v1/operations.bend",
        "legacyOperationsSha256": "63674c8203ac977065997f20299fc32bac0bbb11f9e2c4abbaafccd1bfe96eb9",
        "legacyConsumer": "experiments/public-relations/ordinary-reader-query-v1/system-failure-v1/consumer.bend",
        "legacyConsumerSha256": "de657bb58706de3749891f0bceaf4a504761766e160ee6dc4d9d7d3db5a6a275",
        "suffixSha256": "d8977c3856c85720585b395b662a7be87854de129528be26214842e828a7eafb",
        "currentFixtureSha256": "f00d8efcda945533b737a1c320da550f50d69153e8b38480be10e20abb63fd49",
        "currentOperationsSha256": "701da6176d14d1826087aeecca591b268648265c143200666554be2804706091",
        "currentConsumerSha256": "6aa7b21d250aa54ba8b66576001d82e27ec188256a834e44f7a21ea901f43d78",
        "expectedRaw": "system-failure-expected.stdout",
        "expectedGzip": "system-failure-expected.stdout.gz",
        "snapshotCount": 10,
        "activeReaderSnapshots": 7,
    },
}


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def import_model(path: Path) -> dict:
    namespace: dict = {"__name__": "pinned_legacy_source_model"}
    code = compile(path.read_bytes(), str(path), "exec")
    exec(code, namespace)
    return namespace


def no_import_lines(path: Path) -> str:
    return "\n".join(line for line in path.read_text().splitlines()
                     if not line.startswith("import ")) + "\n"


def execution_suffix(path: Path) -> str:
    source = path.read_text()
    marker = "def write_result"
    if marker not in source:
        raise AssertionError(f"missing operation-suffix marker in {path}")
    return source[source.index(marker):]


def source_rows() -> dict[str, dict]:
    return {row["path"]: row for row in json.loads(FREEZE.read_text())["sourceClosure"]}


def check_current_sources() -> None:
    freeze = json.loads(FREEZE.read_text())
    if len(freeze["sourceClosure"]) != 37:
        raise AssertionError("current-source freeze must retain all 37 rows")
    for row in freeze["sourceClosure"]:
        data = (ROOT / row["path"]).read_bytes()
        if len(data) != row["bytes"] or sha(data) != row["sha256"]:
            raise AssertionError(f"current-source pin mismatch: {row['path']}")
    if sha(FREEZE.read_bytes()) != "c344b6b23ad0f228f418c88e29f5bcf0ee2c3a2eae070f7a88feefb9351998fc":
        raise AssertionError("current-source freeze changed")


def check_source_relationships(name: str) -> None:
    cfg = CONFIG[name]
    scenario = CURRENT / cfg["scenario"]
    old_scenario = ROOT / cfg["legacyScenario"]
    pins = {
        scenario / "fixture.bend": cfg["currentFixtureSha256"],
        scenario / "operations.bend": cfg["currentOperationsSha256"],
        scenario / "consumer.bend": cfg["currentConsumerSha256"],
        ROOT / cfg["legacyFixture"]: cfg["legacyFixtureSha256"],
        ROOT / cfg["legacyOperations"]: cfg["legacyOperationsSha256"],
        ROOT / cfg["legacyConsumer"]: cfg["legacyConsumerSha256"],
    }
    for path, expected in pins.items():
        if sha(path.read_bytes()) != expected:
            raise AssertionError(f"scenario source pin mismatch: {path}")
    if no_import_lines(scenario / "fixture.bend") != no_import_lines(ROOT / cfg["legacyFixture"]):
        raise AssertionError(f"{name}: fixture bodies differ beyond import relocation")
    if no_import_lines(scenario / "operations.bend") != no_import_lines(ROOT / cfg["legacyOperations"]):
        raise AssertionError(f"{name}: operation bodies differ beyond import relocation")
    current_suffix = execution_suffix(scenario / "consumer.bend")
    old_suffix = execution_suffix(ROOT / cfg["legacyConsumer"])
    if current_suffix != old_suffix or sha(current_suffix.encode()) != cfg["suffixSha256"]:
        raise AssertionError(f"{name}: complete executable consumer suffix changed")
    old_entry = old_scenario / cfg["legacyEntry"]
    current_entry = scenario / cfg["entry"]
    old_main = no_import_lines(old_entry).split("def main", 1)[1]
    current_main = no_import_lines(current_entry).split("def main", 1)[1]
    old_main = old_main.replace("F.Workshop", "F.Garden")
    if current_main != old_main:
        raise AssertionError(f"{name}: selected current entrypoint does not call the same generic scenario")


def check_legacy_model(name: str) -> bytes:
    cfg = CONFIG[name]
    model_path = ROOT / cfg["legacyModel"]
    golden_path = ROOT / cfg["legacyGolden"]
    model_bytes = model_path.read_bytes()
    golden = golden_path.read_bytes()
    if sha(model_bytes) != cfg["legacyModelSha256"]:
        raise AssertionError(f"{name}: selected legacy model source changed")
    if sha(golden) != cfg["legacyGoldenSha256"]:
        raise AssertionError(f"{name}: selected legacy golden changed")
    legacy = import_model(model_path)
    raw = legacy["derive"]()
    if raw != golden:
        raise AssertionError(f"{name}: unmodified legacy model no longer reproduces its pinned golden")
    return raw


def derive_current(name: str) -> bytes:
    cfg = CONFIG[name]
    namespace = import_model(ROOT / cfg["legacyModel"])
    namespace["ROOT"] = ROOT
    namespace["ENTRY"] = CURRENT / cfg["scenario"]
    original_ctor = namespace["ctor"]

    def current_ctor(module: str, ctor_name: str, *fields: str) -> str:
        values = list(fields)
        if module == "internal/relation-failures/domains" and ctor_name == "Domain":
            if values and values[-1] == "[4]":
                values[-1] = "[1]"
        if module == "event-runtime" and ctor_name == "Position":
            if values and values[0] == "4":
                values[0] = "1"
        if module == "consumer" and ctor_name == "Snapshot":
            if len(values) != 12:
                raise AssertionError(f"{name}: legacy Snapshot shape changed ({len(values)} fields)")
            values.insert(8, "2")
        return original_ctor(module, ctor_name, *values)

    def current_reg(system_id: int, system_name: str, access: str, cursor: int) -> str:
        registry = original_ctor(
            "consumer", "RegistryView", "1", str(system_id), namespace["st"](system_name),
            namespace["ls"]([namespace["st"](access)]), str(cursor),
        )
        if system_name == "ParentFailures":
            return original_ctor("consumer", "FailureView", registry, "1")
        return registry

    namespace["ctor"] = current_ctor
    namespace["reg"] = current_reg
    # The legacy model precomputes these names on import. Rebind them after
    # changing the entrypoint so all QNames use current-source import depth.
    namespace["ORIGINAL"] = current_ctor("relation-commands", "Original", "99")
    namespace["CYCLE"] = namespace["failure"](1, 2, "HierarchyCycle", 1, 2, "Parent")
    namespace["SELF"] = namespace["failure"](3, 3, "SelfRelationNotAllowed", 3, "Parent")
    namespace["MISSING"] = namespace["failure"](2, 99, "MissingTargetEntity", 2, 99, "Parent")
    return namespace["derive"]()


def identity_counts(name: str, raw: bytes) -> None:
    cfg = CONFIG[name]
    snapshots = cfg["snapshotCount"]
    active = cfg["activeReaderSnapshots"]
    if raw.count(b"consumer.Snapshot{") != snapshots:
        raise AssertionError(f"{name}: unexpected snapshot count")
    if raw.count(b'consumer.FailureView{consumer.RegistryView{1, 4, "ParentFailures"') != snapshots:
        raise AssertionError(f"{name}: failure registry/reader split is not preserved in every snapshot")
    if raw.count(b"event-runtime.Position{1,") != active:
        raise AssertionError(f"{name}: event Position count does not use reader id 1")
    if raw.count(b", [1]}") != active:
        raise AssertionError(f"{name}: active failure Domain membership count does not use reader id 1")
    if raw.count(b", 2, consumer.RegistryView") != snapshots:
        raise AssertionError(f"{name}: nextReader=2 is not present in each snapshot")


def derive(name: str) -> bytes:
    if name not in CONFIG:
        raise ValueError(f"unknown scenario {name!r}")
    check_current_sources()
    check_source_relationships(name)
    check_legacy_model(name)
    raw = derive_current(name)
    identity_counts(name, raw)
    return raw


def write_outputs() -> dict:
    results = {}
    for name, cfg in CONFIG.items():
        raw = derive(name)
        gz = gzip.compress(raw, mtime=0)
        (HERE / cfg["expectedRaw"]).write_bytes(raw)
        (HERE / cfg["expectedGzip"]).write_bytes(gz)
        results[name] = {
            "rawPath": cfg["expectedRaw"], "rawBytes": len(raw), "rawSha256": sha(raw),
            "gzipPath": cfg["expectedGzip"], "gzipSha256": sha(gz),
        }
    return results


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    parser.add_argument("scenario", nargs="?", choices=tuple(CONFIG))
    args = parser.parse_args()
    if args.write:
        print(json.dumps(write_outputs(), sort_keys=True, indent=2))
    elif args.scenario:
        import sys
        sys.stdout.buffer.write(derive(args.scenario))
    else:
        parser.error("choose --write or a scenario")
