"""Whole component fixture JS preparation/execution; each stage separately admitted.
No CLI success transfer, partition, cap increase, Native/proof/adoption credit.
"""
import hashlib,importlib.util,json,os,pathlib,re,shutil,sys,time
sys.dont_write_bytecode=True
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[3]
ACTUAL_ROOT=pathlib.Path('/workspace/formal-proofs/bendvy')
CONFIG_TOOL=ROOT/'experiments/public-relations/promotion-stage/application/next-version/v1/tool-pins.py'
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
T=load('task_runner',ROOT/'scripts/task_runner.py');E=load('boundary',HERE/'evidence-boundary.py');C=load('cli_helpers',HERE/'cli-runner.py');TOOLS=load('approved_tools',CONFIG_TOOL)
NAMES=['bend','node','python','taskset','clang']
def sha(p):return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def encode(v):
 if isinstance(v,bytes):return {'rawBase64':__import__('base64').b64encode(v).decode()}
 raise TypeError(type(v))
def decode(v):
 if isinstance(v,dict):
  if set(v)=={'rawBase64'}:return __import__('base64').b64decode(v['rawBase64'])
  return {k:decode(x) for k,x in v.items()}
 if isinstance(v,list):return [decode(x) for x in v]
 return v
def dump(p,value):p.write_text(json.dumps(value,indent=2,default=encode)+'\n')
def inputs_guard(expected):
 observed={}
 for name,value in expected.items():
  p=pathlib.Path(name);observed[name]=T.Inputs(directories=[p]).expected[name] if isinstance(value,dict) else sha(p)
 assert observed==expected,'frozen input membership/hash drift'
def closure(path,seen):
 path=path.resolve();assert path.is_file() and not path.is_symlink()
 if path in seen:return
 seen.add(path)
 for name in re.findall(r'^import\s+(\S+)',path.read_text(),re.M):
  closure(pathlib.Path('/home/node/.bend/bend2/base.bend') if name=='Base' else path.parent/name,seen)
def roots_for(out,sources,tool_config):
 return sorted({HERE,ROOT,ACTUAL_ROOT,out,out/'stage',pathlib.Path('/home/node/.bend/bend2'),*[p.parent for p in sources],*[pathlib.Path(p).parent for p in tool_config['tools'].values()],*[pathlib.Path(p) for p in tool_config['resource_roots']]})
def tool_configuration(env,execute):
 value=TOOLS.configuration();value['cpu']=5;value['env']=dict(env);value['execute']=execute
 return value
