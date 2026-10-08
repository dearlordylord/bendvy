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

def ts_configs(out,stage,tools,env,core):
 result=current_configs(out,stage,tools,env)
 names=['bend.json','bend.jsonc','bend.toml','check.json','check.jsonc','bender.json','bender.jsonc','.bend','.bend.json','bend.config.json','package.json','tsconfig.json','.node-version','.nvmrc','.npmrc']
 roots=[core,*[f.parent for f in core.rglob('*.ts')],*[f.parent for f in stage.rglob('*.mjs')]];paths=set()
 for root in roots:
  for parent in [root,*root.parents]:
   paths.update(parent/name for name in names)
 def kind(path):
  if path.is_file():return {'kind':'file','sha256':sha(path)}
  if path.is_dir():return {'kind':'directory','inventory':inventory(path)}
  return {'kind':'absent'}
 while paths:
  path=paths.pop()
  if str(path) in result:continue
  if path.is_symlink():
   target=path.resolve();result[str(path)]={'kind':'symlink','link':os.readlink(path),'target':str(target),'resolved':kind(target)};paths.add(target)
   for parent in [target.parent,*target.parent.parents]:paths.update(parent/name for name in names)
  else:result[str(path)]=kind(path)
 return result
def prepare():
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  prior=HERE/'aligned-correctness-js-1791451752148896105';oldpath=prior/'plan.json';old=decode(json.loads(oldpath.read_text()));r=json.loads((prior/'receipt.json').read_text())
  assert sha(oldpath)=='6f62e3ed0d3a031f20166ba6be5591c810a277c2fb1fcaa8b3ff6bf4d34f901a'==r['planSHA256']
  assert sha(prior/'receipt.json')=='50a142643239cfd09d5bbad9de7b1d7127705e42067c4180dd85fd7b897074ff'
  assert r['status']=='FULL116_ALIGNED_CAPTURES_AND_UNCHANGED42_JS_CORRECTNESS_PASS_NO_TIMING_CREDIT' and not r.get('guardFailures',[])
  assert len(old['commands'])==len(r['commands'])==2 and [c['seconds'] for c in old['commands']]==[30,5]
  assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
  assert set(r['logs'])=={c['label']+suffix for c in old['commands'] for suffix in ['.stdout','.stderr']}
  assert all(sha(prior/n)==digest for n,digest in r['logs'].items()) and all(sha(f)==digest for f,digest in r['generated'].items())
  labels=['guard-'+str(i)+'-ldd-'+tool for i in range(5) for tool in ['bend','node','python','taskset','clang']]
  probes=prior/'execution-probes';assert old['executionProbeLabels']==labels and r['probeCommandsExecuted']==25
  assert set(r['probePins'])=={str(probes/(label+suffix)) for label in labels for suffix in ['.json','.stdout','.stderr']}=={str(f) for f in probes.iterdir()}
  assert all(sha(f)==digest for f,digest in r['probePins'].items())
  for label in labels:
   record=json.loads((probes/(label+'.json')).read_text());tool=label.split('-ldd-',1)[1]
   assert record['argv']==[old['tools']['taskset'],'-c','8',old['tools']['ldd'],old['tools']['tools'][tool]] and record['seconds']==5
   assert record['exit']==0 and record['failure'] is None and record.get('exception') is None
   assert record['runnerSHA256']==sha(T.IMPLEMENTATION)==r['commands'][0]['runnerSHA256']==r['commands'][1]['runnerSHA256']
  assert all(sha(f)==digest for f,digest in old['pins'].items()) and inventory(Path(old['stage']))==old['inventory']
  original=Path(old['privateEnvironment']);assert sha(original)==old['environmentSHA256'];env=json.loads(original.read_text());validate_node_environment(env)
  assert current_configs(prior,Path(old['stage']),old['tools'],env)==old['configurationStates']
  source=HERE/'capture-alignment-source-v1';review=source/'ts-source-review.json';m=json.loads(review.read_text());assert sha(review)=='7b69a9a9f82a6aea6a4058c62b98013159e7344e0a9354b3ac060f265a2103c0'
  assert all(sha(f)==digest for f,digest in m['files'].items())
  tmPath=HERE.parent/'ts-source-review-manifest.json';tm=json.loads(tmPath.read_text());assert tm['pinnedTSSource']['commit']=='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334'
  ref=Path('/workspace/formal-proofs/bendvy/.references/bevy-ts');core=ref/'packages/core/src'
  assert {str(f.relative_to(ref)):sha(f) for f in core.rglob('*') if f.is_file()}==tm['pinnedTSSource']['coreInventory']
  refManifest=Path(tm['pinnedTSSource']['sourceManifest']);assert sha(refManifest)==tm['pinnedTSSource']['sourceManifestSHA256']
  out=HERE/('aligned-TS-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir()
  for f in map(Path,m['files']):
   target=stage/f.relative_to(HERE);target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(f.read_bytes())
  files={Path(f) for f in old['pins']}|{oldpath,prior/'receipt.json',original,review,tmPath,refManifest,Path(__file__),BOUNDARY,TOOL,ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'}
  files.update(map(Path,m['files']));files.update(prior/n for n in r['logs']);files.update(map(Path,r['generated']));files.update(map(Path,r['probePins']));files.update(f for f in core.rglob('*') if f.is_file())
  ep=out/'private-environment.json';ep.write_bytes(original.read_bytes());ep.chmod(0o600);assert sha(ep)==old['environmentSHA256']
  tools=old['tools'];cfg=P.configuration();assert cfg['cpu']==tools['cpu']==8 and cfg['taskset']==tools['taskset'];assert all(Path(cfg['tools'][name]).resolve()==Path(target).resolve() for name,target in tools['tools'].items())
  command={'label':'aligned-TS-consume','argv':[tools['taskset'],'-c','8',tools['tools']['node'],str(stage/'capture-alignment-source-v1/consumer-ts.mjs')],'seconds':5,'expected':0}
  plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'privateEnvironment':str(ep),'environmentSHA256':sha(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':ts_configs(out,stage,tools,env,core),'tsCoreRoot':str(core),'tsCoreInventory':inventory(core),'commands':[command],'executionProbeLabels':['guard-'+str(i)+'-ldd-'+tool for i in range(3) for tool in ['bend','node','python','taskset','clang']],'sourceReviewManifestSHA256':sha(review),'scope':'Actual pinned TS same-runtime Node5 CPU8/15guards complete116 common captures and unchanged42 checkpoints; allactualraw retained beforeassert, clockfunction0. No timing/Native/proof/adoption/physical-schema equivalence.'}
  (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));planSHA=sha(path);stage=Path(p['stage']);ep=Path(p['privateEnvironment']);env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 ledger=None
 def source_guard():
  assert sha(path)==planSHA and sha(NOTICE)==NOTICE_SHA
  validate_node_environment(env)
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert ts_configs(out,stage,p['tools'],env,Path(p['tsCoreRoot']))==p['configurationStates']
  assert inventory(Path(p['tsCoreRoot']))==p['tsCoreInventory'];assert sha(ep)==p['environmentSHA256'];assert all(sha(path)==digest for path,digest in generated.items())
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
    assert result['stderr'] in ([b'',NOTICE.read_bytes()] if c['label']=='aligned-emit' else [b'']),'unexpected emission/runtime stderr'
    if c['label']=='aligned-emit':assert not result['stdout'],'unexpected emission stdout'
    if c['label']=='aligned-io-run':
     validator=load(Path(p['validator']),'ledger_independent_validator');validated=validator.validate(result['stdout'].decode());r['independentValidationStatus']=validated['status']
    if c.get('generated'):assert c['generated'] in generated,'emission did not produce admitted output'
   assert r['commands'][0]['exit']==0 and r['commands'][0]['failure'] is None
   assert ledger.index==15
   r['status']='ACTUAL_PINNED_TS_ALIGNED116_COMMON_AND_UNCHANGED42_WITH_FULL_RAW_PASS'
  except BaseException as e:
   if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
   raise
 print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args()
prepare() if args.prepare else run(args.run)
