#!/usr/bin/env python3
"""Build and observe the identical public application on JS and Native."""
import argparse
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "examples/user-simulation"))
from verify import validate


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--evidence", type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    evidence = args.evidence.resolve()
    output.mkdir(parents=True, exist_ok=True)
    evidence.mkdir(parents=True, exist_ok=True)
    receipt = {"status": "INCOMPLETE", "commands": [], "sources": {}, "observations": {}}
    for folder in [ROOT / "src/ecs", ROOT / "examples/user-simulation"]:
        for source in sorted(folder.glob("*.bend")):
            receipt["sources"][str(source.relative_to(ROOT))] = sha(source)
    work = ROOT / "experiments/user-api/core-controls/retry-work.bend"
    receipt["sources"][str(work.relative_to(ROOT))] = sha(work)
    env = os.environ.copy()
    env["BENDVY_CLANG19_ROOT"] = "/tmp/bendvy-clang19-diagnostic/root"

    def run(command, seconds, label):
        command = [str(part) for part in command]
        result = subprocess.run(["timeout", f"{seconds}s", *command], cwd=ROOT,
                                env=env, text=True, stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        (evidence / f"{label}.stdout").write_text(result.stdout)
        (evidence / f"{label}.stderr").write_text(result.stderr)
        receipt["commands"].append({"argv": command, "limitSeconds": seconds,
                                    "exit": result.returncode, "label": label})
        (evidence / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
        if result.returncode:
            raise RuntimeError(f"{label} failed with exit {result.returncode}")
        return result.stdout

    entry = ROOT / "examples/user-simulation/main.bend"
    run(["bend", entry, "--check-only"], 5, "checker")
    run(["bend", entry, "-o", output / "simulation.js"], 30, "js-emit")
    run(["bend", entry, "-o", output / "simulation.c"], 30, "c-emit")
    clang = Path("/tmp/bendvy-clang19-diagnostic/clang19")
    run([clang, "-O3", output / "simulation.c", "-o", output / "simulation.native",
         "-pthread", "-lm"], 120, "native-build")
    for backend, command in [("JS", ["node", output / "simulation.js"]),
                             ("Native", [output / "simulation.native"])]:
        observed = json.loads(run(command, 5, backend.lower() + "-run"))
        receipt["observations"][backend] = validate(observed)
        (evidence / (backend.lower() + ".json")).write_text(json.dumps(observed, indent=2) + "\n")
    run(["bend", work, "-o", output / "retry-work.js"], 30, "work-js-emit")
    run(["bend", work, "-o", output / "retry-work.c"], 30, "work-c-emit")
    run([clang, "-O3", output / "retry-work.c", "-o", output / "retry-work.native",
         "-pthread", "-lm"], 120, "work-native-build")
    for backend, command in [("JS", ["node", output / "retry-work.js"]),
                             ("Native", [output / "retry-work.native"])]:
        counted = json.loads(run(command, 5, backend.lower() + "-work-run"))
        assert counted == [[2, 1, 1, 1], [0, 1, 0, 0]], "Authored retry work differs"
        receipt["observations"][backend]["retryWorkCounts"] = counted
    for source, digest in receipt["sources"].items():
        assert sha(ROOT / source) == digest, "Source changed during controls"
    receipt["artifacts"] = {name: sha(output / name) for name in
                            ["simulation.js", "simulation.c", "simulation.native"]}
    receipt["status"] = "PASS_FINITE_PUBLIC_APPLICATION_BOTH_BACKENDS"
    (evidence / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps(receipt["observations"]))


if __name__ == "__main__":
    main()
