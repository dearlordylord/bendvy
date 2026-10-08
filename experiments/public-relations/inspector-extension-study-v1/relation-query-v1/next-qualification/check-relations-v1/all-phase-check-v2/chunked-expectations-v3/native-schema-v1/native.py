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
SUBJECTS=(('workshop','workshop-io.bend','expected-workshop.json'),('garden','garden-io.bend','expected-garden.json'))
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
 extra=set() if stage is None else {out,stage,*[p.parent for p in stage.rglob('*.bend')]}
 native=P.configuration();extra|={Path(x).resolve().parent for x in native['tools'].values()}|{Path(x) for x in native['resource_roots']}
 for origin in (extra|{p.parent for p in closure()}|{H,R,COORDINATOR,INSTALLED,Path.home(),Path.home()/'.bend'}|{Path(shutil.which(n)).resolve().parent for n in ('bend','node','taskset')}):
  for parent in (origin,*origin.parents):
   for name in ('.bend.json','bend.config.json','bend.json','bend.jsonc','bend.toml','check.json','check.jsonc','bender.json','bender.jsonc','.bend','package.json','tsconfig.json','.node-version','.nvmrc','.npmrc','clang.cfg','.clang'):
    paths.add(parent/name)
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
 configuration=P.configuration();configuration.update(execute=ledger.execute,env=ledger.env,cpu=5);return configuration


def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def encode(x):
 if isinstance(x,bytes):return {'rawBase64':base64.b64encode(x).decode()}
 raise TypeError(type(x))
def decode(x):
 if isinstance(x,dict):return base64.b64decode(x['rawBase64']) if set(x)=={'rawBase64'} else {k:decode(v) for k,v in x.items()}
 if isinstance(x,list):return [decode(v) for v in x]
 return x
