#!/usr/bin/env python3
"""Same-host paired baseline/current regression benchmark with complete outputs."""
import argparse
import gzip
import hashlib
import io
import json
import os
import platform
import random
import shutil
import statistics
import subprocess
import sys
import tarfile
import time
from pathlib import Path
from decision import assess

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner


ROOT = Path(__file__).resolve().parents[1]
HERE = Path(__file__).resolve().parent


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--cpu", type=int, default=min(os.sched_getaffinity(0)))
    parser.add_argument("--inject-slowdown-ms", type=int, default=0,
                        help="Harness negative control only; delay both candidate processes")
    parser.add_argument("--candidate-provider", type=Path,
                        help="Reviewed provider adapter; frozen gameplay and inputs remain unchanged")
    parser.add_argument("--candidate-declarations", default="declarations.bend",
                        choices=("declarations.bend", "owned-declarations.bend"),
                        help="Select the reviewed declaration entry within the provider")
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    os.sched_setaffinity(0, {args.cpu})
    contract = json.loads((HERE / "contract.json").read_text())
    if args.inject_slowdown_ms < 0:
        raise ValueError("Negative injected delay")
    if not args.candidate_provider and args.candidate_declarations != "declarations.bend":
        raise ValueError("Alternate declarations require a provider")
    receipt = {"status": "INCOMPLETE", "contract": contract, "cpu": args.cpu,
               "machine": platform.uname()._asdict(), "commands": [], "pairs": [],
               "versions": {}, "sources": {}, "artifacts": {}, "timings": []}
    receipt["injectedSlowdownMs"] = args.inject_slowdown_ms
    monitored = list((ROOT / "src/ecs").glob("*.bend")) + list(HERE.glob("*.py")) + [HERE / "contract.json"]
    if args.candidate_provider:
        provider = args.candidate_provider.resolve()
        provider_names = ["schema.bend", args.candidate_declarations]
        # Only these reviewed provisioning helpers may supplement the adapter.
        # Driver, gameplay, observation, inputs and the baseline remain archived.
        provider_names += [name for name in ("owned-rows.bend", "reference-declarations.bend")
                           if (provider / name).is_file()]
        monitored += [provider / name for name in provider_names]
        receipt["providerFiles"] = provider_names
        receipt["providerDeclarations"] = args.candidate_declarations
        receipt["candidateProvider"] = str(provider.relative_to(ROOT))
        receipt["scope"] = "Reviewed optimized-provider variant; same frozen baseline gameplay, inputs, observations and statistical contract"
    monitored.append(ROOT/'scripts/task_runner.py')
    initial = {str(p.relative_to(ROOT)): sha(p) for p in monitored}
    receipt["currentSourceHashes"] = initial
    env = os.environ.copy()
    env["BENDVY_CLANG19_ROOT"] = "/tmp/bendvy-clang19-diagnostic/root"

    def save():
        (output / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")

    def run(argv, seconds, label):
        argv = list(map(str, argv))
        started = time.perf_counter_ns()
        result = task_runner.run(argv, timeout=seconds, cwd=ROOT,
                                env=env, capture_output=True)
        elapsed = (time.perf_counter_ns() - started) / 1_000_000
        text = result.stdout.decode()
        receipt["commands"].append({"argv": argv, "limitSeconds": seconds,
                                    "label": label, "exit": result.returncode,
                                    "elapsedMs": elapsed,
                                    "stdoutSHA256": hashlib.sha256(result.stdout).hexdigest()})
        if result.stderr:
            (output / (label + ".stderr")).write_bytes(result.stderr)
        save()
        if result.returncode:
            raise RuntimeError(f"{label}: exit {result.returncode}: {result.stderr.decode()[-1000:]}")
        return text, elapsed

    try:
        for label, command in [("Bend", ["bend", "version"]), ("Node", ["node", "--version"]),
                               ("Clang", ["/tmp/bendvy-clang19-diagnostic/clang19", "--version"])]:
            receipt["versions"][label] = run(command, 5, "version-" + label)[0].strip()
        ref = ROOT / ".references/bevy-ts"
        if run(["git", "-C", ref, "rev-parse", "HEAD"], 5, "reference-head")[0].strip() != contract["referenceCommit"]:
            raise ValueError("Reference commit drift")
        if run(["git", "-C", ref, "status", "--porcelain", "--", "packages/core/src"], 5, "reference-clean")[0].strip():
            raise ValueError("Modified reference sources")
        receipt["referenceHashes"] = {str(p.relative_to(ref)): sha(p)
                                      for p in (ref / "packages/core/src").rglob("*") if p.is_file()}
        archive = task_runner.run(["git", "archive", contract["baselineCommit"], "src/ecs",
                                  "examples/query-composition"], cwd=ROOT, check=True,
                                 capture_output=True, timeout=15).stdout
        receipt["baselineArchiveSHA256"] = hashlib.sha256(archive).hexdigest()
        for role in ("baseline", "candidate"):
            stage = output / role
            stage.mkdir()
            with tarfile.open(fileobj=io.BytesIO(archive)) as contents:
                members = contents.getmembers()
                for member in members:
                    name = Path(member.name)
                    if name.is_absolute() or ".." in name.parts or not (member.isfile() or member.isdir()):
                        raise ValueError("Unsupported archive member: " + member.name)
                contents.extractall(stage, members=members)
            if role == "candidate":
                shutil.rmtree(stage / "src/ecs")
                shutil.copytree(ROOT / "src/ecs", stage / "src/ecs")
                if args.candidate_provider:
                    for name in provider_names:
                        source = provider / name
                        # Rebase only imports when relocating this reviewed adapter.
                        original_parent = source.parent
                        destination = "declarations.bend" if name == args.candidate_declarations else name
                        target = stage / "examples/query-composition" / destination
                        lines = []
                        for line in source.read_text().splitlines():
                            if line.startswith("import "):
                                parts = line.split()
                                if parts[1].endswith(".bend"):
                                    imported = (original_parent / parts[1]).resolve()
                                    if imported.is_relative_to(ROOT / "src/ecs"):
                                        if imported.parent != ROOT / "src/ecs" or imported not in monitored:
                                            raise ValueError("Unmonitored core import: " + parts[1])
                                        parts[1] = "../../src/ecs/" + imported.name
                                        line = " ".join(parts)
                                    elif imported in {provider / n for n in provider_names}:
                                        parts[1] = "declarations.bend" if imported.name == args.candidate_declarations else imported.name
                                        line = " ".join(parts)
                                    elif parts[1] in ("gameplay.bend", "observe.bend"):
                                        # These names always select archived workload files,
                                        # never the provider's local copies.
                                        if not (stage / "examples/query-composition" / parts[1]).is_file():
                                            raise ValueError("Missing archived workload import: " + parts[1])
                                    else:
                                        raise ValueError("Import outside staged provider boundary: " + parts[1])
                            lines.append(line)
                        target.write_text("\n".join(lines) + "\n")

            receipt["sources"][role] = {str(p.relative_to(stage)): sha(p)
                                        for p in stage.rglob("*") if p.is_file()}
        workload = output / "baseline/examples/query-composition"
        expected = json.loads((workload / "expected.json").read_text())
        expected["checkpoints"] = [p for p in expected["checkpoints"] if p["label"] != "foreign-collision-reference"]
        reference = (workload / "reference.mjs").read_text()
        start = reference.index("// Explicit approved world-identity divergence;")
        end = reference.index("const result=", start)
        reference = (reference[:start] + reference[end:]).replace("JSON.stringify(result,null,2)", "JSON.stringify(result)")
        (output / "normative-reference.mjs").write_text(reference)
        (output / "reference.mjs").write_text(f"for(let i=0;i<{contract['iterations']};i++) await import('./normative-reference.mjs?iteration='+i);\n")
        programs = {"TS": ["node", output / "reference.mjs"]}
        for role in ("baseline", "candidate"):
            stage = output / role
            entry = stage / "examples/query-composition/timing-main.bend"
            run(["bend", entry, "--check-only"], 5, role + "-checker")
            run(["bend", entry, "-o", stage / "workshop.js"], 30, role + "-js-emit")
            run(["bend", entry, "-o", stage / "workshop.c"], 30, role + "-c-emit")
            run(["/tmp/bendvy-clang19-diagnostic/clang19", "-O3", stage / "workshop.c",
                 "-o", stage / "workshop.native", "-pthread", "-lm"], 120, role + "-native-build")
            programs[role + "-JS"] = ["node", stage / "workshop.js"]
            programs[role + "-Native"] = [stage / "workshop.native"]
        if args.inject_slowdown_ms:
            for backend in ("JS", "Native"):
                role = "candidate-" + backend
                programs[role] = [sys.executable, HERE / "slowdown-control.py",
                                  args.inject_slowdown_ms, *programs[role]]
        receipt["artifacts"] = {str(p.relative_to(output)): sha(p)
                                 for p in output.rglob("*") if p.is_file() and p.suffix in (".js", ".mjs", ".c", ".native")}

        def measure(role, label):
            text, elapsed = run(programs[role], 5, label)
            lines = text.splitlines()
            if len(lines) != contract["iterations"] or any(json.loads(line) != expected for line in lines):
                raise ValueError("Complete observation mismatch: " + label)
            # All outputs are retained losslessly; no rejected/outlier rows disappear.
            (output / (label + ".stdout.gz")).write_bytes(gzip.compress(text.encode(), mtime=0))
            return elapsed

        for warmup in range(contract["warmups"]):
            for role in programs:
                measure(role, f"warmup-{warmup}-{role}")
        rng = random.Random(contract["seed"])
        orders = {}
        for backend in ("JS", "Native"):
            orders[backend] = [False, True] * (contract["pairs"] // 2)
            rng.shuffle(orders[backend])
        for pair in range(contract["pairs"]):
            groups = [["TS"]]
            for backend in ("JS", "Native"):
                roles = ["baseline-" + backend, "candidate-" + backend]
                groups.append(list(reversed(roles)) if orders[backend][pair] else roles)
            rng.shuffle(groups)
            order = [role for group in groups for role in group]
            clocks = {role: measure(role, f"pair-{pair}-{role}") for role in order}
            receipt["timings"].append({"pair": pair, "order": order, "milliseconds": clocks})
            for backend in ("JS", "Native"):
                receipt["pairs"].append({"pair": pair, "backend": backend,
                                         "baselineMs": clocks["baseline-" + backend],
                                         "candidateMs": clocks["candidate-" + backend]})
            save()
        for relative, digest in initial.items():
            if sha(ROOT / relative) != digest:
                raise ValueError("Source changed during benchmark: " + relative)
        current = list((ROOT / "src/ecs").glob("*.bend")) + list(HERE.glob("*.py")) + [HERE / "contract.json"]
        if args.candidate_provider:
            final_provider_names = ["schema.bend", args.candidate_declarations] + [
                name for name in ("owned-rows.bend", "reference-declarations.bend")
                if (provider / name).is_file()]
            current += [provider / name for name in final_provider_names]
        if {str(p.relative_to(ROOT)) for p in current} != set(initial):
            raise ValueError("Current source inventory changed during benchmark")
        for role in ("baseline", "candidate"):
            stage = output / role
            frozen = {str(p.relative_to(stage)): sha(p)
                      for folder in (stage / "src/ecs", stage / "examples/query-composition")
                      for p in folder.rglob("*") if p.is_file()}
            if frozen != receipt["sources"][role]:
                raise ValueError("Staged source drift: " + role)
        for relative, digest in receipt["artifacts"].items():
            if sha(output / relative) != digest:
                raise ValueError("Artifact changed during benchmark: " + relative)
        final_reference = {str(p.relative_to(ref)): sha(p)
                           for p in (ref / "packages/core/src").rglob("*") if p.is_file()}
        if final_reference != receipt["referenceHashes"]:
            raise ValueError("Reference changed during benchmark")
        result = assess(receipt["pairs"], contract["pairs"], contract["alpha"])
        medians = {role: statistics.median(r["milliseconds"][role] for r in receipt["timings"]) for role in programs}
        receipt.update(result, mediansMs=medians,
                       descriptiveTargets={"JS/TS": medians["candidate-JS"] / medians["TS"],
                                           "Native/TS": medians["candidate-Native"] / medians["TS"]})
        save()
        print(json.dumps({"status": receipt["status"], "endpoints": receipt["endpoints"],
                          "descriptiveTargets": receipt["descriptiveTargets"]}))
        return 1 if receipt["status"] == "REGRESSION" else 0
    except Exception as error:
        receipt.update(status="ERROR", error=str(error))
        save()
        raise


if __name__ == "__main__":
    raise SystemExit(main())
