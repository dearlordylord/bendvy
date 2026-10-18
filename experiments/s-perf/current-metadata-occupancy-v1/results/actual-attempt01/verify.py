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
assert len(d['cases'])==6
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
 kind=case['kind'];role=case['role'];plans[kind,role]=p
 if kind=='fixture':
  assert len(actual)==4981 and sha(actual)=='ce0d2cfa993708107c9c3bd6ee65b5c4ff6accc5be1f3f44871672eed2f3e3e6';v=json.loads(actual)
  assert list(v)==['plain','exceptional','unequal','capacitySplit','prepared','preparedIndexed','restore','rollback']
  assert v['rollback']['outcome']=='Failure'and v['rollback']['clock']==3 and v['rollback']['stamp']==[1,1]
  assert[x['site']for x in v['rollback']['trace']['main']]==['empty','mark','mark','restore_stamp']
  outputs[kind,role]=actual;continue
 assert len(actual)==10810200 and sha(actual)=='183936740ad2407530099198388cc87d872b121fa0681a3a7777ec42797b83ce'
 metric=p['metricArtifact'];actualMetric=raw(metric['path']);gold=raw(metric['oracle']);value=json.loads(actualMetric);normal=json.loads(gold)
 labels=['source-metrics']if kind=='normal'else['source-metrics-normal','source-metrics-counter']
 for label in labels:
  command=next(x for x in p['commands']if x['label']==label);expectedPath=command['argv'][-1];goldBytes=raw(expectedPath);v=obj(q/(label+'.stdout'));matched=actualMetric==goldBytes
  assert v['status']==('METRICS_PASS'if matched else'METRICS_REJECT')and raw(q/(label+'.stderr'))==(v['status']+'\n').encode()
  assert v['actualPath']==metric['path']and v['actualBytes']==len(actualMetric)and v['actualSHA256']==sha(actualMetric)and v['expectedPath']==expectedPath and v['expectedSHA256']==sha(goldBytes)and v['stableRegularFile']is True and v['stats']==value
 if kind=='normal':
  assert actualMetric==gold and len(actualMetric)==67575 and sha(actualMetric)=='09d1d2c794cd9893eae80ade652873caf4a94d588b4e4c19baeb2182b4bd03fa'
  root=Path(metric['oracle']).parent;receipt=obj(root/'GENERATION-RECEIPT.json');assert receipt['sampleCounts']=={k:len(rows)for k,rows in value.items()}=={'main':321,'aux':23,'flag':22}
  for name,rows in value.items():
   fields=[flatten(row['snapshot'])for row in rows];maxima={key:max(row[key]for row in fields)for key in fields[0]};assert maxima==receipt['perColumnCompleteStatePeaks'][name]['fieldMaxima']
   sites=collections.Counter(x['site']for x in rows);assert all(sites[k]==n for k,n in receipt['siteCounts'][name].items())
 else:
  transformed=copy.deepcopy(normal)
  for rows in transformed.values():
   for row in rows:
    row['snapshot']['metadata']['added'][2]+=1;row['snapshot']['metadata']['changed'][2]+=1
  assert value==transformed and actualMetric==raw(metric['counterOracle'])and len(actualMetric)==67581 and sha(actualMetric)=='82509ee7d2960ed7ef0cb196b720ebfcc76047695d95c0826b5940a76945790a'
 outputs[kind,role]=actualMetric
for kind in ['normal','fixture','counter']:assert outputs[kind,'js']==outputs[kind,'native']
normal=plans['normal','js'];counter=plans['counter','js'];normalStage=Path(normal['stage']);counterStage=Path(counter['stage'])
for name,h in counter['sourceInventory'].items():
 p=Path(name)
 if p.parent!=counterStage:continue
 original=normalStage/p.name;source=blob(original,normal['sourceInventory'][str(original)]).decode().replace('../private/','../../private/')
 if p.name=='metadata-report.bend':assert source.count('Nat.show(nonzero)')==1;source=source.replace('Nat.show(nonzero)','Nat.show(1n+nonzero)')
 assert blob(p,h).decode()==source,p
assert len(d['unexecutedDrafts'])==2
for draft in d['unexecutedDrafts']:
 q=Path(draft['directory']);assert draft['status']=='UNEXECUTED';assert not any(name==str(q/'receipt.json')for name,h in members)
 assert sha(raw(q/'plan.json'))==draft['planSHA256'];p=obj(q/'plan.json')
 for name,h in p['pins'].items():pin(name,h)
for row in members.values():
 if 'hashOnly'in row:assert row['actualPath']in tools
 if 'sourceEpoch'in row:assert row['gitCommit']=='8fb4e9efc3be174a848a8fc9594a14641eff4af4'and 'Historical unexecuted actual01'in row['sourceEpoch']
assert len(seen)==d['objects']==len(list((b/'objects').iterdir()));print('PASS',len(members),'members',len(seen),'objects',guards,'guards;2normal fullcanonical+366completedmetadata states,2fullaffinefixtures,2reachedreportercontrols; no aggregate/allocator claim; manifest',sha((b/'RETENTION.json').read_bytes()))
