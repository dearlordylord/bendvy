"""Fresh reached rejected-disposal mutant JS consumer; complete independent oracle."""
import argparse, fcntl, json, os, shutil, time, types
from pathlib import Path
H=Path(__file__).resolve().parent
HELPER=H.parent/'native-controls-v1/run.py';N=types.ModuleType('cleanup_shared');N.__file__=str(HELPER)
body=HELPER.read_text();prefix=body.split('\nparser=argparse.ArgumentParser();')[0];assert len(prefix)<len(body)
exec(compile(prefix,str(HELPER),'exec'),N.__dict__)
ROOT=Path('/workspace/formal-proofs/bendvy')
SOURCE=H/'mutant-source-1791461077721513378'
SOURCE_PLAN='f8e9adb623d503b96373899b688da7554b25b844ab15eb2ca44efa51b9793b22'
SOURCE_RECEIPT='6b1c3f7c6fc408d4f3d7ea89f020a15afff94b076a53df1fb748fdd067bca26b'
STDERR='868d786993c068cbabfbf08a6e010acd658835fed5352da8f5617803b19c72a9'
NOTICE=H/'known-notice.txt';NOTICE_SHA='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
def source_prerequisite():
 assert N.sha(SOURCE/'plan.json')==SOURCE_PLAN and N.sha(SOURCE/'receipt.json')==SOURCE_RECEIPT
 old=json.loads((SOURCE/'plan.json').read_text());r=json.loads((SOURCE/'receipt.json').read_text())
 assert r['status']=='CLEANUP_MUTANT_SOURCE_RAW_COLLECTED_NO_TYPING_OR_RUNTIME_CREDIT' and not r.get('guardFailures',[]) and len(r['commands'])==1
 assert r['commands'][0]['exit']==1 and r['commands'][0]['failure'] is None
 assert r['commands'][0]['argv']==old['command']['argv'] and r['commands'][0]['seconds']==5
 assert set(r['logs'])=={'cleanup-source.stdout','cleanup-source.stderr'}
 for name,digest in r['logs'].items():assert N.sha(SOURCE/name)==digest
 assert (SOURCE/'cleanup-source.stdout').read_bytes()==b'' and N.sha(SOURCE/'cleanup-source.stderr')==STDERR
 classification=json.loads((H/'mutant-source-classification.json').read_text());assert classification['receiptSHA256']==SOURCE_RECEIPT and classification['stderrSHA256']==STDERR
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
  out=H/('mutant-js-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage)
  private=out/'environment.private.json';private.write_bytes(ep.read_bytes());os.chmod(private,0o600)
  files={Path(p) for p in old['pins']}|{SOURCE/'plan.json',SOURCE/'receipt.json',SOURCE/'cleanup-source.stdout',SOURCE/'cleanup-source.stderr',H/'mutant-source-classification.json',Path(__file__),H/'validate-mutant.py',H/'mutant-model.py',H/'mutant-expected.json',H/'model.py',H/'expected.json',H/'mutant-proposal.json',H/'mutant-caller-core.bend',private}
  # Full independent Python model dependency closure, not first-output inference.
  files.update([ROOT/'experiments/public-machines/followup/foreign-model.py',ROOT/'experiments/public-machines/followup/skip-model.py',ROOT/'experiments/public-machines/full-model.py',ROOT/'experiments/public-machines/followup/evidence/primary-ts-v1/expected.json.gz',ROOT/'experiments/public-machines/expected.json'])
  assert all(p.is_file() for p in files)
  model=N.load(H/'mutant-model.py','cleanup_mutant_author_oracle');assert json.loads((H/'mutant-expected.json').read_text())==model.expected()
  active=[k for k in tools['tools'] if k not in tools['skip_ldd']]
  labels=['guard-'+str(i)+'-ldd-'+k for i in range(5) for k in active]
  commandprefix=[tools['taskset'],'-c','8'];generated=out/'application.js';target=stage/H.relative_to(N.ROOT)/'caller.bend'
  plan={'scope':'Two JS development commands, complete36 worldrows and22 instance records; effect-boundary source not safeproof; post-consumption cleanup only; no timing/Native/core adoption','sourcePlanSHA256':SOURCE_PLAN,'sourceReceiptSHA256':SOURCE_RECEIPT,'pins':{str(p):N.sha(p) for p in sorted(files)},'stage':str(stage),'inventory':N.inventory(stage),'tools':tools,'resources':resources,'cpuAssociation':'Historical installed hashes reused; freshCPU8 ordinary guards, no oldCPU7 raw credit','environment':str(private),'environmentSHA256':N.sha(private),'configurationStates':N.diagnostic_configs(out,stage,tools,env),'executionProbeLabels':labels,'expectedProbeCount':len(labels),'commands':[{'label':'emit-js','argv':commandprefix+[tools['tools']['bend'],str(target),'-o',str(generated)],'seconds':30,'generated':str(generated)},{'label':'consumer','argv':commandprefix+[tools['tools']['node'],str(generated)],'seconds':5}]}
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
     assert result['stderr']==b'';validation=N.load(H/'validate-mutant.py','cleanup_complete_mutant_validator');observed=validation.validate(result['stdout']);normal=N.load(H/'model.py','cleanup_normal_witness_model').expected();assert json.dumps(observed,sort_keys=True)!=json.dumps(normal,sort_keys=True)
     for schema in ['A','B']:
      rejected=next(x for x in observed[schema]['worlds']['B'] if x['label']=='foreign-disposal-rejected');assert 'positions=[]' in rejected['fields']['flowStream']
      assert observed[schema]['instances'][-2]=='B-survivor-delivery=[actual:flow=[Boot>Play]:level=[]:lagged=false,false]'
     r['reachedWitnessSchemas']=['A','B'];r['completeWorldRows']=36;r['completeInstanceRecords']=22
   assert ledger.index==p['expectedProbeCount']
   r['status']='COMPLETE_TWO_SCHEMA_REJECTED_DISPOSAL_DELETION_MUTANT_JS_FULL_ORACLE_AND_WITNESSES_PASS'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare()
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
