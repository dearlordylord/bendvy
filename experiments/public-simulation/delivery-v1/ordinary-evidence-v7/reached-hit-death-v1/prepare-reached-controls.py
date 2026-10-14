"""Prepare source-pinned hit/death omission controls from ordinary v7 inputs.

This is a preparation-only helper. It copies the exact current full stage,
changes one event-send expression in each private copy, and derives the two
counter-oracles by removing only that event constructor from the independent
normal oracle. It never launches Bend, Node, Clang, or a consumer.
"""
import copy
import gzip
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import tarfile

HERE = Path(__file__).resolve().parent
V7 = HERE.parent
TEMPLATE = V7 / "plan.json"
STAGE_ROOT = Path("/tmp/bendvy63-ordinary-delivery-stage-v7")
NORMAL_OUT = Path("/tmp/bendvy63-ordinary-delivery-v7")
VARIANT_ROOT = Path("/tmp/bendvy63-reached-hit-death-source-v1")
OUTPUT_ROOT = Path("/tmp/bendvy63-reached-hit-death-v1")
ARCHIVE = HERE / "variant-stages.tar.gz"
MUTATION_MAP = HERE / "mutation-source-map.json"
ORACLE = Path("/workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/independent-expected.json")
NORMAL_RECEIPT = NORMAL_OUT / "receipt.json"
PARSER = Path("/workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/parse-report.py")

