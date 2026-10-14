"""Verify portable retained #38 bytes without execution or live source reads."""
from pathlib import Path
import gzip, hashlib, json, zipfile
HERE = Path(__file__).resolve().parent
sha = lambda raw: hashlib.sha256(raw).hexdigest()
delivery = json.loads((HERE / "DELIVERY.json").read_text())
for filename, expected in delivery["files"].items():
    assert sha((HERE / filename).read_bytes()) == expected, filename
manifest = json.loads((HERE / "MANIFEST.json").read_text())
with zipfile.ZipFile(HERE / "EVIDENCE.zip") as archive:
    assert set(archive.namelist()) == set(manifest["members"])
    assert len(archive.namelist()) == len(set(archive.namelist()))
    data = {}
    for member, row in manifest["members"].items():
        raw = archive.read(member)
        assert len(raw) == row["bytes"] and sha(raw) == row["sha256"]
        data[(row["path"], row["sha256"])] = raw
    def bound(path, digest=None):
        if digest is None:
            choices = manifest["pathHashToMember"][path]
            assert len(choices) == 1, (path, "version must be explicit")
            digest = next(iter(choices))
        return data[(path, digest)]
    root = delivery["producerLeaf"]
    for role in manifest["roles"]:
        directory = root + "/" + role
        plan_raw = bound(directory + "/plan.json")
        plan = json.loads(plan_raw)
        receipt = json.loads(bound(directory + "/receipt.json"))
        assert receipt["planSHA256"] == sha(plan_raw)
        assert receipt["status"] == "COMPLETE_CONSUMER_DEVELOPMENT_PASS"
        for path, digest in plan["pins"].items():
            if path.startswith("/workspace/"):
                assert sha(bound(path, digest)) == digest
        for guard in receipt["guards"]:
            obj = json.loads(bound(guard["path"], guard["sha256"]))
            assert obj["unchanged"]
        expected = gzip.decompress(bound(plan["oracle"], plan["pins"][plan["oracle"]]))
        assert len(expected) == plan["oracleBytes"]
        assert sha(expected) == plan["oracleSHA256"]
        for command in receipt["commands"]:
            assert command["exit"] == 0 and not command["failure"]
            for stream in ("stdout", "stderr"):
                row = command[stream]
                assert sha(bound(row["path"], row["sha256"])) == row["sha256"]
            if command["label"] == "consumer":
                assert bound(command["stdout"]["path"], command["stdout"]["sha256"]) == expected
                assert command["stderr"]["bytes"] == 0
        for label, path in (("emit", plan["generated"]), ("build", plan["native"])):
            digest = receipt.get(label + "ArtifactSHA256")
            if digest:
                assert sha(bound(path, digest)) == digest
    normal = bound(root + "/public-authority-js01/scenario.js")
    changed = bound(root + "/public-collision-js01/mutant.js")
    anchor, replacement = b"return state.next++;", b"return 1;"
    assert normal.count(anchor) == 1
    assert changed == normal.replace(anchor, replacement, 1)
    at = normal.index(anchor)
    assert changed[:at] + anchor + changed[at + len(replacement):] == normal
    assert bound(root + "/public-authority-js01/consumer.stdout") != bound(root + "/public-collision-js01/consumer.stdout")
print(json.dumps({"status": "PASS_RETAINED_CURRENT_PUBLIC_HOST_SEMANTICS", "members": len(manifest["members"]), "publicRoles": 7, "adoptionRegression": "HOLD"}))
