#!/usr/bin/env python3
"""Reviewed bounded whole-process comparison; no canonical optimization loop."""
import argparse
import gzip
import hashlib
import json
import os
import statistics
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ITERATIONS = 10
ORDER = ["TS", "JS", "Native", "JS", "Native", "TS", "Native", "TS", "JS",
         "TS", "Native", "JS", "JS", "TS", "Native"]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--evidence", type=Path, required=True)
    parser.add_argument("--cpu", type=int, default=8)
    args = parser.parse_args()
    output, evidence = args.output.resolve(), args.evidence.resolve()
    output.mkdir(parents=True, exist_ok=True)
    evidence.mkdir(parents=True, exist_ok=True)
    os.sched_setaffinity(0, {args.cpu})
    sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    receipt = {"status": "INCOMPLETE", "scope": "Informational whole-process generic API comparison",
               "iterations": ITERATIONS, "cpu": args.cpu, "order": ORDER,
               "commands": [], "rows": [], "sources": {}}
    for directory in [ROOT / "src/ecs", ROOT / "examples/user-simulation"]:
        for source in directory.glob("*.bend"):
            receipt["sources"][str(source.relative_to(ROOT))] = sha(source)
    expected = json.loads((ROOT / "examples/user-simulation/expected.json").read_text())
    expected["checkpoints"] = [p for p in expected["checkpoints"]
                                if p["label"] != "foreign-collision-reference"]
    reference = ROOT / "examples/user-simulation/reference.mjs"
    text = reference.read_text()
    start = text.index("// Root brands are compile-time TS boundaries;")
    end = text.index("const despawn=", start)
    # Preserve the frozen reference. The only removed operations are the
    # intentionally different foreign-world probe, independently verified first.
    text = text[:start] + text[end:]
    text = text.replace("JSON.stringify(result,null,2)", "JSON.stringify(result)")
    normative = output / "normative-reference.mjs"
    normative.write_text(text)
    ts_entry = output / "timing-reference.mjs"
    ts_entry.write_text(f"for(let i=0;i<{ITERATIONS};i++) await import('./normative-reference.mjs?iteration='+i);\n")
    env = os.environ.copy()
    env["BENDVY_CLANG19_ROOT"] = "/tmp/bendvy-clang19-diagnostic/root"

    def save():
        (evidence / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")

    def command(argv, cap, label):
        argv = list(map(str, argv))
        started = time.perf_counter_ns()
        proc = subprocess.run(["timeout", f"{cap}s", *argv], cwd=ROOT, env=env,
                              text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        elapsed = (time.perf_counter_ns() - started) / 1_000_000
        receipt["commands"].append({"argv": argv, "limit": cap, "exit": proc.returncode,
                                    "label": label, "stderr": proc.stderr,
                                    "elapsedMs": elapsed})
        save()
        if proc.returncode:
            raise RuntimeError(f"{label} failed: {proc.returncode}")
        return proc.stdout

    entry = ROOT / "examples/user-simulation/timing-main.bend"
    command(["bend", entry, "--check-only"], 5, "checker")
    command(["bend", entry, "-o", output / "timing.js"], 30, "js-emit")
    command(["bend", entry, "-o", output / "timing.c"], 30, "c-emit")
    command(["/tmp/bendvy-clang19-diagnostic/clang19", "-O3", output / "timing.c",
             "-o", output / "timing.native", "-pthread", "-lm"], 120, "native-build")
    programs = {"TS": ["node", ts_entry], "JS": ["node", output / "timing.js"],
                "Native": [output / "timing.native"]}
    # Untimed complete-output controls for each compiled route.
    for backend, argv in programs.items():
        lines = command(argv, 5, backend + "-control").splitlines()
        assert len(lines) == ITERATIONS and all(json.loads(line) == expected for line in lines)
    for index, backend in enumerate(ORDER):
        observed = command(programs[backend], 5, f"row-{index}-{backend}")
        elapsed = receipt["commands"][-1]["elapsedMs"]
        lines = observed.splitlines()
        valid = len(lines) == ITERATIONS and all(json.loads(line) == expected for line in lines)
        filename = f"row-{index}-{backend}.stdout.gz"
        (evidence / filename).write_bytes(gzip.compress(observed.encode(), mtime=0))
        receipt["rows"].append({"backend": backend, "elapsedMs": elapsed,
                                "valid": valid, "output": filename,
                                "outputSha256": hashlib.sha256(observed.encode()).hexdigest()})
        save()
        if not valid:
            raise AssertionError("Timed full observation mismatch")
    for source, digest in receipt["sources"].items():
        assert sha(ROOT / source) == digest, "Source changed during cohort"
    medians = {b: statistics.median(r["elapsedMs"] for r in receipt["rows"] if r["backend"] == b)
               for b in programs}
    receipt.update(status="PASS_BOUNDED_INFORMATIONAL_COHORT", mediansMs=medians,
                   ratios={"JS/TS": medians["JS"] / medians["TS"],
                           "Native/TS": medians["Native"] / medians["TS"]},
                   artifacts={p.name: sha(p) for p in [reference, normative, ts_entry,
                                                       output / "timing.js", output / "timing.c",
                                                       output / "timing.native"]})
    save()
    print(json.dumps({"mediansMs": medians, "ratios": receipt["ratios"]}))


if __name__ == "__main__":
    main()
