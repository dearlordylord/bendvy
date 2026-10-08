"""Fresh two-helper staged foreign Native14-row runtime control."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time,fcntl
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
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

def prepare():
 prior=HERE/'development/handler-helper-lost-exit-a-diagnostic-1791428738577520584'
 old=decode(json.loads((prior/'plan.json').read_text()));receipt=json.loads((prior/'receipt.json').read_text())
 assert receipt['status']=='STAGED_HANDLER_HELPERS_LOST_EXIT_A_SOURCE_AND_C_EMISSION_PASS_NO_RUNTIME' and receipt['planSHA256']==sha(prior/'plan.json')
 assert sha(prior/'receipt.json')=='9b3cf314d1518153100804cafd5a168e5330cbd72543afc311014be9cb7cd98f'
 assert receipt['probeCommandsExecuted']==25 and len(receipt['commands'])==2 and all(c['exit']==0 and c['failure'] is None for c in receipt['commands'])
 assert all(sha(f)==digest for f,digest in old['pins'].items()) and all(sha(f)==digest for f,digest in old['tools']['pins'].items())
 stage=Path(old['stage']);assert inventory(stage)==old['inventory'] and configs(prior,stage)==old['configurationStates']
 assert all(sha(prior/name)==digest for name,digest in receipt['logs'].items()) and all(sha(f)==digest for f,digest in receipt['probePins'].items())
 assert len(receipt['generated'])==1;code=Path(next(iter(receipt['generated'])));assert sha(code)==receipt['generated'][str(code)]=='ba814fb2739eb0e0828e9c33cce3738812d4bb8dcbca9e03b61de04bd903017e'
 out=HERE/'development'/('handler-helper-lost-exit-a-runtime-'+str(time.time_ns()));out.mkdir()
 files={Path(f) for f in old['pins']}|{Path(f) for f in old['tools']['pins']}|{prior/'plan.json',prior/'receipt.json',code,Path(__file__).resolve(),HERE/'development/c4-blocking-queue/queue.py'}
 files.update(prior/name for name in receipt['logs']);files.update(Path(f) for f in receipt['probePins'])
 originalEnvironment=Path(old['privateEnvironment']);assert sha(originalEnvironment)==old['environmentSHA256'];files.add(originalEnvironment)
 ep=out/'private-environment.json';ep.write_bytes(originalEnvironment.read_bytes());ep.chmod(0o600);assert sha(ep)==old['environmentSHA256']
 cfg=P.configuration();assert cfg['cpu']==old['tools']['cpu']==8 and cfg['taskset']==old['tools']['taskset'];assert set(cfg['tools'])==set(old['tools']['tools']) and all(Path(cfg['tools'][name]).resolve()==Path(target).resolve() for name,target in old['tools']['tools'].items())
 prefix=[old['tools']['taskset'],'-c',str(old['tools']['cpu'])];binary=out/'lost-exit-a-native';root=old['nominalRoots']['lost-retry-A-exit'];expected=Path(root['expected']);assert sha(expected)==root['expectedSHA256'];files.add(expected)
 commands=[{'label':'lost-exit-a-clang','argv':prefix+[old['tools']['tools']['clang-wrapper'],'-O3',str(code),'-pthread','-lm','-o',str(binary)],'seconds':120,'generated':str(binary)},{'label':'lost-exit-a-run','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'phaseOracle':True}]
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':old['tools'],'environmentSHA256':sha(ep),'privateEnvironment':str(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(5) for n in ['bend','node','python','taskset','clang']],'sourceMapping':old['sourceMapping'],'sourceCQualification':{'plan':str(prior/'plan.json'),'planSHA256':sha(prior/'plan.json'),'receipt':str(prior/'receipt.json'),'receiptSHA256':sha(prior/'receipt.json'),'generatedC':str(code),'generatedCSHA256':sha(code)},'nominalRoot':root,'scope':'Only lost-A exit emittedC reuse compile120/run5,25 ordinary guards/current two-helper closure. Same exact C/source/tool/config/env/raw/25-probe input history, no checker/emitter/baseline replay. Complete16+2 unchanged independent subset only; not originalA48+6/B/full96+12 kill, proof, timing, adoption or new policy. Original4ece timeout and zerochildrefusals remain separate.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))

def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 generated={};ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def source_guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];assert all(sha(f)==h for f,h in generated.items());ledger.guard()
 def guard():
  source_guard();P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'completeIssue49':False,'proofCredit':False,'productionAdopted':False}
 wanted=Path(p['nominalRoot']['expected']).read_bytes();assert hashlib.sha256(wanted).hexdigest()==p['nominalRoot']['expectedSHA256']
 try:
  guard()
  for c in p['commands']:
   guard()
   if c.get('generated'):assert not Path(c['generated']).exists()
   try:
    result=runner.run(c['label'],c['argv'],c['seconds'])
   finally:
    try:
     if c.get('generated') and Path(c['generated']).is_file():
      generated[c['generated']]=sha(c['generated']);runner.inputs=T.Inputs(files=[path,ep,*p['pins'],*generated],directories=[stage])
    finally:
     logs.guard();guard()
   r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
   assert not result['stderr'],'unexpected emission/compile/runtime stderr'
   if c.get('generated'):assert c['generated'] in generated
   if c.get('phaseOracle'):assert result['stdout']==wanted,'complete lost-A exit16+2 independent rows differ'
  assert ledger.index==25;logs.guard();source_guard();r['status']='STAGED_HANDLER_HELPERS_LOST_EXIT_A_NATIVE_COMPLETE16_AND2_PASS_NO_FULL_UNION'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:
  try:
   logs.guard();source_guard()
  except BaseException as finalError:
   r['status']='INCOMPLETE';r['finalizationError']=str(finalError);raise
  finally:
   r.update(generated=generated,logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args()
prepare() if args.prepare else run(args.run)
