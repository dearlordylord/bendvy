"""Fresh actually consumed generic cleanup complete JS scenario consumer; no timing or core adoption."""
import argparse, ast, fcntl, json, os, shutil, time, types
from pathlib import Path
V=Path(__file__).resolve().parent
H=V.parent.parent
HELPER=H.parents[1]/'native-controls-v1/run.py';N=types.ModuleType('cleanup_shared');N.__file__=str(HELPER)
body=HELPER.read_text();prefix=body.split('\nparser=argparse.ArgumentParser();')[0];assert len(prefix)<len(body)
exec(compile(prefix,str(HELPER),'exec'),N.__dict__)
ROOT=Path('/workspace/formal-proofs/bendvy')
NOTICE=H.parent/'known-notice.txt';NOTICE_SHA='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
SCENARIOS={'post-consumption':('experiments/public-machines/followup/stream-opt/cleanup-controls-v1/caller.bend',36,22),'failed-batch':('experiments/public-machines/followup/stream-opt/cleanup-controls-v1/failed-batch-v1/caller.bend',32,16)}

def consumed_imports(stage,entry,inventory):
 tree=ast.parse((V/'run-source.py').read_text());function=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='consumed_imports');module=ast.Module(body=[function],type_ignores=[]);namespace={'N':N,'Path':Path};exec(compile(module,str(V/'run-source.py'),'exec'),namespace);return namespace['consumed_imports'](stage,entry,inventory)

