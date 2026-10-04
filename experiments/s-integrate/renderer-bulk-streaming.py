#!/usr/bin/env python3
"""Verify every actual full JSON element before retaining a compact evidence record."""
import importlib.util,json,hashlib,tempfile,time
from pathlib import Path
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('render',HERE/'renderer-run.py');r=importlib.util.module_from_spec(s);s.loader.exec_module(r)
def main():
 source=(HERE/'renderer-bulk-baseline.bend').read_text().replace('IO.print(R.render_motion(', 'R.write_motion(').replace('False{}}))','False{}})')
 evidence={'scope':'full actual Native JSON validation; JS failure retained','sources':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [HERE/'host-render.bend',HERE/'renderer-bulk-baseline.bend',Path(__file__)]},'outcomes':[]}
 with tempfile.TemporaryDirectory(prefix='bendvy-streaming-') as tmp:
  folder=Path(tmp);fixture=folder/'streaming.bend';fixture.write_text(r.imports(source,HERE/'renderer-bulk-baseline.bend'))
  binaries=r.runner.build(fixture,folder)
  for binary in binaries:
   start=time.monotonic()
   try:raw=r.runner.execute(binary)
   except RuntimeError as error:
    assert binary.suffix=='.js' and '5s limit' in str(error),str(error)
    evidence['outcomes'].append({'backend':'JS','status':'FAIL','reason':str(error),'seconds':time.monotonic()-start});continue
   elapsed=time.monotonic()-start;obj=json.loads(raw)
   assert obj['kind']=='Read' and obj['count']==65537 and obj['boundary']==dict(since=10,streamSince=11,thisRun=12)
   assert obj['step']=='bulk' and obj['system']=='Fast'
   assert all(obj[k]==[] for k in ['removed','despawned','messages']) and all(obj[k] is False for k in ['messageLag','removedLag','despawnedLag'])
   for field in ['query','added','changed']:
    values=obj[field];assert len(values)==65537
    for i,value in enumerate(values,1):
     expected={'handle':dict(namespace=71,id=i),'main':dict(coordinates=r.four(i,i+1,i+2,i+3),frame=i+4),'aux':dict(rates=r.four(i+5,i+6,i+7,i+8),moving=True),'flag':dict(group=i+9)}
     assert value==expected,(field,i,value)
   # Only AFTER every original public JSON field/order has been checked.
   evidence['outcomes'].append({'backend':'JS' if binary.suffix=='.js' else 'Native','status':'PASS','seconds':elapsed,'bytes':len(raw.encode()),'raw_sha256':hashlib.sha256(raw.encode()).hexdigest(),'all_full_rows_verified':3*65537,'count_per_list':65537,'first_id':1,'last_id':65537})
 (HERE/'renderer-bulk-streaming-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
 print('Native full JSON all-field PASS; JS five-second failure retained')
if __name__=='__main__':main()
