"""Fresh complete failedcallback nonemptybatch cleanup Native consumer, no timing/core adoption."""
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

JS=H/'js-1791463557276222515'
JS_PLAN='eee8cef0f84245021dd76dbaba2230059fabecd5900032cb2db6e1c6408ccab0'
JS_RECEIPT='2a8a9ab241f37acc9a7857b4f75ebc1bda5e632f8e3bc14b0d5d1617b6cd0ba5'
def qualified_js():
 assert N.sha(JS/'plan.json')==JS_PLAN and N.sha(JS/'receipt.json')==JS_RECEIPT
 old=json.loads((JS/'plan.json').read_text());r=json.loads((JS/'receipt.json').read_text())
 assert r['status']=='COMPLETE_FAILED_BATCH_CLEANUP_JS32_WORLD16_INSTANCE_PASS_NO_ISSUE_CLOSURE' and not r.get('guardFailures',[]) and len(r['commands'])==2
 for command,result in zip(old['commands'],r['commands']):
  assert result['label']==command['label'] and result['argv']==command['argv'] and result['seconds']==command['seconds'] and result['exit']==0 and result['failure'] is None
 assert N.inventory(Path(old['stage']))==old['inventory'] and all(N.sha(n)==v for n,v in old['pins'].items())
 assert set(r['logs'])=={'emit-js.stdout','emit-js.stderr','consumer.stdout','consumer.stderr'}
 for name,digest in r['logs'].items():assert N.sha(JS/name)==digest
 assert (JS/'emit-js.stdout').read_bytes()==b'' and (JS/'consumer.stderr').read_bytes()==b''
 assert (JS/'emit-js.stderr').read_bytes() in [b'',NOTICE.read_bytes()]
 assert r['generated']=={old['commands'][0]['generated']:N.sha(old['commands'][0]['generated'])}
 assert r['probeCommandsExecuted']==old['expectedProbeCount']==35
 names={label+suffix for label in old['executionProbeLabels'] for suffix in ['.json','.stdout','.stderr']}
 assert {p.name for p in (JS/'execution-probes').iterdir()}==names and set(r['probePins'])=={str(JS/'execution-probes'/n) for n in names}
 for name,digest in r['probePins'].items():assert N.sha(name)==digest
 for label in old['executionProbeLabels']:
  record=json.loads((JS/'execution-probes'/(label+'.json')).read_text());tool=label.split('-ldd-',1)[1]
  assert record['argv']==[old['tools']['taskset'],'-c','8',old['tools']['ldd'],old['tools']['tools'][tool]] and record['seconds']==5 and record['exit']==0 and record['failure'] is None and record['exception'] is None and record['runnerSHA256']==old['pins'][str(N.T.IMPLEMENTATION)]
 assert r['completeWorldRows']==32 and r['completeInstanceRecords']==16
 N.load(H/'validate.py','cleanup_qualified_js_model').validate((JS/'consumer.stdout').read_bytes())
 return old,r

def prepare():
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  source_prerequisite();old,r=qualified_js();assert N.sha(NOTICE)==NOTICE_SHA
  ep=Path(old['environment']);assert N.sha(ep)==old['environmentSHA256'];env=json.loads(ep.read_text());N.validate_node_environment(env)
  tools=old['tools'];assert tools['cpu']==8 and all(N.sha(n)==v for n,v in tools['pins'].items())
  assert all(N.inventory(Path(n))==v for n,v in old['resources'].items())
  assert N.diagnostic_configs(JS,Path(old['stage']),tools,env)==old['configurationStates']
  out=H/('native-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage)
  private=out/'environment.private.json';private.write_bytes(ep.read_bytes());os.chmod(private,0o600)
  files={Path(p) for p in old['pins']}|{JS/'plan.json',JS/'receipt.json',Path(__file__),private,Path(old['commands'][0]['generated'])}
  files.update(JS/n for n in r['logs']);files.update(map(Path,r['probePins']))
  active=[k for k in tools['tools'] if k not in tools['skip_ldd']];labels=['guard-'+str(i)+'-ldd-'+k for i in range(7) for k in active]
  prefix=[tools['taskset'],'-c','8'];c=out/'application.c';binary=out/'application-native';target=stage/H.relative_to(N.ROOT)/'caller.bend'
  p={'scope':'Native complete32 worldrows/16instances, threecommands C30/Clang120/run5 CPU8thread1GPUoff/49guards, no timing/proof/coreadoption; failedcallback nonemptyretainedbatch sameworldsurvivor cleanup','JSPlanSHA256':JS_PLAN,'JSReceiptSHA256':JS_RECEIPT,'pins':{str(p):N.sha(p) for p in sorted(files)},'stage':str(stage),'inventory':N.inventory(stage),'tools':tools,'resources':old['resources'],'environment':str(private),'environmentSHA256':N.sha(private),'configurationStates':N.current_configs(out,stage,tools,env),'executionProbeLabels':labels,'expectedProbeCount':len(labels),'commands':[{'label':'emit-c','argv':prefix+[tools['tools']['bend'],str(target),'-o',str(c)],'seconds':30,'generated':str(c)},{'label':'clang','argv':prefix+[tools['tools']['clang_wrapper'],'-O3',str(c),'-o',str(binary),'-pthread','-lm'],'seconds':120,'generated':str(binary)},{'label':'consumer','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5}]}
  (out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json');print(N.sha(out/'plan.json'))

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
   if env is not None:assert N.current_configs(out,stage,p['tools'],env)==p['configurationStates']
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
    if c['label']=='emit-c':assert result['stdout']==b'' and result['stderr'] in [b'',NOTICE.read_bytes()] and c['generated'] in generated
    elif c['label']=='clang':assert result['stdout']==result['stderr']==b'' and c['generated'] in generated
    else:
     assert result['stderr']==b'';validation=N.load(H/'validate.py','cleanup_complete_validator');validation.validate(result['stdout']);r['completeWorldRows']=32;r['completeInstanceRecords']=16
   assert ledger.index==p['expectedProbeCount']
   r['status']='COMPLETE_FAILED_BATCH_CLEANUP_NATIVE32_WORLD16_INSTANCE_PASS_NO_ISSUE_CLOSURE'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare()
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
