"""Prospective actual public TS observation only; no backend acceptance."""
import pathlib,sys,hashlib,json,time,os,shutil,importlib.util,base64
D=pathlib.Path(__file__).resolve().parent;R=D.parents[5];H=R/'experiments/public-relations/promotion-stage/current-core-replay/guarded-v2'
sys.path.insert(0,str(H));import raw_supervisor
spec=importlib.util.spec_from_file_location('owned_tools',R/'scripts/owned-tool-pins.py');tools=importlib.util.module_from_spec(spec);spec.loader.exec_module(tools)
spec=importlib.util.spec_from_file_location('raw_logs',R/'scripts/receipt-logs.py');logs_module=importlib.util.module_from_spec(spec);spec.loader.exec_module(logs_module)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();env=os.environ.copy();out=D/'observations'/str(time.time_ns());out.mkdir(parents=True)
kwargs={'execute':raw_supervisor.execute,'tools':{'node':shutil.which('node'),'python':sys.executable,'taskset':shutil.which('taskset')},'resource_roots':[],'ldd':shutil.which('ldd'),'taskset':shutil.which('taskset'),'cpu':8,'env':env,'capture_mode':'merged-stdout'}
tool_snapshot=tools.snapshot(**kwargs)
files={pathlib.Path(__file__).resolve(),D/'reference.mjs',R/'scripts/owned-tool-pins.py',R/'scripts/receipt-logs.py',H/'raw_supervisor.py'}|set((R/'.references/bevy-ts/packages/core/src').rglob('*.ts'))|set((R/'.references/bevy-ts').glob('package.json'))|{R/'.references/bevy-ts/packages/core/package.json'}|{pathlib.Path(p) for p in tool_snapshot['pins']}
pins={str(p):sha(p) for p in sorted(files)};configPaths=set()
for folder in [D,R,pathlib.Path.cwd(),out]:
 for a in [folder,*folder.parents]:
  for name in ['check.json','bend.json','bender.json']:configPaths.add(a/name)
configs={str(p):sha(p) if p.is_file() else None for p in configPaths};logs=logs_module.CommandLogs(out,['actual-ts'])
serial=lambda v: {'base64':base64.b64encode(v).decode()} if isinstance(v,bytes) else (_ for _ in ()).throw(TypeError(type(v)))
r={'scope':'actual TS next application observation; no Bend/refinement/performance acceptance','status':'INCOMPLETE','pins':pins,'configurationStates':configs,'toolSnapshot':tool_snapshot,'limits':{'runtime':5},'plannedLabels':['actual-ts'],'commands':[],'capture':'raw merged stdout/stderr; explicitly empty stderr'}
def save():(out/'receipt.json').write_text(json.dumps(r,indent=2,default=serial)+'\n')
def guard():
 tools.verify(tool_snapshot,**kwargs);assert all(sha(pathlib.Path(p))==h for p,h in pins.items());assert {str(p):sha(p) if p.is_file() else None for p in configPaths}==configs;logs.guard()
try:
 save();guard();argv=['taskset','-c','8','node',str(D/'reference.mjs')];res=raw_supervisor.execute(argv,5,env=env);guard();r['commandLogPins']=logs.record('actual-ts',res['stdout'],res['stderr']);r['commands'].append({'argv':argv,'exit':res['exit'],'failure':res['failure'],'cap':5});save();assert res['exit']==0 and res['failure'] is None
 parsed=[json.loads(l) for l in res['stdout'].decode().splitlines()];assert [x['root'] for x in parsed]==['Workshop','Other'];assert [len(x['records']) for x in parsed]==[15,15];r['recordCount']=30;r['status']='ACTUAL_TS_APPLICATION_OBSERVED';guard()
except Exception as e:r['status']='FAIL';r['error']=repr(e)
finally:save()
print(out,r['status'])
