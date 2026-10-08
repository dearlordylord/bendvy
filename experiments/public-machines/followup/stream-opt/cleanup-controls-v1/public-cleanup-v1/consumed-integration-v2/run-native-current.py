"""Fresh current-world actual cleanup Native complete scenario; historical JS is not current-world acceptance."""
import argparse, ast, fcntl, json, os, shutil, time, types, tarfile, hashlib
from pathlib import Path
H=Path(__file__).resolve().parent.parent
V=Path(__file__).resolve().parent
HELPER=H.parents[1]/'native-controls-v1/run.py';N=types.ModuleType('cleanup_shared');N.__file__=str(HELPER)
body=HELPER.read_text();prefix=body.split('\nparser=argparse.ArgumentParser();')[0];assert len(prefix)<len(body)
exec(compile(prefix,str(HELPER),'exec'),N.__dict__)
ROOT=Path('/workspace/formal-proofs/bendvy')
SOURCE=V/'bridge-source-1791473372175098193'
SOURCE_PLAN='3d4dcdc27dd8b7100c07632fe47d3b8b92c5c0475015fe75a07c43a1f5552b64'
SOURCE_RECEIPT='4354d217e1b718c8afdcdba1e96464fcaa2d057aa6a6c2717e099091a40c32bb'
NOTICE=H.parent/'known-notice.txt';NOTICE_SHA='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
SCENARIOS={'post-consumption':('experiments/public-machines/followup/stream-opt/cleanup-controls-v1/caller.bend',36,22),'failed-batch':('experiments/public-machines/followup/stream-opt/cleanup-controls-v1/failed-batch-v1/caller.bend',32,16)}

def consumed_imports(stage,entry,inventory):
 tree=ast.parse((V/'run-source.py').read_text());function=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='consumed_imports');module=ast.Module(body=[function],type_ignores=[]);namespace={'N':N,'Path':Path};exec(compile(module,str(V/'run-source.py'),'exec'),namespace);return namespace['consumed_imports'](stage,entry,inventory)

O=V/'native-current-v1'
PACKET=V/'delivery-js-v1'
PACKET_MANIFEST='1b738f40d318f768f0fe554c98dc9d501060f5147b7a71355e26e38cf435a564'
PROPOSAL='6fa986f7601d95f9381f817cfb9dda1cd7af5f3a67d2c050b0c09389e7eda831'
NORMALS={'post-consumption':('post-JS','9275c0a7806305441bf164f2c9182202d63de46fc512a30e1c84c4d8fd6cd542','21626d9e62314f31e27707dcc69dbb9cef4c8f550ffa0123f08364f2aaa8a1b3'),'failed-batch':('failed-JS','5163c40ea803a9d8e642e40b4ca62ff9cbbcc408e1decf0c1de83eb9cef6f201','8590c4c2c73e3ffb18166b8efe19ffa3804a66f4917b73255ce81dd8d406d8c9')}
def historical_packet(scenario):
 assert N.sha(PACKET/'manifest.json')==PACKET_MANIFEST
 manifest=json.loads((PACKET/'manifest.json').read_text());assert N.sha(PACKET/'cohort.tar.gz')==manifest['archive']['sha256']
 with tarfile.open(PACKET/'cohort.tar.gz') as archive:
  entries=archive.getmembers();names=[e.name for e in entries];assert len(names)==len(set(names)) and set(names)==set(manifest['archive']['members'])
  assert all(e.isfile() and not Path(e.name).is_absolute() and '..' not in Path(e.name).parts for e in entries)
  data={e.name:archive.extractfile(e).read() for e in entries}
 for n,e in manifest['archive']['members'].items():assert hashlib.sha256(data[n]).hexdigest()==e['sha256'] and len(data[n])==e['bytes']
 label,ps,rs=NORMALS[scenario];assert hashlib.sha256(data[label+'/plan.json']).hexdigest()==ps and hashlib.sha256(data[label+'/receipt.json']).hexdigest()==rs
 # Reviewed portable verifier checks all eight exact historical cohorts, complete
 # raw/model outputs, scalar identity dispositions and reached branch controls.
 namespace={'__file__':str(V/'verify-js.py'),'__name__':'cleanup_packet_preparation'};assert N.sha(V/'verify-js.py')=='15e11b61de6a3798d42aad74d8fb66acb35d32b7635dadc4a01e9ae3d41be540'
 exec(compile((V/'verify-js.py').read_text(),str(V/'verify-js.py'),'exec'),namespace)
 return json.loads(data[label+'/plan.json'])
