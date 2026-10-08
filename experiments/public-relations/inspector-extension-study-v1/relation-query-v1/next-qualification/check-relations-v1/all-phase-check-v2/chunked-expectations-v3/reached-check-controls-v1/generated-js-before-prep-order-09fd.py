"""Standalone full Check consumer; external coordinator owns serial flock."""
import base64,argparse,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent;R=next(p for p in H.parents if (p/"scripts/task_runner.py").exists())
COORDINATOR=Path('/workspace/formal-proofs/bendvy')
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(R/'scripts/task_runner.py','task_runner');L=load(R/'scripts/receipt-logs.py','receipt_logs');B=load(COORDINATOR/'scripts/evidence_boundary.py','evidence_boundary')
NAMES=('normal','outgoing-filter-negated','incoming-order-reversed','world-valid-omitted')
SUBJECTS=tuple((n,n+'/closure/experiments/public-relations/inspector-extension-study-v1/relation-query-v1/next-qualification/check-relations-v1/all-phase-check-v2/chunked-expectations-v3/complete-io.bend',n+'/expected-complete.json') for n in NAMES)
INSTALLED=Path('/home/node/.bend/bend2')
def installed_membership():
 return {str(p.relative_to(INSTALLED)):str(p.resolve()) for p in sorted(INSTALLED.rglob('*')) if p.is_file()}
def closure():
 pending=[H/source for _,source,_ in SUBJECTS];seen=set()
 while pending:
  p=pending.pop().resolve()
  if p in seen:continue
  assert p.is_file(),str(p);seen.add(p)
  for imp in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
   target=INSTALLED/'base.bend' if imp=='Base' else p.parent/imp
   pending.append(target)
 return seen
def strict(value):
 if isinstance(value,dict):return ('dict',tuple((k,strict(v)) for k,v in sorted(value.items())))
 if isinstance(value,list):return ('list',tuple(map(strict,value)))
 return (type(value).__name__,value)
def configuration(stage=None,out=None):
 paths=set()
 extra=set() if stage is None else {out,stage,*[p.parent for p in stage.rglob("*.bend")]}
 for origin in (extra|{p.parent for p in closure()}|{H,R,COORDINATOR,INSTALLED,Path.home(),Path.home()/'.bend'}|{Path(shutil.which(n)).resolve().parent for n in ('bend','node','taskset')}):
  for parent in (origin,*origin.parents):
   for name in ('.bend.json','bend.config.json','bend.json','bend.jsonc','bend.toml','check.json','check.jsonc','bender.json','bender.jsonc','.bend','package.json','tsconfig.json','.node-version','.nvmrc','.npmrc'):
    paths.add(parent/name)
 # Expand participating configuration links to their resolved ancestry too.
 known=set()
 while True:
  added=set()
  for path in paths-known:
   candidates=[path]
   if path.is_dir():candidates.extend(q for q in path.rglob('*') if q.is_symlink())
   for q in candidates:
    if q.is_symlink():
     origin=q.resolve().parent
     for parent in (origin,*origin.parents):
      for name in ('.bend.json','bend.config.json','bend.json','bend.jsonc','bend.toml','check.json','check.jsonc','bender.json','bender.jsonc','.bend','package.json','tsconfig.json','.node-version','.nvmrc','.npmrc'):
       added.add(parent/name)
  known.update(paths)
  if added<=paths:break
  paths.update(added)
 def actual(p,ancestors):
  if p.is_file():return {'kind':'file','SHA256':sha(p)}
  if p.is_dir():
   resolved=str(p.resolve())
   if resolved in ancestors:return {'kind':'directory-cycle','resolvedPath':resolved}
   chain=ancestors|{resolved}
   return {'kind':'directory','inventory':{q.name:state(q,chain) for q in sorted(p.iterdir())}}
  return {'kind':'absent'}
 def state(p,ancestors=frozenset()):
  if p.is_symlink():return {'kind':'symlink','target':os.readlink(p),'resolvedPath':str(p.resolve()),'resolvedState':actual(p.resolve(),ancestors)}
  return actual(p,ancestors)

 return {str(p):state(p) for p in sorted(paths)}

