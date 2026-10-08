"""Actual current-world accepted-cleanup clock Native counterfactual; complete independent models, no adoption."""
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
M=V/'mutation-clock-v2'
CONTROL=O/'mutation-clock-v1'
CONTROL_PROPOSAL='f57aca616458ab09b697dea558bb912f3366f23bb0dadf85e482483dae102643'
NATIVE_NORMALS={'post-consumption':('native-post-consumption-1791477367734479656','1175edf25840ba2e489d3d17420bafe158ff86f0c66778d5984c076e0632ce24','719046f5514a2a7f8789490f4812fb2d9132974204730b14edc21026372a75c3'),'failed-batch':('native-failed-batch-1791477677697672506','15a11601ab8d353634bc866e85a49e16cb1f5e66c92d5ee0e72bb5536e61e9cb','a32ae02f52720daec1c95eb5b9749821380e7214cc73afbe29c2d5748a176fe0')}
def current_normal(scenario):
 folder,ps,rs=NATIVE_NORMALS[scenario];root=O/folder;assert N.sha(root/'plan.json')==ps and N.sha(root/'receipt.json')==rs
 p=json.loads((root/'plan.json').read_text());r=json.loads((root/'receipt.json').read_text());assert r['planSHA256']==ps and r['status']=='ACTUAL_CURRENT_WORLD_CLEANUP_'+scenario.upper().replace('-','_')+'_FULL_NATIVE_ORACLE_PASS_NO_ISSUE_CLOSURE' and not r.get('guardFailures',[])
 assert len(p['commands'])==len(r['commands'])==3 and [c['label'] for c in p['commands']]==['emit-c','clang','consumer'] and [c['seconds'] for c in p['commands']]==[30,120,5]
 for c,a in zip(p['commands'],r['commands']):assert all(a[k]==c[k] for k in ['argv','label','seconds']) and a['exit']==0 and a['failure'] is None and a['runnerSHA256']==N.sha(N.T.IMPLEMENTATION)
 assert set(r['logs'])=={c['label']+suffix for c in p['commands'] for suffix in ['.stdout','.stderr']} and all(N.sha(root/n)==h for n,h in r['logs'].items())
 assert (root/'emit-c.stdout').read_bytes()==b'' and (root/'emit-c.stderr').read_bytes() in [b'',NOTICE.read_bytes()] and (root/'clang.stdout').read_bytes()==(root/'clang.stderr').read_bytes()==(root/'consumer.stderr').read_bytes()==b''
 assert set(r['generated'])=={c['generated'] for c in p['commands'] if 'generated' in c} and all(N.sha(n)==h for n,h in r['generated'].items())
 assert all(N.sha(n)==h for n,h in p['pins'].items()) and N.inventory(Path(p['stage']))==p['inventory']
 labels=p['executionProbeLabels'];active=[k for k in p['tools']['tools'] if k not in p['tools']['skip_ldd']];assert labels==['guard-'+str(i)+'-ldd-'+k for i in range(7) for k in active] and p['expectedProbeCount']==r['probeCommandsExecuted']==49
 members={label+suffix for label in labels for suffix in ['.json','.stdout','.stderr']};assert set(r['probePins'])=={str(root/'execution-probes'/n) for n in members} and {p.name for p in (root/'execution-probes').iterdir()}==members
 for n,h in r['probePins'].items():assert N.sha(n)==h
 for label in labels:
  q=json.loads((root/'execution-probes'/(label+'.json')).read_text());key=label.split('-ldd-',1)[1];assert q['argv']==[p['tools']['taskset'],'-c','8',p['tools']['ldd'],p['tools']['tools'][key]] and q['seconds']==5 and q['exit']==0 and q['failure'] is None and q.get('exception') is None and q['runnerSHA256']==N.sha(N.T.IMPLEMENTATION)
 N.load(H/'models'/scenario/'validate.py','current_complete_normal_oracle').validate((root/'consumer.stdout').read_bytes())
 return root,p,r
