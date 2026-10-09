import json,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent
m=json.loads((HERE/'SOURCE-DELTA.json').read_text());mapping={r['original']:r['candidate'] for r in m['files']}
for r in m['files']:
 old,new=Path(r['original']),Path(r['candidate']);assert hashlib.sha256(old.read_bytes()).hexdigest()==r['originalSHA256'];assert hashlib.sha256(new.read_bytes()).hexdigest()==r['candidateSHA256']
 s=old.read_text()
 for a,b in mapping.items():s=s.replace(a,b)
 if new.name=='fixture.bend':
  s=s.replace('def observe(owner:',"def zero_at(owner:Payload.Payload,index:U32) -> Payload.Payload & U32:\n  Payload.at(owner,0)\ndef zero_declaration() -> Query.Declaration<Schema,Payload.Payload,Cap.Request<Payload.Payload,U32,U32>>:\n  Decl.read(~Schema,~Payload.Payload,~U32,~U32,~zero_at,\"owned-events\")\ndef observe(owner:")
  s=s.replace('~read_declaration(),~observed,owner,Unit{})','~zero_declaration(),~observed,owner,Unit{})')
 assert new.read_text()==s
r=json.loads((HERE/'source-checks/registered-mutant.json').read_text());assert r['exit']==0 and r['failure']is None and r['unchangedAfter']
for k in ['stdout','stderr']:
 f=Path(r[k]['path']);assert hashlib.sha256(f.read_bytes()).hexdigest()==r[k]['sha256']
print('PASS sole reached grant index-zero delta and source5 receipt')
