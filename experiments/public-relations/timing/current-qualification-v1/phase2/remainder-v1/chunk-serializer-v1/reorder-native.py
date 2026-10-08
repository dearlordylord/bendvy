"""Fresh current registered reorder normal and three reached mutants, Native only."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];HERE=Path(__file__).resolve().parent
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
 for root in {ROOT,Path.cwd(),out,stage,stage/'src/ecs',stage/'experiments/public-relations/promotion-stage',*[p.parent for p in stage.rglob('*.bend')]}:
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
  try:result=self.runner.run(label,argv,limit)
  except BaseException as error:
   result=getattr(error,'result',None)
   path=self.directory/(label+'.json');path.write_text(json.dumps({'argv':list(map(str,argv)),'seconds':limit,'exit':result['exit'] if result else None,'failure':result['failure'] if result else None,'collectionError':str(error),'runnerSHA256':result['runnerSHA256'] if result else None},indent=2)+'\n');self.receipts[str(path)]=sha(path);self.logs.guard();raise
  path=self.directory/(label+'.json');path.write_text(json.dumps({'argv':list(map(str,argv)),'seconds':limit,'exit':result['exit'],'failure':result['failure'],'runnerSHA256':result['runnerSHA256']},indent=2)+'\n');self.receipts[str(path)]=sha(path);self.guard();return result
 def guard(self):
  self.logs.guard();assert all(sha(p)==h for p,h in self.receipts.items())
  assert {str(p) for p in self.directory.iterdir()}==set(self.receipts)|{str(self.directory/n) for n in self.logs.hashes}
 def pins(self):return {**self.receipts,**{str(self.directory/n):h for n,h in self.logs.hashes.items()}}
def owned_configuration(ledger):
 configuration=P.configuration();configuration['execute']=ledger.execute;configuration['env']=ledger.env;return configuration

def prepare(js):
 js=Path(js).resolve();jp=js.parent/'plan.json';old=decode(json.loads(jp.read_text()));r=json.loads(js.read_text());assert r['status']=='CURRENT_REGISTERED_REORDER_JS_FULL52_THREE_MUTANTS_PASS_NO_TIMING' and r['planSHA256']==sha(jp);assert r['probeCommandsExecuted']==68 and len(r['commands'])==8
 assert all(c['exit']==0 and c['failure'] is None and c['status']=='QUALIFIED' for c in r['commands'])
 files={js,jp,Path(__file__).resolve(),HERE/'reorder-runtime-proposal.json',HERE/'reorder-current-root-closure.json',TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'}
 for n,s in old['pins'].items():assert sha(n)==s;files.add(Path(n))
 for n,s in r['probePins'].items():assert sha(n)==s;files.add(Path(n))
 for n,s in r['generated'].items():assert sha(n)==s;files.add(Path(n))
 for n,s in r['logs'].items():assert sha(js.parent/n)==s;files.add(js.parent/n)
 assert sha(old['privateEnvironment'])==old['environmentSHA256'];assert inventory(Path(old['stage']))==old['inventory']
 prep=js.parent/'prepare-receipt.json';pr=json.loads(prep.read_text());assert pr['status']=='OWNED_TOOL_PREPARATION_PASS' and pr['probeCommandsExecuted']==4;files.add(prep)
 for n,s in pr['probePins'].items():assert sha(n)==s;files.add(Path(n))
 out=ROOT/'.artifacts'/('relations-current-reorder-native-'+str(time.time_ns()));out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage);assert inventory(stage)==old['inventory']
 rootjoin=json.loads((HERE/'reorder-current-root-closure.json').read_text())
 for row in rootjoin['files']:assert sha(Path(rootjoin['root'])/row['path'])==row['currentRootSHA256']
 for case in ['normal','inverse-order-omission','child-before-parent','wrong-failure-target']:
  for row in rootjoin['files']:
   path=stage/case/row['path'];digest=sha(path)
   if row['path'] not in ['src/ecs/relation-reorder-core.bend','src/ecs/relation-reorder.bend'] or case=='normal':assert digest==row['currentRootSHA256']
 env=P.configuration()['env'];config_before=configs(out,stage);env_before=json.dumps(env,sort_keys=True);inputs=T.Inputs(files=files,directories=[stage]);inputs.guard();ledger=ProbeLedger(out/'prepare-probes',['prepare-ldd-'+n for n in ['bend','node','python','taskset','clang']],inputs,env)
 try:
  tools=P.shared.snapshot(**owned_configuration(ledger));assert ledger.index==5;inputs.guard();assert configs(out,stage)==config_before and json.dumps(env,sort_keys=True)==env_before
 except BaseException as error:
  (out/'prepare-receipt.json').write_text(json.dumps({'status':'PREPARE_FAILED','error':str(error),'probeCommandsExecuted':ledger.index,'probePins':ledger.pins()},indent=2)+'\n');raise
 pr=out/'prepare-receipt.json';pr.write_text(json.dumps({'status':'OWNED_TOOL_PREPARATION_PASS','probeCommandsExecuted':ledger.index,'probePins':ledger.pins()},indent=2)+'\n');private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600);files.update([pr,private]);files.update(map(Path,ledger.pins()));files.update(map(Path,tools['pins']))
 commands=[]
 for c in old['commands']:
  if 'case' not in c:continue
  case=c['case'];entry=stage/case/'experiments/public-relations/promotion-stage/reorder-owned.bend';artifact=out/(case+'.c');binary=out/(case+'-native');commands.extend([{'label':'emit-'+case,'argv':['taskset','-c','5','bend',str(entry),'-o',str(artifact)],'seconds':30,'artifact':str(artifact)},{'label':'compile-'+case,'argv':['taskset','-c','5','/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(artifact),'-pthread','-lm','-o',str(binary)],'seconds':120,'artifact':str(binary)},{'label':'run-'+case,'argv':['taskset','-c','5',str(binary),'--threads','1','--gpu','off'],'seconds':5,'case':case,'normalOracle':c['normalOracle'],'witnessOracle':c['witnessOracle']}])
 plan={'pins':{str(p):sha(p) for p in sorted(files)},'tools':tools,'privateEnvironment':str(private),'environmentSHA256':sha(private),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(25) for n in ['bend','node','python','taskset','clang']],'scope':'Fresh current registered reorder normal plus3compilingmutants Native full52checkpoints/exact0,46,42,38 witnesses; no performance/proof/adoption/full42 acceptance'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));stage=Path(p['stage']);private=Path(p['privateEnvironment']);assert sha(private)==p['environmentSHA256'];env=json.loads(private.read_text());generated={};ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,*p['pins']],directories=[stage]),env)
 def guard():
  assert all(sha(n)==s for n,s in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(private)==p['environmentSHA256'];assert all(sha(n)==s for n,s in generated.items());P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='merged-stdout');r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[],'results':[]}
 try:
  guard()
  for c in p['commands']:
   guard()
   if 'artifact' in c:assert not Path(c['artifact']).exists()
   item={'label':c['label'],'argv':c['argv'],'seconds':c['seconds'],'exit':None,'failure':None,'status':'NOT_COLLECTED'};r['commands'].append(item)
   try:
    result=runner.run(c['label'],c['argv'],c['seconds'],expected=None);item.update(exit=result['exit'],failure=result['failure'],status='COLLECTED')
   except BaseException as error:
    failed=getattr(error,'result',None)
    if failed is not None:item.update(exit=failed['exit'],failure=failed['failure'],status='COLLECTED')
    item['collectionError']=str(error);raise
   finally:logs.guard();guard()
   assert result['exit']==0 and result['failure'] is None and result['stderr']==b''
   if 'artifact' in c:
    assert result['stdout']==b'';generated[c['artifact']]=sha(c['artifact'])
   else:
    actual=result['stdout'].decode().splitlines();expected=Path(c['normalOracle']).read_text().splitlines();assert len(actual)==len(expected)==56
    witnesses=[{'checkpoint':i,'expected':a,'actual':b} for i,(a,b) in enumerate(zip(expected,actual)) if a!=b];assert witnesses==json.loads(Path(c['witnessOracle']).read_text());r['results'].append({'case':c['case'],'checkpointCount':52,'witnessCount':len(witnesses)})
   item['status']='QUALIFIED'
  assert ledger.index==125;r['status']='CURRENT_REGISTERED_REORDER_NATIVE_FULL52_THREE_MUTANTS_PASS_NO_TIMING'
 except BaseException as error:r['error']=str(error);raise
 finally:logs.guard();r['generated']=generated;r['logs']=dict(logs.hashes);r['probePins']=ledger.pins();r['probeCommandsExecuted']=ledger.index;(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare');parser.add_argument('--run');args=parser.parse_args();prepare(args.prepare) if args.prepare else run(args.run)
