"""One frozen complete interpreted consumer, no installed-library discovery."""
from pathlib import Path
import hashlib,json,os,re,runpy,shutil,sys,time
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'scripts'));import task_runner
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def closure(p,files):
 p=p.resolve()
 if p in files:return
 files.add(p)
 for n in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
  if n!='Base':closure(p.parent/n,files)
files=set();closure(HERE/'retention-fail-skip-main.bend',files);files.update([Path(__file__).resolve(),HERE/'retention-fail-skip-oracle.json',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',Path(shutil.which('bend')).resolve(),Path(shutil.which('taskset')).resolve()])
out=ROOT/'.artifacts'/('inspect54-retention-fail-skip-'+str(time.time_ns()));out.mkdir();env=dict(os.environ,BEND_NO_TELEMETRY='1');inputs=task_runner.Inputs(files=files,directories=[Path('/home/node/.bend/bend2')]);argv=['taskset','-c','5','bend',str(HERE/'retention-fail-skip-main.bend')]
p={'inputs':inputs.expected,'argv':argv,'capSeconds':5,'environmentSHA256':hashlib.sha256(json.dumps(env,sort_keys=True).encode()).hexdigest(),'scope':'Actual system successful advancement and disposal, both schemas; interpreted development only'};(out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](out,['retention-fail-skip']);runner=task_runner.Runner(logs,inputs=inputs,env=env,cwd=ROOT);r={'status':'INCOMPLETE','planSHA256':sha(out/'plan.json')}
try:
 x=runner.run('retention-fail-skip',argv,5);r['command']={'exit':x['exit'],'failure':x['failure']};assert x['exit']==0 and x['failure'] is None;actual=json.loads(x['stdout']);expected=json.loads((HERE/'retention-fail-skip-oracle.json').read_text());assert actual==expected,(actual,expected);inputs.guard();logs.guard();r['status']='ACTUAL_SYSTEM_RETENTION_ADVANCEMENT_DISPOSAL_FULL_ORACLE_PASS'
finally:
 r['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
