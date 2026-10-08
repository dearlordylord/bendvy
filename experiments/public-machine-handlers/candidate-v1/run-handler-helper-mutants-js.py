"""Current-closure three full JS semantic mutation witnesses; no Native or proof credit."""
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
 previous=Path(args.source_run).resolve();assert previous.is_relative_to(HERE/'development')
 old=decode(json.loads((previous/'plan.json').read_text()));receipt=json.loads((previous/'receipt.json').read_text())
 assert receipt['status']=='STAGED_HANDLER_HELPERS_THREE_MUTANTS_SOURCE_TYPING_PASS' and receipt['planSHA256']==sha(previous/'plan.json')
 assert receipt['probeCommandsExecuted']==35 and all(c['exit']==0 and c['failure'] is None for c in receipt['commands'])
 assert all(sha(p)==h for p,h in old['pins'].items()) and inventory(Path(old['stage']))==old['inventory']
 assert configs(previous,Path(old['stage']))==old['configurationStates']
 assert all(sha(previous/n)==h for n,h in receipt['logs'].items())
 out=HERE/'development'/('handler-helper-mutants-js-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage)
 files={Path(p) for p in old['pins']}|{previous/'plan.json',previous/'receipt.json',Path(__file__).resolve()}
 files.update(previous/n for n in receipt['logs']);files.update(Path(p) for p in receipt['probePins'])
 for p,h in receipt['probePins'].items():assert sha(p)==h
 original_env=Path(old['privateEnvironment']);assert sha(original_env)==old['environmentSHA256'];files.add(original_env)
 ep=out/'private-environment.json';ep.write_bytes(original_env.read_bytes());ep.chmod(0o600);assert sha(ep)==old['environmentSHA256']
 prefix=old['commands'][0]['argv'][:4];assert prefix==[old['tools']['taskset'],'-c',str(old['tools']['cpu']),old['tools']['tools']['bend']];assert old['tools']['cpu']==8;node=old['tools']['tools']['node'];commands=[]
 for variant in old['sourceMapping']['variants']:
  fixture=stage/variant/'experiments/public-machine-handlers/candidate-v1';generated=out/(variant+'.mjs')
  commands.append({'label':variant+'-emit','argv':prefix+[str(fixture/'full-driver-v2.bend'),'-o',str(generated)],'seconds':30,'expected':0,'generated':str(generated)})
  commands.append({'label':variant+'-consume','argv':[node,str(fixture/'full-mutant-complete-consumer.mjs'),str(generated),str(fixture/'full-expected.json'),variant,str(fixture/('full-mutant-'+variant+'-expected.json'))],'seconds':5,'expected':0})
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':old['tools'],'environmentSHA256':sha(ep),'privateEnvironment':str(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(13) for n in ['bend','node','python','taskset','clang']],'selectedReference':old['selectedReference'],'sourceMapping':old['sourceMapping'],'sourceQualification':str(previous/'receipt.json'),'scope':'Three current two-helper staged actual controlled mutations, fresh emit30 and full consumerNode5 each. Reuse exact three typing PASS/35guards, no checker or baseline replay. All24strings/full96+12 independent variants, prefix/Local/cursor witnesses mandatory. No Native kill/proof/performance/adoption/issueclosure credit; Native narrow9roots and regression still pending.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))

def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def source_guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];assert all(sha(path)==digest for path,digest in generated.items());ledger.guard()
 def guard():
  source_guard();P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 generated={}
 reference=load(ROOT/'scripts/selected_reference.py','selected_reference')
 reference.verify(ROOT,p['selectedReference'])
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'completeIssue49':False,'proofCredit':False}
 try:
  guard()
  for c in p['commands']:
   guard()
   if c.get('generated'):assert not Path(c['generated']).exists()
   try:
    result=runner.run(c['label'],c['argv'],c['seconds'],expected=c['expected'])
   finally:
    try:
     if c.get('generated') and Path(c['generated']).is_file():
      generated[c['generated']]=sha(c['generated']);runner.inputs=T.Inputs(files=[path,ep,*p['pins'],*generated],directories=[stage])
    finally:
     logs.guard();guard()
   r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
   assert not result['stderr'],'unexpected source/emission/runtime stderr'
   if c.get('typingOnly'):assert result['stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
   if c.get('generated'):assert c['generated'] in generated
  reference.verify(ROOT,p['selectedReference']);assert ledger.index==65;logs.guard();source_guard();r['status']='STAGED_HANDLER_HELPERS_THREE_MUTANTS_FULL96_AND12_JS_PASS'
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

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--source-run');args=parser.parse_args()
prepare() if args.prepare else run(args.run)
