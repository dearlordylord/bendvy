"""Whole-schema aligned Native exact-C correctness; no clocks or timing."""
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
NOTICE=HERE/'development-clock-source-1791442786008956162/clock.stderr'
NOTICE_SHA='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
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
def diagnostic_configs(out,stage,tools,env):
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
def current_configs(out,stage,tools,env):
 roots=[ROOT,HERE,Path.cwd(),out,stage,*[p.parent for p in stage.rglob('*.bend')],*[Path(p).resolve().parent for p in tools['tools'].values()],*[Path(p) for p in tools['resource_roots']],Path(env['HOME'])/'.bend']
 names=['bend.json','bend.jsonc','bend.toml','check.json','check.jsonc','bender.json','bender.jsonc','.bend','.bend.json','bend.config.json','package.json','tsconfig.json','.node-version','.nvmrc','.npmrc','clang.cfg','.clang']
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

def prepare(schema):
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  assert schema=='B';prior=HERE/'aligned-native-B-diagnostic-1791454597062595215';oldpath=prior/'plan.json';old=decode(json.loads(oldpath.read_text()));receipt=json.loads((prior/'receipt.json').read_text())
  assert sha(oldpath)=='abb8528948e21351c65081b4f2c21a72c74a4ed781c6934d50553b868ed40291'==receipt['planSHA256']
  assert sha(prior/'receipt.json')=='ef3ac042502e3bb55ba2a3255fc26250b14d297fd39568c931e01e341739b443'
  assert receipt['status']=='SCHEMA_B_ALIGNED_WHOLE_IO_SOURCE_C_EMISSION_PASS_NO_RUNTIME_TIMING_CREDIT' and not receipt.get('guardFailures',[])
  prefix=[old['tools']['taskset'],'-c','8'];main=Path(old['stage'])/'capture-alignment-source-v1/native-B.bend';cfile=prior/'aligned-ledger-B.c'
  assert old['commands']==[{'label':'aligned-native-source','argv':prefix+[old['tools']['tools']['bend'],str(main),'--check-only'],'seconds':5,'expected':0}, {'label':'aligned-native-emit','argv':prefix+[old['tools']['tools']['bend'],str(main),'-o',str(cfile)],'seconds':30,'expected':0,'generated':str(cfile)}]
  assert len(receipt['commands'])==2 and all(c['exit']==0 and c['failure'] is None for c in receipt['commands'])
  # Historical collector appends result-only records in its exact frozen command loop.
  assert all(set(c)=={'exit','failure','capture','runnerSHA256'} and c['capture']=='split' for c in receipt['commands'])
  collector=HERE/'run-aligned-native-diagnostic.py'
  assert old['pins'][str(collector)]==sha(collector)=='d9d9be8f2df0a0b7da466810f103deb060c9c73db8c8a4a3c7df836d6ea69c58'
  assert set(receipt['logs'])=={c['label']+suffix for c in old['commands'] for suffix in ['.stdout','.stderr']}
  assert all(sha(prior/n)==digest for n,digest in receipt['logs'].items())
  assert receipt['generated']=={str(cfile):sha(cfile)} and sha(cfile)=='5a4137561f4fc5968c6a6f952e41ec7557716b61b1023f3fc8c5119eb59c1e0d'
  labels=['guard-'+str(i)+'-ldd-'+tool for i in range(5) for tool in ['bend','node','python','taskset','clang']]
  probes=prior/'execution-probes';assert old['executionProbeLabels']==labels and receipt['probeCommandsExecuted']==25
  assert set(receipt['probePins'])=={str(probes/(label+suffix)) for label in labels for suffix in ['.json','.stdout','.stderr']}
  assert set(receipt['probePins'])=={str(f) for f in probes.iterdir()} and all(sha(f)==digest for f,digest in receipt['probePins'].items())
  for label in labels:
   record=json.loads((probes/(label+'.json')).read_text());tool=label.split('-ldd-',1)[1]
   assert record['argv']==prefix+[old['tools']['ldd'],old['tools']['tools'][tool]] and record['seconds']==5
   assert record['exit']==0 and record['failure'] is None and record.get('exception') is None
   assert record['runnerSHA256']==sha(T.IMPLEMENTATION)==receipt['commands'][0]['runnerSHA256']==receipt['commands'][1]['runnerSHA256']
  assert all(sha(f)==digest for f,digest in old['pins'].items()) and inventory(Path(old['stage']))==old['inventory']
  envpath=Path(old['privateEnvironment']);assert sha(envpath)==old['environmentSHA256'];env=json.loads(envpath.read_text());validate_node_environment(env)
  assert diagnostic_configs(prior,Path(old['stage']),old['tools'],env)==old['configurationStates']
  assert sha(NOTICE)==NOTICE_SHA
  source=HERE/'capture-alignment-source-v1';review=source/'native-source-review.json';mapping=json.loads(review.read_text());assert all(sha(f)==digest for f,digest in mapping['source'].items())
  out=HERE/('aligned-native-'+schema+'-runtime-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(Path(old['stage']),stage)
  files=set();files.update([source/'validate-schema.py',source/'model.py',source/'expected-before-output.json',HERE/'ledger-native-source-v1/validate-schema.py',HERE/'ledger-driver-source-v1/physical-expected-before-output.json',HERE/'operations.json',HERE/'common-expected.json',HERE.parent/'oracle.py'])
  files.update(map(Path,old['pins']));files.update([oldpath,prior/'receipt.json',envpath,review,NOTICE,Path(__file__),BOUNDARY,TOOL,ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'])
  files.update(Path(f) for f in mapping['source']);files.update(prior/n for n in receipt['logs']);files.update(Path(f) for f in receipt['probePins']);files.update(Path(f) for f in receipt['generated'])
  files.update(f for f in Path(old['stage']).rglob('*') if f.is_file())
  ep=out/'private-environment.json';ep.write_bytes(envpath.read_bytes());ep.chmod(0o600);assert sha(ep)==old['environmentSHA256']
  tools=old['tools'];cfg=P.configuration();assert cfg['cpu']==tools['cpu']==8 and cfg['taskset']==tools['taskset']
  assert all(Path(cfg['tools'][name]).resolve()==Path(target).resolve() for name,target in tools['tools'].items())
  generated=out/('aligned-ledger-'+schema)
  commands=[{'label':'aligned-native-clang','argv':prefix+[tools['tools']['clang-wrapper'],'-O3',str(cfile),'-pthread','-lm','-o',str(generated)],'seconds':120,'expected':0,'generated':str(generated)}, {'label':'aligned-native-run','argv':prefix+[str(generated),'--threads','1','--gpu','off'],'seconds':5,'expected':0,'oracle':True}]
  plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'privateEnvironment':str(ep),'environmentSHA256':sha(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':current_configs(out,stage,tools,env),'commands':commands,'executionProbeLabels':labels,'schema':schema,'sourceReviewManifestSHA256':sha(review),'sourceDiagnosticPlanSHA256':sha(oldpath),'sourceDiagnosticReceiptSHA256':sha(prior/'receipt.json'),'validator':str(source/'validate-schema.py'),'scope':'Whole schema'+schema+' aligned no-clock exact-C Clang120/run5 CPU8/runtime1/GPUoff/25guards. All13setups/45operations/58captures/21checkpoints; no source/emission replay/other-schema/full116/timing credit.'}
  (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));planSHA=sha(path);stage=Path(p['stage']);ep=Path(p['privateEnvironment']);env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 ledger=None
 def source_guard():
  assert sha(path)==planSHA and sha(NOTICE)==NOTICE_SHA
  validate_node_environment(env)
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert current_configs(out,stage,p['tools'],env)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];assert all(sha(path)==digest for path,digest in generated.items())
  if ledger is not None:ledger.guard()
 def guard():
  source_guard();P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 generated={}
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=None;r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'completeIssue49':False,'proofCredit':False}
 def receipt_metadata():
  r.update(generated=generated,logs=dict(logs.hashes),probePins=ledger.pins() if ledger is not None else {},probeCommandsExecuted=ledger.index if ledger is not None else 0)
 with E.ReceiptBoundary(r,out/'receipt.json',[('receipt metadata',receipt_metadata),('subject logs',logs.guard),('source/config/environment/generated/probe ledger',source_guard)]):
  try:
   source_guard()
   ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
   runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split')
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
    if c['label']=='aligned-native-clang':assert not result['stdout'],'unexpected compiler stdout'
    if c.get('oracle'):
     validated=load(Path(p['validator']),'aligned_native_schema_validator').validate(p['schema'],result['stdout'].decode());r['independentValidationStatus']=validated['status']
    if c.get('generated'):assert c['generated'] in generated,'emission did not produce admitted output'
   assert ledger.index==25
   r['status']='SCHEMA_'+p['schema']+'_COMPLETE58_AND21_ALIGNED_IO_NATIVE_CORRECTNESS_PASS_NO_FULL116_TIMING_CREDIT'
  except BaseException as e:
   if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
   raise
 print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--schema',choices=['A','B'],default='B');args=parser.parse_args()
prepare(args.schema) if args.prepare else run(args.run)
