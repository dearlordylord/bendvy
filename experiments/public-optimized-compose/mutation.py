"""Reach a compiling selected-route current-owner recovery omission."""
import hashlib
import json
import os
import pathlib
import shutil
import subprocess
import tempfile
from freeze import ROOT

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
from task_runner import run as _run_command


old = "Array.set(Maybe<&1,C>,values,U32.sub(current,1),owner)"
new = "Array.set(Maybe<&1,C>,values,U32.sub(current,1),None{})"
with tempfile.TemporaryDirectory(prefix="bendvy-compose30-mutant-") as temporary:
    stage = pathlib.Path(temporary)
    shutil.copytree(ROOT / "src/ecs", stage / "src/ecs")
    shutil.copytree(ROOT / "experiments/public-optimized-compose/workshop",
                    stage / "experiments/public-optimized-compose/workshop")
    column = stage / "src/ecs/column.bend"
    source = column.read_text()
    assert source.count(old) == 1
    column.write_text(source.replace(old, new))
    main = stage / "experiments/public-optimized-compose/workshop/main.bend"
    originals = {str(p.relative_to(stage)): hashlib.sha256(p.read_bytes()).hexdigest()
                 for p in sorted((stage / "src/ecs").glob("*.bend"))}
    originals["src/ecs/column.bend"] = hashlib.sha256(source.encode()).hexdigest()
    fixture_hashes = {str(p.relative_to(stage)): hashlib.sha256(p.read_bytes()).hexdigest()
                      for p in sorted((stage / "experiments/public-optimized-compose/workshop").glob("*.bend"))}
    receipt = {"mutation": "drop active owner during final selected-route recovery",
               "originalColumnSHA256": hashlib.sha256(source.encode()).hexdigest(),
               "mutantColumnSHA256": hashlib.sha256(column.read_bytes()).hexdigest(),
               "sourceHashes": originals, "fixtureHashes": fixture_hashes,
               "runnerSHA256": hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(),
               "commands": [], "backends": {}, "status": "INCOMPLETE"}
    env = dict(os.environ, BENDVY_CLANG19_ROOT="/tmp/bendvy-clang19-diagnostic/root")
    def run(command, limit):
        result = _run_command(command, timeout=limit, capture_output=True, text=True, env=env)
        receipt["commands"].append({"command": command, "limit": limit,
                                    "exit": result.returncode, "stdout": result.stdout,
                                    "stderr": result.stderr})
        assert result.returncode == 0, result.stderr
        return result.stdout
    run(["bend", str(main), "--check-only"], 5)
    expected = json.loads((ROOT / "examples/query-composition/expected.json").read_text())
    for backend in ["JS", "Native"]:
        generated = stage / ("mutant.js" if backend == "JS" else "mutant.c")
        run(["bend", str(main), "-o", str(generated)], 30)
        artifact_hashes = {generated.name: hashlib.sha256(generated.read_bytes()).hexdigest()}
        if backend == "Native":
            binary = stage / "mutant"
            run(["/tmp/bendvy-clang19-diagnostic/clang19", "-O3", str(generated),
                 "-o", str(binary), "-pthread", "-lm"], 120)
            artifact_hashes[binary.name] = hashlib.sha256(binary.read_bytes()).hexdigest()
            command = [str(binary)]
        else:
            command = ["node", str(generated)]
        stdout = run(command, 5)
        evidence = {"artifactHashes": artifact_hashes}
        try:
            observed = json.loads(stdout)
        except json.JSONDecodeError as error:
            evidence["observationFailure"] = {"error": str(error), "offset": error.pos,
                                               "near": stdout[max(0,error.pos-80):error.pos+80]}
        else:
            differences = [a["label"] for a, b in zip(observed["checkpoints"], expected["checkpoints"])
                           if a["label"] != "foreign-collision-reference" and a != b]
            labels = [a["label"] for a in observed["checkpoints"]]
            expected_labels = [a["label"] for a in expected["checkpoints"]]
            assert differences or labels != expected_labels, "Mutant did not change a full observation"
            evidence["changedNormativeCheckpoints"] = differences
            evidence["labelsMatch"] = labels == expected_labels
        evidence["status"] = "DETECTED"
        receipt["backends"][backend] = evidence
    for name, digest in {**originals, **fixture_hashes}.items():
        assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest, "Live closure drift: " + name
    receipt["status"] = "DETECTED_BOTH"
    print(json.dumps(receipt, indent=2))
