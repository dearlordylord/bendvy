"""No-child lossless whole four-cohort source/plan/oracle/raw reconciliation."""
import gzip,hashlib,json,types
from pathlib import Path
HERE=Path(__file__).resolve().parent
manifest=json.loads((HERE/'MANIFEST.json').read_bytes());data={};sha=lambda b:hashlib.sha256(b).hexdigest()
for row in manifest['members']:
 compressed=(HERE/row['archive']).read_bytes();raw=gzip.decompress(compressed);assert sha(compressed)==row['gzipSHA256']and sha(raw)==row['sha256']and len(raw)==row['bytes'];assert row['original']not in data;data[row['original']]=raw
assert {str(p.relative_to(HERE))for p in (HERE/'objects').iterdir()}=={row['archive']for row in manifest['members']}
def load(name,path):
 p=Path(path);m=types.ModuleType(name);m.__file__=str(p);m.__dict__['VERIFIED_SOURCES']={k:v for k,v in data.items()if k.endswith('.py')};exec(compile(data[str(p)],str(p),'exec'),m.__dict__);return m
for cohort in manifest['plans']:
 pf=Path(cohort['plan']);plan=json.loads(data[str(pf)]);receipt=json.loads(data[str(pf.parent/'receipt.json')]);assert sha(data[str(pf)])==cohort['sha256']==receipt['preparedPlanSha256'];assert receipt['status']=='DEVELOPMENT_PASS'and not receipt.get('guardFailures')and not receipt.get('error')
 assert plan['native']==cohort['native']and plan['role']==cohort['role'];assert len(receipt['commands'])==len(plan['commands'])
 for name,digest in plan['inputs'].items():
  p=Path(name)
  if isinstance(digest,str):
   assert p.is_file()and not p.is_symlink()and sha(p.read_bytes())==digest
   if name in data:assert sha(data[name])==digest
  else:assert {str(q.relative_to(p)):sha(q.read_bytes())for q in sorted(p.rglob('*'))if q.is_file()}==digest
 for command,row in zip(plan['commands'],receipt['commands']):
  assert all(row[k]==v for k,v in command.items())and row['exit']==0 and row['failure']is None;assert row['argv'][:3]==['/usr/bin/taskset','-c','5']
  assert data[str(pf.parent/'raw'/(row['label']+'.stderr'))]==b''
 for name,digest in receipt['logs'].items():assert sha(data[str(pf.parent/'raw'/name)])==digest
 for name,digest in receipt['generated'].items():assert sha(data[name])==digest
 binding_name=next(n for n in plan['inputs']if n.endswith(cohort['role']+'-binding.json'));binding=json.loads(data[binding_name]);assert sha(data[binding_name])==plan['assemblyBindingSha256'];transport=load('actual_transport',binding['transport']['path']);expected=json.loads(data[binding['oracles'][1]['path']]);observed=data[str(pf.parent/'raw/complete-run.stdout')]
 assert observed==data[binding['oracles'][0]['path']];assert transport.parse(cohort['role'],observed)==expected;assert(transport.render(cohort['role'],expected)+'\n').encode()==observed
 assert [row['capSeconds']for row in receipt['commands']]==([30,120,5]if cohort['native']else[30,5])
 if cohort['native']:assert receipt['commands'][-1]['argv'][-4:]==['--threads','1','--gpu','off']
print('PASS98 lossless members/four exact current cohorts/complete832+37318 raw+typed observations; no child')
