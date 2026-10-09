import gzip, hashlib, json
from pathlib import Path
root = Path(__file__).resolve().parent
manifest = json.loads((root / "FILES.json").read_text())
files = {}
for row in manifest["members"]:
    data = gzip.decompress((root / row["object"]).read_bytes())
    assert len(data) == row["bytes"]
    assert hashlib.sha256(data).hexdigest() == row["sha256"]
    files[row["path"]] = data
base = "/tmp/bendvy-inspect54-layout-provenance04/"
plan = files[base + "plan.json"]
assert hashlib.sha256(plan).hexdigest() == "d5bd77ebd415e3823f82323d0a4aa1cc5e897588e18147c321586a6a16eb22df"
receipt = json.loads(files[base + "receipt.json"])
assert receipt["planSHA256"] == hashlib.sha256(plan).hexdigest()
assert receipt["commands"][0]["exit"] == 1
assert receipt["commands"][0]["failure"] is None
for row in receipt["guards"]:
    assert hashlib.sha256(files[row["path"]]).hexdigest() == row["sha256"]
for key in ("stdout", "stderr"):
    row = receipt["commands"][0][key]
    assert hashlib.sha256(files[row["path"]]).hexdigest() == row["sha256"]
raw = files[base + "emit.stderr"]
rows = [x for x in raw.splitlines() if x.startswith(b"REFERENCE_LAYOUT_PROVENANCE ")]
assert len(rows) == 1 and len(rows[0]) == 65536
try:
    json.loads(rows[0].split(b" ", 1)[1])
except json.JSONDecodeError:
    pass
else:
    raise AssertionError("Expected retained truncated provenance")
profile_raw = files[base + "recursive.cpuprofile"]
assert hashlib.sha256(profile_raw).hexdigest() == receipt["profileSHA256"]
p = json.loads(profile_raw)
ids = {n["id"] for n in p["nodes"]}
assert len(ids) == len(p["nodes"])
assert len(p["samples"]) == len(p["timeDeltas"]) == 17886
assert all(x in ids for x in p["samples"])
assert base + "reference.c" not in files
print("PASS: lossless retained failure/profile joins; provenance remains truncated")