RELATIVE_SOURCE = "experiments/public-simulation/bend-v1/damage-body.bend"
MUTATIONS = {
    "omit-hit": {
        "target": "events.bend::SimulationHit",
        "operation": "hit_health",
        "old": "Cap.send(~H,~Events.SimulationEvent,~events_cap(~S,~H,ops),ctx,Events.SimulationHit{id,damage})",
        "new": "ctx",
        "reason": "Remove only the reached SimulationHit publication; the consumed owner is passed unchanged to died().",
    },
    "omit-death": {
        "target": "events.bend::SimulationDeath",
        "operation": "died",
        "old": "Cap.action(~H,~despawn_cap(~S,~H,ops),Cap.send(~H,~Events.SimulationEvent,~events_cap(~S,~H,ops),ctx,Events.SimulationDeath{id}))",
        "new": "Cap.action(~H,~despawn_cap(~S,~H,ops),ctx)",
        "reason": "Remove only the reached SimulationDeath publication; retain the surrounding despawn action and pass its consumed owner unchanged.",
    },
}


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read_regular(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file():
        raise ValueError(f"expected regular input: {path}")
    return path.read_bytes()


def dump_json(value):
    return (json.dumps(value, indent=2, ensure_ascii=False) + "\n").encode()


def strict(value):
    if isinstance(value, dict):
        return ("dict", tuple((key, strict(item)) for key, item in sorted(value.items())))
    if isinstance(value, list):
        return ("list", tuple(strict(item) for item in value))
    return (type(value).__name__, value)


def omit_event(value, target):
    if isinstance(value, list):
        return [omit_event(item, target) for item in value
                if not (isinstance(item, dict) and value_constructor(item) == target)]
    if isinstance(value, dict):
        return {key: omit_event(item, target) for key, item in value.items()}
    return value


def value_constructor(value):
    return value.get("constructor") if set(value) == {"constructor", "fields"} else None


def count_constructor(value, target):
    if isinstance(value, list):
        return sum(count_constructor(item, target) for item in value)
    if isinstance(value, dict):
        here = int(value_constructor(value) == target)
        return here + sum(count_constructor(item, target) for item in value.values())
    return 0


def normalize(value, literal_to_neutral):
    if isinstance(value, list):
        return [normalize(item, literal_to_neutral) for item in value]
    if isinstance(value, dict):
        if set(value) == {"constructor", "fields"}:
            return {"constructor": literal_to_neutral[value["constructor"]],
                    "fields": normalize(value["fields"], literal_to_neutral)}
        if set(value) == {"nat"}:
            return {"nat": value["nat"]}
        raise ValueError("unexpected parsed report shape")
    return value


def load_parser(path):
    namespace = {"__name__": "reached_control_report_parser"}
    source = read_regular(path)
    exec(compile(source, str(path), "exec"), namespace)
    return namespace


def archive_stages(stage_paths):
    tar_buffer = io.BytesIO()
    with tarfile.open(fileobj=tar_buffer, mode="w") as archive:
        for role, stage in sorted(stage_paths.items()):
            for path in sorted(stage.rglob("*")):
                if path.is_symlink():
                    raise ValueError("variant stage symlink refused")
                if not path.is_file():
                    continue
                relative = PurePosixPath("stages") / role / path.relative_to(stage).as_posix()
                data = read_regular(path)
                info = tarfile.TarInfo(relative.as_posix())
                info.size = len(data)
                info.mode = 0o644
                info.mtime = 0
                info.uid = info.gid = 0
                info.uname = info.gname = ""
                archive.addfile(info, io.BytesIO(data))
    ARCHIVE.write_bytes(gzip.compress(tar_buffer.getvalue(), compresslevel=9, mtime=0))


def prepare():
    for destination in (VARIANT_ROOT, OUTPUT_ROOT):
        if destination.exists() or destination.is_symlink():
            raise ValueError(f"refusing to reuse prior path: {destination}")
    for destination in (ARCHIVE, MUTATION_MAP, HERE / "plan.json", HERE / "counter-oracle-hit.json", HERE / "counter-oracle-death.json"):
        if destination.exists() or destination.is_symlink():
            raise ValueError(f"refusing to overwrite prepared evidence: {destination}")

    base_plan_raw = read_regular(TEMPLATE)
    base_plan = json.loads(base_plan_raw)
    if base_plan.get("scope") != "Current-root full 106-source stage; complete relocated simulation JS/Native plus pinned TS semantic consumer; no timing/full-parity claim.":
        raise ValueError("ordinary v7 source plan scope changed")
    if base_plan.get("stageRoot") != str(STAGE_ROOT):
        raise ValueError("ordinary v7 stage binding changed")
    normal_receipt_raw = read_regular(NORMAL_RECEIPT)
    normal_receipt = json.loads(normal_receipt_raw)
    if normal_receipt.get("planSHA256") != sha(base_plan_raw):
        raise ValueError("ordinary v7 receipt is not bound to the selected plan")
    if normal_receipt.get("status") != "RELOCATED_SIMULATION_SEMANTIC_DELIVERY_PASS_NOT_TIMING_OR_FULL_PARITY":
        raise ValueError("ordinary v7 full-consumer evidence is not a pass")
    command_by_label = {row["label"]: row for row in normal_receipt["commands"]}
    for label in ("source", "TS", "JS-emit", "JS-run", "Native-emit", "Native-clang", "Native-run"):
        row = command_by_label[label]
        if row.get("exit") != 0 or row.get("failure") is not None or row.get("stderr", {}).get("bytes") != 0:
            raise ValueError(f"ordinary v7 command did not pass cleanly: {label}")
    if normal_receipt.get("cases", {}).get("JS-run", {}).get("fullOracleSHA256") != base_plan["oracleSHA256"]:
        raise ValueError("ordinary v7 JS full oracle binding changed")
    if normal_receipt.get("cases", {}).get("Native-run", {}).get("fullOracleSHA256") != base_plan["oracleSHA256"]:
        raise ValueError("ordinary v7 Native full oracle binding changed")
    if normal_receipt.get("cases", {}).get("TS", {}).get("completeMatch") is not True:
        raise ValueError("ordinary v7 TS evidence is not complete")

    source_manifest = json.loads(read_regular(STAGE_ROOT / "stage.json"))
    stage_files = {str(path.relative_to(STAGE_ROOT)): path
                   for path in STAGE_ROOT.rglob("*") if path.is_file() and not path.is_symlink()}
    if set(stage_files) != set(base_plan["stagePins"]):
        raise ValueError("ordinary v7 stage file membership drift")
    for relative, expected in base_plan["stagePins"].items():
        if sha(read_regular(stage_files[relative])) != expected:
            raise ValueError(f"ordinary v7 source drift: {relative}")
    if source_manifest.get("sourceAudit", {}).get("sourceCount") != 106 or source_manifest.get("sourceAudit", {}).get("reachableCount") != 51:
        raise ValueError("ordinary v7 full-stage closure changed")

    normal_raw = read_regular(ORACLE)
    if sha(normal_raw) != base_plan["oracleSHA256"]:
        raise ValueError("independent normal oracle pin changed")
    normal_oracle = json.loads(normal_raw)
    if value_constructor(normal_oracle) != "main.bend::TwoSchemaReport" or len(normal_oracle["fields"]) != 2 or any(len(schema) != 14 for schema in normal_oracle["fields"]):
        raise ValueError("independent full oracle shape changed")
    parser = load_parser(PARSER)
    stage_mapper = base_plan["constructorJoins"]
    if len(stage_mapper) != 32 or len(set(stage_mapper)) != 32:
        raise ValueError("ordinary constructor join changed")
    raw_normal_js = read_regular(NORMAL_OUT / "JS-run.stdout")
    raw_normal_native = read_regular(NORMAL_OUT / "Native-run.stdout")
    raw_normal_ts = read_regular(NORMAL_OUT / "TS.stdout")
    for label, raw in (("JS-run", raw_normal_js), ("Native-run", raw_normal_native)):
        row = command_by_label[label]
        if row["stdout"]["sha256"] != sha(raw) or row["stdout"]["bytes"] != len(raw):
            raise ValueError(f"ordinary v7 retained output receipt join changed: {label}")
        parsed = parser["parse"](raw.decode())
        if parser["render"](parsed) != raw.decode().strip():
            raise ValueError(f"ordinary v7 retained output does not roundtrip: {label}")
        if strict(normalize(parsed, stage_mapper)) != strict(normal_oracle):
            raise ValueError(f"ordinary v7 retained output differs from normal oracle: {label}")
    if raw_normal_js != raw_normal_native:
        raise ValueError("ordinary v7 JS/Native complete stdout differ")
    if command_by_label["TS"]["stdout"]["sha256"] != sha(raw_normal_ts):
        raise ValueError("ordinary v7 retained TS output receipt join changed")

    VARIANT_ROOT.mkdir(mode=0o700)
    stage_paths = {}
    mutations = {}
    stage_manifest_sha = sha(read_regular(STAGE_ROOT / "stage.json"))
    for role, detail in MUTATIONS.items():
        stage = VARIANT_ROOT / role
        shutil.copytree(STAGE_ROOT, stage, symlinks=False)
        for path in stage.rglob("*"):
            if path.is_symlink():
                raise ValueError("variant stage symlink refused")
        source = stage / RELATIVE_SOURCE
        base_source = STAGE_ROOT / RELATIVE_SOURCE
        original = read_regular(base_source)
        current = read_regular(source)
        if current != original or sha(original) != base_plan["stagePins"][RELATIVE_SOURCE]:
            raise ValueError("variant source does not start from the exact ordinary stage")
        old = detail["old"].encode()
        new = detail["new"].encode()
        if original.count(old) != 1:
            raise ValueError(f"expected exactly one reached mutation site: {role}")
        mutant = original.replace(old, new, 1)
        source.write_bytes(mutant)

        manifest_path = stage / "stage.json"
        manifest = json.loads(read_regular(manifest_path))
        manifest["scope"] = "Current-root v7 complete source stage with one named private event-send mutation; all other source bytes and import layout are retained."
        manifest["sources"][RELATIVE_SOURCE]["stagedSha256"] = sha(mutant)
        manifest["mutation"] = {
            "role": role,
            "source": RELATIVE_SOURCE,
            "operation": detail["operation"],
            "targetEvent": detail["target"],
            "baselineStageManifestSha256": stage_manifest_sha,
            "baselineSourceSha256": sha(original),
            "mutantSourceSha256": sha(mutant),
            "oldExpression": detail["old"],
            "newExpression": detail["new"],
        }
        manifest["sourceAudit"]["mutation"] = f"{role}: one event-send expression only; no other staged source changed"
        manifest_path.write_bytes(dump_json(manifest))

        counter = omit_event(normal_oracle, detail["target"])
        removed = count_constructor(normal_oracle, detail["target"])
        if removed == 0 or count_constructor(counter, detail["target"]) != 0:
            raise ValueError(f"independent normal model lacks reached target: {role}")
        other_target = "events.bend::SimulationDeath" if role == "omit-hit" else "events.bend::SimulationHit"
        if count_constructor(counter, other_target) != count_constructor(normal_oracle, other_target):
            raise ValueError(f"counter model removed another event: {role}")
        oracle_path = HERE / f"counter-oracle-{role.removeprefix('omit-')}.json"
        oracle_raw = dump_json(counter)
        oracle_path.write_bytes(oracle_raw)
        stage_paths[role] = stage
        mutations[role] = {
            **detail,
            "sourceRelativePath": RELATIVE_SOURCE,
            "baselineSourcePath": str((STAGE_ROOT / RELATIVE_SOURCE).resolve()),
            "mutantSourcePath": str(source.resolve()),
            "baselineSourceSha256": sha(original),
            "mutantSourceSha256": sha(mutant),
            "baselineStageManifestSha256": stage_manifest_sha,
            "mutantStageManifestPath": str(manifest_path.resolve()),
            "mutantStageManifestSha256": sha(read_regular(manifest_path)),
            "exactSourceOccurrencesRemoved": removed,
            "otherEventConstructor": other_target,
            "otherEventOccurrencesPreserved": count_constructor(counter, other_target),
            "counterOraclePath": str(oracle_path.resolve()),
            "counterOracleSha256": sha(oracle_raw),
            "derivation": "Recursively remove only list values whose constructor equals targetEvent from the separately pinned independent normal oracle; every other field, scalar, list order and constructor is preserved.",
        }

    archive_stages(stage_paths)
    mutation_map = {
        "scope": "Two source-current JS reached hit/death omission controls; no timing claim and no mutation of shared root sources.",
        "basePlanPath": str(TEMPLATE.resolve()),
        "basePlanSha256": sha(base_plan_raw),
        "baseStageRoot": str(STAGE_ROOT),
        "baseStageManifestSha256": stage_manifest_sha,
        "baseSourceCount": 106,
        "baseReachableCount": 51,
        "independentNormalOraclePath": str(ORACLE.resolve()),
        "independentNormalOracleSha256": sha(normal_raw),
        "constructorJoinCount": len(stage_mapper),
        "sourcePath": RELATIVE_SOURCE,
        "sourceObservationBasis": [
            "damage-body.hit_health publishes SimulationHit only through the single recorded Cap.send; replacing that expression with the same affine ctx removes that publication.",
            "damage-body.died publishes SimulationDeath only through the inner Cap.send; the mutation retains the surrounding Cap.action/despawn and returns the same affine ctx.",
            "event-runtime.sync_values obtains published values from W.events_view and appends only newly published values to batches; reader/snapshot outputs derive from those lists.",
            "The independent oracle is a complete two-schema, fourteen-phase report. Applying the single event-list omission to that oracle predicts all retained component, resource, allocation, reader cursor, queue, clock, action and other-event observations unchanged.",
        ],
        "ordinaryV7Evidence": {
            "receiptPath": str(NORMAL_RECEIPT.resolve()),
            "receiptSha256": sha(normal_receipt_raw),
            "receiptStatus": normal_receipt["status"],
            "outputs": {
                label: {"path": str((NORMAL_OUT / filename).resolve()), "sha256": sha(raw), "bytes": len(raw)}
                for label, filename, raw in (
                    ("TS", "TS.stdout", raw_normal_ts),
                    ("JS-run", "JS-run.stdout", raw_normal_js),
                    ("Native-run", "Native-run.stdout", raw_normal_native),
                )
            },
        },
        "mutations": mutations,
        "variantArchive": str(ARCHIVE.resolve()),
        "variantArchiveSha256": sha(read_regular(ARCHIVE)),
        "timingStatusCaveat": "The existing delivery collector uses REACHED_TIMING_SEQUENCE_CONTROLS_PASS_NOT_MEASUREMENT for every qualificationValidator plan. This inherited token is not the hit/death control verdict and does not claim timing measurement; actual controls are the exact full-oracle counter matches recorded by the validator.",
    }
    mutation_map_raw = dump_json(mutation_map)
    MUTATION_MAP.write_bytes(mutation_map_raw)

    plan = copy.deepcopy(base_plan)
    plan["scope"] = "Reuse the complete current v7 normal JS/Native/TS evidence, then run current-source JS full-consumer hit/death omission controls against independently derived complete counter-oracles; no timing or full parity claim."
    plan["timing"] = "No performance measurements; qualification is limited to reached event omission controls and their complete output oracles."
    plan["outputRoot"] = str(OUTPUT_ROOT)
    plan["commands"] = []
    for role in MUTATIONS:
        stage = stage_paths[role]
        main = str((stage / "experiments/public-simulation/bend-v1/main.bend").resolve())
        program = role + ".js"
        artifact = OUTPUT_ROOT / program
        bend = plan["toolConfiguration"]["tools"]["bend"]
        node = plan["toolConfiguration"]["tools"]["node"]
        taskset = plan["toolConfiguration"]["taskset"]
        prefix = [taskset, "-c", "5"]
        plan["commands"].extend([
            {"label": role + "-source", "argv": prefix + [bend, main, "--check-only"], "capSeconds": 5},
            {"label": role + "-JS-emit", "argv": prefix + [bend, main, "-o", str(artifact)], "capSeconds": 30, "emits": program},
            {"label": role + "-JS-run", "argv": prefix + [node, str(artifact)], "capSeconds": 5, "control": role},
        ])
    plan["qualificationValidator"] = str((HERE / "validate-reached-controls.py").resolve())
    plan["reachedHitDeath"] = {
        "mutationMap": str(MUTATION_MAP.resolve()),
        "mutationMapSha256": sha(mutation_map_raw),
        "controlRoles": list(MUTATIONS),
        "statusTokenCaveat": mutation_map["timingStatusCaveat"],
    }
    plan["normalBaseline"] = mutation_map["ordinaryV7Evidence"]
    plan["independentNormalOraclePath"] = str(ORACLE.resolve())

    new_inputs = [HERE / "prepare-reached-controls.py", HERE / "validate-reached-controls.py", MUTATION_MAP, ARCHIVE,
                  HERE / "counter-oracle-hit.json", HERE / "counter-oracle-death.json", NORMAL_RECEIPT,
                  TEMPLATE, ORACLE, PARSER,
                  NORMAL_OUT / "TS.stdout", NORMAL_OUT / "JS-run.stdout", NORMAL_OUT / "Native-run.stdout"]
    for stage in stage_paths.values():
        new_inputs.extend(path for path in stage.rglob("*") if path.is_file())
    pins = dict(plan["pins"])
    for path in new_inputs:
        absolute = str(path.resolve())
        pins[absolute] = sha(read_regular(path))
    plan["pins"] = pins
    plan["smallInputPaths"] = sorted(set(plan["smallInputPaths"]) | {str(path.resolve()) for path in new_inputs})
    plan["maximumProbeCommands"] = 140
    plan["closedResolverQualified"] = False

    plan_raw = dump_json(plan)
    (HERE / "plan.json").write_bytes(plan_raw)
    freeze = {
        "scope": "Frozen current-source reached hit/death control sequence; no backend command is launched by this file.",
        "plan": "plan.json",
        "planSha256": sha(plan_raw),
        "mutationMapSha256": sha(mutation_map_raw),
        "variantArchiveSha256": sha(read_regular(ARCHIVE)),
        "baseOrdinaryV7PlanSha256": sha(base_plan_raw),
        "baseOrdinaryV7ReceiptSha256": sha(normal_receipt_raw),
        "independentNormalOracleSha256": sha(normal_raw),
        "commands": [{key: command[key] for key in ("label", "argv", "capSeconds", "emits", "control") if key in command}
                     for command in plan["commands"]],
        "unchangedCollector": "/workspace/formal-proofs/bendvy/experiments/public-simulation/delivery-v1/run-delivery.py",
        "unchangedCollectorSha256": plan["pins"]["/workspace/formal-proofs/bendvy/experiments/public-simulation/delivery-v1/run-delivery.py"],
        "resourceCaps": {"source": 5, "emit": 30, "run": 5, "cpu": 5, "threadCount": 1, "gpu": "off"},
        "outputRoot": str(OUTPUT_ROOT),
    }
    (HERE / "FREEZE.json").write_bytes(dump_json(freeze))
    return {"planSha256": sha(plan_raw), "mutationMapSha256": sha(mutation_map_raw),
            "archiveSha256": sha(read_regular(ARCHIVE)), "variantFiles": sum(len(list(p.rglob("*"))) for p in stage_paths.values())}


if __name__ == "__main__":
    print(json.dumps(prepare(), indent=2))
