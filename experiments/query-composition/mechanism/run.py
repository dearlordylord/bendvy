#!/usr/bin/env python3
"""Fresh instantiated mechanism checks; no law/proof or performance acceptance."""
from pathlib import Path
import json
import subprocess
import tempfile

root = Path(__file__).resolve().parents[3]

def run(argv):
    result = subprocess.run(["timeout", "5s", *map(str, argv)], cwd=root,
                            text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(f"{argv}: exit {result.returncode}\n{result.stdout}{result.stderr}")
    return result.stdout.strip()

print(run(["bend", "version"]))
run(["bend", "guide"])
for module in ("capabilities", "compose"):
    verdict = run(["bend", f"src/ecs/{module}.bend"])
    assert "ALL PROOFS CHECK" in verdict, verdict
with tempfile.TemporaryDirectory(prefix="bendvy-composition-mechanism-") as tmp:
    for name, expected in (("positive", "19|2|ok|7@1,19@2,"),
                           ("failure", "7|0|failed|")):
        source = f"experiments/query-composition/mechanism/{name}.bend"
        expected_text = json.dumps(expected)
        assert run(["bend", source]) == expected_text
        native = Path(tmp) / name
        js = Path(tmp) / f"{name}.mjs"
        run(["bend", source, "-o", native])
        run(["bend", source, "-o", js])
        assert run([native, "--threads", "1", "--gpu", "off"]) == expected_text
        script = f"import M from {json.dumps(js.as_uri())}; console.log(JSON.stringify(M.main()));"
        assert run(["node", "--input-type=module", "-e", script]) == expected_text
        print(f"{name}: checker, JS, Native {expected_text}")
