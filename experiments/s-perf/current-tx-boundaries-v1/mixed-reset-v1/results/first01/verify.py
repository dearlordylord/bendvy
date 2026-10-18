from pathlib import Path
import json,gzip,hashlib,sys
B=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-current-tx-mixed-reset/experiments/s-perf/current-tx-boundaries-v1/mixed-reset-v1/results/first01');d=json.loads((B/'RETENTION.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();rows={(r['actualPath'],r['sha256']):r for r in d['members']};assert len(rows)==len(d['members']);seen={};context={};tools=set();guards=0;stats={}
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
assert len(d['cases'])==8
for case in d['cases']:
 q=Path(case['directory']);p=obj(q/'plan.json',case['planSHA256']);r=obj(q/'receipt.json',case['receiptSHA256']);assert sha(raw(q/'plan.json',case['planSHA256']))==r['planSHA256'];context={};history=case['kind']=='original-omitted-js-rejected';normal=case['kind'].startswith('normal-')
 for f,h in p['pins'].items():pin(f,h)
 for root,files in p['resourceRoots'].items():
  for f,h in files.items():name=str(Path(root)/f);pin(name,h);tools.add(name)
 tools.update(p['tools'].values())
 for g in r['guards']:
  pin(g['path'],g['sha256']);guard=obj(g['path']);assert guard['unchanged'];guards+=1
  for f,h in guard['actualPins'].items():pin(f,h)
 assert r['status']==('INCOMPLETE' if history else 'COMPLETE_CONSUMER_DEVELOPMENT_PASS');assert len(r['commands'])==len(p['commands'])
 for a,e in zip(r['commands'],p['commands']):
  for k in ['label','argv','capSeconds']:assert a[k]==e[k]
  assert a['failure'] is None;assert a['exit']==(1 if history and a['label']=='source-metrics-exact-wrong' else e.get('expectedExit',0))
  for k in ['stdout','stderr']:v=a[k];pin(v['path'],v['sha256']);assert len(raw(v['path']))==v['bytes']
 assert raw(q/'consumer.stderr')==b'';canonical=raw(q/'consumer.stdout');assert canonical==gzip.decompress(raw(p['oracle']));assert len(canonical)==2446 and sha(canonical)==p['oracleSHA256']
 m=p['metricArtifact'];actual=raw(m['path']);stats[case['kind']]=actual
 if normal:
  gold=raw(m['oracle'],m['oracleSHA256']);v=obj(q/'source-metrics.stdout');assert actual==gold and v['status']=='METRICS_PASS'
 else:
  gold=raw(m['normalOracle'],m['normalOracleSHA256']);wrong=raw(m['wrongOracle'],m['wrongOracleSHA256']);assert actual!=gold;v=obj(q/'source-metrics-reject.stdout');w=obj(q/'source-metrics-exact-wrong.stdout');assert v['status']=='METRICS_REJECT';assert w['status']==('METRICS_REJECT' if history else 'METRICS_PASS');assert (actual==wrong)==(not history)
  if history:assert actual==wrong+b'\n'
 for command in r['commands']:
  if command['label'].startswith('source-metrics'):
   v=obj(command['stdout']['path']);assert v['actualPath']==m['path'] and v['actualSHA256']==sha(actual) and v['actualBytes']==len(actual) and v['stableRegularFile'] is True and v['stats']==json.loads(actual)
J=Path(d['jsRevalidation']);context={};p=obj(J/'plan.json');r=obj(J/'receipt.json');assert r['planSHA256']==sha(raw(J/'plan.json'));assert r['status']=='CORRECTED_SOURCE_MODEL_REVALIDATION_PASS' and r['originalCollectorStatus']=='INCOMPLETE'
for f,h in p['pins'].items():pin(f,h)
assert len(r['commands'])==len(p['commands'])==len(p['expectedExits'])==2
for i,command in enumerate(r['commands']):
 assert command['argv']==p['commands'][i] and command['exit']==p['expectedExits'][i];assert sha(raw(J/f'validation{i}.stdout'))==command['stdoutSHA256'];assert sha(raw(J/f'validation{i}.stderr'))==command['stderrSHA256'];assert obj(J/f'validation{i}.stdout')['status']==('METRICS_REJECT' if i==0 else 'METRICS_PASS')
assert stats['normal-js']==stats['normal-native'];assert stats['original-omitted-js-rejected']==stats['omitted-reset-native']
for name in ['wrong-category','corrupt-counter']:assert stats[name+'-js']==stats[name+'-native']
# Independently reconstruct all wrong cached paths from sealed normal deltas and actual terminal counts.
for name in ['omitted-reset','wrong-category','corrupt-counter']:
 gold=json.loads(stats['normal-js'])
 for case in gold['cases']:
  for sample in case['reports']:
   tx=sample['tx'];current=[0,0,0];peak=[0,0,0]
   for row in tx['boundaries']:
    delta=row['delta'][:]
    if name=='wrong-category' and row['site']=='transaction.emit':delta=[0,1,0];row['delta']=delta
    if row['site']=='bundle-batch.stage':
     if name!='omitted-reset':current[1]=0
    else:
     current=[a+b for a,b in zip(current,delta)]
     if name=='corrupt-counter':current[0]+=1
    peak=[max(a,b) for a,b in zip(peak,current)];row['current']=current[:];row['peak']=peak[:]
   tx['consistent']=current==tx['terminal']
 expected=(json.dumps(gold,separators=(',',':'))+'\n').encode();actual=stats['original-omitted-js-rejected'] if name=='omitted-reset' else stats[name+'-js'];assert expected==actual
for plan in d['unexecutedPlans']:assert not any(name==str(Path(plan).parent/'receipt.json') for name,h in rows)
for row in rows.values():
 if 'hashOnly' in row:assert row['actualPath'] in tools
assert len(seen)==d['objects']==len(list((B/'objects').iterdir()));print('PASS',len(rows),'members',len(seen),'objects',guards,'guards; normal pair+6 exact accounting defects, historical framing rejection and immutable repair retained; bounded',sha((B/'RETENTION.json').read_bytes()))
