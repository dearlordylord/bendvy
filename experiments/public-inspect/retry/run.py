"""Five-second Node-only source-pinned retry observations."""
from pathlib import Path
import hashlib,json,os,runpy,shutil,sys,time
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'scripts'));import task_runner
OUT=ROOT/'.artifacts'/('public-inspect-retry-'+str(time.time_ns()));OUT.mkdir()
labels=['node-version','reference-bevy-ts','reference-bevy','reference-bend2','inspect-retry-TS']
logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](OUT,labels)
inputs=task_runner.Inputs(files=[HERE/'run.py',HERE/'reference.mjs',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'.references/sources.json',ROOT/'.references/bevy-ts/package.json',ROOT/'.references/bevy-ts/packages/core/package.json',Path(shutil.which('node')).resolve(),Path(shutil.which('git')).resolve(),Path(shutil.which('taskset')).resolve()],directories=[ROOT/'.references/bevy-ts/packages/core/src'])
env=dict(os.environ);runner=task_runner.Runner(logs,inputs=inputs,env=env,cwd=ROOT)
receipt={'status':'INCOMPLETE','inputs':inputs.expected,'plannedLabels':labels,'commands':[],'cpu':5,'capSeconds':5,'runnerSHA256':task_runner.IMPLEMENTATION_SHA256,'environmentSHA256':hashlib.sha256(json.dumps(env,sort_keys=True).encode()).hexdigest(),'scope':'Node reference event-read exception/retry only; no Bend implementation/static access negatives, law/proof/policy/performance acceptance'}
def run(label,argv):
 try:result=runner.run(label,['taskset','-c','5',*map(str,argv)],5)
 except (RuntimeError,TimeoutError) as error:
  result=getattr(error,'result',{});receipt['commands'].append({'label':label,'error':str(error),'exit':result.get('exit'),'failure':result.get('failure')});raise
 receipt['commands'].append({'label':label,'exit':result['exit'],'failure':result['failure']});assert not result['stderr'];return result['stdout'].decode()
try:
 receipt['nodeVersion']=run('node-version',['node','--version']);manifest=json.loads((ROOT/'.references/sources.json').read_text());receipt['references']={}
 for name,entry in manifest['sources'].items():
  head=run('reference-'+name,['git','-C',ROOT/'.references'/name,'rev-parse','HEAD']).strip();assert head==entry['commit'];receipt['references'][name]=head
 data=json.loads(run('inspect-retry-TS',['node',HERE/'reference.mjs']));assert data['application']=='PublicInspectEventRetry';receipt['observations']=len(data['observations']);assert {x['schema'] for x in data['observations']}=={'Workshop','Garden'};inputs.guard();logs.guard();receipt['status']='TS_INSPECT_EVENT_RETRY_OBSERVED'
finally:
 receipt['immutableLogs']=dict(logs.hashes);(OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(OUT)
