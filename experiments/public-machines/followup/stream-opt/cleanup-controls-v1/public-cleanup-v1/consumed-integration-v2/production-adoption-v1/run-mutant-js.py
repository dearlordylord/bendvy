"""Fresh actually consumed generic cleanup complete JS scenario consumer; no timing or core adoption."""
import argparse, ast, fcntl, json, os, shutil, time, types
from pathlib import Path
V=Path(__file__).resolve().parent
H=V.parent.parent
HELPER=H.parents[1]/'native-controls-v1/run.py';N=types.ModuleType('cleanup_shared');N.__file__=str(HELPER)
body=HELPER.read_text();prefix=body.split('\nparser=argparse.ArgumentParser();')[0];assert len(prefix)<len(body)
exec(compile(prefix,str(HELPER),'exec'),N.__dict__)
M=V.parent/'mutation-clock-v2'
ROOT=Path('/workspace/formal-proofs/bendvy')
NOTICE=H.parent/'known-notice.txt';NOTICE_SHA='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
SCENARIOS={'post-consumption':('experiments/public-machines/followup/stream-opt/cleanup-controls-v1/caller.bend',36,22),'failed-batch':('experiments/public-machines/followup/stream-opt/cleanup-controls-v1/failed-batch-v1/caller.bend',32,16)}

def consumed_imports(stage,entry,inventory):
 tree=ast.parse((V/'run-source.py').read_text());function=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='consumed_imports');module=ast.Module(body=[function],type_ignores=[]);namespace={'N':N,'Path':Path};exec(compile(module,str(V/'run-source.py'),'exec'),namespace);return namespace['consumed_imports'](stage,entry,inventory)

