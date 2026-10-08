"""Fresh failedcallback retained-batch cleanup JS consumer; no timing or core adoption."""
import argparse, fcntl, json, os, shutil, time, types
from pathlib import Path
H=Path(__file__).resolve().parent
HELPER=H.parents[1]/'native-controls-v1/run.py';N=types.ModuleType('cleanup_shared');N.__file__=str(HELPER)
body=HELPER.read_text();prefix=body.split('\nparser=argparse.ArgumentParser();')[0];assert len(prefix)<len(body)
exec(compile(prefix,str(HELPER),'exec'),N.__dict__)
ROOT=Path('/workspace/formal-proofs/bendvy')
SOURCE=H/'source-1791463371647215030'
SOURCE_PLAN='21282080652192e0b6791d17e58bd6d3aaca012c291dee14c970d922bcc82fd4'
SOURCE_RECEIPT='88f02251717923e01a8075dbb8f3052079a83e3943849b22bc50a35f066c76c4'
STDERR='607556a2b69ba1750877198242ed267c204cc7fc3e97b4419f3e68f6f6c8b67e'
NOTICE=H.parent/'known-notice.txt';NOTICE_SHA='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
def source_prerequisite():
 assert N.sha(SOURCE/'plan.json')==SOURCE_PLAN and N.sha(SOURCE/'receipt.json')==SOURCE_RECEIPT
 old=json.loads((SOURCE/'plan.json').read_text());r=json.loads((SOURCE/'receipt.json').read_text())
 assert r['status']=='FAILED_BATCH_CLEANUP_SOURCE_RAW_COLLECTED_NO_TYPING_OR_RUNTIME_CREDIT' and not r.get('guardFailures',[]) and len(r['commands'])==1
 assert r['commands'][0]['exit']==1 and r['commands'][0]['failure'] is None
 assert r['commands'][0]['argv']==old['command']['argv'] and r['commands'][0]['seconds']==5
 assert set(r['logs'])=={'cleanup-source.stdout','cleanup-source.stderr'}
 for name,digest in r['logs'].items():assert N.sha(SOURCE/name)==digest
 assert (SOURCE/'cleanup-source.stdout').read_bytes()==b'' and N.sha(SOURCE/'cleanup-source.stderr')==STDERR
 classification=json.loads((H/'source-classification.json').read_text());assert classification['receiptSHA256']==SOURCE_RECEIPT and classification['stderrSHA256']==STDERR
 assert N.inventory(Path(old['stage']))==old['inventory'] and all(N.sha(p)==s for p,s in old['pins'].items())
 return old