def freeze_preparation():
 old=ROOT/'.artifacts/inspect54-component-cli-1791439276598458975';op=old/'plan.json';orr=old/'receipt.json';p=json.loads(op.read_text());r=json.loads(orr.read_text())
 assert sha(op)=='a61fcd5dbd95bb750505eaed32d2ba6581be59e1887a5a165eca2607ce0163f4' and r['planSHA256']==sha(op)
 assert r['status']=='INCOMPLETE' and r['failure']=='child deadline' and r['guardFailures']==[]
 assert r['logs']=={n:sha(old/n) for n in ['stdout.raw','stderr.raw']}
 inputs_guard(p['inputs']);assert C.configurations(list(map(pathlib.Path,p['configurationRoots'])))==p['configurationStates']
 original=pathlib.Path(p['privateEnvironment']);assert sha(original)==p['environmentSHA256'];base_env=json.loads(original.read_text())
 assert set(base_env)<=set(['PATH','HOME','TMPDIR','LANG','LC_ALL','TZ'])
 out=ROOT/'.artifacts'/('inspect54-component-js-'+str(time.time_ns()));out.mkdir();sources=set();closure(HERE/'output-io-main.bend',sources)
 current={};rootdeps=[]
 for staged in sorted(sources):
  if staged.is_relative_to(HERE/'core-v1/src/ecs'):
   root=ACTUAL_ROOT/'src/ecs'/staged.name;assert sha(root)==sha(staged);current[str(staged)]={'root':str(root),'sha256':sha(root)};rootdeps.append(root)
  else:assert staged.is_relative_to(HERE) or staged==pathlib.Path('/home/node/.bend/bend2/base.bend')
 # Pure and IO wrapper successful historical source qualification covers all consumed bytes.
 wp=ROOT/'.artifacts/inspect54-io-wrapper-dev01/plan.json';wr=wp.parent/'receipt.json';w=json.loads(wp.read_text());wrr=json.loads(wr.read_text())
 assert sha(wp)==p['wrapperSourceJoin']['planSHA256'] and sha(wr)==p['wrapperSourceJoin']['receiptSHA256'] and wrr['exit']==0 and wrr['status']=='SOURCE_FEASIBILITY_PASS'
 for n,d in wrr['logs'].items():assert sha(wp.parent/n)==d
 for source in sources:
  if source.is_relative_to(HERE):assert sha(source)==w['sourceArchive'][str(source.relative_to(HERE))]==sha(wp.parent/'source'/source.relative_to(HERE))
 stage=out/'stage';stage.mkdir();inventory={}
 for source in sorted(sources):
  if source.is_relative_to(HERE):
   relative=source.relative_to(HERE);dest=stage/relative;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,dest);inventory[str(relative)]=sha(dest)
 tc=TOOLS.configuration();env=dict(base_env)
 for name in ['BEND_NO_TELEMETRY','BENDVY_CLANG19_ROOT','LD_LIBRARY_PATH']:env[name]=tc['env'][name]
 assert not any(name in env for name in ['NODE_OPTIONS','NODE_PATH','LD_PRELOAD','LD_AUDIT','DYLD_INSERT_LIBRARIES','DYLD_LIBRARY_PATH'])
 private=out/'environment.private.json';dump(private,env);private.chmod(0o600)
 git_env=out/'git-environment.private.json';dump(git_env,dict(os.environ));git_env.chmod(0o600)
 source_roots=roots_for(out,sources,tc);source_roots+=sorted({p.parent for p in stage.rglob('*.bend')})
 files=[*sources,*rootdeps,pathlib.Path(__file__).resolve(),HERE/'cli-runner.py',HERE/'evidence-boundary.py',HERE/'JS-PROPOSAL.json',HERE/'physical-oracle.py',HERE/'BEND-PHYSICAL-EXPECTED-v1.txt',HERE/'COMPONENT-ORACLE-v2.json',CONFIG_TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',op,orr,*[old/n for n in r['logs']],wp,wr,*[wp.parent/n for n in wrr['logs']],*[wp.parent/'source'/source.relative_to(HERE) for source in sources if source.is_relative_to(HERE)],private,git_env]
 for name in ['plan.json','receipt.json','stdout.raw','stderr.raw']:files.append(ROOT/'.artifacts/inspect54-output-dev03'/name)
 files+=list(map(pathlib.Path,tc['tools'].values()))+[pathlib.Path(tc['ldd']),pathlib.Path(tc['taskset']),pathlib.Path(shutil.which('git')).resolve()]
 directories=[stage,*map(pathlib.Path,tc['resource_roots'])]
 prepared={'status':'PREPARED_UNADMITTED_ORDINARY_PREPARATION_ONLY','inputs':T.Inputs(files=files,directories=directories).expected,'configurationRoots':list(map(str,source_roots)),'configurationStates':C.configurations(source_roots),'privateEnvironment':str(private),'environmentSHA256':sha(private),'gitEnvironment':str(git_env),'gitEnvironmentSHA256':sha(git_env),'stage':str(stage),'stageInventory':inventory,'rootDependencies':current,'historicalCLI':{'path':str(op),'sha256':sha(op),'receiptSHA256':sha(orr),'qualification':'INCOMPLETE deadline; source/env/library bindings only, no runtime transfer'},'frozenToolConfiguration':{k:v for k,v in tc.items() if k not in ['env','execute','cpu']},'ordinaryProbeLabels':['prepare-ldd-'+n for n in NAMES],'gitOriginCommand':['/usr/bin/taskset','-c','5',str(pathlib.Path(shutil.which('git')).resolve()),'ls-files'],'gitOriginSeconds':5,'oracle':str(HERE/'BEND-PHYSICAL-EXPECTED-v1.txt'),'oracleSHA256':sha(HERE/'BEND-PHYSICAL-EXPECTED-v1.txt'),'commandsAfterSeparateReview':[{'label':'complete-emit-js','argv':[tc['taskset'],'-c','5',tc['tools']['bend'],str(stage/'output-io-main.bend'),'-o',str(out/'component-complete.js')],'seconds':30,'generated':str(out/'component-complete.js')},{'label':'complete-run-js','argv':[tc['taskset'],'-c','5',tc['tools']['node'],str(out/'component-complete.js')],'seconds':5,'oracle':str(HERE/'BEND-PHYSICAL-EXPECTED-v1.txt')}],'scope':'Preparation only: five ordinary approved owned ldd probes and separate bounded normal-environment Git source-origin read. Pre/post configuration equality, current actual transitive source closure. Same complete unpartitioned5MB independent oracle, no emission/run/adoption/proof/CLI acceptance.'}
 path=out/'preparation-plan.json';dump(path,prepared);print(path);print(sha(path))
class Ledger:
 def __init__(self,path,labels,env,checks):
  self.path=path;self.path.mkdir();self.labels=labels;self.env=env;self.index=0;self.pins={};self.checks=checks
 def guard(self):
  assert {str(p) for p in self.path.iterdir()}==set(self.pins),'ledger membership drift'
  assert {n:sha(n) for n in self.pins}==self.pins,'ledger byte drift'
 def write(self,path,data):
  self.pins[str(path)]=hashlib.sha256(data).hexdigest();path.write_bytes(data)
 def execute(self,argv,seconds,env):
  assert env==self.env and seconds==5 and self.index<len(self.labels)
  label=self.labels[self.index];self.index+=1
  with E.GuardBoundary([*self.checks,('complete owned probe raw/metadata ledger',self.guard)]):
   for _,check in self.checks:check()
   self.guard()
   result=T.execute_result(argv,seconds,env,str(ROOT),'merged-stdout')
   for key in ['stdout','stderr']:self.write(self.path/(label+'.'+key+'.raw'),result[key])
   raw=(json.dumps({'argv':list(map(str,argv)),'seconds':seconds,'exit':result['exit'],'failure':result['failure'],'runnerSHA256':result['runnerSHA256']},indent=2)+'\n').encode();self.write(self.path/(label+'.json'),raw)
   assert result['failure'] is None and result['exit']==0,'owned probe failed/deadline'
   return result
def stage_guard(p):
 inputs_guard(p['inputs'])
 assert C.configurations(list(map(pathlib.Path,p['configurationRoots'])))==p['configurationStates'],'configuration drift'
 assert sha(p['privateEnvironment'])==p['environmentSHA256']
 if 'gitEnvironment' in p:assert sha(p['gitEnvironment'])==p['gitEnvironmentSHA256']
 assert {str(q.relative_to(p['stage'])):sha(q) for q in pathlib.Path(p['stage']).rglob('*') if q.is_file()}==p['stageInventory'],'stage membership drift'
def prepare_tools(path):
 p=json.loads(path.read_text());out=path.parent;env=json.loads(pathlib.Path(p['privateEnvironment']).read_text());receipt={'status':'INCOMPLETE','preparationPlanSHA256':sha(path),'scope':p['scope']};raw={};artifacts={}
 def guard():stage_guard(p)
 def raw_guard():
  assert {q.name for q in out.glob('*.raw')}==set(raw)
  assert {n:sha(out/n) for n in raw}==raw and receipt.get('logs',{})==raw
 def artifact_guard():assert {n:sha(n) for n in artifacts}==artifacts
 checks=[('complete frozen sources/tools/config/environment/stage',guard),('source-origin raw membership/hash',raw_guard),('created metadata hashes',artifact_guard)]
 ledger=Ledger(out/'prepare-probes',p['ordinaryProbeLabels'],env,[('complete frozen sources/tools/config/environment/stage',guard)])
 checks.append(('complete preparation probe ledger',ledger.guard))
 with E.ReceiptBoundary(receipt,out/'prepare-receipt.json',checks):
  guard();raw_guard();ledger.guard()
  receipt['configurationBefore']=C.configurations(list(map(pathlib.Path,p['configurationRoots'])))
  with E.GuardBoundary(checks):
   result=T.execute_result(p['gitOriginCommand'],5,json.loads(pathlib.Path(p['gitEnvironment']).read_text()),str(ACTUAL_ROOT),'split')
   raw.update({n+'.raw':hashlib.sha256(result[k]).hexdigest() for n,k in [('source-origin.stdout','stdout'),('source-origin.stderr','stderr')]});receipt['logs']=dict(raw)
   (out/'source-origin.stdout.raw').write_bytes(result['stdout']);(out/'source-origin.stderr.raw').write_bytes(result['stderr'])
   receipt['gitOrigin']={'exit':result['exit'],'failure':result['failure'],'seconds':5,'scope':'separate bounded Git read in ordinary environment, not resolver probe'}
   assert result['failure'] is None and result['exit']==0 and result['stderr']==b''
   tracked=set(result['stdout'].decode().splitlines())
   for v in p['rootDependencies'].values():assert str(pathlib.Path(v['root']).relative_to(ACTUAL_ROOT)) in tracked
   cfg={**p['frozenToolConfiguration'],'env':env,'execute':ledger.execute,'cpu':5}
   snapshot=TOOLS.shared.snapshot(**cfg);assert ledger.index==5
   receipt['configurationAfter']=C.configurations(list(map(pathlib.Path,p['configurationRoots'])))
   assert receipt['configurationBefore']==receipt['configurationAfter']==p['configurationStates']
   receipt.update(probeCount=5,probePins=dict(ledger.pins),toolsSnapshotPins=snapshot['pins'])
   toolpath=out/'tool-snapshot.json';dump(toolpath,snapshot);artifacts[str(toolpath)]=sha(toolpath)
  receipt['status']='COMPLETE_ORDINARY_OWNED_JS_PREPARATION'
 # Snapshot/ledger/receipt are now immutable input evidence for the separately reviewed execution plan.
 files=[path,*map(pathlib.Path,[n for n,v in p['inputs'].items() if not isinstance(v,dict)]),toolpath,out/'prepare-receipt.json',*[out/n for n in raw],*map(pathlib.Path,ledger.pins),*map(pathlib.Path,snapshot['pins'])]
 directories=[pathlib.Path(n) for n,v in p['inputs'].items() if isinstance(v,dict)]
 plan={**p,'status':'PREPARED_UNADMITTED_JS_EXECUTION','scope':'Exact whole two-schema complete emittedJS fixture/full original5MB oracle; emit30/run5 CPU5. No CLI acceptance/partition/caprise/Native/proof/adoption/general constructor truth. Trusted closed setup and diagnostic writes outside readonly Check boundary remain explicit.','inputs':T.Inputs(files=files,directories=directories).expected,'preparationPlan':str(path),'preparationPlanSHA256':sha(path),'preparationReceiptSHA256':sha(out/'prepare-receipt.json'),'toolSnapshot':str(toolpath),'toolSnapshotSHA256':sha(toolpath),'commands':p['commandsAfterSeparateReview'],'prepareProbeCount':5,'executionProbeLabels':['verify-'+str(i)+'-ldd-'+name for i in range(5) for name in NAMES]}
 actual=out/'plan.json';dump(actual,plan);print(actual);print(sha(actual))
def run(path):
 p=json.loads(path.read_text());out=path.parent;env=json.loads(pathlib.Path(p['privateEnvironment']).read_text());receipt={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]};raw={};generated={}
 def guard():
  stage_guard(p)
  assert sha(p['toolSnapshot'])==p['toolSnapshotSHA256'] and sha(p['preparationPlan'])==p['preparationPlanSHA256'] and sha(out/'prepare-receipt.json')==p['preparationReceiptSHA256']
 def raw_guard():
  expected={n:sha(out/n) for n in json.loads((out/'prepare-receipt.json').read_text())['logs']}
  assert {q.name for q in out.glob('*.raw')}==set(raw)|set(expected)
  assert {n:sha(out/n) for n in raw}==raw and receipt.get('logs',{})==raw
 def generated_guard():
  assert {str(q) for q in out.glob('*.js')}==set(generated),'generated JS membership drift'
  assert {n:sha(n) for n in generated}==generated and receipt.get('generated',{})==generated,'generated JS hash/receipt drift'
 ledger=Ledger(out/'execution-probes',p['executionProbeLabels'],env,[('complete frozen sources/tools/config/environment/stage',guard)])
 checks=[('complete frozen source/tool/environment/config/stage',guard),('captured full raw membership/hash',raw_guard),('generated object membership/hash',generated_guard),('complete execution probe ledger',ledger.guard)]
 snapshot=decode(json.loads(pathlib.Path(p['toolSnapshot']).read_text()))
 def verify():
  with E.GuardBoundary(checks):
   guard();raw_guard();generated_guard();ledger.guard()
   TOOLS.shared.verify(snapshot,**{**p['frozenToolConfiguration'],'env':env,'execute':ledger.execute,'cpu':5})
 with E.ReceiptBoundary(receipt,out/'receipt.json',checks):
  guard();raw_guard();generated_guard();ledger.guard();verify()
  for command in p['commands']:
   verify()
   with E.GuardBoundary(checks):
    result=T.execute_result(command['argv'],command['seconds'],env,str(ROOT),'split')
    label=command['label'];raw.update({label+'.'+k+'.raw':hashlib.sha256(result[k]).hexdigest() for k in ['stdout','stderr']});receipt['logs']=dict(raw)
    for k in ['stdout','stderr']:(out/(label+'.'+k+'.raw')).write_bytes(result[k])
    receipt['commands'].append({'label':label,'exit':result['exit'],'failure':result['failure'],'seconds':command['seconds']})
    # Register even a failed emitter's partial output before unconditional postguards.
    if 'generated' in command and pathlib.Path(command['generated']).exists():generated[command['generated']]=sha(command['generated']);receipt['generated']=dict(generated)
    if result['failure'] is None and result['exit']==0 and 'generated' in command:assert command['generated'] in generated,'successful emission missing output'
    verify()
    assert result['failure'] is None and result['exit']==0,'backend failed/deadline'
    if 'oracle' in command:
     assert result['stderr']==b'','Node emitted unexpected stderr'
     expected=pathlib.Path(command['oracle']).read_bytes();assert result['stdout']==expected,'complete independent public/physical oracle mismatch'
     receipt['oracle']={'actualSHA256':hashlib.sha256(result['stdout']).hexdigest(),'expectedSHA256':p['oracleSHA256'],'bytes':len(expected),'exactIOPrintLF':True}
    else:assert result['stdout']==b'' and result['stderr'] in [b'',b'bend 2.0.36 is available: run bend update\n'],'unexpected emitter framing'
  assert ledger.index==25
  receipt.update(status='COMPLETE_WHOLE_COMPONENT_STANDALONE_JS_PASS',probeCount=25,probePins=dict(ledger.pins))
 print(json.dumps(receipt))
if __name__=='__main__':
 if sys.argv[1]=='freeze-preparation':freeze_preparation()
 elif sys.argv[1]=='prepare-tools':prepare_tools(pathlib.Path(sys.argv[2]).resolve())
 else:run(pathlib.Path(sys.argv[2]).resolve())
