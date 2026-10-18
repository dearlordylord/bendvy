from pathlib import Path
import json,gzip,hashlib,sys
b=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-lifecycle-ordinary-app/experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/runtime-v1/ordinary-app-family01');d=json.loads((b/'RETENTION.json').read_text());sha=lambda x:hashlib.sha256(x).hexdigest();members={r['actualPath']:r for r in d['members']};assert len(members)==len(d['members']);seen={}
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
assert len(d['current'])==12 and len(d['history'])==0;guards=0;tools=set();classified=[]
for a in d['current']+d['history']:
 q=Path(a['actualDirectory']);p=obj(q/'plan.json');assert sha(raw(q/'plan.json'))==a['planSHA256']
 for path,h in p['pins'].items():pin(path,h)
 for root,files in p['resourceRoots'].items():
  for n,h in files.items():path=str(Path(root)/n);pin(path,h);tools.add(path)
 tools.update(p['tools'].values());rp=str(q/'receipt.json')
 if rp not in members:assert a['status']=='UNEXECUTED' and p['runtimeArguments']==['1024','64'];classified.append('UNEXECUTED_1024');continue
 r=obj(rp);assert r['planSHA256']==a['planSHA256'] and sha(raw(rp))==a['receiptSHA256'];assert not r.get('guardFailures',[]);assert len(p['commands'])==len(r['commands'])
 for g in r['guards']:
  pin(g['path'],g['sha256']);v=obj(g['path']);assert v['unchanged']
  for path,h in v['actualPins'].items():pin(path,h)
  guards+=1
 for c,e in zip(r['commands'],p['commands']):
  for k in ['label','argv','capSeconds']:assert c[k]==e[k]
  for k in ['stdout','stderr']:
   v=c[k];pin(v['path'],v['sha256']);assert members[v['path']]['bytes']==v['bytes']
 assert raw(q/'consumer.stderr')==b''
 count=p['runtimeArguments'][0];schema='health' if 'health' in str(q) else 'motion'
 expectedN,expectedHash={'motion':{'64':(3848488,'ff435edc418dbded9b6e76106da002fbe1058f919879f065fb6281c4f58cca05'),'256':(14372070,'8189f8014728da73657aea2ed95e56b5c80f30edc8cc2c34561b9ee2a145c62d'),'1024':(57594965,'24c5b13acdd5ffd6cfa9181bb99f8c160b4899fba1f52a88183d2b5aba50966a')},'health':{'64':(3904540,'c30881d63a508601b736a6fa5973237ed6ec1afd800c9da265ad8c8aa8e7a851'),'256':(14649881,'159f4cf175f2b605200a7ab26df21051c27ae76d766ee10b98cde58b46fb3b29'),'1024':(58759817,'b29e11da6067af6c3433e7c6679b0ba9d57dc3ff828c03b8c01ece333d109ec0')}}[schema][count]
 assert p['oracleBytes']==expectedN and p['oracleSHA256']==expectedHash
 # Compare every retained actual byte to the independently bound oracle, streaming.
 import io
 outputrow=members[str(q/'consumer.stdout')];n=0
 with gzip.open(b/outputrow['object'],'rb') as actual, gzip.GzipFile(fileobj=io.BytesIO(raw(p['oracle']))) as expected:
  while chunk:=actual.read(1048576):assert chunk==expected.read(len(chunk));n+=len(chunk)
  if a in d['current']:assert expected.read(1)==b''
 assert n==outputrow['bytes']
 if a in d['current']:
  assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS' and all(c['exit']==0 and c['failure'] is None for c in r['commands']);assert n==expectedN and outputrow['sha256']==expectedHash;classified.append('PASS')
 else:
  assert r['status']=='INCOMPLETE' and r['commands'][-1]['exit'] is None and r['commands'][-1]['failure']=='child deadline'
  assert (count,p['role'],n,outputrow['sha256'])==('1024','native',222023680,'bf62bd35d7365d1aa38244927bb6f876ee5539c89155a8c0b5b0399db39048e6')
  classified.append('INCOMPLETE_EXACT_PREFIX')
for r in members.values():
 if 'hashOnly'in r:assert r['actualPath']in tools
assert classified.count('PASS')==12 and classified.count('INCOMPLETE_EXACT_PREFIX')==0;assert len(list((b/'objects').iterdir()))==d['objects'];assert len(seen)==d['objects']+d['referencedObjects'];print('PASS',len(members),'members',len(seen),'objects',guards,'guards',classified,'manifest',sha((b/'RETENTION.json').read_bytes()))
