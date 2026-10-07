"""Cheap extended-capability negative diagnostic discovery, not acceptance."""
from pathlib import Path
import hashlib,importlib.util,json,os,sys,time
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'scripts'));import task_runner
s=importlib.util.spec_from_file_location('receipt_logs',ROOT/'scripts/receipt-logs.py');L=importlib.util.module_from_spec(s);s.loader.exec_module(L)
names=['write-read','cross-schema','duplicate-owner','undeclared-read'];out=ROOT/'.artifacts'/('inspect54-full-negative-dev-'+str(time.time_ns()));out.mkdir();inputs=task_runner.Inputs(files=[HERE/'negative-development.py',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py'],directories=[HERE,ROOT/'experiments/public-inspect/bend-candidate',ROOT/'src/ecs',Path('/home/node/.bend/bend2')]);logs=L.CommandLogs(out,names);runner=task_runner.Runner(logs,inputs=inputs,env=dict(os.environ,BEND_NO_TELEMETRY='1'),cwd=ROOT);r={'status':'INCOMPLETE','inputs':inputs.expected,'commands':[],'scope':'Extended API diagnostic discovery; exact negative admission remains separate'}
try:
 for n in names:
  x=runner.run(n,['taskset','-c','5','bend',HERE/'negatives'/(n+'.bend'),'--check-only'],5,expected=1);r['commands'].append({'label':n,'exit':x['exit'],'failure':x['failure']});assert x['stderr'];inputs.guard();logs.guard()
 r['status']='EXTENDED_INSPECTOR_NEGATIVE_DIAGNOSTICS_DISCOVERED'
finally:r['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
