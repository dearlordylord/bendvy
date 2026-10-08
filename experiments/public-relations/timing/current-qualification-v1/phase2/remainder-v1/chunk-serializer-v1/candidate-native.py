"""Affected chunk serializer Native finite controls; no performance acceptance."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time
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
  result=self.runner.run(label,argv,limit)
  path=self.directory/(label+'.json');path.write_text(json.dumps({'argv':list(map(str,argv)),'seconds':limit,'exit':result['exit'],'failure':result['failure'],'runnerSHA256':result['runnerSHA256']},indent=2)+'\n');self.receipts[str(path)]=sha(path);self.guard();return result
 def guard(self):
  self.logs.guard();assert all(sha(p)==h for p,h in self.receipts.items())
  assert {str(p) for p in self.directory.iterdir()}==set(self.receipts)|{str(self.directory/n) for n in self.logs.hashes}
 def pins(self):return {**self.receipts,**{str(self.directory/n):h for n,h in self.logs.hashes.items()}}
def owned_configuration(ledger):
 configuration=P.configuration();configuration['execute']=ledger.execute;configuration['env']=ledger.env;return configuration

F=load(HERE.parents[2]/'trace-cheap.py','summary')
def prepare(first):
 first=Path(first).resolve();fr=json.loads(first.read_text());fp=first.parent/'plan.json';old=decode(json.loads(fp.read_text()));assert fr['status']=='CHUNK_DEPTH128_COMPLETE30_JS_PASS_NO_TIMING' and fr['planSHA256']==sha(fp)
 assert all(sha(p)==digest for p,digest in old['pins'].items());assert inventory(Path(old['stage']))==old['inventory'];assert sha(old['privateEnvironment'])==old['environmentSHA256'];assert all(sha(p)==digest for p,digest in fr['generated'].items())
 for name,digest in fr['logs'].items():assert sha(first.parent/name)==digest
 assert all(sha(n)==digest for n,digest in fr['probePins'].items())
 out=ROOT/'.artifacts'/('relations-chunk-native-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();files=set(map(Path,old['pins']));files.update([first,fp,Path(old['privateEnvironment']),*[first.parent/n for n in fr['logs']],*[Path(p) for p in fr['generated']],HERE/'native-proposal.json',HERE/'exhaustion-source-plan.json',Path(__file__).resolve()]);closure(HERE/'driver-exhaustion.bend',files)
 reference=HERE.parents[1]/'reference.mjs';maxoracle=HERE.parents[1]/'expected/population-64-seed-4294967295.json';depth1=HERE.parent/'expected/depth-256-span-1-seed-0.json';depth16=HERE.parent/'expected/depth-256-span-16-seed-0.json';depth128=HERE.parent/'expected/depth-256-span-128-seed-0.json';assert sha(depth128)==old['pins'][str(depth128)];assert (first.parent/'js-depth128.stdout').read_bytes()==depth128.read_bytes();files.update([reference,maxoracle,depth1,depth16,depth128,*[Path(n) for n in fr['probePins']]])
 extension=ROOT/'.artifacts/relations-chunk-extension-1791419118574552727';ep=extension/'plan.json';er=extension/'receipt.json';extended=decode(json.loads(ep.read_text()));extensionr=json.loads(er.read_text());assert extensionr['status']=='CHUNK_BOUNDED_CONTROLS_JS_PASS_NO_TIMING' and extensionr['planSHA256']==sha(ep);assert all(sha(n)==digest for n,digest in extended['pins'].items());assert sha(extended['privateEnvironment'])==extended['environmentSHA256'];assert inventory(Path(extended['stage']))==extended['inventory'];assert all(sha(extension/n)==digest for n,digest in extensionr['logs'].items());assert all(sha(n)==digest for n,digest in extensionr['probePins'].items());files.update([ep,er,Path(extended['privateEnvironment']),*[Path(n) for n in extended['pins']],*[extension/n for n in extensionr['logs']],*[Path(n) for n in extensionr['probePins']]])
 assert json.loads((extension/'ts64max.stdout').read_bytes())==json.loads(maxoracle.read_bytes())
 hp=ROOT/'.artifacts/relations-normal-first-1791415751785839164/plan.json';hr=hp.parent/'receipt.json';hist=json.loads(hp.read_text());receipt=json.loads(hr.read_text());assert receipt['planSHA256']==sha(hp)
 for label,oracle in [('0-ts',depth1),('1-ts',depth16)]:
  assert any(c['label']==label and c['exit']==0 and c['failure'] is None for c in receipt['commands']);assert sha(hp.parent/(label+'.stdout'))==receipt['logs'][label+'.stdout'];assert json.loads((hp.parent/(label+'.stdout')).read_bytes())==json.loads(oracle.read_bytes());files.update([hp.parent/(label+'.stdout'),hp.parent/(label+'.stderr')])
 assert all(sha(n)==digest for n,digest in receipt['probePins'].items());files.update(map(Path,receipt['probePins']));assert inventory(Path(hist['tsImportRoot']))==hist['tsImportInventory'];files.update(Path(hist['tsImportRoot'])/n for n in hist['tsImportInventory'])
 for source in sorted(files):
  if source.is_relative_to(ROOT) and (source.suffix=='.bend' or source in [HERE.parents[2]/'trace-boundary.c',HERE.parents[2]/'trace-boundary.js']):
   dest=stage/source.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,dest);assert sha(source)==sha(dest)
 env=P.configuration()['env'];pinsource=[Path(__file__).resolve(),TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'];preparationconfig=configs(out,stage);prepinputs=T.Inputs(files=[*files,*pinsource],directories=[stage]);prepinputs.guard();environment_before=json.dumps(env,sort_keys=True);ledger=ProbeLedger(out/'prepare-probes',['prepare-ldd-'+name for name in ['bend','node','python','taskset','clang']],prepinputs,env)
 try:
  tools=P.shared.snapshot(**owned_configuration(ledger));assert ledger.index==5;prepinputs.guard();assert configs(out,stage)==preparationconfig;assert json.dumps(env,sort_keys=True)==environment_before
 except BaseException as error:
  (out/'prepare-receipt.json').write_text(json.dumps({'status':'PREPARE_FAILED','error':str(error),'probeCommandsExecuted':ledger.index,'probePins':ledger.pins()},indent=2)+'\n');raise
 (out/'prepare-receipt.json').write_text(json.dumps({'status':'OWNED_TOOL_PREPARATION_PASS','probeCommandsExecuted':ledger.index,'probePins':ledger.pins()},indent=2)+'\n');private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600);files.update(pinsource);files.add(out/'prepare-receipt.json');files.update(map(Path,ledger.pins()));files.update(map(Path,tools['pins']));prefix=['taskset','-c','5'];c=out/'trace.c';binary=out/'trace-native';ec=out/'exhaustion.c';eb=out/'exhaustion-native';clang='/tmp/bendvy-clang19-diagnostic/clang19'
 commands=[{'label':'emit-main-c','argv':prefix+['bend',str(stage/(HERE/'driver.bend').relative_to(ROOT)),'-o',str(c)],'seconds':30},{'label':'compile-main','argv':prefix+[clang,'-O3',str(c),'-pthread','-lm','-o',str(binary)],'seconds':120}]
 for label,args,oracle in [('native-depth128',['depth','256','128','0'],depth128),('native-depth1',['depth','256','1','0'],depth1),('native-depth16',['depth','256','16','0'],depth16),('native64max',['population','64','0','4294967295'],maxoracle)]:commands.append({'label':label,'argv':prefix+[str(binary),'--threads','1','--gpu','off',*args],'seconds':5,'oracle':str(oracle)})
 commands.extend([{'label':'input-refusal','argv':prefix+[str(binary),'--threads','1','--gpu','off','population','7','0','0'],'seconds':5,'refusal':'INPUT_REFUSED\n'},{'label':'emit-exhaustion-c','argv':prefix+['bend',str(stage/(HERE/'driver-exhaustion.bend').relative_to(ROOT)),'-o',str(ec)],'seconds':30},{'label':'compile-exhaustion','argv':prefix+[clang,'-O3',str(ec),'-pthread','-lm','-o',str(eb)],'seconds':120},{'label':'serialization-exhaustion','argv':prefix+[str(eb),'--threads','1','--gpu','off','depth','256','1','0'],'seconds':5,'refusal':'TRACE_SERIALIZATION_INCOMPLETE\n','forcedOracle':str(depth1)}])
 plan={'pins':{str(p):sha(p) for p in sorted(files)},'tools':tools,'environmentSHA256':sha(private),'privateEnvironment':str(private),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+name for i in range(21) for name in ['bend','node','python','taskset','clang']],'scope':'AffectedcandidateNative main4full30cases/inputrefusal pluspostforceexhaustion; no performance/N1024/fanout/wholefamily/proof acceptance'};(out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
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
   if 'refusal' in command:
    assert result['stdout']==command['refusal'].encode(),'exact refusal mismatch'
    expected=[] if 'forcedOracle' not in command else [{'boundary':'begin'},{'boundary':'complete-trace-forced',**F.force(json.loads(Path(command['forcedOracle']).read_text()))}]
    assert [json.loads(line) for line in result['stderr'].splitlines()]==expected,'refusal forcing boundary mismatch'
   guard()
  assert ledger.index==105;receipt['status']='CHUNK_AFFECTED_NATIVE_FULL30_REFUSALS_PASS_NO_TIMING'
 except BaseException as error:receipt['error']=str(error);raise
 finally:receipt['generated']=generated;receipt['logs']=dict(logs.hashes);receipt['probePins']=ledger.pins();receipt['probeCommandsExecuted']=ledger.index;(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare');parser.add_argument('--run');args=parser.parse_args();prepare(args.prepare) if args.prepare else run(args.run)
