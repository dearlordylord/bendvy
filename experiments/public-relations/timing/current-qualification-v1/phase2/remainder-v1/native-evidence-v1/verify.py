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
 index=json.loads((HERE/'index.json').read_text());assert sha((HERE/'objects.tar.gz').read_bytes())==index['archiveSHA256'];objects={}
 with tarfile.open(HERE/'objects.tar.gz','r:gz') as archive:
  for member in archive:
   assert member.isfile() and member.name in index['objects'] and member.name not in objects;data=archive.extractfile(member).read();assert sha(data)==member.name and len(data)==index['objects'][member.name];assert not data.startswith(b'\x7fELF');objects[member.name]=data
 assert set(objects)==set(index['objects'])==set(index['files'].values())
 raw=lambda key:objects[index['files'][key]]
 read=lambda key:json.loads(raw(key))
 plan=read('native/plan.json');receipt=read('native/receipt.json');prepare=read('native/prepare-receipt.json');assert receipt['status']=='THREE_RUNTIME_INPUT_COMPLETE30_NATIVE_CONSUMERS_PASS_NO_TIMING_VERDICT' and receipt['planSHA256']==sha(raw('native/plan.json'))
 assert len(plan['commands'])==5 and [command['seconds'] for command in plan['commands']]==[30,120,5,5,5];assert all(command['exit']==0 and command['failure'] is None for command in receipt['commands']);assert receipt['probeCommandsExecuted']==55 and prepare['probeCommandsExecuted']==5 and prepare['status']=='OWNED_TOOL_PREPARATION_PASS'
 for name,digest in receipt['logs'].items():assert sha(raw('native/'+name))==digest
 expected={}
 for case in read('oracle/manifest.json')['cases']:
  assert sha(raw('oracle/'+case['expected']))==case['sha256'];value=read('oracle/'+case['expected']);assert sum(len(root['records']) for root in value['roots'])==30;expected[tuple(case['input'])]=value
 binary=plan['commands'][1]['argv'][-1];assert binary in receipt['generated'];assert len(receipt['generated'])==2
 for command in plan['commands'][2:]:
  assert command['argv'][3]==binary and command['argv'][4:8]==['--threads','1','--gpu','off'];value=expected[tuple(command['argv'][8:])];name=command['label'];assert read('native/'+name+'.stdout')==value;assert [json.loads(line) for line in raw('native/'+name+'.stderr').splitlines()]==[dict(boundary='begin'),dict(boundary='complete-trace-forced',**summary(value))]
 for group,data,count in [('prepare-probes',prepare,5),('execution-probes',receipt,55)]:
  for source,digest in data['probePins'].items():assert sha(raw('native/'+group+'/'+Path(source).name))==digest
  keys=[key for key in index['files'] if key.startswith('native/'+group+'/') and key.endswith('.json')];assert len(keys)==count
  for key in keys:
   probe=read(key);assert probe['seconds']==5 and probe['exit']==0 and probe['failure'] is None
 join=plan['historicalJSsourceVsCurrentNativeDeliveryJoin'];assert join['removedBytes']=='eight LF bytes at EOF only' and join['qualifiedBytes']-join['liveDeliveryBytes']==8
 print('PASS: three full30 Native consumers, one binary/runtimeinputs,5subjects+60ownedprobes; historicalJS EOFjoin explicit; no child/backend/timing replay')
if __name__=='__main__':main()
