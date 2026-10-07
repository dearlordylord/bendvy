"""Reuse exact emitted schemaA C for full48+6 Native observations; partial mutant coverage."""
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

def prepare(receipt):
 receipt=Path(receipt).resolve();r=json.loads(receipt.read_text());prior_path=receipt.parent/'plan.json';prior=decode(json.loads(prior_path.read_text()));assert r['planSHA256']==sha(prior_path) and r['status']=='WHOLE_MARKER_SCHEMA_A_EMISSION_PASS_NO_NATIVE_RUN'
 assert all(sha(f)==digest for f,digest in prior['pins'].items());assert all(sha(receipt.parent/n)==digest for n,digest in r['logs'].items());assert all(sha(f)==digest for f,digest in r['generated'].items());assert all(sha(f)==digest for f,digest in r['probePins'].items())
 c=Path(next(iter(r['generated'])));assert sha(c)=='3baf3905b11c6bd9af28d9d4080a420d7277cc86aebdfdb1909d418cb8867dbd'
 expected=next(Path(f) for f in prior['pins'] if Path(f).name=='expected-native.stdout');assert sha(expected)==prior['subsetBinding']['completeRawSubsetSHA256']
 out=HERE/'development'/('mutant-native-first-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(Path(prior['stage']),stage);envfile=out/'private-environment.json';oldenv=Path(prior['privateEnvironment']);assert sha(oldenv)==prior['environmentSHA256'];envfile.write_bytes(oldenv.read_bytes());envfile.chmod(0o600)
 files=set(map(Path,prior['pins']));files.update([receipt,prior_path,c,oldenv,Path(__file__).resolve()]);files.update(map(Path,r['probePins']));files.update(receipt.parent/n for n in r['logs']);binary=out/'whole-marker-a-native';prefix=prior['commands'][0]['argv'][:3]
 commands=[{'label':'clang','argv':prefix+[P.configuration()['tools']['clang-wrapper'],'-O3',str(c),'-pthread','-lm','-o',str(binary)],'seconds':120},{'label':'run-native','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'oracle':str(expected)}]
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':prior['tools'],'privateEnvironment':str(envfile),'environmentSHA256':sha(envfile),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(5) for n in ['bend','node','python','taskset','clang']],'subsetBinding':prior['subsetBinding'],'emissionReceiptSHA256':sha(receipt),'scope':'Exact previous whole-marker-A C reused, clang120/run5 only,25 ordinary guards and full48+6 unchanged independent raw oracle. No source/emit/probe snapshot/normal baseline replay, no cap raise. Partial one-schema Native coverage; two-schema full96+12 union remains pending. No timing/proof/completeIssue49 claim.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))

def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env);generated={}
 ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];assert all(sha(f)==h for f,h in generated.items());P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'completeIssue49':False,'proofCredit':False}
 try:
  guard()
  for c in p['commands']:
   guard()
   if '-o' in c['argv']:assert not Path(c['argv'][-1]).exists()
   result=runner.run(c['label'],c['argv'],c['seconds']);r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
   if '-o' in c['argv']:
    generated[c['argv'][-1]]=sha(c['argv'][-1]);runner.inputs=T.Inputs(files=[path,ep,*p['pins'],*generated],directories=[stage])
   if 'oracle' in c:
    assert result['stdout']==Path(c['oracle']).read_bytes(),'complete original schemaA48+6 variant bytes differ'
    assert not result['stderr'],'Native runtime diagnostics are inconclusive'
   guard()
  assert ledger.index==25;r['status']='WHOLE_MARKER_A_NATIVE_COMPLETE48_AND6_PASS_PARTIAL_TWO_SCHEMA_SCOPE'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:
  r.update(generated=generated,logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare');parser.add_argument('--run');args=parser.parse_args()
prepare(args.prepare) if args.prepare else run(args.run)