def prepare(scenario):
 assert scenario in SCENARIOS
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  normalroot,np,nr=current_normal(scenario)
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
  out=CONTROL/('native-'+scenario+'-'+str(time.time_ns()));out.mkdir();stage=out/'stage';assert N.sha(CONTROL/'proposal.json')==CONTROL_PROPOSAL;control=json.loads((CONTROL/'proposal.json').read_text());assert N.inventory(Path(control['stage']))==control['inventory'];assert {n for n in proposal['inventory'] if proposal['inventory'][n]!=control['inventory'][n]}=={control['changedFile']};assert N.sha(M/'adapter.bend')==control['mutantSHA256'];shutil.copytree(control['stage'],stage)
  private=out/'environment.private.json';private.write_bytes(ep.read_bytes());os.chmod(private,0o600)
  spec=json.loads((H/'models-direction.json').read_text());assert all(N.sha(H/n)==s for n,s in spec['files'].items())
  mutationSpec=json.loads((M/'models-direction.json').read_text());assert all(N.sha(H/n)==h for n,h in mutationSpec['files'].items());model=N.load(M/'models'/scenario/'model.py','current_cleanup_independent_mutant_model');assert json.dumps(json.loads((M/'models'/scenario/'expected.json').read_text()),sort_keys=True)==json.dumps(model.expected(),sort_keys=True)
  files={Path(__file__),HELPER,V/'run-source.py',V/'verify-js.py',PACKET/'manifest.json',PACKET/'cohort.tar.gz',PACKET/'REPORT.md',O/'proposal.json',private,ep,NOTICE,H/'models-direction.json',N.T.IMPLEMENTATION,Path(N.L.__file__),Path(N.E.__file__),Path(N.Shared.__file__)}
  files.update(Path(n) for n in tools['pins']);files.update(Path(n) for n in proposal['currentCore']);files.update(H/n for n in spec['files']);files.update(H/n for n in json.loads((PACKET/'manifest.json').read_text())['sources'])
  files.update({CONTROL/'proposal.json',M/'proposal.json',M/'model.py',M/'models-direction.json',normalroot/'plan.json',normalroot/'receipt.json'});files.update(H/n for n in mutationSpec['files']);files.update(map(Path,np['pins']));files.update(map(Path,nr['generated']));files.update(normalroot/n for n in nr['logs']);files.update(map(Path,nr['probePins']))
  inventory=N.inventory(stage);target=stage/SCENARIOS[scenario][0];assert target.is_file() and N.sha(target)==inventory[SCENARIOS[scenario][0]]==proposal['inventory'][SCENARIOS[scenario][0]]
  consumed=consumed_imports(stage,SCENARIOS[scenario][0],inventory);assert 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/adapter.bend' in consumed
  active=[k for k in tools['tools'] if k not in tools['skip_ldd']];labels=['guard-'+str(i)+'-ldd-'+k for i in range(7) for k in active]
  prefix=[tools['taskset'],'-c','8'];c=out/'application.c';binary=out/'application-native';assert not c.exists() and not binary.exists()
  plan={'scenario':scenario,'scope':'Fresh current-world actual accepted-adapter Native counterfactual full scenario, C30/Clang120/run5 CPU8 thread1 GPUoff49; historical JS source/body identity only, no current-world acceptance transfer, no timing/coreadoption/proof','historicalJSPlanSHA256':NORMALS[scenario][1],'historicalJSReceiptSHA256':NORMALS[scenario][2],'sourceSelectionSHA256':PROPOSAL,'controlProposalSHA256':CONTROL_PROPOSAL,'normalNativePlanSHA256':NATIVE_NORMALS[scenario][1],'normalNativeReceiptSHA256':NATIVE_NORMALS[scenario][2],'consumedImports':consumed,'pins':{str(p):N.sha(p) for p in sorted(files)},'stage':str(stage),'inventory':inventory,'tools':tools,'resources':old['resources'],'environment':str(private),'environmentSHA256':N.sha(private),'configurationStates':N.current_configs(out,stage,tools,env),'executionProbeLabels':labels,'expectedProbeCount':len(labels),'commands':[{'label':'emit-c','argv':prefix+[tools['tools']['bend'],str(target),'-o',str(c)],'seconds':30,'generated':str(c)},{'label':'clang','argv':prefix+[tools['tools']['clang_wrapper'],'-O3',str(c),'-o',str(binary),'-pthread','-lm'],'seconds':120,'generated':str(binary)},{'label':'consumer','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5}]}
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
     assert result['stderr']==b'';validation=N.load(M/'models'/p['scenario']/'validate.py','cleanup_complete_mutant_validator');observed=validation.validate(result['stdout']);normal=N.load(H/'models'/p['scenario']/'model.py','independent_normal_model').expected();assert observed!=normal;r['witnesses']=[{'schema':schema,'world':world,'label':row['label'],'expectedNormal':normal[schema]['worlds'][world][i]['fields']['componentClock'],'actualMutant':row['fields']['componentClock']} for schema in ['A','B'] for world in ['A','B'] for i,row in enumerate(observed[schema]['worlds'][world]) if row['fields']['componentClock']!=normal[schema]['worlds'][world][i]['fields']['componentClock']];assert len(r['witnesses'])==6 and {w['schema'] for w in r['witnesses']}=={'A','B'};r['completeWorldRows']=SCENARIOS[p['scenario']][1];r['completeInstanceRecords']=SCENARIOS[p['scenario']][2]
   assert ledger.index==p['expectedProbeCount']
   r['status']='ACTUAL_CURRENT_WORLD_ACCEPTED_CLOCK_MUTANT_'+p['scenario'].upper().replace('-','_')+'_FULL_NATIVE_VARIANT_ORACLE_AND_BOTH_SCHEMA_WITNESSES_PASS_NO_ADOPTION'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--scenario',choices=list(SCENARIOS));parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare(args.scenario)
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
