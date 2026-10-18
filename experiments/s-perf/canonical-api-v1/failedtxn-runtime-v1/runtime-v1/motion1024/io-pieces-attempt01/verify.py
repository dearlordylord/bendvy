from pathlib import Path
import json,gzip,hashlib,sys
b=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-failedtxn-io-pieces/experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1/runtime-v1/motion1024/io-pieces-attempt01');d=json.loads((b/'RETENTION.json').read_text());sha=lambda x:hashlib.sha256(x).hexdigest();members={r['actualPath']:r for r in d['members']};assert len(members)==len(d['members']);seen={}
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
assert not d['current'] and len(d['history'])==2;guards=0;tools=set();classified=[]
expectedPlans={'js':'867c9c947de1a713a0f659e8f93fcb894809dac0f2011ce63146a19fb3599da2','native':'beb726200e48cf7cfa1bde5a0523f760653601244603e42bc58ecaf206ca0b5d'}
for a in d['current']+d['history']:
 q=Path(a['actualDirectory']);p=obj(q/'plan.json');assert sha(raw(q/'plan.json'))==a['planSHA256']==expectedPlans[p['role']]
 assert len(p['commands'])==1 and p['commands'][0]['label']=='consumer' and p['commands'][0]['capSeconds']==5 and p['commands'][0]['argv'][1:3]==['-c','11']
 for sidecar,h in p['foreignConsumption']['sidecars'].items():
  pin(sidecar,h);assert p['pins'][sidecar]==h
  assert h=={'write-pieces.c':'01cecbe0a31999ad9742c7e21a7a40b54b41b02d5034a90f7a9b6bb124385007','write-pieces.js':'ab28d91424e3f93c461aa563c57f41ad199f478d1ccefe7b2ae102cf20228564'}[Path(sidecar).name]
 producer=p['producer'];pin(producer['plan'],producer['planSHA256']);pin(producer['receipt'],producer['receiptSHA256']);pin(producer['generated'],producer['generatedSHA256']);assert p['generated']==producer['generated']
 pp=obj(producer['plan']);pr=obj(producer['receipt']);assert pr['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS' and pr['planSHA256']==producer['planSHA256'] and all(c['exit']==0 and c['failure'] is None for c in pr['commands'])
 if p['role']=='native':pin(producer['native'],producer['nativeSHA256']);assert p['native']==producer['native']
 for g in pr['guards']:
  pin(g['path'],g['sha256']);guard=obj(g['path']);assert guard['unchanged']
  for path,h in guard['actualPins'].items():pin(path,h)
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
 count=p['runtimeArguments'][0] if p['runtimeArguments'] else '64';expectedN,expectedHash={'64':(38459780,'28595ef3734a1b4772e43d01b63806120db6c452207c31caaddd3d50cb45e3f0'),'256':(118614122,'41a054579aa0e8d224d9d9a99ebbe01cd624b8290651c9d4b95df5b2c0bcf433'),'1024':(444624902,'b46c21923f303fc17c04c31b6af7fef16b45223883356d81c3e94a9c469ed0de')}[count]
 if 'io-pieces-control' in str(q):expectedN,expectedHash=18095,'b5a3c4e914c5435aef380dac96ed3ae05fc5661512cb315f9695db5390832aaf'
 if 'maybe-affine-control' in str(q):expectedN,expectedHash=229,'1dd3c34822329c7f14f9934b679dd7a3c9810322906d9c411f12326b2841e75f'
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
  assert (count,n,outputrow['sha256'])=={'js':('1024',0,'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'),'native':('1024',49319936,'8a8c3887a835c50168fedadfadadaad671c1b6ab297cb8ed569e3779da24812d')}[p['role']]
  classified.append('INCOMPLETE_EXACT_PREFIX')
for r in members.values():
 if 'hashOnly'in r:assert r['actualPath']in tools
assert classified.count('PASS')==0 and classified.count('INCOMPLETE_EXACT_PREFIX')==2;assert len(list((b/'objects').iterdir()))==d['objects'];assert len(seen)==d['objects']+d['referencedObjects'];print('PASS',len(members),'members',len(seen),'objects',guards,'guards',classified,'manifest',sha((b/'RETENTION.json').read_bytes()))
