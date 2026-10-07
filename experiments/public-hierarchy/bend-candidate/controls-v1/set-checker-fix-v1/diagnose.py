from pathlib import Path
import json,hashlib,os,runpy,time,sys
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4];OLD=HERE.parent/'development/refusal-controls-1791393605594137174'
sys.path.insert(0,str(ROOT/'scripts'));import task_runner
out=HERE/('diagnostic-'+str(time.time_ns()));out.mkdir();plan=json.loads((OLD/'plan.json').read_text());c=next(x for x in plan['commands'] if x['label']=='omit-set-refusal-baseline-check');stage=Path(plan['stages'][c['subject']]['path']);inputs=task_runner.Inputs(files=[Path(__file__),OLD/'plan.json',OLD/'receipt.json',Path(c['argv'][3]).resolve()],directories=[stage,Path('/home/node/.bend/bend2')]);logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](out,['archived-set-check']);runner=task_runner.Runner(logs,inputs=inputs,env=dict(os.environ,BEND_NO_TELEMETRY='1'),cwd=ROOT);p={'command':c,'inputs':inputs.expected,'originalPlanSHA256':hashlib.sha256((OLD/'plan.json').read_bytes()).hexdigest(),'capSeconds':5};(out/'plan.json').write_text(json.dumps(p,indent=2));r={'status':'INCOMPLETE'}
try:
 x=runner.run('archived-set-check',c['argv'],5);r={'status':'PASS' if x['exit']==0 else 'FAIL','exit':x['exit'],'failure':x['failure']}
except BaseException as e:r['error']=str(e)
finally:r['logs']=logs.hashes;(out/'receipt.json').write_text(json.dumps(r,indent=2));print(out);print(r)
