"""Verify archived finite observations/source hashes; never spawn a child or extract."""
from pathlib import Path
import hashlib,json,tarfile
E=Path(__file__).resolve().parent;index=json.loads((E/'index.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest()
assert sha((E/'objects.tar.gz').read_bytes())==index['archiveSHA256'];objects={}
with tarfile.open(E/'objects.tar.gz','r:gz') as t:
 for m in t.getmembers():
  assert m.isfile() and m.name.startswith('objects/') and len(m.name)==72
  digest=m.name[8:];b=t.extractfile(m).read();assert sha(b)==digest and digest not in objects;objects[digest]=b
assert sorted(objects)==index['objects'];assert all(v in objects for v in index['records'].values())
def data(digest):return json.loads(objects[digest])
def strict(v):
 if isinstance(v,dict):return ('dict',tuple((k,strict(x)) for k,x in sorted(v.items())))
 if isinstance(v,list):return ('list',tuple(map(strict,v)))
 return (type(v).__name__,v)
for role,c in index['cohorts'].items():
 p=data(c['plan']);r=data(c['receipt']);assert r['planSHA256']==c['plan']
 assert r['logs']==c['raw'];assert all(v in objects for v in c['raw'].values())
 assert {**c['retainedPins'],**c['excludedLocalPins']}==p['pins'];assert set(c['retainedPins']).isdisjoint(c['excludedLocalPins']);assert all(v in objects for v in c['retainedPins'].values())
 assert c['privateEnvironmentSHA256']==p['environmentSHA256']
 if role in ('ts-failure','pure-timeout','metadata-malformed'):
  assert r['status']=='INCOMPLETE' and len(r['commands'])==1
  if role=='pure-timeout':assert r['commands'][0]['failure']=='child deadline' and all(objects[d]==b'' for d in c['raw'].values())
  if role=='metadata-malformed':assert r['commands'][0]['exit']==0 and r['error'].startswith('JSONDecodeError:')
  continue
 expected_status={'ts-public':'DEVELOPMENT_ACTUAL_TS_COMPLETE18_PASS_NOT_FULL55','boundary-io':'DEVELOPMENT_ACTUAL_IO_FULL_BOUNDARY_ORACLE_PASS_NOT_FULL55','remaining-v2':'DEVELOPMENT_PURE_REMAINING_TWO_FULL_ORACLES_PASS_NOT_FULL55'}[role]
 assert r['status']==expected_status
 commands=p.get('commands',[p.get('command')]);assert len(commands)==len(r['commands'])
 for command,result in zip(commands,r['commands']):
  assert result['exit']==0 and result['failure'] is None and result['argv']==command['argv'] and result['seconds']==5
  label=command['label'];out=objects[c['raw'][label+'.stdout']];err=objects[c['raw'][label+'.stderr']];assert err==b''
  if role=='ts-public':actual=json.loads(out);oracle=p['oracle'];assert len(actual['observations'])==18
  else:
   text=out.decode();value,end=json.JSONDecoder().raw_decode(text);assert text[end:]=='\n';actual=json.loads(value) if role=='remaining-v2' else value;oracle=command['oracle']
  oracle_hash=p['pins'][oracle];assert oracle_hash in objects;assert strict(actual)==strict(data(oracle_hash))
  if role=='boundary-io':assert len(actual['records'])==16 and len(actual['missing'])==2 and actual['schemaErrors']=={'Workshop':[],'Garden':[]}
  if role=='remaining-v2' and label=='direct-check':
   assert len(actual['observations'])==4 and all(row['before']==row['after'] for row in actual['observations'])
print('PASS finite TS18 / complete boundary IO / metadata / direct Check; histories preserved; not full55 or fresh backend verification')
