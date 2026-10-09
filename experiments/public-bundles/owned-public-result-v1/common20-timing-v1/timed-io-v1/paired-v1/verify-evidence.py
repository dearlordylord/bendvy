"""No-child full86 IO paired raw/guard/metric/order/summary reconciliation."""
import gzip,hashlib,json,types
from pathlib import Path
HERE=Path(__file__).resolve().parent
prepared=json.loads((HERE/'PREPARED.json').read_bytes())
out=HERE/'evidence-v1';manifest=json.loads((out/'MANIFEST.json').read_bytes())
members={m['original']:m for m in manifest['members']}
assert len(members)==len(manifest['members'])==349
assert {p.name for p in out.iterdir()}=={'MANIFEST.json'}|{m['archive']for m in members.values()}
def raw(name):return gzip.decompress((out/members[name]['archive']).read_bytes())
for name,item in members.items():
 data=raw(name);assert len(data)==item['bytes'] and hashlib.sha256(data).hexdigest()==item['sha256']
 assert hashlib.sha256((out/item['archive']).read_bytes()).hexdigest()==item['gzipSHA256']
plan=json.loads(raw('plan.json'));receipt=json.loads(raw('receipt.json'))
assert prepared['sha256']==manifest['executedPlanSHA256']==members['plan.json']['sha256']==receipt['planSHA256']
assert receipt['status']=='COMPLETE_FEATURE_OBSERVATIONS'
assert len(plan['commands'])==len(receipt['commands'])==len(receipt['observations'])==len(receipt['samplingRaw'])==86
assert len(receipt['guards'])==175
for ref in receipt['guards']:
 name=Path(ref['path']).name;assert members[name]['sha256']==ref['sha256'];guard=json.loads(raw(name))
 assert guard['unchanged'] and guard['actualResources']==plan['resourceInventory']
 assert all(guard['actualPins'][name]==value for name,value in plan['pins'].items())
 for name,item in members.items():
  original=str(Path(prepared['plan']).parent/name)
  if original in guard['actualPins']:assert guard['actualPins'][original]==item['sha256']
def load_source(name,path):
 path=Path(path);source=path.read_bytes();assert hashlib.sha256(source).hexdigest()==plan['pins'][str(path)]
 module=types.ModuleType(name);module.__file__=str(path);exec(compile(source,str(path),'exec'),module.__dict__);return module
transports={role:load_source('transport_'+role,info['transport'])for role,info in plan['roles'].items()}
sampling=load_source('sampling_io',plan['samplingHelper'])
contract=json.loads(Path(next(name for name in plan['pins']if name.endswith('/benchmarks/contract.json'))).read_bytes())
assert sampling.schedule(contract,[1])==plan['samplingRows']
outputs={}
for spec,command,observation,sample in zip(plan['commands'],receipt['commands'],receipt['observations'],receipt['samplingRaw']):
 assert all(command[k]==value for k,value in spec.items()) and command['exit']==0 and command['failure']is None
 assert command['label']==observation['label']==sample['label']
 assert observation['samplingRow']==next(row for row in plan['samplingRows']if row['label']==spec['label'])
 assert observation['role']==spec['role']
 for field in ['stdout','stderr']:
  ref=command[field];name=Path(ref['path']).name;assert members[name]['sha256']==ref['sha256'] and members[name]['bytes']==ref['bytes']
 stdout=raw(Path(command['stdout']['path']).name);stderr=raw(Path(command['stderr']['path']).name)
 info=plan['roles'][spec['role']];expected=Path(info['oracle']).read_bytes();assert hashlib.sha256(expected).hexdigest()==info['expectedSHA256']
 result={'exit':0,'failure':None,'stdout':stdout,'stderr':stderr}
 qualified=transports[spec['role']].validate_result(result,json.loads(expected),False)
 assert qualified['timer']==observation['region'] and stderr.hex()==sample['stderr']['rawHex']
 assert all(key in observation['before']and key in observation['after']for key in ['loadavg','cpuStat'])
 if spec['role']in outputs:assert outputs[spec['role']]==stdout.decode('utf8')
 outputs[spec['role']]=stdout.decode('utf8')
assert receipt['summary']==sampling.summarize(plan['samplingRows'],receipt['samplingRaw'])
assert len(receipt['summary']['summary'])==2 and all(len(s['allPairs'])==20 for s in receipt['summary']['summary'])
join_path=HERE.parents[1]/'shared-public-join.py';join_bytes=join_path.read_bytes()
retained=[value for name,value in plan['pins'].items()if name.endswith('/common20-timing-v1/shared-public-join.py')]
assert len(retained)==1 and hashlib.sha256(join_bytes).hexdigest()==retained[0]
join=types.ModuleType('join');join.__file__=str(join_path);exec(compile(join_bytes,str(join_path),'exec'),join.__dict__)
actual_join={'sourceSHA256':retained[0],'JS':join.compare(outputs['JS'],outputs['TS']),'Native':join.compare(outputs['Native'],outputs['TS'])}
assert actual_join==json.loads((HERE/'ACTUAL-PUBLIC-JOIN.json').read_bytes())
print('All349 members/86 complete IO samples/175 guards/20 balanced pairs each/full20 public joins/descriptive summaries PASS')
print('Internal reservation retained; external contention possible; no quiet guarantee/corecause/fullparity/duplicatepolicy acceptance')
