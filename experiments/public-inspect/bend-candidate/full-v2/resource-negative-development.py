"""Focused optional-resource capability diagnostic discovery."""
from pathlib import Path
import json,os,runpy,sys,time
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'scripts'));import task_runner
names=['write-read-workshop','write-read-garden','cross-schema-workshop','cross-schema-garden','undeclared-workshop','undeclared-garden','duplicate-resource-owner'];out=ROOT/'.artifacts'/('inspect54-resource-negatives-'+str(time.time_ns()));out.mkdir();inputs=task_runner.Inputs(files=[HERE/'resource-negative-development.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'],directories=[HERE,ROOT/'experiments/public-inspect/bend-candidate',ROOT/'src/ecs',Path('/home/node/.bend/bend2')]);logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](out,names);runner=task_runner.Runner(logs,inputs=inputs,env=dict(os.environ,BEND_NO_TELEMETRY='1'),cwd=ROOT);r={'status':'INCOMPLETE','scope':'Seven optional-resource source-current API diagnostic controls only; no universal proof/confinement claim','inputs':inputs.expected,'commands':[]}
try:
 for n in names:
  x=runner.run(n,['taskset','-c','5','bend',HERE/'resource-negatives'/(n+'.bend'),'--check-only'],5,expected=1);r['commands'].append({'label':n,'exit':x['exit'],'failure':x['failure']});assert x['stderr'];inputs.guard();logs.guard()
 r['status']='OPTIONAL_RESOURCE_SEVEN_NEGATIVE_DIAGNOSTICS_DISCOVERED'
finally:r['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
