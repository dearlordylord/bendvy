"""Bounded development source feasibility only; no acceptance/proof credit."""
import fcntl,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[2]
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(R/'scripts/task_runner.py','control_source_runner');L=load(R/'scripts/receipt-logs.py','control_source_logs')
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def closure(p,files):
 p=p.resolve()
 if p in files:return
 files.add(p)
 for name in re.findall(r'^\s*import\s+(\S+)',p.read_text(),re.M):
  if name!='Base' and not name.startswith(chr(34)):closure(p.parent/name,files)
if len(sys.argv)==1:
 out=H/'development'/('foreign-consumer-cheap-'+str(time.time_ns()));stage=out/'stage';stage.mkdir(parents=True)
 entries={'foreign':H/'full-foreign-controls.bend'};files=set()
 for entry in entries.values():closure(entry,files)
 for source in files:
  target=stage/source.relative_to(R);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)
 prior=json.loads((H/'development/foreign-authority-source-1791406441952311812/plan.json').read_text());prefix=prior['commands'][0]['argv'][:-2]
 files.update([Path(prefix[0]).resolve(),Path(prefix[-1]).resolve(),Path('/home/node/.bend/bend2/base.bend'),Path(__file__).resolve(),R/'scripts/task_runner.py',R/'scripts/receipt-logs.py'])
 env=out/'private-environment.json';env.write_text(json.dumps(dict(os.environ,BEND_NO_TELEMETRY='1'),sort_keys=True));env.chmod(0o600)
 generated=out/'foreign.mjs';consumer=H/'full-foreign-consumer.mjs';oracle=H/'full-foreign-expected.json';node=Path(shutil.which('node')).resolve()
 positive=H/'development/control-source-cheap-1791407861883379025';qualified=json.loads((positive/'receipt.json').read_text());positivePlan=json.loads((positive/'plan.json').read_text())
 assert qualified['status']=='AFFECTED_CONTROL_SOURCES_DEVELOPMENT_PASS_NO_ACCEPTANCE_CREDIT' and qualified['planSHA256']==sha(positive/'plan.json')
 assert all(sha(f)==digest for f,digest in positivePlan['pins'].items())
 assert inventory(Path(positivePlan['stage']))==positivePlan['inventory']
 assert all(sha(positive/n)==digest for n,digest in qualified['logs'].items())
 sourceJoin={str(source):sha(Path(positivePlan['stage'])/source.relative_to(R)) for source in files if source.suffix=='.bend' and source.is_relative_to(R)}
 assert all(sha(source)==digest for source,digest in sourceJoin.items())
 files.update([consumer,oracle,H/'full-foreign-oracle.py',node,positive/'plan.json',positive/'receipt.json',*[positive/n for n in qualified['logs']]])
 commands=[{'label':'emit','argv':prefix+[str(stage/entries['foreign'].relative_to(R)),'-o',str(generated)],'seconds':30},{'label':'consume','argv':[str(node),str(consumer),str(generated),str(oracle)],'seconds':5}]
 p={'status':'PREPARED_DEVELOPMENT_SOURCE_ONLY','pins':{str(f):sha(f) for f in sorted(files)},'stage':str(stage),'inventory':inventory(stage),'privateEnvironment':str(env),'environmentSHA256':sha(env),'commands':commands,'sourceReuseJoin':sourceJoin,'reusedSourceReceipt':str(positive/'receipt.json'),'reusedSourceReceiptSHA256':sha(positive/'receipt.json'),'lock':'/tmp/bendvy-parity-heavy.lock','scope':'Actual complete two-schema foreign registry consumer development check: reuse exact unchanged positive source receipt/stage closure; emit30 then Node5 comparing complete seven-row actual World/registry/cursor/Local/Invocation observations against independent full oracle. No sourcecheck/TS/full96 replay or probes. Source/Base/executables/environment frozen; no full resolver/acceptance/proof/performance credit. Final guarded foreign+negative cohort remains required.'}
 (out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
else:
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(sys.argv[1]).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory']
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),cwd=stage,env=json.loads(ep.read_text()),capture='split');generated={};r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'acceptanceQualified':False}
 try:
  for c in p['commands']:
   if '-o' in c['argv']:assert not Path(c['argv'][c['argv'].index('-o')+1]).exists()
   result=runner.run(c['label'],c['argv'],c['seconds'])
   if '-o' in c['argv']:
    target=c['argv'][c['argv'].index('-o')+1];generated[target]=sha(target);runner.inputs=T.Inputs(files=[path,ep,*p['pins'],*generated],directories=[stage])
   r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
  r['status']='COMPLETE_FOREIGN_TWO_SCHEMA_JS_DEVELOPMENT_PASS_NO_ACCEPTANCE_CREDIT'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:r['generated']=generated;r['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
