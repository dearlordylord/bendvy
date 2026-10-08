"""Separate caller schema Native runtime qualification; immutable diagnostic C reuse for A."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time,fcntl
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
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
 for root in [ROOT,Path.cwd(),out,stage,stage/'src/ecs',stage/'experiments/public-machine-handlers/candidate-v1',*[p.parent for p in stage.rglob('*.bend')]]:
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
   if name!='Base' and not name.startswith(chr(34)):closure(p.parent/name,files)
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

def prepare(schema):
 prior=HERE/'native-A-diagnostic-1791432923643306535';old=decode(json.loads((prior/'plan.json').read_text()));r=json.loads((prior/'receipt.json').read_text())
 assert r['status']=='CAPABILITY_CALLER_SCHEMA_A_SOURCE_AND_C_EMISSION_FEASIBLE_NO_RUNTIME' and r['planSHA256']==sha(prior/'plan.json')
 assert all(sha(f)==h for f,h in old['pins'].items()) and inventory(Path(old['stage']))==old['inventory'] and configs(prior,Path(old['stage']))==old['configurationStates']
 assert all(sha(prior/n)==h for n,h in r['logs'].items()) and all(sha(f)==h for f,h in r['probePins'].items()) and all(sha(f)==h for f,h in r['generated'].items())
 out=HERE/('native-runtime-'+schema+'-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage)
 files={Path(f) for f in old['pins']}|{prior/'plan.json',prior/'receipt.json',Path(__file__).resolve(),HERE/'expected-draft.json'}
 files.update(prior/n for n in r['logs']);files.update(Path(f) for f in r['probePins']);files.update(Path(f) for f in r['generated'])
 fixture=stage/'experiments/public-machine-handlers/candidate-v1/public-caller-v1/capability-v2'
 if schema=='B':
  files.add(HERE/'native-b.bend');shutil.copyfile(HERE/'native-b.bend',fixture/'native-b.bend')
 ep=out/'private-environment.json';original=Path(old['privateEnvironment']);assert sha(original)==old['environmentSHA256'];ep.write_bytes(original.read_bytes());ep.chmod(0o600);assert sha(ep)==old['environmentSHA256'];files.add(original)
 tools=old['tools'];cfg=P.configuration();assert cfg['cpu']==tools['cpu']==8 and cfg['taskset']==tools['taskset']
 assert all(Path(cfg['tools'][n]).resolve()==Path(target).resolve() for n,target in tools['tools'].items())
 prefix=[tools['taskset'],'-c',str(tools['cpu'])];code=prior/'caller-A.c' if schema=='A' else out/'caller-B.c';binary=out/('caller-'+schema)
 commands=[]
 if schema=='B':
  commands=[{'label':'caller-B-source','argv':prefix+[tools['tools']['bend'],str(fixture/'native-b.bend'),'--check-only'],'seconds':5,'expected':0},{'label':'caller-B-emit','argv':prefix+[tools['tools']['bend'],str(fixture/'native-b.bend'),'-o',str(code)],'seconds':30,'generated':str(code),'expected':0}]
 commands += [{'label':'caller-'+schema+'-clang','argv':prefix+[tools['tools']['clang-wrapper'],'-O3',str(code),'-pthread','-lm','-o',str(binary)],'seconds':120,'generated':str(binary),'expected':0},{'label':'caller-'+schema+'-run','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'expected':0,'oracle':True}]
 plan={'schema':schema,'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'environmentSHA256':sha(ep),'privateEnvironment':str(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(1+2*len(commands)) for n in ['bend','node','python','taskset','clang']],'diagnosticQualification':{'plan':str(prior/'plan.json'),'receipt':str(prior/'receipt.json'),'receiptSHA256':sha(prior/'receipt.json')},'oracle':str(HERE/'expected-draft.json'),'scope':'Schema '+schema+' actual independent caller seven complete JSON observations only. A exact C reuse compile120/run5; B source5/emit30/compile120/run5. CPU8/thread1/GPUoff; separate full14 reconciliation required. No mathematical proof, adoption, full49 closure or performance credit.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def complete_oracle(raw,p):
 def pairs(items):
  d={}
  for k,value in items:
   assert k not in d,'duplicate JSON key';d[k]=value
  return d
 expected=json.loads(Path(p['oracle']).read_text())['rows'];keys=[k for k in expected if k.startswith(p['schema']+'_')]
 rows=raw.decode().splitlines();assert len(rows)==len(keys)==7
 observed={}
 for key,line in zip(keys,rows):
  name,body=line.split('|',1);assert name==key
  value=json.loads(body,object_pairs_hook=pairs,parse_constant=lambda x: (_ for _ in ()).throw(ValueError(x)))
  assert json.dumps(value,sort_keys=True,separators=(',',':'))==json.dumps(expected[key],sort_keys=True,separators=(',',':')),'complete JSON oracle mismatch: '+key
  observed[key]=value
 return observed
def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def source_guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];assert all(sha(path)==digest for path,digest in generated.items());ledger.guard()
 def guard():
  source_guard();P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 generated={}
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'completeIssue49':False,'proofCredit':False}
 try:
  guard()
  for c in p['commands']:
   guard()
   if c.get('generated'):assert not Path(c['generated']).exists(),'generated output already exists'
   try:
    result=runner.run(c['label'],c['argv'],c['seconds'],expected=c['expected'])
   finally:
    try:
     if c.get('generated') and Path(c['generated']).is_file():
      generated[c['generated']]=sha(c['generated']);runner.inputs=T.Inputs(files=[path,ep,*p['pins'],*generated],directories=[stage])
    finally:
     logs.guard();guard()
   r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
   assert not result['stderr'],'unexpected emission/runtime stderr'
   if c.get('generated'):assert c['generated'] in generated,'emission did not produce admitted output'
   if c['label'].endswith('-source'):assert result['stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
   if c.get('oracle'):r['observations']=complete_oracle(result['stdout'],p)
  assert ledger.index==len(p['executionProbeLabels'])
  logs.guard();source_guard()
  r['status']='CAPABILITY_CALLER_SCHEMA_'+p['schema']+'_SEVEN_COMPLETE_NATIVE_OBSERVATIONS_PASS'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:
  try:
   logs.guard();source_guard()
  except BaseException:
   r['status']='INCOMPLETE'
   raise
  finally:
   r.update(generated=generated,logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--schema',choices=['A','B']);args=parser.parse_args()
prepare(args.schema) if args.prepare else run(args.run)
