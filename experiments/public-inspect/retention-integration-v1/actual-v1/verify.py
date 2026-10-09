"""Existing lossless current-cohort reconciliation pattern; no backend replay."""
import gzip,hashlib,json,types
from pathlib import Path
HERE=Path(__file__).resolve().parent
manifest=json.loads((HERE/'MANIFEST.json').read_bytes());data={};sha=lambda b:hashlib.sha256(b).hexdigest()
for row in manifest['members']:
 compressed=(HERE/row['archive']).read_bytes();raw=gzip.decompress(compressed);assert sha(compressed)==row['gzipSHA256']and sha(raw)==row['sha256']and len(raw)==row['bytes'];assert row['original']not in data;data[row['original']]=raw
assert {str(p.relative_to(HERE))for p in(HERE/'objects').iterdir()}=={r['archive']for r in manifest['members']}
def load(name,path):
 p=Path(path);m=types.ModuleType(name);m.__file__=str(p);m.__dict__['VERIFIED_SOURCES']={k:v for k,v in data.items()if k.endswith('.py')};exec(compile(data[str(p)],str(p),'exec'),m.__dict__);return m
index=json.loads(data[manifest['index']]);assert index['plans']==manifest['plans']and len(index['plans'])==4
summary=[];normal_model=None
for cohort in index['plans']:
 pf=Path(cohort['plan']);plan=json.loads(data[str(pf)]);receipt=json.loads(data[str(pf.parent/'receipt.json')]);assert sha(data[str(pf)])==cohort['planSha256']==receipt['preparedPlanSha256'];assert receipt['status']=='DEVELOPMENT_PASS'and not receipt.get('guardFailures')and not receipt.get('error')
 assert plan['native']==cohort['native']and plan['role']=='generic';assert len(receipt['commands'])==len(plan['commands'])
 for name,digest in plan['inputs'].items():
  p=Path(name)
  if isinstance(digest,str):
   assert p.is_file()and not p.is_symlink()and sha(p.read_bytes())==digest
   if name in data:assert sha(data[name])==digest
   else:assert manifest['externalIdentityOnly'][name]==digest
  else:assert{str(q.relative_to(p)):sha(q.read_bytes())for q in sorted(p.rglob('*'))if q.is_file()}==digest
 for command,row in zip(plan['commands'],receipt['commands']):
  assert all(row[k]==v for k,v in command.items())and row['exit']==0 and row['failure']is None;assert row['argv'][:3]==['/usr/bin/taskset','-c','5']
  assert data[str(pf.parent/'raw'/(row['label']+'.stderr'))]==b''
 for name,digest in receipt['logs'].items():assert sha(data[str(pf.parent/'raw'/name)])==digest
 for name,digest in receipt['generated'].items():assert sha(data[name])==digest
 binding=json.loads(data[cohort['binding']]);assert sha(data[cohort['binding']])==cohort['bindingSha256']==plan['assemblyBindingSha256']
 assert all(sha(data[n])==v for n,v in binding['sourcePins'].items())
 transport=load('actual_transport',binding['transport']['path']);expected=json.loads(data[binding['oracles'][1]['path']]);observed=data[str(pf.parent/'raw/complete-run.stdout')]
 assert len(expected)==13 and observed==data[binding['oracles'][0]['path']];assert transport.parse('generic',observed)==expected;assert(transport.render('generic',expected)+'\n').encode()==observed
 assert [row['capSeconds']for row in receipt['commands']]==([30,120,5]if cohort['native']else[30,5])
 assert plan['tools']['bend']=='/home/node/.bend/bin/bend-2.0.35'
 if cohort['native']:assert receipt['commands'][-1]['argv'][-4:]==['--threads','1','--gpu','off']and '-O3'in plan['commands'][1]['argv']
 if cohort['name']=='normal':
  if normal_model is None:normal_model=expected
  else:assert expected==normal_model
 else:
  assert expected!=normal_model and transport.parse('generic',observed)!=normal_model
  baseline=(transport.render('generic',normal_model)+'\n').encode();assert observed!=baseline
 summary.append({'name':cohort['name'],'native':cohort['native'],'planSha256':cohort['planSha256'],'status':receipt['status'],'commands':len(receipt['commands']),'rawBytes':len(observed),'rawSha256':sha(observed),'wholeBaselineRejected':cohort['name']=='retainer'})
assert json.loads((HERE/'SUMMARY.json').read_bytes())==summary
print('PASS',len(data),'lossless members/four stock current cohorts/whole13 normal+counter raw+typed/whole baseline refusals/C+ELF+input joins; no replay/full54/performance claim')
