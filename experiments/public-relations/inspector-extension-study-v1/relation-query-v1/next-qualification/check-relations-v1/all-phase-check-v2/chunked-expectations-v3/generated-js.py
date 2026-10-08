"""Standalone full Check consumer; external coordinator owns serial flock."""
import base64,argparse,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
H=Path(__file__).resolve().parent;R=H.parents[7]
COORDINATOR=Path('/workspace/formal-proofs/bendvy')
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(R/'scripts/task_runner.py','task_runner');L=load(R/'scripts/receipt-logs.py','receipt_logs');B=load(COORDINATOR/'scripts/evidence_boundary.py','evidence_boundary')
SUBJECTS=(('check-js','complete-io.bend','expected-complete.json'),)
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
 for origin in (extra|{p.parent for p in closure()}|{H,R,COORDINATOR,INSTALLED,Path.home(),Path.home()/'.bend'}|{Path(shutil.which(n)).resolve().parent for n in ('bend','node','taskset')}):
  for parent in (origin,*origin.parents):
   for name in ('.bend.json','bend.config.json','bend.json','bend.jsonc','bend.toml','check.json','check.jsonc','bender.json','bender.jsonc','.bend','package.json','tsconfig.json','.node-version','.nvmrc','.npmrc'):
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
 a=json.loads((H/'js-proposal.json').read_text());assert sha(Path(__file__).resolve())==a['wrapperSHA256'];assert sha(H/'complete-io.bend')==a['sourceSHA256'];assert sha(H/'expected-complete.json')==a['oracleSHA256']
 files=closure()|{Path(__file__).resolve(),H/'js-proposal.json',H/'source-proposal.json',H/'expected-complete.json',H/'author-strings.py',H.parents[1]/'author-gate-strings.py',H.parents[1]/'author-complete-oracle.py',H.parents[1]/'author-query-oracle.py',H.parents[3]/'author-oracle-v2.py',H.parent/'expected-complete.json',H.parents[4]/'pinned-bend-notice.bytes',TOOL,R/'scripts/owned-tool-pins.py',R/'scripts/task_runner.py',R/'scripts/receipt-logs.py',COORDINATOR/'scripts/evidence_boundary.py'}
 assert (H/'expected-complete.json').read_bytes()==(H.parent/'expected-complete.json').read_bytes()
 sourceRecord=H/'development/source-1791457127801796816';sr=json.loads((sourceRecord/'plan.json').read_text());assert (sourceRecord/'exit').read_text()=='0\n'
 for name,digest in sr['ownedSourceHashes'].items():assert sha(name)==digest
 files.update(p for p in sourceRecord.iterdir() if p.is_file())
 for source in (H.parents[3]/'source-joins.json',H.parents[1]/'gated-core-joins.json'):
  files.add(source);joined=json.loads(source.read_text())
  for row in joined.get('files',joined.get('joins',[])):
   original=Path(row['source']);copy=R/row['copy'] if 'sourceSHA256' in row else H.parents[3]/row['copy']
   if 'sourceSHA256' in row:
    assert sha(original)==row['sourceSHA256'] and sha(copy)==row['copySHA256'];assert copy.read_bytes()==original.read_bytes().replace(b'import ./world.bend as W',b'import ../../../core-v1/src/ecs/world.bend as W')
   else:assert sha(original)==sha(copy)==row['SHA256']
   files.update((original,copy))
 ts=R/'.artifacts/check-relation55-ts-1791455293147900891';tp=json.loads((ts/'plan.json').read_text());tr=json.loads((ts/'receipt.json').read_text())
 assert sha(ts/'plan.json')=='bc51730cf85af77ef53b59863d7328256f69ac64be7edcd3cfd1dd78d84897f2' and sha(ts/'receipt.json')=='338540d86c1097cefa9106e28eda985d04fa4829779a48ad1d76ed877bf779e8'
 assert tr['status']=='DEVELOPMENT_ACTUAL_TS_CHECK192_PLUS128_PASS_NOT_FULL55' and tr.get('guardFailures',[])==[] and len(tr['commands'])==1
 assert all(tr['commands'][0][k]==tp['command'][k] for k in ('label','argv','seconds')) and tp['command']['seconds']==5
 assert tr['commands'][0]['exit']==0 and tr['commands'][0]['failure'] is None and tr['commands'][0]['fullOracleMatched'] is True and set(tr['logs'])=={'ts-relations.stdout','ts-relations.stderr'}
 files.update((ts/'plan.json',ts/'receipt.json',Path(tp['privateEnvironment'])))
 for name,digest in tp['pins'].items():assert sha(name)==digest;files.add(Path(name))
 for name,digest in tr['logs'].items():assert sha(ts/name)==digest;files.add(ts/name)
 assert sha(tp['privateEnvironment'])==tp['environmentSHA256']
 assert strict(json.loads((ts/'ts-relations.stdout').read_bytes()))==strict(json.loads(Path(tp['oracle']).read_text())) and (ts/'ts-relations.stderr').read_bytes()==b''
 failed=R/'.artifacts/check-relation55-boundary-io-1791455550381679103';fp=json.loads((failed/'plan.json').read_text());fr=json.loads((failed/'receipt.json').read_text())
 assert sha(failed/'plan.json')=='0efaf164900088ed5e429db52fd10aff542ab4e1fc3613b5e290077fe6f3850c' and sha(failed/'receipt.json')=='2fd0c06cf9470d6a60df8a7cc603ad99f73b41932df4a04411599262e85f542c'
 assert all(fr['commands'][0][k]==fp['commands'][0][k] for k in ('label','argv','seconds')) and fp['commands'][0]['seconds']==5
 assert fr['status']=='INCOMPLETE' and fr.get('guardFailures',[])==[] and len(fr['commands'])==1 and fr['commands'][0]['exit']==1 and fr['commands'][0]['failure'] is None and set(fr['logs'])=={'check-io.stdout','check-io.stderr'}
 assert (failed/'check-io.stdout').read_bytes()==b'' and (failed/'check-io.stderr').read_bytes()==b'Error: the machine stack overflowed (a deep recursion, or a literal too large to expand)\n'
 files.update((failed/'plan.json',failed/'receipt.json',Path(fp['privateEnvironment'])))
 for name,digest in fp['pins'].items():assert sha(name)==digest;files.add(Path(name))
 for name,digest in fr['logs'].items():assert sha(failed/name)==digest;files.add(failed/name)
 assert sha(fp['privateEnvironment'])==fp['environmentSHA256']
 emissionHistory=R/'.artifacts/check-relation55-standalone-js-1791456378843042105';op=decode(json.loads((emissionHistory/'plan.json').read_text()));orr=json.loads((emissionHistory/'receipt.json').read_text());opr=json.loads((emissionHistory/'prepare-receipt.json').read_text())
 assert sha(emissionHistory/'plan.json')=='f13ca8627f14a6aa2a3920ca29514049d5316b5db301ad26baf3c80bedaf0480' and sha(emissionHistory/'receipt.json')=='4dbb74c6498522c3d211c1f64e089082a695863d0d2c20986ce3cca1769c097d'
 assert orr['status']=='INCOMPLETE' and orr.get('guardFailures',[])==[] and len(orr['commands'])==1 and orr['commands'][0]['exit']==1 and orr['commands'][0]['failure'] is None
 assert all(orr['commands'][0][k]==op['commands'][0][k] for k in ('label','argv','seconds','artifact')) and op['commands'][0]['seconds']==30 and not Path(op['commands'][0]['artifact']).exists() and orr['generated']=={}
 assert orr['probeCommandsExecuted']==12 and opr['status']=='OWNED_JS_PREPARATION_PASS' and opr['probeCommandsExecuted']==4 and opr.get('guardFailures',[])==[]
 assert inventory(Path(op['stage']))==op['inventory'];files.update(p for p in Path(op['stage']).rglob('*') if p.is_file());files.update((emissionHistory/'plan.json',emissionHistory/'receipt.json',emissionHistory/'prepare-receipt.json',Path(op['privateEnvironment'])))
 assert sha(op['privateEnvironment'])==op['environmentSHA256']
 for name,digest in op['pins'].items():assert sha(name)==digest;files.add(Path(name))
 assert set(orr['logs'])=={'emit-check.stdout','emit-check.stderr'} and (emissionHistory/'emit-check.stdout').read_bytes()==b'' and (emissionHistory/'emit-check.stderr').read_bytes()==(failed/'check-io.stderr').read_bytes()
 for name,digest in orr['logs'].items():assert sha(emissionHistory/name)==digest;files.add(emissionHistory/name)
 for record,folder,labels in ((orr,'execution-probes',op['executionProbeLabels'][:12]),(opr,'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset')])):
  assert set(record['probePins'])=={str(emissionHistory/folder/(label+suffix)) for label in labels for suffix in ('.json','.stdout','.stderr')}
  for name,digest in record['probePins'].items():assert sha(name)==digest;files.add(Path(name))
  for label in labels:
   item=json.loads((emissionHistory/folder/(label+'.json')).read_text());tool=label.rsplit('-',1)[-1]
   assert item['argv']==[op['tools']['taskset'],'-c','5',op['tools']['ldd'],op['tools']['tools'][tool]] and item['seconds']==5 and item['exit']==0 and item['failure'] is None and item.get('exception') is None and item['runnerSHA256']==op['pins'][str(R/'scripts/task_runner.py')]
 for row in op['stageImportJoins']:assert sha(row['source'])==sha(row['copy']) and sha(row['originalTarget'])==sha(row['actualTarget'])==row['SHA256']
 facts=json.loads((H/'source-proposal.json').read_text())
 for name,digest in facts['compilerSourcePins'].items():assert sha(name)==digest;files.add(Path(name))
 files.update((H/'representation-joins.json',H/'SOURCE-PROPOSAL.md'))
 membership=installed_membership();files.update(INSTALLED/name for name in membership)
 for tool in ('bend','node','taskset','ldd'):files.add(Path(shutil.which(tool)).resolve())
 files.add(Path(sys.executable).resolve())
 out=R/'.artifacts'/('check-relation55-chunk-standalone-js-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir();importJoins=[]
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
 artifact=out/'check.js';entry=stage/(H/'complete-io.bend').relative_to(R)
 commands=[{'label':'emit-check','argv':['taskset','-c','5','bend',str(entry),'-o',str(artifact)],'seconds':30,'artifact':str(artifact)},{'label':'js-check','argv':['taskset','-c','5','node',str(artifact)],'seconds':5,'oracle':str(H/'expected-complete.json')}]
 plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'privateEnvironment':str(private),'environmentSHA256':sha(private),'stage':str(stage),'inventory':stageBefore,'stageImportJoins':importJoins,'configuration':states,'installedMembership':membership,'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-'+n for i in range(5) for n in ('bend','node','python','taskset')],'scope':'Actual320 K.run declared query evaluations plus192 separate diagnostics, truefalse128 included, complete owner/foreign oracle; no feature timing/wholeWorld/proof/full55/adoption credit','historicalTSPlanSHA256':sha(ts/'plan.json'),'historicalTSReceiptSHA256':sha(ts/'receipt.json'),'historicalIOIncompletePlanSHA256':sha(failed/'plan.json'),'historicalIOIncompleteReceiptSHA256':sha(failed/'receipt.json'),'historicalEmitIncompleteReceiptSHA256':sha(emissionHistory/'receipt.json'),'expectedRepresentation':'Exact bounded literal pieces concatenate complete independent Strings; no comparison/output cut'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();out=path.parent;planSHA=sha(path);p=None;stage=None;private=None;inputs=None;ledger=None;logs=None;runner=None;generated={};record={'status':'INCOMPLETE','planSHA256':planSHA,'commands':[]}
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
    assert result['stdout']==b'' and result['stderr'] in (b'',(H.parents[4]/'pinned-bend-notice.bytes').read_bytes());assert Path(command['artifact']).is_file() and generated[command['artifact']]==sha(command['artifact'])
   else:
    assert result['stderr']==b'';text=result['stdout'].decode();actual,end=json.JSONDecoder().raw_decode(text);assert text[end:].encode()==b'\n';assert strict(actual)==strict(json.loads(Path(command['oracle']).read_text()))
    assert sum(len(phase['queries']) for schema in actual['schemas'] for phase in schema['phases'])==192;assert all(s['gate']['bodyMarkers']==1 and s['gate']['allowed']==[{'ran':1}] and s['gate']['skipped']==[{'skipped':1}] for s in actual['schemas']);item['fullOracleMatched']=True;item['oracleSHA256']=sha(command['oracle'])
   item['status']='QUALIFIED'
  assert ledger.index==20;record['status']='DEVELOPMENT_STANDALONE_JS_CHECK320_PLUS192_DIAGNOSTICS_PASS_NOT_FULL55'
 print(out)
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
