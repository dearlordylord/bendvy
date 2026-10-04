#!/usr/bin/env python3
"""Actual large owner-return mark filtering and independent boundary controls."""
import hashlib
import json
import pathlib
import re
import shutil
import sys
import tempfile

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "t05"))
from run import build, paired

EXPECTED = "\n".join([
    "[1:4|true|Some(false)|Some(selected=9)]",
    "[1:1|true|Some(true)|Some(selected=8)]",
    "[1:1|true|Some(true)|Some(selected=8)]",
    "[1:1|true|Some(true)|Some(selected=8), 1:4|true|Some(false)|Some(selected=9)]",
    "[1:4|true|Some(false)|Some(selected=9)]", "[]",
])
MUTANTS = [
    ("include-since-boundary", "U32.is_gt(tick,since)", "U32.is_ge(tick,since)"),
    ("exclude-this-run-boundary", "U32.is_le(tick,thisRun)", "U32.is_lt(tick,thisRun)"),
    ("swap-mark-kind", "marked_case(equal,changed,added,last,0)", "marked_case(equal,Bool.not(changed),added,last,0)"),
    ("reverse-filtered-order", "List.reverse(&2,O.QueryRow<Schema,V,AV,F>,reverse)", "reverse"),
]


def closure():
    pending = ["host-mark-controls.bend", "host-mark-boundary-controls.bend"]
    result = set()
    while pending:
        name = pending.pop()
        if name in result:
            continue
        result.add(name)
        pending.extend(re.findall(r"^import \./([^\s]+\.bend)", (HERE / name).read_text(), re.MULTILINE))
    return sorted(result)


def copy(folder, names):
    folder.mkdir()
    for name in names:
        shutil.copyfile(HERE / name, folder / name)


def main():
    names = closure()
    evidence = {"scope": "actual mark filter prerequisite, not full E11 or performance acceptance",
                "checkerLimitSeconds": 5, "runtimeLimitSeconds": 5, "cases": [], "mutants": []}
    with tempfile.TemporaryDirectory(prefix="host-mark-") as temporary:
        base = pathlib.Path(temporary)
        original = base / "original"
        copy(original, names)
        programs = build(original / "host-mark-controls.bend", original)
        for schema, number in (("Motion", 0), ("Health", 1)):
            for count in (1, 17, 65537):
                assert paired(programs, [str(number), str(count)]) == "true", (schema, count)
                evidence["cases"].append({"schema": schema, "count": count, "nativeJsEqual": True})
                print(schema, count, "PASS", flush=True)
        boundary = paired(build(original / "host-mark-boundary-controls.bend", original), quoted=True)
        assert boundary == EXPECTED, boundary
        evidence["boundary"] = {"completeEqual": True, "observed": boundary}
        for label, old, new in MUTANTS:
            folder = base / label
            copy(folder, names)
            target = folder / "host.bend"
            source = target.read_text()
            assert source.count(old) == 1, (label, source.count(old))
            target.write_text(source.replace(old, new))
            observed = paired(build(folder / "host-mark-boundary-controls.bend", folder), quoted=True)
            assert observed != EXPECTED, label
            evidence["mutants"].append({"name": label, "compilingNativeJs": True, "observed": observed})
            print(label, "DETECTED", flush=True)
    evidence["sources"] = {name: hashlib.sha256((HERE / name).read_bytes()).hexdigest()
                           for name in names + ["host-mark-run.py", "HOST-MARK-LAWS-DRAFT.md"]}
    (HERE / "host-mark-evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")
    print("HOST MARK PASS; original baseline failures retained separately", flush=True)


if __name__ == "__main__":
    main()
