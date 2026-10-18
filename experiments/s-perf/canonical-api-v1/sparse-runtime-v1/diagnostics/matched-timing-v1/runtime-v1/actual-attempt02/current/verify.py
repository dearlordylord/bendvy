from pathlib import Path
import json,gzip,hashlib,sys
b=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-sparse-matched-method/experiments/s-perf/canonical-api-v1/sparse-runtime-v1/diagnostics/matched-timing-v1/runtime-v1/actual-attempt02/current');d=json.loads((b/'RETENTION.json').read_text());sha=lambda x:hashlib.sha256(x).hexdigest();members={r['actualPath']:r for r in d['members']};assert len(members)==len(d['members']);seen={}
for r in members.values():
 if 'object' not in r:assert r['hashOnly']=='Installed tool/shared library identity only; not redistributed';continue
 p=b/r['object'];assert sha(p.read_bytes())==r['objectSHA256'];assert p.name==r['sha256']+'.gz'
 if r['object'] not in seen:
  h=hashlib.sha256();n=0
  with gzip.open(p,'rb') as f:
   while chunk:=f.read(1048576):h.update(chunk);n+=len(chunk)
  seen[r['object']]=(h.hexdigest(),n)
 assert seen[r['object']]==(r['sha256'],r['bytes'])
def raw(path):r=members[str(path)];assert 'object'in r;return gzip.decompress((b/r['object']).read_bytes())
def obj(path):return json.loads(raw(path))
def pin(path,h):assert members[str(path)]['sha256']==h,(path,h)
for dep in d['objectDependencies']:assert sha((b/dep['manifest']).read_bytes())==dep['sha256']
assert len(d['current'])==3;guards=0;tools=set();tuples=0
import io,math
validationPath='/tmp/bendvy21-sparse-motion-b1-method-pilot-actual02/VALIDATION.json';validation=obj(validationPath);assert validation['status']=='B1_METHOD_COMPLETE_FULL_RECORDS_PASS'
fixturePath=next(p for p in members if p.endswith('/model/expected-common.json'));fixture=obj(fixturePath)
assert len(fixture['tuple'])==35061 and fixture['fold']==2367956733
for a in d['current']:
 q=Path(a['actualDirectory']);p=obj(q/'plan.json');r=obj(q/'receipt.json');assert sha(raw(q/'plan.json'))==a['planSHA256']==r['planSHA256'];assert sha(raw(q/'receipt.json'))==a['receiptSHA256']
 for path,h in p['pins'].items():pin(path,h)
 for root,files in p['resourceRoots'].items():
  for n,h in files.items():path=str(Path(root)/n);pin(path,h);tools.add(path)
 tools.update(p['tools'].values());assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS' and not r.get('guardFailures',[]);assert len(p['commands'])==len(r['commands'])
 for g in r['guards']:
  pin(g['path'],g['sha256']);v=obj(g['path']);assert v['unchanged']
  for path,h in v['actualPins'].items():pin(path,h)
  guards+=1
 for c,e in zip(r['commands'],p['commands']):
  for k in ['label','argv','capSeconds']:assert c[k]==e[k]
  assert c['exit']==0 and c['failure'] is None
  for k in ['stdout','stderr']:
   v=c[k];pin(v['path'],v['sha256']);assert members[v['path']]['bytes']==v['bytes']
  assert c['stderr']['bytes']==0
 expectedN,expectedHash=(695984,'8b31e88f9ebc9124e4c9a39f0fb587647072f14610f3a9b05a38986a6a920713') if a['role']=='ts' else (1071136,'d5539a7c28a847d2d37af474532781371bf0db58b04f75b43774c9ba4fdd1179')
 assert p['oracleBytes']==expectedN and p['oracleSHA256']==expectedHash
 actual=raw(q/'consumer.stdout');oracle=gzip.decompress(raw(p['oracle']));assert actual==oracle and len(actual)==expectedN and sha(actual)==expectedHash
 values=[json.loads(line[6:])for line in actual.decode().splitlines()if line.startswith('TUPLE:')];assert len(values)==2 and all(x==fixture['tuple']for x in values);tuples+=len(values)
 checked=next(x for x in validation['roles']if x['role']==a['role']);assert checked['planSHA256']==a['planSHA256']
 for declared,clock in zip(p['clockSidecars'],checked['clocks']):
  assert declared['path']==clock['path'] and declared['phase']==clock['phase'];data=raw(clock['path']);assert sha(data)==clock['sha256'] and len(data)==clock['bytes'] and data.decode()==clock['raw'];value=float(data);assert math.isfinite(value) and value>=0
for r in members.values():
 if 'hashOnly'in r:assert r['actualPath']in tools
assert tuples==6 and len(list((b/'objects').iterdir()))==d['objects'] and len(seen)==d['objects']
print('PASS',len(members),'members',len(seen),'objects',guards,'guards',tuples,'complete actual tuples; method-only; manifest',sha((b/'RETENTION.json').read_bytes()))