def prepare():
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  old=source_prerequisite();assert N.sha(NOTICE)==NOTICE_SHA
  ep=Path(old['environment']);assert N.sha(ep)==old['environmentSHA256'];env=json.loads(ep.read_text());N.validate_node_environment(env)
  tools=old['tools'];tools=json.loads(json.dumps(tools));tools['cpu']=8
  # Hash/resource reuse only. Current CPU8 ordinary guards requalify binaries;
  # no CPU7 command/raw qualification is rewritten or credited as CPU8 evidence.
  assert all(N.sha(p)==s for p,s in tools['pins'].items())
  resources={str(Path(p)):N.inventory(Path(p)) for p in tools['resource_roots']}
  out=H/('js-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage)
  private=out/'environment.private.json';private.write_bytes(ep.read_bytes());os.chmod(private,0o600)
  files={Path(p) for p in old['pins']}|{SOURCE/'plan.json',SOURCE/'receipt.json',SOURCE/'cleanup-source.stdout',SOURCE/'cleanup-source.stderr',H/'source-classification.json',Path(__file__),H/'validate.py',H/'model.py',H/'expected.json',private}
  # Full independent Python model dependency closure, not first-output inference.
  files.update([ROOT/'experiments/public-machines/followup/foreign-model.py',ROOT/'experiments/public-machines/followup/skip-model.py',ROOT/'experiments/public-machines/full-model.py',ROOT/'experiments/public-machines/followup/evidence/primary-ts-v1/expected.json.gz',ROOT/'experiments/public-machines/expected.json'])
  assert all(p.is_file() for p in files)
  model=N.load(H/'model.py','cleanup_author_oracle');assert json.loads((H/'expected.json').read_text())==model.expected()
  active=[k for k in tools['tools'] if k not in tools['skip_ldd']]
  labels=['guard-'+str(i)+'-ldd-'+k for i in range(5) for k in active]
  commandprefix=[tools['taskset'],'-c','8'];generated=out/'application.js';target=stage/H.relative_to(N.ROOT)/'caller.bend'
  plan={'scope':'Two JS development commands, complete32 worldrows and16 instance records; effect-boundary source not safeproof; failedcallback/nonemptybatch/sameworldsurvivor cleanup; no timing/Native/core adoption','sourcePlanSHA256':SOURCE_PLAN,'sourceReceiptSHA256':SOURCE_RECEIPT,'pins':{str(p):N.sha(p) for p in sorted(files)},'stage':str(stage),'inventory':N.inventory(stage),'tools':tools,'resources':resources,'cpuAssociation':'Historical installed hashes reused; freshCPU8 ordinary guards, no oldCPU7 raw credit','environment':str(private),'environmentSHA256':N.sha(private),'configurationStates':N.diagnostic_configs(out,stage,tools,env),'executionProbeLabels':labels,'expectedProbeCount':len(labels),'commands':[{'label':'emit-js','argv':commandprefix+[tools['tools']['bend'],str(target),'-o',str(generated)],'seconds':30,'generated':str(generated)},{'label':'consumer','argv':commandprefix+[tools['tools']['node'],str(generated)],'seconds':5}]}
  (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json');print(N.sha(out/'plan.json'))
def run(path,admitted):
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);env=None;logs=None;ledger=None;runner=None;generated={}
  assert not (out/'receipt.json').exists()
  r={'planSHA256':admitted,'scope':p['scope'],'commands':[]}
  def sourceguard():
   assert N.sha(path)==admitted and N.sha(NOTICE)==NOTICE_SHA
   assert all(N.sha(n)==s for n,s in p['pins'].items()) and N.inventory(stage)==p['inventory']
   assert all(N.inventory(Path(n))==v for n,v in p['resources'].items())
   assert all(N.sha(n)==v for n,v in generated.items())
   if env is not None:assert N.diagnostic_configs(out,stage,p['tools'],env)==p['configurationStates']
   if ledger is not None:ledger.guard()
  def metadata():
   r.update(logs=dict(logs.hashes) if logs is not None else {},generated=generated,probePins=ledger.pins() if ledger is not None else {},probeCommandsExecuted=ledger.index if ledger is not None else 0)
  def rawguard():
   if logs is not None:logs.guard()
  with N.E.ReceiptBoundary(r,out/'receipt.json',[('metadata',metadata),('source/config/env/generated/probes',sourceguard),('raw logs',rawguard)]):
   sourceguard();env=json.loads(Path(p['environment']).read_text());N.validate_node_environment(env);assert N.sha(p['environment'])==p['environmentSHA256'];os.environ.clear();os.environ.update(env);sourceguard()
   logs=N.L.CommandLogs(out,[c['label'] for c in p['commands']]);inputs=N.T.Inputs(files=[path,*p['pins']],directories=[stage])
   ledger=N.ProbeLedger(out/'execution-probes',p['executionProbeLabels'],inputs,env);runner=N.T.Runner(logs,inputs=inputs,env=env,cwd=stage,capture='split')
   def guard():
    sourceguard();N.Shared.verify(N.decode(p['tools']),**N.owned_configuration(ledger,N.decode(p['tools']),env));sourceguard()
   guard()
   for c in p['commands']:
    guard()
    def register_generated():
     if c.get('generated') and Path(c['generated']).is_file():
      generated[c['generated']]=N.sha(c['generated']);fresh=N.T.Inputs(files=[path,*p['pins'],*generated],directories=[stage]);runner.inputs=fresh;ledger.runner.inputs=fresh
    attempt={'label':c['label'],'argv':c['argv'],'seconds':c['seconds'],'status':'ATTEMPTED'};r['commands'].append(attempt)
    try:
     with N.E.GuardBoundary([('generated input registration',register_generated),('raw logs',rawguard),('source/tool/config guard',guard)]):
      if c.get('generated'):assert not Path(c['generated']).exists()
      result=runner.run(c['label'],c['argv'],c['seconds'],expected=0)
    except BaseException as error:
     attempt.update(status='FAILED',exception=type(error).__name__+': '+str(error))
     if hasattr(error,'result'):attempt.update({k:v for k,v in error.result.items() if k not in ['stdout','stderr']})
     raise
    attempt.update({k:v for k,v in result.items() if k not in ['stdout','stderr']});attempt['status']='TERMINAL'
    if c['label']=='emit-js':assert result['stdout']==b'' and result['stderr'] in [b'',NOTICE.read_bytes()] and c['generated'] in generated
    else:
     assert result['stderr']==b'';validation=N.load(H/'validate.py','cleanup_complete_validator');validation.validate(result['stdout']);r['completeWorldRows']=32;r['completeInstanceRecords']=16
   assert ledger.index==p['expectedProbeCount']
   r['status']='COMPLETE_FAILED_BATCH_CLEANUP_JS32_WORLD16_INSTANCE_PASS_NO_ISSUE_CLOSURE'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare()
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
