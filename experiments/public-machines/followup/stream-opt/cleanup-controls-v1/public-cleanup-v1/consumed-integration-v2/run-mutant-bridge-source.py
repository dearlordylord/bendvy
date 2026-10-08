"""One matched actual-adapter accepted-clock mutant named bridge typing root; RAW source only, no runtime."""
import argparse,fcntl,json,os,shutil,time,types
from pathlib import Path
H=Path(__file__).resolve().parent.parent
V=Path(__file__).resolve().parent
M=V/'mutation-clock-v1'
HELPER=H.parents[1]/'native-controls-v1/run.py';N=types.ModuleType('generic_cleanup_source_guard');N.__file__=str(HELPER)
body=HELPER.read_text();prefix=body.split('\nparser=argparse.ArgumentParser();')[0];assert len(prefix)<len(body);exec(compile(prefix,str(HELPER),'exec'),N.__dict__)
NORMAL=H.parent/'failed-batch-v1/native-1791464060587256164/plan.json'
NORMAL_SHA='b57074e075c9cf7f06c260824062d9e3a9b4e8410111a9658fe9a190981c0ec0'

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
  assert N.sha(NORMAL)==NORMAL_SHA;old=json.loads(NORMAL.read_text());envpath=Path(old['environment']);assert N.sha(envpath)==old['environmentSHA256'];env=json.loads(envpath.read_text());tools=old['tools'];assert tools['cpu']==8 and all(N.sha(n)==v for n,v in tools['pins'].items())
  matched=V/'bridge-source-1791473372175098193';assert N.sha(matched/'plan.json')=='3d4dcdc27dd8b7100c07632fe47d3b8b92c5c0475015fe75a07c43a1f5552b64' and N.sha(matched/'receipt.json')=='4354d217e1b718c8afdcdba1e96464fcaa2d057aa6a6c2717e099091a40c32bb'
  mp=json.loads((matched/'plan.json').read_text());mr=json.loads((matched/'receipt.json').read_text());assert len(mr['commands'])==1 and mr['commands'][0]['exit']==0 and mr['commands'][0]['failure'] is None and not mr.get('guardFailures',[])
  assert set(mr['logs'])=={'source-0.stdout','source-0.stderr'} and all(N.sha(matched/n)==v for n,v in mr['logs'].items())
  assert (matched/'source-0.stdout').read_bytes()==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and (matched/'source-0.stderr').read_bytes()==b''
  assert all(N.sha(n)==v for n,v in mp['pins'].items()) and N.inventory(Path(mp['stage']))==mp['inventory']
  failed=V/'source-controls-1791472653210206664';assert N.sha(failed/'plan.json')=='ad5ccd1e38f56824b66112f80a9d5f2f4eb5e663043ad43a84895ab9f43a5265' and N.sha(failed/'receipt.json')=='df89c932ddc0ffa3a6708d78017eb123cef8a3198225db92fcd5eee1579cb021'
  prior=json.loads((failed/'plan.json').read_text());fr=json.loads((failed/'receipt.json').read_text());assert fr['status']=='INCOMPLETE' and not fr.get('guardFailures',[]) and len(fr['commands'])==1 and fr['commands'][0]['failure']=='child deadline' and fr['commands'][0]['exit'] is None
  assert set(fr['logs'])=={'source-0.stdout','source-0.stderr'} and all(N.sha(failed/n)==v for n,v in fr['logs'].items()) and all((failed/n).read_bytes()==b'' for n in fr['logs'])
  assert N.inventory(Path(prior['stage']))==prior['inventory'] and all(N.sha(n)==v for n,v in prior['pins'].items())
  spec=json.loads((M/'bridge-source-direction.json').read_text());origin=Path(spec['stage']);assert N.inventory(origin)==spec['inventory'];assert len(spec['subjects'])==1
  for n,v in spec['negativeFiles'].items():assert N.sha(H/n)==v
  joins=json.loads((H/'current-core-joins.json').read_text());assert all(N.sha(n)==v['sha256']==N.sha(v['copy']) for n,v in joins['files'].items())
  assert all(N.inventory(Path(n))==v for n,v in old['resources'].items())
  out=M/('bridge-source-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(origin,stage);private=out/'environment.private.json';private.write_bytes(envpath.read_bytes());os.chmod(private,0o600)
  commands=[{'label':'source-'+str(i),'argv':[tools['taskset'],'-c','8',tools['tools']['bend'],str(stage/n),'--check-only'],'seconds':5,'source':n} for i,n in enumerate(spec['subjects'])]
  assert all(Path(c['argv'][4]).is_file() and N.sha(c['argv'][4])==spec['inventory'][c['source']] for c in commands)
  consumed={c['source']:consumed_imports(stage,c['source'],spec['inventory']) for c in commands}
  files={Path(__file__),HELPER,N.BOUNDARY,N.T.IMPLEMENTATION,N.ROOT/'scripts/receipt-logs.py',N.ROOT/'scripts/owned-tool-pins.py',NORMAL,envpath,private,M/'bridge-source-direction.json',V/'proposal.json',H/'SCOPE-CORRECTION.md',H/'CONSUMED-CLOSURE-AUDIT.json',H/'fixture-relocation.json',H/'fixture-relocation-before-final-sha.json',H/'current-core-joins.json',H/'source-direction.json',H/'oracle-provenance.json',H/'post-consumption-expected.json',H/'failed-batch-expected.json',*map(Path,tools['pins']),*map(Path,joins['files'])}
  files.update({matched/'plan.json',matched/'receipt.json',V/'run-bridge-source.py',V/'source-classification.json',M/'proposal.json',M/'stage-joins.json',M/'bridge-typing-direction.json',M/'model.py',M/'adapter.bend',M/'post-consumption-expected.json',M/'failed-batch-expected.json'});files.update(matched/n for n in mr['logs']);files.update(map(Path,mp['pins']))
  files.update({failed/'plan.json',failed/'receipt.json',V/'bridge-typing-proposal.json',V/'bridge-typing.bend',V/'run-source.py'});files.update(failed/n for n in fr['logs']);files.update(map(Path,prior['pins']))
  files.add(H/'SCOPE-SOURCE-JOINS.json');files.update(H/x['copy'] for x in json.loads((H/'SCOPE-SOURCE-JOINS.json').read_text())['records'])
  files.update(Path(v['copy']) for v in joins['files'].values());files.update(H/n for n in spec['negativeFiles']);files.update(H/n for n in ['adapter.bend','ports.bend','caller.bend'])
  p={'scope':'One matched actual accepted-clock defect named-parameter bridge source5 RAW typing root only; prior full consumer deadline INCOMPLETE retained; zero resolver probes/runtime/proof/API adoption. Preserve historical baseline-only evidence; classify complete raw separately.','normalToolMetadataPlanSHA256':NORMAL_SHA,'pins':{str(n):N.sha(n) for n in sorted(files)},'stage':str(stage),'inventory':N.inventory(stage),'resources':old['resources'],'tools':tools,'environment':str(private),'environmentSHA256':N.sha(private),'configurationStates':N.diagnostic_configs(out,stage,tools,env),'commands':commands,'consumedImports':consumed}
  (out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json');print(N.sha(out/'plan.json'))
def run(path,admitted):
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);env=None;logs=None;inputs=None;assert not(out/'receipt.json').exists();r={'planSHA256':admitted,'scope':p['scope'],'commands':[]}
  def guard():
   assert N.sha(path)==admitted and all(N.sha(n)==v for n,v in p['pins'].items()) and N.inventory(stage)==p['inventory'];assert all(N.inventory(Path(n))==v for n,v in p['resources'].items())
   assert {c['source']:consumed_imports(stage,c['source'],p['inventory']) for c in p['commands']}==p['consumedImports']
   if env is not None:assert N.diagnostic_configs(out,stage,p['tools'],env)==p['configurationStates']
   if inputs is not None:inputs.guard()
  def raw():
   if logs is not None:r['logs']=dict(logs.hashes);logs.guard()
  with N.E.ReceiptBoundary(r,out/'receipt.json',[('source/resource/config/env',guard),('raw logs',raw)]):
   guard();env=json.loads(Path(p['environment']).read_text());assert N.sha(p['environment'])==p['environmentSHA256'];guard();logs=N.L.CommandLogs(out,[c['label'] for c in p['commands']]);inputs=N.T.Inputs(files=[path,*p['pins']],directories=[stage]);runner=N.T.Runner(logs,inputs=inputs,env=env,cwd=stage,capture='split')
   for c in p['commands']:
    guard();attempt=dict(c,status='ATTEMPTED');r['commands'].append(attempt)
    try:
     with N.E.GuardBoundary([('source/resource/config/env',guard),('raw logs',raw)]):result=runner.run(c['label'],c['argv'],5,expected=None)
    except BaseException as error:
     attempt.update(status='FAILED',exception=type(error).__name__+': '+str(error))
     if hasattr(error,'result'):attempt.update({k:v for k,v in error.result.items() if k not in ['stdout','stderr']})
     raise
    attempt.update({k:v for k,v in result.items() if k not in ['stdout','stderr']});attempt['status']='TERMINAL';assert result['exit'] in [0,1] and result['failure'] is None
   r['status']='MATCHED_ACTUAL_ADAPTER_CLOCK_MUTANT_NAMED_BRIDGE_RAW_COLLECTED_NO_FULL_SOURCE_RUNTIME_PROOF_ACCEPTANCE';r['diagnosticClassification']='RAW_UNCLASSIFIED_PENDING_FULL_INDEPENDENT_REVIEW'
  print(out);print(N.sha(out/'receipt.json'))
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--plan-sha256');args=parser.parse_args()
if args.prepare:prepare()
else:assert args.run and args.plan_sha256;run(args.run,args.plan_sha256)
