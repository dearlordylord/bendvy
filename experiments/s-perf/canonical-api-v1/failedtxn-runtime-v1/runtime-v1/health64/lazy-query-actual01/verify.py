from pathlib import Path
import json,gzip,hashlib,sys
b=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-failedtxn-health-lazy-query/experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1/runtime-v1/health64/lazy-query-actual01')
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
assert len(d['current'])==2 and not d['history'];guards=0;tools=set()
for a in d['current']:
 q=Path(a['actualDirectory']);p=obj(q/'plan.json');r=obj(q/'receipt.json');assert sha(raw(q/'plan.json'))==a['planSHA256']==r['planSHA256'];assert sha(raw(q/'receipt.json'))==a['receiptSHA256'];assert r['status']==a['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS';assert len(p['commands'])==len(r['commands'])
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
  assert c['exit']==0 and c['failure'] is None
  for k in ['stdout','stderr']:
   v=c[k];pin(v['path'],v['sha256']);assert members[v['path']]['bytes']==v['bytes']
 stdout=raw(q/'consumer.stdout');expected=gzip.decompress(raw(p['oracle']));assert stdout==expected and len(stdout)==38400832 and sha(stdout)=='a20f7dccdf2efd66b44cb4dde507b0f7256ea493c1d3d5935d12f97db0ef5a95';assert raw(q/'consumer.stderr')==b'';assert a['bytes']==len(stdout) and a['sha256']==sha(stdout)
for r in members.values():
 if 'hashOnly' in r:assert r['actualPath'] in tools
assert len(seen)==d['objects'];print('PASS',len(members),'members',len(seen),'objects',guards,'guards','2 complete Health64 roles','manifest',sha((b/'RETENTION.json').read_bytes()))
