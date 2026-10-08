"""Single matched depth16 CPU/allocation diagnostics; no timing acceptance."""
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
 return {'execute':ledger.execute,'tools':{'bend':shutil.which('bend'),'node':shutil.which('node'),'python':sys.executable,'taskset':shutil.which('taskset')},'resource_roots':['/home/node/.bend/bend2'],'ldd':shutil.which('ldd'),'taskset':shutil.which('taskset'),'cpu':5,'env':ledger.env,'skip_ldd':[],'capture_mode':'merged-stdout'}

F=load(HERE.parents[2]/'trace-cheap.py','summary')
def prepare():
 current=ROOT/'.artifacts/relations-chunk-extension-1791419118574552727';cp=current/'plan.json';cr=current/'receipt.json';p=decode(json.loads(cp.read_text()));r=json.loads(cr.read_text());assert r['status']=='CHUNK_BOUNDED_CONTROLS_JS_PASS_NO_TIMING' and r['planSHA256']==sha(cp);assert all(sha(n)==s for n,s in p['pins'].items());assert sha(p['privateEnvironment'])==p['environmentSHA256'];assert inventory(Path(p['stage']))==p['inventory'];assert all(sha(current/n)==s for n,s in r['logs'].items())
 history=ROOT/'.artifacts/relations-normal-first-1791415751785839164';hp=history/'plan.json';hr=history/'receipt.json';old=json.loads(hp.read_text());older=json.loads(hr.read_text());assert older['planSHA256']==sha(hp);assert any(c['label']=='1-js' and c['exit']==0 and c['failure'] is None for c in older['commands']);assert sha(old['privateEnvironment'])==old['environmentSHA256'];assert all(sha(n)==s for n,s in old['pins'].items());assert all(sha(history/n)==s for n,s in older['logs'].items())
 baseline=Path(old['commands'][4]['argv'][4]);candidate=Path(p['commands'][2]['argv'][4]);oracle=Path(p['commands'][2]['oracle']);assert old['commands'][4]['input']==['depth','256','16','0'];assert p['commands'][2]['argv'][-4:]==['depth','256','16','0'];assert sha(baseline)==old['pins'][str(baseline)];assert sha(candidate)==p['pins'][str(candidate)];assert json.loads((history/'1-js.stdout').read_bytes())==json.loads(oracle.read_bytes())==json.loads((current/'js-depth16.stdout').read_bytes())
 out=ROOT/'.artifacts'/('relations-chunk-profiles-'+str(time.time_ns()));out.mkdir();stage=out/'wrappers';stage.mkdir();files={cp,cr,hp,hr,baseline,candidate,oracle,Path(p['privateEnvironment']),Path(old['privateEnvironment']),HERE/'profile-proposal.json',Path(__file__).resolve(),*[Path(n) for n in p['pins']],*[Path(n) for n in old['pins']],*[current/n for n in r['logs']],*[history/n for n in older['logs']]};commands=[]
 for role,artifact in [('original',baseline),('candidate',candidate)]:
  source=artifact.read_text();trailer='cli(process.argv.slice(1));\nio_exit($main$, null);';assert source.endswith(trailer+'\n');body=source[:-len(trailer+'\n')]
  for mode in ['cpu','allocation']:
   label=role+'-'+mode;profile=out/(label+'.profile.json');wrapper=stage/(label+'.cjs')
   start="await profPost('Profiler.enable');await profPost('Profiler.setSamplingInterval',{interval:100});await profPost('Profiler.start');" if mode=='cpu' else "await profPost('HeapProfiler.enable');await profPost('HeapProfiler.startSampling',{samplingInterval:16384,includeObjectsCollectedByMajorGC:true,includeObjectsCollectedByMinorGC:true});"
   stop="const profResult=await profPost('Profiler.stop');" if mode=='cpu' else "const profResult=await profPost('HeapProfiler.stopSampling');"
   tail="\nconst profSession=new (require('node:inspector').Session)();profSession.connect();\nconst profPost=(method,params={})=>new Promise((resolve,reject)=>profSession.post(method,params,(error,result)=>error?reject(error):resolve(result)));\nconst profExit=process.exit;let profZero=0;process.exit=code=>{if(code!==0)throw Error('nonzero application exit:'+code);profZero++;};\n(async()=>{\n"+start+'\n'+trailer+'\n'+stop+"\nif(profZero!==1)throw Error('expected one completed invocation');require('node:fs').writeFileSync("+json.dumps(str(profile))+",JSON.stringify({profile:profResult.profile,zeroExits:profZero,invocations:1,mode:"+json.dumps(mode)+"}));profSession.disconnect();process.exit=profExit;})().catch(error=>{process.exit=profExit;console.error(error);process.exit(1);});\n"
   wrapper.write_text(body+tail);files.add(wrapper);commands.append({'label':label,'argv':['taskset','-c','5','node',str(wrapper),'depth','256','16','0'],'seconds':5,'profile':str(profile),'oracle':str(oracle),'artifact':str(artifact),'artifactSHA256':sha(artifact),'mode':mode})
 env=dict(os.environ,BEND_NO_TELEMETRY='1');pinsource=[TOOL,ROOT/'scripts/owned-tool-pins.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'];files.update(pinsource);preparationconfig=configs(out,stage);inputs=T.Inputs(files=files,directories=[stage]);inputs.guard();environment_before=json.dumps(env,sort_keys=True);ledger=ProbeLedger(out/'prepare-probes',['prepare-ldd-'+n for n in ['bend','node','python','taskset']],inputs,env)
 try:
  tools=P.shared.snapshot(**owned_configuration(ledger));assert ledger.index==4;inputs.guard();assert configs(out,stage)==preparationconfig and json.dumps(env,sort_keys=True)==environment_before
 except BaseException as e:
  (out/'prepare-receipt.json').write_text(json.dumps({'status':'PREPARE_FAILED','error':str(e),'probeCommandsExecuted':ledger.index,'probePins':ledger.pins()},indent=2)+'\n');raise
 (out/'prepare-receipt.json').write_text(json.dumps({'status':'OWNED_TOOL_PREPARATION_PASS','probeCommandsExecuted':4,'probePins':ledger.pins()},indent=2)+'\n');files.add(out/'prepare-receipt.json');files.update(map(Path,ledger.pins()));files.update(map(Path,tools['pins']));private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600);plan={'pins':{str(f):sha(f) for f in sorted(files)},'tools':tools,'privateEnvironment':str(private),'environmentSHA256':sha(private),'stage':str(stage),'inventory':inventory(stage),'configurationStates':configs(out,stage),'commands':commands,'executionProbeLabels':['guard-'+str(i)+'-ldd-'+n for i in range(9) for n in ['bend','node','python','taskset']],'scope':'Instrumented one matched complete30 depth16 fixture per original/candidate CPU/allocation role; no timing/RSS/totalallocation/cause/universal acceptance'};(out/'plan.json').write_text(json.dumps(plan,indent=2,default=encode)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();out=path.parent;p=decode(json.loads(path.read_text()));private=Path(p['privateEnvironment']);assert sha(private)==p['environmentSHA256'];env=json.loads(private.read_text());stage=Path(p['stage']);profiles={};ledger=ProbeLedger(out/'execution-probes',p['executionProbeLabels'],T.Inputs(files=[path,*p['pins']],directories=[stage]),env)
 def guard():
  assert all(sha(n)==s for n,s in p['pins'].items());assert inventory(stage)==p['inventory'];assert configs(out,stage)==p['configurationStates'];assert sha(private)==p['environmentSHA256'];assert {str(f) for f in out.glob('*.profile.json')}==set(profiles);assert all(sha(n)==s for n,s in profiles.items());P.shared.verify(p['tools'],**owned_configuration(ledger));ledger.guard()
 guard();logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);runner=T.Runner(logs,inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]),env=env,cwd=stage);receipt={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[],'scope':p['scope']}
 try:
  for c in p['commands']:
   guard();assert not Path(c['profile']).exists();attempt={'label':c['label'],'status':'INCOMPLETE'};receipt['commands'].append(attempt)
   result=runner.run(c['label'],c['argv'],5);assert result['exit']==0 and result['failure'] is None;expected=json.loads(Path(c['oracle']).read_text());assert json.loads(result['stdout'])==expected;assert [json.loads(x) for x in result['stderr'].splitlines()]==[{'boundary':'begin'},{'boundary':'complete-trace-forced',**F.force(expected)}];data=json.loads(Path(c['profile']).read_text());assert data['zeroExits']==1 and data['invocations']==1 and data['mode']==c['mode'];assert data['profile'].get('nodes') if c['mode']=='cpu' else data['profile'].get('head') and data['profile'].get('samples');profiles[c['profile']]=sha(c['profile']);attempt['status']='FULL30_PROFILE_OUTPUT_PASS';guard()
  assert ledger.index==36;receipt['status']='MATCHED_DEPTH16_CPU_ALLOCATION_DIAGNOSTICS_PASS_NO_VERDICT'
 except BaseException as e:receipt['error']=str(e);raise
 finally:receipt['profiles']=profiles;receipt['logs']=dict(logs.hashes);receipt['probePins']=ledger.pins();receipt['probeCommandsExecuted']=ledger.index;(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');args=parser.parse_args();prepare() if args.prepare else run(args.run)
