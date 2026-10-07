from pathlib import Path
import fcntl
import hashlib
import json
import os
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
sys.path.insert(0, str(ROOT / "scripts"))
from task_runner import execute_result

binding = json.loads((HERE / "stage-binding.json").read_text())
observed = {str(path.relative_to(HERE / "tree")) for path in (HERE / "tree").rglob("*") if path.is_file()}
assert observed == set(binding["stage"]), "source stage membership drift"
for name, want in binding["stage"].items():
    assert hashlib.sha256((HERE / "tree" / name).read_bytes()).hexdigest() == want, name
out = HERE / "source-controls"
out.mkdir(exist_ok=False)
results = []
with open("/tmp/bendvy-parity-heavy.lock", "a") as lock:
    for source in binding["entrypoints"]:
        fcntl.flock(lock, fcntl.LOCK_EX)
        try:
            result = execute_result(["bend", str(HERE / "tree" / source), "--check-only"], 5, env=os.environ.copy(), cwd=ROOT, capture="split")
        finally:
            fcntl.flock(lock, fcntl.LOCK_UN)
        label = Path(source).stem
        for stream in ("stdout", "stderr"):
            (out / (label + "." + stream)).write_bytes(result[stream])
        results.append({"source": source, "exit": result["exit"], "failure": result["failure"], "stdoutSha256": hashlib.sha256(result["stdout"]).hexdigest(), "stderrSha256": hashlib.sha256(result["stderr"]).hexdigest()})
        print(label, result["exit"], result["failure"], flush=True)
        (out / "results.json").write_text(json.dumps({"status": "UNCLASSIFIED_SOURCE_OBSERVATIONS_NOT_PROOF", "sourceBindingSha256": hashlib.sha256((HERE / "stage-binding.json").read_bytes()).hexdigest(), "results": results}, indent=2) + "\n")
        if result["failure"] is not None:
            break
