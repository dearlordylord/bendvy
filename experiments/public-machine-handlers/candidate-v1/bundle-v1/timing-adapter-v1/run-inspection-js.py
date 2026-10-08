"""Source-only clock emission inspection and complete42 correctness development cohort."""
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
def current_configs(out,stage,tools):
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
 prior=HERE.parent/'bundle-relocated-js-1791438924907924172'
 # Resolve the retained qualified normal plan by its admitted literal SHA.
 expected='4d57b972050bdffdfde3f4cb46334a32892f660d29228146df9f93ac872af972'
 candidates=[p for p in HERE.parent.glob('bundle-relocated-js-*/plan.json') if sha(p)==expected]
 assert len(candidates)==1
 prior=candidates[0].parent;old=decode(json.loads((prior/'plan.json').read_text()));receipt=json.loads((prior/'receipt.json').read_text())
 assert receipt['planSHA256']==sha(prior/'plan.json') and receipt['status']=='INDEPENDENT_BUNDLE_FORTY_EIGHT_COMPLETE_JS_OBSERVATIONS_PASS'
 assert len(old['commands'])==2 and [c['seconds'] for c in old['commands']]==[30,5]
 prefix=[old['tools']['taskset'],'-c',str(old['tools']['cpu'])];oldfixture=Path(old['stage'])/'experiments/public-machine-handlers/candidate-v1/bundle-v1';oldgenerated=str(prior/'bundle.mjs')
 assert old['commands']==[{'label':'bundle-emit','argv':prefix+[old['tools']['tools']['bend'],str(oldfixture/'main.bend'),'-o',oldgenerated],'seconds':30,'generated':oldgenerated,'expected':0},{'label':'bundle-consume','argv':prefix+[old['tools']['tools']['node'],str(oldfixture/'consumer.mjs'),oldgenerated],'seconds':5,'expected':0}]
 # Historical receipt has ordered result-only commands; association is bound
 # by exact admitted command list, raw labels, and its frozen collector source.
 assert len(receipt['commands'])==2 and all(c['capture']=='split' for c in receipt['commands'])
 assert [c['exit'] for c in receipt['commands']]==[0,0] and all(c['failure'] is None for c in receipt['commands'])
 labels=[c['label'] for c in old['commands']]
 assert set(receipt['logs'])=={label+suffix for label in labels for suffix in ['.stdout','.stderr']}
 assert all(not (prior/(label+'.stderr')).read_bytes() for label in labels)
 assert len(old['executionProbeLabels'])==25 and receipt['probeCommandsExecuted']==25
 probeSet={str(prior/'execution-probes'/(label+suffix)) for label in old['executionProbeLabels'] for suffix in ['.json','.stdout','.stderr']}
 assert set(receipt['probePins'])==probeSet and {str(f) for f in (prior/'execution-probes').iterdir()}==probeSet
 for label in old['executionProbeLabels']:
  raw=json.loads((prior/'execution-probes'/(label+'.json')).read_text());assert raw['exit']==0 and raw['failure'] is None
 historicDoc=HERE/'historical-readiness-fe23fd7e.md';currentDoc=HERE.parent.parent/'readiness-v1/README.md'
 docKey=str(currentDoc.resolve());assert old['pins'][docKey]=='a9c5bbcd16b9b88757f18b2c5827e4b035d4067e2215e7f708d601fbdc7a0ba1' and sha(historicDoc)==old['pins'][docKey]
 assert all(sha(f)==digest for f,digest in old['pins'].items() if f!=docKey) and inventory(Path(old['stage']))==old['inventory']
 assert configs(prior,Path(old['stage']))==old['configurationStates']
 assert all(sha(prior/n)==digest for n,digest in receipt['logs'].items()) and all(sha(f)==digest for f,digest in receipt['probePins'].items()) and all(sha(f)==digest for f,digest in receipt['generated'].items())
 manifest=HERE/'source-review-manifest.json';m=json.loads(manifest.read_text())
 assert all(sha(f)==digest for f,digest in m['sourceFiles'].items()) and all(sha(f)==digest for f,digest in m['compilerAndClockSource'].items())
 original=HERE/'stage';out=HERE/('inspection-js-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(original,stage)
 files={Path(f) for f in old['pins'] if f!=docKey}|{historicDoc,currentDoc}|{prior/'plan.json',prior/'receipt.json',manifest,Path(__file__).resolve(),BOUNDARY,TOOL,ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'}
 files.update(prior/n for n in receipt['logs']);files.update(Path(f) for f in receipt['probePins']);files.update(Path(f) for f in receipt['generated']);files.update(Path(f) for f in m['sourceFiles']);files.update(Path(f) for f in m['compilerAndClockSource'])
 files.update(f for f in original.rglob('*') if f.is_file())
 sourceNotice=HERE/'development-clock-source-1791442786008956162';files.update(f for f in sourceNotice.iterdir() if f.is_file())
 files.update(f for f in (HERE/'development-source-1791442462932997662').iterdir() if f.is_file())
 ep=out/'private-environment.json';oldenv=Path(old['privateEnvironment']);assert sha(oldenv)==old['environmentSHA256'];ep.write_bytes(oldenv.read_bytes());ep.chmod(0o600);assert sha(ep)==old['environmentSHA256'];files.add(oldenv);validate_node_environment(json.loads(ep.read_text()))
 tools=old['tools'];cfg=P.configuration();assert cfg['cpu']==tools['cpu']==8 and cfg['taskset']==tools['taskset']
 assert all(Path(cfg['tools'][n]).resolve()==Path(target).resolve() for n,target in tools['tools'].items())
 prefix=[tools['taskset'],'-c',str(tools['cpu'])];fixture=stage/'experiments/public-machine-handlers/candidate-v1/bundle-v1';generated=out/'inspection.mjs'
 consumer=HERE/'bend-consumer.mjs';files.add(consumer);files.add(HERE/'common-expected.json')
 commands=[{'label':'clock-inspection-emit','argv':prefix+[tools['tools']['bend'],str(fixture/'inspection-main.bend'),'-o',str(generated)],'seconds':30,'generated':str(generated),'expected':0},{'label':'common-correctness-consume','argv':prefix+[tools['tools']['node'],str(consumer),str(generated)],'seconds':5,'expected':0}]
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'environmentSHA256':sha(ep),'privateEnvironment':str(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':current_configs(out,stage,tools),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(5) for n in ['bend','node','python','taskset','clang']],'historicalDocumentationJoin':{'originalPath':docKey,'historicalSHA256':old['pins'][docKey],'archive':str(historicDoc),'gitCommit':'fe23fd7e3ed4f0cad1073b6c350b9598807a2773','currentSHA256':sha(currentDoc),'scope':'Documentation-only pin; all executable/tool/config/raw/generated prerequisite pins remain exact.'},'sourceReviewManifestSHA256':sha(manifest),'scope':'Fresh thin clock IO emission inspection plus actual SAME-OWNER full42 common correctness; consumer NEVER calls clock_inspection. CPU8 emit30/Node5/25 guard probes. No elapsed measurements, population/sample choice, timing boundary proof, Native or delivery credit.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));planSHA=sha(path);stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def source_guard():
  assert sha(path)==planSHA
  validate_node_environment(env)
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert current_configs(out,stage,p['tools'])==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];assert all(sha(path)==digest for path,digest in generated.items());ledger.guard()
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
    if c.get('generated'):assert c['generated'] in generated,'emission did not produce admitted output'
   assert ledger.index==25
   r['status']='CLOCK_CODE_EMISSION_AND_FULL42_CORRECTNESS_PASS_NO_TIMING_CREDIT'
  except BaseException as e:
   if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
   raise
 print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args()
prepare() if args.prepare else run(args.run)
