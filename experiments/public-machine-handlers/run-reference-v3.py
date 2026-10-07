"""Prospective narrow Node24 public-handler consumer, complete oracle, owned five-second stages."""
import hashlib,importlib.util,json,os,shutil,sys,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def inv(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(ROOT/'scripts/task_runner.py','handlers_task_runner');L=load(ROOT/'scripts/receipt-logs.py','handlers_logs');O=load(HERE/'oracle.py','handlers_oracle')
def env():return dict(os.environ,BEND_NO_TELEMETRY='1')
def digest(v):return hashlib.sha256(json.dumps(v,sort_keys=True).encode()).hexdigest()
def prepare():
 out=HERE/'evidence'/('reference-'+str(time.time_ns()));out.mkdir(parents=True);reference=ROOT/'.references/bevy-ts/packages/core/src';manifest=json.loads((ROOT/'.references/sources.json').read_text())['sources'];node=Path(shutil.which('node')).resolve();git=Path(shutil.which('git')).resolve();taskset=Path(shutil.which('taskset')).resolve();oracle=out/'expected.json';oracle.write_text(json.dumps(O.expected(),indent=2)+'\n')
 files=[Path(__file__),HERE/'oracle.py',HERE/'reference-v3.mjs',oracle,ROOT/'.references/sources.json',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',node,git,taskset]
 commands=[{'label':'head-'+name,'argv':[str(git),'-C',str(ROOT/'.references'/name),'rev-parse','HEAD'],'seconds':5,'expectedCommit':record['commit']} for name,record in manifest.items()]
 commands.append({'label':'reference','argv':[str(taskset),'-c','7',str(node),str(HERE/'reference-v3.mjs')],'seconds':5})
 plan={'status':'PREPARED_UNADMITTED_HANDLER_REFERENCE','pins':{str(p.resolve()):sha(p) for p in files},'TSReference':str(reference),'TSInventory':inv(reference),'environmentSHA256':digest(env()),'commands':commands,'expected':str(oracle),'scope':'Actual Node24 built-in TS imports, two independently bound schemas,6failure positions8checkpoints each; complete world/streams/host-local observations. No dependency/Bend/law/performance approval. Installed ELF/library/loader qualification remains unperformed.'};p=out/'plan.json';p.write_text(json.dumps(plan,indent=2)+'\n');print(p);print(sha(p))
def command_receipt(label,command,result):
 return {'label':label,'argv':command,'seconds':5,**{k:v for k,v in result.items() if k not in ('stdout','stderr')},'stdoutSHA256':hashlib.sha256(result['stdout']).hexdigest(),'stderrSHA256':hashlib.sha256(result['stderr']).hexdigest()}
def execute(p):
 plan=json.loads(p.read_text());out=p.parent;environment=env();receipt={'status':'INCOMPLETE','planSHA256':sha(p),'commands':[],'scope':plan['scope']};logs=L.CommandLogs(out,[c['label'] for c in plan['commands']])
 def guard():
  assert all(sha(f)==h for f,h in plan['pins'].items());assert inv(Path(plan['TSReference']))==plan['TSInventory'];assert digest(environment)==plan['environmentSHA256'];logs.guard()
 guard();runner=T.Runner(logs,inputs=T.Inputs(files=[p,*plan['pins']],directories=[Path(plan['TSReference'])]),cwd=ROOT,env=environment,capture='split')
 try:
  for c in plan['commands']:
   guard();result=runner.run(c['label'],c['argv'],c['seconds']);receipt['commands'].append(command_receipt(c['label'],c['argv'],result));guard()
   if 'expectedCommit' in c:assert (out/(c['label']+'.stdout')).read_text().strip()==c['expectedCommit']
  actual=json.loads((out/'reference.stdout').read_text());receipt['comparison']=O.compare(actual);assert actual==json.loads(Path(plan['expected']).read_text());receipt['status']='ACTUAL_TS_HANDLER_FAILURE_RETRY_COMPLETE_OBSERVATIONS_PASS'
 except BaseException as e:
  receipt['status']='FAIL';receipt['error']=str(e)
  if hasattr(e,'result'):receipt['commands'].append(command_receipt(c['label'],c['argv'],e.result))
  raise
 finally:receipt['logs']=logs.hashes;(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
if __name__=='__main__':
 if len(sys.argv)==1:prepare()
 else:execute(Path(sys.argv[1]).resolve())
