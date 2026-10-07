from pathlib import Path
import hashlib
import json
import zipfile

HERE = Path(__file__).resolve().parent
BASE = HERE.parent
sha = lambda raw: hashlib.sha256(raw).hexdigest()
m = json.loads((HERE / "DELIVERY.json").read_text())
for name, expected in m["selectedLiveFiles"].items():
    assert sha((HERE / name).read_bytes()) == expected, name
assert sha((HERE / "evidence-v1.zip").read_bytes()) == m["archiveSha256"]
with zipfile.ZipFile(HERE / "evidence-v1.zip") as archive:
    assert set(archive.namelist()) == set(m["archiveEntries"])
    for name, expected in m["archiveEntries"].items():
        assert sha(archive.read(name)) == expected, name
    assert not any("environment" in Path(name).name or name.endswith(".native") for name in archive.namelist())
    prefix = "canonical-mutant-v1/"
    plan = json.loads(archive.read(prefix + "execution-plan.json"))
    receipt = json.loads(archive.read(prefix + "execution/receipt.json"))
    assert sha(archive.read(prefix + "execution-plan.json")) == m["planSha256"] == receipt["planSHA256"]
    assert sha(archive.read(prefix + "execution/receipt.json")) == m["receiptSha256"]
    assert receipt["status"] == "CANONICAL_OMITTED_VALUE_REACHED_COMPLETE22_JS_NATIVE_FINITE_CONTROL_PASS"
    assert len(plan["commands"]) == len(receipt["commands"]) == 6
    assert [row["seconds"] for row in plan["commands"]] == [5, 30, 5, 30, 120, 5]
    assert len(receipt["toolGuardSnapshots"]) == 13
    assert len(receipt["probeCommands"]) == 52 and len(plan["preparationProbeResults"]) == 4
    binding = json.loads((BASE / "canonical-source-v2/stage-binding.json").read_text())
    assert plan["normalSourceFiles"] == binding["stage"]
    expected_stage = dict(binding["stage"])
    assert len(plan["changes"]) == 2
    with zipfile.ZipFile(BASE / "canonical-source-v2/source-stage.zip") as sources:
        assert set(sources.namelist()) == set(binding["stage"])
        for name, change in plan["changes"].items():
            raw = sources.read(name)
            assert sha(raw) == change["baseSha256"]
            text = raw.decode()
            assert text.count(change["replace"]) == 1
            assert sha(text.replace(change["replace"], change["withText"]).encode()) == change["mutantSha256"]
            expected_stage[name] = change["mutantSha256"]
    assert len(expected_stage) == 59 and receipt["stagedInputs"] == plan["stageFiles"] == expected_stage
    for index, command in enumerate(receipt["commands"]):
        expected_exit = 1 if index == 0 else 0
        assert command["exit"] == command["result"]["exit"] == expected_exit
        assert command["failure"] is None and command["result"]["failure"] is None
        for stream in ("stdout", "stderr"):
            name = command["label"] + "." + stream
            assert bytes.fromhex(command["result"][stream]["rawHex"]) == archive.read(prefix + "execution/" + name)
    diagnostic = archive.read(prefix + "execution/mutant-source.stderr")
    expected_diagnostic = (BASE / "expected-check-only.stderr").read_bytes()
    assert diagnostic in (expected_diagnostic, expected_diagnostic + b"bend 2.0.36 is available: run bend update\n")
    assert not archive.read(prefix + "execution/mutant-source.stdout")
    for name, expected in receipt["rawLogs"].items():
        assert sha(archive.read(prefix + "execution/" + name)) == expected
    for name, expected in receipt["generated"].items():
        if name.endswith(".native"):
            assert m["hashOnlyExcludedBinaries"][name]["sha256"] == expected
        else:
            assert sha(archive.read(prefix + "execution/" + name)) == expected
    oracle = (BASE / "expected-omitted-value.stdout").read_bytes()
    normal = (BASE / "expected.stdout").read_bytes()
    assert sha(oracle) == plan["completeIndependentMutantOracleSha256"]
    for kind in ("JS", "Native"):
        raw = archive.read(prefix + "execution/mutant-" + kind + "-full22.stdout")
        assert raw == oracle and raw != normal and len(raw.splitlines()) == 22
        folder = "canonical-" + kind.lower() + "-v1"
        normal_plan_raw = archive.read("normal/" + folder + "/execution-plan.json")
        normal_receipt_raw = archive.read("normal/" + folder + "/execution/receipt.json")
        normal_plan = json.loads(normal_plan_raw)
        normal_receipt = json.loads(normal_receipt_raw)
        assert normal_receipt["planSHA256"] == sha(normal_plan_raw)
        assert normal_plan["stageFiles"] == normal_receipt["stagedInputs"] == binding["stage"]
        assert normal_receipt["status"] == "CANONICAL_CORE_OWNED_REQUEST_COMPLETE22_AND20_" + kind.upper() + "_FINITE_PASS"
        consumer = next(row for row in normal_receipt["commands"] if row["label"] == "full22-" + kind + "-consumer")
        assert consumer["exit"] == 0 and consumer["failure"] is None
        assert bytes.fromhex(consumer["result"]["stdout"]["rawHex"]) == normal
    diff = json.loads(archive.read(prefix + "DIFF.json"))
    changed = [i + 1 for i, (a, b) in enumerate(zip(normal.splitlines(), oracle.splitlines())) if a != b]
    assert [row["row"] for row in diff["changedRows"]] == changed
    assert diff["sourceChanges"] == plan["changes"]
print("PASS: exact two installer mutations, expected source IO boundary and actual full22 JS/Native defect traces; normal59 bindings preserved; no proof/performance/adoption claim")
