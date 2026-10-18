from pathlib import Path
import json,gzip,hashlib,sys
b=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-readers-ordinary-app/experiments/s-perf/canonical-api-v1/readers-runtime-v1/runtime-v1/ordinary-family-attempt01');d=json.loads((b/'RETENTION.json').read_text());sha=lambda x:hashlib.sha256(x).hexdigest();members={r['actualPath']:r for r in d['members']};assert len(members)==len(d['members']);seen={}
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
assert len(d['current'])==12 and len(d['history'])==1 and len(d['reusedSemanticControls'])==2
guards=0;tools=set();classified=[]
applicability=next(r for r in members if r.endswith('/checks/ordinary-app-v1/CONTROL-APPLICABILITY.json'))
ca=obj(applicability);drift=ca['records'][0]['policyDrift'][0]
def scopedpin(path,h,reuse):
 if reuse and path==drift['path']:
  assert h==drift['expectedHistoricalSHA256'];pin(drift['historicalSourceSnapshot'],h)
 else:pin(path,h)
expected={('motion',64):(10810200,'183936740ad2407530099198388cc87d872b121fa0681a3a7777ec42797b83ce'),('motion',256):(40177844,'4618b75f14abbb4479ff5598e182f8c4d4eb291d0baf66abe2fe4529a60b8e28'),('motion',1024):(158696224,'791ec1cac044df30972ae2657c9d2008f8391e917594ce182d4e1c535ebd1ecc'),('health',64):(8077591,'159139269b00038c4d1220a835c75adb65389446c5f61eb5b2dfce8db799a9e5'),('health',256):(29692447,'3539fc3ab27aff5f113ff6c69ee8fd2fe14308e73516a3d17f0208648dd39e8a'),('health',1024):(117322528,'f4a7cf88b02f98fa0cde8d4502d2f76979bce11e766505107c6bd2ce706d898b')}
import io,re
for a in d['current']+d['history']+d['reusedSemanticControls']:
 reuse=a in d['reusedSemanticControls'];history=a in d['history'];q=Path(a['actualDirectory']);p=obj(q/'plan.json');assert sha(raw(q/'plan.json'))==a['planSHA256']
 for path,h in p['pins'].items():scopedpin(path,h,reuse)
 for root,files in p['resourceRoots'].items():
  for n,h in files.items():path=str(Path(root)/n);pin(path,h);tools.add(path)
 tools.update(p['tools'].values());r=obj(q/'receipt.json');assert r['planSHA256']==a['planSHA256'] and sha(raw(q/'receipt.json'))==a['receiptSHA256'];assert not r.get('guardFailures',[])
 assert len(r['commands'])<=len(p['commands'])
 for g in r['guards']:
  pin(g['path'],g['sha256']);v=obj(g['path']);assert v['unchanged']
  for path,h in v['actualPins'].items():scopedpin(path,h,reuse)
  guards+=1
 for c,e in zip(r['commands'],p['commands']):
  for k in ['label','argv','capSeconds']:assert c[k]==e[k]
  for k in ['stdout','stderr']:
   v=c[k];pin(v['path'],v['sha256']);assert members[v['path']]['bytes']==v['bytes']
 if history:
  assert 'motion64-actual01/normal/native' in str(q);assert r['status']=='INCOMPLETE' and len(r['commands'])==1
  c=r['commands'][0];assert c['label']=='emit' and c['capSeconds']==30 and c['exit'] is None and c['failure']=='child deadline'
  assert c['stdout']['bytes']==c['stderr']['bytes']==0;classified.append('HISTORICAL_EMIT30_DEADLINE');continue
 assert len(r['commands'])==len(p['commands']);assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS';assert all(c['exit']==0 and c['failure'] is None and c['stderr']['bytes']==0 for c in r['commands'])
 if reuse:
  en,eh=135,'bf6b72ebfda829821728847dc67f52d098031abb853986696bd7f9209caf3f17'
  record=next(x for x in ca['records'] if x['plan']==str(q/'plan.json'));assert record['sourceMatches']==63 and not record['mismatches']
  for path,h in record['sourceInventory'].items():pin(path,h)
  assert all(drift['path'] not in c['argv'] for c in p['commands']);assert drift['usedByAnyChildArgv'] is False
 else:
  m=re.search(r'ordinary-app-(motion|health)(64|256|1024)-actual',str(q));assert m;en,eh=expected[(m[1],int(m[2]))]
 assert p['oracleBytes']==en and p['oracleSHA256']==eh
 outputrow=members[str(q/'consumer.stdout')];n=0
 with gzip.open(b/outputrow['object'],'rb') as actual,gzip.GzipFile(fileobj=io.BytesIO(raw(p['oracle']))) as oracle:
  while chunk:=actual.read(1048576):assert chunk==oracle.read(len(chunk));n+=len(chunk)
  assert oracle.read(1)==b''
 assert n==en==outputrow['bytes'] and outputrow['sha256']==eh;assert raw(q/'consumer.stderr')==b'';classified.append('REUSED_AFFINE_SEMANTICS' if reuse else 'PASS')
for r in members.values():
 if 'hashOnly'in r:assert r['actualPath']in tools
assert classified.count('PASS')==12 and classified.count('REUSED_AFFINE_SEMANTICS')==2
assert len(list((b/'objects').iterdir()))==d['objects'] and len(seen)==d['objects']
print('PASS',len(members),'members',len(seen),'objects',guards,'guards',classified,'manifest',sha((b/'RETENTION.json').read_bytes()))
