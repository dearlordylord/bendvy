"""Frozen complete full96/12 Native development cohort; no performance claim."""
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
 for root in [ROOT,Path.cwd(),out,stage,stage/'src/ecs',stage/'experiments/public-machine-handlers/candidate-v1']:
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
ENTRIES={'normal':HERE/'full-native-schema-a.bend'}
ORACLE=HERE/'full-expected.json'
def prepare(cheap):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 cheap=Path(cheap).resolve();rec=json.loads(cheap.read_text());prior=json.loads((cheap.parent/'plan.json').read_text())
 assert rec['status']=='FULL96_AND12_RUNTIME_DRIVER_JS_DEVELOPMENT_PASS' and rec['planSHA256']==sha(cheap.parent/'plan.json')
 assert all(sha(cheap.parent/n)==h for n,h in rec['logs'].items())
 assert all(sha(f)==h for f,h in prior['pins'].items())
 out=HERE/'development'/('schema-a-c-diagnostic-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();files=set()
 closure(ENTRIES['normal'],files)
 original_stage=Path(prior['stage']);joins={}
 for source in sorted(files):
  previous=original_stage/source.relative_to(ROOT);current=source.read_bytes()
  if source==ENTRIES['normal']:
   joins[str(source)]={'currentSHA256':sha(source),'join':'new IO-only schemaA wrapper; source-check first required'};continue
  old=previous.read_bytes()
  if old!=current:
   assert source==HERE/'event-stream.bend' and old==current+b'\n'
  joins[str(source)]={'historicalSHA256':sha(previous),'currentSHA256':sha(source),'join':'byte exact' if old==current else 'remove exactly one final LF; historical semantic JS reuse only'}
 files.update([ORACLE,HERE/'full-native-consumer.py',Path(__file__).resolve(),cheap,cheap.parent/'plan.json',*[cheap.parent/n for n in rec['logs']]])
 for p in sorted(files):
  if p.suffix=='.bend':
   target=stage/p.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,target);assert sha(p)==sha(target)
 old_plan=HERE/'development/full-driver-v2-native-1791405024263814664/plan.json';old_receipt=old_plan.parent/'receipt.json';previous=decode(json.loads(old_plan.read_text()));historical=json.loads(old_receipt.read_text())
 assert historical['planSHA256']==sha(old_plan) and historical['status']=='INCOMPLETE'
 assert all(sha(f)==h for f,h in previous['pins'].items())
 tools=previous['tools'];envfile_previous=Path(previous['privateEnvironment']);assert sha(envfile_previous)==previous['environmentSHA256'];env=json.loads(envfile_previous.read_text())
 files.update([old_plan,old_receipt,envfile_previous]);files.update(map(Path,historical['probePins']))
 envfile=out/'private-environment.json';envfile.write_text(json.dumps(env,sort_keys=True));envfile.chmod(0o600)
 files.update([TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'.references/sources.json']);files.update(map(Path,tools['pins']))
 c=out/'full.c';binary=out/'full-native';prefix=[P.configuration()['taskset'],'-c',str(P.configuration()['cpu'])]
 commands=[{'label':'source-check','argv':prefix+[P.configuration()['tools']['bend'],str(stage/ENTRIES['normal'].relative_to(ROOT)),'--check-only'],'seconds':5},{'label':'emit-c','argv':prefix+[P.configuration()['tools']['bend'],str(stage/ENTRIES['normal'].relative_to(ROOT)),'-o',str(c)],'seconds':30}]
 p={'pins':{str(p):sha(p) for p in sorted(files)},'tools':tools,'environmentSHA256':sha(envfile),'privateEnvironment':str(envfile),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(5) for n in ['bend','node','python','taskset','clang']],'cheapReceipt':str(cheap),'cheapReceiptSHA256':sha(cheap),'semanticSourceJoin':joins,'scope':'Cheapest actual nominal-schemaA C-emission diagnostic: new IO wrapper invokes same qualified runtime driver six complete positive applications plus six actual refusal observations. Source-check5 then emitC30, no Clang/runtime/Node/TS. Existing installed-tool snapshot reused with25 current owned verification probes; no cap raise or Native correctness/timing verdict.'};(out/'plan.json').write_text(json.dumps(p,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);envfile=Path(p['privateEnvironment']);assert sha(envfile)==p['environmentSHA256'];env=json.loads(envfile.read_text());os.environ.clear();os.environ.update(env);generated={};probe_inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],probe_inputs,env)
 def guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(envfile)==p['environmentSHA256'];assert all(sha(f)==h for f,h in generated.items());P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 guard();inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);logs=L.CommandLogs(out,[x['label'] for x in p['commands']]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=stage);oracle=json.loads(ORACLE.read_text())['bend'];names=[f'schema{schema}_{phase}{pos}{suffix}' for schema in ['A','B'] for phase in ['exit','transition','enter'] for pos in [0,1] for suffix in ['', '_missing']];assert set(names)==set(oracle);expected=('\n'.join(name+'|['+', '.join(oracle[name])+']' for name in names)+'\n').encode();r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]}
 try:
  for c in p['commands']:
   guard()
   if '-o' in c['argv']:assert not Path(c['argv'][c['argv'].index('-o')+1]).exists()
   x=runner.run(c['label'],c['argv'],c['seconds']);r['commands'].append({'label':c['label'],'exit':x['exit'],'failure':x['failure']});assert x['exit']==0 and x['failure'] is None
   if '-o' in c['argv']:
    f=c['argv'][c['argv'].index('-o')+1];generated[f]=sha(f);runner.inputs=T.Inputs(files=[path,*p['pins'],*generated],directories=[stage])
   if 'oracle' in c:
    assert x['stdout']==expected,'complete Native bytes differ from independent full96/12 oracle'
   guard()
  assert ledger.index==25;r['status']='SCHEMA_A_C_EMISSION_DIAGNOSTIC_PASS_NO_NATIVE_RUN'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:r['generated']=generated;r['logs']=dict(logs.hashes);r['probePins']=ledger.pins();r['probeCommandsExecuted']=ledger.index;(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
p=argparse.ArgumentParser();p.add_argument('--prepare-from-cheap');p.add_argument('--run');a=p.parse_args();prepare(a.prepare_from_cheap) if a.prepare_from_cheap else run(a.run)