def prepare(scenario):
 assert scenario in SCENARIOS
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  old=historical_packet(scenario);assert N.sha(NOTICE)==NOTICE_SHA and N.sha(O/'proposal.json')==PROPOSAL
  proposal=json.loads((O/'proposal.json').read_text());assert N.inventory(Path(proposal['stage']))==proposal['inventory']
  for original,e in proposal['currentCore'].items():assert N.sha(original)==N.sha(Path(proposal['stage'])/e['copy'])==e['sha256']
  assert {n for n in old['inventory'] if old['inventory'][n]!=proposal['inventory'][n]}=={e['path'] for e in proposal['changedFiles']}
  for e in proposal['changedFiles']:
   assert e['oldSHA256']==old['inventory'][e['path']] and e['newSHA256']==proposal['inventory'][e['path']]
  ep=Path(old['environment']);assert N.sha(ep)==old['environmentSHA256'];env=json.loads(ep.read_text());N.validate_node_environment(env)
  tools=old['tools'];assert tools['cpu']==8 and all(N.sha(n)==s for n,s in tools['pins'].items())
  assert all(N.inventory(Path(n))==s for n,s in old['resources'].items())
  historicalRoot=Path(old['stage']).parent
  assert N.diagnostic_configs(historicalRoot,Path(old['stage']),tools,env)==old['configurationStates']
  out=O/('native-'+scenario+'-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(proposal['stage'],stage)
  private=out/'environment.private.json';private.write_bytes(ep.read_bytes());os.chmod(private,0o600)
  spec=json.loads((H/'models-direction.json').read_text());assert all(N.sha(H/n)==s for n,s in spec['files'].items())
  model=N.load(H/'models'/scenario/'model.py','current_cleanup_independent_model');assert json.loads((H/'models'/scenario/'expected.json').read_text())==model.expected()
  files={Path(__file__),HELPER,V/'run-source.py',V/'verify-js.py',PACKET/'manifest.json',PACKET/'cohort.tar.gz',PACKET/'REPORT.md',O/'proposal.json',private,ep,NOTICE,H/'models-direction.json',N.T.IMPLEMENTATION,Path(N.L.__file__),Path(N.E.__file__),Path(N.Shared.__file__)}
  files.update(Path(n) for n in tools['pins']);files.update(Path(n) for n in proposal['currentCore']);files.update(H/n for n in spec['files']);files.update(H/n for n in json.loads((PACKET/'manifest.json').read_text())['sources'])
  inventory=N.inventory(stage);target=stage/SCENARIOS[scenario][0];assert target.is_file() and N.sha(target)==inventory[SCENARIOS[scenario][0]]==proposal['inventory'][SCENARIOS[scenario][0]]
  consumed=consumed_imports(stage,SCENARIOS[scenario][0],inventory);assert 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/adapter.bend' in consumed
  active=[k for k in tools['tools'] if k not in tools['skip_ldd']];labels=['guard-'+str(i)+'-ldd-'+k for i in range(7) for k in active]
  prefix=[tools['taskset'],'-c','8'];c=out/'application.c';binary=out/'application-native';assert not c.exists() and not binary.exists()
  plan={'scenario':scenario,'scope':'Fresh current-world actual consumed cleanup Native normal full scenario, C30/Clang120/run5 CPU8 thread1 GPUoff49; historical JS source/body identity only, no current-world acceptance transfer, no timing/coreadoption/proof','historicalJSPlanSHA256':NORMALS[scenario][1],'historicalJSReceiptSHA256':NORMALS[scenario][2],'sourceSelectionSHA256':PROPOSAL,'consumedImports':consumed,'pins':{str(p):N.sha(p) for p in sorted(files)},'stage':str(stage),'inventory':inventory,'tools':tools,'resources':old['resources'],'environment':str(private),'environmentSHA256':N.sha(private),'configurationStates':N.current_configs(out,stage,tools,env),'executionProbeLabels':labels,'expectedProbeCount':len(labels),'commands':[{'label':'emit-c','argv':prefix+[tools['tools']['bend'],str(target),'-o',str(c)],'seconds':30,'generated':str(c)},{'label':'clang','argv':prefix+[tools['tools']['clang_wrapper'],'-O3',str(c),'-o',str(binary),'-pthread','-lm'],'seconds':120,'generated':str(binary)},{'label':'consumer','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5}]}
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
   assert consumed_imports(stage,SCENARIOS[p['scenario']][0],p['inventory'])==p['consumedImports']
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
      generated[c['generated']]=N.sha(c['generated']);sourceguard();fresh=N.T.Inputs(files=[path,*p['pins'],*generated],directories=[stage]);runner.inputs=fresh;ledger.runner.inputs=fresh
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
     assert result['stderr']==b'';validation=N.load(H/'models'/p['scenario']/'validate.py','cleanup_complete_validator');validation.validate(result['stdout']);r['completeWorldRows']=SCENARIOS[p['scenario']][1];r['completeInstanceRecords']=SCENARIOS[p['scenario']][2]
   assert ledger.index==p['expectedProbeCount']
   r['status']='ACTUAL_CURRENT_WORLD_CLEANUP_'+p['scenario'].upper().replace('-','_')+'_FULL_NATIVE_ORACLE_PASS_NO_ISSUE_CLOSURE'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--scenario',choices=list(SCENARIOS));parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare(args.scenario)
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
