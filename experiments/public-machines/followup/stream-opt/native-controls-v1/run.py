"""Full65537 two-schema machine-stream Native mutation controls; no timing."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time,fcntl
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
TOOL=ROOT/'scripts/owned-tool-pins.py'
sys.dont_write_bytecode=True

def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(ROOT/'scripts/task_runner.py','task_runner');L=load(ROOT/'scripts/receipt-logs.py','logs');Shared=load(TOOL,'tools')
BOUNDARY=Path('/workspace/formal-proofs/bendvy/scripts/evidence_boundary.py'); E=load(BOUNDARY,'bundle_evidence_boundary')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def encode(x):
 if isinstance(x,bytes):return {'rawBase64':base64.b64encode(x).decode()}
 raise TypeError(type(x))
def decode(x):
 if isinstance(x,dict):return base64.b64decode(x[next(iter(x))]) if set(x) in [{'rawBase64'},{'base64'}] else {k:decode(v) for k,v in x.items()}
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
  self.logs=L.CommandLogs(directory,labels);self.runner=T.Runner(self.logs,inputs=inputs,env=env,cwd=ROOT,capture='split')
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
def owned_configuration(ledger,tools,env):
 return {'execute':ledger.execute,'tools':tools['tools'],'resource_roots':tools['resource_roots'],'ldd':tools['ldd'],'taskset':tools['taskset'],'cpu':tools['cpu'],'env':env,'skip_ldd':tools['skip_ldd'],'capture_mode':'split'}
def capsule(path):
 import tarfile
 with tarfile.open(path) as archive:
  entries=archive.getmembers();assert len(entries)==len({e.name for e in entries}) and all(e.isfile() for e in entries)
  prefixes={e.name.split('/')[0] for e in entries};assert len(prefixes)==1
  return {e.name.split('/',1)[1]:archive.extractfile(e).read() for e in entries}
def prepare(label):
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  proposal=HERE/'source-proposal.json';mapping=json.loads(proposal.read_text());assert all(sha(f)==h for f,h in mapping['inputs'].items())
  olddir=Path('/workspace/formal-proofs/bendvy/.artifacts/machines-stream-opt-linear-native-freeze-v1');oldpath=olddir/'plan.json';old=decode(json.loads(oldpath.read_text()));rr=olddir/'receipt.json'
  retained=capsule(HERE.parent.parent/'evidence/linear-native-v1/cohort.tar.gz')
  assert oldpath.read_bytes()==retained['plan.json'] and rr.read_bytes()==retained['receipt.json']
  assert sha(rr)=='70152f7721b1a601bbfeee8521bf4ac982d02ed3db9dfd5fd42ea6ff2d8bdf2a'
  receipt=json.loads(rr.read_text());assert receipt['status']=='FULL65537_LINEAR_OBSERVER_NATIVE_MODEL_PASS_NO_ISSUE_ACCEPTANCE' and receipt['planSHA256']==sha(oldpath)
  tools=old['installedTools'];assert tools['cpu']==7 and tools['capture_mode']=='split' and len(tools['pins'])==343
  assert all(sha(f)==h for f,h in tools['pins'].items())
  assert all(inventory(Path(p))==v for p,v in old['resources'].items())
  originalEnv=olddir/'environment.private.json';assert sha(originalEnv)==old['privateEnvironmentMapSHA256'];env=json.loads(originalEnv.read_text());validate_node_environment(env)
  assert env.get('BEND_NO_TELEMETRY')=='1'
  cache=Path('/home/node/.bend/check.json');cacheBefore='2701f29532eebe9f6fc5ed50c50cbfcbc33925cfe033065a86fa7bc8f9f43e5d';cacheNow='2323ddd47baf7dd03018bcf923b6c9b4bb306f04c80bce7e21c4e5e62bc3c564'
  for name,record in old['configuration'].items():
   actual=Path(name);present=actual.is_file();digest=sha(actual) if present else None;link=os.readlink(actual) if actual.is_symlink() else None
   if actual==cache:
    assert record=={'present':True,'sha256':cacheBefore,'symlink':None,'scope':'daily update-notice cache'} and present and digest==cacheNow and link is None
   else:assert record['present']==present and record['sha256']==digest and record['symlink']==link
  telemetrySource=Path('/workspace/formal-proofs/bendvy/.references/bend2/bend2/main.ts')
  assert sha(telemetrySource)=='d1a3e026f5014f8daec3614df8e39cf261e3fbc47769eb0916fd891bc18703c9'
  assert 'if (process.env.BEND_NO_TELEMETRY) {\n    return;\n  }' in telemetrySource.read_text()
  historicalCache=HERE/'historical-check-cache.json';currentCache=HERE/'current-check-cache.json';cacheProvenance=HERE/'cache-byte-provenance.json'
  assert sha(historicalCache)==cacheBefore and sha(currentCache)==cacheNow==sha(cache)
  before=json.loads(historicalCache.read_text());after=json.loads(currentCache.read_text());assert set(before)==set(after)=={'t','ver','notice'} and before['notice']==after['notice']
  assert {k for k in before if before[k]!=after[k]} <= {'t','ver'}
  assert hashlib.sha256(json.dumps(env,sort_keys=True,separators=(',',':'),ensure_ascii=True).encode()).hexdigest()==tools['environment_sha256']
  stageInfo=mapping['stages'][label];stage=Path(stageInfo['currentRoot']);assert inventory(stage)==stageInfo['inventory']
  oracle=stage.parent/(label+'-expected.json.gz');assert sha(oracle)==stageInfo['oracleSHA256']
  import gzip
  controls=load(HERE.parent/'controls.py','machine_control_seams');oracles=load(HERE.parent/'mutant-oracles.py','machine_mutant_oracles');model=load(HERE.parent.parent/'overflow-model.py','machine_full_model')
  expected=json.loads(gzip.decompress(oracle.read_bytes()));assert expected==oracles.expected(label,model)
  assert len(expected['A'])==len(expected['B'])==7
  out=HERE/('native-'+label+'-'+str(time.time_ns()));out.mkdir();private=out/'private-environment.json';private.write_bytes(originalEnv.read_bytes());private.chmod(0o600);assert sha(private)==sha(originalEnv)
  files=set(map(Path,mapping['inputs']));files.update(map(Path,tools['pins']));files.update([proposal,oldpath,rr,originalEnv,oracle,Path(__file__),BOUNDARY,TOOL,ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',telemetrySource,historicalCache,currentCache,cacheProvenance])
  prefix=[tools['taskset'],'-c','7'];root=stage/'experiments/public-machines/followup/overflow.bend';generated=out/'application.c';binary=out/'application-native'
  commands=[{'label':'emit-c','argv':prefix+[tools['tools']['bend'],str(root),'-o',str(generated)],'seconds':30,'expected':0,'generated':str(generated)}, {'label':'clang','argv':prefix+[tools['tools']['clang_wrapper'],'-O3',str(generated),'-o',str(binary),'-pthread','-lm'],'seconds':120,'expected':0,'generated':str(binary)}, {'label':'native','argv':prefix+[str(binary),'--threads','1','--gpu','off','65537'],'seconds':5,'expected':0,'oracle':True}]
  lddTools=[n for n in tools['tools'] if n not in tools['skip_ldd']];assert len(lddTools)==7
  labels=['guard-'+str(i)+'-ldd-'+n for i in range(7) for n in lddTools]
  plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'resources':old['resources'],'privateEnvironment':str(private),'environmentSHA256':sha(private),'stage':str(stage),'inventory':stageInfo['inventory'],'configurationStates':current_configs(out,stage,tools,env),'commands':commands,'executionProbeLabels':labels,'mutant':label,'oracle':str(oracle),'sourceProposalSHA256':sha(proposal),'expectedProbeCount':49,'historicalConfigurationBoundary':{'scope':'Only disabled daily update-notice cache differs; all other historical configuration fields exact; current fullkind configurations separately frozen','path':str(cache),'historicalSHA256':cacheBefore,'currentSHA256':cacheNow,'sourcePath':str(telemetrySource),'sourceSHA256':sha(telemetrySource),'completeEnvironmentUnchanged':True,'BEND_NO_TELEMETRY':'1'},'normalNativePlanSHA256':sha(oldpath),'normalNativeReceiptSHA256':sha(rr),'scope':'Full65537/defaultcapacity65536 two-schema14-row '+label+' Native mutation controls only, CPU7/thread1/GPUoff, emit30/Clang120/run5/49ordinaryprobes. No normal/JS/API-negative replay, timing, ownership policy, proof or issueclosure.'}
  (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));planSHA=sha(path);stage=Path(p['stage']);ep=Path(p['privateEnvironment']);env=None
 ledger=None
 def source_guard():
  assert sha(path)==planSHA
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert all(inventory(Path(root))==v for root,v in p['resources'].items());assert sha(ep)==p['environmentSHA256'];assert all(sha(path)==digest for path,digest in generated.items())
  if env is not None:
   validate_node_environment(env);assert current_configs(out,stage,p['tools'],env)==p['configurationStates']
  if ledger is not None:ledger.guard()
 def guard():
  source_guard();Shared.verify(p['tools'],**owned_configuration(ledger,p['tools'],env));ledger.guard()
 generated={}
 logs=None;runner=None;r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'completeIssue49':False,'proofCredit':False}
 def receipt_metadata():
  r.update(generated=generated,logs=dict(logs.hashes) if logs is not None else {},probePins=ledger.pins() if ledger is not None else {},probeCommandsExecuted=ledger.index if ledger is not None else 0)
 with E.ReceiptBoundary(r,out/'receipt.json',[('receipt metadata',receipt_metadata),('subject logs',lambda: logs.guard() if logs is not None else None),('source/config/environment/generated/probe ledger',source_guard)]):
  try:
   source_guard()
   env=json.loads(ep.read_text());validate_node_environment(env);os.environ.clear();os.environ.update(env)
   logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);source_guard()
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
    assert not result['stderr'],'unexpected emission/compiler/runtime stderr'
    if c['label'] in ['emit-c','clang']:assert not result['stdout'],'unexpected emission/compiler stdout'
    if c.get('oracle'):
     import gzip
     model=load(HERE.parent.parent/'overflow-model.py','machine_native_control_model');oracles=load(HERE.parent/'mutant-oracles.py','machine_native_control_oracles');controls=load(HERE.parent/'controls.py','machine_native_control_witness')
     expected=json.loads(gzip.decompress(Path(p['oracle']).read_bytes()));oracles.validate(p['mutant'],result['stdout'],model,expected);r['witnesses']=controls.witness(p['mutant'],result['stdout'],model);r['independentValidationStatus']='FULL14_EXACT_MUTANT_ORACLE_BOTH_SCHEMA_WITNESS_PASS'
    if c.get('generated'):assert c['generated'] in generated,'emission did not produce admitted output'
   assert ledger.index==p['expectedProbeCount']==49
   r['status']='FULL65537_FOURTEEN_ROWS_BOTH_SCHEMA_'+p['mutant']+'_NATIVE_MUTANT_REACHED_NO_ISSUE_ACCEPTANCE'
  except BaseException as e:
   if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
   raise
 print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--mutant',choices=['queue-capacity','cached-size','oldest-newest-order','dropped-through','successful-cursor'],default='queue-capacity');args=parser.parse_args()
prepare(args.mutant) if args.prepare else run(args.run)
