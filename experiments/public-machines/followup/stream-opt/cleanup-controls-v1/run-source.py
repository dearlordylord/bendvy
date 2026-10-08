"""One frozen cleanup source5 developmental collector; no probes/runtime/proof."""
import argparse, fcntl, json, os, shutil, time, types
from pathlib import Path
H=Path(__file__).resolve().parent
HELPER=H.parent/'native-controls-v1/run.py'
N=types.ModuleType('stream_control_guard'); N.__file__=str(HELPER)
body=HELPER.read_text(); prefix=body.split('\nparser=argparse.ArgumentParser();')[0]
assert len(prefix)<len(body)
exec(compile(prefix,str(HELPER),'exec'),N.__dict__)
ROOT=Path('/workspace/formal-proofs/bendvy')
NOTICE=H/'known-notice.txt'
NOTICE_SHA='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
STDOUT=b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
def prepare():
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  prior=H.parent/'native-controls-v1/native-queue-capacity-1791456387123243290/plan.json';old=json.loads(prior.read_text())
  assert N.sha(NOTICE)==NOTICE_SHA
  envpath=Path(old['privateEnvironment']);assert N.sha(envpath)==old['environmentSHA256'];env=json.loads(envpath.read_text())
  spec=json.loads((H/'source-proposal.json').read_text());assert all(N.sha(p)==s for p,s in spec['sourcePins'].items())
  out=H/('source-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir()
  # Exact root historical88 paths refreshed explicitly in reviewed source proposal.
  history=json.loads((H.parent/'cleanup-history-join.json').read_text())
  for rel in history['historicalStagePins']:
   src=ROOT/rel;dst=stage/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
  rel=H.relative_to(N.ROOT)
  for name in ['caller.bend','caller-core.bend']:
   dst=stage/rel/name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(H/name,dst)
  files={Path(p) for p in spec['sourcePins']}|{Path(__file__),HELPER,H/'source-proposal.json',H/'PLAN.md',H/'model.py',H/'expected.json',NOTICE,H.parent/'cleanup-history-join.json',prior,envpath,N.T.IMPLEMENTATION,N.BOUNDARY,N.ROOT/'scripts/receipt-logs.py',N.TOOL}
  files.update(map(Path,old['tools']['pins']))
  private=out/'environment.private.json';private.write_bytes(envpath.read_bytes());os.chmod(private,0o600);files.add(private)
  plan={'scope':'One affected source5 development collector, zero probes/backends/proof; post-consumption cleanup only, failed callback retention excluded','pins':{str(p):N.sha(p) for p in sorted(files)},'stage':str(stage),'inventory':N.inventory(stage),'environment':str(private),'environmentSHA256':N.sha(private),'tools':old['tools'],'configurationStates':N.diagnostic_configs(out,stage,old['tools'],env),'command':{'label':'cleanup-source','argv':['/usr/bin/taskset','-c','8',old['tools']['tools']['bend'],str(stage/rel/'caller.bend'),'--check-only'],'seconds':5}}
  (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json');print(N.sha(out/'plan.json'))
def run(path,admitted):
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);logs=None;inputs=None;env=None
  assert not (out/'receipt.json').exists()
  def guard():
   assert N.sha(path)==admitted and N.sha(NOTICE)==NOTICE_SHA
   assert all(N.sha(n)==s for n,s in p['pins'].items())
   assert N.inventory(stage)==p['inventory']
   if env is not None:assert N.diagnostic_configs(out,stage,p['tools'],env)==p['configurationStates']
   if inputs is not None:inputs.guard()
  def rawguard():
   if logs is not None:
    receipt['logs']=dict(logs.hashes);logs.guard()
  receipt={'planSHA256':admitted,'scope':p['scope'],'commands':[]}
  with N.E.ReceiptBoundary(receipt,out/'receipt.json',[('source/configuration',guard),('raw logs',rawguard)]):
   guard();env=json.loads(Path(p['environment']).read_text());assert N.sha(p['environment'])==p['environmentSHA256'];guard()
   logs=N.L.CommandLogs(out,['cleanup-source']);inputs=N.T.Inputs(files=[*p['pins'],path],directories=[stage]);runner=N.T.Runner(logs,inputs=inputs,env=env,cwd=stage,capture='split')
   attempt={'label':'cleanup-source','argv':p['command']['argv'],'seconds':5,'status':'ATTEMPTED'};receipt['commands'].append(attempt)
   try:
    with N.E.GuardBoundary([('source/configuration',guard),('raw logs',rawguard)]):result=runner.run('cleanup-source',p['command']['argv'],5,expected=None)
   except BaseException as error:
    attempt['status']='FAILED';attempt['exception']=type(error).__name__+': '+str(error)
    if hasattr(error,'result'):attempt.update({k:v for k,v in error.result.items() if k not in ['stdout','stderr']})
    raise
   attempt.update({k:v for k,v in result.items() if k not in ['stdout','stderr']});attempt['status']='TERMINAL'
   assert result['exit']==0 and result['failure'] is None and result['stdout']==STDOUT and result['stderr'] in [b'',NOTICE.read_bytes()]
   receipt['status']='CLEANUP_SOURCE_DEVELOPMENT_TYPING_PASS_NO_RUNTIME_CREDIT'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare()
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
