from pathlib import Path
import json,gzip,hashlib,sys
b=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-failedtxn-row-json/experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1/runtime-v1/motion1024/row-json-attempt01')
d=json.loads((b/'RETENTION.json').read_text());sha=lambda x:hashlib.sha256(x).hexdigest();members={r['actualPath']:r for r in d['members']};assert len(members)==len(d['members']);seen={}
for r in members.values():
 if 'object' not in r:assert r['hashOnly']=='Installed tool/shared library identity only; not redistributed';continue
 p=b/r['object'];assert sha(p.read_bytes())==r['objectSHA256'];assert p.name==r['sha256']+'.gz'
 if r['object'] not in seen:
  h=hashlib.sha256();n=0
  with gzip.open(p,'rb') as f:
   while chunk:=f.read(1048576):h.update(chunk);n+=len(chunk)
  seen[r['object']]=(h.hexdigest(),n)
 assert seen[r['object']]==(r['sha256'],r['bytes'])
def raw(path):
 r=members[str(path)];assert 'object' in r;return gzip.decompress((b/r['object']).read_bytes())
def obj(path):return json.loads(raw(path))
def pin(path,h):assert members[str(path)]['sha256']==h,(path,h)
assert not d['current'] and len(d['history'])==2;guards=0;tools=set()
for dependency in d['objectDependencies']:assert sha((b/dependency['manifest']).read_bytes())==dependency['sha256']
for a in d['history']:
 q=Path(a['actualDirectory']);p=obj(q/'plan.json');r=obj(q/'receipt.json');assert sha(raw(q/'plan.json'))==a['planSHA256']==r['planSHA256'];assert sha(raw(q/'receipt.json'))==a['receiptSHA256'];assert r['status']==a['status']=='INCOMPLETE';assert not r.get('guardFailures',[]);assert len(p['commands'])==len(r['commands'])
 for path,h in p['pins'].items():pin(path,h)
 for root,files in p['resourceRoots'].items():
  for n,h in files.items():path=str(Path(root)/n);pin(path,h);tools.add(path)
 tools.update(p['tools'].values())
 for g in r['guards']:
  pin(g['path'],g['sha256']);v=obj(g['path']);assert v['unchanged'];assert not v.get('failures',[])
  for path,h in v['actualPins'].items():pin(path,h)
  guards+=1
 for c,e in zip(r['commands'],p['commands']):
  for k in ['label','argv','capSeconds']:assert c[k]==e[k]
  assert c['exit'] is None and c['failure']=='child deadline'
  for k in ['stdout','stderr']:
   v=c[k];pin(v['path'],v['sha256']);assert members[v['path']]['bytes']==v['bytes']
 stdout=raw(q/'consumer.stdout');expected=gzip.decompress(raw(p['oracle']));assert len(expected)==444624902 and sha(expected)=='b46c21923f303fc17c04c31b6af7fef16b45223883356d81c3e94a9c469ed0de';assert stdout==expected[:len(stdout)] and len(stdout)<len(expected);assert raw(q/'consumer.stderr')==b''
 if p['role']=='js':assert stdout==b''
 else:assert len(stdout)==85372928 and sha(stdout)=='e01ba4411da787ac80c0cf36fb1edf6f826e072ff72d81a000537796677ab188'
for r in members.values():
 if 'hashOnly' in r:assert r['actualPath'] in tools
assert len(list((b/'objects').iterdir()))==d['objects'];assert len(seen)==d['objects']+d['referencedObjects'];print('PASS',len(members),'members',len(seen),'objects',guards,'guards','2 INCOMPLETE Motion1024 attempts; no qualification','manifest',sha((b/'RETENTION.json').read_bytes()))
