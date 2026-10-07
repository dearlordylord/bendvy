"""Fresh resolver-guarded authority sources and retained complete JS controls; no baseline replay."""
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

VARIANTS=['lost-retry','premature-publication','whole-marker-rollback']

def prepare():
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 out=HERE/'development'/('controls-qualified-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();files=set();entries={'authority-positive':HERE/'full-authority-positive.bend','foreign':HERE/'full-foreign-controls.bend'}
 for v in VARIANTS:
  version='v6' if v=='whole-marker-rollback' else 'v2';entries[v]=HERE/'development'/('handler-mutants-prepared-'+version)/v/'experiments/public-machine-handlers/candidate-v1/full-driver-v2.bend'
 classification=HERE/'authority-diagnostic-classification-v1.json';classified=json.loads(classification.read_text())
 for name,control in classified['controls'].items():
  source=HERE/('full-negative-'+name+'.bend');assert sha(source)==control['sourceSHA256'];entries[name]=source
 for entry in entries.values():closure(entry,files)
 for source in sorted(files):
  target=stage/source.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target);assert sha(source)==sha(target)
 # Bind actual historical artifacts and complete source closures, not only output hashes.
 historical={};joins={}
 for label,dirname in [('foreign','foreign-consumer-cheap-1791408106680526278'),('mutants','mutants-complete-cheap-1791410160619766954')]:
  base=HERE/'development'/dirname;receipt=json.loads((base/'receipt.json').read_text());plan=json.loads((base/'plan.json').read_text());assert sha(base/'plan.json')==receipt['planSHA256']
  assert all(sha(base/name)==digest for name,digest in receipt['logs'].items());assert all(sha(path)==digest for path,digest in receipt['generated'].items())
  files.update([base/'receipt.json',base/'plan.json',*[base/name for name in receipt['logs']],*map(Path,receipt['generated'])]);historical[label]={'receipt':str(base/'receipt.json'),'sha256':sha(base/'receipt.json')}
  relevant=['foreign'] if label=='foreign' else VARIANTS
  for name in relevant:
   subset=set();closure(entries[name],subset)
   for source in subset:
    archived=Path(plan['stage'])/source.relative_to(ROOT);assert sha(source)==sha(archived);files.add(archived);joins[str(source)]={'historical':str(archived),'sha256':sha(archived)}
 files.update([classification,HERE/'full-expected.json',HERE/'full-foreign-expected.json',HERE/'full-foreign-consumer.mjs',HERE/'full-mutant-complete-consumer.mjs',HERE/'full-oracle.py',HERE/'full-mutant-oracle.py',Path(__file__).resolve(),TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'.references/sources.json'])
 for v in VARIANTS:files.add(HERE/('full-mutant-'+v+'-expected.json'))
 for name in ['delivery-controls-v1','delivery-mutants-v1']:
  manifest=HERE/name/'manifest.json';m=json.loads(manifest.read_text());assert all(sha(HERE/f)==digest for f,digest in m['source'].items());files.add(manifest);files.update(HERE/f for f in m['source'])
 env=P.configuration()['env'];ledger=ProbeLedger(out/'prepare-probes',['prepare-ldd-'+n for n in ['bend','node','python','taskset','clang']],T.Inputs(files=list(files),directories=[stage]),env)
 tools=P.shared.snapshot(**owned_configuration(ledger));assert ledger.index==5
 prep=out/'prepare-receipt.json';prep.write_text(json.dumps({'status':'OWNED_TOOL_PREPARATION_PASS','probePins':ledger.pins(),'probeCommandsExecuted':ledger.index},indent=2)+'\n');files.add(prep);files.update(map(Path,ledger.pins()));files.update(map(Path,tools['pins']))
 ep=out/'private-environment.json';ep.write_text(json.dumps(env,sort_keys=True));ep.chmod(0o600);prefix=[P.configuration()['taskset'],'-c',str(P.configuration()['cpu'])]
 commands=[{'label':name+'-source','argv':prefix+[P.configuration()['tools']['bend'],str(stage/entry.relative_to(ROOT)),'--check-only'],'seconds':5,'expected':1 if name in classified['controls'] else 0,'diagnostic':classified['controls'][name]['intendedErrorSnippets'] if name in classified['controls'] else None} for name,entry in entries.items()]
 foreign=HERE/'development/foreign-consumer-cheap-1791408106680526278';old=json.loads((foreign/'plan.json').read_text());consumer=next(c for c in old['commands'] if c['label'].endswith('consume'));commands.append(dict(consumer,label='foreign-consume',expected=0))
 mutants=HERE/'development/mutants-complete-cheap-1791410160619766954';old=json.loads((mutants/'plan.json').read_text())
 for c in old['commands']:
  if c['label'].endswith('consume'):commands.append(dict(c,expected=0))
 for c in commands:
  if c['label'].endswith('consume'):
   c['argv'][0]=P.configuration()['tools']['node'];files.update(Path(x) for x in c['argv'][1:] if Path(x).is_file())
 for command in commands:
  name=command['label'].removesuffix('-source')
  if name in classified['controls']:
   command['expectedStderrSHA256']=classified['controls'][name]['rawStderrSHA256']
 assert len(commands)==13
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'environmentSHA256':sha(ep),'privateEnvironment':str(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(27) for n in ['bend','node','python','taskset','clang']],'historicalEvidence':historical,'exactSourceGeneratedHistoryJoins':joins,'scope':'Nine source5 including four exact intended diagnostic refusals/matchedpositive and actual foreign/three mutants; four Node5 retained generated complete consumers, no emitter/normalTS/normalJS/normalNative replay. Fresh ordinary complete tool/library/config/discovery/environment/source/raw guards. IO root source typing only not safeproof/--verdict. Native mutant scope remains pending; no proof/performance/fullIssue49 credit.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))

def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'completeIssue49':False,'proofCredit':False}
 try:
  guard()
  for c in p['commands']:
   guard();result=runner.run(c['label'],c['argv'],c['seconds'],expected=c['expected']);r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
   if c.get('diagnostic'):
    assert not result['stdout'] and all(snippet.encode() in result['stderr'] for snippet in c['diagnostic']),'unrelated negative error is inconclusive'
    assert hashlib.sha256(result['stderr']).hexdigest()==c['expectedStderrSHA256'],'changed/unrelated diagnostic is inconclusive'
   elif c['label'].endswith('-source'):
    assert not result['stderr'],'positive source emitted unexpected diagnostics'
   guard()
  assert ledger.index==135;r['status']='ORDINARY_RESOLVER_CONTROLS_COMPLETE_DIAGNOSTICS_AND_PHYSICAL_JS_PASS'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:
  r.update(logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args()
prepare() if args.prepare else run(args.run)
