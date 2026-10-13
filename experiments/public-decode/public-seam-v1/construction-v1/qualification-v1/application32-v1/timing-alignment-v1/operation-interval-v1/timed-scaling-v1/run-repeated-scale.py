#!/usr/bin/env python3
"""Run scale-two and scale-four consumers against reused pinned artifacts."""
from __future__ import annotations

import argparse
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import sys
import time


ROOT = Path("/workspace/formal-proofs/bendvy")
HERE = Path(__file__).resolve().parent
RUNNER = ROOT / "scripts/task_runner.py"
BOUNDARY = ROOT / "scripts/evidence_boundary.py"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec is not None and spec.loader is not None, path
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def check_pins(plan: dict, plan_path: Path, plan_sha: str) -> None:
    assert sha(plan_path) == plan_sha, "frozen repeated-consumer plan changed"
    basis_path = Path(plan["sourceBasis"]["path"])
    assert sha(basis_path) == plan["sourceBasis"]["sha256"], "source basis changed"
    for path, expected in plan["pins"].items():
        item = Path(path)
        assert item.is_file() and sha(item) == expected, {"inputDrift": path}


def verify_scale_one_reuse(plan: dict) -> dict:
    evidence = plan["scaleOneEvidence"]
    pins = plan["pins"]
    for item in evidence["artifacts"].values():
        path = item["path"]
        expected = item["sha256"]
        assert pins.get(path) == expected, {"reuseNotPinned": path}
        assert Path(path).is_file() and sha(Path(path)) == expected, {"reuseDrift": path}

    prior_plan_path = Path(evidence["plan"]["path"])
    prior_plan = json.loads(prior_plan_path.read_text())
    assert prior_plan["status"] == "FROZEN_SCALE_ONE_FULL_LIFECYCLE_CANARY"
    assert sha(prior_plan_path) == evidence["plan"]["sha256"]
    assert prior_plan["sourceBasis"]["sha256"] == plan["sourceBasis"]["sha256"]

    receipt_path = Path(evidence["receipt"]["path"])
    receipt = json.loads(receipt_path.read_text())
    assert sha(receipt_path) == evidence["receipt"]["sha256"]
    assert receipt["status"] == "COMPLETE_SCALE_ONE_JS_TS_NATIVE_PASS"
    assert receipt["planSHA256"] == evidence["plan"]["sha256"]
    assert receipt["sourceBasisSHA256"] == plan["sourceBasis"]["sha256"]

    metadata_path = Path(plan["independentOracle"]["metadata"])
    metadata = json.loads(metadata_path.read_text())
    base = metadata["baseOracle"]
    commands = {row["label"]: row for row in receipt["commands"]}
    retained_logs = {(row["label"], channel): row[channel] for row in evidence["logs"] for channel in ("stdout", "stderr")}
    assert set(commands) == {row["label"] for row in evidence["logs"]}
    for label, row in commands.items():
        for channel in ("stdout", "stderr"):
            expected = retained_logs[(label, channel)]
            actual = row[channel]
            assert actual["path"] == expected["path"]
            assert actual["sha256"] == expected["sha256"]
            assert pins.get(expected["path"]) == expected["sha256"]

    for label in ("js-consumer", "ts-consumer", "native-consumer"):
        row = commands[label]
        validation = row["validation"]
        assert row["exit"] == 0 and row["failure"] is None
        assert validation["status"] == "COMPLETE_REPEATED_REPORT_AND_INTERVAL_PROTOCOL_PASS"
        assert validation["applications"] == 1 and validation["records"] == base["records"]
        assert validation["stdoutBytes"] == base["rawBytes"]
        assert validation["stdoutSHA256"] == base["rawSha256"]
        assert validation["metrics"]["intervals"] == 1

    prior_steps = {row["label"]: row for row in prior_plan["steps"]}
    for step in plan["steps"]:
        prior_label = f"{step['implementation']}-consumer"
        prior_step = prior_steps[prior_label]
        assert step["argv"] == prior_step["argv"][:-1] + [str(step["scale"])], step["label"]
        assert step["cwd"] == prior_step["cwd"]
        assert step["capSeconds"] == prior_step["capSeconds"]

    emission_path = Path(evidence["artifacts"]["emissionReceipt"]["path"])
    emission = json.loads(emission_path.read_text())
    assert emission["status"] == "EMIT_JS_C_COMPLETE"
    assert emission["sourceBasisSHA256"] == plan["sourceBasis"]["sha256"]
    for key in ("js", "nativeC"):
        item = evidence["artifacts"][key]
        assert emission["generated"][key]["path"] == item["path"]
        assert emission["generated"][key]["sha256"] == item["sha256"]

    barrier_path = Path(evidence["artifacts"]["generatedBarrier"]["path"])
    barrier = json.loads(barrier_path.read_text())
    assert barrier["status"] == "SCALE_ONE_SOURCE_AND_GENERATED_TIMER_BOUNDARY_PASS"
    assert barrier["generated"]["js"]["sha256"] == evidence["artifacts"]["js"]["sha256"]
    assert barrier["generated"]["nativeC"]["sha256"] == evidence["artifacts"]["nativeC"]["sha256"]

    build = commands["native-build"]
    binary = evidence["artifacts"]["nativeBinary"]
    assert build["exit"] == 0 and build["failure"] is None
    assert build["artifact"]["path"] == binary["path"]
    assert build["artifact"]["sha256"] == binary["sha256"]
    for key, item in (("js", evidence["artifacts"]["js"]), ("nativeC", evidence["artifacts"]["nativeC"])):
        emission_row = commands["emission-js" if key == "js" else "emission-native-c"]
        assert emission_row["artifact"]["path"] == item["path"]
        assert emission_row["artifact"]["sha256"] == item["sha256"]
    generated_barrier = receipt["outputs"]["generated-barrier"]
    assert generated_barrier["path"] == evidence["artifacts"]["generatedBarrier"]["path"]
    assert generated_barrier["sha256"] == evidence["artifacts"]["generatedBarrier"]["sha256"]

    for scale in plan["scales"]:
        expected = metadata["repetitions"][str(scale)]
        planned = plan["independentOracle"]["scales"][str(scale)]
        assert planned["applications"] == expected["applications"] == scale
        assert planned["records"] == expected["completeRecords"] == 32 * scale
        assert planned["stdoutBytes"] == expected["bytes"]
        assert planned["stdoutSHA256"] == expected["sha256"]
        assert planned["fnv1a32"] == expected["fnv1a32"]
        assert planned["gzipSHA256"] == expected["gzipSha256"]
    return {
        "status": "SCALE_ONE_SOURCE_EMIT_BUILD_AND_RUNTIME_CHAIN_REUSED_AND_GUARDED",
        "scaleOnePlanSHA256": evidence["plan"]["sha256"],
        "scaleOneReceiptSHA256": evidence["receipt"]["sha256"],
        "artifacts": {
            key: {"path": item["path"], "sha256": item["sha256"]}
            for key, item in evidence["artifacts"].items()
        },
    }


