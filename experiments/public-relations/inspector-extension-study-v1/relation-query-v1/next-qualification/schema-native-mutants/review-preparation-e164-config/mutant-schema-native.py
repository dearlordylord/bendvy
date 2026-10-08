"""One complete relation mutant, two nominal Native roots, source preparation only."""
import argparse,base64,hashlib,importlib.util,json,os,re,shutil,sys,time,tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
CASE=None
CASES=("outgoing-filter-negated","incoming-order-reversed","world-valid-omitted")
COORDINATOR=Path("/workspace/formal-proofs/bendvy")
TOOL=ROOT/'experiments/public-relations/promotion-stage/application/next-version/v1/tool-pins.py'
sys.dont_write_bytecode=True

def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
T=load(ROOT/'scripts/task_runner.py','task_runner');L=load(ROOT/'scripts/receipt-logs.py','logs');P=load(TOOL,'tools');B=load(COORDINATOR/'scripts/evidence_boundary.py','boundary')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def encode(x):
 if isinstance(x,bytes):return {'rawBase64':base64.b64encode(x).decode()}
 raise TypeError(type(x))
def decode(x):
 if isinstance(x,dict):return base64.b64decode(x['rawBase64']) if set(x)=={'rawBase64'} else {k:decode(v) for k,v in x.items()}
 if isinstance(x,list):return [decode(v) for v in x]
 return x
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def closure():
 pending=[HERE/'next-qualification/schema-native-mutants'/CASE/'workshop-io.bend',HERE/'next-qualification/schema-native-mutants'/CASE/'garden-io.bend'];seen=set();installed=Path('/home/node/.bend/bend2')
 while pending:
  p=pending.pop().resolve()
  if p in seen:continue
  assert p.is_file();seen.add(p)
  for name in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):pending.append(installed/'base.bend' if name=='Base' else p.parent/name)
 return seen
def config_state(p):
 if p.is_symlink():
  resolved=p.resolve();actual={'kind':'file','SHA256':sha(resolved)} if resolved.is_file() else {'kind':'directory'} if resolved.is_dir() else {'kind':'absent'}
  return {'kind':'symlink','target':os.readlink(p),'resolved':str(resolved),'resolvedState':actual}
 return {'kind':'file','SHA256':sha(p)} if p.is_file() else {'kind':'directory'} if p.is_dir() else {'kind':'absent'}
def configs(out,stage):
 nativeConfig=P.configuration();nativePaths={Path(value).resolve().parent for value in nativeConfig['tools'].values()}|{Path(value) for value in nativeConfig['resource_roots']}
 paths=set();origins=nativePaths|{HERE,ROOT,COORDINATOR,out,stage,Path('/home/node/.bend/bend2'),*[p.parent for p in closure()],*[p.parent for p in stage.rglob('*.bend')],*[Path(shutil.which(n)).resolve().parent for n in ('bend','node','taskset')]}
 for origin in origins:
  for parent in (origin,*origin.parents):
   for name in ('bend.json','bend.jsonc','bend.toml','check.json','check.jsonc','bender.json','bender.jsonc','.bend','package.json','tsconfig.json','.node-version','.nvmrc','.npmrc','clang.cfg','.clang','.bend.json','bend.config.json'):
    paths.add(parent/name)
 return {str(p):config_state(p) for p in sorted(paths)}
def strict(x):
 if isinstance(x,dict):return ('dict',tuple((k,strict(v)) for k,v in sorted(x.items())))
 if isinstance(x,list):return ('list',tuple(map(strict,x)))
 return (type(x).__name__,x)
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
 configuration=P.configuration();configuration['execute']=ledger.execute;configuration['env']=ledger.env;configuration['cpu']=5;return configuration


