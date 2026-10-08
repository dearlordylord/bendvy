"""One failed-batch cleanup source5 raw developmental collector; no probes/runtime/proof."""
import argparse, fcntl, json, os, shutil, time, types
from pathlib import Path
H=Path(__file__).resolve().parent
HELPER=H.parents[1]/'native-controls-v1/run.py'
N=types.ModuleType('stream_control_guard'); N.__file__=str(HELPER)
body=HELPER.read_text(); prefix=body.split('\nparser=argparse.ArgumentParser();')[0]
assert len(prefix)<len(body)
exec(compile(prefix,str(HELPER),'exec'),N.__dict__)
ROOT=Path('/workspace/formal-proofs/bendvy')
NOTICE=H.parent/'known-notice.txt'
NOTICE_SHA='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
STDOUT=b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
NORMAL_HELPER=H.parent/'run-native.py'
Q=types.ModuleType('normal_cleanup_source_prerequisite');Q.__file__=str(NORMAL_HELPER)
qbody=NORMAL_HELPER.read_text();qprefix=qbody.split('\nparser=argparse.ArgumentParser();')[0];assert len(qprefix)<len(qbody)
exec(compile(qprefix,str(NORMAL_HELPER),'exec'),Q.__dict__)
def prepare():
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  old,r=Q.qualified_js();assert N.sha(NOTICE)==NOTICE_SHA
  envpath=Path(old['environment']);assert N.sha(envpath)==old['environmentSHA256'];env=json.loads(envpath.read_text())
  assert N.diagnostic_configs(Q.JS,Path(old['stage']),old['tools'],env)==old['configurationStates']
  spec=json.loads((H/'source-proposal.json').read_text());assert all(N.sha(H/n)==v for n,v in spec['sources'].items()) and all(N.sha(n)==v for n,v in spec['baselineHelpers'].items())
  failed=H/'source-1791463100953863708';repair=spec['developmentRepair']
  assert N.sha(failed/'plan.json')==repair['failedPlanSHA256'] and N.sha(failed/'receipt.json')==repair['failedReceiptSHA256']
  fp=json.loads((failed/'plan.json').read_text());fr=json.loads((failed/'receipt.json').read_text());assert N.inventory(Path(fp['stage']))==fp['inventory'] and len(fp['inventory'])==92
  assert fr['commands'][0]['exit']==1 and fr['commands'][0]['failure'] is None and not fr.get('guardFailures',[])
  historyFiles={failed/'plan.json',failed/'receipt.json'}
  for name,digest in fr['logs'].items():assert N.sha(failed/name)==digest;historyFiles.add(failed/name)
  archiveMapping={str(H/'caller-core.bend'):H/'caller-core-before-tuple-pattern.txt',str(H/'source-proposal.json'):H/'source-proposal-before-tuple-pattern.json',str(H/'run-source.py'):H/'run-source-before-failed-history.txt'}
  for name,digest in fp['pins'].items():
   historic=archiveMapping.get(name,Path(name));assert N.sha(historic)==digest;historyFiles.add(historic)
  historyFiles.update(Path(fp['stage'])/n for n in fp['inventory'])
  out=H/('source-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage)
  rel=H.relative_to(N.ROOT)
  for name in ['caller.bend','caller-core.bend']:
   dst=stage/rel/name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(H/name,dst)
  assert len(N.inventory(stage))==92
  files={Path(p) for p in old['pins']}|{Q.JS/'plan.json',Q.JS/'receipt.json',Path(__file__),HELPER,NORMAL_HELPER,H/'source-proposal.json',H/'model.py',H/'expected.json',H/'validate.py',H/'caller.bend',H/'caller-core.bend',NOTICE,N.T.IMPLEMENTATION,N.BOUNDARY,N.ROOT/'scripts/receipt-logs.py',N.TOOL,Path(old['commands'][0]['generated'])}
  files.update(historyFiles)
  files.update(Q.JS/n for n in r['logs']);files.update(map(Path,r['probePins']))
  private=out/'environment.private.json';private.write_bytes(envpath.read_bytes());os.chmod(private,0o600);files.add(private)
  plan={'scope':'One failedcallback retainednonemptybatch cleanup source5 RAW collector, zero resolverprobes/runtime/proof; diagnostics separate','baselineJSPlanSHA256':Q.JS_PLAN,'baselineJSReceiptSHA256':Q.JS_RECEIPT,'pins':{str(p):N.sha(p) for p in sorted(files)},'stage':str(stage),'inventory':N.inventory(stage),'environment':str(private),'environmentSHA256':N.sha(private),'tools':old['tools'],'configurationStates':N.diagnostic_configs(out,stage,old['tools'],env),'command':{'label':'cleanup-source','argv':['/usr/bin/taskset','-c','8',old['tools']['tools']['bend'],str(stage/rel/'caller.bend'),'--check-only'],'seconds':5}}
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
   receipt['status']='FAILED_BATCH_CLEANUP_SOURCE_RAW_COLLECTED_NO_TYPING_OR_RUNTIME_CREDIT'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare()
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
