"""Fresh two-helper staged foreign Native14-row runtime control."""
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

def prepare():
 # Metadata only; fresh IO seam emits both real7-row/schema foreign applications.
 prior=Path(args.normal_run).resolve();assert prior.is_relative_to(HERE/'development')
 old=decode(json.loads((prior/'plan.json').read_text()));receipt=json.loads((prior/'receipt.json').read_text())
 assert receipt['status']=='STAGED_HANDLER_HELPERS_NORMAL_NATIVE_FULL96_AND12_UNION_PASS' and receipt['planSHA256']==sha(prior/'plan.json')
 assert receipt['probeCommandsExecuted']==65 and all(x['failure'] is None and x['exit']==0 for x in receipt['commands'])
 reconciliationPath=HERE/'development/handler-helper-native-finalization-failure/reconciliation.json';assert sha(reconciliationPath)=='f4101e0272a82a4349e53b3807929f77df24d492c31bf968bc5bfffa106225e3';reconciliation=json.loads(reconciliationPath.read_text());assert reconciliation['status']=='READ_ONLY_NATIVE_SUBJECTS_AND_EXPLICIT_DERIVED_UNION_RECONCILED' and reconciliation['receiptSHA256']==sha(prior/'receipt.json') and reconciliation['planSHA256']==sha(prior/'plan.json') and reconciliation['historicalTerminalExit']==1 and reconciliation['originalReceiptNotTerminalAcceptance'] and not reconciliation['backendReplay']
 assert all(sha(path)==digest for path,digest in old['pins'].items()) and inventory(Path(old['stage']))==old['inventory']
 assert configs(prior,Path(old['stage']))==old['configurationStates']
 assert all(sha(prior/name)==digest for name,digest in receipt['logs'].items()) and all(sha(path)==digest for path,digest in receipt['generated'].items())
 out=HERE/'development'/('handler-helper-foreign-native-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage)
 fixture=stage/'experiments/public-machine-handlers/candidate-v1';entry=fixture/'full-foreign-native.bend'
 qualified=HERE/'development/adoption-foreign-native-1791419366637172002';qualifiedPlan=decode(json.loads((qualified/'plan.json').read_text()));qualifiedReceipt=json.loads((qualified/'receipt.json').read_text());assert qualifiedReceipt['status']=='PROPOSED_HANDLER_EXTRACTION_NATIVE_FOREIGN_TWO_SCHEMAS_COMPLETE7_ROWS_EACH_PASS' and qualifiedReceipt['planSHA256']==sha(qualified/'plan.json');assert sha(HERE/entry.name)==qualifiedPlan['newIOSeam']['sha256'];shutil.copyfile(HERE/entry.name,entry)
 needed=set();closure(entry,needed);assert all(x.is_relative_to(stage) for x in needed)
 assert all(sha(f)==digest for f,digest in old['tools']['pins'].items())
 files={reconciliationPath,Path(reconciliation['terminalObservation']),HERE/'reconcile-handler-helper-native-finalization.py'}|{Path(x) for x in old['pins']}|{Path(f) for f in old['tools']['pins']}|{qualified/'plan.json',qualified/'receipt.json'}|{prior/'plan.json',prior/'receipt.json',HERE/entry.name,Path(__file__).resolve()}
 files.update(prior/name for name in receipt['logs']);files.update(Path(x) for x in receipt['generated']);files.update(Path(x) for x in receipt['probePins'])
 for path,digest in receipt['probePins'].items():assert sha(path)==digest
 originalEnvironment=Path(old['privateEnvironment']);assert sha(originalEnvironment)==old['environmentSHA256'];files.add(originalEnvironment)
 ep=out/'private-environment.json';ep.write_bytes(originalEnvironment.read_bytes());ep.chmod(0o600);assert sha(ep)==old['environmentSHA256']
 cfg=P.configuration();assert cfg['cpu']==old['tools']['cpu']==8 and cfg['taskset']==old['tools']['taskset'];assert set(cfg['tools'])==set(old['tools']['tools']) and all(Path(cfg['tools'][name]).resolve()==Path(target).resolve() for name,target in old['tools']['tools'].items());prefix=[old['tools']['taskset'],'-c',str(old['tools']['cpu'])];code=out/'foreign.c';binary=out/'foreign-native'
 commands=[{'label':'foreign-emit','argv':prefix+[old['tools']['tools']['bend'],str(entry),'-o',str(code)],'seconds':30,'generated':str(code)},{'label':'foreign-clang','argv':prefix+[old['tools']['tools']['clang-wrapper'],'-O3',str(code),'-pthread','-lm','-o',str(binary)],'seconds':120,'generated':str(binary)},{'label':'foreign-run','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'foreignOracle':True}]
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':old['tools'],'environmentSHA256':sha(ep),'privateEnvironment':str(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(7) for n in ['bend','node','python','taskset','clang']],'sourceMapping':old['sourceMapping'],'normalNativeQualification':{'receipt':str(prior/'receipt.json'),'sha256':sha(prior/'receipt.json'),'originalTerminalExit':1,'reconciliation':str(reconciliationPath),'reconciliationSHA256':sha(reconciliationPath)},'newIOSeam':{'source':str(HERE/entry.name),'sha256':sha(HERE/entry.name),'scope':'Only append two existing actual7-row/schema foreign applications and print original strings; no world/handler/oracle changes'},'scope':'Three prospective-core Native foreign subjects emit30/clang120/run5/35ordinaryguards; complete7physical rows eachschemaA/B exact concatenated independentforeignoracle. Fresh IO-only print seam, same developmental source7/zero probes+freshJS4/45+normalNative6/65 core/root4 closure and privateClang snapshot/environment; no baseline/JS/sourcechecker replay/oldC reuse. Refusal before realregisteredcallback/Local access, owners/cursors/pending/world preserved. Three relocatedsemanticmutants/regression/math/adoption/issueclosure unqualified.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))

def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 generated={};ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def source_guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];assert all(sha(f)==h for f,h in generated.items());ledger.guard()
 def guard():
  source_guard();P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'completeIssue49':False,'proofCredit':False,'productionAdopted':False}
 expected=json.loads((stage/'experiments/public-machine-handlers/candidate-v1/full-foreign-expected.json').read_text());assert set(expected)=={'schemaA','schemaB'} and all(len(x)==7 for x in expected.values());wanted=('\n'.join(expected['schemaA']+expected['schemaB'])+'\n').encode()
 try:
  guard()
  for c in p['commands']:
   guard()
   if c.get('generated'):assert not Path(c['generated']).exists()
   try:
    result=runner.run(c['label'],c['argv'],c['seconds'])
   finally:
    try:
     if c.get('generated') and Path(c['generated']).is_file():
      generated[c['generated']]=sha(c['generated']);runner.inputs=T.Inputs(files=[path,ep,*p['pins'],*generated],directories=[stage])
    finally:
     logs.guard();guard()
   r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
   assert not result['stderr'],'unexpected emission/compile/runtime stderr'
   if c.get('generated'):assert c['generated'] in generated
   if c.get('foreignOracle'):assert result['stdout']==wanted,'complete both-schema14 physical foreign rows differ'
  assert ledger.index==35;logs.guard();source_guard();r['status']='STAGED_HANDLER_HELPERS_NATIVE_FOREIGN_TWO_SCHEMAS_COMPLETE7_ROWS_EACH_PASS'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:
  try:
   logs.guard();source_guard()
  except BaseException as finalError:
   r['status']='INCOMPLETE';r['finalizationError']=str(finalError);raise
  finally:
   r.update(generated=generated,logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--normal-run');args=parser.parse_args()
prepare() if args.prepare else run(args.run)
