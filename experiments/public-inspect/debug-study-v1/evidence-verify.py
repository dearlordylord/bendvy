"""Pure local capsule reconciliation; opens no live source paths or tool child."""
from pathlib import Path
import hashlib,json,tarfile
H=Path(__file__).resolve().parent/'evidence-v1';i=json.loads((H/'index.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();a=H/'objects.tar.gz';assert sha(a.read_bytes())==i['archiveSHA256']
with tarfile.open(a) as t:o={m.name:t.extractfile(m).read() for m in t.getmembers()}
assert set(o)==set(i['objects'])
for h,b in o.items():assert sha(b)==h and len(b)==i['objects'][h]
raw=lambda key:o[i['files'][key]]
read=lambda key:json.loads(raw(key))
base='owned/preflight/'
roles=['1791436307922867757','1791436439370695276','1791436566935334828','1791436705192929282','1791437041909327885']
for role in roles:
 p=read(base+role+'/plan.json');r=read(base+role+'/receipt.json');assert r['planSHA256']==sha(raw(base+role+'/plan.json'))
 for n,h in r['logs'].items():assert sha(raw(base+role+'/'+n))==h
 stageprefix=base+role+'/stage/'
 stagefiles={k[len(stageprefix):]:h for k,h in i['files'].items() if k.startswith(stageprefix)}
 if role=='1791436705192929282':
  # Remaining Node consumes the already frozen emitted prior stage.
  original='1791436566935334828';prefix=base+original+'/stage/';stagefiles={k[len(prefix):]:h for k,h in i['files'].items() if k.startswith(prefix)}
 assert stagefiles==p['inventory']
 if role!='1791437041909327885':assert r['status']=='INCOMPLETE'
 else:
  assert r['status']=='DEVELOPMENT_PREFLIGHT_FULL16_PASS_NOT_DELIVERY' and len(r['commands'])==2
  assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
  assert raw(base+role+'/candidate.stderr')==b''
  assert raw(base+role+'/candidate.stdout')==raw(base+role+'/stage/study/EXPECTED.stdout')
  assert len(raw(base+role+'/candidate.stdout').splitlines())==16
# Actual successful TS16 belongs to an otherwise INCOMPLETE old cohort.
r=read(base+'1791436439370695276/receipt.json');assert r['commands'][0]['exit']==0 and r['commands'][0]['failure'] is None
assert raw(base+'1791436439370695276/reference.stderr')==b''
rows=[json.loads(line) for line in raw(base+'1791436439370695276/reference.stdout').splitlines()];assert len(rows)==16
oracle=read('owned/ORACLE.json');fixture=oracle['fixture'];cases=oracle['cases']
entity=lambda id:{'id':id,'components':{name:fixture[name][str(id)] for name in ('left','right') if fixture[name][str(id)]!='absent'},'relations':{}}
baseentities=[entity(id) for id in fixture['liveIds']]
for n,row in enumerate(rows):
 assert row['before']==row['after']
 assert row['before']['entities']==baseentities and row['before']['entityCount']==4 and row['before']['resources']=={'resource':[19,23]}
 assert row['before']['version']==1 and row['before']['machines']=={} and row['before']['pendingCommands']==[{'tag':'spawn','system':'pending'},{'tag':'spawn','system':'pending'}]
 if n==15:continue
 case=cases[n];assert row['name']==case['name']
 if n==0:assert row['observed']=='Disabled' and row['control']=='adapter-disabled-no-call'
 else:assert row['observed']['entities']==[entity(id) for id in case['ids']] and row['observed']['entityCount']==4 and row['observed']['resources']=={'resource':[19,23]}
 expected=case.get('normalized',{'tag':'Unbounded'})
 assert row['digits']==expected
assert rows[-1]['scope']=='Bend MissingEntity boundary; TS debug only local numeric IDs'
notice=raw(base+'1791436566935334828/emit.stderr');assert notice==b'bend 2.0.36 is available: run bend update\n' and len(notice)==42
assert read(base+'1791436705192929282/emit-classification.json')['originalCohortStatus']=='INCOMPLETE'
print('PASS: development actual TS16 + current JS16, owner snapshots and all retained failures; no delivery/Native/proof/full56')
