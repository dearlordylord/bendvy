"""Fresh source-bound Workshop and affine-owner integration observations."""
import argparse
import hashlib
import importlib.util
import json
import os
import pathlib
import shutil
import subprocess
from freeze import ROOT

parser = argparse.ArgumentParser()
parser.add_argument("--output", type=pathlib.Path, required=True)
args = parser.parse_args()
output = args.output.resolve()
output.mkdir(parents=True, exist_ok=False)
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
def sources():
    paths = list((ROOT / "src/ecs").glob("*.bend"))
    paths += list((ROOT / "experiments/public-optimized-compose").rglob("*.bend"))
    return {str(p.relative_to(ROOT)): digest(p) for p in sorted(paths)}
receipt = {"sourceHashes": sources(), "runnerSHA256": digest(pathlib.Path(__file__)), "commands": [], "status": "INCOMPLETE"}
env = dict(os.environ, BENDVY_CLANG19_ROOT="/tmp/bendvy-clang19-diagnostic/root")
def run(label, command, limit):
    result = subprocess.run(command, timeout=limit, capture_output=True, text=True, env=env)
    (output / (label + ".stdout")).write_text(result.stdout)
    (output / (label + ".stderr")).write_text(result.stderr)
    receipt["commands"].append({"label": label, "command": list(map(str, command)),
                                "limit": limit, "exit": result.returncode,
                                "stdoutSHA256": hashlib.sha256(result.stdout.encode()).hexdigest()})
    assert result.returncode == 0, result.stderr
    return result.stdout
spec = importlib.util.spec_from_file_location("workshop_verify", ROOT / "examples/query-composition/verify.py")
verifier = importlib.util.module_from_spec(spec)
spec.loader.exec_module(verifier)
try:
    receipt["bendVersion"] = run("version", ["bend", "version"], 5).strip()
    for case, expected in [("workshop/main", None),
                           ("prepared-control", [[3,7],[41,43],[11,19],[3,7],[100,200],[3,7],[11,19]]),
                           ("refusal-control", [[41,43],[3,7],[11,19]]),
                           ("wrapped-prepared-control", [[3,7],[41,43],[11,19],[3,7],[100,200],[3,7],[11,19]]),
                           ("wrapped-refusal-control", [[41,43],[3,7],[11,19]]),
                           ("wrapped-recovery-control", [[3,7],[11,19]]),
                           ("producer-fuel-control", "PAIRED_PRODUCER"),
                           ("view-fuel-control", "PAIRED_VIEW"),
                           ("get-validation-control", "PAIRED_GET"),
                           ("tx-set-refusal-control", [[1,4294967295,0,1,1,1,1,41,43,3,7,5,9]]*2 + [[2,4294967295,0,1,1,1,1,41,43,3,7,5,9]]*2 + [[2,8,0,1,1,1,1,41,43,3,7,5,9]]*2)]:
        source = ROOT / "experiments/public-optimized-compose" / (case + ".bend")
        label = case.replace("/", "-")
        run(label + "-check", ["bend", source, "--check-only"], 5)
        for backend in ["JS", "Native"]:
            generated = output / (label + (".js" if backend == "JS" else ".c"))
            run(label + "-emit-" + backend, ["bend", source, "-o", generated], 30)
            receipt.setdefault("generatedHashes", {})[generated.name] = digest(generated)
            if backend == "Native":
                binary = output / label
                run(label + "-compile", ["/tmp/bendvy-clang19-diagnostic/clang19", "-O3",
                                          generated, "-o", binary, "-pthread", "-lm"], 120)
                receipt.setdefault("binaryHashes", {})[binary.name] = digest(binary)
                command = [binary]
            else:
                command = ["node", generated]
            observed = json.loads(run(label + "-run-" + backend, command, 5))
            if expected is None:
                verifier.validate(observed)
            elif expected == "PAIRED_GET":
                assert len(observed) == 48 and all(observed[i] == observed[i+1] for i in range(0,48,2)), observed
            elif expected == "PAIRED_VIEW":
                assert len(observed) == 102 and all(observed[i] == observed[i+1] for i in range(0,102,2)), observed
            elif expected == "PAIRED_PRODUCER":
                assert len(observed) == 84 and all(observed[i] == observed[i+1] for i in range(0,84,2)), observed
            else:
                assert observed == expected, observed
    assert sources() == receipt["sourceHashes"], "Source closure changed during observation"
    receipt["status"] = "PASS"
finally:
    (output / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
print(json.dumps({"status": receipt["status"], "cases":10, "backends":["JS","Native"]}))
