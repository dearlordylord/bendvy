import json,sys,hashlib,os,stat
from pathlib import Path
p=Path(sys.argv[1]);meta=json.loads(Path(sys.argv[2]).read_bytes());fd=os.open(p,os.O_RDONLY|os.O_NOFOLLOW)
with os.fdopen(fd,"rb") as stream:
 info=os.fstat(stream.fileno());assert stat.S_ISREG(info.st_mode) and [info.st_dev,info.st_ino]==meta["identity"]
 raw=stream.read();assert len(raw)==meta["bytes"] and hashlib.sha256(raw).hexdigest()==meta["sha256"]
d=json.loads(raw);ids={n["id"] for n in d["nodes"]}
assert len(ids)==len(d["nodes"]) and all(x in ids for x in d.get("samples",[]))
assert len(d.get("samples",[]))==len(d.get("timeDeltas",[]))
assert all(c in ids for n in d["nodes"] for c in n.get("children",[]))
assert isinstance(d["startTime"],(int,float)) and d["endTime"]>=d["startTime"]
print(json.dumps({"sha256":hashlib.sha256(raw).hexdigest(),"bytes":len(raw),"nodes":len(ids),"samples":len(d.get("samples",[]))}))
