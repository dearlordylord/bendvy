from pathlib import Path
import json,gzip,hashlib,sys
b=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-failedtxn-io-pieces/experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1/runtime-v1/motion64/io-pieces-attempt01');d=json.loads((b/'RETENTION.json').read_text());sha=lambda x:hashlib.sha256(x).hexdigest();members={r['actualPath']:r for r in d['members']};assert len(members)==len(d['members']);seen={}
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
assert len(d['current'])==10 and not d['history'];guards=0;tools=set();classified=[]
expectedPlans={
'/tmp/bendvy21-failedtxn-io-pieces-control-actual01/normal/js':'5b223778ad476c58006bef5d2b051f8749540c3240d4531f6cd9977d2c282a2b',
'/tmp/bendvy21-failedtxn-io-pieces-control-actual01/normal/native':'d6a1403c5ca5c9b0113cc8ee046f6937c8fad5ef00544d6f1b1d44ead8fdc842',
'/tmp/bendvy21-failedtxn-io-pieces-optional-control-actual01/normal/js':'6143ccb38314ea66fe194e63d084cb7d4ba883632d6fc25be5e042647fce3e9f',
'/tmp/bendvy21-failedtxn-io-pieces-optional-control-actual01/normal/native':'1ef194b4e268a8d36e896a1338fe29e7d59afac8cc38e7cd7704499088b5f298',
'/tmp/bendvy21-failedtxn-io-pieces-quad-control-actual01/normal/js':'734a963aec2c98bef79ee3e138ff248ade3a3d3ba73bcad02b18165cc41ab95d',
'/tmp/bendvy21-failedtxn-io-pieces-quad-control-actual01/normal/native':'b01b483bd85aaaf756b271b9ec265a0579af0e0d488595ee4f5a9b65032f114b',
'/tmp/bendvy21-canonical-failedtxn-io-pieces-motion64-actual01/normal/js':'aba6695ae55e57efef7df67ed49c128c0a6bc65cf0aa05ad31785bd825a24aba',
'/tmp/bendvy21-canonical-failedtxn-io-pieces-motion64-actual01/normal/native':'9525960bca7ef97698a58242faa166a70c36155c6dcf2750c70434a0857e131b',
'/tmp/bendvy21-canonical-failedtxn-io-pieces-motion256-actual01/normal/js':'483b5dfcbe43830fcd49f15ef7b2ffab0d27c3c449d03c072412f2fbf28248bc',
'/tmp/bendvy21-canonical-failedtxn-io-pieces-motion256-actual01/normal/native':'0ae92206425636b4c82fc2bb79c6c33c60041466f9c44417d6e512167c4a9ac9'}
assert {r['actualDirectory'] for r in d['current']}==set(expectedPlans)

for a in d['current']+d['history']:
 q=Path(a['actualDirectory']);p=obj(q/'plan.json');assert sha(raw(q/'plan.json'))==a['planSHA256']==expectedPlans[str(q)]
 for path,h in p['pins'].items():pin(path,h)
 for root,files in p['resourceRoots'].items():
  for n,h in files.items():path=str(Path(root)/n);pin(path,h);tools.add(path)
 tools.update(p['tools'].values())
 for sidecar,h in p['foreignConsumption']['sidecars'].items():
  pin(sidecar,h);assert p['pins'][sidecar]==h
  assert h=={'write-pieces.c':'01cecbe0a31999ad9742c7e21a7a40b54b41b02d5034a90f7a9b6bb124385007','write-pieces.js':'ab28d91424e3f93c461aa563c57f41ad199f478d1ccefe7b2ae102cf20228564'}[Path(sidecar).name]
 assert p['foreignConsumption']['typedDeclaration'] in p['sourceInventory'];pin(p['foreignConsumption']['typedDeclaration'],p['foreignConsumption']['typedDeclarationSHA256'])
 rp=str(q/'receipt.json')
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
 if 'io-pieces-control' in str(q):expectedN,expectedHash=146951,'3814c252781752716879b24ed3c70737352380d1cff01dcecd5c491f7e55580d'
 if 'io-pieces-optional-control' in str(q):expectedN,expectedHash=2268,'6d58adb83ef933b31fa59cc2d1030960c0c5706b1229feabb121317abd855fad'
 if 'io-pieces-quad-control' in str(q):expectedN,expectedHash=20345,'4e35fc849521f3706b734e6c3f75b45fa51254518e92bc890d587d9ade5f2ac5'
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
  assert count=='256' # Exact terminal bindings pending.
  classified.append('INCOMPLETE_EXACT_PREFIX')
sourceRoot=Path('/tmp/bendvy-failedtxn-io-pieces/experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1')
forForeign=obj(sourceRoot/'checks/io-pieces-v1/SOURCE-FREEZE.json')
assert forForeign['sourceCheck']['exit']==1 and 'not proof PASS' in forForeign['sourceCheck']['result']
for stem in ['source01','consumer01']:
 err=raw(sourceRoot/'checks/io-pieces-v1'/(stem+'.stderr'));assert b'defs rely on unsafe or foreign code' in err and b'Location:' not in err
assert sha(raw('/tmp/bendvy21-io-pieces-common-independent.stdout'))=='3814c252781752716879b24ed3c70737352380d1cff01dcecd5c491f7e55580d'
for r in members.values():
 if 'hashOnly'in r:assert r['actualPath']in tools
assert classified.count('PASS')==10 and not classified.count('INCOMPLETE_EXACT_PREFIX');assert len(list((b/'objects').iterdir()))==d['objects'];assert len(seen)==d['objects']+d['referencedObjects'];print('PASS',len(members),'members',len(seen),'objects',guards,'guards',classified,'manifest',sha((b/'RETENTION.json').read_bytes()))
