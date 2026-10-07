from pathlib import Path
import hashlib
import json
import runpy
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
    plan = json.loads(archive.read("adoption-js-v2/execution-plan.json"))
    receipt = json.loads(archive.read("adoption-js-v2/execution/receipt.json"))
    assert sha(archive.read("adoption-js-v2/execution-plan.json")) == m["planSha256"] == receipt["planSHA256"]
    assert sha(archive.read("adoption-js-v2/execution/receipt.json")) == m["receiptSha256"]
    assert receipt["status"] == "OWNED_PRODUCTION_LEAF_COMPLETE22_AND20_JS_FINITE_PASS"
    assert len(plan["commands"]) == len(receipt["commands"]) == 4
    assert [row["seconds"] for row in plan["commands"]] == [30, 5, 30, 5]
    assert len(receipt["toolGuardSnapshots"]) == 9
    assert len(receipt["probeCommands"]) == 27 and len(plan["preparationProbeResults"]) == 3
    assert len(receipt["stagedInputs"]) == 59 and receipt["stagedInputs"] == plan["stageFiles"]
    for command in receipt["commands"]:
        assert command["exit"] == 0 and command["failure"] is None
        assert command["result"]["exit"] == 0 and command["result"]["failure"] is None
        for stream in ("stdout", "stderr"):
            name = command["label"] + "." + stream
            assert bytes.fromhex(command["result"][stream]["rawHex"]) == archive.read("adoption-js-v2/execution/" + name)
    for name, expected in receipt["rawLogs"].items():
        assert sha(archive.read("adoption-js-v2/execution/" + name)) == expected
    for name, expected in receipt["generated"].items():
        assert sha(archive.read("adoption-js-v2/execution/" + name)) == expected
    for label, expected, rows in (("full22", "expected.stdout", 22), ("full20", "surface-expected.stdout", 20)):
        raw = archive.read("adoption-js-v2/execution/" + label + "-JS-consumer.stdout")
        assert raw == (BASE / expected).read_bytes() and len(raw.splitlines()) == rows
    join = runpy.run_path(str(BASE / "surface-public-join.py"))["compare"]
    joined = join(archive.read("adoption-js-v2/execution/full20-JS-consumer.stdout").decode(), (BASE / "surface-expected-reference.stdout").read_text())
    assert len(joined["publicCheckpoints"]) == 20
    assert joined == json.loads(archive.read("adoption-js-v2/execution/declared-public-join.json"))
    failed = json.loads(archive.read("adoption-js-v1/execution/receipt.json"))
    assert failed["status"] == "INCOMPLETE" and len(failed["commands"]) == 1
    assert failed["commands"][0]["exit"] == 1 and failed["commands"][0]["failure"] is None
    assert b"ENOENT" in archive.read("adoption-js-v1/execution/full22-JS-emit.stderr")
    sides = json.loads(archive.read("adoption-js-v2/foreign-sidecars.json"))
    binding = json.loads((BASE / "adoption-stage-v2/stage-binding.json").read_text())
    combined = dict(binding["stage"])
    combined.update({name: row["sha256"] for name, row in sides["files"].items()})
    assert combined == plan["stageFiles"]
    inspection = json.loads(archive.read("adoption-js-v2/generated-inspection.json"))
    for label, row in inspection["observations"].items():
        current = archive.read("adoption-js-v2/" + row["currentArtifact"])
        assert sha(current) == row["currentSha256"] and len(current) == row["currentBytes"]
        assert current.count(b'$: "../../../src/ecs/capabilities.OwnedRequest"') == row["ownedRequestConstructionSites"]
        with zipfile.ZipFile(BASE / row["baselineArchive"]) as old:
            raw = old.read(row["baselineMember"])
            assert sha(raw) == row["baselineSha256"] and len(raw) == row["baselineBytes"]
print("PASS: complete22/20 JS and20 public joins; retained ENOENT failure; static wrapper allocation sites only; no backend replay/proof/performance acceptance")
