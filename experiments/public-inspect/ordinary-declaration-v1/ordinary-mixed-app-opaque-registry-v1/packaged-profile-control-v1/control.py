"""One authorized version-only packaged ELF profile capability control."""
import fcntl,hashlib,json,sys
from pathlib import Path
sys.path.insert(0,"/workspace/formal-proofs/bendvy/scripts")
import task_runner as runner
from evidence_boundary import ReceiptBoundary
planpath=Path(sys.argv[1]);plan=json.loads(planpath.read_text());root=planpath.parent
assert hashlib.sha256(planpath.read_bytes()).hexdigest()==sys.argv[2]
assert not (root/"receipt.json").exists() and not list((root/"profiles").iterdir())
def guard():
    for name,digest in plan["pins"].items():
        assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==digest,name
record={"scope":plan["scope"],"planSHA256":sys.argv[2],"commands":[]}
with ReceiptBoundary(record,root/"receipt.json",[("final pins",guard)]):
    guard()
    with open("/tmp/bendvy-parity-heavy.lock","a") as lock:
        fcntl.flock(lock,fcntl.LOCK_EX)
        guard();(root/"pre.guard.json").write_text(json.dumps(plan["pins"],indent=2)+"\n")
        result=runner.execute_result(plan["argv"],5,plan["environment"],plan["cwd"],"split")
    row={key:value for key,value in result.items() if not isinstance(value,bytes)}
    for key in ("stdout","stderr"):
        raw=result[key];(root/("version."+key)).write_bytes(raw);row[key]={"path":str(root/("version."+key)),"bytes":len(raw),"sha256":hashlib.sha256(raw).hexdigest()}
    record["commands"].append(row);guard();(root/"post.guard.json").write_text(json.dumps(plan["pins"],indent=2)+"\n")
    assert result["exit"]==0 and result["failure"] is None
    assert result["stdout"]==b"bend 2.0.35\n"
    artifacts=[]
    for path in sorted((root/"profiles").iterdir()):
        raw=path.read_bytes();artifacts.append({"path":str(path),"bytes":len(raw),"sha256":hashlib.sha256(raw).hexdigest()})
    record["profileArtifacts"]=artifacts
    profile=root/"profiles/version.cpuprofile"
    record["profileExists"]=profile.is_file()
    if profile.is_file():
        raw=profile.read_bytes();(root/"captured-version.cpuprofile").write_bytes(raw);data=json.loads(raw);ids={node["id"] for node in data["nodes"]};assert len(ids)==len(data["nodes"]);assert all(i in ids for i in data["samples"]);assert len(data["samples"])==len(data["timeDeltas"])
        record["profileSchema"]={"nodes":len(data["nodes"]),"samples":len(data["samples"])}
    record["status"]="PACKAGED_VERSION_PROFILE_OBSERVED" if record["profileExists"] else "PACKAGED_VERSION_PROFILE_ABSENT"
