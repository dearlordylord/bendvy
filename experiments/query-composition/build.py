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
sys.path.insert(0, str(ROOT / "examples/query-composition"))
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
    for folder in [ROOT / "src/ecs", ROOT / "examples/query-composition"]:
        for source in sorted(folder.glob("*.bend")):
            receipt["sources"][str(source.relative_to(ROOT))] = sha(source)
    for relative in ["examples/query-composition/verify.py", "examples/query-composition/expected.json",
                     "examples/query-composition/reference.mjs", "experiments/query-composition/build.py",
                     ".references/sources.json"]:
        receipt["sources"][relative] = sha(ROOT / relative)
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

    receipt["compilerVersion"] = run(["bend", "version"], 5, "bend-version").strip()
    receipt["nodeVersion"] = run(["node", "--version"], 5, "node-version").strip()
    receipt["referenceCommits"] = {}
    manifest = json.loads((ROOT / ".references/sources.json").read_text())
    for name, source in manifest["sources"].items():
        checkout = Path("/workspace/formal-proofs/bendvy/.references") / name
        observed = run(["git", "-C", checkout, "rev-parse", "HEAD"], 5, "reference-" + name).strip()
        assert observed == source["commit"], "Read-only reference commit differs"
        receipt["referenceCommits"][name] = observed
    reference = json.loads(run(["node", ROOT / "examples/query-composition/reference.mjs", "--verify"],
                               5, "reference-run"))
    assert reference == {"status": "PASS", "checkpoints": 23}, "Fresh reference run differs"
    receipt["observations"]["TS"] = reference
    entry = ROOT / "examples/query-composition/main.bend"
    run(["bend", entry, "--check-only"], 5, "checker")
    run(["bend", entry, "-o", output / "workshop.js"], 30, "js-emit")
    run(["bend", entry, "-o", output / "workshop.c"], 30, "c-emit")
    clang = Path("/tmp/bendvy-clang19-diagnostic/clang19")
    run([clang, "-O3", output / "workshop.c", "-o", output / "workshop.native",
         "-pthread", "-lm"], 120, "native-build")
    for backend, command in [("JS", ["node", output / "workshop.js"]),
                             ("Native", [output / "workshop.native"])]:
        observed = json.loads(run(command, 5, backend.lower() + "-run"))
        receipt["observations"][backend] = validate(observed)
        (evidence / (backend.lower() + ".json")).write_text(json.dumps(observed, indent=2) + "\n")
    controls = ROOT / "examples/query-composition/array-controls.bend"
    run(["bend", controls, "--check-only"], 5, "array-checker")
    run(["bend", controls, "-o", output / "array-controls.js"], 30, "array-js-emit")
    run(["bend", controls, "-o", output / "array-controls.c"], 30, "array-c-emit")
    run([clang, "-O3", output / "array-controls.c", "-o", output / "array-controls.native",
         "-pthread", "-lm"], 120, "array-native-build")
    expected_arrays = [{"value": 99, "owned": list(range(1, n + 1))} for n in [0, 9, 17]]
    for backend, command in [("JS", ["node", output / "array-controls.js"]),
                             ("Native", [output / "array-controls.native"])]:
        observed = json.loads(run(command, 5, backend.lower() + "-array-run"))
        assert observed == expected_arrays, "Complete dynamic array projection differs"
        receipt["observations"][backend]["dynamicArrayLengths"] = [0, 9, 17]
    for source, digest in receipt["sources"].items():
        assert sha(ROOT / source) == digest, "Source changed during controls"
    receipt["artifacts"] = {name: sha(output / name) for name in
                            ["workshop.js", "workshop.c", "workshop.native",
                             "array-controls.js", "array-controls.c", "array-controls.native"]}
    receipt["status"] = "PASS_FINITE_PUBLIC_APPLICATION_BOTH_BACKENDS"
    (evidence / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps(receipt["observations"]))


if __name__ == "__main__":
    main()
