"""Full same-owner IO correctness emission/execution only; no clocks or timing."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time,fcntl
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
TOOL=ROOT/'experiments/public-relations/promotion-stage/application/next-version/v1/tool-pins.py'
sys.dont_write_bytecode=True

def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(ROOT/'scripts/task_runner.py','task_runner');L=load(ROOT/'scripts/receipt-logs.py','logs');P=load(TOOL,'tools')
BOUNDARY=Path('/workspace/formal-proofs/bendvy/scripts/evidence_boundary.py'); E=load(BOUNDARY,'bundle_evidence_boundary')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def encode(x):
 if isinstance(x,bytes):return {'rawBase64':base64.b64encode(x).decode()}
 raise TypeError(type(x))
def decode(x):
 if isinstance(x,dict):return base64.b64decode(x['rawBase64']) if set(x)=={'rawBase64'} else {k:decode(v) for k,v in x.items()}
 if isinstance(x,list):return [decode(v) for v in x]
 return x
def validate_node_environment(env):
 assert 'NODE_PATH' not in env,'NODE_PATH injection not admitted'
 assert re.fullmatch(r'--max-old-space-size=[0-9]+',env.get('NODE_OPTIONS','')) or not env.get('NODE_OPTIONS'),'Node loader/options injection not admitted'
 assert 'NODE_REPL_EXTERNAL_MODULE' not in env,'Node external module injection not admitted'
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def configs(out,stage):
 paths=set()
 for root in [ROOT,Path.cwd(),out,stage,stage/'src/ecs',stage/'experiments/public-machine-handlers/candidate-v1',*[p.parent for p in stage.rglob('*.bend')]]:
  for parent in [root,*root.parents]:
   for name in ['check.json','bend.json','bender.json','package.json','.bend.json','bend.config.json']:paths.add(parent/name)
 for name in ['check.json','bend.json','bender.json','package.json','.bend.json','bend.config.json']:paths.add(Path('/home/node/.bend')/name)
 return {str(p):sha(p) if p.is_file() else None for p in paths}
def historical_current_configs(out,stage,tools):
 roots=[ROOT,HERE,Path.cwd(),out,stage,*[p.parent for p in stage.rglob('*.bend')],*[Path(p).resolve().parent for p in tools['tools'].values()],*[Path(p) for p in tools['resource_roots']]]
 paths=set()
 for root in roots:
  for parent in [root,*root.parents]:
   for name in ['check.json','check.jsonc','bend.json','bend.jsonc','bender.json','bender.jsonc','package.json','.bend.json','.bend','bend.config.json','tsconfig.json','.node-version','.nvmrc','.npmrc']:
    paths.add(parent/name)
 result={}
 for path in paths:
  if path.is_symlink():result[str(path)]={'kind':'symlink','target':str(path.resolve()),'sha256':sha(path) if path.is_file() else None}
  elif path.is_file():result[str(path)]={'kind':'file','sha256':sha(path)}
  elif path.is_dir():result[str(path)]={'kind':'directory','inventory':inventory(path)}
  else:result[str(path)]={'kind':'absent'}
 return result
def historical_native_configs(out,stage,tools,env):
 roots=[ROOT,HERE,Path.cwd(),out,stage,*[p.parent for p in stage.rglob('*.bend')],*[Path(p).resolve().parent for p in tools['tools'].values()],*[Path(p) for p in tools['resource_roots']],Path(env['HOME'])/'.bend']
 names=['bend.json','bend.jsonc','bend.toml','check.json','check.jsonc','bender.json','bender.jsonc','.bend','.bend.json','bend.config.json']
 paths=set()
 for root in roots:
  for parent in [root,*root.parents]:
   for name in names:paths.add(parent/name)
 def kind(path):
  if path.is_file():return {'kind':'file','sha256':sha(path)}
  if path.is_dir():return {'kind':'directory','inventory':inventory(path)}
  return {'kind':'absent'}
 result={}
 while paths:
  path=paths.pop()
  if str(path) in result:continue
  if path.is_symlink():
   target=path.resolve();result[str(path)]={'kind':'symlink','link':os.readlink(path),'target':str(target),'resolved':kind(target)}
   paths.add(target)
   for parent in [target.parent,*target.parent.parents]:
    for name in names:paths.add(parent/name)
  else:result[str(path)]=kind(path)
 return result
def current_configs(out,stage,tools,env):
 roots=[ROOT,HERE,Path.cwd(),out,stage,*[p.parent for p in stage.rglob('*.bend')],*[Path(p).resolve().parent for p in tools['tools'].values()],*[Path(p) for p in tools['resource_roots']],Path(env['HOME'])/'.bend']
 names=['bend.json','bend.jsonc','bend.toml','check.json','check.jsonc','bender.json','bender.jsonc','.bend','.bend.json','bend.config.json','package.json','tsconfig.json','.node-version','.nvmrc','.npmrc']
 paths=set()
 for root in roots:
  for parent in [root,*root.parents]:
   for name in names:paths.add(parent/name)
 def kind(path):
  if path.is_file():return {'kind':'file','sha256':sha(path)}
  if path.is_dir():return {'kind':'directory','inventory':inventory(path)}
  return {'kind':'absent'}
 result={}
 while paths:
  path=paths.pop()
  if str(path) in result:continue
  if path.is_symlink():
   target=path.resolve();result[str(path)]={'kind':'symlink','link':os.readlink(path),'target':str(target),'resolved':kind(target)}
   paths.add(target)
   for parent in [target.parent,*target.parent.parents]:
    for name in names:paths.add(parent/name)
  else:result[str(path)]=kind(path)
 return result
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
  result=None;primary=None
  try:
   result=self.runner.run(label,argv,limit)
  except BaseException as error:
   primary=error;result=getattr(error,'result',None)
  finally:
   document={'argv':list(map(str,argv)),'seconds':limit,'exception':None if primary is None else type(primary).__name__+': '+str(primary)}
   if result is not None:document.update({k:result[k] for k in ['exit','failure','runnerSHA256']})
   path=self.directory/(label+'.json')
   try:
    with E.GuardBoundary([('probe ledger postguard',self.guard)]):
     try:
      path.write_text(json.dumps(document,indent=2)+'\n');self.receipts[str(path)]=sha(path)
     except BaseException as secondary:
      if primary is not None:primary.add_note('probe JSON write: '+type(secondary).__name__+': '+str(secondary))
      else:primary=secondary
     if primary is not None:raise primary
   except BaseException as preserved:
    primary=preserved
  if primary is not None:raise primary
  return result
 def guard(self):
  self.logs.guard();assert all(sha(p)==h for p,h in self.receipts.items())
  assert {str(p) for p in self.directory.iterdir()}==set(self.receipts)|{str(self.directory/n) for n in self.logs.hashes}
 def pins(self):return {**self.receipts,**{str(self.directory/n):h for n,h in self.logs.hashes.items()}}
def owned_configuration(ledger):
 c=P.configuration();c['execute']=ledger.execute;return c

def prepare():
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX)
 prior=HERE/'native-clock-inspection-1791444817897881996';oldpath=prior/'plan.json'
 assert sha(oldpath)=='6de1c0f4da84987a2ff7f5240858858003b107f33daa44dc9404efc4c1186cfa'
 old=decode(json.loads(oldpath.read_text()));receipt=json.loads((prior/'receipt.json').read_text())
 assert receipt['status']=='NATIVE_SOURCE_AND_C_DEPENDENCY_EMISSION_PASS_NO_RUNTIME_TIMING_CREDIT' and receipt['planSHA256']==sha(oldpath) and not receipt.get('guardFailures')
 assert len(receipt['commands'])==2 and receipt['probeCommandsExecuted']==25
 assert set(receipt['logs'])=={c['label']+suffix for c in old['commands'] for suffix in ['.stdout','.stderr']}
 assert set(receipt['probePins'])=={str(prior/'execution-probes'/(label+suffix)) for label in old['executionProbeLabels'] for suffix in ['.json','.stdout','.stderr']}
 for result,c in zip(receipt['commands'],old['commands'],strict=True):
  assert result['exit']==0 and result['failure'] is None and c['seconds'] in [5,30]
 assert all(sha(f)==digest for f,digest in old['pins'].items())
 assert all(sha(prior/n)==digest for n,digest in receipt['logs'].items())
 assert all(sha(f)==digest for f,digest in receipt['probePins'].items()) and all(sha(f)==digest for f,digest in receipt['generated'].items())
 envpath=Path(old['privateEnvironment']);assert sha(envpath)==old['environmentSHA256'];env=json.loads(envpath.read_text());validate_node_environment(env)
 freshHistorical=historical_native_configs(prior,Path(old['stage']),old['tools'],env)
 delta=HERE/'ledger-telemetry-config-delta-proposal.json';cacheProposal=json.loads(delta.read_text())
 assert cacheProposal['environmentSHA256']==old['environmentSHA256'] and env.get('BEND_NO_TELEMETRY')=='1'
 assert sha(cacheProposal['source'])==cacheProposal['sourceSHA256']
 cache='/home/node/.bend/check.json';parent='/home/node/.bend'
 differences={key for key in set(freshHistorical)|set(old['configurationStates']) if freshHistorical.get(key)!=old['configurationStates'].get(key)}
 assert differences=={cache,parent},'unexpected historical configuration drift'
 assert freshHistorical[cache]==cacheProposal['currentState'] and old['configurationStates'][cache]==cacheProposal['historicalState']
 before=old['configurationStates'][parent];after=freshHistorical[parent]
 assert before['kind']==after['kind']=='directory' and set(before['inventory'])==set(after['inventory'])
 assert {key for key in before['inventory'] if before['inventory'][key]!=after['inventory'][key]}=={'check.json'}
 # Explicit proposed telemetry boundary only; all other old configuration states exact.

 source=HERE/'ledger-driver-source-v1';review=source/'source-review.json';mapping=json.loads(review.read_text())
 assert all(sha(f)==digest for f,digest in mapping['files'].items())
 out=HERE/('ledger-correctness-js-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir()
 files=set();closure(source/'correctness-main.bend',files)
 for f in files:
  target=stage/f.relative_to(HERE);target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(f.read_bytes())
 files.add(delta);files.add(Path(cacheProposal['source']));files.update(map(Path,old['pins']));files.update([oldpath,prior/'receipt.json',envpath,review,Path(__file__),BOUNDARY,TOOL,ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'])
 files.update(Path(f) for f in mapping['files']);files.update(prior/n for n in receipt['logs']);files.update(Path(f) for f in receipt['probePins']);files.update(Path(f) for f in receipt['generated'])
 for name in ['development-ledger-source-1791446267543435301','development-ledger-source-1791446370767736830']:
  development=HERE/name;r=json.loads((development/'receipt.json').read_text())
  assert r['status']=='DEVELOPMENT_LEDGER_TYPING_PASS_NO_RUNTIME_TIMING_CREDIT' and not r.get('guardFailures')
  assert len(r['commands'])==1 and r['commands'][0]['exit']==0 and r['commands'][0]['failure'] is None
  assert all(sha(development/log)==digest for log,digest in r['logs'].items())
  files.update(f for f in development.rglob('*') if f.is_file())
 ep=out/'private-environment.json';ep.write_bytes(envpath.read_bytes());ep.chmod(0o600);assert sha(ep)==old['environmentSHA256']
 tools=old['tools'];cfg=P.configuration();assert cfg['cpu']==tools['cpu']==8 and cfg['taskset']==tools['taskset']
 assert all(Path(cfg['tools'][name]).resolve()==Path(target).resolve() for name,target in tools['tools'].items())
 prefix=[tools['taskset'],'-c','8'];generated=out/'ledger.js'
 commands=[{'label':'ledger-emit','argv':prefix+[tools['tools']['bend'],str(stage/'ledger-driver-source-v1/correctness-main.bend'),'-o',str(generated)],'seconds':30,'expected':0,'generated':str(generated)}, {'label':'ledger-io-run','argv':prefix+[tools['tools']['node'],str(generated)],'seconds':5,'expected':0}]
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'privateEnvironment':str(ep),'environmentSHA256':sha(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':current_configs(out,stage,tools,env),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+name for i in range(5) for name in ['bend','node','python','taskset','clang']],'historicalTelemetryCacheBoundary':cacheProposal,'sourceReviewManifestSHA256':sha(review),'validator':str(source/'validate-correctness.py'),'scope':'Actual full same-owner IO main correctness only; CPU8 emitJS30/Node5/25guards. IO.pure timestamps, no clock requests/timing/population/repetitions. Complete independent physical and type-sensitive common42 oracle; six Bend-only controls separate.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));planSHA=sha(path);stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def source_guard():
  assert sha(path)==planSHA
  validate_node_environment(env)
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert current_configs(out,stage,p['tools'],env)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];assert all(sha(path)==digest for path,digest in generated.items());ledger.guard()
 def guard():
  source_guard();P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 generated={}
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'completeIssue49':False,'proofCredit':False}
 def receipt_metadata():
  r.update(generated=generated,logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index)
 with E.ReceiptBoundary(r,out/'receipt.json',[('receipt metadata',receipt_metadata),('subject logs',logs.guard),('source/config/environment/generated/probe ledger',source_guard)]):
  try:
   guard()
   for c in p['commands']:
    guard()
    def register_generated():
     if c.get('generated') and Path(c['generated']).is_file():
      generated[c['generated']]=sha(c['generated']);runner.inputs=T.Inputs(files=[path,ep,*p['pins'],*generated],directories=[stage]);ledger.runner.inputs=T.Inputs(files=[path,ep,*p['pins'],*generated],directories=[stage])
    with E.GuardBoundary([('generated consumer input registration',register_generated),('subject logs',logs.guard),('source/tool/config/environment/generated/probe ledger',guard)]):
     if c.get('generated'):assert not Path(c['generated']).exists(),'generated output already exists'
     result=runner.run(c['label'],c['argv'],c['seconds'],expected=c['expected'])
    r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
    assert not result['stderr'],'unexpected emission/runtime stderr'
    if c['label']=='ledger-emit':assert not result['stdout'],'unexpected emission stdout'
    if c['label']=='ledger-io-run':
     validator=load(Path(p['validator']),'ledger_independent_validator');validated=validator.validate(result['stdout'].decode());r['independentValidationStatus']=validated['status']
    if c.get('generated'):assert c['generated'] in generated,'emission did not produce admitted output'
   assert ledger.index==25
   r['status']='FULL42_SAME_OWNER_IO_LEDGER_JS_CORRECTNESS_PASS_NO_TIMING_CREDIT'
  except BaseException as e:
   if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
   raise
 print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args()
prepare() if args.prepare else run(args.run)
