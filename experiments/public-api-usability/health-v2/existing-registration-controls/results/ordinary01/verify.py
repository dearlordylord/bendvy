from pathlib import Path
import json,gzip,hashlib,sys
b=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-ordinary-existing-entry/experiments/public-api-usability/health-v2/existing-registration-controls/results/ordinary01');d=json.loads((b/'RETENTION.json').read_text());sha=lambda x:hashlib.sha256(x).hexdigest();members={(r['actualPath'],r['sha256']):r for r in d['members']};assert len(members)==len(d['members']);seen={};context={};guards=0;outputs={};tools=set();invs={}
for row in members.values():
 if 'object' not in row:assert row['hashOnly']=='Installed tool/shared library identity only; not redistributed';continue
 p=b/row['object'];assert sha(p.read_bytes())==row['objectSHA256'];assert p.name==row['sha256']+'.gz'
 if row['object'] not in seen:
  raw=gzip.decompress(p.read_bytes());seen[row['object']]=(sha(raw),len(raw))
 assert seen[row['object']]==(row['sha256'],row['bytes'])
def raw(path):
 path=str(path);choices=[r for (name,h),r in members.items() if name==path and (name not in context or h==context[name])];assert len(choices)==1,(path,len(choices));return gzip.decompress((b/choices[0]['object']).read_bytes())
def obj(path):return json.loads(raw(path))
def pin(name,h):assert (str(name),h) in members,(name,h);context[str(name)]=h
assert len(d['cases'])==5
for case in d['cases']:
 q=Path(case['directory']);p=obj(q/'plan.json');r=obj(q/'receipt.json');assert sha(raw(q/'plan.json'))==case['planSHA256']==r['planSHA256'];assert sha(raw(q/'receipt.json'))==case['receiptSHA256'];assert not r.get('guardFailures',[])
 for name,h in p['pins'].items():pin(name,h)
 for root,files in p['resourceRoots'].items():
  for name,h in files.items():path=str(Path(root)/name);pin(path,h);tools.add(path)
 tools.update(p['tools'].values())
 for g in r['guards']:
  pin(g['path'],g['sha256']);guard=obj(g['path']);assert guard['unchanged'];guards+=1
  for name,h in guard['actualPins'].items():pin(name,h)
 for c,e in zip(r['commands'],p['commands']):
  for k in ['label','argv','capSeconds']:assert c[k]==e[k]
  assert c['exit']==0 and c['failure'] is None
  for key in ['stdout','stderr']:v=c[key];pin(v['path'],v['sha256']);assert len(raw(v['path']))==v['bytes']
 if not case['current']:
  assert r['status']=='INCOMPLETE' and len(r['commands'])==1 and r['commands'][0]['label']=='source-core';assert 'expectedExit' in r['error'];assert 'expectedExit' not in p['commands'][0];continue
 assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS' and len(r['commands'])==len(p['commands']);assert p['commands'][0]['expectedExit']==0
 assert raw(q/'consumer.stderr')==b'';actual=raw(q/'consumer.stdout');expected=gzip.decompress(raw(p['oracle']));assert actual==expected;assert len(actual)==p['oracleBytes'] and sha(actual)==p['oracleSHA256'];outputs[(case['kind'],case['role'])]=actual;invs[case['kind']]=p['sourceInventory']
assert outputs['normal','js']==outputs['normal','native'] and outputs['mutant','js']==outputs['mutant','native'];normal=outputs['normal','js'];mutant=outputs['mutant','js'];assert len(normal)==300 and sha(normal)=='3852cd5a1ddb8318f4fb8b84849132f612dcff5ef16cbbe1d7435ed083a2fb68';assert len(mutant)==298 and sha(mutant)=='57b636d9366376fa708d874a1e2052b90040efd8dd9b6a6ee77002dd53c01c49';assert normal!=mutant and normal.splitlines()[2:]==mutant.splitlines()[2:] and all(a!=b for a,b in zip(normal.splitlines()[:2],mutant.splitlines()[:2]))
# The actual reached library differs, while the ordinary consumer sources match.
normalRoot='/tmp/bendvy-ordinary-existing-entry/';mutantRoot='/tmp/bendvy-existing-route-mutant/';a={p.removeprefix(normalRoot):h for p,h in invs['normal'].items()};c={p.removeprefix(mutantRoot):h for p,h in invs['mutant'].items()};assert a.keys()==c.keys();assert [p for p in a if a[p]!=c[p]]==['src/ecs/ordinary-app-existing-execution.bend']
for row in members.values():
 if 'hashOnly' in row:assert row['actualPath'] in tools
assert len(seen)==d['objects']==len(list((b/'objects').iterdir()));print('PASS',len(members),'members',len(seen),'objects',guards,'guards','4 COMPLETE + historical binding failure; MUTANT_REJECTS_NORMAL','manifest',sha((b/'RETENTION.json').read_bytes()))
