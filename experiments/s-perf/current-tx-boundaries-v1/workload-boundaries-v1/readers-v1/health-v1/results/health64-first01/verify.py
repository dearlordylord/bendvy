from pathlib import Path
import json,gzip,hashlib,sys
B=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-workload-readers-health-boundaries/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/readers-v1/health-v1/results/health64-first01');d=json.loads((B/'RETENTION.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();rows={(r['actualPath'],r['sha256']):r for r in d['members']};assert len(rows)==len(d['members']);seen={};context={};tools=set();guards=0;stats={}
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
assert len(d['cases'])==2
assert {c['kind'] for c in d['cases']}=={'normal-js','normal-native'}
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
 assert raw(q/'consumer.stderr')==b'';canonical=raw(q/'consumer.stdout');assert canonical==gzip.decompress(raw(p['oracle']));assert len(canonical)==8077591 and sha(canonical)==p['oracleSHA256']
 m=p['metricArtifact'];actual=raw(m['path']);stats[case['kind']]=actual
 assert normal
 gold=raw(m['oracle'],m['oracleSHA256']);v=obj(q/'source-metrics.stdout');assert actual==gold and v['status']=='METRICS_PASS'
 if case['kind']=='normal-js':
  module=p['moduleInterpretation'];pin(module['path'],module['sha256']);assert obj(module['path'])=={'type':'commonjs'}
 for command in r['commands']:
  if command['label'].startswith('source-'):
   v=obj(command['stdout']['path']);assert v['actualPath']==m['path'] and v['actualSHA256']==sha(actual) and v['actualBytes']==len(actual) and v['stableRegularFile'] is True and v['stats']==json.loads(actual)
assert stats['normal-js']==stats['normal-native']
normal=json.loads(stats['normal-js']);assert len(normal)==277
assert [x['group'] for x in normal]==['domain']*193+['reader']*84
assert all(x['cursor'] is None for x in normal)
assert [x['ordinal'] for x in normal[:193]]==list(range(193))
assert [x['ordinal'] for x in normal[193:]]==list(range(84))
for row in rows.values():
 if 'hashOnly' in row:assert row['actualPath'] in tools
assert len(seen)==d['objects']==len(list((B/'objects').iterdir()));print('PASS',len(rows),'members',len(seen),'objects',guards,'guards; actualReadersHealth64 fullnormalpair,277actualreports each; genericcontrols external; bounded',sha((B/'RETENTION.json').read_bytes()))
