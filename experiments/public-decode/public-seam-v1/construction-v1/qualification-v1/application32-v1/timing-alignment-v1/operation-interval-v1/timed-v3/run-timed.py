#!/usr/bin/env python3
"""Run one pinned full lifecycle, stopping at the first failed gate."""
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
SOURCE_BASIS = HERE / "SOURCE-BASIS.json"
EMISSION = HERE / "runtime-timed-emit01"
RECEIPT = EMISSION / "EMIT-RECEIPT.json"
BARRIER = EMISSION / "GENERATED-BARRIER.json"
OUTPUT = HERE / "runtime-timed-full01"
RUNNER = ROOT / "scripts/task_runner.py"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check_pins(plan: dict, plan_path: Path, plan_sha: str) -> None:
    assert sha(plan_path) == plan_sha, "frozen runtime plan changed"
    for path, expected in plan["pins"].items():
        p = Path(path)
        assert p.is_file() and sha(p) == expected, {"inputDrift": path}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan", type=Path, required=True)
    parser.add_argument("--plan-sha256", required=True)
    args = parser.parse_args()
    plan_path = args.plan.resolve()
    plan_sha = args.plan_sha256
    plan = json.loads(plan_path.read_text())
    assert plan["status"] == "FROZEN_CURRENT_SOURCE_TIMED_LIFECYCLE_PLAN"
    check_pins(plan, plan_path, plan_sha)
    assert not OUTPUT.exists(), "fresh runtime output required"
    OUTPUT.mkdir()

    sys.path.insert(0, str(ROOT / "scripts"))
    import task_runner
    loader = importlib.util.spec_from_file_location("timed_validator", HERE / "validate-runtime.py")
    validator = importlib.util.module_from_spec(loader)
    loader.loader.exec_module(validator)

    env = dict(os.environ)
    env.update(plan["environment"])
    record = {
        "status": "INCOMPLETE_TIMED_LIFECYCLE",
        "plan": str(plan_path),
        "planSHA256": plan_sha,
        "controller": str(Path(__file__).resolve()),
        "controllerSHA256": sha(Path(__file__).resolve()),
        "runner": str(RUNNER),
        "runnerSHA256": sha(RUNNER),
        "commands": [],
        "outputs": {},
        "scope": "Correctness of one complete fresh 32-case lifecycle; elapsed time is recorded telemetry only.",
    }
    (OUTPUT / "RUNTIME-RECEIPT.json").write_text(json.dumps(record, indent=2) + "\n")

    completed = set()
    for step in plan["steps"]:
        check_pins(plan, plan_path, plan_sha)
        assert set(step["requires"]) <= completed, (step["label"], step["requires"], completed)
        for output in step["freshOutputs"]:
            assert not Path(output).exists(), output
        started = time.monotonic()
        result = task_runner.execute_result(
            step["argv"], step["capSeconds"], env=env, cwd=step["cwd"], capture="split"
        )
        elapsed = time.monotonic() - started
        stdout_path = OUTPUT / (step["label"] + ".stdout.gz")
        with stdout_path.open("wb") as f:
            with gzip.GzipFile(fileobj=f, mode="wb", filename="", mtime=0) as stream:
                stream.write(result["stdout"])
        stderr_path = OUTPUT / (step["label"] + ".stderr")
        stderr_path.write_bytes(result["stderr"])
        row = {
            "label": step["label"],
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
        record["status"] = "INCOMPLETE_TIMED_LIFECYCLE"
        (OUTPUT / "RUNTIME-RECEIPT.json").write_text(json.dumps(record, indent=2) + "\n")
        check_pins(plan, plan_path, plan_sha)
        if result["failure"] is not None or result["exit"] != 0:
            record["status"] = "STOPPED_ON_FIRST_COMMAND_FAILURE"
            (OUTPUT / "RUNTIME-RECEIPT.json").write_text(json.dumps(record, indent=2) + "\n")
            print(json.dumps({"status": record["status"], "failedStep": step["label"], "exit": result["exit"], "failure": result["failure"]}, sort_keys=True))
            return
        if step["kind"] == "timed-consumer":
            validation = validator.validate(result["stdout"], result["stderr"])
            row["validation"] = validation
            record["outputs"][step["label"]] = validation
            record["commands"][-1] = row
            (OUTPUT / "RUNTIME-RECEIPT.json").write_text(json.dumps(record, indent=2) + "\n")
        if step["kind"] == "artifact":
            artifact = Path(step["artifact"])
            assert artifact.is_file(), artifact
            record["outputs"][step["label"]] = {"path": str(artifact), "bytes": artifact.stat().st_size, "sha256": sha(artifact)}
            (OUTPUT / "RUNTIME-RECEIPT.json").write_text(json.dumps(record, indent=2) + "\n")
        check_pins(plan, plan_path, plan_sha)
        completed.add(step["label"])

    record["status"] = "COMPLETE_TIMED_LIFECYCLE_JS_TS_NATIVE_PASS"
    record["timingInterpretation"] = "Elapsed nanoseconds are descriptive telemetry only; no threshold, speed ratio, or comparative performance verdict is applied."
    (OUTPUT / "RUNTIME-RECEIPT.json").write_text(json.dumps(record, indent=2) + "\n")
    check_pins(plan, plan_path, plan_sha)
    print(json.dumps({"status": record["status"], "outputs": record["outputs"]}, sort_keys=True))


if __name__ == "__main__":
    main()
