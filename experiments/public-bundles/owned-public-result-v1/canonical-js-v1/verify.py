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
    plan = json.loads(archive.read("canonical-js-v1/execution-plan.json"))
    receipt = json.loads(archive.read("canonical-js-v1/execution/receipt.json"))
    assert sha(archive.read("canonical-js-v1/execution-plan.json")) == m["planSha256"] == receipt["planSHA256"]
    assert sha(archive.read("canonical-js-v1/execution/receipt.json")) == m["receiptSha256"]
    assert receipt["status"] == "CANONICAL_CORE_OWNED_REQUEST_COMPLETE22_AND20_JS_FINITE_PASS"
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
            assert bytes.fromhex(command["result"][stream]["rawHex"]) == archive.read("canonical-js-v1/execution/" + name)
    for name, expected in receipt["rawLogs"].items():
        assert sha(archive.read("canonical-js-v1/execution/" + name)) == expected
    for name, expected in receipt["generated"].items():
        assert sha(archive.read("canonical-js-v1/execution/" + name)) == expected
    for label, expected, rows in (("full22", "expected.stdout", 22), ("full20", "surface-expected.stdout", 20)):
        raw = archive.read("canonical-js-v1/execution/" + label + "-JS-consumer.stdout")
        assert raw == (BASE / expected).read_bytes() and len(raw.splitlines()) == rows
    join = runpy.run_path(str(BASE / "surface-public-join.py"))["compare"]
    joined = join(archive.read("canonical-js-v1/execution/full20-JS-consumer.stdout").decode(), (BASE / "surface-expected-reference.stdout").read_text())
    assert len(joined["publicCheckpoints"]) == 20
    assert joined == json.loads(archive.read("canonical-js-v1/execution/declared-public-join.json"))
    binding = json.loads((BASE / "canonical-source-v2/stage-binding.json").read_text())
    assert binding["stage"] == plan["stageFiles"]
    inspection = json.loads(archive.read("canonical-js-v1/generated-inspection.json"))
    for label, row in inspection["observations"].items():
        current = archive.read("canonical-js-v1/" + row["currentArtifact"])
        assert sha(current) == row["currentSha256"] and len(current) == row["currentBytes"]
        assert current.count(b'$: "../../../src/ecs/capabilities.OwnedRequest"') == row["currentOwnedRequestSites"]
        assert current.count(b'$: "public.Request"') == row["currentPublicRequestSites"] == 0
        with zipfile.ZipFile(BASE / row["originalArchive"]) as old:
            raw = old.read(row["originalMember"])
            assert sha(raw) == row["originalSha256"] and len(raw) == row["originalBytes"]
        with zipfile.ZipFile(BASE / row["compatibilityArchive"]) as compat:
            raw = compat.read(row["compatibilityMember"])
            assert sha(raw) == row["compatibilitySha256"] and len(raw) == row["compatibilityBytes"]
        assert row["deltaVersusCompatibilityBytes"] == row["currentBytes"] - row["compatibilityBytes"]
print("PASS: canonical complete22/20 JS and20 public joins; nested compatibility record removed in emitted code; no dynamic allocation/performance/proof/Native/adoption claim")