def prepare(scenario):
 assert scenario in SCENARIOS
 modeldir=H/'models'/scenario
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  toolplan=V.parent/'native-current-v1/native-post-consumption-1791477367734479656/plan.json';assert N.sha(toolplan)=='1175edf25840ba2e489d3d17420bafe158ff86f0c66778d5984c076e0632ce24'
  old=json.loads(toolplan.read_text());ep=Path(old['environment']);assert N.sha(ep)==old['environmentSHA256'];env=json.loads(ep.read_text());N.validate_node_environment(env);tools=old['tools'];assert tools['cpu']==8 and all(N.sha(n)==v for n,v in tools['pins'].items())
  assert N.sha(NOTICE)==NOTICE_SHA
  assert N.sha(V/'full-scene-source-proposal.json')=='d4faf779a974ef31d45ddb842ce75f544892359420e9eb54b5ac658a61d0ab71';spec=json.loads((V/'full-scene-source-proposal.json').read_text());origin=Path(spec['stage']);assert N.inventory(origin)==spec['inventory'];assert all(N.sha(n)==v for n,v in spec['modelsUnchanged'].items())
  entry=SCENARIOS[scenario][0];assert consumed_imports(origin,entry,spec['inventory'])==spec['consumedClosures'][entry]['files']
  resources={str(Path(n)):N.inventory(Path(n)) for n in tools['resource_roots']}
  out=V/('js-'+scenario+'-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(origin,stage);private=out/'environment.private.json';private.write_bytes(ep.read_bytes());os.chmod(private,0o600)
  files={Path(__file__),V/'run-source.py',V/'full-scene-source-proposal.json',V/'stage-v3-inventory.json',HELPER,N.BOUNDARY,N.T.IMPLEMENTATION,N.ROOT/'scripts/receipt-logs.py',N.ROOT/'scripts/owned-tool-pins.py',toolplan,ep,private,NOTICE,*map(Path,tools['pins']),*map(Path,spec['modelsUnchanged'])}
  files.update(f for f in (H/'model-root').rglob('*') if f.is_file() and f.suffix in ['.py','.bend','.json'])
  files.update(f for f in (V/'development-checks').glob('*') if f.is_file())
  failed=V/'factory-source-1791480514303878539';assert N.sha(failed/'plan.json')=='e475ff21995438795092df44b7533c111cdc53947290c36434d6b38082dbe69b' and N.sha(failed/'receipt.json')=='fd0ba585f74678ae68801990b30510a29d1c4d433ed2157e89fbec0870a0f245'
  fr=json.loads((failed/'receipt.json').read_text());assert all(N.sha(failed/n)==v for n,v in fr['logs'].items());files.update({failed/'plan.json',failed/'receipt.json'});files.update(failed/n for n in fr['logs']);files.update(f for f in (failed/'stage').rglob('*') if f.is_file())
  model=N.load(modeldir/'model.py','cleanup_author_oracle');assert json.loads((modeldir/'expected.json').read_text())==model.expected()
  active=[k for k in tools['tools'] if k not in tools['skip_ldd']];labels=['guard-'+str(i)+'-ldd-'+k for i in range(5) for k in active];assert len(labels)==35
  target=stage/entry;assert target.is_file() and N.sha(target)==spec['inventory'][entry];consumed=consumed_imports(stage,entry,spec['inventory']);assert 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/system-cleanup.bend' in consumed and 'experiments/public-machines/reader-factory.bend' in consumed
  generated=out/'application.js';assert not generated.exists();prefix=[tools['taskset'],'-c','8']
  plan={'scenario':scenario,'scope':'Fresh complete ordinary factory scene JS normal only; actual Managed registration/invoke/disposal consumed. Source development named template check0 and full-scene FFI boundaries only, no safeproof. Full model unchanged, actual publickernel counterfactual remains separately required. No Native/performance/adoption transfer.','consumedImports':consumed,'pins':{str(n):N.sha(n) for n in sorted(files)},'stage':str(stage),'inventory':spec['inventory'],'tools':tools,'resources':resources,'environment':str(private),'environmentSHA256':N.sha(private),'configurationStates':N.diagnostic_configs(out,stage,tools,env),'executionProbeLabels':labels,'expectedProbeCount':35,'commands':[{'label':'emit-js','argv':prefix+[tools['tools']['bend'],str(target),'-o',str(generated)],'seconds':30,'generated':str(generated)},{'label':'consumer','argv':prefix+[tools['tools']['node'],str(generated)],'seconds':5}]}
  (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json');print(N.sha(out/'plan.json'))
def run(path,admitted):
 with open('/tmp/bendvy-parity-heavy.lock','w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);env=None;logs=None;ledger=None;runner=None;generated={}
  assert not (out/'receipt.json').exists()
  r={'planSHA256':admitted,'scope':p['scope'],'commands':[]}
  def sourceguard():
   assert N.sha(path)==admitted and N.sha(p['environment'])==p['environmentSHA256'] and N.sha(NOTICE)==NOTICE_SHA
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
    with N.E.GuardBoundary([('generated input registration',register_generated),('raw logs',rawguard),('source/tool/config guard',guard)]):
     try:
      if c.get('generated'):assert not Path(c['generated']).exists()
      result=runner.run(c['label'],c['argv'],c['seconds'],expected=0)
     except BaseException as error:
      attempt.update(status='FAILED',exception=type(error).__name__+': '+str(error))
      if hasattr(error,'result'):attempt.update({k:v for k,v in error.result.items() if k not in ['stdout','stderr']})
      attempt['rawSHA256']=dict(logs.hashes)
      raise
     attempt.update({k:v for k,v in result.items() if k not in ['stdout','stderr']});attempt['status']='TERMINAL';attempt['rawSHA256']=dict(logs.hashes)
     if c['label']=='emit-js':assert result['stdout']==b'' and result['stderr'] in [b'',NOTICE.read_bytes()]
     else:
      assert result['stderr']==b'';validation=N.load(H/'models'/p['scenario']/'validate.py','cleanup_complete_validator');validation.validate(result['stdout']);r['completeWorldRows']=SCENARIOS[p['scenario']][1];r['completeInstanceRecords']=SCENARIOS[p['scenario']][2]
    if c.get('generated'):assert c['generated'] in generated
   assert ledger.index==p['expectedProbeCount']
   r['status']='COMPLETE_ORDINARY_FACTORY_CLEANUP_'+p['scenario'].upper().replace('-','_')+'_FULL_JS_ORACLE_PASS_NO_ISSUE_CLOSURE'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--scenario',choices=list(SCENARIOS));parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare(args.scenario)
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
