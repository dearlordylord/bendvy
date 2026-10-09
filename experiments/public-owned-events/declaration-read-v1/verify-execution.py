"""No-child four complete ordinary declaration development observation joins."""
import hashlib,json
from pathlib import Path
import transport
HERE=Path(__file__).resolve().parent;E=HERE/'evidence'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
digests=json.loads((E/'prepared-plan-digests.json').read_text())
hashes={'generic':('8d7f588ae41e38f41593b60ac164af11ca2e15a060b077b50f665269c5243d3c','5fb9f70d1b9b04623e3e8d02a8737cd9ae13be481057700594932de289fabd45'),'registered':('e13246770caf111e88b4ac799dde38d4dc252138fc36427308dc79d8f16abd69','a3c252aa2776ddfa1aca5f103e29be787cb6e31a7fb83cb66cc33f11ae1d829e')}
for role in ('generic','registered'):
 oracle_raw=E/('executed-'+role+'-expected.stdout');oracle_json=E/('executed-'+role+'-expected.json')
 assert sha(oracle_raw)==hashes[role][0] and sha(oracle_json)==hashes[role][1]
 expected=json.loads(oracle_json.read_text());closures=[]
 for backend in ('js','native'):
  folder=E/(role+'-'+backend+'-1');pf=folder/'plan.json';plan=json.loads(pf.read_text());receipt=json.loads((folder/'receipt.json').read_text())
  assert sha(pf)==digests[role+'-'+backend] and receipt['preparedPlanSha256']==sha(pf)
  assert plan['role']==role and plan['native']==(backend=='native') and plan['oracleCommit']=='3f6a26c2'
  assert receipt['status']=='DEVELOPMENT_PASS' and receipt.get('guardFailures',[])==[] and 'error' not in receipt
  entry=Path(plan['commands'][0]['argv'][4]);transport.HERE=entry.parent if role=='generic' else entry.parent.parent
  observed=(folder/'raw/complete-run.stdout').read_bytes()
  assert observed==oracle_raw.read_bytes() and transport.parse(role,observed)==expected
  assert (transport.render(role,expected)+'\n').encode()==observed
  assert [r['capSeconds'] for r in receipt['commands']]==([30,5] if backend=='js' else [30,120,5])
  assert len(receipt['commands'])==len(plan['commands'])
  for row,command in zip(receipt['commands'],plan['commands']):
   assert row['exit']==0 and row['failure'] is None and all(row[k]==v for k,v in command.items())
   assert row['argv'][:3]==['/usr/bin/taskset','-c','5'] and (folder/'raw'/(row['label']+'.stderr')).read_bytes()==b''
  assert {p.name for p in (folder/'raw').iterdir()}==set(receipt['logs'])
  for name,digest in receipt['logs'].items():assert (folder/'raw'/name).is_file() and not (folder/'raw'/name).is_symlink() and sha(folder/'raw'/name)==digest
  assert plan['tools']['python'] in plan['inputs']
  for path,digest in plan['inputs'].items():
   suffix='/declaration-read-v1/'
   if suffix in path and path.endswith(('.bend','.py')):assert sha(HERE/path.split(suffix,1)[1])==digest
   if path.endswith('/registered-read-v1/transport.py'):assert sha(HERE.parent/'registered-read-v1/transport.py')==digest
  for suffix,source in [(role+'-expected.json',oracle_json),(role+'-expected.stdout',oracle_raw)]:assert [v for k,v in plan['inputs'].items() if k.endswith('/oracle-v1/'+suffix)]==[sha(source)]
  if backend=='native':assert receipt['commands'][-1]['argv'][-4:]==['--threads','1','--gpu','off']
  closures.append({k:v for k,v in plan['inputs'].items() if k.endswith('.bend')})
 assert closures[0]==closures[1]
print('PASS four exact admitted cohorts, full generic/registered JS=Native oracle/source/plan/raw joins; no child')
