"""Focused frozen complete-snapshot JS/Native development cohort."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
TOOL=ROOT/'experiments/public-relations/promotion-stage/application/next-version/v1/tool-pins.py'
sys.dont_write_bytecode=True

def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(ROOT/'scripts/task_runner.py','task_runner');L=load(ROOT/'scripts/receipt-logs.py','logs');P=load(TOOL,'tools')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def encode(x):
 if isinstance(x,bytes):return {'rawBase64':base64.b64encode(x).decode()}
 raise TypeError(type(x))
def decode(x):
 if isinstance(x,dict):return base64.b64decode(x['rawBase64']) if set(x)=={'rawBase64'} else {k:decode(v) for k,v in x.items()}
 if isinstance(x,list):return [decode(v) for v in x]
 return x
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def configs(out,stage):
 paths=set()
 for root in [ROOT,Path.cwd(),out,stage,stage/'src/ecs',stage/'experiments/public-inspect/bend-candidate/full-v2']:
  for parent in [root,*root.parents]:
   for name in ['check.json','bend.json','bender.json','package.json','.bend.json','bend.config.json']:paths.add(parent/name)
 for name in ['check.json','bend.json','bender.json','package.json','.bend.json','bend.config.json']:paths.add(Path('/home/node/.bend')/name)
 return {str(p):sha(p) if p.is_file() else None for p in paths}
def closure(p,files):
 p=p.resolve()
 if p in files:return
 files.add(p)
 if p.suffix=='.bend':
  for name in re.findall(r'^\s*import\s+(\S+)',p.read_text(),re.M):
   if name!='Base':closure(p.parent/name,files)
class ProbeLedger:
 def __init__(self,directory,labels,inputs,env):
  directory.mkdir();self.directory=directory;self.labels=labels;self.index=0;self.receipts={};self.env=env
  self.logs=L.CommandLogs(directory,labels);self.runner=T.Runner(self.logs,inputs=inputs,env=env,cwd=ROOT,capture='merged-stdout')
 def execute(self,argv,limit,env):
  assert env==self.env and limit==5
  label=self.labels[self.index];self.index+=1
  result=self.runner.run(label,argv,limit)
  path=self.directory/(label+'.json');path.write_text(json.dumps({'argv':list(map(str,argv)),'seconds':limit,'exit':result['exit'],'failure':result['failure'],'runnerSHA256':result['runnerSHA256']},indent=2)+'\n');self.receipts[str(path)]=sha(path);self.guard();return result
 def guard(self):
  self.logs.guard();assert all(sha(p)==h for p,h in self.receipts.items())
  assert {str(p) for p in self.directory.iterdir()}==set(self.receipts)|{str(self.directory/n) for n in self.logs.hashes}
 def pins(self):return {**self.receipts,**{str(self.directory/n):h for n,h in self.logs.hashes.items()}}
def owned_configuration(ledger):
 c=P.configuration();c['execute']=ledger.execute;return c
def prepare():
 out=ROOT/'.artifacts'/('inspect54-retained-backends-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();files=set();closure(HERE/'retained-main.bend',files)
 files.update([HERE/'retained-oracle.json',HERE/'backends.py'])
 for p in sorted(files):
  dest=stage/p.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dest);assert sha(p)==sha(dest)
 env=P.configuration()['env'];probe_inputs=T.Inputs(files=[HERE/'backends.py',TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'],directories=[stage]);prepare_labels=['prepare-ldd-'+n for n in ['bend','node','python','taskset','clang']];prepare_ledger=ProbeLedger(out/'prepare-probes',prepare_labels,probe_inputs,env);tools=P.shared.snapshot(**owned_configuration(prepare_ledger));assert prepare_ledger.index==5;envfile=out/'private-environment.json';envfile.write_text(json.dumps(env,sort_keys=True));envfile.chmod(0o600)
 files.update(Path(p) for p in prepare_ledger.pins());files.update([TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'.references/sources.json']);files.update(Path(p) for p in tools['pins']);files.update((ROOT/'.references/bend2/bend2').rglob('*.ts'))
 entry=stage/'experiments/public-inspect/bend-candidate/full-v2/retained-main.bend';js=out/'retained.js';c=out/'retained.c';binary=out/'retained-native';prefix=['taskset','-c','5']
 commands=[{'label':'emit-js','argv':prefix+['bend',str(entry),'-o',str(js)],'seconds':30},{'label':'run-js','argv':prefix+['node',str(js)],'seconds':5},{'label':'emit-c','argv':prefix+['bend',str(entry),'-o',str(c)],'seconds':30},{'label':'clang','argv':prefix+['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(c),'-pthread','-lm','-o',str(binary)],'seconds':120},{'label':'run-native','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5}]
 p={'pins':{str(p):sha(p) for p in sorted(files)},'tools':tools,'environmentSHA256':sha(envfile),'privateEnvironment':str(envfile),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(11) for n in ['bend','node','python','taskset','clang']],'scope':'Complete eight snapshots per JS/Native, typed lookup and separate removal/despawn plus two actual registered retaining owners. Development qualification only; TS reference has separate cheap receipt. No static negatives/mutants/performance/proof/foreign Inspector policies/full54 acceptance.'}
 (out/'plan.json').write_text(json.dumps(p,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);envfile=Path(p['privateEnvironment']);assert sha(envfile)==p['environmentSHA256'];env=json.loads(envfile.read_text());os.environ.clear();os.environ.update(env);generated={};probe_inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],probe_inputs,env)
 def guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(envfile)==p['environmentSHA256'];assert all(sha(f)==h for f,h in generated.items());P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 guard();inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);logs=L.CommandLogs(out,[x['label'] for x in p['commands']]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=stage);r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope']};oracle=json.loads((stage/'experiments/public-inspect/bend-candidate/full-v2/retained-oracle.json').read_text())['retained-bend']
 try:
  for cmd in p['commands']:
   guard()
   if '-o' in cmd['argv']:assert not Path(cmd['argv'][cmd['argv'].index('-o')+1]).exists()
   x=runner.run(cmd['label'],cmd['argv'],cmd['seconds']);r['commands'].append({'label':cmd['label'],'exit':x['exit'],'failure':x['failure']})
   if '-o' in cmd['argv']:
    f=cmd['argv'][cmd['argv'].index('-o')+1];generated[f]=sha(f);runner.inputs=T.Inputs(files=[path,*p['pins'],*generated],directories=[stage])
   if cmd['label'].startswith('run-'):assert json.loads(x['stdout'])==oracle
   guard()
  assert ledger.index==len(p['executionProbeLabels']);r['status']='RETAINED_LOOKUP_DESPAWN_FULL_JS_NATIVE_ORACLE_PASS'
 except BaseException as e:r['error']=str(e);raise
 finally:r['generated']=generated;r['logs']=dict(logs.hashes);r['probePins']=ledger.pins();r['probeCommandsExecuted']=ledger.index;(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare()
else:run(a.run)
