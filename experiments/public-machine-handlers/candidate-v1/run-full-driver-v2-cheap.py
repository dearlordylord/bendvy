"""Frozen development preflight; no full #49 acceptance or performance claim."""
import hashlib,importlib.util,json,os,shutil,sys,time,fcntl
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[2]
REFERENCE=Path("/workspace/formal-proofs/bendvy/experiments/public-machine-handlers/reference.mjs")
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(R/'scripts/task_runner.py','handler_fixture_runner');L=load(R/'scripts/receipt-logs.py','handler_fixture_logs')
def inventory(p):return {str(x.relative_to(p)):sha(x) for x in p.rglob('*') if x.is_file()}
if len(sys.argv)==1:
 out=H/'development'/('driver-v2-cheap-'+str(time.time_ns()));stage=out/'stage';target=stage/'experiments/public-machine-handlers/candidate-v1';target.mkdir(parents=True)
 for p in H.glob('*.bend'):shutil.copy2(p,target/p.name)
 shutil.copytree(R/'src/ecs',stage/'src/ecs');machines=stage/'experiments/public-machines';machines.mkdir(parents=True)
 for p in (R/'experiments/public-machines').glob('*.bend'):shutil.copy2(p,machines/p.name)
 for n in ['full-driver-v2-consumer.mjs','full-expected.json','full-oracle.py']:shutil.copy2(H/n,target/n)
 env=dict(os.environ,BEND_NO_TELEMETRY='1');ep=out/'private-environment.json';ep.write_text(json.dumps(env,sort_keys=True));ep.chmod(0o600)
 files=[H/'full-main.bend',H/'full-readers.bend',H/'full-marker.bend',H/'full-query.bend',H/'full-steps.bend',REFERENCE,R/'.references/sources.json',Path(__file__),H/'PLAN.md',H/'full-driver-v2.bend',H/'full-actions.bend',H/'full-locals.bend',H/'full-context.bend',H/'full-provider.bend',H/'full-observe.bend',H/'full-driver-v2-consumer.mjs',H/'full-oracle.py',H/'full-expected.json',R/'scripts/task_runner.py',R/'scripts/receipt-logs.py',Path(shutil.which('bend')).resolve(),Path(shutil.which('node')).resolve(),Path('/home/node/.bend/bend2/base.bend')]
 reference=REFERENCE
 for p in (R/'.references/bevy-ts/packages/core/src').rglob('*.ts'):files.append(p)
 generated=out/'full-driver-v2.mjs';source=target/'full-driver-v2.bend'
 plan={'lock':'/tmp/bendvy-parity-heavy.lock','status':'PREPARED_BOUNDED_CONSUMER','pins':{str(p.resolve()):sha(p) for p in files},'stage':str(stage),'inventory':inventory(stage),'privateEnvironment':str(ep),'environmentSHA256':sha(ep),'commands':[{'label':'source-check','argv':[shutil.which('bend'),str(source),'--check-only'],'seconds':5},{'label':'emit','argv':[shutil.which('bend'),str(source),'-o',str(generated)],'seconds':30},{'label':'consume','argv':[shutil.which('node'),str(target/'full-driver-v2-consumer.mjs'),str(generated),str(target/'full-expected.json'),],'seconds':5}],'scope':'12 actual nominal-schema/failure-position applications × eight complete physical checkpoints + 12 actual pre-frame requirement-union refusals. Changed runtime descriptor IO driver; same actual registered callbacks/core. Node checks all96 complete physical checkpoint literals plus12 refusal literals against unchanged independent oracle. Previously qualified actual selected TS is historical semantic evidence, not re-executed. No Native/negatives/mutants/performance/production or completeIssue49 acceptance.'};p=out/'plan.json';p.write_text(json.dumps(plan,indent=2)+'\n');print(p);print(sha(p))
else:
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 p=Path(sys.argv[1]).resolve();plan=json.loads(p.read_text());out=p.parent;stage=Path(plan['stage']);ep=Path(plan['privateEnvironment']);assert sha(ep)==plan['environmentSHA256'];env=json.loads(ep.read_text())
 assert all(sha(f)==h for f,h in plan['pins'].items());assert inventory(stage)==plan['inventory'];logs=L.CommandLogs(out,[c['label'] for c in plan['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[p,ep,*plan['pins']],directories=[stage]),cwd=R,env=env,capture='split');receipt={'status':'INCOMPLETE','planSHA256':sha(p),'scope':plan['scope'],'commands':[],'completeIssue49':False,'performanceQualified':False}
 try:
  for c in plan['commands']:
   q=runner.run(c['label'],c['argv'],c['seconds']);receipt['commands'].append({k:v for k,v in q.items() if k not in ('stdout','stderr')})
  receipt['status']='FULL96_AND12_RUNTIME_DRIVER_JS_DEVELOPMENT_PASS'
 except BaseException as e:
  receipt['status']='FAIL';receipt['error']=str(e)
  if hasattr(e,'result'):receipt['commands'].append({k:v for k,v in e.result.items() if k not in ('stdout','stderr')})
  raise
 finally:receipt['logs']=logs.hashes;receipt['generated']={str(x):sha(x) for x in out.glob('*.mjs')};(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
