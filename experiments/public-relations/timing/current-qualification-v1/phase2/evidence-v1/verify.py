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
 manifest=read('oracle/manifest.json');expected={}
 for case in manifest['cases']:
  assert sha(raw('oracle/'+case['expected']))==case['sha256'];value=read('oracle/'+case['expected']);assert sum(len(root['records']) for root in value['roots'])==30;expected[tuple(case['input'])]=value
 for number in range(1,7):
  receipt=read(f'diagnostics/{number}/receipt.json');assert receipt['returncode']==1;assert sha(raw(f'diagnostics/{number}/stdout.raw'))==receipt['stdoutSha256'];assert sha(raw(f'diagnostics/{number}/stderr.raw'))==receipt['stderrSha256']
  if number>=4:
   for digest in receipt['sourceHashes'].values():assert sha(raw(f'diagnostics/{number}/source-bytes/'+digest))==digest
 assert b'9 defs rely on unsafe or foreign code' in raw('diagnostics/6/stderr.raw')
 assert read('ambient-guard/preflight-failure.json')['subjectsExecuted']==0
 statuses={'cheap':'DEVELOPMENT_COMPLETE30_CONSUMERS_PASS_NOT_DELIVERY','js':'THREE_RUNTIME_INPUT_COMPLETE30_JS_CONSUMERS_PASS_NO_TIMING_VERDICT'}
 for name,status in statuses.items():
  receipt=read(name+'/receipt.json');assert receipt['status']==status and receipt['planSHA256']==sha(raw(name+'/plan.json'));assert all(command['exit']==0 and command['failure'] is None for command in receipt['commands'])
  for filename,digest in receipt['logs'].items():assert sha(raw(name+'/'+filename))==digest
 cheap=read('cheap/plan.json');assert [command[2] for command in cheap['commands']]==[5,5]
 controls=lambda value:[dict(boundary='begin'),dict(boundary='complete-trace-forced',**summary(value))]
 original=expected[('population','64','0','0')]
 for name in ['ts','bend-io']:
  assert read('cheap/'+name+'.stdout')==original;assert [json.loads(line) for line in raw('cheap/'+name+'.stderr').splitlines()]==controls(original)
 plan=read('js/plan.json');receipt=read('js/receipt.json');assert len(plan['commands'])==4 and [command['seconds'] for command in plan['commands']]==[30,5,5,5];assert receipt['probeCommandsExecuted']==36 and len(receipt['generated'])==1
 generated=next(iter(receipt['generated']));assert all(command['argv'][4]==generated for command in plan['commands'][1:])
 for command in plan['commands'][1:]:
  inputs=tuple(command['argv'][5:]);value=expected[inputs];name=command['label'];assert read('js/'+name+'.stdout')==value;assert [json.loads(line) for line in raw('js/'+name+'.stderr').splitlines()]==controls(value)
 assert plan['cheapReceiptSHA256']==sha(raw('cheap/receipt.json'))
 prepare=read('js/prepare-receipt.json');assert prepare['status']=='OWNED_TOOL_PREPARATION_PASS' and prepare['probeCommandsExecuted']==4
 for group,data,count in [('prepare-probes',prepare,4),('execution-probes',receipt,36)]:
  for source,digest in data['probePins'].items():assert sha(raw('js/'+group+'/'+Path(source).name))==digest
  keys=[key for key in index['files'] if key.startswith('js/'+group+'/') and key.endswith('.json')];assert len(keys)==count
  for key in keys:
   probe=read(key);assert probe['seconds']==5 and probe['exit']==0 and probe['failure'] is None
 print('PASS: five complete30 consumers; one same-artifact three-input JS cohort;6subjects+40ownedprobes;6source diagnostics+zero-child guard failure; evidence only')
if __name__=='__main__':main()
