"""One source-bound development TS consumer. External coordinator owns flock."""
import argparse,hashlib,importlib.util,json,os,shutil,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent
R=H.parents[2]
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
sys.dont_write_bytecode=True
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(R/'scripts/task_runner.py','task_runner')
L=load(R/'scripts/receipt-logs.py','receipt_logs')
def configuration():
 paths=set()
 for origin in [H,R,*[Path(p).parent for p in json.loads((H/'ts-cheap-proposal.json').read_text())['referenceClosure']]]:
  for parent in [origin,*origin.parents]:
   for name in ('package.json','tsconfig.json','.node-version','.nvmrc'):
    paths.add(parent/name)
 return {str(p):sha(p) if p.is_file() else None for p in sorted(paths)}
def prepare():
 proposal=json.loads((H/'ts-cheap-proposal.json').read_text());assert sha(H/'reference.mjs')==proposal['sourceSHA256'];assert sha(H/'expected-public.json')==proposal['commands'][0]['oracleSHA256']
 files={H/'reference.mjs',H/'expected-public.json',H/'ts-cheap-proposal.json',Path(__file__).resolve(),R/'scripts/task_runner.py',R/'scripts/receipt-logs.py'}
 for name,s in proposal['referenceClosure'].items():assert sha(name)==s;files.add(Path(name))
 node=Path(shutil.which('node')).resolve();taskset=Path(shutil.which('taskset')).resolve();files.update((node,taskset))
 configs=configuration();files.update(Path(p) for p,s in configs.items() if s is not None)
 pins={str(p):sha(p) for p in sorted(files)}
 out=R/'.artifacts'/('inspector-machine55-ts-cheap-'+str(time.time_ns()));out.mkdir()
 env=dict(os.environ)
 for name in ('NODE_OPTIONS','NODE_PATH','LD_PRELOAD','LD_LIBRARY_PATH'):env.pop(name,None)
 private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True)+'\n');private.chmod(0o600)
 assert {str(p):sha(p) for p in files}==pins and configuration()==configs
 plan={'pins':pins,'configuration':configs,'privateEnvironment':str(private),'environmentSHA256':sha(private),'command':{'label':'actual-ts','argv':[str(taskset),'-c','5',str(node),str(H/'reference.mjs')],'seconds':5},'oracle':str(H/'expected-public.json'),'scope':'One cheap actual TS complete18 public DTO development consumer; no fresh installed dependency resolver probe/runtime backend proof/performance/adoption. Executable bytes/config/source/env guarded; not closed library resolver qualification.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;private=Path(p['privateEnvironment']);env=json.loads(private.read_text());c=p['command'];logs=L.CommandLogs(out,[c['label']]);inputs=T.Inputs(files=[path,private,*p['pins']]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=R,capture='split');item={'label':c['label'],'argv':c['argv'],'seconds':c['seconds'],'exit':None,'failure':None};r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[item]}
 def guard():
  assert all(sha(n)==s for n,s in p['pins'].items());assert sha(private)==p['environmentSHA256'];assert configuration()==p['configuration'];inputs.guard();logs.guard()
 try:
  guard()
  primary=None
  try:
   result=runner.run(c['label'],c['argv'],c['seconds'],expected=None);item.update(exit=result['exit'],failure=result['failure'])
  except BaseException as error:
   failed=getattr(error,'result',None)
   if failed is not None:item.update(exit=failed['exit'],failure=failed['failure'])
   item['collectionError']=str(error);primary=error;raise
  finally:
   try:guard()
   except BaseException as error:
    r['postChildGuardError']=str(error);r['status']='INCOMPLETE'
    if primary is None:raise
  assert result['exit']==0 and result['failure'] is None and result['stderr']==b''
  actual=json.loads(result['stdout']);expected=json.loads(Path(p['oracle']).read_text());assert actual==expected and len(actual['observations'])==18
  r['status']='DEVELOPMENT_ACTUAL_TS_COMPLETE18_PASS_NOT_FULL55';r['observationCount']=18
 except BaseException as error:r['error']=str(error);raise
 finally:
  try:logs.guard()
  except BaseException as error:r['finalLogGuardError']=str(error);r['status']='INCOMPLETE'
  finally:
   r['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args();prepare() if args.prepare else run(args.run)
