#!/usr/bin/env python3
"""Guarded JS/C emission only; no build or consumer execution."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import sys
import time

ROOT = Path("/workspace/formal-proofs/bendvy")
WT = Path("/workspace/formal-proofs/bendvy-worktrees/decode46-native-resume-v1")
HERE = Path(__file__).resolve().parent
SOURCE_BASIS = HERE / "SOURCE-BASIS.json"
OUTPUT = HERE / "runtime-timed-emit01"
ENTRY = HERE / "bend/main.bend"
BEND = Path("/home/node/.bend/bin/bend-2.0.35")
TASKSET = Path("/usr/bin/taskset")
RUNNER = ROOT / "scripts/task_runner.py"
CLANG_ROOT = Path("/tmp/bendvy-clang19-diagnostic/root")


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def bind_sources(basis: dict) -> list[str]:
    drift = [path for path, expected in basis["sourceInputs"].items() if not Path(path).is_file() or sha(Path(path)) != expected]
    drift += [path for path, expected in basis["toolInputs"].items() if not Path(path).is_file() or sha(Path(path)) != expected]
    assert not drift, {"sourceOrToolDrift": drift}
    return drift


def main() -> None:
    sys.path.insert(0, str(ROOT / "scripts"))
    import task_runner

    assert not OUTPUT.exists(), "fresh emission directory required"
    basis = json.loads(SOURCE_BASIS.read_text())
    assert basis["entryBend"] == str(ENTRY)
    assert basis["toolInputs"][str(BEND)] == sha(BEND)
    assert basis["toolInputs"][str(TASKSET)] == sha(TASKSET)
    bind_sources(basis)
    OUTPUT.mkdir()
    record = {
        "status": "EMIT_ONLY_INCOMPLETE",
        "sourceBasis": str(SOURCE_BASIS),
        "sourceBasisSHA256": sha(SOURCE_BASIS),
        "emitter": str(Path(__file__).resolve()),
        "emitterSHA256": sha(Path(__file__).resolve()),
        "runner": str(RUNNER),
        "runnerSHA256": sha(RUNNER),
        "commands": [],
        "artifacts": {},
        "scope": "JS and Native C emission only; no sourcecheck, compile, timer protocol, or consumer run.",
    }
    fixed_env = {
        "BEND_NO_TELEMETRY": "1",
        "BENDVY_CLANG19_ROOT": str(CLANG_ROOT),
        "HOME": "/home/node",
        "LANG": "C",
        "LC_ALL": "C",
        "LD_LIBRARY_PATH": "/tmp/bendvy-clang19-diagnostic/root/usr/lib/aarch64-linux-gnu:/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib:/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu",
        "PATH": "/usr/bin:/bin",
        "TZ": "UTC",
    }
    env = dict(os.environ, **fixed_env)
    stages = [("JS", OUTPUT / "timed.js"), ("NativeC", OUTPUT / "timed.c")]
    for label, target in stages:
        bind_sources(basis)
        assert not target.exists(), target
        command = [str(TASKSET), "-c", "3", str(BEND), str(ENTRY), "-o", str(target)]
        started = time.monotonic()
        result = task_runner.execute_result(command, 30, env=env, cwd=ENTRY.parent, capture="split")
        elapsed_seconds = time.monotonic() - started
        stdout_path = OUTPUT / (label.lower() + ".stdout")
        stderr_path = OUTPUT / (label.lower() + ".stderr")
        stdout_path.write_bytes(result["stdout"])
        stderr_path.write_bytes(result["stderr"])
        artifact = None
        if target.is_file():
            artifact = {"path": str(target), "bytes": target.stat().st_size, "sha256": sha(target)}
        command_record = {
            "label": label,
            "argv": command,
            "cwd": str(ENTRY.parent),
            "capSeconds": 30,
            "elapsedSeconds": elapsed_seconds,
            "exit": result["exit"],
            "failure": result["failure"],
            "capture": result["capture"],
            "stdout": {"path": str(stdout_path), "bytes": len(result["stdout"]), "sha256": sha(stdout_path)},
            "stderr": {"path": str(stderr_path), "bytes": len(result["stderr"]), "sha256": sha(stderr_path)},
            "artifact": artifact,
        }
        record["commands"].append(command_record)
        record["status"] = "EMIT_ONLY_INCOMPLETE"
        (OUTPUT / "EMIT-RECEIPT.json").write_text(json.dumps(record, indent=2) + "\n")
        bind_sources(basis)
        assert result["exit"] == 0 and result["failure"] is None and artifact is not None, command_record
    record["status"] = "EMIT_ONLY_JS_AND_C_COMPLETE"
    record["generatedBarrierPending"] = True
    (OUTPUT / "EMIT-RECEIPT.json").write_text(json.dumps(record, indent=2) + "\n")
    print(json.dumps({"status": record["status"], "artifacts": [x["artifact"] for x in record["commands"]]}, sort_keys=True))


if __name__ == "__main__":
    main()
