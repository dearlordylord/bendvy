"""Bounded source-pinned Node observations, not Bend or parity acceptance."""
from pathlib import Path
import hashlib,json,os,runpy,shutil,sys,time
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'scripts'))
import task_runner
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
OUT=ROOT/'.artifacts'/('public-inspect-reference-'+str(time.time_ns()));OUT.mkdir()
labels=['node-version','bend-version','bend-guide','reference-bevy-ts','reference-bevy','reference-bend2','public-inspect-TS']
logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](OUT,labels)
files=[HERE/'run.py',HERE/'reference.mjs',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'.references/sources.json',ROOT/'.references/bevy-ts/package.json',ROOT/'.references/bevy-ts/packages/core/package.json',Path(shutil.which('node')).resolve(),Path(shutil.which('bend')).resolve(),Path(shutil.which('git')).resolve(),Path(shutil.which('taskset')).resolve()]
inputs=task_runner.Inputs(files=files,directories=[ROOT/'.references/bevy-ts/packages/core/src',Path('/home/node/.bend/bend2')]);env=dict(os.environ,BEND_NO_TELEMETRY='1')
runner=task_runner.Runner(logs,inputs=inputs,env=env,cwd=ROOT)
receipt={'status':'INCOMPLETE','scope':'Actual TS reference discovery only; no static TypeScript/Bend negatives, runtime refinement, performance, laws or feature acceptance','inputSnapshot':inputs.expected,'plannedLabels':labels,'commands':[],'cpu':5,'caps':{'allCommands':5},'runnerSHA256':task_runner.IMPLEMENTATION_SHA256,'environmentSHA256':hashlib.sha256(json.dumps(env,sort_keys=True).encode()).hexdigest()}
def run(label,argv):
 try:result=runner.run(label,['taskset','-c','5',*map(str,argv)],5)
 except (RuntimeError,TimeoutError) as error:
  result=getattr(error,'result',{});receipt['commands'].append({'label':label,'error':str(error),'exit':result.get('exit'),'failure':result.get('failure')});raise
 receipt['commands'].append({'label':label,'exit':result['exit'],'failure':result['failure'],'runnerSHA256':result['runnerSHA256']});assert not result['stderr'];return result['stdout'].decode()
try:
 receipt['nodeVersion']=run('node-version',['node','--version']);receipt['bendVersion']=run('bend-version',['bend','version']);guide=run('bend-guide',['bend','guide']);assert '# Bend' in guide
 manifest=json.loads((ROOT/'.references/sources.json').read_text());receipt['references']={}
 for name,entry in manifest['sources'].items():
  head=run('reference-'+name,['git','-C',ROOT/'.references'/name,'rev-parse','HEAD']).strip();assert head==entry['commit'];receipt['references'][name]=head
 observed=json.loads(run('public-inspect-TS',['node',HERE/'reference.mjs']));assert observed['application']=='PublicInspect';receipt['schemas']=sorted({x['schema'] for x in observed['observations']});receipt['observations']=len(observed['observations']);assert len(receipt['schemas'])==2
 inputs.guard();logs.guard();receipt['status']='TS_PUBLIC_INSPECT_DISCOVERY_OBSERVED'
finally:
 receipt['immutableLogs']=dict(logs.hashes);receipt['terminalProcLoadavg']=Path('/proc/loadavg').read_text();(OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(OUT)
