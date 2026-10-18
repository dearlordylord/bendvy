from pathlib import Path
import json,gzip,hashlib,sys
b=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-lifecycle-matched-method/experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/diagnostics/matched-timing-v1/runtime-v1/actual-attempt01');d=json.loads((b/'RETENTION.json').read_text());sha=lambda x:hashlib.sha256(x).hexdigest();members={r['actualPath']:r for r in d['members']};assert len(members)==len(d['members']);seen={}
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
assert [a['role'] for a in d['current']]==['js','native','ts'];guards=0;tools=set();tuples=0
import io,math
validationPath='/tmp/bendvy21-lifecycle-motion-b1-method-pilot-actual01/ALL-ROLES-VALIDATION.json';validation=obj(validationPath);assert validation['status']=='B1_COMPLETE_SHARED_AND_OWN_FOREIGN_RECORDS_PASS'
fixturePath=next(p for p in members if p.endswith('/model/observer-fixtures.json.gz'));fixtures=json.loads(gzip.decompress(raw(fixturePath)))
assert len(fixtures)==2 and all(len(f['tuple'])==2044440 and f['fold']==3945713710 for f in fixtures)
foreignTuples=0
for a in d['current']:
 q=Path(a['actualDirectory']);p=obj(q/'plan.json');r=obj(q/'receipt.json');assert sha(raw(q/'plan.json'))==a['planSHA256']==r['planSHA256'];assert sha(raw(q/'receipt.json'))==a['receiptSHA256']
 assert 'NODE_OPTIONS'not in p['environment']and 'NODE_PATH'not in p['environment']
 node=p['nodePackageScope'];assert node['referenceNestedMembership']in p['resourceRoots']
 assert obj(node['referencePackage'])['type']=='module'
 assert obj(node.get('entryPackage',node.get('subjectPackage')))['type']=='module'
 if a['role']=='js':assert obj(node['generatedPackage'])=={'type':'commonjs'}
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
 expectedN,expectedHash=(17437766,'eaff4dd3990ab9afd45d6befa3fd062db6ce4f5de3cfaa1370dbcea69b722b5e') if a['role']=='ts' else (26249413,'a63887c33c37b50f9e7b9da609533d588ac1a439321cbce1e96f9ebe71b0b6e2')
 assert p['oracleBytes']==expectedN and p['oracleSHA256']==expectedHash
 actual=raw(q/'consumer.stdout');oracle=gzip.decompress(raw(p['oracle']));assert actual==oracle and len(actual)==expectedN and sha(actual)==expectedHash
 values=[json.loads(line[6:])for line in actual.decode().splitlines()if line.startswith('TUPLE:')];assert len(values)==2 and all(x==f['tuple']for x,f in zip(values,fixtures));tuples+=len(values)
 foreign=[json.loads(line[len('FOREIGN-TUPLE:'):])for line in actual.decode().splitlines()if line.startswith('FOREIGN-TUPLE:')];role='ts'if a['role']=='ts'else 'bend';assert len(foreign)==2 and all(x==f['foreignTuples'][role]for x,f in zip(foreign,fixtures));foreignTuples+=len(foreign)
 checked=next(x for x in validation['roles']if x['role']==a['role']);assert checked['planSHA256']==a['planSHA256']
 for declared,clock in zip(p['clockSidecars'],checked['clocks']):
  assert declared['path']==clock['path'] and declared['phase']==clock['phase'];data=raw(clock['path']);assert sha(data)==clock['sha256'] and len(data)==clock['bytes'] and data.decode()==clock['raw'];value=float(data);assert math.isfinite(value) and value>=0
rss=obj(d['rssValidation']);assert rss['status']=='RAW_RSS_TRANSPORT_PASS'
ts=next(x for x in d['current'] if x['role']=='ts');tsplan=obj(Path(ts['actualDirectory'])/'plan.json')
assert len(tsplan['methodRSSSidecars'])==len(rss['sidecars'])==2
identities=set()
for declared,actual in zip(tsplan['methodRSSSidecars'],rss['sidecars']):
 assert declared['path']==actual['path'] and declared['phase']==actual['phase']
 data=raw(actual['path']);assert sha(data)==actual['sha256'] and len(data)==actual['bytes']
 value=json.loads(data);assert value==actual['value'] and list(value)==['peakRssKiB','platform','units','scope']
 assert type(value['peakRssKiB'])is int and value['peakRssKiB']>=0
 assert value['platform']==declared['platform'] and value['units']=='KiB' and value['scope']=='whole-process-highwater-including-warmup'
 identity=(actual['device'],actual['inode']);assert identity not in identities;identities.add(identity)
for r in members.values():
 if 'hashOnly'in r:assert r['actualPath']in tools
assert tuples==foreignTuples==6 and len(list((b/'objects').iterdir()))==d['objects'] and len(seen)==d['objects']
print('PASS',len(members),'members',len(seen),'objects',guards,'guards',tuples,'complete shared tuples +',foreignTuples,'own-role foreign tuples; method-only; manifest',sha((b/'RETENTION.json').read_bytes()))
