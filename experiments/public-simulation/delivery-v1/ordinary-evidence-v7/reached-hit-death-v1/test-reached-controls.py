"""CPU-only controls for the retained hit/death validator evidence."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile


LEAF = Path(__file__).resolve().parent
PLAN_PATH = LEAF / "plan.json"


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def require_rejection(action, expected):
    try:
        action()
    except ValueError as error:
        if expected not in str(error):
            raise AssertionError(f"expected {expected!r}, got {str(error)!r}") from error
        return str(error)
    raise AssertionError(f"expected rejection containing {expected!r}")


def bump_first_nat(value):
    if isinstance(value, dict):
        if set(value) == {"nat"}:
            value["nat"] += 1
            return True
        return any(bump_first_nat(item) for item in value.values())
    if isinstance(value, list):
        return any(bump_first_nat(item) for item in value)
    return False


def main():
    frozen_plan_raw = PLAN_PATH.read_bytes()
    frozen_plan = json.loads(frozen_plan_raw)
    if digest(frozen_plan_raw) != "de303c94e974a1612b59662ef5c14a4cfbb600e49d470abba9c013ce1f46f56e":
        raise ValueError("historical de303 plan changed")

    validator_path = Path(frozen_plan["qualificationValidator"]).resolve()
    spec = importlib.util.spec_from_file_location("reached_control_validator", validator_path)
    validator = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(validator)

    # The original plan and failed receipt remain immutable. This in-memory
    # copy qualifies only the validator source successor under test.
    plan = copy.deepcopy(frozen_plan)
    plan["pins"][str(validator_path)] = digest(validator_path.read_bytes())
    output_root = Path(plan["outputRoot"])
    receipt = json.loads((output_root / "receipt.json").read_text())
    labels = [row["label"] for row in receipt["commands"]]
    if labels != ["omit-hit-source", "omit-hit-JS-emit", "omit-hit-JS-run"]:
        raise ValueError("preserved de303 collector receipt changed")
    if receipt.get("error") != "ValueError: full two-schema/fourteen-phase report shape changed":
        raise ValueError("preserved de303 terminal failure changed")

    hit_stdout = (output_root / "omit-hit-JS-run.stdout").read_bytes()
    if not validator.validate("omit-hit", hit_stdout, b"", plan=plan):
        raise AssertionError("retained hit output did not match its independent counter")

    parser = validator.load_parser(plan["parser"], plan["pins"])
    joins = plan["constructorJoins"]
    normal = json.loads(Path(plan["independentNormalOraclePath"]).read_text())
    for label in ("JS-run", "Native-run"):
        baseline = plan["normalBaseline"]["outputs"][label]
        raw = Path(baseline["path"]).read_bytes()
        parsed = validator.parse_complete(raw, parser, joins)
        if validator.strict(validator.normalize(parsed, joins)) != validator.strict(normal):
            raise ValueError(f"retained normal oracle mismatch: {label}")

    normal_js = Path(plan["normalBaseline"]["outputs"]["JS-run"]["path"]).read_bytes()
    normal_rejection = require_rejection(
        lambda: validator.validate("omit-hit", normal_js, b"", plan=plan),
        "mutation did not reject the normal full oracle",
    )

    wrong_root = validator.parse_complete(hit_stdout, parser, joins)
    wrong_root["constructor"] = next(
        literal for literal, neutral in joins.items() if neutral != "main.bend::TwoSchemaReport"
    )
    root_rejection = require_rejection(
        lambda: validator.parse_complete(parser["render"](wrong_root).encode(), parser, joins),
        "full two-schema/fourteen-phase report shape changed",
    )

    missing_phase = validator.parse_complete(hit_stdout, parser, joins)
    missing_phase["fields"][0].pop()
    phase_rejection = require_rejection(
        lambda: validator.parse_complete(parser["render"](missing_phase).encode(), parser, joins),
        "full two-schema/fourteen-phase report shape changed",
    )

    wrong_stream = validator.parse_complete(hit_stdout, parser, joins)
    if not bump_first_nat(wrong_stream):
        raise ValueError("could not construct wrong-stream control")
    stream_rejection = require_rejection(
        lambda: validator.validate(
            "omit-hit", parser["render"](wrong_stream).encode(), b"", plan=plan
        ),
        "full mutation report differs from the independent counter oracle",
    )

    mutation_map = json.loads(Path(plan["reachedHitDeath"]["mutationMap"]).read_text())
    death = mutation_map["mutations"]["omit-death"]
    death_counter = json.loads(Path(death["counterOraclePath"]).read_text())
    if validator.strict(validator.omit_event(normal, death["target"])) != validator.strict(death_counter):
        raise ValueError("death counter is not independently derived from the normal oracle")

    hit_mutation = mutation_map["mutations"]["omit-hit"]
    corrupt_counter = json.loads(Path(hit_mutation["counterOraclePath"]).read_text())
    if not bump_first_nat(corrupt_counter):
        raise ValueError("could not construct corrupt-oracle control")
    with tempfile.TemporaryDirectory(prefix="bendvy63-counter-control-") as temp_dir:
        temporary = Path(temp_dir)
        counter_path = temporary / "counter.json"
        map_path = temporary / "mutation-map.json"
        counter_raw = (json.dumps(corrupt_counter, sort_keys=True, separators=(",", ":")) + "\n").encode()
        counter_path.write_bytes(counter_raw)
        hit_mutation["counterOraclePath"] = str(counter_path.resolve())
        hit_mutation["counterOracleSha256"] = digest(counter_raw)
        map_raw = (json.dumps(mutation_map, indent=2) + "\n").encode()
        map_path.write_bytes(map_raw)
        corrupted_plan = copy.deepcopy(plan)
        corrupted_plan["reachedHitDeath"]["mutationMap"] = str(map_path.resolve())
        corrupted_plan["reachedHitDeath"]["mutationMapSha256"] = digest(map_raw)
        corrupted_plan["pins"][str(counter_path.resolve())] = digest(counter_raw)
        corrupted_plan["pins"][str(map_path.resolve())] = digest(map_raw)
        oracle_rejection = require_rejection(
            lambda: validator.validate("omit-hit", hit_stdout, b"", plan=corrupted_plan),
            "materialized counter is not derived from the independent normal oracle",
        )

    print(json.dumps({
        "retained_plan": "de303c94e974a1612b59662ef5c14a4cfbb600e49d470abba9c013ce1f46f56e",
        "retained_hit_counter_match": True,
        "retained_normal_js_native_positive": True,
        "normal_rejected_for_mutant_reason": normal_rejection,
        "malformed_root_rejected": root_rejection,
        "missing_phase_rejected": phase_rejection,
        "wrong_stream_rejected": stream_rejection,
        "wrong_oracle_rejected": oracle_rejection,
        "death_counter_independent_derivation": True,
        "original_collector_receipt_unchanged": True,
    }, sort_keys=True))


if __name__ == "__main__":
    main()
