"""Validate fresh clean-child RSS transport; no numerical memory criterion."""
import hashlib,json,stat,sys
from pathlib import Path
plan=json.loads(Path(sys.argv[2]).read_text()); paths=[Path(plan['cleanChildRSS']['path']),*[Path(x['path'])for x in plan['clockSidecars']]]
if sys.argv[1]=='fresh':
 for path in paths:assert not path.exists()and not path.is_symlink(),path
 print('FRESH_SIDECARS_PASS');sys.exit(0)
records=[];identities=set()
for path in paths:
 before=path.lstat();assert stat.S_ISREG(before.st_mode)and not path.is_symlink();identity=(before.st_dev,before.st_ino);assert identity not in identities;identities.add(identity)
 raw=path.read_bytes();after=path.lstat();assert (before.st_dev,before.st_ino,before.st_size,before.st_mtime_ns)==(after.st_dev,after.st_ino,after.st_size,after.st_mtime_ns)
 assert raw.endswith(b'\n')and raw.count(b'\n')==1
 if path==paths[0]:
  value=json.loads(raw);assert list(value)==['launcherPeakRssKiB','childPeakRssKiB','exitCode'];assert all(type(v)is int and v>=0 for v in value.values());assert value['exitCode']==0
 else:assert raw[:-1].isdigit();value=int(raw)
 records.append({'path':str(path),'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'device':before.st_dev,'inode':before.st_ino,'value':value})
print(json.dumps({'status':'CLEAN_CHILD_RSS_TRANSPORT_PASS','scope':'child invocation including startup, warmup, setup, operations and serialization; launcher highwater diagnostic only; no allocation/comparative claim','sidecars':records},indent=2))
