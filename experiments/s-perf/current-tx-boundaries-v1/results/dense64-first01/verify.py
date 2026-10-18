from pathlib import Path
import json,gzip,hashlib,sys
B=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-current-tx-boundaries/experiments/s-perf/current-tx-boundaries-v1/results/dense64-first01');d=json.load(open(B/'RETENTION.json'));sha=lambda b:hashlib.sha256(b).hexdigest();rows={(r['actualPath'],r['sha256']):r for r in d['members']};assert len(rows)==len(d['members']);seen={};context={};tools=set();guards=0;stats={}
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
 q=Path(case['directory']);p=obj(q/'plan.json',case['planSHA256']);r=obj(q/'receipt.json',case['receiptSHA256']);assert sha(raw(q/'plan.json',case['planSHA256']))==r['planSHA256'];context={};history=case['kind']=='original-js-rejected';mutant=case['kind'].startswith('missing-hook')
 for f,h in p['pins'].items():pin(f,h)
 for root,files in p['resourceRoots'].items():
  for f,h in files.items():name=str(Path(root)/f);pin(name,h);tools.add(name)
 tools.update(p['tools'].values())
 for g in r['guards']:
  pin(g['path'],g['sha256']);guard=obj(g['path']);assert guard['unchanged'];guards+=1
  for f,h in guard['actualPins'].items():pin(f,h)
 assert r['status']==('INCOMPLETE' if history else 'COMPLETE_CONSUMER_DEVELOPMENT_PASS');assert len(r['commands'])==len(p['commands'])
 for actual,expected in zip(r['commands'],p['commands']):
  for k in ['label','argv','capSeconds']:assert actual[k]==expected[k]
  assert actual['failure'] is None
  assert actual['exit']==(1 if history and actual['label']=='source-metrics' else expected.get('expectedExit',0))
  for k in ['stdout','stderr']:v=actual[k];pin(v['path'],v['sha256']);assert len(raw(v['path']))==v['bytes']
 assert raw(q/'consumer.stderr')==b'';canonical=raw(q/'consumer.stdout');assert canonical==gzip.decompress(raw(p['oracle']));assert len(canonical)==p['oracleBytes'] and sha(canonical)==p['oracleSHA256']
 metric=p['metricArtifact'];v=obj(q/'source-metrics.stdout');a=raw(metric['path']);assert v['actualPath']==metric['path'] and v['actualSHA256']==sha(a) and v['actualBytes']==len(a) and v['stableRegularFile'] is True;gold=raw(metric['oracle'],metric['oracleSHA256']);assert v['expectedSHA256']==sha(gold);assert v['stats']==json.loads(a);assert v['status']==('METRICS_REJECT' if mutant or history else 'METRICS_PASS');assert (a==gold)==(not mutant and not history)
 if mutant:
  cm=p['counterModel'];wrong=raw(cm['oracle'],cm['oracleSHA256']);assert a==wrong;cv=obj(q/'source-counter-model.stdout');assert cv['status']=='METRICS_PASS' and cv['actualSHA256']==sha(a);assert cv['expectedSHA256']==sha(wrong)
 stats[case['kind']]=a
J=Path(d['jsRevalidation']);context={};p=obj(J/'plan.json');r=obj(J/'receipt.json');assert r['planSHA256']==sha(raw(J/'plan.json'));assert r['status']=='CORRECTED_SOURCE_MODEL_REVALIDATION_PASS' and r['originalCollectorStatus']=='INCOMPLETE' and r['originalMetricStatus']=='METRICS_REJECT' and r['exit']==0
for f,h in p['pins'].items():pin(f,h)
assert sha(raw(J/'validation.stdout'))==r['stdoutSHA256'];assert sha(raw(J/'validation.stderr'))==r['stderrSHA256'];v=obj(J/'validation.stdout');assert v['status']=='METRICS_PASS';corrected=raw(p['command'][3]);assert stats['original-js-rejected']==stats['normal-native']==corrected
oldcase=d['cases'][0];oldp=obj(Path(oldcase['directory'])/'plan.json',oldcase['planSHA256']);old=raw(oldp['metricArtifact']['oracle'],oldp['metricArtifact']['oracleSHA256']);assert old.count(b'resource.replace_join')==4096 and corrected==old.replace(b'resource.replace_join',b'resource-field.journaled')
normal=json.loads(corrected);assert len(normal['reports'])==65
wrong=json.loads(corrected)
for sample in wrong['reports'][1:]:
 tx=sample['tx'];out=[];u=0
 for row in tx['boundaries']:
  if row['site']=='resource-field.journaled':continue
  u+=1;row['current']=[u,0,0];row['peak']=[u,0,0];out.append(row)
 tx['boundaries']=out;tx['consistent']=False
expected=(json.dumps(wrong,separators=(',',':'))+'\n').encode();assert stats['missing-hook-js']==stats['missing-hook-native']==expected
assert not any(name==str(Path(d['unexecutedNativePlan']).parent/'receipt.json') for name,h in rows)
for row in rows.values():
 if 'hashOnly' in row:assert row['actualPath'] in tools
assert len(seen)==d['objects']==len(list((B/'objects').iterdir()));print('PASS',len(rows),'members',len(seen),'objects',guards,'guards; firstDense actualappend pair qualified, original rejection+source-model repair retained,2 exact source counter defects; bounded',sha((B/'RETENTION.json').read_bytes()))
