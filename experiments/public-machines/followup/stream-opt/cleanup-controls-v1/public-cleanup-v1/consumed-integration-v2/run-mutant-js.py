"""Actual accepted-adapter clock defect complete JS counterfactual; no timing or core adoption."""
import argparse, ast, fcntl, json, os, shutil, time, types
from pathlib import Path
H=Path(__file__).resolve().parent.parent
V=Path(__file__).resolve().parent
M=V/'mutation-clock-v2'
HELPER=H.parents[1]/'native-controls-v1/run.py';N=types.ModuleType('cleanup_shared');N.__file__=str(HELPER)
body=HELPER.read_text();prefix=body.split('\nparser=argparse.ArgumentParser();')[0];assert len(prefix)<len(body)
exec(compile(prefix,str(HELPER),'exec'),N.__dict__)
ROOT=Path('/workspace/formal-proofs/bendvy')
SOURCE=M/'bridge-source-1791474452154689141'
SOURCE_PLAN='a63315f310c1588c54dddf0dd4daab65015ce8b9891e64eab5a1fc66498b2a5d'
SOURCE_RECEIPT='be2e4a741439e8dbae4006d0e22897fe3be89412939afe04365f20d149d93541'
NOTICE=H.parent/'known-notice.txt';NOTICE_SHA='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
SCENARIOS={'post-consumption':('experiments/public-machines/followup/stream-opt/cleanup-controls-v1/caller.bend',36,22),'failed-batch':('experiments/public-machines/followup/stream-opt/cleanup-controls-v1/failed-batch-v1/caller.bend',32,16)}

def consumed_imports(stage,entry,inventory):
 tree=ast.parse((V/'run-source.py').read_text());function=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='consumed_imports');module=ast.Module(body=[function],type_ignores=[]);namespace={'N':N,'Path':Path};exec(compile(module,str(V/'run-source.py'),'exec'),namespace);return namespace['consumed_imports'](stage,entry,inventory)

def source_prerequisite():
 assert N.sha(SOURCE/'plan.json')==SOURCE_PLAN and N.sha(SOURCE/'receipt.json')==SOURCE_RECEIPT
 old=json.loads((SOURCE/'plan.json').read_text());r=json.loads((SOURCE/'receipt.json').read_text())
 assert r['status']=='MATCHED_ACTUAL_ADAPTER_CLOCK_MUTANT_NAMED_BRIDGE_RAW_COLLECTED_NO_FULL_SOURCE_RUNTIME_PROOF_ACCEPTANCE' and not r.get('guardFailures',[]) and len(r['commands'])==1 and len(old['commands'])==1
 assert set(r['logs'])=={'source-0.stdout','source-0.stderr'}
 c=old['commands'][0];actual=r['commands'][0];assert actual['argv']==c['argv'] and actual['seconds']==5 and actual['label']==c['label'] and actual['failure'] is None and actual['exit']==0
 assert actual['runnerSHA256']==N.sha(N.T.IMPLEMENTATION)
 for name,digest in r['logs'].items():assert N.sha(SOURCE/name)==digest
 assert (SOURCE/'source-0.stdout').read_bytes()==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and (SOURCE/'source-0.stderr').read_bytes()==b''
 assert N.inventory(Path(old['stage']))==old['inventory'] and all(N.sha(p)==v for p,v in old['pins'].items())
 return old


