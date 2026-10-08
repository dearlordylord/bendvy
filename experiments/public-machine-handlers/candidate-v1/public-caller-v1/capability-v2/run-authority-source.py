"""Fresh two-helper closure full normal and foreign JS runtime qualification."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time,fcntl
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
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

def prepare():
 prior=HERE.parent/'cheap-js-1791432084271257355';old=decode(json.loads((prior/'plan.json').read_text()));receipt=json.loads((prior/'receipt.json').read_text())
 assert receipt['status']=='INDEPENDENT_CALLER_FOURTEEN_COMPLETE_JS_OBSERVATIONS_PASS' and receipt['planSHA256']==sha(prior/'plan.json')
 assert all(sha(f)==digest for f,digest in old['pins'].items()) and inventory(Path(old['stage']))==old['inventory'] and configs(prior,Path(old['stage']))==old['configurationStates']
 assert all(sha(prior/n)==digest for n,digest in receipt['logs'].items()) and all(sha(f)==digest for f,digest in receipt['probePins'].items())
 manifest=HERE/'source-review-manifest.json';m=json.loads(manifest.read_text());assert sha(manifest)=='3e0737a1bbfbd340177f7f6769c2ea6185f1ad9a079e436f74a23e820b597eb3'
 assert all(sha(HERE/n)==digest for n,digest in m['source'].items())
 out=HERE/('authority-source-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir()
 files={Path(f) for f in old['pins']}|{prior/'plan.json',prior/'receipt.json',manifest,Path(__file__).resolve()}
 files.update(prior/n for n in receipt['logs']);files.update(Path(f) for f in receipt['probePins'])
 for rel,digest in m['stageClosure'].items():
  original=HERE.parent/'development-stage-capability-v2'/rel;assert sha(original)==digest
  dest=stage/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(original,dest);files.add(original)
 fixture=stage/'experiments/public-machine-handlers/candidate-v1/public-caller-v1/capability-v2'
 names=['main','authority-positive','negative-undeclared','negative-read-write','negative-cross-schema','negative-owner-duplication']
 for name in names:
  original=HERE/(name+'.bend');assert sha(original)==m['source'][name+'.bend'];shutil.copyfile(original,fixture/(name+'.bend'));files.add(original)
 ep=out/'private-environment.json';original=Path(old['privateEnvironment']);assert sha(original)==old['environmentSHA256'];ep.write_bytes(original.read_bytes());ep.chmod(0o600);files.add(original)
 tools=old['tools'];cfg=P.configuration();assert cfg['cpu']==tools['cpu']==8 and cfg['taskset']==tools['taskset']
 assert all(Path(cfg['tools'][n]).resolve()==Path(target).resolve() for n,target in tools['tools'].items())
 prefix=[tools['taskset'],'-c',str(tools['cpu'])]
 commands=[{'label':name,'argv':prefix+[tools['tools']['bend'],str(fixture/(name+'.bend')),'--check-only'],'seconds':5,'expected':1 if name.startswith('negative') else 0} for name in names]
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'environmentSHA256':sha(ep),'privateEnvironment':str(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(13) for n in ['bend','node','python','taskset','clang']],'sourceReviewManifestSHA256':sha(manifest),'scope':'Six current capability caller source5 subjects fullmain/matchedWorkpositive/four raw UNCLASSIFIED negative diagnostics,65 ordinaryguards. Exact positive rawtyping; four negative raw outcomes grant no intended authority acceptance before independent complete diagnostic review. No mathematical proof/runtime/Native/adoption.'}
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
  assert all(sha(f)==h for f,h in p['pins'].items()) and inventory(stage)==p['inventory'] and configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];ledger.guard()
 def guard():
  source_guard();P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'classifications':{},'scope':p['scope'],'completeIssue49':False,'proofCredit':False}
 try:
  guard()
  for c in p['commands']:
   guard()
   try: result=runner.run(c['label'],c['argv'],c['seconds'],expected=c['expected'])
   finally: logs.guard();guard()
   r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']});intended(c['label'],result);r['classifications'][c['label']]='UNCLASSIFIED_RAW_NEGATIVE_NO_AUTHORITY_ACCEPTANCE' if c['expected']==1 else 'EXACT_TYPING_ONLY_POSITIVE'
  assert ledger.index==65;logs.guard();source_guard();r['status']='CURRENT_CAPABILITY_CALLER_MATCHED_SOURCE_AND_FOUR_RAW_REFUSALS_COLLECTED_UNCLASSIFIED'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:
  try: logs.guard();source_guard()
  except BaseException: r['status']='INCOMPLETE';raise
  finally:r.update(logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args()
prepare() if args.prepare else run(args.run)
