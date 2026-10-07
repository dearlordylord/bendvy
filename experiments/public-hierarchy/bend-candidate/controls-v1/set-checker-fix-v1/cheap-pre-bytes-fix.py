from pathlib import Path
import hashlib,json,os,re,runpy,shutil,sys,time,importlib.util
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];OLD=HERE.parent/'development/refusal-controls-1791393605594137174'
sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'scripts'));import task_runner
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
O=load(HERE.parent/'refusal-oracle.py','set_oracle')
def prepare():
 old=json.loads((OLD/'plan.json').read_text());out=HERE/('cheap-'+str(time.time_ns()));out.mkdir();stages={};commands=[]
 for mode in ['baseline','mutant']:
  name='omit-set-refusal-'+mode;original=old['stages'][name];source=Path(original['path']);assert inventory(source)==original['inventory'];stage=out/mode/'stage';stage.parent.mkdir();shutil.copytree(source,stage);assert inventory(stage)==original['inventory'];
  for rel in original['inventory']:
   current=ROOT/rel
   if rel!='experiments/public-hierarchy/bend-candidate/full-v1/application.bend' and not (mode=='mutant' and rel=='src/ecs/relation-reorder-core.bend'):assert current.read_bytes()==(stage/rel).read_bytes(),rel
  stages[mode]={'path':str(stage),'inventory':original['inventory']};entry=stage/'experiments/public-hierarchy/bend-candidate/full-v1/application.bend';js=stage.parent/'application.js'
  oracle=out/(mode+'-oracle.txt');oracle.write_text(O.expected('omit-set-refusal',mode=='mutant'))
  for phase,argv,cap in [('check',['bend',str(entry),'--check-only'],5),('emit-js',['bend',str(entry),'-o',str(js)],30),('run-js',['node',str(js)],5)]:commands.append({'label':mode+'-'+phase,'mode':mode,'phase':phase,'argv':['taskset','-c','8',*argv],'seconds':cap})
 files=[Path(__file__),HERE.parent/'refusal-oracle.py',HERE.parents[1]/'full-v1/compare.py',HERE.parents[1]/'compare-v2.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',OLD/'plan.json',OLD/'receipt.json',out/'baseline-oracle.txt',out/'mutant-oracle.txt',*[Path(shutil.which(x)).resolve() for x in ['bend','node','taskset']]]
 files.extend(ROOT/rel for rel in old['stages']['omit-set-refusal-baseline']['inventory']);
 env=dict(os.environ,BEND_NO_TELEMETRY='1');ef=out/'private-environment.json';ef.write_text(json.dumps(env,sort_keys=True));ef.chmod(0o600);inputs=task_runner.Inputs(files=files,directories=[Path(x['path']) for x in stages.values()]+[Path('/home/node/.bend/bend2')]);p={'files':list(map(str,files)),'directories':[str(x['path']) for x in stages.values()]+['/home/node/.bend/bend2'],'inputs':inputs.expected,'stages':stages,'commands':commands,'privateEnvironment':str(ef),'environmentSHA256':sha(ef),'scope':'Source-current set baseline and exact child-set mismatch mutant; complete six records, two nominal schemas; cheapJS only.'};path=out/'plan.json';path.write_text(json.dumps(p,indent=2));print(path);print(sha(path))
def run(path):
 path=Path(path).resolve();out=path.parent;p=json.loads(path.read_text());inputs=task_runner.Inputs(files=p['files'],directories=list(map(Path,p['directories'])));assert inputs.expected==p['inputs'];ef=Path(p['privateEnvironment']);assert sha(ef)==p['environmentSHA256'];env=json.loads(ef.read_text());logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](out,[x['label'] for x in p['commands']]);runner=task_runner.Runner(logs,inputs=inputs,env=env,cwd=ROOT);r={'status':'INCOMPLETE','planSHA256':sha(path),'commands':[]};generated={}
 try:
  for c in p['commands']:
   if c['phase']=='emit-js':assert not Path(c['argv'][-1]).exists()
   x=runner.run(c['label'],c['argv'],c['seconds']);r['commands'].append({'label':c['label'],'exit':x['exit'],'failure':x['failure']});assert x['exit']==0 and x['failure'] is None
   if c['phase']=='emit-js':generated[c['argv'][-1]]=sha(c['argv'][-1]);runner.inputs=task_runner.Inputs(files=[*p['files'],*generated],directories=list(map(Path,p['directories'])))
   if c['phase']=='run-js':assert x['stdout']==(out/(c['mode']+'-oracle.txt')).read_text()
   runner.inputs.guard();logs.guard();assert sha(ef)==p['environmentSHA256'];assert all(sha(f)==h for f,h in generated.items())
  assert (out/'baseline-run-js.stdout').read_bytes()!=(out/'mutant-run-js.stdout').read_bytes();r['status']='COMPLETE_SIX_RECORD_SET_BASELINE_REACHED_MUTANT_JS_PASS'
 except BaseException as e:r['error']=str(e);raise
 finally:r['logs']=logs.hashes;r['generated']=generated;(out/'receipt.json').write_text(json.dumps(r,indent=2));print(out)
if len(sys.argv)==1:prepare()
else:run(sys.argv[1])
