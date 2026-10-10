"""Unchanged development chain plus unconditional profile observation, no executor replacement."""
import hashlib,json,sys,types,os,stat,fcntl
from pathlib import Path
planpath=Path(sys.argv[1]);digest=sys.argv[2];raw=planpath.read_bytes();assert hashlib.sha256(raw).hexdigest()==digest
p=json.loads(raw);out=planpath.parent
for name,sha in p["pins"].items():assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==sha,name
def pins():
 for name,sha in p["pins"].items():assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==sha,name
def publish(path,data):
 fd=os.open(path,os.O_WRONLY|os.O_CREAT|os.O_EXCL|os.O_NOFOLLOW,0o600)
 with os.fdopen(fd,"wb") as stream:
  info=os.fstat(stream.fileno());assert stat.S_ISREG(info.st_mode)
  stream.write(data);stream.flush();os.fsync(stream.fileno())
 return {"path":str(path),"bytes":len(data),"sha256":hashlib.sha256(data).hexdigest(),"identity":[info.st_dev,info.st_ino]}
def joined(meta):
 fd=os.open(meta["path"],os.O_RDONLY|os.O_NOFOLLOW)
 with os.fdopen(fd,"rb") as stream:
  info=os.fstat(stream.fileno());assert stat.S_ISREG(info.st_mode) and [info.st_dev,info.st_ino]==meta["identity"]
  raw=stream.read();assert len(raw)==meta["bytes"] and hashlib.sha256(raw).hexdigest()==meta["sha256"]
profile=out/"profiles/stock.cpuprofile";assert not list(profile.parent.iterdir())
def load(name,path):
 m=types.ModuleType(name);m.__file__=path;exec(compile(Path(path).read_bytes(),path,"exec"),m.__dict__);return m
dev=load("development",p["profileObservation"]["collector"]);error=None
try:dev.run(planpath,digest)
except BaseException as e:error=e
finally:
 record={"planSHA256":digest,"profileExists":profile.exists(),"originalReceipt":str(out/"receipt.json"),"scope":"Profiling-only environment; absence after deadline is inconclusive; no timing or phase claim"}
 try:
  if profile.exists():
   assert not profile.is_symlink();fd=os.open(profile,os.O_RDONLY|os.O_NOFOLLOW)
   with os.fdopen(fd,"rb") as stream:
    info=os.fstat(stream.fileno());assert stat.S_ISREG(info.st_mode);data=stream.read()
   record["originalProfile"]={"path":str(profile),"bytes":len(data),"sha256":hashlib.sha256(data).hexdigest(),"identity":[info.st_dev,info.st_ino]}
   captured=out/"captured-stock.cpuprofile"
   record["profile"]=publish(captured,data)
   record["metadata"]=publish(out/"captured-stock.metadata.json",(json.dumps(dict(record["profile"],original=record["originalProfile"]),indent=2)+"\n").encode())
   pins();joined(record["profile"]);joined(record["metadata"])
   runner=load("runner",p["profileObservation"]["runner"])
   with open("/tmp/bendvy-parity-heavy.lock","a") as lock:
    fcntl.flock(lock,fcntl.LOCK_EX)
    r=runner.execute_result([p["tools"]["python"],p["profileObservation"]["validator"],str(captured),str(out/"captured-stock.metadata.json")],5,p["environment"],p["cwd"],"split")
   row={k:v for k,v in r.items() if not isinstance(v,bytes)}
   for k in ("stdout","stderr"):
    target=out/("profile-validation."+k)
    row[k]=publish(target,r[k])
   record["validation"]=row
   pins();joined(record["profile"]);joined(record["metadata"])
   for k in ("stdout","stderr"):joined(row[k])
   assert r["exit"]==0 and r["failure"] is None,"Profile validator failed"
   assert json.loads(r["stdout"])["sha256"]==record["profile"]["sha256"]
   record["status"]="PROFILE_CAPTURE_VALIDATED"
  else:record["status"]="PROFILE_ABSENT_NO_PHASE_INFERENCE"
 except BaseException as e:
  record["captureError"]=str(e);record["status"]="PROFILE_OBSERVATION_FAILED"
  if error is None:error=e
 finally:
  try:pins()
  except BaseException as e:
   record["finalPinsError"]=str(e);record["status"]="PROFILE_OBSERVATION_FAILED"
   if error is None:error=e
  if (out/"receipt.json").exists():record["originalReceiptSHA256"]=hashlib.sha256((out/"receipt.json").read_bytes()).hexdigest()
  with (out/"profile-observation.json").open("x") as stream:json.dump(record,stream,indent=2);stream.write("\n")
if error:raise error
