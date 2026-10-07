"""Focused frozen complete-snapshot JS/Native development cohort."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
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
 c=P.configuration();c['execute']=ledger.execute;return c
ENTRIES={'normal':HERE/'trace-emitted.bend','last-leaf':HERE/'trace-emitted-last-leaf.bend','moved-walk':HERE/'trace-emitted-moved-walk.bend'}
ORACLE=ROOT/'experiments/public-relations/promotion-stage/application/next-version/v1/expected.json'
F=load(HERE/'trace-cheap.py','public_trace')
def retained_receipt(path,status):
 path=Path(path).resolve();r=json.loads(path.read_text());p=json.loads((path.parent/'plan.json').read_text());assert r['status']==status and r['planSHA256']==sha(path.parent/'plan.json')
 for n,h in r['logs'].items():assert sha(path.parent/n)==h
 previous=T.Inputs(files=p['files'],directories=list(map(Path,p['directories'])));assert previous.expected==p['inputs'];previous.guard()
 generated=r.get('generated',{})
 if 'generatedSHA256' in r:generated[str(path.parent/'trace.js')]=r['generatedSHA256']
 assert all(sha(f)==h for f,h in generated.items())
 return [path,path.parent/'plan.json',*[path.parent/n for n in r['logs']],*map(Path,generated)]
def prepare(cheap,controls):
 retained=retained_receipt(cheap,'COMPLETE_PUBLIC_TRACE_ANCHOR_PASS_NOT_FAIR_TIMING_QUALIFIED')+retained_receipt(controls,'BOTH_JS_FORCING_BOUNDARY_FALSIFIERS_PASS_NO_TIMING_VERDICT')
 out=ROOT/'.artifacts'/('relations-public-trace-native-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();files=set()
 for entry in ENTRIES.values():closure(entry,files)
 files.update([HERE/'trace-boundary.c',HERE/'trace-boundary.js',HERE/'trace-cheap.py',ORACLE,Path(__file__).resolve(),*retained])
 for p in sorted(files):
  if p.suffix=='.bend' or p in [HERE/'trace-boundary.c',HERE/'trace-boundary.js']:
   target=stage/p.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,target);assert sha(p)==sha(target)
 env=P.configuration()['env'];prepare_inputs=T.Inputs(files=[Path(__file__).resolve(),TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'],directories=[stage]);prepare_ledger=ProbeLedger(out/'prepare-probes',['prepare-ldd-'+n for n in ['bend','node','python','taskset','clang']],prepare_inputs,env);
 try:
  tools=P.shared.snapshot(**owned_configuration(prepare_ledger));assert prepare_ledger.index==5
 except BaseException as error:
  (out/'prepare-receipt.json').write_text(json.dumps({'status':'INCOMPLETE_PREPARE_FAILURE','error':str(error),'probeCommandsExecuted':prepare_ledger.index,'probePins':prepare_ledger.pins()},indent=2)+'\n');raise
 (out/'prepare-receipt.json').write_text(json.dumps({'status':'OWNED_TOOL_PREPARATION_PASS','probeCommandsExecuted':prepare_ledger.index,'probePins':prepare_ledger.pins()},indent=2)+'\n')
 envfile=out/'private-environment.json';envfile.write_text(json.dumps(env,sort_keys=True));envfile.chmod(0o600)
 files.add(out/'prepare-receipt.json');files.update(map(Path,prepare_ledger.pins()));files.update([TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'.references/sources.json']);files.update(map(Path,tools['pins']))
 commands=[]
 for name,entry in ENTRIES.items():
  c=out/(name+'.c');binary=out/(name+'-native');prefix=['taskset','-c','5'];commands.extend([{'label':name+'-emit-c','argv':prefix+['bend',str(stage/entry.relative_to(ROOT)),'-o',str(c)],'seconds':30},{'label':name+'-clang','argv':prefix+['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(c),'-pthread','-lm','-o',str(binary)],'seconds':120},{'label':name+'-run-native','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'seconds':5,'oracle':name}])
 p={'pins':{str(p):sha(p) for p in sorted(files)},'tools':tools,'environmentSHA256':sha(envfile),'privateEnvironment':str(envfile),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(19) for n in ['bend','node','python','taskset','clang']],'cheapReceipt':str(cheap),'cheapReceiptSHA256':sha(cheap),'controlsReceipt':str(controls),'controlsReceiptSHA256':sha(controls),'scope':'Native complete30 public trace after Begin plus last-leaf/moved-walk falsifiers. Ordinary owned tool probes. No timing/scaling/production/proof acceptance.'};(out/'plan.json').write_text(json.dumps(p,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);envfile=Path(p['privateEnvironment']);assert sha(envfile)==p['environmentSHA256'];env=json.loads(envfile.read_text());os.environ.clear();os.environ.update(env);generated={};probe_inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],probe_inputs,env)
 def guard():
  assert all(sha(f)==h for f,h in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(envfile)==p['environmentSHA256'];assert all(sha(f)==h for f,h in generated.items());P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 guard();inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);logs=L.CommandLogs(out,[x['label'] for x in p['commands']]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=stage);oracle=json.loads(ORACLE.read_text());summary=F.force(oracle);mutated=json.loads(json.dumps(oracle));mutated[-1]['records'][-1]['systemResult']=1;r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]}
 try:
  for c in p['commands']:
   guard()
   if '-o' in c['argv']:assert not Path(c['argv'][c['argv'].index('-o')+1]).exists()
   x=runner.run(c['label'],c['argv'],c['seconds']);r['commands'].append({'label':c['label'],'exit':x['exit'],'failure':x['failure']});assert x['exit']==0 and x['failure'] is None
   if '-o' in c['argv']:
    f=c['argv'][c['argv'].index('-o')+1];generated[f]=sha(f);runner.inputs=T.Inputs(files=[path,*p['pins'],*generated],directories=[stage])
   if 'oracle' in c:
    actual=json.loads(x['stdout']);boundaries=[json.loads(line) for line in x['stderr'].splitlines()];name=c['oracle']
    if name=='normal':assert actual==oracle and boundaries==[dict(boundary='begin'),dict(boundary='complete-trace-forced',**summary)]
    elif name=='last-leaf':assert actual==mutated and actual!=oracle;assert boundaries==[dict(boundary='begin'),dict(boundary='complete-trace-forced',**F.force(mutated))];assert F.force(mutated)!=summary
    else:assert actual==oracle and boundaries==[dict(boundary='begin'),dict(boundary='complete-trace-forced',nodes=0,characters=0,sum=0),dict(boundary='complete-trace-forced',**summary)]
   guard()
  assert ledger.index==95;r['status']='COMPLETE30_NATIVE_TRACE_AND_BOTH_FORCING_FALSIFIERS_PASS_NO_TIMING_VERDICT'
 except BaseException as e:r['error']=str(e);raise
 finally:r['generated']=generated;r['logs']=dict(logs.hashes);r['probePins']=ledger.pins();r['probeCommandsExecuted']=ledger.index;(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
p=argparse.ArgumentParser();p.add_argument('--prepare-from-cheap');p.add_argument('--controls');p.add_argument('--run');a=p.parse_args();prepare(a.prepare_from_cheap,a.controls) if a.prepare_from_cheap else run(a.run)