NORMALS={'post-consumption':('js-post-consumption-1791474240852091648','9275c0a7806305441bf164f2c9182202d63de46fc512a30e1c84c4d8fd6cd542','21626d9e62314f31e27707dcc69dbb9cef4c8f550ffa0123f08364f2aaa8a1b3'),'failed-batch':('js-failed-batch-1791474296271509351','5163c40ea803a9d8e642e40b4ca62ff9cbbcc408e1decf0c1de83eb9cef6f201','8590c4c2c73e3ffb18166b8efe19ffa3804a66f4917b73255ce81dd8d406d8c9')}
def normal_prerequisite(scenario):
 folder,ps,rs=NORMALS[scenario];root=V/folder;assert N.sha(root/'plan.json')==ps and N.sha(root/'receipt.json')==rs
 p=json.loads((root/'plan.json').read_text());r=json.loads((root/'receipt.json').read_text());assert r['planSHA256']==ps and r['status']=='COMPLETE_GENERIC_CLEANUP_'+scenario.upper().replace('-','_')+'_FULL_JS_ORACLE_PASS_NO_ISSUE_CLOSURE' and not r.get('guardFailures',[])
 assert len(p['commands'])==len(r['commands'])==2 and [c['label'] for c in p['commands']]==['emit-js','consumer'] and [c['seconds'] for c in p['commands']]==[30,5]
 for c,a in zip(p['commands'],r['commands']):
  assert a['argv']==c['argv'] and a['seconds']==c['seconds'] and a['label']==c['label'] and a['exit']==0 and a['failure'] is None and a['runnerSHA256']==N.sha(N.T.IMPLEMENTATION)
 assert set(r['logs'])=={label+'.'+ext for label in ['emit-js','consumer'] for ext in ['stdout','stderr']} and all(N.sha(root/n)==v for n,v in r['logs'].items())
 assert (root/'emit-js.stdout').read_bytes()==b'' and (root/'emit-js.stderr').read_bytes() in [b'',NOTICE.read_bytes()] and (root/'consumer.stderr').read_bytes()==b''
 assert set(r['generated'])=={p['commands'][0]['generated']} and all(N.sha(n)==v for n,v in r['generated'].items())
 assert all(N.sha(n)==v for n,v in p['pins'].items()) and N.inventory(Path(p['stage']))==p['inventory']
 labels=p['executionProbeLabels'];assert len(labels)==r['probeCommandsExecuted']==p['expectedProbeCount']==35
 members={label+'.'+ext for label in labels for ext in ['json','stdout','stderr']};assert set(r['probePins'])=={str(root/'execution-probes'/n) for n in members} and members=={x.name for x in (root/'execution-probes').iterdir()}
 for n,v in r['probePins'].items():assert N.sha(Path(n))==v
 for label in labels:
  q=json.loads((root/'execution-probes'/(label+'.json')).read_text());key=label.split('-ldd-',1)[1];assert q['argv']==[p['tools']['taskset'],'-c','8',p['tools']['ldd'],p['tools']['tools'][key]] and q['seconds']==5 and q['exit']==0 and q['failure'] is None and q.get('exception') is None and q['runnerSHA256']==N.sha(N.T.IMPLEMENTATION)
 N.load(H/'models'/scenario/'validate.py','qualified_normal_full_oracle').validate((root/'consumer.stdout').read_bytes())
 return root,p,r

