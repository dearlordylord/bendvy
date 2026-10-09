"""No-child retained normal feasibility audit."""
from pathlib import Path
import gzip,hashlib,json
HERE=Path(__file__).resolve().parent
manifest=json.loads((HERE/'FILES.json').read_text());files={};identities={}
for row in manifest['members']:
 raw=gzip.decompress((HERE/row['object']).read_bytes())
 assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256']
 assert row['path'] not in files
 files[row['path']]=raw;identities[row['path']]=row['sha256']
for row in manifest['externalIdentityOnly']:
 assert row['path'] not in identities
 identities[row['path']]=row['sha256']
assert len(files)==97
for cohort in manifest['cohorts']:
 root=cohort['root']+'/'
 plan_raw=files[root+'plan.json'];assert hashlib.sha256(plan_raw).hexdigest()==cohort['planSHA256']
 plan=json.loads(plan_raw);receipt=json.loads(files[root+'receipt.json'])
 assert receipt['planSHA256']==cohort['planSHA256'] and receipt['status']==cohort['status']
 assert len(plan['pins'])==62 and len(plan['sourceInventory'])==len(plan['importClosure'])==46
 for name,digest in plan['pins'].items():assert identities[name]==digest
 for relative,digest in plan['sourceInventory'].items():assert identities[plan['stage']+'/'+relative]==digest
 expected=gzip.decompress(files[plan['oracle']]);assert len(expected)==plan['oracleBytes']==5077477
 assert hashlib.sha256(expected).hexdigest()==plan['oracleSHA256']=='810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2'
 for row,planned in zip(receipt['commands'],plan['commands']):
  assert row['label']==planned['label'] and row['argv']==planned['argv'] and row['capSeconds']==planned['capSeconds']
  for key in ('stdout','stderr'):
   rawrow=row[key];assert rawrow['published'] is True
   assert identities[rawrow['path']]==rawrow['sha256'] and len(files[rawrow['path']])==rawrow['bytes']
 for guardrow in receipt['guards']:
  assert identities[guardrow['path']]==guardrow['sha256']
  guard=json.loads(files[guardrow['path']]);assert guard['unchanged'] is True
  assert set(plan['pins'])<=set(guard['actualPins'])
  for name,digest in guard['actualPins'].items():assert identities[name]==digest
 if cohort['role']=='js':
  assert len(receipt['commands'])==2 and len(receipt['guards'])==7
  assert all(row['exit']==0 and row['failure'] is None for row in receipt['commands'])
  consumer=receipt['commands'][-1]
  assert files[consumer['stdout']['path']]==expected and files[consumer['stderr']['path']]==b''
  assert identities[plan['generated']]==receipt['emitArtifactSHA256']
  assert receipt['wholeOracleSHA256']==plan['oracleSHA256']
 else:
  assert len(receipt['commands'])==1 and len(receipt['guards'])==4
  assert receipt['status']=='INCOMPLETE' and 'Owned child failed: emit' in receipt['error']
  row=receipt['commands'][0];assert row['exit'] is None and row['failure']=='child deadline'
  assert files[row['stdout']['path']]==files[row['stderr']['path']]==b''
  assert plan['generated'] not in files and plan['native'] not in files
join=json.loads((HERE/'CURRENT-CORE-JOIN.json').read_text())
assert len(join['modules'])==19
for row in join['modules']:
 current=files[row['currentRootPath']];assert hashlib.sha256(current).hexdigest()==row['currentRootSHA256']
 stage_rows=[raw for name,raw in files.items() if name.endswith('/stage/core-v1/src/ecs/'+row['module'])]
 assert len(stage_rows)==1 and hashlib.sha256(stage_rows[0]).hexdigest()==row['stageSHA256']
 if row['matches']:assert current==stage_rows[0]
 else:assert row['module']=='owner-handoff.bend' and current==stage_rows[0]+b'\n\n\n'
print('PASS97 lossless members/2exact plans/11guards/wholeJSoracle/Nativeemitdeadline/19postrun core joins; no replay')
