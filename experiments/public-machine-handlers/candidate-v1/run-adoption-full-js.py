"""Fresh resolver-guarded authority sources and retained complete JS controls; no baseline replay."""
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
 source=HERE/'development/adoption-source-controls-1791417894671205302'
 old=decode(json.loads((source/'plan.json').read_text()));receipt=json.loads((source/'receipt.json').read_text())
 assert receipt['status']=='PROPOSED_HANDLER_EXTRACTION_SEVEN_SOURCE_CONTROLS_PASS_NO_RUNTIME' and receipt['planSHA256']==sha(source/'plan.json')
 assert receipt['probeCommandsExecuted']==75 and all(x['failure'] is None for x in receipt['commands'])
 assert all(sha(path)==digest for path,digest in old['pins'].items()) and inventory(Path(old['stage']))==old['inventory']
 assert all(sha(source/name)==digest for name,digest in receipt['logs'].items())
 out=HERE/'development'/('adoption-full-js-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage)
 files={Path(x) for x in old['pins']}|{source/'plan.json',source/'receipt.json',Path(__file__).resolve()}
 files.update(source/name for name in receipt['logs']);files.update(Path(x) for x in receipt['probePins'])
 for path,digest in receipt['probePins'].items():assert sha(path)==digest
 fixture=stage/'experiments/public-machine-handlers/candidate-v1'
 for name in ['full-driver-v2-consumer.mjs','full-foreign-consumer.mjs','full-expected.json','full-foreign-expected.json','full-oracle.py','full-foreign-oracle.py']:
  original=HERE/name;shutil.copyfile(original,fixture/name);files.add(original)
 # Select exact tracked comparator and retain its historical semantic capsule.
 reference=load(ROOT/'scripts/selected_reference.py','selected_reference')
 selected=reference.binding(ROOT,ROOT/'experiments/public-machine-handlers/delivery-manifest.json','experiments/public-machine-handlers/reference-v3.mjs')
 files.update([ROOT/'scripts/selected_reference.py',Path(selected['manifest']),Path(selected['reference'])])
 historical=ROOT/'experiments/public-machine-handlers/portable-reference-v1'
 for name in ['manifest.json','REPORT.md','objects.tar.gz']:files.add(historical/name)
 oracleManifest=HERE/'delivery-driver-native-v1/manifest.json';files.add(oracleManifest)
 ep=out/'private-environment.json';ep.write_bytes(Path(old['privateEnvironment']).read_bytes());ep.chmod(0o600)
 prefix=old['commands'][0]['argv'][:4];tools=old['tools'];node=tools['tools']['node'] if 'tools' in tools else None
 # Existing owned configuration supplies paths; snapshot and environment remain pinned.
 cfg=P.configuration();node=cfg['tools']['node'];commands=[]
 for label,entry,consumer,expected in [('full96-and12','full-driver-v2.bend','full-driver-v2-consumer.mjs','full-expected.json'),('foreign-two-schemas','full-foreign-controls.bend','full-foreign-consumer.mjs','full-foreign-expected.json')]:
  generated=out/(label+'.mjs')
  commands.append({'label':label+'-emit','argv':prefix+[str(fixture/entry),'-o',str(generated)],'seconds':30,'expected':0,'generated':str(generated)})
  commands.append({'label':label+'-consume','argv':[node,str(fixture/consumer),str(generated),str(fixture/expected)],'seconds':5,'expected':0})
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'environmentSHA256':sha(ep),'privateEnvironment':str(ep),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(9) for n in ['bend','node','python','taskset','clang']],'selectedReference':selected,'sourceMapping':old['sourceMapping'],'sourceQualificationReceipt':str(source/'receipt.json'),'scope':'Four changed-production-closure JS subjects emit30/Node5 for unchanged full96+12 runtime driver and complete7rows/schema actual foreign controls. Reuse exact source7/75 ordinary typing/refusal receipt and tooling snapshot only; new stage/raw/generated guards. Actual selected TS semantic capsule remains historical, not reexecuted. INTERNAL Data handler helper, no new #53ownership/capture laws. Native/currentclosure3mutants/regression/adoption/issue closure still pending. No proof/performance credit.'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))

def run(path):
 lock=open('/tmp/bendvy-parity-heavy.lock','a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);ep=Path(p['privateEnvironment']);assert sha(ep)==p['environmentSHA256'];env=json.loads(ep.read_text());os.environ.clear();os.environ.update(env)
 ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env)
 def guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(ep)==p['environmentSHA256'];assert all(sha(path)==digest for path,digest in generated.items());P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 generated={}
 reference=load(ROOT/'scripts/selected_reference.py','selected_reference')
 reference.verify(ROOT,p['selectedReference'])
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,ep,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split');r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope'],'completeIssue49':False,'proofCredit':False}
 try:
  guard()
  for c in p['commands']:
   guard();result=runner.run(c['label'],c['argv'],c['seconds'],expected=c['expected']);r['commands'].append({k:v for k,v in result.items() if k not in ['stdout','stderr']})
   assert not result['stderr'],'unexpected emission/runtime stderr'
   if c.get('generated'):generated[c['generated']]=sha(c['generated'])
   guard()
  reference.verify(ROOT,p['selectedReference']);assert ledger.index==45;r['status']='PROPOSED_HANDLER_EXTRACTION_FULL96_AND12_PLUS_FOREIGN_JS_PASS'
 except BaseException as e:
  r['error']=str(e)
  if hasattr(e,'result'):r['failedCommand']={k:v for k,v in e.result.items() if k not in ['stdout','stderr']}
  raise
 finally:
  r.update(generated=generated,logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)

parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args()
prepare() if args.prepare else run(args.run)
