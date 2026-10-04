#!/usr/bin/env python3
"""One bounded baseline classification for the failed 1024 diagnostic cases."""
from replay import R,HERE
import pathlib,json,hashlib
root=pathlib.Path('/tmp/prep22-tx-built');e=json.loads((HERE/'evidence.json').read_text());expected=e['generated']['failure-original'];results=[]
for name,digest in expected.items():assert hashlib.sha256((root/name).read_bytes()).hexdigest()==digest
for schema,number in [('Motion',0),('Health',1)]:
 for backend,program in [('Native',[root/'failure-original','--threads','1','--gpu','off']),('JS',['node',root/'failure-original.js'])]:
  cmd=['taskset','-c','8',*program,str(number),'1024','64'];record={'schema':schema,'count':1024,'iterations':64,'backend':backend,'command':list(map(str,cmd))}
  try:
   out,err=R.run(cmd);record.update(status='COMPLETED',outputBytes=len(out.encode()),publicSha256=hashlib.sha256(out.encode()).hexdigest())
  except Exception as exc:record.update(status='DEADLINE_OR_FAILURE',error=str(exc))
  results.append(record);print(schema,backend,record['status'],flush=True)
(HERE/'deadline-classification.json').write_text(json.dumps({'limits':{'runtime':5},'generated':expected,'results':results},indent=2)+'\n')