NORMALS={'post-consumption':('js-post-consumption-1791481324477388802','5deeab1afee75d5e051c4594d4569b35116421d2c7773ddf52b6ea273ef33007','19930cb274868ee05b7c6baac9b6c86778bfcd9d31149f117568ade2618f3d6e'),'failed-batch':('js-failed-batch-1791481425920288723','7b15329369010764567c1cdb2738a235e8f709aae711df84544eacf923a87f1d','3daee4a0c80d2b6eebe2fc480b0fb0af7bb6ffb783c1dce2031c0a0c2216317e')}
def normal_prerequisite(scenario):
 folder,ps,rs=NORMALS[scenario];root=V/folder;assert N.sha(root/'plan.json')==ps and N.sha(root/'receipt.json')==rs
 p=json.loads((root/'plan.json').read_text());r=json.loads((root/'receipt.json').read_text());assert r['planSHA256']==ps and r['status']=='COMPLETE_ORDINARY_FACTORY_CLEANUP_'+scenario.upper().replace('-','_')+'_FULL_JS_ORACLE_PASS_NO_ISSUE_CLOSURE' and not r.get('guardFailures',[])
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
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  toolplan=V.parent/'native-current-v1/native-post-consumption-1791477367734479656/plan.json';assert N.sha(toolplan)=='1175edf25840ba2e489d3d17420bafe158ff86f0c66778d5984c076e0632ce24'
  normalroot,normalplan,normalreceipt=normal_prerequisite(scenario);old=json.loads(toolplan.read_text());ep=Path(old['environment']);assert N.sha(ep)==old['environmentSHA256'];env=json.loads(ep.read_text());N.validate_node_environment(env);tools=old['tools'];assert tools['cpu']==8 and all(N.sha(n)==v for n,v in tools['pins'].items())
  assert N.sha(NOTICE)==NOTICE_SHA
  assert N.sha(V/'mutation-clock-v1/proposal.json')=='3f3cff90f8700cde9ff32a86184386649d653c943b498fb64022039795cd6078';mutation=json.loads((V/'mutation-clock-v1/proposal.json').read_text());assert N.sha(V/'full-scene-source-proposal.json')=='d4faf779a974ef31d45ddb842ce75f544892359420e9eb54b5ac658a61d0ab71';base=json.loads((V/'full-scene-source-proposal.json').read_text());spec=dict(base,stage=mutation['stage'],inventory=mutation['inventory']);origin=Path(spec['stage']);assert N.inventory(origin)==spec['inventory'];assert all(N.sha(n)==v for n,v in spec['modelsUnchanged'].items()) and all(N.sha(n)==v for n,v in mutation['independentModels'].items());assert set(spec['inventory'])==set(normalplan['inventory']);assert [n for n in spec['inventory'] if spec['inventory'][n]!=normalplan['inventory'][n]]==[mutation['soleChangedSource']]
  entry=SCENARIOS[scenario][0];assert consumed_imports(origin,entry,spec['inventory'])==spec['consumedClosures'][entry]['files']
  resources={str(Path(n)):N.inventory(Path(n)) for n in tools['resource_roots']}
  out=V/'mutation-clock-v1'/('js-'+scenario+'-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(origin,stage);private=out/'environment.private.json';private.write_bytes(ep.read_bytes());os.chmod(private,0o600)
  files={Path(__file__),V/'run-source.py',V/'full-scene-source-proposal.json',V/'stage-v3-inventory.json',HELPER,N.BOUNDARY,N.T.IMPLEMENTATION,N.ROOT/'scripts/receipt-logs.py',N.ROOT/'scripts/owned-tool-pins.py',toolplan,ep,private,NOTICE,*map(Path,tools['pins']),*map(Path,spec['modelsUnchanged'])}
  files.update({V/'mutation-clock-v1/proposal.json',normalroot/'plan.json',normalroot/'receipt.json'});files.update(map(Path,normalplan['pins']));files.update(normalroot/n for n in normalreceipt['logs']);files.update(map(Path,normalreceipt['probePins']));files.update(map(Path,normalreceipt['generated']));files.update(map(Path,mutation['independentModels']));files.update(f for f in (M/'models').rglob('*') if f.is_file() and f.suffix in ['.py','.json']);files.update(f for f in (H/'model-root').rglob('*') if f.is_file() and f.suffix in ['.py','.bend','.json'])
  files.update(f for f in (V/'development-checks').glob('*') if f.is_file())
  failed=V/'factory-source-1791480514303878539';assert N.sha(failed/'plan.json')=='e475ff21995438795092df44b7533c111cdc53947290c36434d6b38082dbe69b' and N.sha(failed/'receipt.json')=='fd0ba585f74678ae68801990b30510a29d1c4d433ed2157e89fbec0870a0f245'
  fr=json.loads((failed/'receipt.json').read_text());assert all(N.sha(failed/n)==v for n,v in fr['logs'].items());files.update({failed/'plan.json',failed/'receipt.json'});files.update(failed/n for n in fr['logs']);files.update(f for f in (failed/'stage').rglob('*') if f.is_file())
  model=N.load(modeldir/'model.py','cleanup_author_oracle');assert json.loads((modeldir/'expected.json').read_text())==model.expected()
  active=[k for k in tools['tools'] if k not in tools['skip_ldd']];labels=['guard-'+str(i)+'-ldd-'+k for i in range(5) for k in active];assert len(labels)==35
  target=stage/entry;assert target.is_file() and N.sha(target)==spec['inventory'][entry];consumed=consumed_imports(stage,entry,spec['inventory']);assert 'experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/system-cleanup.bend' in consumed and 'experiments/public-machines/reader-factory.bend' in consumed
  generated=out/'application.js';assert not generated.exists();prefix=[tools['taskset'],'-c','8']
  plan={'normalPlanSHA256':NORMALS[scenario][1],'normalReceiptSHA256':NORMALS[scenario][2],'scenario':scenario,'scope':'Fresh actual publickernel accepted-arm counterfactual for ordinary factory; exact qualified full normal and independently authored full variant/six bothschema clock witnesses. No safeproof/Native/performance/adoption transfer.','consumedImports':consumed,'pins':{str(n):N.sha(n) for n in sorted(files)},'stage':str(stage),'inventory':spec['inventory'],'tools':tools,'resources':resources,'environment':str(private),'environmentSHA256':N.sha(private),'configurationStates':N.diagnostic_configs(out,stage,tools,env),'executionProbeLabels':labels,'expectedProbeCount':35,'commands':[{'label':'emit-js','argv':prefix+[tools['tools']['bend'],str(target),'-o',str(generated)],'seconds':30,'generated':str(generated)},{'label':'consumer','argv':prefix+[tools['tools']['node'],str(generated)],'seconds':5}]}
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
      assert result['stderr']==b'';validation=N.load(M/'models'/p['scenario']/'validate.py','cleanup_complete_variant_validator');observed=validation.validate(result['stdout']);normal=N.load(H/'models'/p['scenario']/'model.py','independent_normal_model').expected();assert observed!=normal;r['witnesses']=[{'schema':schema,'world':world,'label':row['label'],'expectedNormal':normal[schema]['worlds'][world][i]['fields']['componentClock'],'actualMutant':row['fields']['componentClock']} for schema in ['A','B'] for world in ['A','B'] for i,row in enumerate(observed[schema]['worlds'][world]) if row['fields']['componentClock']!=normal[schema]['worlds'][world][i]['fields']['componentClock']];assert len(r['witnesses'])==6 and {w['schema'] for w in r['witnesses']}=={'A','B'};r['completeWorldRows']=SCENARIOS[p['scenario']][1];r['completeInstanceRecords']=SCENARIOS[p['scenario']][2]
    if c.get('generated'):assert c['generated'] in generated
   assert ledger.index==p['expectedProbeCount']
   r['status']='REACHED_ORDINARY_FACTORY_KERNEL_CLOCK_CONTROL_'+p['scenario'].upper().replace('-','_')+'_FULL_JS_ORACLE_PASS_NO_ISSUE_CLOSURE'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--scenario',choices=list(SCENARIOS));parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare(args.scenario)
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
