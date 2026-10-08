from pathlib import Path
import hashlib
import json
import runpy
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
    assert not any("environment" in Path(name).name or name.endswith(".native") for name in archive.namelist())
    plan = json.loads(archive.read("production-js-v1/execution-plan.json"))
    receipt = json.loads(archive.read("production-js-v1/execution/receipt.json"))
    assert sha(archive.read("production-js-v1/execution-plan.json")) == m["planSha256"] == receipt["planSHA256"]
    assert sha(archive.read("production-js-v1/execution/receipt.json")) == m["receiptSha256"]
    assert receipt["status"] == "PRODUCTION_BUNDLES_COMPLETE22_AND20_JS_FINITE_PASS"
    assert len(plan["commands"]) == len(receipt["commands"]) == 4
    assert [row["seconds"] for row in plan["commands"]] == [30, 5, 30, 5]
    assert len(receipt["toolGuardSnapshots"]) == 9
    assert len(receipt["probeCommands"]) == 27 and len(plan["preparationProbeResults"]) == 3
    assert len(receipt["stagedInputs"]) == 68 and receipt["stagedInputs"] == plan["stageFiles"]
    for command in receipt["commands"]:
        assert command["exit"] == 0 and command["failure"] is None
        assert command["result"]["exit"] == 0 and command["result"]["failure"] is None
        for stream in ("stdout", "stderr"):
            name = command["label"] + "." + stream
            assert bytes.fromhex(command["result"][stream]["rawHex"]) == archive.read("production-js-v1/execution/" + name)
    for name, expected in receipt["rawLogs"].items():
        assert sha(archive.read("production-js-v1/execution/" + name)) == expected
    for name, expected in receipt["generated"].items():
        assert sha(archive.read("production-js-v1/execution/" + name)) == expected
    for label, expected, rows in (("full22", "expected.stdout", 22), ("full20", "surface-expected.stdout", 20)):
        raw = archive.read("production-js-v1/execution/" + label + "-JS-consumer.stdout")
        assert raw == (BASE / expected).read_bytes() and len(raw.splitlines()) == rows
    join = runpy.run_path(str(BASE / "surface-public-join.py"))["compare"]
    joined = join(archive.read("production-js-v1/execution/full20-JS-consumer.stdout").decode(), (BASE / "surface-expected-reference.stdout").read_text())
    assert len(joined["publicCheckpoints"]) == 20
    assert joined == json.loads(archive.read("production-js-v1/execution/declared-public-join.json"))
    binding = json.loads((BASE / "production-rewire-v1/BINDING.json").read_text())
    assert binding["stage"] == plan["stageFiles"]
    proposal = json.loads(archive.read("production-js-v1/PLAN.json"))
    assert len(proposal["rootProductionPins"]) == 26
    for name, expected in proposal["rootProductionPins"].items():
        relative = name.split("/bendvy/", 1)[1]
        assert plan["files"][name] == expected == binding["stage"][relative]
    inspection = json.loads(archive.read("production-js-v1/STRUCTURAL.json"))
    assert sha((BASE / "canonical-js-v1/evidence-v1.zip").read_bytes()) == inspection["canonicalJsArchiveSha256"]
    with zipfile.ZipFile(BASE / "canonical-js-v1/evidence-v1.zip") as canonical:
        for row in inspection["rows"]:
            label = row["label"]
            current = archive.read("production-js-v1/execution/" + label + ".js")
            previous = canonical.read("canonical-js-v1/execution/" + label + ".js")
            assert sha(current) == row["productionSha256"] and sha(previous) == row["canonicalSha256"]
            assert len(current) == row["productionBytes"] and len(previous) == row["canonicalBytes"]
            assert row["byteDelta"] == len(current) - len(previous)
            sites = lambda raw: sum('{$:' in line and 'capabilities.OwnedRequest' in line for line in raw.decode().splitlines())
            assert sites(current) == sites(previous) == row["productionOwnedRequestConstructorSites"] == row["canonicalOwnedRequestConstructorSites"]
            assert row["productionLegacyPublicRequestConstructorSites"] == row["canonicalLegacyPublicRequestConstructorSites"] == 0
    assert archive.read("production-js-v1/DELIVERY.json") == (HERE / "DELIVERY.json").read_bytes()
print("PASS: actual production68/root26 complete22/20 JS and20 public TS joins; not proof/performance/Native/adoption")
