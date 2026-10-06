#!/usr/bin/env python3
"""Final #26 scoped suite, distinct from the still-open full-core gates."""
import json
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
rows = []


def run(argv):
    started = time.monotonic()
    proc = subprocess.run(argv, cwd=ROOT, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    rows.append({"argv": argv, "exit": proc.returncode,
                 "seconds": time.monotonic() - started, "output": proc.stdout})
    print(proc.stdout, flush=True)
    (HERE / "suite.json").write_text(json.dumps({"status": "INCOMPLETE", "commands": rows}, indent=2) + "\n")
    if proc.returncode:
        raise SystemExit(proc.returncode)


for name in ["design", "core", "system", "transaction"]:
    folder = "design-canaries" if name == "design" else name + "-controls"
    run(["python3", "experiments/user-api/check.py",
         f"experiments/user-api/{folder}/cases.json", "--output",
         f"experiments/user-api/{name}-evidence-final"])
run(["python3", "experiments/user-api-provider/replay.py", "--evidence",
     "experiments/user-api/provider-evidence-final.json"])
run(["python3", "experiments/user-api/fresh-consumer/check.py"])
run(["timeout", "5s", "node", "examples/user-simulation/reference.mjs", "--verify"])
run(["python3", "experiments/user-api/build.py", "--output", ".artifacts/user-api-final",
     "--evidence", "experiments/user-api/application-evidence-final"])
(HERE / "suite.json").write_text(json.dumps({"status": "PASS_SCOPED_USER_API_SUITE", "commands": rows}, indent=2) + "\n")
