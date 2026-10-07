"""Cheap frozen complete resource consumer before broad installed-tool discovery."""
from pathlib import Path
import argparse,hashlib,json,os,re,runpy,shutil,sys,time
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'scripts'));import task_runner
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def closure(p,files):
 p=p.resolve()
 if p in files:return
 files.add(p)
 if p.suffix=='.bend':
  for name in re.findall(r'^\s*import\s+(\S+)',p.read_text(),re.M):
   if name!='Base':closure(p.parent/name,files)
def prepare():
 out=ROOT/'.artifacts'/('inspect54-resource-cheap-'+str(time.time_ns()));out.mkdir();files=set();closure(HERE/'resource-main.bend',files);files.update([HERE/'resource-reference.mjs',HERE/'resource-oracle.json',HERE/'resource-development.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py']);files.update(Path(shutil.which(n)).resolve() for n in ['bend','node','taskset']);dirs=[ROOT/'.references/bevy-ts/packages/core/src',Path('/home/node/.bend/bend2')];env=dict(os.environ,BEND_NO_TELEMETRY='1');envfile=out/'private-environment.json';envfile.write_text(json.dumps(env,sort_keys=True));envfile.chmod(0o600);inputs=task_runner.Inputs(files=files,directories=dirs);js=out/'resource.js';prefix=['taskset','-c','5'];commands=[{'label':'resource-ts','argv':prefix+['node',str(HERE/'resource-reference.mjs')],'seconds':5},{'label':'resource-emit','argv':prefix+['bend',str(HERE/'resource-main.bend'),'-o',str(js)],'seconds':30},{'label':'resource-js','argv':prefix+['node',str(js)],'seconds':5}]
 p={'files':list(map(str,sorted(files))),'directories':list(map(str,dirs)),'inputs':inputs.expected,'environmentSHA256':sha(envfile),'privateEnvironment':str(envfile),'commands':commands,'generated':str(js),'scope':'Complete24 resource/check snapshots across two nominal schemas and absent/present worlds; cheap development only, no Native/installedtool/staticnegative/mutant/performance/refinement acceptance'}
 (out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();out=path.parent;p=json.loads(path.read_text());inputs=task_runner.Inputs(files=p['files'],directories=[Path(x) for x in p['directories']]);assert inputs.expected==p['inputs'];envfile=Path(p['privateEnvironment']);assert sha(envfile)==p['environmentSHA256'];env=json.loads(envfile.read_text());logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](out,[x['label'] for x in p['commands']]);runner=task_runner.Runner(logs,inputs=inputs,env=env,cwd=ROOT);oracle=json.loads((HERE/'resource-oracle.json').read_text());r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]};generated={}
 try:
  for c in p['commands']:
   if c['label']=='resource-emit':assert not Path(p['generated']).exists()
   x=runner.run(c['label'],c['argv'],c['seconds']);r['commands'].append({'label':c['label'],'exit':x['exit'],'failure':x['failure']})
   if c['label']=='resource-ts':assert json.loads(x['stdout'])==oracle['ts']
   if c['label']=='resource-emit':generated[p['generated']]=sha(Path(p['generated']));runner.inputs=task_runner.Inputs(files=[*p['files'],p['generated']],directories=[Path(x) for x in p['directories']])
   if c['label']=='resource-js':assert json.loads(x['stdout'])==oracle['bendText']
   runner.inputs.guard();logs.guard();assert sha(envfile)==p['environmentSHA256'];assert all(sha(Path(f))==h for f,h in generated.items())
  r['status']='OPTIONAL_RESOURCE_CHECK24_COMPLETE_TS_JS_DEVELOPMENT_PASS'
 except BaseException as e:r['error']=str(e);raise
 finally:r['logs']=dict(logs.hashes);r['generated']=generated;(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare()
else:run(a.run)
