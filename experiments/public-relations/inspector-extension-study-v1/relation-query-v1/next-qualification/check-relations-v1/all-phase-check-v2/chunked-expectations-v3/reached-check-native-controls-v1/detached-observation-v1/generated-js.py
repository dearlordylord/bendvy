"""Standalone full Check consumer; external coordinator owns serial flock."""
import tarfile,base64,argparse,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent;R=next(p for p in H.parents if (p/"scripts/task_runner.py").exists())
COORDINATOR=Path('/workspace/formal-proofs/bendvy')
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(R/'scripts/task_runner.py','task_runner');L=load(R/'scripts/receipt-logs.py','receipt_logs');B=load(COORDINATOR/'scripts/evidence_boundary.py','evidence_boundary')
NAMES=('normal',)
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
 proposal=H/'js-proposal.json';a=json.loads(proposal.read_text());assert sha(__file__)==a['wrapperSHA256'] and sha(H/'source-proposal.json')==a['sourceProposalSHA256']
 notice=R/'experiments/public-relations/inspector-extension-study-v1/pinned-bend-notice.bytes';assert sha(notice)=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
 files=closure()|{Path(__file__).resolve(),proposal,H/'source-proposal.json',H/'source-joins.json',H/'source.diff',H/'source-positive.bend',H/'normal/expected-complete.json',notice,TOOL,R/'scripts/owned-tool-pins.py',R/'scripts/task_runner.py',R/'scripts/receipt-logs.py',COORDINATOR/'scripts/evidence_boundary.py'}
 sourceRecord=R/'.artifacts/check55-detached-source-dev-1791466119998852285';sp=json.loads((sourceRecord/'plan.json').read_text());sr=json.loads((sourceRecord/'receipt.json').read_text())
 assert sha(sourceRecord/'plan.json')=='8478f5bdc9713e74377a8a42d5a049990560bcfbee5a2c9350d2ab4d92a11cb4' and sr['planSHA256']==sha(sourceRecord/'plan.json') and sr['status']=='SOURCE_FEASIBLE_NOT_PROOF' and sr['exit']==0 and sr['failure'] is None and not sr['sourceDrift']
 assert sp['seconds']==sr['seconds']==5 and sr['command']==sp['argv'] and sp['argv']==['taskset','-c','5','bend',str(H/'source-positive.bend'),'--check-only']
 assert (sourceRecord/'stdout.raw').read_bytes()==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and (sourceRecord/'stderr.raw').read_bytes()==b''
 files.update((sourceRecord/'plan.json',sourceRecord/'receipt.json'))
 for name,digest in sp['sourcePins'].items():assert sha(name)==digest;files.add(Path(name))
 for name,digest in sr['rawSHA256'].items():f=sourceRecord/(name+'.raw');assert sha(f)==digest;files.add(f)
 # Historical qualified JS remains a whole-output authority, not new candidate credit.
 hist=R/'.artifacts/check-relation55-reached-controls-js-1791462194945874132';hp=json.loads((hist/'plan.json').read_text());hr=json.loads((hist/'receipt.json').read_text());hq=json.loads((hist/'prepare-receipt.json').read_text())
 assert sha(hist/'plan.json')=='69ffb7f1a432d152b6b47d5829b7092ce9a7538355eb2c4ee2ae6755f11d9f76' and sha(hist/'receipt.json')=='c6e0baada28d82ab35635874f26c2782b277316fc66db24a8c3bf07e53b79fbd'
 assert hr['status']=='DEVELOPMENT_FOUR_REACHED_CHECK_CONTROLS_FULL192_DIAGNOSTICS_JS_PASS_NOT_FULL55' and not hr.get('guardFailures') and hq['status']=='OWNED_JS_PREPARATION_PASS' and not hq.get('guardFailures') and hr['probeCommandsExecuted']==68 and hq['probeCommandsExecuted']==4
 for f in (hist/'plan.json',hist/'receipt.json',hist/'prepare-receipt.json',Path(hp['privateEnvironment'])):files.add(f)
 assert sha(hp['privateEnvironment'])==hp['environmentSHA256']
 for name,digest in hp['pins'].items():assert sha(name)==digest;files.add(Path(name))
 for receipt in (hr,hq):
  for name,digest in receipt['probePins'].items():assert sha(name)==digest;files.add(Path(name))
 for name,digest in hr['logs'].items():f=hist/name;assert sha(f)==digest;files.add(f)
 for name,digest in hr['generated'].items():assert sha(name)==digest;files.add(Path(name))
 assert strict(json.loads((hist/'js-normal.stdout').read_bytes()))==strict(json.loads((H/'normal/expected-complete.json').read_bytes()))
 # Exact failed C30 and additive-wrapper parser failure remain immutable history.
 failed=R/'.artifacts/check-relation55-reached-native-normal-1791464870172183905';fp=json.loads((failed/'plan.json').read_text());fr=json.loads((failed/'receipt.json').read_text());fq=json.loads((failed/'prepare-receipt.json').read_text())
 assert sha(failed/'plan.json')=='88b98c14bbaa3e1424ad54ad48fb8b7986465fd10a4d3751bf9beb7b95abfe89' and sha(failed/'receipt.json')=='28f9fa27dcb2fa0f7eb8a9aa51b94829b8938345661a666ce03010c41188586a' and fr['status']=='INCOMPLETE' and not fr.get('guardFailures') and fr['probeCommandsExecuted']==15 and fq['probeCommandsExecuted']==5
 files.update((failed/'plan.json',failed/'receipt.json',failed/'prepare-receipt.json',Path(fp['privateEnvironment'])))
 assert sha(fp['privateEnvironment'])==fp['environmentSHA256']
 for name,digest in fp['pins'].items():assert sha(name)==digest;files.add(Path(name))
 for receipt in (fr,fq):
  for name,digest in receipt['probePins'].items():assert sha(name)==digest;files.add(Path(name))
 for name,digest in fr['logs'].items():f=failed/name;assert sha(f)==digest;files.add(f)
 old=R/'.artifacts/check55-detached-source-dev-1791466043914719214';op=json.loads((old/'plan.json').read_text());orr=json.loads((old/'receipt.json').read_text())
 assert sha(old/'plan.json')=='e8f50daba929085f33870409cda7a038d39ee3e063c28492f17589eb610297bb' and sha(old/'receipt.json')=='8d4414e3e8370c481af946cfc05efa815e0efa9761ecbe99885742e02a192385' and orr['status']=='INCOMPLETE' and orr['exit']==1 and orr['failure'] is None and not orr['sourceDrift'] and orr['planSHA256']==sha(old/'plan.json')
 assert orr['command']==op['argv'] and op['seconds']==orr['seconds']==5
 for name,digest in orr['rawSHA256'].items():assert sha(old/(name+'.raw'))==digest
 with tarfile.open(H/'review-e8f-wrapper-parser/source-attempt.tar.gz') as tar:
  archived={m.name:tar.extractfile(m).read() for m in tar.getmembers() if m.isfile()}
  for name,digest in op['sourcePins'].items():
   f=Path(name)
   if f.is_relative_to(R):assert hashlib.sha256(archived[str(f.relative_to(R))]).hexdigest()==digest
   else:assert sha(f)==digest;files.add(f)
 for f in (old/'plan.json',old/'receipt.json',old/'stdout.raw',old/'stderr.raw',H/'review-e8f-wrapper-parser/source-attempt.tar.gz'):files.add(f)
 for f in (H.parent/'review-88b-C-emission-deadline').rglob('*'):
  if f.is_file():files.add(f)
 membership=installed_membership();files.update(INSTALLED/n for n in membership)
 files.add(Path(sys.executable).resolve())
 out=R/'.artifacts'/('check55-detached-normal-js-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();importJoins=[]
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
  if ledger is not None:prep.update(probePins=ledger.pins(),probeCommandsExecuted=ledger.index);ledger.guard()
 with B.ReceiptBoundary(prep,out/'prepare-receipt.json',[('all input/config bytes',prepguard),('owned preparation raw',probeguard)]):
  prepguard();inputs=T.Inputs(files=files,directories=[stage]);ledger=ProbeLedger(out/'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset')],inputs,env);tools=P.shared.snapshot(**owned_configuration(ledger));assert ledger.index==4;prep['status']='OWNED_JS_PREPARATION_PASS'
 files.update((out/'prepare-receipt.json',*map(Path,ledger.pins()),*map(Path,tools['pins'])))
 commands=[]
 for name,source,oracle in SUBJECTS:
  artifact=out/(name+'.js');originalEntry=(H/source).resolve();entry=stage/originalEntry.relative_to(R)
  assert '..' not in entry.parts and entry.is_file() and sha(entry)==sha(originalEntry)==stageBefore[str(entry.relative_to(stage))]
  commands.extend([{'label':'emit-'+name,'argv':['taskset','-c','5','bend',str(entry),'-o',str(artifact)],'seconds':30,'artifact':str(artifact),'variant':name},{'label':'js-'+name,'argv':['taskset','-c','5','node',str(artifact)],'seconds':5,'oracle':str(H/oracle),'variant':name}])
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'privateEnvironment':str(private),'environmentSHA256':sha(private),'stage':str(stage),'inventory':stageBefore,'stageImportJoins':importJoins,'configuration':states,'installedMembership':membership,'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-'+n for i in range(5) for n in ('bend','node','python','taskset')],'scope':'Ten real K.run callbacks/320 declaration visits plus192 separate diagnostics per full two-schema fixture; exact returned Bool/error/owners and actual gates. No When/policy/proof/full55/adoption/timing credit.','sourcePlanSHA256':sha(sourceRecord/'plan.json'),'sourceReceiptSHA256':sha(sourceRecord/'receipt.json')}
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
    assert result['stdout']==b'' and result['stderr'] in (b'',(R/'experiments/public-relations/inspector-extension-study-v1/pinned-bend-notice.bytes').read_bytes());assert Path(command['artifact']).is_file() and generated[command['artifact']]==sha(command['artifact'])
   else:
    assert result['stderr']==b'';text=result['stdout'].decode();actual,end=json.JSONDecoder().raw_decode(text);assert text[end:].encode()==b'\n';assert strict(actual)==strict(json.loads(Path(command['oracle']).read_text()))
    assert sum(len(phase['queries']) for schema in actual['schemas'] for phase in schema['phases'])==192
    name=command['variant'];expectedBool=name=='normal'
    assert all(schema['phaseChecks']==[{'done':expectedBool}]*3 and schema['gate']['bodyMarkers']==(1 if expectedBool else 0) and schema['gate']['allowed']==([{'ran':1}] if expectedBool else [{'skipped':1}]) and schema['gate']['skipped']==[{'skipped':1}] for schema in actual['schemas'])
    if expectedBool:
     assert result['stdout']==(R/'.artifacts/check-relation55-reached-controls-js-1791462194945874132/js-normal.stdout').read_bytes()
     normalActual=actual
    else:
     assert normalActual is not None
     witnesses=differences(normalActual,actual);wanted=json.loads((H/name/'expected-witnesses.json').read_text());assert strict(witnesses)==strict(wanted);item['witnesses']=len(witnesses);item['witnessSHA256']=sha(H/name/'expected-witnesses.json')
    item['fullOracleMatched']=True;item['oracleSHA256']=sha(command['oracle'])
   item['status']='QUALIFIED'
  assert ledger.index==20;record['status']='DEVELOPMENT_DETACHED_CHECK_OBSERVATION_NORMAL_JS_PASS_NOT_FULL55'
 print(out)
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
