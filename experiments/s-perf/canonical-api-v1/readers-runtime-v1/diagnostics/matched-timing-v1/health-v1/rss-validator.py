"""Validate declared raw post-clock RSS sidecars; no comparative memory criterion."""
from pathlib import Path
import hashlib,json,os,stat,sys
plan=json.loads(Path(sys.argv[1]).read_text());expected=plan['methodRSSSidecars'];assert len(expected)==2
assert [x['phase']for x in expected]==['warmup','sample']
seen=set();result=[]
for item in expected:
 path=Path(item['path']);before=path.lstat();assert stat.S_ISREG(before.st_mode)and not path.is_symlink()
 identity=(before.st_dev,before.st_ino);assert identity not in seen;seen.add(identity)
 raw=path.read_bytes();after=path.lstat()
 assert (before.st_dev,before.st_ino,before.st_size,before.st_mtime_ns)==(after.st_dev,after.st_ino,after.st_size,after.st_mtime_ns)
 assert raw.endswith(b'\n')and raw.count(b'\n')==1
 value=json.loads(raw);assert list(value)==['peakRssKiB','platform','units','scope']
 assert type(value['peakRssKiB'])is int and value['peakRssKiB']>=0
 assert value['platform']==item['platform'] and value['units']=='KiB'
 assert value['scope']=='whole-process-highwater-including-warmup'
 result.append({'phase':item['phase'],'path':str(path),'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'device':before.st_dev,'inode':before.st_ino,'value':value})
print(json.dumps({'status':'RAW_RSS_TRANSPORT_PASS','scope':'actual post-clock process.resourceUsage maxRSS; whole-process highwater including warmup, not reset or qualified memory comparison','sidecars':result},indent=2))