def prepare():
 out=R/'.artifacts'/('check-relation55-schema-native-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir()
 record={'status':'INCOMPLETE','probeCommandsExecuted':0};before=None;states=None;stageBefore=None;inputs=None;ledger=None;env=None;envBefore=None
 def prepguard():
  if before is None:return
  assert all(sha(n)==digest for n,digest in before.items()) and configuration(stage,out)==states and inventory(stage)==stageBefore and json.dumps(env,sort_keys=True)==envBefore
  if inputs is not None:inputs.guard()
 def probeguard():
  if ledger is not None:ledger.guard();record.update(probePins=ledger.pins(),probeCommandsExecuted=ledger.index)
 with B.ReceiptBoundary(record,out/'prepare-receipt.json',[('all preparation bytes/config/env',prepguard),('preparation raw',probeguard)]):
  proposal=H/'native-proposal.json';q=json.loads(proposal.read_text());assert sha(__file__)==q['wrapperSHA256']
  files=closure()|{Path(__file__).resolve(),proposal,H/'source-proposal.json',H.parent/'expected-complete.json',TOOL,R/'scripts/owned-tool-pins.py',R/'scripts/task_runner.py',R/'scripts/receipt-logs.py',COORDINATOR/'scripts/evidence_boundary.py',H.parents[5]/'pinned-bend-notice.bytes'}
  for n,digest in q['sourceAndOraclePins'].items():assert sha(R/n)==digest;files.add(R/n)
  normal=R/'.artifacts/check-relation55-chunk-standalone-js-1791457454442741470';np=json.loads((normal/'plan.json').read_text());nr=json.loads((normal/'receipt.json').read_text())
  assert sha(normal/'plan.json')=='49647d8cbb7a4d4f979b808c464aca3b88b67e74aa000141abeac0058925997e'==nr['planSHA256'] and sha(normal/'receipt.json')=='d76961ef23f206b031968eff9f4f4c0cebe1b6050c40ec4faf761bbc3a4c9e79'
  assert nr['status']=='DEVELOPMENT_STANDALONE_JS_CHECK320_PLUS192_DIAGNOSTICS_PASS_NOT_FULL55' and nr.get('guardFailures',[])==[] and nr['probeCommandsExecuted']==20
  files.update((normal/'plan.json',normal/'receipt.json',normal/'prepare-receipt.json'))
  for n,digest in np['pins'].items():assert sha(n)==digest;files.add(Path(n))
  for n,digest in np['inventory'].items():path=Path(np['stage'])/n;assert sha(path)==digest;files.add(path)
  for rec,folder,labels in ((nr,'execution-probes',np['executionProbeLabels']),(json.loads((normal/'prepare-receipt.json').read_text()),'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset')])):
   assert rec.get('guardFailures',[])==[] and len(labels)==rec['probeCommandsExecuted'];assert set(rec['probePins'])=={str(normal/folder/(label+suffix)) for label in labels for suffix in ('.json','.stdout','.stderr')}
   for n,digest in rec['probePins'].items():assert sha(n)==digest;files.add(Path(n))
   for label in labels:
    m=json.loads((normal/folder/(label+'.json')).read_text());tool=label.rsplit('-',1)[-1]
    assert m['argv']==[np['tools']['taskset'],'-c','5',np['tools']['ldd'],np['tools']['tools'][tool]] and m['seconds']==5 and m['exit']==0 and m['failure'] is None and m.get('exception') is None and m['runnerSHA256']==np['pins'][str(R/'scripts/task_runner.py')]
  for n,digest in nr['logs'].items():assert sha(normal/n)==digest;files.add(normal/n)
  for n,digest in nr['generated'].items():assert sha(n)==digest;files.add(Path(n))
  assert nr['commands'][1]['fullOracleMatched'] is True and nr['commands'][1]['oracleSHA256']==sha(H.parent/'expected-complete.json')
  typed=R/'.artifacts/check-relation55-schema-source-1791459062128874336';sp=json.loads((typed/'plan.json').read_text());sr=json.loads((typed/'receipt.json').read_text())
  assert sha(typed/'receipt.json')=='b5e298d8cbd6bc6c406d3e4b46708c5beb871c4c70f48b3926b3f583df300629' and sha(typed/'plan.json')==sr['planSHA256']=='673489e0b9bb54ea386d0011c412ec3e723391406574cd676a888bd63fe966ee'
  assert sr['status']=='DEVELOPMENT_TWO_NATIVE_ROOT_SOURCES_FEASIBLE_NOT_NATIVE' and sr.get('guardFailures',[])==[] and len(sr['commands'])==2
  files.update((typed/'plan.json',typed/'receipt.json'))
  assert sha(sp['privateEnvironment'])==sp['environmentSHA256'];files.add(Path(sp['privateEnvironment']))
  for n,digest in sp['pins'].items():assert sha(n)==digest;files.add(Path(n))
  for n,digest in sr['logs'].items():assert sha(typed/n)==digest;files.add(typed/n)
  for pc,rc in zip(sp['commands'],sr['commands']):
   assert all(pc[k]==rc[k] for k in ('label','argv','seconds')) and rc['exit']==0 and rc['failure'] is None and rc['seconds']==5
   assert (typed/(rc['label']+'.stdout')).read_bytes()==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and (typed/(rc['label']+'.stderr')).read_bytes()==b''
  whole=json.loads((H.parent/'expected-complete.json').read_text());assert whole=={'schemas':[json.loads((H/'expected-workshop.json').read_text())['schemas'][0],json.loads((H/'expected-garden.json').read_text())['schemas'][0]]}
  membership=installed_membership();files.update(INSTALLED/n for n in membership)
  for source in closure():
   if source.is_relative_to(R):target=stage/source.relative_to(R);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target);assert sha(target)==sha(source)
  joins=[]
  for source in closure():
   if not source.is_relative_to(R):continue
   copy=stage/source.relative_to(R)
   for name in re.findall(r'^import\s+(\S+)',source.read_text(),re.M):
    original=(INSTALLED/'base.bend' if name=='Base' else source.parent/name).resolve();target=(INSTALLED/'base.bend' if name=='Base' else copy.parent/name).resolve()
    assert original in closure() and target.is_file() and sha(original)==sha(target)
    assert target==stage/original.relative_to(R) if original.is_relative_to(R) else name=='Base' and target==original
    joins.append({'source':str(source),'copy':str(copy),'import':name,'originalTarget':str(original),'actualTarget':str(target),'SHA256':sha(original)})
  env=P.configuration()['env'];approvedLD=env.get('LD_LIBRARY_PATH')
  for n in tuple(env):
   if n.startswith(('LD_','DYLD_')) or n in ('NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE'):env.pop(n,None)
  if approvedLD is not None:env['LD_LIBRARY_PATH']=approvedLD
  states=configuration(stage,out);files.update(Path(n) for n,state in states.items() if state['kind']=='file');before={str(path):sha(path) for path in sorted(files)};stageBefore=inventory(stage);envBefore=json.dumps(env,sort_keys=True);inputs=T.Inputs(files=files,directories=[stage]);ledger=ProbeLedger(out/'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset','clang')],inputs,env)
  prepguard();tools=P.shared.snapshot(**owned_configuration(ledger));assert ledger.index==5;record['status']='OWNED_NATIVE_PREPARATION_PASS'
 private=out/'private-environment.json';private.write_text(envBefore);private.chmod(0o600);files.update((out/'prepare-receipt.json',private));files.update(map(Path,ledger.pins()));files.update(map(Path,tools['pins']))
 commands=[]
 for family,source,oracle in SUBJECTS:
  c=out/(family+'.c');binary=out/(family+'-native');entry=stage/(H/source).relative_to(R)
  commands.extend([{'label':'emit-'+family,'argv':['taskset','-c','5','bend',str(entry),'-o',str(c)],'seconds':30,'artifact':str(c)},{'label':'compile-'+family,'argv':['taskset','-c','5','/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(c),'-pthread','-lm','-o',str(binary)],'seconds':120,'artifact':str(binary)},{'label':'run-'+family,'argv':['taskset','-c','5',str(binary),'--threads','1','--gpu','off'],'seconds':5,'family':family,'oracle':str(H/oracle)}])
 p={'pins':{str(path):sha(path) for path in sorted(files)},'tools':tools,'privateEnvironment':str(private),'environmentSHA256':sha(private),'stage':str(stage),'inventory':stageBefore,'stageImportJoins':joins,'configuration':states,'installedMembership':membership,'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-'+n for i in range(13) for n in ('bend','node','python','taskset','clang')],'scope':'Native two complete schema branches total320actualK+192separate diagnostics/selectedowners; no proof/performance/full55/adoption'}
 (out/'plan.json').write_text(json.dumps(p,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();out=path.parent;planSHA=sha(path);p=None;stage=None;private=None;inputs=None;ledger=None;logs=None;runner=None;generated={};schemaRaw={};record={'status':'INCOMPLETE','planSHA256':planSHA,'commands':[]}
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
  if logs is not None:logs.guard();record['logs']=dict(logs.hashes)
  if ledger is not None:ledger.guard();record.update(probePins=ledger.pins(),probeCommandsExecuted=ledger.index)
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
    assert result['stdout']==b'';assert result['stderr'] in (b'',(H.parents[5]/'pinned-bend-notice.bytes').read_bytes()) if command['label'].startswith('emit-') else result['stderr']==b'';assert Path(command['artifact']).is_file() and generated[command['artifact']]==sha(command['artifact'])
   else:
    assert result['stderr']==b'';text=result['stdout'].decode();actual,end=json.JSONDecoder().raw_decode(text);assert text[end:].encode()==b'\n';assert strict(actual)==strict(json.loads(Path(command['oracle']).read_text()))
    assert sum(len(phase['queries']) for schema in actual['schemas'] for phase in schema['phases'])==96;assert all(s['gate']['bodyMarkers']==1 and s['gate']['allowed']==[{'ran':1}] and s['gate']['skipped']==[{'skipped':1}] for s in actual['schemas']);item['fullOracleMatched']=True;item['oracleSHA256']=sha(command['oracle']);raw=result['stdout'];assert raw.startswith(b'{"schemas":[') and raw.endswith(b']}\n');schemaRaw[command['family']]=raw[len(b'{"schemas":['):-3]
   item['status']='QUALIFIED'
  assert ledger.index==65 and set(schemaRaw)=={'workshop','garden'}
  combined=b'{"schemas":['+schemaRaw['workshop']+b','+schemaRaw['garden']+b']}\n';assert combined==(R/'.artifacts/check-relation55-chunk-standalone-js-1791457454442741470/js-check.stdout').read_bytes();assert strict(json.loads(combined))==strict(json.loads((H.parent/'expected-complete.json').read_text()));record.update(full192DiagnosticAnd320CheckJoinMatched=True,combinedFullRawSHA256=hashlib.sha256(combined).hexdigest(),status='DEVELOPMENT_TWO_SCHEMA_NATIVE_CHECK320_PLUS192_DIAGNOSTICS_PASS_NOT_FULL55')
 print(out)
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
