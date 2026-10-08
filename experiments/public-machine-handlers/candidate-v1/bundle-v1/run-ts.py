"""Actual pinned TS42 common comparator, retaining complete raw; no full48 authority mapping."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time,fcntl
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
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
def configs(out,stage,include_reference=True):
 paths=set()
 names=['check.json','bend.json','bender.json','package.json','.bend.json','bend.config.json']
 if include_reference:names+=['tsconfig.json','.node-version','.nvmrc','.npmrc']
 extraParents=[f.parent for f in Path('/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src').rglob('*.ts')]+[f.parent for f in stage.rglob('*.mjs')] if include_reference else []
 for root in [ROOT,Path.cwd(),out,stage,stage/'src/ecs',stage/'experiments/public-machine-handlers/candidate-v1',*[p.parent for p in stage.rglob('*.bend')]]+([Path('/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src')] if include_reference else [])+extraParents:
  for parent in [root,*root.parents]:
   for name in names:paths.add(parent/name)
 for name in names:paths.add(Path('/home/node/.bend')/name)
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
 prior=HERE/'bundle-js-1791435891914821638';old=decode(json.loads((prior/'plan.json').read_text()));receipt=json.loads((prior/'receipt.json').read_text())
 assert receipt['status']=='INDEPENDENT_BUNDLE_FORTY_EIGHT_COMPLETE_JS_OBSERVATIONS_PASS' and receipt['planSHA256']==sha(prior/'plan.json')
 assert all(sha(f)==digest for f,digest in old['pins'].items()) and inventory(Path(old['stage']))==old['inventory'] and configs(prior,Path(old['stage']),include_reference=False)==old['configurationStates']
 assert all(sha(prior/n)==digest for n,digest in receipt['logs'].items()) and all(sha(f)==digest for f,digest in receipt['probePins'].items()) and all(sha(f)==digest for f,digest in receipt['generated'].items())
 manifest=HERE/'source-review-manifest.json';m=json.loads(manifest.read_text());assert sha(manifest)=='3d7c5224bbf27173a0488a8ebccb64eca0a82dcf3be23059a855ac80c470ad3b'
 assert all(sha(HERE/n)==digest for n,digest in m['source'].items())
 originalStage=Path(m['stage']);assert inventory(originalStage)==m['stageInventory'] and all(sha(f)==digest for f,digest in m['sourceClosure'].items())
 actualRoot=Path('/workspace/formal-proofs/bendvy');assert all(sha(actualRoot/n)==digest for n,digest in m['rootCoreByteJoins'].items())
 out=HERE/('bundle-TS-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(originalStage,stage)
 files={Path(f) for f in old['pins']}|{prior/'plan.json',prior/'receipt.json',manifest,Path(__file__).resolve(),BOUNDARY,TOOL,ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'}
 files.update(prior/n for n in receipt['logs']);files.update(Path(f) for f in receipt['probePins']);files.update(Path(f) for f in receipt['generated']);files.update(Path(f) for f in m['sourceClosure']);files.update(HERE/n for n in m['source']);files.update(actualRoot/n for n in m['rootCoreByteJoins'])
 files.update(f for f in originalStage.rglob('*') if f.is_file())
 failed=HERE/'bundle-TS-1791437104734996072';fp=decode(json.loads((failed/'plan.json').read_text()));fr=json.loads((failed/'receipt.json').read_text())
 assert sha(failed/'plan.json')=='1438b839174991ea4b3f36fdc11844040df886bc2c5ccdf70b1993ed938656da'==fr['planSHA256'] and fr['status']=='INCOMPLETE'
 assert inventory(Path(fp['stage']))==fp['inventory'];assert all(sha(failed/n)==digest for n,digest in fr['logs'].items()) and all(sha(f)==digest for f,digest in fr['probePins'].items())
 files.update(f for f in failed.rglob('*') if f.is_file() and f.name!='private-environment.json')
 files.update(f for f in (HERE/'history-ts1438-before-reader-activation').rglob('*') if f.is_file())

 fixture=stage/'experiments/public-machine-handlers/candidate-v1/bundle-v1'
 tsManifest=HERE/'ts-source-review-manifest.json';assert sha(tsManifest)=='ebcd303afd54d0ec1daa3725bf7d5fb1660b213c182405fc72fb786a302f283c';tm=json.loads(tsManifest.read_text());files.add(tsManifest)
 assert all(sha(HERE/n)==digest for n,digest in tm['source'].items())
 referenceRoot=Path('/workspace/formal-proofs/bendvy/.references/bevy-ts');referenceCore=referenceRoot/'packages/core/src'
 actualCore={str(f.relative_to(referenceRoot)):sha(f) for f in referenceCore.rglob('*') if f.is_file()};assert actualCore==tm['pinnedTSSource']['coreInventory']
 files.update(referenceRoot/n for n in actualCore);files.add(Path(tm['pinnedTSSource']['sourceManifest']));assert sha(Path(tm['pinnedTSSource']['sourceManifest']))==tm['pinnedTSSource']['sourceManifestSHA256']
 for n in tm['source']:
  files.add(HERE/n);shutil.copyfile(HERE/n,fixture/n)

 ep=out/'private-environment.json';original=Path(old['privateEnvironment']);assert sha(original)==old['environmentSHA256'];ep.write_bytes(original.read_bytes());ep.chmod(0o600);assert sha(ep)==old['environmentSHA256'];files.add(original);validate_node_environment(json.loads(ep.read_text()))
 tools=old['tools'];cfg=P.configuration();assert cfg['cpu']==tools['cpu']==8 and cfg['taskset']==tools['taskset']
 assert all(Path(cfg['tools'][n]).resolve()==Path(target).resolve() for n,target in tools['tools'].items())
 prefix=[tools['taskset'],'-c',str(tools['cpu'])]
 commands=[{'label':'bundle-TS-consume','argv':prefix+[tools['tools']['node'],str(fixture/'consumer-ts.mjs'),str(fixture/'reference-ts.mjs')],'seconds':5,'expected':0}]
 plan={'tsCoreRoot':str(referenceCore),'tsCoreInventory':inventory(referenceCore),'tsSourceReviewManifestSHA256':sha(tsManifest),'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'environmentSHA256':sha(ep),'privateEnvironment':str(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(3) for n in ['bend','node','python','taskset','clang']],'sourceReviewManifestSHA256':sha(manifest),'historicalToolSnapshot':{'plan':str(prior/'plan.json'),'receipt':str(prior/'receipt.json')},'scope':'Actual pinned TS Node5 CPU8/15 guards compares42 common semantic records and retains complete raw debug/result/stream/history. FullBend48 prerequisite remains unchanged; six Bend-specific authority/restoration records not fabricated as TS. No Native/full49/performance/adoption/proof credit.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def source_guard():
  validate_node_environment(env)
  assert inventory(Path(p['tsCoreRoot']))==p['tsCoreInventory']
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];assert all(sha(path)==digest for path,digest in generated.items());ledger.guard()
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
      generated[c['generated']]=sha(c['generated']);runner.inputs=T.Inputs(files=[path,ep,*p['pins'],*generated],directories=[stage])
    with E.GuardBoundary([('generated consumer input registration',register_generated),('subject logs',logs.guard),('source/tool/config/environment/generated/probe ledger',guard)]):
     if c.get('generated'):assert not Path(c['generated']).exists(),'generated output already exists'
     result=runner.run(c['label'],c['argv'],c['seconds'],expected=c['expected'])
    r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
    assert not result['stderr'],'unexpected emission/runtime stderr'
    if c.get('generated'):assert c['generated'] in generated,'emission did not produce admitted output'
   assert ledger.index==15
   r['status']='ACTUAL_PINNED_TS_FORTY_TWO_COMMON_WITH_COMPLETE_RAW_PASS'
  except BaseException as e:
   if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
   raise
 print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args()
prepare() if args.prepare else run(args.run)
