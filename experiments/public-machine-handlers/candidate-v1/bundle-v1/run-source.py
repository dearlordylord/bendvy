"""Current typed single-machine bundle finite source/runtime cohort."""
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
 prior=HERE.parent/'public-caller-v1/capability-v2/cheap-js-1791432710709125093';old=decode(json.loads((prior/'plan.json').read_text()));receipt=json.loads((prior/'receipt.json').read_text())
 assert receipt['status']=='INDEPENDENT_CALLER_FOURTEEN_COMPLETE_JS_OBSERVATIONS_PASS' and receipt['planSHA256']==sha(prior/'plan.json')
 assert all(sha(f)==digest for f,digest in old['pins'].items()) and inventory(Path(old['stage']))==old['inventory'] and configs(prior,Path(old['stage']))==old['configurationStates']
 assert all(sha(prior/n)==digest for n,digest in receipt['logs'].items()) and all(sha(f)==digest for f,digest in receipt['probePins'].items()) and all(sha(f)==digest for f,digest in receipt['generated'].items())
 manifest=HERE/'source-review-manifest.json';m=json.loads(manifest.read_text());assert sha(manifest)=='3d7c5224bbf27173a0488a8ebccb64eca0a82dcf3be23059a855ac80c470ad3b'
 assert all(sha(HERE/n)==digest for n,digest in m['source'].items())
 originalStage=Path(m['stage']);assert inventory(originalStage)==m['stageInventory'] and all(sha(f)==digest for f,digest in m['sourceClosure'].items())
 actualRoot=Path('/workspace/formal-proofs/bendvy');assert all(sha(actualRoot/n)==digest for n,digest in m['rootCoreByteJoins'].items())
 out=HERE/('bundle-source-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(originalStage,stage)
 files={Path(f) for f in old['pins']}|{prior/'plan.json',prior/'receipt.json',manifest,Path(__file__).resolve(),BOUNDARY,TOOL,ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'}
 files.update(prior/n for n in receipt['logs']);files.update(Path(f) for f in receipt['probePins']);files.update(Path(f) for f in receipt['generated']);files.update(Path(f) for f in m['sourceClosure']);files.update(HERE/n for n in m['source']);files.update(actualRoot/n for n in m['rootCoreByteJoins'])
 files.update(f for f in originalStage.rglob('*') if f.is_file())
 fixture=stage/'experiments/public-machine-handlers/candidate-v1/bundle-v1'
 ep=out/'private-environment.json';original=Path(old['privateEnvironment']);assert sha(original)==old['environmentSHA256'];ep.write_bytes(original.read_bytes());ep.chmod(0o600);assert sha(ep)==old['environmentSHA256'];files.add(original);validate_node_environment(json.loads(ep.read_text()))
 tools=old['tools'];cfg=P.configuration();assert cfg['cpu']==tools['cpu']==8 and cfg['taskset']==tools['taskset']
 assert all(Path(cfg['tools'][n]).resolve()==Path(target).resolve() for n,target in tools['tools'].items())
 prefix=[tools['taskset'],'-c',str(tools['cpu'])]
 names=['main','authority-positive','negative-other-machine','negative-cross-schema-requirements','negative-owner-duplication','negative-read-write','negative-undeclared']
 commands=[{'label':name,'argv':prefix+[tools['tools']['bend'],str(fixture/(name+'.bend')),'--check-only'],'seconds':5,'expected':1 if name.startswith('negative') else 0} for name in names]
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'environmentSHA256':sha(ep),'privateEnvironment':str(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(15) for n in ['bend','node','python','taskset','clang']],'sourceReviewManifestSHA256':sha(manifest),'historicalToolSnapshot':{'plan':str(prior/'plan.json'),'receipt':str(prior/'receipt.json')},'scope':'Seven bundle source5 subjects/75 guardprobes CPU8: two exact58typing positives and five UNCLASSIFIED raw concrete refusals. Complete diagnostic independentreview required before intendedauthorityacceptance. Currentarbitraryarity singlemachine48fulloracle retained; no runtime/mathproof/adoption/full49/latekey policy credit.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def intended(label,result):
 if not label.startswith('negative'):
  assert result['stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and not result['stderr'];return
 # Negative raw diagnostics remain UNCLASSIFIED until independent full-location review.
 return
def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def source_guard():
  validate_node_environment(env)
  assert all(sha(f)==h for f,h in p['pins'].items()) and inventory(stage)==p['inventory'] and configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];ledger.guard()
 def guard():
  source_guard();P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'classifications':{},'scope':p['scope'],'completeIssue49':False,'proofCredit':False}
 def receipt_metadata():
  r.update(logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index)
 with E.ReceiptBoundary(r,out/'receipt.json',[('receipt metadata',receipt_metadata),('subject logs',logs.guard),('source/config/environment/probe ledger',source_guard)]):
  try:
   guard()
   for c in p['commands']:
    guard()
    with E.GuardBoundary([('subject logs',logs.guard),('source/tool/config/environment/probe ledger',guard)]):
     result=runner.run(c['label'],c['argv'],c['seconds'],expected=c['expected'])
    r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']});intended(c['label'],result);r['classifications'][c['label']]='UNCLASSIFIED_RAW_NEGATIVE_NO_AUTHORITY_ACCEPTANCE' if c['expected']==1 else 'EXACT_TYPING_ONLY_POSITIVE'
   assert ledger.index==75
   r['status']='CURRENT_BUNDLE_MATCHED_SOURCE_AND_FIVE_RAW_REFUSALS_COLLECTED_UNCLASSIFIED'
  except BaseException as e:
   if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
   raise
 print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args()
prepare() if args.prepare else run(args.run)