def verify_plan_shape(plan: dict, python_path: Path) -> None:
    assert plan["status"] == "FROZEN_SCALE_TWO_FOUR_CONSUMER_CANARY"
    assert plan["sourcePinsCount"] == len(plan["pins"])
    assert Path(sys.executable).resolve() == python_path.resolve(), {
        "pythonInterpreter": sys.executable,
        "expected": str(python_path),
    }
    assert plan["scales"] == [2, 4]
    assert len(plan["steps"]) == 6
    labels = []
    seen = []
    for scale in plan["scales"]:
        for implementation in ("js", "ts", "native"):
            label = f"{implementation}-consumer-scale{scale}"
            row = next(item for item in plan["steps"] if item["label"] == label)
            assert row["kind"] == "timed-consumer" and row["scale"] == scale
            assert row["implementation"] == implementation
            assert row["argv"][-1] == str(scale), (label, row["argv"])
            assert row["requires"] == ["scale-one-artifact-reuse-guard"]
            assert row["freshOutputs"] == []
            labels.append(label)
            seen.append((scale, implementation))
    assert [row["label"] for row in plan["steps"]] == labels
    assert seen == [(scale, impl) for scale in (2, 4) for impl in ("js", "ts", "native")]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan", type=Path, required=True)
    parser.add_argument("--plan-sha256", required=True)
    parser.add_argument("--preflight-only", action="store_true")
    args = parser.parse_args()

    plan_path = args.plan.resolve()
    plan_sha = args.plan_sha256
    plan = json.loads(plan_path.read_text())
    basis_path = Path(plan["sourceBasis"]["path"])
    check_pins(plan, plan_path, plan_sha)
    verify_plan_shape(plan, Path(plan["toolPins"]["python"]))

    sys.path.insert(0, str(ROOT / "scripts"))
    import task_runner
    import evidence_boundary

    input_guard = task_runner.Inputs(
        files=plan["pins"].keys(), directories=plan["resourceRoots"].keys()
    )
    for root, expected in plan["resourceRoots"].items():
        actual = input_guard.expected[str(Path(root).resolve())]
        assert actual == expected, {"resourceRootDrift": root}

    validator = load_module("timed_scale_validator", HERE / "validate.py")
    reused = verify_scale_one_reuse(plan)
    input_guard.guard()
    if args.preflight_only:
        print(json.dumps({"status": "SCALE_TWO_FOUR_PREFLIGHT_PASS", "reuse": reused}, sort_keys=True))
        return

    output = Path(plan["outputRoot"])
    assert not output.exists(), "fresh scale-two/four output root required"
    output.mkdir()
    receipt_path = output / "SCALE-CANARY-RECEIPT.json"
    record = {
        "status": "INCOMPLETE_SCALE_TWO_FOUR_CONSUMER_CANARY",
        "plan": str(plan_path),
        "planSHA256": plan_sha,
        "sourceBasis": str(basis_path),
        "sourceBasisSHA256": sha(basis_path),
        "controller": str(Path(__file__).resolve()),
        "controllerSHA256": sha(Path(__file__).resolve()),
        "runner": str(RUNNER),
        "runnerSHA256": sha(RUNNER),
        "reuse": reused,
        "commands": [],
        "outputs": {},
        "scope": plan["scope"],
        "timingInterpretation": "Elapsed values are descriptive telemetry only; this canary makes no timing threshold, ratio or performance claim.",
    }
    receipt_path.write_text(json.dumps(record, indent=2) + "\n")

    env = dict(os.environ)
    env.update(plan["environment"])
    completed = {"scale-one-artifact-reuse-guard"}

    def guard_inputs() -> None:
        check_pins(plan, plan_path, plan_sha)
        input_guard.guard()
        verify_scale_one_reuse(plan)

    def save_receipt() -> None:
        receipt_path.write_text(json.dumps(record, indent=2) + "\n")

    checks = [("terminal frozen inputs and reused artifacts", guard_inputs)]
    with evidence_boundary.ReceiptBoundary(record, receipt_path, checks):
        save_receipt()
        for step in plan["steps"]:
            with evidence_boundary.GuardBoundary([("pre-command frozen inputs", guard_inputs)]):
                assert set(step["requires"]) <= completed, (step["label"], step["requires"], completed)
                started = time.monotonic()
                result = task_runner.execute_result(
                    step["argv"], step["capSeconds"], env=env, cwd=step["cwd"], capture="split"
                )
                elapsed = time.monotonic() - started

            stdout_path = output / f"{step['label']}.stdout.gz"
            with stdout_path.open("wb") as stream:
                with gzip.GzipFile(fileobj=stream, mode="wb", filename="", mtime=0) as zipped:
                    zipped.write(result["stdout"])
            stderr_path = output / f"{step['label']}.stderr"
            stderr_path.write_bytes(result["stderr"])
            row = {
                "label": step["label"],
                "kind": step["kind"],
                "implementation": step["implementation"],
                "scale": step["scale"],
                "argv": step["argv"],
                "cwd": step["cwd"],
                "capSeconds": step["capSeconds"],
                "elapsedWallSeconds": elapsed,
                "exit": result["exit"],
                "failure": result["failure"],
                "capture": result["capture"],
                "runnerSHA256": result.get("runnerSHA256"),
                "stdout": {"path": str(stdout_path), "bytes": len(result["stdout"]), "sha256": sha(stdout_path)},
                "stderr": {"path": str(stderr_path), "bytes": len(result["stderr"]), "sha256": sha(stderr_path)},
            }
            record["commands"].append(row)
            save_receipt()
            with evidence_boundary.GuardBoundary([("post-command frozen inputs", guard_inputs)]):
                pass
            if result["failure"] is not None or result["exit"] != 0:
                raise RuntimeError(json.dumps({"failedStep": step["label"], "exit": result["exit"], "failure": result["failure"]}))

            validation = validator.validate(step["scale"], result["stdout"], result["stderr"])
            row["validation"] = validation
            record["outputs"][step["label"]] = validation
            save_receipt()
            completed.add(step["label"])

        record["status"] = "COMPLETE_SCALE_TWO_FOUR_JS_TS_NATIVE_PASS"

    print(json.dumps({"status": record["status"], "outputs": record["outputs"]}, sort_keys=True))


if __name__ == "__main__":
    main()
