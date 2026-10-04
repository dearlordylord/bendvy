#!/usr/bin/env python3
"""Bounded probes: explicit checker/runtime 5s; code generation 30s, clang 120s."""
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import tempfile
import time

HERE = Path(__file__).resolve().parent
CHECK = HERE.parent / "t01" / "bend-check"
PHASES = ["pending", "next-schedule", "live", "insert-pending", "inserted", "remove-pending", "removed", "despawn-pending", "stale", "empty-marker"]

def command(args, expected=0, timeout=5):
    p = subprocess.Popen([str(a) for a in args], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, start_new_session=True)
    try:
        out, err = p.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        os.killpg(p.pid, signal.SIGKILL)
        p.communicate()
        raise RuntimeError(str(timeout)+"s limit: " + str(args[0]))
    if p.returncode != expected:
        raise RuntimeError(f"exit {p.returncode}, expected {expected}: {args}\n{out}{err}")
    return out + err

def build(source, folder):
    name = source.stem
    c = folder / (name + ".c")
    native = folder / (name + "-native")
    js = folder / (name + ".js")
    # SPEC bounds the checker, while native code generation and optimization
    # are separate build work. The exact source must pass the explicit 5s gate.
    checked = command([CHECK, source, "--check-only"])
    assert "ALL PROOFS CHECK" in checked, checked
    command(["bend", source, "-o", c], timeout=30)
    command(["clang", "-std=c11", "-O3", c, "-lpthread", "-lm", "-o", native], timeout=120)
    command(["bend", source, "-o", js], timeout=30)
    print("built " + str(source), flush=True)
    return native, js

def execute(binary, args=()):
    if binary.suffix == ".js":
        return command(["node", binary, *args]).rstrip("\n")
    return command([binary, *args, "--threads", "1", "--gpu", "off"]).rstrip("\n")

def paired(programs, args=(), quoted=False):
    values = [execute(p, args) for p in programs]
    assert values[0] == values[1], values
    return json.loads(values[0]) if quoted else values[0]

def copy_mutant(folder, replacements):
    folder.mkdir()
    names = ["lifecycle.bend", "fixture.bend", "queries.bend", "lookups.bend", "foreign.bend", "extras.bend"]
    for name in names:
        text = (HERE / name).read_text()
        def rewrite(match):
            original = (HERE / match.group(1)).resolve()
            target = folder / original.name if original.parent == HERE else original
            path = os.path.relpath(target, folder)
            if not path.startswith("."):
                path = "./" + path
            return "import " + path
        text = re.sub(r"import (\.[^\s]+)", rewrite, text)
        if name == "lifecycle.bend":
            for old, new in replacements:
                assert text.count(old) == 1, old
                text = text.replace(old, new)
        (folder / name).write_text(text)

def main():
    # Optional Linux affinity avoids unrelated parallel test workloads; no process
    # outside this runner is stopped or reprioritized.
    if os.environ.get("BENDVY_CPU") and hasattr(os, "sched_setaffinity"):
        os.sched_setaffinity(0, {int(os.environ["BENDVY_CPU"])})

    with tempfile.TemporaryDirectory(prefix="build-", dir=HERE) as temporary:
        folder = Path(temporary)
        programs = {name: build(HERE / (name + ".bend"), folder) for name in ["queries", "lookups", "foreign", "extras"]}
        reference = command(["node", HERE / "reference.mjs"]).splitlines()
        assert len(reference) == 82, len(reference)
        lines = []
        for stage, phase in enumerate(PHASES):
            for mode, name in enumerate(["Required", "Present", "Absent", "Optional"]):
                text = paired(programs["queries"], [str(stage), str(mode), "0"])
                lines.append(f"{phase}:{name}:{text}")
            for entity, label in enumerate(["a", "b"]):
                for mode, name in enumerate(["Required", "Present"]):
                    text = paired(programs["lookups"], [str(stage), str(mode), str(entity)])
                    lines.append(f"{phase}:lookup-{label}-{name}:{text}")
        assert lines == reference[:80], "ordered lifecycle mismatch"
        print("80 ordered lifecycle observations: native/JS/reference PASS", flush=True)
        collision = paired(programs["foreign"], quoted=True)
        assert collision == "MissingEntity", collision
        assert reference[-1] == "foreign-collision:lookup:match:local:7", reference[-1]
        assert reference[-2] == "foreign:lookup:MissingEntity", reference[-2]
        print("same-schema world collision: approved MissingEntity divergence PASS", flush=True)
        expected = ["MissingEntity", "MissingEntity", "exhausted:4294967295", "exhausted:4294967295", "2:b:2:present{};c:3:absent;", "same:1:absent;same:2:present{};", "local:7:absent;"]
        for case, result in enumerate(expected):
            assert paired(programs["extras"], [str(case)]) == result, (case, result)
        print("7 additional boundary/identity/ownership scenarios PASS", flush=True)
        positive = command([CHECK, HERE / "schema-control.bend", "--check-only"])
        negative = command([CHECK, HERE / "schema-negative.bend", "--check-only"], expected=1)
        assert "ALL PROOFS CHECK" in positive
        assert "SOME PROOFS FAIL" in negative and "HealthToken" in negative and "MotionToken" in negative
        print("paired intended schema rejection PASS", flush=True)
        positive = command([CHECK, HERE / "read-write-control.bend", "--check-only"])
        negative = command([CHECK, HERE / "read-write-negative.bend", "--check-only"], expected=1)
        assert "ALL PROOFS CHECK" in positive
        assert "- expected : A.Cell<S.MotionToken>" in negative and "- observed : P" in negative
        print("paired read-capability write rejection PASS", flush=True)
        mutants = [
            ("foreign-lookup", [("lookup_identity(U32.is_eq(id, world), selection", "lookup_identity(True{}, selection")], "foreign", [], collision, True),
            ("fifo", [("List.reverse(&1, Command, pending)", "pending")], "queries", ["2", "0", "0"], "a:1:absent;b:2:absent;", False),
            ("auto-flush", [("def tick(~Schema: Data, w: World<Schema>) -> World<Schema>:\n  w", "def tick(~Schema: Data, w: World<Schema>) -> World<Schema>:\n  flush(~Schema, w)")], "queries", ["0", "0", "0"], "", False),
            ("foreign-command", [("enqueue_if(~Schema, U32.is_eq(id, world), id", "enqueue_if(~Schema, True{}, id")], "extras", ["6"], "local:7:absent;", False),
        ]
        for name, replacements, entry, args, correct, quoted in mutants:
            mutant = folder / name
            copy_mutant(mutant, replacements)
            mutated = build(mutant / (entry + ".bend"), mutant)
            value = paired(mutated, args, quoted)
            assert value != correct, "surviving compiling mutant: " + name
            print("compiling mutant detected: " + name + " -> " + repr(value), flush=True)
    print("T05 bounded lifecycle gate PASS; no proof or production/performance claim", flush=True)

if __name__ == "__main__":
    main()
