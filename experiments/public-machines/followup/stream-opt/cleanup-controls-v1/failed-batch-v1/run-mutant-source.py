"""One accepted-cleanup batch-erasure mutant source5 raw collector, no runtime reach."""
import argparse, fcntl, json, os, shutil, time, types
from pathlib import Path
H=Path(__file__).resolve().parent
HELPER=H.parents[1]/'native-controls-v1/run.py'
N=types.ModuleType('stream_control_guard'); N.__file__=str(HELPER)
body=HELPER.read_text(); prefix=body.split('\nparser=argparse.ArgumentParser();')[0]
assert len(prefix)<len(body)
exec(compile(prefix,str(HELPER),'exec'),N.__dict__)
ROOT=Path('/workspace/formal-proofs/bendvy')
NORMAL_HELPER=H/'run-native.py'
Q=types.ModuleType('normal_cleanup_qualification');Q.__file__=str(NORMAL_HELPER)
qbody=NORMAL_HELPER.read_text();qprefix=qbody.split('\nparser=argparse.ArgumentParser();')[0];assert len(qprefix)<len(qbody)
exec(compile(qprefix,str(NORMAL_HELPER),'exec'),Q.__dict__)
NOTICE=H.parent/'known-notice.txt'
NOTICE_SHA='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
STDOUT=b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
def prepare():
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  js,jr=Q.qualified_js()
  prior=Q.JS/'plan.json';old=json.loads(prior.read_text())
  assert N.sha(NOTICE)==NOTICE_SHA
  envpath=Path(old['environment']);assert N.sha(envpath)==old['environmentSHA256'];env=json.loads(envpath.read_text())
  assert N.diagnostic_configs(Q.JS,Path(old['stage']),old['tools'],env)==old['configurationStates']
  spec=json.loads((H/'source-proposal.json').read_text());assert all(N.sha(H/n)==v for n,v in spec['sources'].items())
  mutation=json.loads((H/'mutant-proposal.json').read_text());assert N.sha(H/'caller-core.bend')==mutation['baseSourceSHA256'] and N.sha(H/'mutant-caller-core.bend')==mutation['mutantSHA256']
  base=(H/'caller-core.bend').read_text();assert base.count(mutation['oldBody'])==1 and base.count('def first_cleaned(')==1
  expected=base.replace('import ../../../../slots.bend as Slots','import ../../../../slots.bend as Slots\n'+mutation['additionalImport']).replace('def first_cleaned(',mutation['helper']+'def first_cleaned(').replace(mutation['oldBody'],mutation['newBody'])
  assert expected==(H/'mutant-caller-core.bend').read_text() and N.sha(H/'mutant-expected.json')==mutation['independentOracleSHA256']
  out=H/('mutant-source-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage);rel=H.relative_to(N.ROOT)
  (stage/rel/'caller-core.bend').write_bytes((H/'mutant-caller-core.bend').read_bytes());assert len(N.inventory(stage))==92
  files={Path(p) for p in old['pins']}|{Path(__file__),HELPER,NORMAL_HELPER,H/'mutant-proposal.json',H/'mutant-caller-core.bend',H/'mutant-model.py',H/'mutant-expected.json',H/'validate-mutant.py',Q.JS/'plan.json',Q.JS/'receipt.json',NOTICE,Path(old['commands'][0]['generated'])}
  files.update(Q.JS/n for n in jr['logs']);files.update(map(Path,jr['probePins']))
  private=out/'environment.private.json';private.write_bytes(envpath.read_bytes());os.chmod(private,0o600);files.add(private)
  plan={'scope':'One affected mutant source5 RAW diagnostic collection only; zero probes/runtime/proof; classification separate.','pins':{str(p):N.sha(p) for p in sorted(files)},'stage':str(stage),'inventory':N.inventory(stage),'environment':str(private),'environmentSHA256':N.sha(private),'tools':old['tools'],'configurationStates':N.diagnostic_configs(out,stage,old['tools'],env),'command':{'label':'cleanup-source','argv':['/usr/bin/taskset','-c','8',old['tools']['tools']['bend'],str(stage/rel/'caller.bend'),'--check-only'],'seconds':5}}
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
   assert result['exit'] in [0,1] and result['failure'] is None
   receipt['diagnosticClassification']='RAW_UNCLASSIFIED_PENDING_FULL_INDEPENDENT_REVIEW'
   receipt['status']='FAILED_BATCH_ERASURE_MUTANT_SOURCE_RAW_COLLECTED_NO_TYPING_OR_RUNTIME_CREDIT'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare()
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