def prepare(scenario):
 assert scenario in SCENARIOS
 modeldir=M/'models'/scenario
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  old=source_prerequisite();assert N.sha(NOTICE)==NOTICE_SHA
  normalroot,np,nr=normal_prerequisite(scenario)
  ep=Path(old['environment']);assert N.sha(ep)==old['environmentSHA256'];env=json.loads(ep.read_text());N.validate_node_environment(env)
  assert N.diagnostic_configs(SOURCE,Path(old['stage']),old['tools'],env)==old['configurationStates']
  tools=old['tools'];tools=json.loads(json.dumps(tools));tools['cpu']=8
  # Hash/resource reuse only. Current CPU8 ordinary guards requalify binaries;
  # no CPU7 command/raw qualification is rewritten or credited as CPU8 evidence.
  assert all(N.sha(p)==s for p,s in tools['pins'].items())
  resources={str(Path(p)):N.inventory(Path(p)) for p in tools['resource_roots']}
  out=M/('js-'+scenario+'-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage)
  private=out/'environment.private.json';private.write_bytes(ep.read_bytes());os.chmod(private,0o600)
  files={Path(p) for p in old['pins']}|{SOURCE/'plan.json',SOURCE/'receipt.json',Path(__file__),private,NOTICE,M/'runtime-js-direction.json',M/'proposal.json',M/'models-direction.json',M/'model.py',M/'source-classification.json',V/'consumed-route.json',V/'proposal.json',V/'source-classification.json',H/'models-direction.json',H/'source-classification.json'}
  raw=json.loads((SOURCE/'receipt.json').read_text());files.update(SOURCE/n for n in raw['logs'])
  files.update({normalroot/'plan.json',normalroot/'receipt.json'});files.update(map(Path,np['pins']));files.update(map(Path,nr['generated']));files.update(normalroot/n for n in nr['logs']);files.update(map(Path,nr['probePins']))
  mutation_spec=json.loads((M/'models-direction.json').read_text());assert all(N.sha(H/n)==v for n,v in mutation_spec['files'].items());files.update(H/n for n in mutation_spec['files']);files.add(M/'model.py')
  spec=json.loads((H/'models-direction.json').read_text());assert all(N.sha(H/n)==digest for n,digest in spec['files'].items());files.update(H/n for n in spec['files'])
  assert all(p.is_file() for p in files)
  model=N.load(modeldir/'model.py','cleanup_author_oracle');assert json.loads((modeldir/'expected.json').read_text())==model.expected()
  active=[k for k in tools['tools'] if k not in tools['skip_ldd']]
  labels=['guard-'+str(i)+'-ldd-'+k for i in range(5) for k in active]
  commandprefix=[tools['taskset'],'-c','8'];generated=out/'application.js';target=stage/SCENARIOS[scenario][0];assert target.is_file() and N.sha(target)==old['inventory'][SCENARIOS[scenario][0]]
  consumed=consumed_imports(stage,SCENARIOS[scenario][0],N.inventory(stage));assert 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/adapter.bend' in consumed
  files.add(V/'run-source.py')
  plan={'normalPlanSHA256':NORMALS[scenario][1],'normalReceiptSHA256':NORMALS[scenario][2],'consumedImports':consumed,'scenario':scenario,'scope':'Two actual accepted-adapter clock mutation JS commands; matched complete normal actualcombinedmain qualified; named mutated template typing only and full main source deadline retained; complete independent variant scenario oracle and strict bothschema changed-clock witnesses. No timing/Native/core adoption/proof','sourcePlanSHA256':SOURCE_PLAN,'sourceReceiptSHA256':SOURCE_RECEIPT,'pins':{str(p):N.sha(p) for p in sorted(files)},'stage':str(stage),'inventory':N.inventory(stage),'tools':tools,'resources':resources,'cpuAssociation':'Historical installed hashes reused; freshCPU8 ordinary guards, no oldCPU7 raw credit','environment':str(private),'environmentSHA256':N.sha(private),'configurationStates':N.diagnostic_configs(out,stage,tools,env),'executionProbeLabels':labels,'expectedProbeCount':len(labels),'commands':[{'label':'emit-js','argv':commandprefix+[tools['tools']['bend'],str(target),'-o',str(generated)],'seconds':30,'generated':str(generated)},{'label':'consumer','argv':commandprefix+[tools['tools']['node'],str(generated)],'seconds':5}]}
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
    if c['label']=='emit-js':assert result['stdout']==b'' and result['stderr'] in [b'',NOTICE.read_bytes()] and c['generated'] in generated
    else:
     assert result['stderr']==b'';validation=N.load(M/'models'/p['scenario']/'validate.py','cleanup_complete_mutant_validator');observed=validation.validate(result['stdout']);normal=N.load(H/'models'/p['scenario']/'model.py','independent_normal_model').expected();assert observed!=normal;r['witnesses']=[{'schema':schema,'world':world,'label':row['label'],'expectedNormal':normal[schema]['worlds'][world][i]['fields']['componentClock'],'actualMutant':row['fields']['componentClock']} for schema in ['A','B'] for world in ['A','B'] for i,row in enumerate(observed[schema]['worlds'][world]) if row['fields']['componentClock']!=normal[schema]['worlds'][world][i]['fields']['componentClock']];assert len(r['witnesses'])==6 and {w['schema'] for w in r['witnesses']}=={'A','B'};r['completeWorldRows']=SCENARIOS[p['scenario']][1];r['completeInstanceRecords']=SCENARIOS[p['scenario']][2]
   assert ledger.index==p['expectedProbeCount']
   r['status']='ACTUAL_ADAPTER_ACCEPTED_CLOCK_MUTANT_'+p['scenario'].upper().replace('-','_')+'_FULL_JS_VARIANT_ORACLE_AND_BOTH_SCHEMA_WITNESSES_PASS_NO_NATIVE_ADOPTION'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--scenario',choices=list(SCENARIOS));parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare(args.scenario)
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
