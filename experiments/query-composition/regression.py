#!/usr/bin/env python3
"""Replay prior public consumers without overwriting their historical receipts."""
import argparse
import hashlib
import json
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FOLDERS = ["src/ecs", "examples/user-simulation", "experiments/user-api",
           "experiments/user-api-provider"]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--evidence", type=Path, required=True)
    args = parser.parse_args()
    evidence = args.evidence.resolve()
    evidence.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="query-composition-regression-") as temp:
        stage = Path(temp)
        for folder in FOLDERS:
            shutil.copytree(ROOT / folder, stage / folder)
        sources = {}
        for folder in FOLDERS:
            for path in sorted((stage / folder).rglob("*")):
                if path.is_file() and (path.suffix in (".bend", ".py", ".mjs")
                                       or path.name in ("expected.json", "cases.json", "controls.json")):
                    sources[str(path.relative_to(stage))] = hashlib.sha256(path.read_bytes()).hexdigest()
        proc = subprocess.run(["python3", "experiments/user-api/run-all.py"],
                              cwd=stage, text=True, stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT)
        (evidence / "suite.log").write_text(proc.stdout)
        for source, target in [
            ("experiments/user-api/suite.json", "suite.json"),
            ("experiments/user-api/application-evidence-final/receipt.json", "application.json"),
            ("experiments/user-api/fresh-consumer/evidence/results.json", "consumer.json"),
        ]:
            if (stage / source).exists():
                shutil.copyfile(stage / source, evidence / target)
        receipt = {"status": "PASS" if proc.returncode == 0 else "FAIL",
                   "exit": proc.returncode, "sources": sources,
                   "runnerSha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
        (evidence / "regression.json").write_text(json.dumps(receipt, indent=2) + "\n")
        print(json.dumps({"status": receipt["status"], "exit": proc.returncode}))
        if proc.returncode:
            print(proc.stdout)
        raise SystemExit(proc.returncode)


if __name__ == "__main__":
    main()
