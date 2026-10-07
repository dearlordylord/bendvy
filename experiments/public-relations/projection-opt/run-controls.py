from pathlib import Path
import sys,os,json,hashlib,importlib.util,time,base64
R=Path(__file__).resolve().parents[3];D=Path(__file__).resolve().parent
sys.path.insert(0,str(R/'scripts'));import task_runner
spec=importlib.util.spec_from_file_location('tools',R/'experiments/public-relations/promotion-stage/application/next-version/v1/tool-pins.py');tools=importlib.util.module_from_spec(spec);spec.loader.exec_module(tools)
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
E=D/'evidence'/str(time.time_ns());E.mkdir(parents=True)
freeze=json.loads((D/'freeze-v2.json').read_text());pins=dict(freeze['pins']);pins[str(Path(__file__).resolve())]=sha(Path(__file__))
pins.update({str(p):sha(p) for p in (R/'src/ecs').glob('*') if p.is_file()});ts=tools.snapshot();pins.update(ts['pins']);pins[str(R/'scripts/task_runner.py')]=sha(R/'scripts/task_runner.py')
receipt={'status':'INCOMPLETE','pins':pins,'tools':ts,'commands':[],'generated':{},'expectedSHA256':sha(D/'expected-v2.txt'),'limits':{'check':5,'emit':30,'clang':120,'run':5}}
def save():(E/'receipt.json').write_text(json.dumps(receipt,indent=2,default=lambda v:{"base64":base64.b64encode(v).decode()} if isinstance(v,bytes) else None)+'\n')
def guard():
 tools.verify(ts);assert all(Path(p).is_file() and sha(p)==h for p,h in pins.items());assert all(sha(p)==h for p,h in receipt['generated'].items())
def run(label,argv,cap,output=None):
 guard();assert output is None or not output.exists();res=task_runner.execute_result(['taskset','-c','8',*map(str,argv)],cap,env={**os.environ,'BEND_NO_TELEMETRY':'1','BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root'},capture='merged-stdout')
 log=E/(label+'.log');log.write_bytes(res['stdout']);receipt['generated'][str(log)]=sha(log)
 if output is not None and output.exists():receipt['generated'][str(output)]=sha(output)
 receipt['commands'].append({'label':label,'argv':list(map(str,argv)),'cap':cap,'exit':res['exit'],'failure':res['failure'],'runnerSHA256':res['runnerSHA256'] if 'runnerSHA256' in res else sha(R/'scripts/task_runner.py')});save();guard();assert res['exit']==0 and res['failure'] is None,(label,res);return res['stdout'].decode()
try:
 for variant in ['baseline','candidate']:
  entry=D/variant/'experiments/public-relations/promotion-stage/application/next-version/v1/projection-control.bend';run(variant+'-check',['bend',entry,'--check-only'],5)
  for backend in ['js','native']:
   code=E/(variant+('.js' if backend=='js' else '.c'));run(variant+'-'+backend+'-emit',['bend',entry,'-o',code],30,code)
   if backend=='native':
    binary=E/(variant+'-native');run(variant+'-clang',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',code,'-pthread','-lm','-o',binary],120,binary);argv=[binary,'--threads','1','--gpu','off']
   else:argv=['node',code]
   actual=run(variant+'-'+backend+'-run',argv,5);assert actual==(D/'expected-v2.txt').read_text(),(variant,backend,actual)
 guard();receipt['status']='ISOLATED_PROJECTION_JS_NATIVE_LITERAL_PASS'
except Exception as e:receipt['status']='FAIL';receipt['error']=repr(e)
finally:save()
print(E,receipt['status']);sys.exit(0 if receipt['status'].endswith('_PASS') else 1)