TOOL=R/'experiments/public-relations/promotion-stage/application/next-version/v1/tool-pins.py'
P=load(TOOL,'owned_tools')
ROOT=R
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
   def preserve_failed_probe():
    path=self.directory/(label+'.json');path.write_text(json.dumps({'argv':list(map(str,argv)),'seconds':limit,'exit':result['exit'] if result else None,'failure':result['failure'] if result else None,'collectionError':str(error),'runnerSHA256':result['runnerSHA256'] if result else None},indent=2)+'\n');self.receipts[str(path)]=sha(path)
   with B.GuardBoundary([('preserve failed owned probe',preserve_failed_probe),('failed owned probe raw namespace',self.guard)]):
    raise
  path=self.directory/(label+'.json');path.write_text(json.dumps({'argv':list(map(str,argv)),'seconds':limit,'exit':result['exit'],'failure':result['failure'],'runnerSHA256':result['runnerSHA256']},indent=2)+'\n');self.receipts[str(path)]=sha(path);self.guard();return result
 def guard(self):
  self.logs.guard();assert all(sha(p)==h for p,h in self.receipts.items())
  assert {str(p) for p in self.directory.iterdir()}==set(self.receipts)|{str(self.directory/n) for n in self.logs.hashes}
 def pins(self):return {**self.receipts,**{str(self.directory/n):h for n,h in self.logs.hashes.items()}}
def owned_configuration(ledger):
 return {'execute':ledger.execute,'tools':{'bend':shutil.which('bend'),'node':shutil.which('node'),'python':sys.executable,'taskset':shutil.which('taskset')},'resource_roots':['/home/node/.bend/bend2'],'ldd':shutil.which('ldd'),'taskset':shutil.which('taskset'),'cpu':5,'env':ledger.env,'skip_ldd':[],'capture_mode':'merged-stdout'}


def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def encode(x):
 if isinstance(x,bytes):return {'rawBase64':base64.b64encode(x).decode()}
 raise TypeError(type(x))
def decode(x):
 if isinstance(x,dict):return base64.b64decode(x['rawBase64']) if set(x)=={'rawBase64'} else {k:decode(v) for k,v in x.items()}
 if isinstance(x,list):return [decode(v) for v in x]
 return x
