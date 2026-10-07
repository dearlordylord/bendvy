"""Focused frozen complete-snapshot JS/Native development cohort."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6];HERE=Path(__file__).resolve().parent
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
 for root in [ROOT,Path.cwd(),out,stage,stage/'src/ecs',stage/'experiments/public-relations/promotion-stage']:
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
 configuration=P.configuration();configuration['execute']=ledger.execute;configuration['env']=ledger.env;return configuration


S=load(Path('/workspace/formal-proofs/bendvy/scripts/selected_reference.py'),'selected_reference')
F=load(HERE.parents[1]/'trace-cheap.py','summary')
REUSE=HERE/'normal-runtime-reuse.json'
ORACLE=HERE/'expected/fanout-256-span-1-seed-0.json'
ARGS=['fanout','256','1','0']
def source_and_artifact_join():
 binding=json.loads(REUSE.read_text());joins=json.loads((HERE.parent/'source-closure.json').read_text());pins={};history=[]
 for role in ['historicalJS','currentNative']:
  b=binding['bindings'][role];path=Path(b['plan']);assert sha(path)==b['planSHA256'];receiptpath=path.parent/'receipt.json';assert sha(receiptpath)==b['receiptSHA256'];plan=decode(json.loads(path.read_text()));receipt=json.loads(receiptpath.read_text());assert receipt['generated']==b['generated']
  for name,digest in b['generated'].items():assert sha(name)==digest;pins[Path(name)]=digest
  for name,digest in b['sourcePins'].items():
   if role=='historicalJS' and name.endswith('/operations.bend'):
    j=joins['qualifiedSourceByteJoins'][0];assert digest==j['qualifiedSourceSha256'] and sha(name)==j['liveDeliverySha256']
    import tarfile
    with tarfile.open(HERE.parent/'evidence-v1/objects.tar.gz') as t:old=t.extractfile(digest).read()
    assert hashlib.sha256(old).hexdigest()==digest and old.rstrip(b'\n')+b'\n'==Path(name).read_bytes()
   else:assert sha(name)==digest
   pins[Path(name)]=sha(name)
  for name,digest in plan['tools']['pins'].items():assert sha(name)==digest;pins[Path(name)]=digest
  for name,digest in plan['configurationStates'].items():assert (sha(name) if Path(name).is_file() else None)==digest
  assert inventory(Path(plan['stage']))==plan['inventory']
  history.append({'role':role,'plan':str(path),'planSHA256':sha(path),'receipt':str(receiptpath),'receiptSHA256':sha(receiptpath),'configurationStates':plan['configurationStates'],'stage':plan['stage'],'inventory':plan['inventory']})
  pins[path]=sha(path);pins[receiptpath]=sha(receiptpath)
 for name,digest in joins['sourceFiles'].items():assert sha(ROOT/name)==digest;pins[ROOT/name]=digest
 return pins,history,binding

def prepare():
 originalpins,history,binding=source_and_artifact_join();reference=S.binding(ROOT,HERE.parent/'delivery-files.json',(HERE.parent/'reference.mjs').relative_to(ROOT));assert sha(ORACLE)==binding['expected']['cases'][1]['sha256']
 # Full actual installed core import root pinned conservatively, including every local static import.
 tsroot=Path('/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src');tsfiles=list(tsroot.rglob('*.ts'));assert tsfiles
 out=ROOT/'.artifacts'/('relations-normal-first-'+str(time.time_ns()));out.mkdir();stage=out/'no-source-stage';stage.mkdir();env=P.configuration()['env']
 files=set(originalpins)|set(tsfiles)|{Path(__file__).resolve(),REUSE,ORACLE,HERE/'expected/manifest.json',HERE.parent/'oracle.py',HERE.parents[1]/'trace-cheap.py',Path(reference['manifest']),Path(reference['reference']),Path(S.__file__),TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'}
 inputs=T.Inputs(files=files,directories=[tsroot]);ledger=ProbeLedger(out/'prepare-probes',['prepare-ldd-'+name for name in ['bend','node','python','taskset','clang']],inputs,env)
 tools=P.shared.snapshot(**owned_configuration(ledger));assert ledger.index==5
 prep={'status':'OWNED_TOOL_PREPARATION_PASS','probePins':ledger.pins(),'probeCommandsExecuted':5};(out/'prepare-receipt.json').write_text(json.dumps(prep,indent=2)+'\n');files.update(map(Path,ledger.pins()));files.add(out/'prepare-receipt.json');files.update(map(Path,tools['pins']));private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600)
 js=next(iter(binding['bindings']['historicalJS']['generated']));native=next(p for p in binding['bindings']['currentNative']['generated'] if not p.endswith('.c'))
 commands=[{'label':'ts','argv':['taskset','-c','5','node',reference['reference'],*ARGS],'seconds':5},{'label':'js','argv':['taskset','-c','5','node',js,*ARGS],'seconds':5},{'label':'native','argv':['taskset','-c','5',native,'--threads','1','--gpu','off',*ARGS],'seconds':5}]
 plan={'scope':'Single missing fanout256/span1/seed0 actual TS and retained artifact JS/Native full30 control; no timing/other7qualification','pins':{str(f):sha(f) for f in files},'tsImportRoot':str(tsroot),'tsImportInventory':inventory(tsroot),'selectedReference':reference,'history':history,'tools':tools,'environmentSHA256':sha(private),'privateEnvironment':str(private),'stage':str(stage),'configurationStates':configs(out,stage),'commands':commands,'oracle':str(ORACLE),'operationCounts':binding['expected']['cases'][1]['operationCounts'],'EOFjoin':binding['EOFsourceJoin'],'executionProbeLabels':['guard-'+str(i)+'-ldd-'+name for i in range(7) for name in ['bend','node','python','taskset','clang']]}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));env=json.loads(Path(p['privateEnvironment']).read_text());assert sha(p['privateEnvironment'])==p['environmentSHA256'];inputs=T.Inputs(files=[path,*p['pins']],directories=[Path(p['tsImportRoot'])]);ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],inputs,env)
 def guard():
  assert all(sha(f)==digest for f,digest in p['pins'].items());assert inventory(Path(p['tsImportRoot']))==p['tsImportInventory'];assert configs(out,Path(p['stage']))==p['configurationStates'];assert sha(p['privateEnvironment'])==p['environmentSHA256'];S.verify(ROOT,p['selectedReference']);source_and_artifact_join();P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 guard();logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=ROOT);expected=json.loads(Path(p['oracle']).read_text());summary=F.force(expected);receipt={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[]}
 try:
  for c in p['commands']:
   guard();r=runner.run(c['label'],c['argv'],c['seconds']);receipt['commands'].append({'label':c['label'],'exit':r['exit'],'failure':r['failure']});assert r['exit']==0 and r['failure'] is None;assert json.loads(r['stdout'])==expected
   assert [json.loads(line) for line in r['stderr'].splitlines()]==[{'boundary':'begin'},{'boundary':'complete-trace-forced',**summary}];guard()
  assert ledger.index==35;receipt['status']='FANOUT_SPAN1_THREE_ROLE_FULL30_PASS_NO_TIMING'
 except BaseException as error:receipt['error']=str(error);raise
 finally:receipt['logs']=dict(logs.hashes);receipt['probePins']=ledger.pins();receipt['probeCommandsExecuted']=ledger.index;(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
