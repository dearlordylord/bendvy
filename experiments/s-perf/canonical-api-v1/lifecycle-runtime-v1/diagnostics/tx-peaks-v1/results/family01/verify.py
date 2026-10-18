from pathlib import Path
import json,gzip,hashlib,sys
b=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-lifecycle-tx-peaks/experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/diagnostics/tx-peaks-v1/results/family01');d=json.loads((b/'RETENTION.json').read_text());sha=lambda x:hashlib.sha256(x).hexdigest();members={(r['actualPath'],r['sha256']):r for r in d['members']};assert len(members)==len(d['members']);seen={};context={};guards=0;outputs={};tools=set();invs={}
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
assert len(d['cases'])==14
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
 assert raw(q/'consumer.stderr')==b'';actual=raw(q/'consumer.stdout');expected=gzip.decompress(raw(p['oracle']));assert actual==expected;assert len(actual)==p['oracleBytes'] and sha(actual)==p['oracleSHA256']
 metric=p['metricArtifact'];v=obj(q/'source-metrics.stdout');m=raw(metric['path']);gold=raw(metric['oracle']);assert v['actualPath']==metric['path'] and v['actualBytes']==len(m) and v['actualSHA256']==sha(m);assert v['expectedPath']==metric['oracle'] and v['expectedSHA256']==sha(gold)==metric['oracleSHA256'];assert v['stableRegularFile'] is True and v['stats']==json.loads(m)
 normal=case['kind']=='normal';assert v['status']==('METRICS_PASS' if normal else 'METRICS_REJECT') and raw(q/'source-metrics.stderr')==(v['status']+'\n').encode();assert (m==gold)==normal
 value=json.loads(m);count=case['count'];expectedSamples=[{'kind':'main-seed','undo':count,'commands':count,'events':0},{'kind':'foreign-seed','undo':1,'commands':1,'events':0}]+[{'kind':'reserve','undo':1,'commands':1,'events':0} for _ in range(64)]+[{'kind':'dispose','undo':0,'commands':2,'events':0} for _ in range(64)]
 if not normal:expectedSamples=[dict(row,undo=row['undo']+1) for row in expectedSamples]
 assert value=={'samples':expectedSamples} and len(value['samples'])==130
 stats[case['kind'],case['schema'],count,case['role']]=m
 metricSources=[path for path in p['sourceInventory'] if path.endswith('/tx-metrics.bend')];assert len(metricSources)==1;sources[case['kind'],case['schema']]=raw(metricSources[0])
for schema in ['motion','health']:
 for count in [64,256,1024]:assert stats['normal',schema,count,'js']==stats['normal',schema,count,'native']
assert stats['mutant','motion',64,'js']==stats['mutant','motion',64,'native'];assert sources['normal','motion']==sources['normal','health'];assert sources['mutant','motion']==sources['normal','motion'].replace(b'Nat.show(undo)',b'Nat.show(1n+undo)')
for row in members.values():
 if 'hashOnly' in row:assert row['actualPath'] in tools
assert len(seen)==d['objects']==len(list((b/'objects').iterdir()));print('PASS',len(members),'members',len(seen),'objects',guards,'guards;12 full LC2+130 grouped metrics PASS;2 compiling reporter defects REJECT with normal LC2 unchanged;terminal-only','manifest',sha((b/'RETENTION.json').read_bytes()))