def prepare():
 proposal=H/'js-proposal.json';a=json.loads(proposal.read_text());assert sha(__file__)==a['wrapperSHA256'] and sha(H/'source-oracle-manifest.json')==a['sourceOracleManifestSHA256']
 assert sha(H.parents[5]/'pinned-bend-notice.bytes')=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
 files=closure()|{Path(__file__).resolve(),proposal,H/'source-oracle-manifest.json',H/'variant-source-joins.json',H/'normal/source-copy-joins.json',H/'author-oracles.py',H/'GENERATED-JS-PROPOSAL.md',H.parents[5]/'pinned-bend-notice.bytes',TOOL,R/'scripts/owned-tool-pins.py',R/'scripts/task_runner.py',R/'scripts/receipt-logs.py',COORDINATOR/'scripts/evidence_boundary.py'}
 sourceRecord=R/'.artifacts/check-relation55-reached-controls-source-1791461742993446675';sp=json.loads((sourceRecord/'plan.json').read_text());sr=json.loads((sourceRecord/'receipt.json').read_text())
 assert sha(sourceRecord/'plan.json')=='d44d63ed30f13a934be3ed14c205e84aed1d44fda93c397f9a1174f4a3c338f3' and sha(sourceRecord/'receipt.json')=='2d3ec9bb271a098c3c9fd8c804724fdbaf739dcbaad0672807450a2b258b3ee6'
 assert sr['status']=='DEVELOPMENT_FOUR_CHECK_CONTROL_SOURCES_FEASIBLE_NOT_RUNTIME' and not sr.get('guardFailures')
 assert len(sr['commands'])==4 and [c['label'] for c in sr['commands']]==list(NAMES)
 for actual,wanted in zip(sr['commands'],sp['commands']):
  assert actual['argv']==wanted['argv'] and actual['seconds']==5 and actual['exit']==0 and actual['failure'] is None
  assert (sourceRecord/(actual['label']+'.stdout')).read_bytes()==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
  assert (sourceRecord/(actual['label']+'.stderr')).read_bytes() in (b'',(H.parents[5]/'pinned-bend-notice.bytes').read_bytes())
 files.update((sourceRecord/'plan.json',sourceRecord/'receipt.json',Path(sp['privateEnvironment'])))
 assert sha(sp['privateEnvironment'])==sp['environmentSHA256']
 for name,digest in sp['pins'].items():assert sha(name)==digest;files.add(Path(name))
 for name,digest in sr['logs'].items():assert sha(sourceRecord/name)==digest;files.add(sourceRecord/name)
 for row in json.loads((H/'source-oracle-manifest.json').read_text())['independentModelSources']:
  f=R/row['path'];assert sha(f)==row['SHA256'];files.add(f)
 for name in NAMES:
  files.add(H/name/'expected-complete.json')
  if name!='normal':files.add(H/name/'expected-witnesses.json')
 membership=installed_membership();files.update(INSTALLED/n for n in membership)
 files.add(Path(sys.executable).resolve())
 out=R/'.artifacts'/('check-relation55-reached-controls-js-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();importJoins=[]
 for source in sorted(closure()):
  if source.is_relative_to(R):
   target=stage/source.relative_to(R);target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(source.read_bytes())
 for source in sorted(closure()):
  if not source.is_relative_to(R):continue
  copy=stage/source.relative_to(R)
  for name in re.findall(r'^import\s+(\S+)',source.read_text(),re.M):
   original=(INSTALLED/'base.bend' if name=='Base' else source.parent/name).resolve();actual=(INSTALLED/'base.bend' if name=='Base' else copy.parent/name).resolve()
   assert original in closure() and actual.is_file() and sha(original)==sha(actual)
   assert actual==(stage/original.relative_to(R) if original.is_relative_to(R) else original)
   importJoins.append({'source':str(source),'copy':str(copy),'import':name,'originalTarget':str(original),'actualTarget':str(actual),'SHA256':sha(original)})
 env=dict(os.environ,BEND_NO_TELEMETRY='1')
 for n in tuple(env):
  if n.startswith(('LD_','DYLD_')) or n in ('NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE'):env.pop(n,None)
 private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True)+'\n');private.chmod(0o600);files.add(private)
 before={str(f):sha(f) for f in sorted(files)};states=configuration(stage,out);stageBefore=inventory(stage);inputs=None;ledger=None;prep={'status':'INCOMPLETE','probeCommandsExecuted':0}
 def prepguard():
  assert all(sha(n)==h for n,h in before.items());assert configuration(stage,out)==states and inventory(stage)==stageBefore and installed_membership()==membership
  if inputs is not None:inputs.guard()
 def probeguard():
  if ledger is not None:ledger.guard();prep.update(probePins=ledger.pins(),probeCommandsExecuted=ledger.index)
 with B.ReceiptBoundary(prep,out/'prepare-receipt.json',[('all input/config bytes',prepguard),('owned preparation raw',probeguard)]):
  prepguard();inputs=T.Inputs(files=files,directories=[stage]);ledger=ProbeLedger(out/'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset')],inputs,env);tools=P.shared.snapshot(**owned_configuration(ledger));assert ledger.index==4;prep['status']='OWNED_JS_PREPARATION_PASS'
 files.update((out/'prepare-receipt.json',*map(Path,ledger.pins()),*map(Path,tools['pins'])))
 commands=[]
 for name,source,oracle in SUBJECTS:
  artifact=out/(name+'.js');entry=stage/(H/source).relative_to(R)
  commands.extend([{'label':'emit-'+name,'argv':['taskset','-c','5','bend',str(entry),'-o',str(artifact)],'seconds':30,'artifact':str(artifact),'variant':name},{'label':'js-'+name,'argv':['taskset','-c','5','node',str(artifact)],'seconds':5,'oracle':str(H/oracle),'variant':name}])
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'privateEnvironment':str(private),'environmentSHA256':sha(private),'stage':str(stage),'inventory':stageBefore,'stageImportJoins':importJoins,'configuration':states,'installedMembership':membership,'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-'+n for i in range(17) for n in ('bend','node','python','taskset')],'scope':'Ten real K.run callbacks/320 declaration visits plus192 separate diagnostics per full two-schema fixture; exact returned Bool/error/owners and actual gates. No When/policy/proof/full55/adoption/timing credit.','sourcePlanSHA256':sha(sourceRecord/'plan.json'),'sourceReceiptSHA256':sha(sourceRecord/'receipt.json')}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def differences(a,b,p=''):
 if type(a)!=type(b):return [{'path':p,'normal':a,'mutant':b}]
 if isinstance(a,dict):
  result=[]
  for key in sorted(a.keys()|b.keys()):
   if key not in a or key not in b:result.append({'path':p+'/'+key,'normal':a.get(key),'mutant':b.get(key)})
   else:result+=differences(a[key],b[key],p+'/'+key)
  return result
 if isinstance(a,list):
  if len(a)!=len(b):return [{'path':p,'normal':a,'mutant':b}]
  return [d for i,(x,y) in enumerate(zip(a,b)) for d in differences(x,y,p+'/'+str(i))]
 return [] if a==b else [{'path':p,'normal':a,'mutant':b}]

