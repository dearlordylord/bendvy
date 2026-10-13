#!/usr/bin/env python3
"""Run a source-pinned scale-one JS/TS/Native correctness canary."""
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


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec is not None and spec.loader is not None, path
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def check_pins(plan: dict, plan_path: Path, plan_sha: str, basis_path: Path) -> None:
    assert sha(plan_path) == plan_sha, "frozen canary plan changed"
    assert sha(basis_path) == plan["sourceBasis"]["sha256"], "source basis changed"
    for path, expected in plan["pins"].items():
        item = Path(path)
        assert item.is_file() and sha(item) == expected, {"inputDrift": path}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan", type=Path, required=True)
    parser.add_argument("--plan-sha256", required=True)
    args = parser.parse_args()
    plan_path = args.plan.resolve()
    plan_sha = args.plan_sha256
    plan = json.loads(plan_path.read_text())
    assert plan["status"] == "FROZEN_SCALE_ONE_FULL_LIFECYCLE_CANARY"
    basis_path = Path(plan["sourceBasis"]["path"])
    check_pins(plan, plan_path, plan_sha, basis_path)

    output = Path(plan["outputRoot"])
    assert not output.exists(), "fresh scale-one output root required"
    output.mkdir()
    generated = output / "generated"
    generated.mkdir()

    sys.path.insert(0, str(ROOT / "scripts"))
    import task_runner
    input_guard = task_runner.Inputs(
        files=plan["pins"].keys(),
        directories=plan["resourceRoots"].keys(),
    )
    for root, expected in plan["resourceRoots"].items():
        actual = input_guard.expected[str(Path(root).resolve())]
        assert actual == expected, {"resourceRootDrift": root}
    validator = load_module("timed_scaling_validator", HERE / "validate.py")
    barrier_check = load_module("timed_scaling_barrier", HERE / "barrier-check.py")

    receipt_path = output / "CANARY-RECEIPT.json"
    emission_path = output / "EMIT-RECEIPT.json"
    record = {
        "status": "INCOMPLETE_SCALE_ONE_FULL_LIFECYCLE_CANARY",
        "plan": str(plan_path),
        "planSHA256": plan_sha,
        "sourceBasis": str(basis_path),
        "sourceBasisSHA256": sha(basis_path),
        "controller": str(Path(__file__).resolve()),
        "controllerSHA256": sha(Path(__file__).resolve()),
        "runner": str(RUNNER),
        "runnerSHA256": sha(RUNNER),
        "commands": [],
        "outputs": {},
        "scope": "One fresh 32-case application per implementation and process. Setup, operations, full report materialization and timer capture are inside its interval; stdout flush follows end. Elapsed values are telemetry only.",
    }
    receipt_path.write_text(json.dumps(record, indent=2) + "\n")
    emission = {
        "status": "EMIT_INCOMPLETE",
        "sourceBasis": str(basis_path),
        "sourceBasisSHA256": sha(basis_path),
        "generated": {},
        "commands": [],
    }
    emission_path.write_text(json.dumps(emission, indent=2) + "\n")

    env = dict(os.environ)
    env.update(plan["environment"])
    completed: set[str] = set()

    def run_step(step: dict) -> dict:
        check_pins(plan, plan_path, plan_sha, basis_path)
        input_guard.guard()
        assert set(step["requires"]) <= completed, (step["label"], step["requires"], completed)
        for path in step["freshOutputs"]:
            assert not Path(path).exists(), path
        started = time.monotonic()
        result = task_runner.execute_result(
            step["argv"], step["capSeconds"], env=env, cwd=step["cwd"], capture="split"
        )
        elapsed = time.monotonic() - started
        stdout_path = output / (step["label"] + ".stdout.gz")
        with stdout_path.open("wb") as stream:
            with gzip.GzipFile(fileobj=stream, mode="wb", filename="", mtime=0) as zipped:
                zipped.write(result["stdout"])
        stderr_path = output / (step["label"] + ".stderr")
        stderr_path.write_bytes(result["stderr"])
        row = {
            "label": step["label"],
            "kind": step["kind"],
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
        receipt_path.write_text(json.dumps(record, indent=2) + "\n")
        check_pins(plan, plan_path, plan_sha, basis_path)
        input_guard.guard()
        if result["failure"] is not None or result["exit"] != 0:
            record["status"] = "STOPPED_ON_FIRST_COMMAND_FAILURE"
            receipt_path.write_text(json.dumps(record, indent=2) + "\n")
            raise RuntimeError(json.dumps({"failedStep": step["label"], "exit": result["exit"], "failure": result["failure"]}))
        if step["kind"] == "artifact" or step["kind"].startswith("emission-"):
            artifact = Path(step["artifact"])
            assert artifact.is_file(), artifact
            row["artifact"] = {"path": str(artifact), "bytes": artifact.stat().st_size, "sha256": sha(artifact)}
            record["commands"][-1] = row
        elif step["kind"] == "timed-consumer":
            validation = validator.validate(step["scale"], result["stdout"], result["stderr"])
            row["validation"] = validation
            record["commands"][-1] = row
            record["outputs"][step["label"]] = validation
        receipt_path.write_text(json.dumps(record, indent=2) + "\n")
        completed.add(step["label"])
        return row

    try:
        for step in plan["steps"]:
            if step["kind"].startswith("emission-"):
                row = run_step(step)
                artifact = row["artifact"]
                emission["commands"].append(row)
                key = "js" if step["kind"] == "emission-js" else "nativeC"
                emission["generated"][key] = artifact
                emission["status"] = "EMIT_INCOMPLETE"
                emission_path.write_text(json.dumps(emission, indent=2) + "\n")
            elif step["kind"] == "generated-barrier":
                check_pins(plan, plan_path, plan_sha, basis_path)
                input_guard.guard()
                assert set(step["requires"]) <= completed, (step["label"], step["requires"], completed)
                for path in step["freshOutputs"]:
                    assert not Path(path).exists(), path
                emission["status"] = "EMIT_JS_C_COMPLETE"
                emission_path.write_text(json.dumps(emission, indent=2) + "\n")
                barrier = barrier_check.validate(plan)
                record["outputs"][step["label"]] = {
                    "status": barrier["status"],
                    "path": plan["generated"]["barrier"]["path"],
                    "sha256": sha(Path(plan["generated"]["barrier"]["path"])),
                }
                check_pins(plan, plan_path, plan_sha, basis_path)
                input_guard.guard()
                completed.add(step["label"])
                receipt_path.write_text(json.dumps(record, indent=2) + "\n")
            else:
                row = run_step(step)
                if step["kind"] == "artifact":
                    record["outputs"][step["label"]] = row["artifact"]
                    receipt_path.write_text(json.dumps(record, indent=2) + "\n")
    except BaseException:
        raise

    record["status"] = "COMPLETE_SCALE_ONE_JS_TS_NATIVE_PASS"
    record["timingInterpretation"] = "Elapsed nanoseconds are descriptive telemetry only; no threshold or ratio is applied."
    receipt_path.write_text(json.dumps(record, indent=2) + "\n")
    check_pins(plan, plan_path, plan_sha, basis_path)
    input_guard.guard()
    print(json.dumps({"status": record["status"], "outputs": record["outputs"]}, sort_keys=True))


if __name__ == "__main__":
    main()
