"""Only current normal consumers: source checks and complete JS oracles first."""
from pathlib import Path
import argparse,hashlib,json,os,re,runpy,shutil,sys,time
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'scripts'));import task_runner
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
ENTRIES={'lifetime':HERE/'query-lifetime/query-owned.bend','cleanup':HERE/'cleanup-owned.bend','large':HERE/'large-owned.bend'}
def closure(p,files):
 p=p.resolve()
 if p in files:return
 files.add(p)
 for n in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
  if n!='Base':closure(p.parent/n,files)
def prepare():
 out=ROOT/'.artifacts'/('relations-current-normal-cheap-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();files=set()
 for entry in ENTRIES.values():closure(entry,files)
 for p in files:
  target=stage/p.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,target)
 files.update([Path(__file__).resolve(),HERE/'current-normal-controls-oracles.json',HERE/'current-normal-controls-oracles.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py']);files.update(Path(shutil.which(n)).resolve() for n in ['bend','node','taskset']);env=dict(os.environ,BEND_NO_TELEMETRY='1');envfile=out/'private-environment.json';envfile.write_text(json.dumps(env,sort_keys=True));envfile.chmod(0o600);directories=[Path('/home/node/.bend/bend2'),stage];inputs=task_runner.Inputs(files=files,directories=directories);commands=[]
 for name,entry in ENTRIES.items():
  staged=stage/entry.relative_to(ROOT);js=out/(name+'.js');commands.extend([{'label':name+'-check','argv':['taskset','-c','5','bend',str(staged),'--check-only'],'seconds':5},{'label':name+'-emit','argv':['taskset','-c','5','bend',str(staged),'-o',str(js)],'seconds':30,'generated':str(js)},{'label':name+'-js','argv':['taskset','-c','5','node',str(js)],'seconds':5,'oracle':name}])
 p={'files':list(map(str,sorted(files))),'directories':list(map(str,directories)),'inputs':inputs.expected,'environmentSHA256':sha(envfile),'privateEnvironment':str(envfile),'commands':commands,'scope':'Current normal lifetime66shapes/retained snapshots, cleanup36records bound219, large131072carrier. Cheap complete JS only, no legacy mutants/tool/Native/performance/production acceptance.'};(out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();out=path.parent;p=json.loads(path.read_text());envfile=Path(p['privateEnvironment']);assert sha(envfile)==p['environmentSHA256'];env=json.loads(envfile.read_text());inputs=task_runner.Inputs(files=p['files'],directories=list(map(Path,p['directories'])));assert inputs.expected==p['inputs'];logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](out,[c['label'] for c in p['commands']]);runner=task_runner.Runner(logs,inputs=inputs,env=env,cwd=Path(p['directories'][-1]));oracle=json.loads((HERE/'current-normal-controls-oracles.json').read_text())['outputs'];r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]};generated={}
 try:
  for c in p['commands']:
   assert sha(envfile)==p['environmentSHA256'];assert all(sha(f)==h for f,h in generated.items())
   if 'generated' in c:assert not Path(c['generated']).exists()
   x=runner.run(c['label'],c['argv'],c['seconds']);r['commands'].append({'label':c['label'],'exit':x['exit'],'failure':x['failure']});assert x['exit']==0 and x['failure'] is None
   if 'generated' in c:generated[c['generated']]=sha(c['generated']);runner.inputs=task_runner.Inputs(files=[*p['files'],*generated],directories=list(map(Path,p['directories'])))
   if 'oracle' in c:assert x['stdout'].decode()==oracle[c['oracle']],(c['label'],x['stdout'].decode(),oracle[c['oracle']])
   runner.inputs.guard();logs.guard()
  r['status']='CURRENT_NORMAL_LIFETIME_CLEANUP_LARGE_FULL_JS_ORACLE_PASS'
 except BaseException as e:r['error']=str(e);raise
 finally:r['generated']=generated;r['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');p.add_argument('--run');a=p.parse_args();prepare() if a.prepare else run(a.run)
