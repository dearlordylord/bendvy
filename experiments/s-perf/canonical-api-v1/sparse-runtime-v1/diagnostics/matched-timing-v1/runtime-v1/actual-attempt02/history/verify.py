from pathlib import Path
import json,gzip,hashlib,sys
b=Path(sys.argv[1])if len(sys.argv)>1 else Path('/tmp/bendvy-sparse-matched-method/experiments/s-perf/canonical-api-v1/sparse-runtime-v1/diagnostics/matched-timing-v1/runtime-v1/actual-attempt02/history');sha=lambda x:hashlib.sha256(x).hexdigest();d=json.loads((b/'RETENTION.json').read_text());members={r['actualPath']:r for r in d['members']};assert len(members)==len(d['members']);seen={}
for r in members.values():
 if 'object'not in r:assert r['hashOnly']=='Installed tool/shared library identity only; not redistributed';continue
 p=b/r['object'];assert sha(p.read_bytes())==r['objectSHA256'] and p.name==r['sha256']+'.gz'
 if r['object']not in seen:
  h=hashlib.sha256();n=0
  with gzip.open(p,'rb')as f:
   while chunk:=f.read(1048576):h.update(chunk);n+=len(chunk)
  seen[r['object']]=(h.hexdigest(),n)
 assert seen[r['object']]==(r['sha256'],r['bytes'])
def raw(p):return gzip.decompress((b/members[str(p)]['object']).read_bytes())
def obj(p):return json.loads(raw(p))
def pin(p,h):assert members[str(p)]['sha256']==h,(p,h)
guards=0;tools=set()
for role in ['native','ts']:assert str(Path('/tmp/bendvy21-sparse-motion-b1-method-pilot-actual01')/role/'receipt.json')not in members
for case in d['cases']:
 q=Path(case['directory']);p=obj(q/'plan.json');r=obj(q/'receipt.json');assert sha(raw(q/'plan.json'))==case['planSHA256']==r['planSHA256'];assert sha(raw(q/'receipt.json'))==case['receiptSHA256'];assert r['status']==case['status']
 tools.update(p['tools'].values())
 for n,h in p['pins'].items():pin(n,h)
 for root,files in p['resourceRoots'].items():
  for n,h in files.items():name=str(Path(root)/n);pin(name,h);tools.add(name)
 for g in r['guards']:
  pin(g['path'],g['sha256']);v=obj(g['path']);assert v['unchanged'];guards+=1
  for n,h in v['actualPins'].items():pin(n,h)
 assert len(r['commands'])==len(p['commands'])
 for c,e in zip(r['commands'],p['commands']):
  for k in ['label','argv','capSeconds']:assert c[k]==e[k]
  assert c['failure']is None
  for k in ['stdout','stderr']:pin(c[k]['path'],c[k]['sha256']);assert len(raw(c[k]['path']))==c[k]['bytes']
 if case['status']=='INCOMPLETE':
  assert len(r['commands'])==2 and r['commands'][0]['label']=='emit'and r['commands'][0]['exit']==0
  c=r['commands'][1];assert c['exit']==1 and raw(c['stdout']['path'])==b'WARMUP\n'and raw(c['stderr']['path'])==b'bend: memory fault (machine stack overflow?)\n'
 else:
  assert len(r['commands'])==1;c=r['commands'][0];assert c['exit']==1==p['commands'][0]['expectedExit']and c['sourceControlPassed'];assert raw(c['stdout']['path'])==b'WARMUP\n';err=raw(c['stderr']['path']);assert len(err)==1260 and b'RangeError: Maximum call stack size exceeded' in err and b'$List$append$'in err
  x=p['diagnosticArtifact'];a=raw(x['originalPath']);z=raw(x['diagnosticPath']);assert sha(a)==x['originalSHA256']and sha(z)==x['diagnosticSHA256'];assert z==a.replace(b'    if (req instanceof RangeError) {\n',b'    if (req instanceof RangeError) {\n      console.error(String(req.stack).slice(0, 16384));\n',1)
historical=[r for r in members.values()if'historicalGitObject'in r];assert len(historical)==1 and historical[0]['historicalGitObject'].startswith('c9534316076ba6eaa725bc59a1aa75ee9c7286d8:')
for r in members.values():
 if'hashOnly'in r:assert r['actualPath']in tools
assert len(seen)==d['objects']==len(list((b/'objects').iterdir()))
print('PASS historical',len(members),'members',len(seen),'objects',guards,'guards; exactfailure+stackdiagnostic,1explicitgit-source-recovery; manifest',sha((b/'RETENTION.json').read_bytes()))