def run(path):
 path=Path(path).resolve();out=path.parent;planSHA=sha(path);p=None;stage=None;private=None;inputs=None;ledger=None;logs=None;runner=None;generated={};record={'status':'INCOMPLETE','planSHA256':planSHA,'commands':[]};normalActual=None
 def metadata():
  assert sha(path)==planSHA==record['planSHA256']
  if p is None:return
  assert all(sha(n)==h for n,h in p['pins'].items());assert sha(private)==p['environmentSHA256'];assert inventory(stage)==p['inventory'] and configuration(stage,out)==p['configuration'] and installed_membership()==p['installedMembership'];assert all(sha(n)==h for n,h in generated.items())
  for row in p['stageImportJoins']:assert sha(row['source'])==sha(row['copy']) and sha(row['originalTarget'])==sha(row['actualTarget'])==row['SHA256']
  assert {c['artifact'] for c in p['commands'] if 'artifact' in c and Path(c['artifact']).exists()}==set(generated)
  if inputs is not None:inputs.guard()
 def owned():
  metadata();P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 def rawguard():
  if logs is not None:record['logs']=dict(logs.hashes);logs.guard()
  if ledger is not None:record.update(probePins=ledger.pins(),probeCommandsExecuted=ledger.index);ledger.guard()
  record['generated']=dict(generated)
 with B.ReceiptBoundary(record,out/'receipt.json',[('final all input/config bytes',metadata),('final complete raw',rawguard)]):
  metadata();p=decode(json.loads(path.read_text()));stage=Path(p['stage']);private=Path(p['privateEnvironment']);record['scope']=p['scope'];metadata();env=json.loads(private.read_text());inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],inputs,env);logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=stage,capture='split');owned()
  for command in p['commands']:
   owned()
   if 'artifact' in command:assert not Path(command['artifact']).exists()
   item={**command,'exit':None,'failure':None,'status':'NOT_COLLECTED'};record['commands'].append(item)
   def register_generated():
    nonlocal inputs
    if 'artifact' in command and Path(command['artifact']).exists():
     assert Path(command['artifact']).is_file();generated[command['artifact']]=sha(command['artifact']);inputs=T.Inputs(files=[path,*p['pins'],*generated],directories=[stage]);runner.inputs=inputs;ledger.runner.inputs=inputs
   with B.GuardBoundary([('register generated bytes',register_generated),('post-child owned source/tools',owned),('post-child complete raw',rawguard)]):
    try:result=runner.run(command['label'],command['argv'],command['seconds'],expected=None);item.update(exit=result['exit'],failure=result['failure'],status='COLLECTED')
    except BaseException as e:
     failed=getattr(e,'result',None)
     if failed is not None:item.update(exit=failed['exit'],failure=failed['failure'])
     item['collectionError']=str(e);raise
   assert result['exit']==0 and result['failure'] is None
   if 'artifact' in command:
    assert result['stdout']==b'' and result['stderr'] in (b'',(H.parents[5]/'pinned-bend-notice.bytes').read_bytes());assert Path(command['artifact']).is_file() and generated[command['artifact']]==sha(command['artifact'])
   else:
    assert result['stderr']==b'';text=result['stdout'].decode();actual,end=json.JSONDecoder().raw_decode(text);assert text[end:].encode()==b'\n';assert strict(actual)==strict(json.loads(Path(command['oracle']).read_text()))
    assert sum(len(phase['queries']) for schema in actual['schemas'] for phase in schema['phases'])==192
    name=command['variant'];expectedBool=name=='normal'
    assert all(schema['phaseChecks']==[{'done':expectedBool}]*3 and schema['gate']['bodyMarkers']==(1 if expectedBool else 0) and schema['gate']['allowed']==([{'ran':1}] if expectedBool else [{'skipped':1}]) and schema['gate']['skipped']==[{'skipped':1}] for schema in actual['schemas'])
    if expectedBool:normalActual=actual
    else:
     assert normalActual is not None
     witnesses=differences(normalActual,actual);wanted=json.loads((H/name/'expected-witnesses.json').read_text());assert strict(witnesses)==strict(wanted);item['witnesses']=len(witnesses);item['witnessSHA256']=sha(H/name/'expected-witnesses.json')
    item['fullOracleMatched']=True;item['oracleSHA256']=sha(command['oracle'])
   item['status']='QUALIFIED'
  assert ledger.index==68;record['status']='DEVELOPMENT_FOUR_REACHED_CHECK_CONTROLS_FULL192_DIAGNOSTICS_JS_PASS_NOT_FULL55'
 print(out)
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
