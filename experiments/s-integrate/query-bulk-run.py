#!/usr/bin/env python3
"""Actual full-field provider/world reads at the public retention input size."""
import hashlib
import json
import pathlib
import shutil
import sys
import tempfile

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "t05"))
from run import build, paired

NAMES = ["query-bulk-controls.bend", "query.bend", "observations.bend",
         "types.bend", "storage.bend", "identity.bend", "commands.bend",
         "payload.bend", "commands-bulk-controls.bend", "storage-stage-fixture.bend"]
MUTANTS = [
    ("reverse-query-observations", "query.bend", "List.reverse(&2,O,values)", "values"),
    ("reverse-returned-owned-rows", "query.bend", "List.reverse(&1,S.Row<M,A,F>,rows)", "rows"),
    ("reverse-world-observations", "observations.bend",
     "List.reverse(&2,RowView<V,AV,F>,values)", "values"),
]


def copy(folder):
    folder.mkdir()
    for name in NAMES:
        shutil.copyfile(HERE / name, folder / name)


def main():
    evidence = {"scope": "actual query and owner-return world-read prerequisite; not full E11",
                "checkerLimitSeconds": 5, "runtimeLimitSeconds": 5,
                "cases": [], "mutants": []}
    with tempfile.TemporaryDirectory(prefix="query-bulk-") as temporary:
        base = pathlib.Path(temporary)
        original = base / "original"
        copy(original)
        programs = build(original / NAMES[0], original)
        for schema, number in (("Motion", 0), ("Health", 1)):
            for count in (1, 17, 65537):
                output = paired(programs, [str(number), str(count)])
                assert output == "true", (schema, count, output)
                evidence["cases"].append({"schema": schema, "count": count,
                                          "nativeJsEqual": True, "allFieldsChecked": True})
                print(schema, count, "PASS", flush=True)
        for label, file, old, new in MUTANTS:
            folder = base / label
            copy(folder)
            target = folder / file
            text = target.read_text()
            assert text.count(old) == 1, (label, text.count(old))
            target.write_text(text.replace(old, new))
            output = paired(build(folder / NAMES[0], folder), ["0", "17"])
            assert output == "false", (label, output)
            evidence["mutants"].append({"name": label, "compilingNativeJs": True,
                                        "detectedOnBothBackends": True})
            print(label, "DETECTED", flush=True)
    evidence["sources"] = {name: hashlib.sha256((HERE / name).read_bytes()).hexdigest()
                           for name in NAMES + ["query-bulk-run.py", "QUERY-BULK-LAWS-DRAFT.md"]}
    (HERE / "query-bulk-evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")
    print("QUERY BULK PASS; no full schedule, retention or performance acceptance", flush=True)


if __name__ == "__main__":
    main()
