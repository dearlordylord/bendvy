"""One isolated exact named-parameter bridge typing root; RAW source only, no runtime."""
import argparse,fcntl,json,os,shutil,time,types
from pathlib import Path
V=Path(__file__).resolve().parent
H=V.parent.parent
HELPER=H.parents[1]/'native-controls-v1/run.py';N=types.ModuleType('generic_cleanup_source_guard');N.__file__=str(HELPER)
body=HELPER.read_text();prefix=body.split('\nparser=argparse.ArgumentParser();')[0];assert len(prefix)<len(body);exec(compile(prefix,str(HELPER),'exec'),N.__dict__)
def consumed_imports(stage,entry,inventory):
 stage=Path(stage).resolve();seen=set()
 def visit(relative):
  if relative in seen:return
  seen.add(relative);literal=stage/relative;assert literal.is_file();resolved=literal.resolve();assert resolved.is_relative_to(stage) and resolved==literal and N.sha(resolved)==inventory[relative]
  for line in resolved.read_text().splitlines():
   text=line.strip()
   if not text or text.startswith('#'):continue
   if not text.startswith('import '):break
   token=text.split()[1]
   if token=='Base':continue # Separately pinned installed Base resource closure.
   assert not token.startswith('/') and not token.startswith('@') and not token.startswith('0x')
   target=resolved.parent/token;assert target.is_file();target=target.resolve();assert target.is_relative_to(stage)
   child=str(target.relative_to(stage));assert N.sha(target)==inventory[child];visit(child)
 visit(entry);return sorted(seen)

def prepare():
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  normal=V.parent/'native-current-v1/native-post-consumption-1791477367734479656/plan.json'
  assert N.sha(normal)=='1175edf25840ba2e489d3d17420bafe158ff86f0c66778d5984c076e0632ce24'
  old=json.loads(normal.read_text());envpath=Path(old['environment']);assert N.sha(envpath)==old['environmentSHA256'];env=json.loads(envpath.read_text());tools=old['tools'];assert tools['cpu']==8 and all(N.sha(n)==v for n,v in tools['pins'].items())
  origin=V/'stage-v1';inventory=json.loads((V/'stage-inventory.json').read_text());assert N.inventory(origin)==inventory
  entry='experiments/public-machines/factory-caller.bend';consumed_imports(origin,entry,inventory)
  out=V/('factory-source-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(origin,stage);private=out/'environment.private.json';private.write_bytes(envpath.read_bytes());os.chmod(private,0o600)
  command={'label':'source-0','argv':[tools['taskset'],'-c','8',tools['tools']['bend'],str(stage/entry),'--check-only'],'seconds':5,'source':entry}
  assert Path(command['argv'][4]).is_file() and N.sha(command['argv'][4])==inventory[entry]
  files={Path(__file__),HELPER,N.BOUNDARY,N.T.IMPLEMENTATION,N.ROOT/'scripts/receipt-logs.py',N.ROOT/'scripts/owned-tool-pins.py',normal,envpath,private,*map(Path,tools['pins'])}
  files.update(V/n for n in ['system-cleanup.bend','system-instance.bend','reader-factory.bend','factory-caller.bend','stage-inventory.json','caller-source-joins.json','PROPOSAL.md','FACTORY-BINDING.md','source-joins.json'])
  p={'scope':'One named ordinary registration/invoke factory source5 RAW feasibility only; Unit main, no full-scene execution/runtime/proof/adoption. Zero resolver probes and no clocks. Full independent models retained unchanged; original Native failed control incomplete.','pins':{str(n):N.sha(n) for n in sorted(files)},'stage':str(stage),'inventory':inventory,'resources':old['resources'],'tools':tools,'environment':str(private),'environmentSHA256':N.sha(private),'configurationStates':N.diagnostic_configs(out,stage,tools,env),'commands':[command],'consumedImports':{entry:consumed_imports(stage,entry,inventory)}}
  assert all(N.inventory(Path(n))==v for n,v in p['resources'].items())
  (out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json');print(N.sha(out/'plan.json'))
def run(path,admitted):
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);env=None;logs=None;inputs=None;assert not(out/'receipt.json').exists();r={'planSHA256':admitted,'scope':p['scope'],'commands':[]}
  def guard():
   assert N.sha(path)==admitted and N.sha(p['environment'])==p['environmentSHA256'] and all(N.sha(n)==v for n,v in p['pins'].items()) and N.inventory(stage)==p['inventory'];assert all(N.inventory(Path(n))==v for n,v in p['resources'].items())
   assert {c['source']:consumed_imports(stage,c['source'],p['inventory']) for c in p['commands']}==p['consumedImports']
   if env is not None:assert N.diagnostic_configs(out,stage,p['tools'],env)==p['configurationStates']
   if inputs is not None:inputs.guard()
  def raw():
   if logs is not None:r['logs']=dict(logs.hashes);logs.guard()
  with N.E.ReceiptBoundary(r,out/'receipt.json',[('source/resource/config/env',guard),('raw logs',raw)]):
   guard();env=json.loads(Path(p['environment']).read_text());assert N.sha(p['environment'])==p['environmentSHA256'];guard();logs=N.L.CommandLogs(out,[c['label'] for c in p['commands']]);inputs=N.T.Inputs(files=[path,*p['pins']],directories=[stage]);runner=N.T.Runner(logs,inputs=inputs,env=env,cwd=stage,capture='split')
   for c in p['commands']:
    guard();attempt=dict(c,status='ATTEMPTED');r['commands'].append(attempt)
    with N.E.GuardBoundary([('source/resource/config/env',guard),('raw logs',raw)]):
     try:
      result=runner.run(c['label'],c['argv'],5,expected=None)
     except BaseException as error:
      attempt.update(status='FAILED',exception=type(error).__name__+': '+str(error))
      if hasattr(error,'result'):attempt.update({k:v for k,v in error.result.items() if k not in ['stdout','stderr']})
      if logs is not None:attempt['rawSHA256']=dict(logs.hashes)
      raise
     attempt.update({k:v for k,v in result.items() if k not in ['stdout','stderr']});attempt['status']='TERMINAL';attempt['rawSHA256']=dict(logs.hashes)
     assert result['exit'] in [0,1] and result['failure'] is None
   r['status']='NAMED_ORDINARY_FACTORY_SOURCE_RAW_COLLECTED_NO_FULL_SCENE_RUNTIME_ACCEPTANCE';r['diagnosticClassification']='RAW_UNCLASSIFIED_PENDING_FULL_INDEPENDENT_REVIEW'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare()
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
