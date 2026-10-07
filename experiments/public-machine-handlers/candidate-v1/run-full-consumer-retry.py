"""Reuse exact retained emitted artifact after an adapter-only repair."""
import hashlib,importlib.util,json,os,shutil,sys,time,fcntl
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[2]
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(R/'scripts/task_runner.py','handler_fixture_rerun');L=load(R/'scripts/receipt-logs.py','handler_fixture_relogs');S=load(R/'scripts/selected_reference.py','handler_selected_reference')
if len(sys.argv)==2:
 binding=S.binding(R,R/'experiments/public-machine-handlers/delivery-manifest.json','experiments/public-machine-handlers/reference-v3.mjs')
 original=Path(sys.argv[1]).resolve();base=json.loads(original.read_text());out=H/'development'/('fixture-consumer-'+str(time.time_ns()));out.mkdir();envpath=Path(base['privateEnvironment']);stage=Path(base['stage']);generated=original.parent/'full.mjs';oldreceipt=original.parent/'receipt.json';rec=json.loads(oldreceipt.read_text());assert rec['commands'][0]['exit']==rec['commands'][1]['exit']==0
 assert {str(x.relative_to(stage)):sha(x) for x in stage.rglob('*') if x.is_file()}==base['inventory'];assert sha(generated)==rec['generated'][str(generated)]
 pins={str(p):sha(p) for p in [Path(__file__),original,oldreceipt,generated,envpath,H/'full-consumer.mjs',H/'full-expected.json',H/'full-oracle.py',R/'experiments/public-machine-handlers/reference-v3.mjs',R/'scripts/task_runner.py',R/'scripts/receipt-logs.py',R/'scripts/selected_reference.py',Path(binding['manifest']),Path(shutil.which('node')).resolve()]};pins.update({str(stage/x):h for x,h in base['inventory'].items()});pins.update({x:h for x,h in base['pins'].items() if x not in [str(H/'full-consumer.mjs'),str(H/'full-expected.json'),str(H/'full-oracle.py')]})
 plan={'selectedReference':binding,'status':'PREPARED_ADAPTER_ONLY_RERUN','pins':pins,'privateEnvironment':str(envpath),'argv':[shutil.which('node'),str(H/'full-consumer.mjs'),str(generated),str(H/'full-expected.json'),str(R/'experiments/public-machine-handlers/reference-v3.mjs')],'seconds':5,'scope':base['scope'],'originalPlan':str(original),'priorFailure':'Earlier attempts mistakenly selected failed initial reference.mjs, then partial correction. This retry executes exact tracked successful reference-v3.mjs SHA 88cd07b9d1b3c2568b616704449297c35300e09db439c42d7af3fa44a6ce61ca joined to retained actual TS plan/output; full oracle and generated Bend unchanged.'};p=out/'plan.json';p.write_text(json.dumps(plan,indent=2)+'\n');print(p);print(sha(p))
else:
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 p=Path(sys.argv[2]).resolve();plan=json.loads(p.read_text());assert all(sha(f)==h for f,h in plan['pins'].items());env=json.loads(Path(plan['privateEnvironment']).read_text());logs=L.CommandLogs(p.parent,['consume']);runner=T.Runner(logs,inputs=T.Inputs(files=[p,*plan['pins']]),cwd=R,env=env,capture='split');receipt={'status':'INCOMPLETE','planSHA256':sha(p),'scope':plan['scope'],'completeIssue49':False,'performanceQualified':False}
 try:
  S.verify(R,plan['selectedReference']);q=runner.run('consume',plan['argv'],5);S.verify(R,plan['selectedReference']);receipt['command']={k:v for k,v in q.items() if k not in ('stdout','stderr')};receipt['status']='FULL96_AND12_REQUIREMENT_JS_DEVELOPMENT_PASS'
 except BaseException as e:
  receipt.update(status='FAIL',error=str(e))
  if hasattr(e,'result'):receipt['command']={k:v for k,v in e.result.items() if k not in ('stdout','stderr')}
  raise
 finally:receipt['logs']=logs.hashes;(p.parent/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