def prepare():
 proposal=json.loads((HERE/'mutant-schema-native-proposal.json').read_text());assert sha(Path(__file__).resolve())==proposal['wrapperSHA256']
 historical=ROOT/'.artifacts/inspector-relation55-boundary-io-1791441401493444111';hp=historical/'plan.json';hr=historical/'receipt.json'
 assert sha(hp)=='be67bdcdc49377484a83d628f6a98222fe400a3719dbf24f48dfa306c038862c' and sha(hr)=='747c6c45d6a5be6bd1261e01e2efb791b86e5810321d41c2540831406b750d6c'
 old=json.loads(hp.read_text());receipt=json.loads(hr.read_text());assert receipt['status']=='INCOMPLETE' and receipt['guardFailures']==[]
 derived=HERE/'reconciliation-v2.json';assert sha(derived)=='592ab358877a90f2654ff2fa8ca220e65ef18c63150efe8be8d327ba07399704'
 d=json.loads(derived.read_text());assert d['status']=='DERIVED_MODEL_V2_FULL192_MATCH_NOT_FULL55'
 assert all(d[k]=={} for k in ('currentHistoricalPinDrift','currentHistoricalConfigurationDrift','currentHistoricalInstalledMembershipDrift'))
 files=set(map(Path,old['pins']))|closure()|{hp,hr,derived,HERE/'expected-relations-v2.json',HERE/'author-oracle-v2.py',HERE/'oracle-v2-source-delta.json',HERE/'reconcile-v2.py',HERE/'source-joins.json',HERE/'mutant-schema-native-proposal.json',Path(__file__).resolve(),TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',COORDINATOR/'scripts/evidence_boundary.py'}
 for name,digest in old['pins'].items():assert sha(name)==digest
 assert sha(old['privateEnvironment'])==old['environmentSHA256'];files.add(Path(old['privateEnvironment']))
 for name,digest in receipt['logs'].items():assert sha(historical/name)==digest;files.add(historical/name)
 for row in json.loads((HERE/'source-joins.json').read_text())['files']:assert sha(row['source'])==sha(HERE/row['copy'])==row['SHA256'];files.update((Path(row['source']),HERE/row['copy']))
 for name,digest in proposal['binding'].items():assert sha(HERE/name)==digest;files.add(HERE/name)
 # Original Native timeout is immutable history, not qualified compiled output.
 timeout=ROOT/'.artifacts/inspector-relation55-native-1791443157477056829'
 assert sha(timeout/'receipt.json')=='35c94404500c35d4a4587a9eeac18cf2b092abcdbb232da8c1266775c2ca299e'
 prior=json.loads((timeout/'plan.json').read_text());failed=json.loads((timeout/'receipt.json').read_text());assert failed['status']=='INCOMPLETE' and failed['generated']=={} and failed['guardFailures']==[]
 assert sha(timeout/'plan.json')=='c775239fd106f8d48e4e481e347c98a7ba2aed078d744c95e15b5705e0c7159c' and failed['planSHA256']==sha(timeout/'plan.json')
 assert len(failed['commands'])==1 and failed['commands'][0]['label']=='emit-c' and failed['commands'][0]['argv']==prior['commands'][0]['argv'] and failed['commands'][0]['seconds']==30 and failed['commands'][0]['failure']=='child deadline'
 assert failed['probeCommandsExecuted']==15 and set(failed['logs'])=={'emit-c.stdout','emit-c.stderr'}
 assert (timeout/'emit-c.stdout').read_bytes()==(timeout/'emit-c.stderr').read_bytes()==b''
 preparation=json.loads((timeout/'prepare-receipt.json').read_text());assert preparation['status']=='OWNED_NATIVE_PREPARATION_PASS' and preparation['probeCommandsExecuted']==5
 for record,folder,labels in ((failed,'execution-probes',prior['executionProbeLabels'][:15]),(preparation,'prepare-probes',['prepare-'+x for x in ('bend','node','python','taskset','clang')])):
  assert set(record['probePins'])=={str(timeout/folder/(label+suffix)) for label in labels for suffix in ('.json','.stdout','.stderr')}
  for label in labels:
   metadata=json.loads((timeout/folder/(label+'.json')).read_text());tool=label.rsplit('-',1)[-1]
   assert metadata['argv']==[prior['tools']['taskset'],'-c',str(prior['tools']['cpu']),prior['tools']['ldd'],prior['tools']['tools'][tool]] and metadata['seconds']==5 and metadata['exit']==0 and metadata['failure'] is None
   assert metadata['runnerSHA256']==prior['pins'][str(ROOT/'scripts/task_runner.py')]

 files.update((timeout/'plan.json',timeout/'receipt.json',timeout/'prepare-receipt.json',Path(prior['privateEnvironment'])))
 assert sha(prior['privateEnvironment'])==prior['environmentSHA256']
 for name,digest in prior['pins'].items():assert sha(name)==digest;files.add(Path(name))
 for record in (failed,json.loads((timeout/'prepare-receipt.json').read_text())):
  assert record.get('guardFailures',[])==[]
  for name,digest in record['probePins'].items():assert sha(name)==digest;files.add(Path(name))
 for name,digest in failed['logs'].items():assert sha(timeout/name)==digest;files.add(timeout/name)
 for family in ('workshop','garden'):
  development=HERE/'development/schema-source-1791443990922734448'/family
  record=json.loads((development/'receipt.json').read_text());assert record['exit']==0 and record['sourceGuardPass'] is True and record['sourcePins']==record['postSourcePins']
  for name,digest in record['sourcePins'].items():assert sha(name)==digest;files.add(Path(name))
  files.update(p for p in development.iterdir() if p.is_file())

 # Exact successful normal Native and reached IO histories are reused, never replayed.
 normal=ROOT/'.artifacts/inspector-relation55-schema-native-1791445269778574093'
 np=json.loads((normal/'plan.json').read_text());nr=json.loads((normal/'receipt.json').read_text());nq=json.loads((normal/'prepare-receipt.json').read_text())
 assert sha(normal/'plan.json')=='b75e52d39b78f6b2dd8699d7698027cc144f361687c125528dad1ff48c0afb9a'
 assert sha(normal/'receipt.json')=='3502aa3cc241c698b5908c76e6a3bbdf513158ee72fe31ddc8a88a72016eef4a'
 assert nr['status']=='DEVELOPMENT_TWO_SCHEMA_NATIVE_COMPLETE192_JOIN_PASS_NOT_FULL55' and nr['full192JoinMatched'] is True and nr['probeCommandsExecuted']==65 and nq['probeCommandsExecuted']==5
 assert len(np['commands'])==len(nr['commands'])==6 and set(nr['logs'])=={c['label']+suffix for c in np['commands'] for suffix in ('.stdout','.stderr')}
 for pc,rc in zip(np['commands'],nr['commands']):
  assert all(pc[k]==rc[k] for k in ('label','argv','seconds')) and rc['exit']==0 and rc['failure'] is None
  if rc['label'].startswith('run-'):assert rc['fullOracleMatched'] is True and sha(rc['oracle'])==rc['oracleSHA256'] and strict(json.loads((normal/(rc['label']+'.stdout')).read_bytes()))==strict(json.loads(Path(rc['oracle']).read_text()))
 files.update((normal/'plan.json',normal/'receipt.json',normal/'prepare-receipt.json'))
 for name,digest in np['pins'].items():assert sha(name)==digest;files.add(Path(name))
 assert sha(np['privateEnvironment'])==np['environmentSHA256'];files.add(Path(np['privateEnvironment']))
 for record,folder,labels in ((nr,'execution-probes',np['executionProbeLabels']),(nq,'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset','clang')])):
  assert set(record['probePins'])=={str(normal/folder/(label+suffix)) for label in labels for suffix in ('.json','.stdout','.stderr')}
  for name,digest in record['probePins'].items():assert sha(name)==digest;files.add(Path(name))
  for label in labels:
   item=json.loads((normal/folder/(label+'.json')).read_text());tool=label.rsplit('-',1)[-1]
   assert item['argv']==[np['tools']['taskset'],'-c','5',np['tools']['ldd'],np['tools']['tools'][tool]] and item['seconds']==5 and item['exit']==0 and item['failure'] is None and item.get('exception') is None
 for name,digest in nr['logs'].items():assert sha(normal/name)==digest;files.add(normal/name)
 for name,digest in nr['generated'].items():assert sha(name)==digest;files.add(Path(name))
 actualIO=ROOT/'.artifacts/inspector-relation55-mutant-io-1791443937298190588';mp=json.loads((actualIO/'plan.json').read_text());mr=json.loads((actualIO/'receipt.json').read_text())
 assert sha(actualIO/'plan.json')=='05c66f420ab881d236b8ac551587fc694da4d6367b026fa870743e185b9f3f45' and sha(actualIO/'receipt.json')=='269241250057cad11c2026e6bc4b542b9dd81ed53de1e4962ee4ef3b788d8fd5'
 assert mr['status']=='DEVELOPMENT_THREE_RELATION192_MUTANTS_REACHED_IO_NOT_FULL55' and mr.get('guardFailures',[])==[]
 assert len(mp['commands'])==len(mr['commands'])==3 and set(mr['logs'])=={case+suffix for case in CASES for suffix in ('.stdout','.stderr')}
 for pc,rc in zip(mp['commands'],mr['commands']):
  assert all(pc[k]==rc[k] for k in ('label','argv','seconds')) and rc['exit']==0 and rc['failure'] is None and rc['fullDefectOracleMatched'] is True and rc['reachedWitnessCount']==dict(zip(CASES,(322,360,576)))[rc['label']]
 files.update((actualIO/'plan.json',actualIO/'receipt.json'))
 for name,digest in mp['pins'].items():assert sha(name)==digest;files.add(Path(name))
 for name,digest in mr['logs'].items():assert sha(actualIO/name)==digest;files.add(actualIO/name)
 for name,digest in mr.get('probePins',{}).items():assert sha(name)==digest;files.add(Path(name))
 assert sha(mp['privateEnvironment'])==mp['environmentSHA256'];files.add(Path(mp['privateEnvironment']))
 assert strict(json.loads((actualIO/(CASE+'.stdout')).read_bytes()))==strict(json.loads((HERE/'next-qualification/mutants'/CASE/'expected-defect.json').read_text()))
 checks=HERE/'next-qualification/schema-native-mutants/source-checks.json';gate=json.loads(checks.read_text());assert gate['complete'] is True;files.add(checks)
 for family in ('workshop','garden'):
  row=gate['results'][CASE+'-'+family];folder=Path(row['directory']);assert sha(folder/'receipt.json')==row['receiptSHA256'];record=json.loads((folder/'receipt.json').read_text())
  assert record['status']=='DEVELOPMENT_SOURCE_TYPING_PASS_NOT_PROOF' and record['sourceGuardPass'] is True and record['exit']==0 and record['sourcePins']==record['postSourcePins'] and record['installedMembership']==record['postInstalledMembership']
  for name,digest in record['sourcePins'].items():assert sha(name)==digest;files.add(Path(name))
  for p in folder.rglob('*'):
   if p.is_file():files.add(p)
 for name in ('expected-defect.json','expected-witnesses.json'):files.add(HERE/'next-qualification/mutants'/CASE/name)
 files.add(HERE/'next-qualification/mutants/author-defects.py')
 out=ROOT/'.artifacts'/('inspector-relation55-native-mutant-'+CASE+'-'+str(time.time_ns()));out.mkdir();stage=out/'stage';stage.mkdir()
 for source in closure():
  if source.is_relative_to(ROOT):
   target=stage/source.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target);assert sha(target)==sha(source)
 # Every copied import resolves inside the same staged closure except explicit Base.
 importJoins=[]
 for source in closure():
  if not source.is_relative_to(ROOT):continue
  copy=stage/source.relative_to(ROOT)
  for name in re.findall(r'^import\s+(\S+)',source.read_text(),re.M):
   original=(Path('/home/node/.bend/bend2/base.bend') if name=='Base' else source.parent/name).resolve()
   target=(Path('/home/node/.bend/bend2/base.bend') if name=='Base' else copy.parent/name).resolve()
   assert original in closure()
   if original.is_relative_to(ROOT):assert target==stage/original.relative_to(ROOT)
   else:assert name=='Base' and target==original
   assert target.is_file() and sha(target)==sha(original)
   importJoins.append({'source':str(source),'copy':str(copy),'import':name,'originalTarget':str(original),'actualTarget':str(target),'SHA256':sha(original)})
 # Complete prior history, oracle and source bytes are frozen BEFORE preparation.
 env=P.configuration()['env'];approvedLD=env.get('LD_LIBRARY_PATH')
 for name in tuple(env):
  if name.startswith(('LD_','DYLD_')) or name in ('NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE'):env.pop(name,None)
 if approvedLD is not None:env['LD_LIBRARY_PATH']=approvedLD
 before={str(p):sha(p) for p in sorted(files)};configuration=configs(out,stage);stageBefore=inventory(stage);envBefore=json.dumps(env,sort_keys=True)
 inputs=T.Inputs(files=files,directories=[stage]);ledger=ProbeLedger(out/'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset','clang')],inputs,env)
 record={'status':'INCOMPLETE','probeCommandsExecuted':0}
 def prepguard():
  assert all(sha(n)==h for n,h in before.items());assert configs(out,stage)==configuration and inventory(stage)==stageBefore and json.dumps(env,sort_keys=True)==envBefore;inputs.guard()
 def probeguard():
  ledger.guard();record['probePins']=ledger.pins();record['probeCommandsExecuted']=ledger.index
 with B.ReceiptBoundary(record,out/'prepare-receipt.json',[('all preparation inputs/config',prepguard),('preparation raw',probeguard)]):
  prepguard();tools=P.shared.snapshot(**owned_configuration(ledger));assert ledger.index==5;record['status']='OWNED_NATIVE_PREPARATION_PASS'
 private=out/'private-environment.json';private.write_text(envBefore);private.chmod(0o600)
 files.update((out/'prepare-receipt.json',private));files.update(map(Path,ledger.pins()));files.update(map(Path,tools['pins']))
 commands=[]
 for family in ('workshop','garden'):
  c=out/(family+'.c');binary=out/(family+'-native');entry=stage/(HERE/'next-qualification/schema-native-mutants'/CASE/(family+'-io.bend')).relative_to(ROOT)
  commands.extend([{'label':'emit-'+family,'argv':['taskset','-c','5','bend',str(entry),'-o',str(c)],'seconds':30,'artifact':str(c)},{'label':'compile-'+family,'argv':['taskset','-c','5','/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(c),'-pthread','-lm','-o',str(binary)],'seconds':120,'artifact':str(binary)},{'label':'run-'+family,'argv':['taskset','-c','5',str(binary),'--threads','1','--gpu','off'],'seconds':5,'family':family,'oracle':str(HERE/'next-qualification/schema-native-mutants'/CASE/(family+'-expected.json'))}])
 plan={'case':CASE,'pins':{str(p):sha(p) for p in sorted(files)},'tools':tools,'privateEnvironment':str(private),'environmentSHA256':sha(private),'stage':str(stage),'inventory':stageBefore,'stageImportJoins':importJoins,'configuration':configuration,'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-'+n for i in range(13) for n in ('bend','node','python','taskset','clang')],'scope':'One reached mutant complete192/owners across two nominal Native roots; exact IO/raw/oracle/witness join; no proof/performance/full55'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();p=decode(json.loads(path.read_text()));assert p['case']==CASE;out=path.parent;stage=Path(p['stage']);private=Path(p['privateEnvironment']);env=json.loads(private.read_text());generated={}
 inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],inputs,env);logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=stage,capture='split')
 planSHA=sha(path)
 schemaRaw={}
 record={'status':'INCOMPLETE','planSHA256':planSHA,'commands':[],'scope':p['scope']}
 def metadata():
  assert sha(path)==planSHA
  assert all(sha(n)==h for n,h in p['pins'].items());assert sha(private)==p['environmentSHA256'] and inventory(stage)==p['inventory'] and configs(out,stage)==p['configuration'];assert all(sha(n)==h for n,h in generated.items());inputs.guard()
  for row in p['stageImportJoins']:
   assert sha(row['source'])==sha(row['copy']) and sha(row['originalTarget'])==sha(row['actualTarget'])==row['SHA256']
  present={c['artifact'] for c in p['commands'] if 'artifact' in c and Path(c['artifact']).exists()}
  assert present==set(generated),'unexpected/unregistered named generated artifact'
 def owned():metadata();P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 def rawguard():
  logs.guard();ledger.guard();record.update(logs=dict(logs.hashes),probePins=ledger.pins(),probeCommandsExecuted=ledger.index,generated=dict(generated))
 with B.ReceiptBoundary(record,out/'receipt.json',[('final inputs/config',metadata),('final raw',rawguard)]):
  owned()
  for command in p['commands']:
   owned()
   if 'artifact' in command:assert not Path(command['artifact']).exists()
   item={**command,'exit':None,'failure':None,'status':'NOT_COLLECTED'};record['commands'].append(item)
   def register_generated():
    nonlocal inputs
    if 'artifact' in command and Path(command['artifact']).exists():
     assert Path(command['artifact']).is_file();generated[command['artifact']]=sha(command['artifact'])
     inputs=T.Inputs(files=[path,*p['pins'],*generated],directories=[stage]);runner.inputs=inputs;ledger.runner.inputs=inputs
   with B.GuardBoundary([('register actual generated output',register_generated),('post-child owned source/tools',owned),('post-child complete raw',rawguard)]):
    try:
     result=runner.run(command['label'],command['argv'],command['seconds'],expected=None);item.update(exit=result['exit'],failure=result['failure'],status='COLLECTED')
    except BaseException as error:
     failed=getattr(error,'result',None)
     if failed is not None:item.update(exit=failed['exit'],failure=failed['failure'])
     item['collectionError']=str(error);raise
   assert result['exit']==0 and result['failure'] is None
   notice=(HERE.parent/'pinned-bend-notice.bytes').read_bytes();assert result['stderr'] in (b'',notice)
   if 'artifact' in command:
    assert result['stdout'] in (b'',notice);artifact=Path(command['artifact']);assert artifact.is_file();assert generated[str(artifact)]==sha(artifact)
   else:
    text=result['stdout'].decode();actual,end=json.JSONDecoder().raw_decode(text);assert text[end:].encode() in (b'\n',b'\n'+notice)
    assert strict(actual)==strict(json.loads(Path(command['oracle']).read_text()))
    assert sum(len(phase['queries']) for phase in actual['phases'])==96
    schemaRaw[command['family']]=text[:end].encode();assert text[end:].encode()==b'\n','schema branch requires exact single IO newline'
    item['fullOracleMatched']=True;item['oracleSHA256']=sha(command['oracle'])
   item['status']='QUALIFIED'
  assert ledger.index==65 and set(schemaRaw)=={'workshop','garden'}
  combined=b'{"schemas":['+schemaRaw['workshop']+b','+schemaRaw['garden']+b'],"scope":"finite relation Inspector development fixture; no full55 qualification"}\n'
  old=ROOT/'.artifacts/inspector-relation55-mutant-io-1791443937298190588'
  assert combined==(old/(CASE+'.stdout')).read_bytes(),'complete reached IO byte framing/body mismatch'
  actual=json.loads(combined);assert strict(actual)==strict(json.loads((HERE/'next-qualification/mutants'/CASE/'expected-defect.json').read_text()))
  author=load(HERE/'next-qualification/mutants/author-defects.py','independent_defect_model');witness=author.differences(author.normal,actual)
  assert strict(witness)==strict(json.loads((HERE/'next-qualification/mutants'/CASE/'expected-witnesses.json').read_text())) and len(witness)==dict(zip(CASES,(322,360,576)))[CASE]
  record['reachedWitnessCount']=len(witness)
  record['combinedFull192RawSHA256']=hashlib.sha256(combined).hexdigest();record['full192JoinMatched']=True
  record['status']='DEVELOPMENT_MUTANT_TWO_SCHEMA_NATIVE192_REACHED_NOT_FULL55'
 print(out)
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--case',choices=CASES,required=True);parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args();CASE=args.case;prepare() if args.prepare else run(args.run)
