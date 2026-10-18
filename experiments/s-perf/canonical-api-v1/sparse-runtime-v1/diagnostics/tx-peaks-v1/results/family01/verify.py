from pathlib import Path
import json,gzip,hashlib,sys
b=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-sparse-tx-peaks/experiments/s-perf/canonical-api-v1/sparse-runtime-v1/diagnostics/tx-peaks-v1/results/family01');d=json.loads((b/'RETENTION.json').read_text());sha=lambda x:hashlib.sha256(x).hexdigest();members={(r['actualPath'],r['sha256']):r for r in d['members']};assert len(members)==len(d['members']);seen={};context={};guards=0;outputs={};tools=set();invs={}
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
assert len(d['cases'])==12
dep=d['acceptedCounterDependency'];assert sha(raw(dep['manifest']))==dep['sha256']=='6b5d3bee7113838a000d095342608bc9cd4fd0fd96ff5eb4dfd5bf920dbc803a'
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
 assert v['status']=='METRICS_PASS' and raw(q/'source-metrics.stderr')==b'METRICS_PASS\n' and m==gold
 value=json.loads(m);count=case['count'];expectedSamples=[{'kind':'seed','undo':count,'commands':count,'events':0}]+[{'kind':'query-loop','undo':2*len(range(0,count,8)),'commands':0,'events':0} for _ in range(64)];assert value=={'samples':expectedSamples}
 stats[case['schema'],count,case['role']]=m
 metricSources=[path for path in p['sourceInventory'] if path.endswith('/tx-metrics.bend')];assert len(metricSources)==1;sources[case['schema']]=sha(raw(metricSources[0]))
for schema,count in [(schema,n) for schema in ['motion','health'] for n in [64,256,1024]]:assert stats[schema,count,'js']==stats[schema,count,'native']
assert sources['motion']==sources['health']=='d729404ef603f65ba07a112eb3598a4ad423a911d94a909931675a1d1f2e965a'
for row in members.values():
 if 'hashOnly' in row:assert row['actualPath'] in tools
assert len(seen)==d['objects']==len(list((b/'objects').iterdir()));print('PASS',len(members),'members',len(seen),'objects',guards,'guards;12 full canonical+sealed metric PASS;accepted reporter defect dependency pinned','manifest',sha((b/'RETENTION.json').read_bytes()))
