#!/usr/bin/env python3
"""Run explicit positive/negative Bend controls without accepting timeouts."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    cases = json.loads(args.manifest.read_text())
    args.output.mkdir(parents=True, exist_ok=True)
    library = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
               for p in sorted((ROOT / "src/ecs").glob("*.bend"))}
    (args.output / "library.json").write_text(json.dumps(library, indent=2) + "\n")
    results = []
    for case in cases:
        source = ROOT / case["file"]
        command = ["timeout", "5s", "bend", str(source)]
        proc = subprocess.run(command, cwd=ROOT, text=True,
                              stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        log = args.output / (case["name"] + ".log")
        log.write_text(proc.stdout)
        rejected = case.get("reject")
        passed = (proc.returncode == 1 and rejected in proc.stdout) if rejected else (
            proc.returncode == 0 and case["expected"].rstrip("\n") == proc.stdout.rstrip("\n"))
        results.append({"name": case["name"], "command": command,
                        "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
                        "exit": proc.returncode, "passed": passed,
                        "log": log.name})
    (args.output / "results.json").write_text(json.dumps(results, indent=2) + "\n")
    print(json.dumps({"passed": sum(r["passed"] for r in results), "total": len(results)}))
    raise SystemExit(0 if all(r["passed"] for r in results) else 1)


if __name__ == "__main__":
    main()
