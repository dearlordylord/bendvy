from pathlib import Path
import json,gzip,hashlib,sys,copy,collections
b=Path(sys.argv[1]);d=json.loads((b/'RETENTION.json').read_text());sha=lambda x:hashlib.sha256(x).hexdigest();members={(r['actualPath'],r['sha256']):r for r in d['members']};assert len(members)==len(d['members']);seen={};context={};guards=0;tools=set();outputs={};plans={}
for row in members.values():
 if 'object' not in row:assert row['hashOnly']=='Installed tool/shared library identity only; not redistributed';continue
 p=b/row['object'];assert sha(p.read_bytes())==row['objectSHA256'];assert p.name==row['sha256']+'.gz'
 if row['object'] not in seen:
  value=gzip.decompress(p.read_bytes());seen[row['object']]=(sha(value),len(value))
 assert seen[row['object']]==(row['sha256'],row['bytes'])
def blob(path,h):
 row=members[str(path),h];return gzip.decompress((b/row['object']).read_bytes())
def raw(path):
 path=str(path);choices=[r for (name,h),r in members.items()if name==path and(name not in context or h==context[name])];assert len(choices)==1,(path,len(choices));return blob(path,choices[0]['sha256'])
def obj(path):return json.loads(raw(path))
def pin(name,h):assert(str(name),h)in members,(name,h);context[str(name)]=h
def flatten(value,prefix=''):
 if isinstance(value,int):return{prefix:value}
 result={}
 if isinstance(value,dict):
  for k,v in value.items():result.update(flatten(v,(prefix+'.'if prefix else '')+k))
 elif isinstance(value,list):
  for i,v in enumerate(value):result.update(flatten(v,prefix+'.'+str(i)))
 return result
assert len(d['cases'])==2
for case in d['cases']:
 q=Path(case['directory']);p=obj(q/'plan.json');r=obj(q/'receipt.json');assert sha(raw(q/'plan.json'))==case['planSHA256']==r['planSHA256'];assert sha(raw(q/'receipt.json'))==case['receiptSHA256'];assert not r.get('guardFailures',[])
 for name,h in p['pins'].items():pin(name,h)
 for root,files in p['resourceRoots'].items():
  for name,h in files.items():path=str(Path(root)/name);pin(path,h);tools.add(path)
 tools.update(p['tools'].values())
 for g in r['guards']:
  pin(g['path'],g['sha256']);guard=obj(g['path']);assert guard['unchanged'];guards+=1
  for name,h in guard['actualPins'].items():pin(name,h)
 assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'and len(r['commands'])==len(p['commands'])
 for command,declared in zip(r['commands'],p['commands']):
  for k in ['label','argv','capSeconds']:assert command[k]==declared[k]
  assert command['exit']==declared.get('expectedExit',0)and command['failure']is None
  for key in ['stdout','stderr']:v=command[key];pin(v['path'],v['sha256']);assert len(raw(v['path']))==v['bytes']
  for token in declared.get('stderrContains',[]):assert token.encode()in raw(q/(command['label']+'.stderr'))
 assert raw(q/'consumer.stderr')==b'';actual=raw(q/'consumer.stdout');expected=gzip.decompress(raw(p['oracle']));assert actual==expected;assert len(actual)==p['oracleBytes']and sha(actual)==p['oracleSHA256']
 metric=p['metricArtifact'];actualMetric=raw(metric['path']);gold=raw(metric['oracle']);assert actualMetric==gold
 assert len(actual)==413934 and sha(actual)=='7bc64f59bd9975f79ff6bf51e1156b90170e345898c3c889779686f37f90002b'
 assert len(actualMetric)==109024 and sha(actualMetric)=='9a7d75dbb1dc7a56ce5bc358d6a9daaf27726a177f94697b82467e7a526b139e'
 v=obj(q/'source-metrics.stdout');assert v['status']=='METRICS_PASS' and v['stableRegularFile']is True and v['actualPath']==metric['path'] and v['actualSHA256']==sha(actualMetric) and v['expectedSHA256']==sha(gold) and v['stats']==json.loads(gold)
 rows=json.loads(actualMetric)['reports'];assert len(rows)==65
 for i,row in enumerate(rows):
  tx=row['tx'];u=c=e=0;peak=[0,0,0]
  for boundary in tx['boundaries']:
   du,dc,de=boundary['delta'];u+=du;c+=dc;e+=de;peak=[max(a,z)for a,z in zip(peak,[u,c,e])]
   assert boundary['current']==[u,c,e]and boundary['peak']==peak
  assert tx['terminal']==[u,c,e]and tx['consistent']is True and row['completion']=='committed'
  assert len(tx['boundaries'])==(128 if i==0 else 16)and tx['terminal']==([64,64,0]if i==0 else[16,0,0])
 outputs[case['role']]=actualMetric
assert outputs['js']==outputs['native']
assert len(tools)>0
for row in members.values():
 if 'hashOnly'in row:assert row['actualPath']in tools
W=Path('/tmp/bendvy-sparse-motion-boundaries');D=W/'experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/sparse-v1/motion-v1'
reuse=obj(D/'checks/CONTROL-APPLICABILITY.json')
import re
strip=lambda v:re.sub(rb'^import .*\n',b'',v,flags=re.M)
for relative,join in reuse['privateCoreNonImportBodyJoins'].items():
 candidate=blob(D/relative,join['candidateSHA256']);accepted=blob(W/join['acceptedPath'],join['acceptedSHA256']);assert strip(candidate)==strip(accepted)and sha(strip(candidate))==join['nonImportBodySHA256']
assert sha(raw(D/'meter.bend'))==reuse['meterSHA256']
for name,h in d['reusedDenseFiles'].items():assert sha((b/'reused-dense'/name).read_bytes())==h
old=json.loads((b/'reused-dense/RETENTION.json').read_text());assert sha((b/'reused-dense/RETENTION.json').read_bytes())==reuse['acceptedManifest']['sha256']
assert[x for x in old['cases']if x['kind'].startswith('missing-hook')]==reuse['acceptedCases']
for row in old['members']:
 if 'object'in row:
  f=b/'reused-dense'/row['object'];assert sha(f.read_bytes())==row['objectSHA256'];v=gzip.decompress(f.read_bytes());assert sha(v)==row['sha256']and len(v)==row['bytes']
print('PASS',len(members),'members',len(seen),'objects',guards,'guards;2newSparsecases+exactacceptedDensecontrolpacket/sourcejoins')
