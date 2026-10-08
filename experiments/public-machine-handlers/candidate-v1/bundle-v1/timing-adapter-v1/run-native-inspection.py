"""Native source/C emission dependency inspection only; no execution or timing."""
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
def current_configs(out,stage,tools,env):
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
 prior=HERE/'inspection-js-1791443615229673439';planFile=prior/'plan.json';old=decode(json.loads(planFile.read_text()));receipt=json.loads((prior/'receipt.json').read_text())
 assert sha(planFile)==receipt['planSHA256']=='0c699e2b50f78993cd3f603d646874d9eaf54ddf9e76e5a08e758fa96c239ad9'
 assert receipt['status']=='CLOCK_CODE_EMISSION_AND_FULL42_CORRECTNESS_PASS_NO_TIMING_CREDIT' and not receipt.get('guardFailures',[])
 assert len(old['commands'])==len(receipt['commands'])==2 and [c['seconds'] for c in old['commands']]==[30,5]
 assert [c['exit'] for c in receipt['commands']]==[0,0] and all(c['failure'] is None for c in receipt['commands'])
 assert all(sha(f)==digest for f,digest in old['pins'].items()) and inventory(Path(old['stage']))==old['inventory']
 assert historical_current_configs(prior,Path(old['stage']),old['tools'])==old['configurationStates']
 labels=['clock-inspection-emit','common-correctness-consume'];assert [c['label'] for c in old['commands']]==labels
 assert set(receipt['logs'])=={label+suffix for label in labels for suffix in ['.stdout','.stderr']}
 assert all(sha(prior/n)==digest for n,digest in receipt['logs'].items()) and all(not (prior/(label+'.stderr')).read_bytes() for label in labels)
 assert all(sha(f)==digest for f,digest in receipt['generated'].items())
 assert old['executionProbeLabels']==['guard-'+str(i)+'-ldd-'+n for i in range(5) for n in ['bend','node','python','taskset','clang']] and receipt['probeCommandsExecuted']==25
 expectedProbes={str(prior/'execution-probes'/(label+suffix)) for label in old['executionProbeLabels'] for suffix in ['.json','.stdout','.stderr']}
 assert set(receipt['probePins'])==expectedProbes=={str(f) for f in (prior/'execution-probes').iterdir()}
 assert all(sha(f)==digest for f,digest in receipt['probePins'].items())
 for label in old['executionProbeLabels']:
  value=json.loads((prior/'execution-probes'/(label+'.json')).read_text());tool=label.rsplit('-ldd-',1)[1]
  assert value['exit']==0 and value['failure'] is None and value['seconds']==5 and value.get('exception') is None
  assert value['argv']==[old['tools']['taskset'],'-c','8',old['tools']['ldd'],old['tools']['tools'][tool]]
 proposal=HERE/'native-inspection-proposal-v1';manifest=proposal/'source-joins.json';m=json.loads(manifest.read_text());assert sha(manifest)=='35ea47e3d81da5558eca33e4f917779ea44324a0bd6df047d0bafdbc7a0f6d5a'
 assert all(sha(name)==digest for name,digest in m['closure'].items()) and sha(proposal/'main.bend')==m['mainSHA256']
 out=HERE/('native-clock-inspection-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(Path(old['stage']),stage)
 fixture=stage/'experiments/public-machine-handlers/candidate-v1/bundle-v1';main=fixture/'native-clock-inspection.bend';main.write_text((proposal/'main.bend').read_text().replace('../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/',''))
 files={Path(f) for f in old['pins']}|{planFile,prior/'receipt.json',manifest,proposal/'main.bend',proposal/'README.md',Path(__file__).resolve(),BOUNDARY,TOOL,ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'}
 files.update(prior/n for n in receipt['logs']);files.update(Path(f) for f in receipt['probePins']);files.update(Path(f) for f in receipt['generated']);files.update(Path(name) for name in m['closure']);files.update(f for f in Path(old['stage']).rglob('*') if f.is_file())
 oldenv=Path(old['privateEnvironment']);assert sha(oldenv)==old['environmentSHA256'];ep=out/'private-environment.json';ep.write_bytes(oldenv.read_bytes());ep.chmod(0o600);assert sha(ep)==old['environmentSHA256'];files.add(oldenv);env=json.loads(ep.read_text());validate_node_environment(env)
 tools=old['tools'];cfg=P.configuration();assert cfg['cpu']==tools['cpu']==8 and cfg['taskset']==tools['taskset'];assert all(Path(cfg['tools'][n]).resolve()==Path(target).resolve() for n,target in tools['tools'].items())
 prefix=[tools['taskset'],'-c','8'];generated=out/'clock-inspection.c'
 commands=[{'label':'native-source-check','argv':prefix+[tools['tools']['bend'],str(main),'--check-only'],'seconds':5,'expected':0},{'label':'native-clock-emit','argv':prefix+[tools['tools']['bend'],str(main),'-o',str(generated)],'seconds':30,'generated':str(generated),'expected':0}]
 p={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'environmentSHA256':sha(ep),'privateEnvironment':str(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':current_configs(out,stage,tools,env),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(5) for n in ['bend','node','python','taskset','clang']],'sourceReviewManifestSHA256':sha(manifest),'sourceRelocation':'Exactly remove relative fixture directory prefix from five main imports; all other bodies/source same.','scope':'Native actual Queue/Marker/Read returned-owner/endclock dependency C inspection only, CPU8 source5/Cemit30/25 guards. Literal1 reachability not workload/population; no Clang/runtime/timing/proof/Native feature qualification/full49 credit. Existing full42 correctness separate.'}
 (out/'plan.json').write_text(json.dumps(p,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
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
    if c['label']=='native-source-check':assert result['stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
   if c.get('generated'):assert c['generated'] in generated,'emission did not produce admitted output'
   assert ledger.index==25
   r['status']='NATIVE_SOURCE_AND_C_DEPENDENCY_EMISSION_PASS_NO_RUNTIME_TIMING_CREDIT'
  except BaseException as e:
   if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
   raise
 print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args()
prepare() if args.prepare else run(args.run)
