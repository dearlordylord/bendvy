"""No-child independent complete-oracle and immutable raw evidence reconciliation."""
from pathlib import Path
import hashlib,json,tarfile
HERE=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def summary(trace):
 pending=[trace];nodes=characters=total=0
 while pending:
  value=pending.pop();nodes+=1
  if value is None:total+=1
  elif isinstance(value,bool):total+=5 if value else 4
  elif isinstance(value,int):total+=2+value
  elif isinstance(value,str):total+=3+sum(ord(c) for c in value);characters+=len(value)
  elif isinstance(value,list):total+=6;pending.extend(reversed(value))
  else:
   total+=7
   for key,item in reversed(list(value.items())):pending.extend([item,key])
 return dict(nodes=nodes&0xffffffff,characters=characters&0xffffffff,sum=total&0xffffffff)
def main():
 index=json.loads((HERE/'index.json').read_text());archive=(HERE/'objects.tar.gz').read_bytes();assert sha(archive)==index['archiveSHA256'];objects={}
 with tarfile.open(HERE/'objects.tar.gz','r:gz') as t:
  for member in t:
   assert member.isfile() and member.name in index['objects'] and member.name not in objects;data=t.extractfile(member).read();assert sha(data)==member.name and len(data)==index['objects'][member.name];objects[member.name]=data
 assert set(objects)==set(index['objects']);assert set(index['files'].values())==set(objects)
 raw=lambda key:objects[index['files'][key]]
 read=lambda key:json.loads(raw(key))
 expected=read('oracle/expected.json');assert len(expected)==2 and [len(x['records']) for x in expected]==[15,15];controls=summary(expected);mutated=json.loads(json.dumps(expected));mutated[-1]['records'][-1]['systemResult']=1
 normal=[dict(boundary='begin'),dict(boundary='complete-trace-forced',**controls)];last=[dict(boundary='begin'),dict(boundary='complete-trace-forced',**summary(mutated))];moved=[dict(boundary='begin'),dict(boundary='complete-trace-forced',nodes=0,characters=0,sum=0),normal[-1]]
 assert controls==dict(nodes=17759,characters=37554,sum=4812892);assert summary(mutated)['sum']==4812894
 statuses={'normal':'COMPLETE_PUBLIC_TRACE_ANCHOR_PASS_NOT_FAIR_TIMING_QUALIFIED','controls':'BOTH_JS_FORCING_BOUNDARY_FALSIFIERS_PASS_NO_TIMING_VERDICT','native':'COMPLETE30_NATIVE_TRACE_AND_BOTH_FORCING_FALSIFIERS_PASS_NO_TIMING_VERDICT'}
 for name,status in statuses.items():
  r=read(name+'/receipt.json');assert r['status']==status and r['planSHA256']==sha(raw(name+'/plan.json'));assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
  for n,h in r['logs'].items():assert sha(raw(name+'/'+n))==h
  plan=read(name+'/plan.json')
  if name=='native':
   assert len(r['commands'])==9 and r['probeCommandsExecuted']==95 and [c['seconds'] for c in plan['commands']]==[30,120,5]*3
   assert plan['cheapReceiptSHA256']==sha(raw('normal/receipt.json')) and plan['controlsReceiptSHA256']==sha(raw('controls/receipt.json'))
   for original,h in r['probePins'].items():assert sha(raw('native/execution-probes/'+Path(original).name))==h
   prep=read('native/prepare-receipt.json');assert prep['status']=='OWNED_TOOL_PREPARATION_PASS' and prep['probeCommandsExecuted']==5
   for original,h in prep['probePins'].items():assert sha(raw('native/prepare-probes/'+Path(original).name))==h
   for group,count in [('prepare-probes',5),('execution-probes',95)]:
    keys=[k for k in index['files'] if k.startswith('native/'+group+'/') and k.endswith('.json')];assert len(keys)==count
    for key in keys:
     p=read(key);assert p['seconds']==5 and p['exit']==0 and p['failure'] is None
  else:
   cmds=plan['commands'];limits=[c[2] if isinstance(c,list) else c['seconds'] for c in cmds];assert limits==([5,5,30,5] if name=='normal' else [5,30,5,30,5])
 cases=[('normal','ts',expected,normal),('normal','js',expected,normal),('controls','last-leaf-run',mutated,last),('controls','moved-walk-run',expected,moved),('native','normal-run-native',expected,normal),('native','last-leaf-run-native',mutated,last),('native','moved-walk-run-native',expected,moved)]
 for group,label,oracle,boundaries in cases:
  assert read(group+'/'+label+'.stdout')==oracle;assert [json.loads(line) for line in raw(group+'/'+label+'.stderr').splitlines()]==boundaries
 assert b'ALL PROOFS CHECK' in raw('normal/check.stdout') and b'ALL PROOFS CHECK' in raw('controls/mutant-pure-check.stdout')
 print('PASS: seven full30 consumers, normal/last-leaf/moved-walk boundaries,18subjects+100ownedprobes; no timing claim')
if __name__=='__main__':main()
