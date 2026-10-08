from pathlib import Path
import hashlib
import json
import zipfile

HERE = Path(__file__).resolve().parent
BASE = HERE.parent
sha = lambda raw: hashlib.sha256(raw).hexdigest()
m = json.loads((HERE / "FINITE-DELIVERY.json").read_text())
for name, expected in m["selectedLiveFiles"].items():
    assert sha((HERE / name).read_bytes()) == expected, name
assert sha((HERE / "evidence-v1.zip").read_bytes()) == m["archiveSha256"]
with zipfile.ZipFile(HERE / "evidence-v1.zip") as archive:
    assert set(archive.namelist()) == set(m["archiveEntries"])
    for name, expected in m["archiveEntries"].items():
        assert sha(archive.read(name)) == expected, name
    assert not any("environment" in Path(name).name for name in archive.namelist())
    prefix = "production-controls-v3/"
    plan_raw = archive.read(prefix + "execution-plan.json")
    receipt_raw = archive.read(prefix + "execution/receipt.json")
    plan = json.loads(plan_raw)
    receipt = json.loads(receipt_raw)
    assert sha(plan_raw) == m["planSha256"] == receipt["planSHA256"]
    assert sha(receipt_raw) == m["receiptSha256"]
    assert receipt["status"] == "PRODUCTION68_SUPPORT_EIGHT_NEGATIVES_TWO_IO_BOUNDARIES_MATCH_NOT_PROOF_NOT_RUNTIME"
    assert len(plan["commands"]) == len(receipt["commands"]) == 11
    assert all(row["seconds"] == 5 for row in plan["commands"])
    assert len(receipt["toolGuardSnapshots"]) == 23 and len(receipt["probeCommands"]) == 46
    assert len(plan["preparationProbeResults"]) == plan["snapshotReuse"]["ordinaryPreparationProbesInherited"] == 2
    binding = json.loads((BASE / "production-rewire-v1/BINDING.json").read_text())
    assert len(binding["stage"]) == 68 and binding["stage"] == plan["stageFiles"] == receipt["stagedInputs"]
    with zipfile.ZipFile(BASE / "production-rewire-v1/source-stage.zip") as stage:
        assert set(stage.namelist()) == set(binding["stage"])
        assert all(sha(stage.read(n)) == v for n, v in binding["stage"].items())
    proposal = json.loads(archive.read(prefix + "PLAN.json"))
    assert len(proposal["rootProductionPins"]) == 26
    for name, expected in proposal["rootProductionPins"].items():
        relative = name.split("/bendvy/", 1)[1]
        assert plan["files"][name] == expected == binding["stage"][relative]
    notice = b"bend 2.0.36 is available: run bend update\n"
    for intended, observed in zip(plan["commands"], receipt["commands"]):
        assert intended["label"] == observed["label"]
        assert observed["exit"] == observed["result"]["exit"] == intended["expectedExit"]
        assert observed["failure"] is None and observed["result"]["failure"] is None
        for stream in ("stdout", "stderr"):
            name = observed["label"] + "." + stream
            raw = archive.read(prefix + "execution/" + name)
            assert bytes.fromhex(observed["result"][stream]["rawHex"]) == raw
            assert sha(raw) == receipt["rawLogs"][name]
            original = (HERE.parents[3] / intended["stdoutSource" if stream == "stdout" else "diagnosticSource"]).read_bytes()
            if stream == "stderr":
                base = original[:-len(notice)] if original.endswith(notice) else original
                assert raw in (base, base + notice)
            else:
                assert raw == original
    assert len(archive.read(prefix + "execution/support.stdout")) == 58
    old_plan_raw = archive.read("production-controls-v2/execution-plan.json")
    old_receipt_raw = archive.read("production-controls-v2/execution/receipt.json")
    old_plan = json.loads(old_plan_raw)
    old_receipt = json.loads(old_receipt_raw)
    assert old_receipt["status"] == "INCOMPLETE" and old_receipt["commands"] == []
    assert sha(old_plan_raw) == plan["snapshotReuse"]["sourcePlanSha256"]
    assert sha(old_receipt_raw) == plan["snapshotReuse"]["zeroChildReceiptSha256"]
    for field in ("toolSnapshot", "environmentSHA256", "stageFiles", "preparationProbeResults", "loaderConfigurations"):
        assert plan[field] == old_plan[field], field
    assert plan["snapshotReuse"]["noFreshToolDiscovery"] is True
    assert archive.read(prefix + "DELIVERY.json") == (HERE / "DELIVERY.json").read_bytes()
print("PASS: actual68/root26 support/eight negatives/two IO source controls; inherited snapshot and zero-child history preserved; not proof/runtime/adoption")
