#!/usr/bin/env python3
"""Finite consumer controls; checker commands always have a five-second limit."""
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EXPECTED = "SSSSFS:position1,position2,health1,health2=8,14,21,5,events=6"
receipt = {"base_public_pin": "7279c98", "restricted_damage_change": "2a31548", "commands": []}


def run(argv, expected_code=0, contains=None):
    start = time.monotonic()
    result = subprocess.run(argv, cwd=ROOT, capture_output=True, text=True, timeout=15)
    output = result.stdout + result.stderr
    receipt["commands"].append({"argv": argv, "exit": result.returncode,
        "seconds": round(time.monotonic() - start, 4), "output": output})
    assert result.returncode == expected_code, output
    if contains:
        assert contains in output, output
    return result.stdout.strip()


run(["bend", "version"])
run(["node", "--version"])
source = str((HERE / "arena.bend").relative_to(ROOT))
run(["timeout", "5s", "bend", source], contains=EXPECTED)
with tempfile.TemporaryDirectory(prefix="bendvy-fresh-consumer-") as tmp:
    binary = str(Path(tmp) / "arena")
    module = str(Path(tmp) / "arena.mjs")
    c_source = str(Path(tmp) / "arena.c")
    run(["timeout", "5s", "bend", source, "-o", c_source])
    run(["clang", "-O2", "-pthread", c_source, "-lm", "-o", binary])
    assert run([binary, "--threads", "1"]) == EXPECTED
    run(["timeout", "5s", "bend", source, "-o", module])
    script = "import Arena from " + json.dumps(module) + "; console.log(Arena.scenario())"
    assert run(["node", "--input-type=module", "-e", script]) == EXPECTED

for name in ["cross_schema", "owned_copy", "read_write", "registry_rebind", "undeclared"]:
    path = str((HERE / ("negative_" + name + ".bend")).relative_to(ROOT))
    run(["timeout", "5s", "bend", path], expected_code=1, contains="- expected :")

receipt["source_sha256"] = {
    str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
    for path in sorted(list((ROOT / "src/ecs").glob("*.bend")) + list(HERE.glob("*.bend")))
}
(HERE / "evidence").mkdir(exist_ok=True)
(HERE / "evidence/results.json").write_text(json.dumps(receipt, indent=2) + "\n")
print("Consumer checker, native, JavaScript and five negative controls passed.")
