from pathlib import Path
import json,gzip,hashlib,sys
B=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-workload-lifecycle-boundaries/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/lifecycle-v1/results/motion64-first01');d=json.loads((B/'RETENTION.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();rows={(r['actualPath'],r['sha256']):r for r in d['members']};assert len(rows)==len(d['members']);seen={};context={};tools=set();guards=0;stats={}
for r in rows.values():
 if 'object' not in r:assert r['hashOnly']=='Installed tool/shared library identity only; not redistributed';continue
 p=B/r['object'];assert sha(p.read_bytes())==r['objectSHA256'] and p.name==r['sha256']+'.gz'
 if r['object'] not in seen:
  raw=gzip.decompress(p.read_bytes());seen[r['object']]=(sha(raw),len(raw))
 assert seen[r['object']]==(r['sha256'],r['bytes'])
def pin(path,h):assert (str(path),h) in rows,(path,h);context[str(path)]=h
def raw(path,h=None):
 path=str(path);h=h or context.get(path);choices=[r for (name,x),r in rows.items() if name==path and (h is None or x==h)];assert len(choices)==1,(path,h);return gzip.decompress((B/choices[0]['object']).read_bytes())
def obj(path,h=None):return json.loads(raw(path,h))
assert len(d['cases'])==4
for case in d['cases']:
 q=Path(case['directory']);p=obj(q/'plan.json',case['planSHA256']);r=obj(q/'receipt.json',case['receiptSHA256']);assert sha(raw(q/'plan.json',case['planSHA256']))==r['planSHA256'];context={};normal=case['kind'].startswith('normal-')
 for f,h in p['pins'].items():pin(f,h)
 for root,files in p['resourceRoots'].items():
  for f,h in files.items():name=str(Path(root)/f);pin(name,h);tools.add(name)
 tools.update(p['tools'].values())
 for g in r['guards']:
  pin(g['path'],g['sha256']);guard=obj(g['path']);assert guard['unchanged'];guards+=1
  for f,h in guard['actualPins'].items():pin(f,h)
 assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS';assert len(r['commands'])==len(p['commands'])
 for a,e in zip(r['commands'],p['commands']):
  for k in ['label','argv','capSeconds']:assert a[k]==e[k]
  assert a['failure'] is None;assert a['exit']==e.get('expectedExit',0)
  for k in ['stdout','stderr']:v=a[k];pin(v['path'],v['sha256']);assert len(raw(v['path']))==v['bytes']
 assert raw(q/'consumer.stderr')==b'';canonical=raw(q/'consumer.stdout');assert canonical==gzip.decompress(raw(p['oracle']));assert len(canonical)==3848488 and sha(canonical)==p['oracleSHA256']
 m=p['metricArtifact'];actual=raw(m['path']);stats[case['kind']]=actual
 if normal:
  gold=raw(m['oracle'],m['oracleSHA256']);v=obj(q/'source-metrics.stdout');assert actual==gold and v['status']=='METRICS_PASS'
 else:
  gold=raw(m['normalOracle'],m['normalOracleSHA256']);wrong=raw(m['wrongOracle'],m['wrongOracleSHA256']);assert actual!=gold;v=obj(q/'source-metrics-reject.stdout');w=obj(q/'source-counter-model.stdout');assert v['status']=='METRICS_REJECT';assert w['status']=='METRICS_PASS';assert actual==wrong
 for command in r['commands']:
  if command['label'].startswith('source-'):
   v=obj(command['stdout']['path']);assert v['actualPath']==m['path'] and v['actualSHA256']==sha(actual) and v['actualBytes']==len(actual) and v['stableRegularFile'] is True and v['stats']==json.loads(actual)
assert stats['normal-js']==stats['normal-native']
assert stats['null-control-js']==stats['null-control-native']
# Independently reconstruct only the new reached raw-discard outcome defect.
wrong=json.loads(stats['normal-js']);assert len(wrong)==4226;count=0
for sample in wrong:
 if sample['action']=='unselect':
  assert sample['committed'] is None;sample['committed']=False;count+=1
assert count==4096
assert (json.dumps(wrong,separators=(',',':'))+'\n').encode()==stats['null-control-js']
for row in rows.values():
 if 'hashOnly' in row:assert row['actualPath'] in tools
assert len(seen)==d['objects']==len(list((B/'objects').iterdir()));print('PASS',len(rows),'members',len(seen),'objects',guards,'guards; actualLifecycleMotion64 normalpair+2exactnulloutcomedefects,4226actualreports each; bounded',sha((B/'RETENTION.json').read_bytes()))
