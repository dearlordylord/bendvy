"""One actual premature-publication SchemaB phase source/C-emission diagnostic."""
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

def prepare(draft,failed):
 draft=Path(draft).resolve();d=json.loads(draft.read_text());failed=Path(failed).resolve();r=json.loads(failed.read_text());prior_path=failed.parent/'plan.json';prior=decode(json.loads(prior_path.read_text()));assert r['status']=='INCOMPLETE' and r['failedCommand']['failure']=='child deadline' and len(r['commands'])==17 and r['planSHA256']==sha(prior_path)
 assert all(sha(f)==digest for f,digest in prior['pins'].items());assert all(sha(failed.parent/n)==digest for n,digest in r['logs'].items());assert all(sha(f)==digest for f,digest in r['probePins'].items())
 phase='exit';entry=Path(d['entries'][phase]);binding=d['bindings'][phase];assert sha(entry)==binding['wrapperSHA256'];out=HERE/'development'/('premature-b-phase-diagnostic-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();files=set(map(Path,prior['pins']));files.update([draft,failed,prior_path,Path(__file__).resolve()]);files.update(map(Path,r['probePins']));files.update(failed.parent/n for n in r['logs']);subset=set();closure(entry,subset);partition=entry.parents[3];original_root=HERE/'development/handler-mutants-prepared-v2/premature-publication';qualified_stage=Path(json.loads((HERE/'development/mutants-complete-cheap-1791410160619766954/plan.json').read_text())['stage']);joins={}
 for source in sorted(subset):
  if source!=entry:
   original=original_root/source.relative_to(partition);qualified=qualified_stage/original.relative_to(ROOT);assert sha(source)==sha(original)==sha(qualified);files.update([original,qualified]);joins[str(source)]={'original':str(original),'qualified':str(qualified),'sha256':sha(original)}
  target=stage/source.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target);files.add(source)
 expected=entry.parent/'expected-phase.stdout';assert sha(expected)==binding['rawSubsetSHA256'];files.add(expected);files.add(HERE/'full-mutant-premature-publication-expected.json');ep=out/'private-environment.json';oldenv=Path(prior['privateEnvironment']);assert sha(oldenv)==prior['environmentSHA256'];ep.write_bytes(oldenv.read_bytes());ep.chmod(0o600);files.add(oldenv);prefix=prior['commands'][0]['argv'][:3];c=out/'premature-b-exit.c'
 commands=[{'label':'source-check','argv':prefix+[P.configuration()['tools']['bend'],str(stage/entry.relative_to(ROOT)),'--check-only'],'seconds':5},{'label':'emit-c','argv':prefix+[P.configuration()['tools']['bend'],str(stage/entry.relative_to(ROOT)),'-o',str(c)],'seconds':30}]
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':prior['tools'],'privateEnvironment':str(ep),'environmentSHA256':sha(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(5) for n in ['bend','node','python','taskset','clang']],'sourceJoins':joins,'phaseBinding':binding,'failedOriginalReceiptSHA256':sha(failed),'scope':'Actual premature-publication schemaB exit0/exit1 phase partition; complete16+2 original physical subset. source5/Cemit30 only,25 ordinary guards reused validated snapshot/environment. Original two failure predicates/handlers/affineowners/Local/core/observations unchanged. No compile/runtime/fullNative verdict, no retry of identical failedfullB/root or capraise. Three phases must eventually join B48+6 and retainedA+B96+12.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))

def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env);generated={}
 ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];assert all(sha(f)==h for f,h in generated.items());P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'proofCredit':False,'completeIssue49':False}
 try:
  guard()
  for c in p['commands']:
   guard()
   if '-o' in c['argv']:assert not Path(c['argv'][-1]).exists()
   result=runner.run(c['label'],c['argv'],c['seconds']);r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']});assert not result['stderr'],'unexpected source/emitter diagnostics'
   if '-o' in c['argv']:
    generated[c['argv'][-1]]=sha(c['argv'][-1]);runner.inputs=T.Inputs(files=[path,ep,*p['pins'],*generated],directories=[stage])
   guard()
  assert ledger.index==25;r['status']='PREMATURE_B_EXIT_PHASE_EMISSION_PASS_NO_NATIVE_RUN'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:
  r.update(generated=generated,logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare');parser.add_argument('--failed-receipt');parser.add_argument('--run');args=parser.parse_args()
prepare(args.prepare,args.failed_receipt) if args.prepare else run(args.run)
