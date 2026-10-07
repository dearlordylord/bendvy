"""Source feasibility checker only; no emission/runtime/parity acceptance."""
import pathlib,sys,json,hashlib,os,time,importlib.util

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner

D=pathlib.Path(__file__).resolve().parent;R=D.parents[3];H=D.parent/'current-core-replay/guarded-v2'
sys.path.insert(0,str(R/'scripts'));import task_runner
sys.path.insert(0,str(H));import task_runner
spec=importlib.util.spec_from_file_location('tp',H/'tool-pins.py');tp=importlib.util.module_from_spec(spec);spec.loader.exec_module(tp)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
out=D/'development-checks'/str(time.time_ns());out.mkdir(parents=True);stage=out/'stage'
sources={str(p.relative_to(R)):p for p in list(D.glob('*.bend'))+list((R/'src/ecs').glob('*')) if p.is_file()}
for p in (D.parent/'modules').glob('*.bend'):key='src/ecs/'+p.name;assert key not in sources;sources[key]=p
contents={key:p.read_bytes() for key,p in sources.items()};plan={key:hashlib.sha256(value).hexdigest() for key,value in contents.items()}
tools=tp.snapshot();files=set(sources.values())|{pathlib.Path(__file__).resolve(),H/'tool-pins.py',ROOT/'scripts/task_runner.py',pathlib.Path(task_runner.__file__).resolve()}|{pathlib.Path(p) for p in tools['pins']};pins={str(p):sha(p) for p in files}
configs={}
for folder in [R,pathlib.Path.cwd(),stage]:
 for ancestor in [folder,*folder.parents]:
  for name in ['check.json','bend.json','bender.json']:
   p=ancestor/name;configs[str(p)]=sha(p) if p.is_file() else None
r={'status':'INCOMPLETE','scope':'source feasibility only','pins':pins,'tools':tools,'prospectiveStage':plan,'configurationStates':configs,'plannedLabels':['version','guide','check'],'commands':[],'capture':'raw merged stdout/stderr; explicitly empty stderr','CPU':8,'checkerSeconds':5}
def save():(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
save()
for key,value in contents.items():p=stage/key;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(value)
def guard():
 tp.verify(tools);assert all(sha(pathlib.Path(p))==h for p,h in pins.items());assert {str(p.relative_to(stage)):sha(p) for p in stage.rglob('*') if p.is_file()}==plan;assert {p:sha(pathlib.Path(p)) if pathlib.Path(p).is_file() else None for p in configs}==configs
 for c in r['commands']:
  for path,h in c['logs'].items():assert sha(pathlib.Path(path))==h
try:
 for label,args in [('version',['bend','version']),('guide',['bend','guide']),('check',['bend',str(stage/str(D.relative_to(R))/'application.bend'),'--check-only'])]:
  guard();argv=['taskset','-c','8',*args];res=task_runner.execute_result(argv,5,env={**os.environ,'BEND_NO_TELEMETRY':'1'});guard();logs={}
  for suffix in ['stdout','stderr']:
   p=out/(label+'.'+suffix);assert not p.exists();p.write_bytes(res[suffix]);logs[str(p)]=sha(p)
  r['commands'].append({'label':label,'argv':argv,'exit':res['exit'],'failure':res['failure'],'logs':logs});save();assert res['exit']==0 and res['failure'] is None
 r['status']='SOURCE_CHECK_PASS'
except Exception as e:r['status']='FAIL';r['error']=repr(e)
finally:save()
print(out,r['status'])
