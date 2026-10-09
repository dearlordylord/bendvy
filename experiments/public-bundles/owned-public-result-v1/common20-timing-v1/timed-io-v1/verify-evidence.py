"""No-child complete IO timer archive, source, receipt and public-join verifier."""
import gzip,hashlib,json,types
from pathlib import Path
HERE=Path(__file__).resolve().parent
index=json.loads((HERE/'BACKEND-PREPARED-v1.json').read_bytes())
outputs={}
for item in index['plans']:
 label=item['label'];out=HERE/'evidence-v1'/label
 manifest=json.loads((out/'MANIFEST.json').read_bytes());members={m['original']:m for m in manifest['members']}
 assert len(members)==len(manifest['members'])
 assert {p.name for p in out.iterdir()}=={'MANIFEST.json'}|{m['archive'] for m in members.values()}
 def raw(name):return gzip.decompress((out/members[name]['archive']).read_bytes())
 for name,m in members.items():
  compressed=(out/m['archive']).read_bytes();data=raw(name)
  assert hashlib.sha256(compressed).hexdigest()==m['gzipSHA256']
  assert len(data)==m['bytes'] and hashlib.sha256(data).hexdigest()==m['sha256']
 plan=json.loads(raw('plan.json'));receipt=json.loads(raw('receipt.json'))
 assert members['plan.json']['sha256']==item['sha256']==receipt['planSHA256']==manifest['executedPlanSHA256']
 assert receipt['status']=='DEVELOPMENT_PASS' and len(receipt['commands'])==len(plan['commands'])
 control=label.startswith('earlyEnd')
 for actual,expected in zip(receipt['commands'],plan['commands']):
  assert all(actual[k]==v for k,v in expected.items()) and actual['failure'] is None
  assert actual['exit'] in (1,2) if control and actual['label']=='consumer' else actual['exit']==0
  for field in ['stdout','stderr']:
   ref=actual[field];member=members[Path(ref['path']).name]
   assert member['sha256']==ref['sha256'] and member['bytes']==ref['bytes']
  if actual['label']!='consumer':assert actual['stderr']['bytes']==0
 assert len(receipt['guards'])==1+3*len(plan['commands'])
 for row in receipt['guards']:
  name=Path(row['path']).name;assert members[name]['sha256']==row['sha256']
  guard=json.loads(raw(name));assert guard['unchanged'] and all(guard['actualPins'][k]==v for k,v in plan['pins'].items())
  if 'resourceInventory' in plan:assert guard['actualResources']==plan['resourceInventory']
  for name,m in members.items():
   original=str(Path(item['plan']).parent/name)
   if original in guard['actualPins']:assert guard['actualPins'][original]==m['sha256']
 expected_file=Path(plan['oracle']);expected_bytes=expected_file.read_bytes()
 assert hashlib.sha256(expected_bytes).hexdigest()==plan['expectedSHA256']==receipt['wholeOracleSHA256']
 helper=Path(item['helper']);transport=helper.parent/('ts-transport-v1' if label=='positiveTS' else 'transport-v1')/'transport.py'
 source=transport.read_bytes();assert hashlib.sha256(source).hexdigest()==plan['pins'][str(transport)]
 module=types.ModuleType('transport');module.__file__=str(transport);exec(compile(source,str(transport),'exec'),module.__dict__)
 result={'stdout':raw('consumer.stdout'),'stderr':raw('consumer.stderr'),'exit':receipt['commands'][-1]['exit'],'failure':None}
 assert module.validate_result(result,json.loads(expected_bytes),control)==receipt['timerQualification']
 outputs[label]=result['stdout'].decode('utf8')
 print(label,'complete archive/raw/guards/full literal/timer protocol PASS')
join_path=HERE.parent/'shared-public-join.py';join_bytes=join_path.read_bytes();join_sha=hashlib.sha256(join_bytes).hexdigest()
for label in ['positiveJS','positiveNative','positiveTS']:
 plan=json.loads((HERE/(label+'-prepared-plan-v1.json')).read_bytes());assert plan['pins'][str(join_path)]==join_sha
module=types.ModuleType('join');module.__file__=str(join_path);exec(compile(join_bytes,str(join_path),'exec'),module.__dict__)
joined={'sourceSHA256':join_sha,'JS':module.compare(outputs['positiveJS'],outputs['positiveTS']),'Native':module.compare(outputs['positiveNative'],outputs['positiveTS'])}
assert joined==json.loads((HERE/'ACTUAL-PUBLIC-JOIN.json').read_bytes())
print('Both full literals and all twenty public rows PASS; no comparative timing credit')
