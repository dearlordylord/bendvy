from pathlib import Path
import json,gzip,hashlib
h=Path(__file__).resolve().parent;m=json.loads((h/'FILES.json').read_bytes());files={};ids={}
for row in m['members']:
 raw=gzip.decompress((h/row['object']).read_bytes());assert hashlib.sha256(raw).hexdigest()==row['sha256'] and len(raw)==row['bytes'];assert row['path']not in files;files[row['path']]=raw;ids[row['path']]=row['sha256']
for row in m['externalIdentityOnly']:assert row['path']not in ids;ids[row['path']]=row['sha256']
assert ids[m['index']]==m['indexSHA256'];index=json.loads(files[m['index']]);assert len(index['plans'])==4
summary=json.loads((h/'SUMMARY.json').read_bytes());total=0;native=None
for row,stored in zip(index['plans'],summary):
 plan=json.loads(files[row['plan']]);receipt=json.loads(files[str(Path(row['plan']).parent/'receipt.json')]);assert ids[row['plan']]==row['sha256']==receipt['planSHA256'];assert all(ids[k]==v for k,v in plan['pins'].items())
 for root,inv in plan['resourceRoots'].items():assert all(ids[str(Path(root)/k)]==v for k,v in inv.items())
 assert len(plan['sourceInventory'])==46;assert all(ids[str(Path(plan['stage'])/k)]==v for k,v in plan['sourceInventory'].items())
 for c,q in zip(receipt['commands'],plan['commands']):
  assert c['argv']==q['argv']and c['capSeconds']==q['capSeconds']
  for k in ['stdout','stderr']:
   raw=c[k];assert raw['published'] and ids[raw['path']]==raw['sha256']and len(files[raw['path']])==raw['bytes']
  if c['label']=='consumer':
   expected=gzip.decompress(files[plan['oracle']]);assert len(expected)==plan['oracleBytes'] and hashlib.sha256(expected).hexdigest()==plan['oracleSHA256'];assert files[c['stdout']['path']]==expected and files[c['stderr']['path']]==b''
   if row['name']!='normal':assert receipt['wholeBaselineRejected']and files[c['stdout']['path']]!=gzip.decompress(files[plan['baselineOracle']])
 for guard in receipt['guards']:
  assert ids[guard['path']]==guard['sha256'];g=json.loads(files[guard['path']]);assert g['unchanged']and all(ids[k]==v for k,v in g['actualPins'].items())
 assert ids[plan['generated']]==receipt['emitArtifactSHA256']
 if row['role']=='js':assert receipt['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'and all(c['exit']==0 and c['failure']is None for c in receipt['commands'])and len(receipt['commands'])==2
 else:native=receipt
 assert stored=={'name':row['name'],'role':row['role'],'planSHA256':row['sha256'],'status':receipt['status'],'error':receipt.get('error'),'commands':len(receipt['commands']),'guards':len(receipt['guards'])}
 total+=len(receipt['commands'])
assert native is not None
if native['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS':assert len(native['commands'])==3 and all(c['exit']==0 and c['failure']is None for c in native['commands'])
else:assert native['status']=='INCOMPLETE'and native['error'] and any(c['exit']!=0 or c['failure']for c in native['commands'])
print('PASS',len(files),'lossless members/three complete JS whole-output gates/both reached baseline refusals/Native terminal',native['status'],'commands',total,'; no replay/performance claim')
