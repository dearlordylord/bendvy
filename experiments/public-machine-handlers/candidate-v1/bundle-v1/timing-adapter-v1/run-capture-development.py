"""Frozen single affected source5 development; no executable probes or runtime."""
import argparse,hashlib,json,time,fcntl,types
from pathlib import Path
H=Path(__file__).resolve().parent
NOTICE=H/'development-clock-source-1791442786008956162/clock.stderr'
NOTICE_SHA='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
N=types.ModuleType('native_inspection');N.__file__=str(H/'run-native-inspection.py')
text=Path(N.__file__).read_text();prefix=text.split('\nparser=argparse.ArgumentParser();')[0];assert len(prefix)<len(text)
exec(compile(prefix,N.__file__,'exec'),N.__dict__)
def prepare():
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  historical=H/'native-clock-inspection-1791444817897881996/plan.json';old=json.loads(historical.read_text())
  envpath=Path(old['privateEnvironment']);assert N.sha(envpath)==old['environmentSHA256'];env=json.loads(envpath.read_text())
  source=H/'capture-alignment-source-v1/correctness-main.bend';files=set();N.closure(source,files)
  assert N.sha(NOTICE)==NOTICE_SHA;files.add(NOTICE)
  files.update(map(Path,old['tools']['pins']));files.update([historical,Path(__file__),Path(N.__file__),N.T.IMPLEMENTATION,N.BOUNDARY,N.ROOT/'scripts/receipt-logs.py',envpath])
  files.update(p for p in (H/'capture-alignment-source-v1').iterdir() if p.is_file())
  out=H/('development-aligned-source-'+str(time.time_ns()));out.mkdir();archive=out/'source';archive.mkdir()
  sources={str(p):N.sha(p) for p in files if p.suffix=='.bend'}
  for index,p in enumerate(sorted(Path(p) for p in sources)):(archive/(str(index)+'.bend')).write_bytes(p.read_bytes())
  plan={'pins':{str(p):N.sha(p) for p in sorted(files)},'source':sources,'environment':str(envpath),'environmentSHA256':N.sha(envpath),'tools':old['tools'],'configurationStates':N.current_configs(out,H/'stage',old['tools'],env),'command':{'argv':['/usr/bin/taskset','-c','8','/home/node/.bend/bin/bend',str(source),'--check-only'],'seconds':5},'scope':'One affected source5 development typing only; zero probes/runtime/timing/proof/finalresolver credit.'}
  (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json');print(N.sha(out/'plan.json'))
def run(planpath,admittedSHA):
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  planpath=Path(planpath).resolve();p=json.loads(planpath.read_text());out=planpath.parent;planSHA=N.sha(planpath)
  assert not (out/'receipt.json').exists();env=json.loads(Path(p['environment']).read_text())
  inputs=None;logs=N.L.CommandLogs(out,['aligned-source'])
  def guard():
   assert N.sha(planpath)==admittedSHA==planSHA and N.sha(NOTICE)==NOTICE_SHA
   assert all(N.sha(name)==digest for name,digest in p['pins'].items())
   if inputs is not None:inputs.guard()
   assert N.sha(p['environment'])==p['environmentSHA256'];assert N.current_configs(out,H/'stage',p['tools'],env)==p['configurationStates']
  receipt={'planSHA256':planSHA,'scope':p['scope'],'commands':[]}
  with N.E.ReceiptBoundary(receipt,out/'receipt.json',[('inputs/configurations',guard),('raw logs',logs.guard)]):
   guard()
   inputs=N.T.Inputs(files=[*p['pins'],planpath]);runner=N.T.Runner(logs,inputs=inputs,env=env,cwd=N.ROOT,capture='split')
   with N.E.GuardBoundary([('inputs/configurations',guard),('raw logs',logs.guard)]):result=runner.run('aligned-source',p['command']['argv'],p['command']['seconds'],expected=None)
   receipt['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']});receipt['logs']=dict(logs.hashes)
   assert result['exit']==0 and result['failure'] is None and result['stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and result['stderr'] in [b'',NOTICE.read_bytes()]
   receipt['status']='ALIGNED_SOURCE_DEVELOPMENT_TYPING_PASS_NO_RUNTIME_CREDIT'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare()
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
