from pathlib import Path
import json,gzip,hashlib,sys
b=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-dense-tx-peaks/experiments/s-perf/canonical-api-v1/dense-runtime-v1/diagnostics/tx-peaks-v1/results/ordinary01');d=json.loads((b/'RETENTION.json').read_text());sha=lambda x:hashlib.sha256(x).hexdigest();members={(r['actualPath'],r['sha256']):r for r in d['members']};assert len(members)==len(d['members']);seen={};context={};guards=0;outputs={};tools=set();invs={}
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
assert len(d['cases'])==4
stats={};sources={}
for case in d['cases']:
 q=Path(case['directory']);p=obj(q/'plan.json');r=obj(q/'receipt.json');assert sha(raw(q/'plan.json'))==case['planSHA256']==r['planSHA256'];assert sha(raw(q/'receipt.json'))==case['receiptSHA256'];assert not r.get('guardFailures',[])
 for name,h in p['pins'].items():pin(name,h)
 for root,files in p['resourceRoots'].items():
  for name,h in files.items():path=str(Path(root)/name);pin(path,h);tools.add(path)
 tools.update(p['tools'].values())
 for g in r['guards']:
  pin(g['path'],g['sha256']);guard=obj(g['path']);assert guard['unchanged'];guards+=1
  for name,h in guard['actualPins'].items():pin(name,h)
 assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS' and len(r['commands'])==len(p['commands'])
 for c,e in zip(r['commands'],p['commands']):
  for k in ['label','argv','capSeconds']:assert c[k]==e[k]
  assert c['exit']==e.get('expectedExit',0) and c['failure'] is None
  for key in ['stdout','stderr']:v=c[key];pin(v['path'],v['sha256']);assert len(raw(v['path']))==v['bytes']
 assert raw(q/'consumer.stderr')==b'';actual=raw(q/'consumer.stdout');expected=gzip.decompress(raw(p['oracle']));assert actual==expected;assert len(actual)==89045==p['oracleBytes'] and sha(actual)==p['oracleSHA256']=='9526d54ea92ce3c9ca6fc874a9a697d84c45016d1ee8de2392530c5a40c9b0d6'
 metric=p['metricArtifact'];v=obj(q/'source-metrics.stdout');m=raw(metric['path']);gold=raw(metric['oracle']);assert v['actualPath']==metric['path'] and v['actualBytes']==len(m) and v['actualSHA256']==sha(m);assert v['expectedPath']==metric['oracle'] and v['expectedSHA256']==sha(gold)==metric['oracleSHA256'];assert v['stableRegularFile'] is True and v['stats']==json.loads(m)
 normal=case['kind']=='normal';assert v['status']==('METRICS_PASS' if normal else 'METRICS_REJECT');assert raw(q/'source-metrics.stderr')==(v['status']+'\n').encode();assert (m==gold)==normal
 value=json.loads(m);expectedStats=json.loads(gold);assert len(value['samples'])==65
 if not normal:
  for a,e in zip(value['samples'],expectedStats['samples']):assert a==dict(e,undo=e['undo']+1)
 stats[case['kind'],case['role']]=m;sources[case['kind']]=p['sourceInventory']
assert stats['normal','js']==stats['normal','native'] and stats['mutant','js']==stats['mutant','native']
a={Path(p).name:h for p,h in sources['normal'].items() if '/subject/' in p};z={Path(p).name:h for p,h in sources['mutant'].items() if '/counter-mutant/' in p};assert a.keys()==z.keys() and [p for p in a if a[p]!=z[p]]==['tx-metrics.bend']
normalPath=next(p for p in sources['normal'] if p.endswith('/subject/tx-metrics.bend'));mutantPath=next(p for p in sources['mutant'] if p.endswith('/counter-mutant/tx-metrics.bend'));assert raw(mutantPath)==raw(normalPath).replace(b'Nat.show(undo)',b'Nat.show(1n+undo)')
for row in members.values():
 if 'hashOnly' in row:assert row['actualPath'] in tools
assert len(seen)==d['objects']==len(list((b/'objects').iterdir()));print('PASS',len(members),'members',len(seen),'objects',guards,'guards;4 full canonical PASS;2 exact metric PASS;2 reporter defects REJECT','manifest',sha((b/'RETENTION.json').read_bytes()))
