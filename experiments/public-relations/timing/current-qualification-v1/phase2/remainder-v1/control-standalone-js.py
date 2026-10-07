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
 return {'execute':ledger.execute,'tools':{'bend':shutil.which('bend'),'node':shutil.which('node'),'python':sys.executable,'taskset':shutil.which('taskset')},'resource_roots':['/home/node/.bend/bend2'],'ldd':shutil.which('ldd'),'taskset':shutil.which('taskset'),'cpu':5,'env':ledger.env,'skip_ldd':[],'capture_mode':'merged-stdout'}

CASES=[(name,['0'],name+'-seed-0.json') for name in ['nonpower','sparse','empty']]
F=load(HERE.parent.parent/'trace-cheap.py','summary')
def prepare(cheap):
 cheap=Path(cheap).resolve();cr=json.loads(cheap.read_text());cp=cheap.parent/'plan.json';assert cr['status']=='DEVELOPMENT_FULL_CONTROL_CONSUMERS_PASS_NOT_DELIVERY' and cr['planSHA256']==sha(cp)
 for name,digest in cr['logs'].items():assert sha(cheap.parent/name)==digest
 old=json.loads(cp.read_text());assert T.Inputs(files=old['files'],directories=map(Path,old['directories'])).expected==old['inputs']
 out=ROOT/'.artifacts'/('relations-phase2-standalone-js-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();files=set()
 for name,_,_ in CASES:closure(HERE/('driver-'+name+'.bend'),files)
 files.update([HERE.parent.parent/'trace-boundary.c',HERE.parent.parent/'trace-boundary.js',HERE.parent.parent/'trace-cheap.py',HERE/'controls-oracle.py',HERE/'control-expected/manifest.json',*[HERE/'control-expected'/name for _,_,name in CASES],Path(__file__).resolve(),cheap,cp,*[cheap.parent/name for name in cr['logs']]])
 for source in sorted(files):
  if source.suffix=='.bend' or source in [HERE.parent.parent/'trace-boundary.c',HERE.parent.parent/'trace-boundary.js']:
   dest=stage/source.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,dest);assert sha(source)==sha(dest)
 env=dict(os.environ,BEND_NO_TELEMETRY='1');pinsource=[Path(__file__).resolve(),TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'];prepinputs=T.Inputs(files=pinsource,directories=[stage]);ledger=ProbeLedger(out/'prepare-probes',['prepare-ldd-'+name for name in ['bend','node','python','taskset']],prepinputs,env)
 try:tools=P.shared.snapshot(**owned_configuration(ledger));assert ledger.index==4
 except BaseException as error:
  (out/'prepare-receipt.json').write_text(json.dumps({'status':'PREPARE_FAILED','error':str(error),'probeCommandsExecuted':ledger.index,'probePins':ledger.pins()},indent=2)+'\n');raise
 (out/'prepare-receipt.json').write_text(json.dumps({'status':'OWNED_TOOL_PREPARATION_PASS','probeCommandsExecuted':ledger.index,'probePins':ledger.pins()},indent=2)+'\n')
 private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600);files.update(pinsource);files.add(out/'prepare-receipt.json');files.update(map(Path,ledger.pins()));files.update(map(Path,tools['pins']));prefix=['taskset','-c','5'];commands=[]
 for name,args,oracle in CASES:
  js=out/(name+'.js');commands.append({'label':'emit-js-'+name,'argv':prefix+['bend',str(stage/(HERE/('driver-'+name+'.bend')).relative_to(ROOT)),'-o',str(js)],'seconds':30})
  commands.append({'label':'js-'+name,'argv':prefix+['node',str(js),*args],'seconds':5,'oracle':str(HERE/'control-expected'/oracle)})
 plan={'pins':{str(source):sha(source) for source in sorted(files)},'tools':tools,'environmentSHA256':sha(private),'privateEnvironment':str(private),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+name for i in range(13) for name in ['bend','node','python','taskset']],'cheapReceipt':str(cheap),'cheapReceiptSHA256':sha(cheap),'scope':'same standalone emitted artifact, three runtime population/seed complete30 cases; no timing/proof/Native/scaling acceptance'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);private=Path(p['privateEnvironment']);assert sha(private)==p['environmentSHA256'];env=json.loads(private.read_text());generated={};ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,*p['pins']],directories=[stage]),env)
 def guard():
  assert all(sha(source)==digest for source,digest in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(private)==p['environmentSHA256'];assert all(sha(source)==digest for source,digest in generated.items());P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 guard();logs=L.CommandLogs(out,[command['label'] for command in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]),env=env,cwd=stage);receipt={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]}
 try:
  for command in p['commands']:
   guard()
   if '-o' in command['argv']:assert not Path(command['argv'][command['argv'].index('-o')+1]).exists()
   result=runner.run(command['label'],command['argv'],command['seconds']);receipt['commands'].append({'label':command['label'],'exit':result['exit'],'failure':result['failure']});assert result['exit']==0 and result['failure'] is None
   if '-o' in command['argv']:
    source=command['argv'][command['argv'].index('-o')+1];generated[source]=sha(source);runner.inputs=T.Inputs(files=[path,*p['pins'],*generated],directories=[stage])
   if 'oracle' in command:
    expected=json.loads(Path(command['oracle']).read_text());actual=json.loads(result['stdout']);assert actual==expected,'full30 oracle mismatch';assert [json.loads(line) for line in result['stderr'].splitlines()]==[{'boundary':'begin'},{'boundary':'complete-trace-forced',**F.force(expected)}];receipt[command['label']+'Records']=sum(len(root['records']) for root in actual['roots'])
   guard()
  assert ledger.index==52;receipt['status']='THREE_CONTROL_FULL_JS_CONSUMERS_PASS_NO_TIMING_VERDICT'
 except BaseException as error:receipt['error']=str(error);raise
 finally:receipt['generated']=generated;receipt['logs']=dict(logs.hashes);receipt['probePins']=ledger.pins();receipt['probeCommandsExecuted']=ledger.index;(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare');parser.add_argument('--run');args=parser.parse_args();prepare(args.prepare) if args.prepare else run(args.run)
