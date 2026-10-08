"""Fresh current registered reorder normal and three reached mutants, JavaScript only."""
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
 return {'execute':ledger.execute,'tools':{'bend':shutil.which('bend'),'node':shutil.which('node'),'python':sys.executable,'taskset':shutil.which('taskset')},'resource_roots':['/home/node/.bend/bend2'],'ldd':shutil.which('ldd'),'taskset':shutil.which('taskset'),'cpu':5,'env':ledger.env,'skip_ldd':[],'capture_mode':'merged-stdout'}

def prepare(cheap):
 cheap=Path(cheap).resolve();cp=cheap.parent/'plan.json';cr=json.loads(cheap.read_text());old=json.loads(cp.read_text());assert cr['status']=='REMAINING_THREE_REORDER_NEGATIVES_EXACT_DIAGNOSTICS_NOT_RUNTIME_OR_PROOF' and cr['planSHA256']==sha(cp)
 files={cheap,cp,Path(__file__).resolve(),HERE/'reorder-current-root-closure.json',HERE/'reorder-runtime-proposal.json',TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'}
 for name,digest in old['pins'].items():assert sha(name)==digest;files.add(Path(name))
 for name,digest in cr['logs'].items():assert sha(cheap.parent/name)==digest;files.add(cheap.parent/name)
 assert inventory(Path(old['stage']))==old['inventory'];assert sha(old['privateEnvironment'])==old['environmentSHA256']
 proposal=json.loads((HERE/'reorder-runtime-proposal.json').read_text());archive=ROOT/proposal['historicalArchive'];assert sha(archive)==proposal['historicalArchiveSHA256'];files.add(archive)
 with tarfile.open(archive) as t: historical={m.name:t.extractfile(m).read() for m in t.getmembers() if m.isfile()}
 hr=json.loads(historical[proposal['receiptMember']]);assert hashlib.sha256(historical[proposal['receiptMember']]).hexdigest()==proposal['receiptSHA256'] and hr['status']=='FINITE_REGISTERED_HIERARCHY_REORDER_PASS'
 out=ROOT/'.artifacts'/('relations-current-reorder-js-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();expected=out/'independent-oracles';expected.mkdir()
 normal=historical['reorder-1791361321007561029/command-19.txt'];lines=normal.decode().splitlines();assert len(lines)==56
 # Historical full captures/witnesses and Bend spec are archived. Python model
 # bytes join the receipt; changed encoder source has only its historical hash.
 (expected/'normal.stdout').write_bytes(normal)
 root_join=json.loads((HERE/'reorder-current-root-closure.json').read_text());current_root=Path(root_join['root'])
 for row in root_join['files']:
  source=current_root/row['path'];assert sha(source)==row['currentRootSHA256'];legacy=(Path(old['stage'])/row['path']).read_bytes();assert hashlib.sha256(legacy).hexdigest()==row['historicalCheapSHA256'];assert source.read_bytes()==legacy or row['state']=='ADDITIVE_EXACT_LEGACY_PREFIX' and source.read_bytes().startswith(legacy);files.add(source)
 model=ROOT/'experiments/public-relations/promotion-stage/reorder-model.py';original_model=next(s for n,s in hr['pins'].items() if n.endswith('/reorder-model.py'));assert sha(model)==original_model;files.add(model)
 archived_spec=historical['reorder-1791361321007561029/normal/experiments/public-relations/reorder-spec.bend'];(expected/'archived-reorder-spec.bend').write_bytes(archived_spec)
 oracle_provenance={'historicalArchiveHasPythonSources':False,'modelSHA256':original_model,'modelMatchesOriginalReceipt':True,'historicalEncoderSHA256':next(s for n,s in hr['pins'].items() if n.endswith('/reorder-controls.py')),'currentEncoderSHA256':sha(ROOT/'experiments/public-relations/promotion-stage/reorder-controls.py'),'encoderSourceJoin':'Changed current helper; original encoder source not archived. No invented byte-current claim.','normalCaptureSHA256':hashlib.sha256(normal).hexdigest(),'archivedBendSpecSHA256':hashlib.sha256(archived_spec).hexdigest()}
 (expected/'provenance.json').write_text(json.dumps(oracle_provenance,indent=2)+'\n')
 cases=['normal',*[m['case'] for m in proposal['mutations']]]
 for case in cases:
  dest=stage/case;shutil.copytree(old['stage'],dest)
  for q in dest.rglob('*'):
   if q.is_file():assert sha(q)==old['inventory'][str(q.relative_to(dest))]
  for row in root_join['files']:
   target=dest/row['path'];target.write_bytes((current_root/row['path']).read_bytes());assert sha(target)==row['currentRootSHA256']
  if case!='normal':
   mutation=next(m for m in proposal['mutations'] if m['case']==case);q=dest/mutation['currentModule'];assert sha(q)==mutation['currentSHA256'];text=q.read_text();assert text.count(mutation['before'])==1;q.write_text(text.replace(mutation['before'],mutation['after']));assert sha(q)==mutation['candidateMutantSHA256']
  result=[x for x in hr['results'] if x['case']==case and x['backend']=='js'];assert len(result)==1 and result[0]['checkpointCount']==52
  (expected/(case+'.witnesses.json')).write_text(json.dumps(result[0]['witnesses'],indent=2)+'\n')
 for q in expected.iterdir():files.add(q)
 env=P.configuration()['env']
 configs_before=configs(out,stage);before=json.dumps(env,sort_keys=True);inputs=T.Inputs(files=files,directories=[stage]);inputs.guard();ledger=ProbeLedger(out/'prepare-probes',['prepare-ldd-'+n for n in ['bend','node','python','taskset']],inputs,env)
 try:
  tools=P.shared.snapshot(**owned_configuration(ledger));assert ledger.index==4;inputs.guard();assert configs(out,stage)==configs_before and json.dumps(env,sort_keys=True)==before
 except BaseException as error:
  (out/'prepare-receipt.json').write_text(json.dumps({'status':'PREPARE_FAILED','error':str(error),'probeCommandsExecuted':ledger.index,'probePins':ledger.pins()},indent=2)+'\n');raise
 pr=out/'prepare-receipt.json';pr.write_text(json.dumps({'status':'OWNED_TOOL_PREPARATION_PASS','probeCommandsExecuted':ledger.index,'probePins':ledger.pins()},indent=2)+'\n');private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600);files.update([pr,private]);files.update(map(Path,ledger.pins()));files.update(map(Path,tools['pins']))
 commands=[]
 for case in cases:
  artifact=out/(case+'.js');entry=stage/case/'experiments/public-relations/promotion-stage/reorder-owned.bend';commands.extend([{'label':'emit-'+case,'argv':['taskset','-c','5','bend',str(entry),'-o',str(artifact)],'seconds':30,'artifact':str(artifact)},{'label':'run-'+case,'argv':['taskset','-c','5','node',str(artifact)],'seconds':5,'case':case,'normalOracle':str(expected/'normal.stdout'),'witnessOracle':str(expected/(case+'.witnesses.json'))}])
 plan={'pins':{str(p):sha(p) for p in sorted(files)},'tools':tools,'privateEnvironment':str(private),'environmentSHA256':sha(private),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(17) for n in ['bend','node','python','taskset']],'scope':'Fresh current registered reorder normal plus3actual compilingmutants JS complete52checkpoints/original46,42,38 witnesses; no Native/performance/proof/full42 adoption acceptance'}
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
  assert ledger.index==68;r['status']='CURRENT_REGISTERED_REORDER_JS_FULL52_THREE_MUTANTS_PASS_NO_TIMING'
 except BaseException as error:r['error']=str(error);raise
 finally:logs.guard();r['generated']=generated;r['logs']=dict(logs.hashes);r['probePins']=ledger.pins();r['probeCommandsExecuted']=ledger.index;(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare');parser.add_argument('--run');args=parser.parse_args();prepare(args.prepare) if args.prepare else run(args.run)
