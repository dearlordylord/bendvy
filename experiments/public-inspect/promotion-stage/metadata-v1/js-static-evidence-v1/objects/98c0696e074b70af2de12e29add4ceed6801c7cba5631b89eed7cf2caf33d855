"""Execute only an explicitly admitted frozen metadata development plan."""
from pathlib import Path
import argparse,json,sys,types
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
B=types.ModuleType('metadata_execution');B.__file__=str(HERE.parent/'control-development.py')
exec((HERE.parent/'control-development.py').read_text().rsplit('p=argparse.ArgumentParser();',1)[0],B.__dict__)
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;private=Path(p['privateEnvironment']);assert B.sha(private)==p['environmentSHA256'];env=json.loads(private.read_text())
 initial=B.task_runner.Inputs(files=p['files'],directories=map(Path,p['directories']));assert initial.expected==p['inputs']
 logs=B.runpy.run_path(str(B.ROOT/'scripts/receipt-logs.py'))['CommandLogs'](out,[c['label'] for c in p['commands']]);generated={}
 inputs=B.task_runner.Inputs(files=[path,*p['files']],directories=map(Path,p['directories']));runner=B.task_runner.Runner(logs,inputs=inputs,env=env,cwd=B.ROOT)
 receipt={'status':'INCOMPLETE','planSHA256':B.sha(path),'commands':[],'scope':p['scope']}
 def guard():
  runner.inputs.guard();logs.guard();assert B.sha(private)==p['environmentSHA256'];assert B.configurations(list(map(Path,p['configurationRoots'])))==p['configurationStates'];assert all(B.sha(f)==digest for f,digest in generated.items())
  for name in ['sourceJoin','nodeJoin']:
   join=p[name];assert B.sha(join['receipt'])==join['sha256'];assert B.sha(Path(join['receipt']).parent/'plan.json')==join['planSHA256']
  tool_plan=Path(p['approvedToolSnapshotPlan']);assert B.sha(tool_plan)==p['approvedToolSnapshotPlanSHA256']
  for file,digest in json.loads(tool_plan.read_text())['tools']['pins'].items():assert B.sha(file)==digest
 try:
  guard()
  for c in p['commands']:
   guard();negative=p['status']=='PREPARED_UNADMITTED_CONTROLS' and c['label']!='positive'
   if 'generated' in c:assert not Path(c['generated']).exists(),'generated output already exists'
   try:r=runner.run(c['label'],c['argv'],c['seconds'],expected=None if negative else 0)
   except BaseException as error:
    r=getattr(error,'result',None);receipt['commands'].append({'label':c['label'],'exit':r['exit'] if r else None,'failure':r['failure'] if r else str(error)});raise
   receipt['commands'].append({'label':c['label'],'exit':r['exit'],'failure':r['failure'],'rawClassification':'UNCLASSIFIED' if negative else 'POSITIVE'})
   if negative:assert r['exit']==1 and r['failure'] is None,'unexpected negative outcome; intended raw diagnostic review required'
   if 'oracle' in c:assert r['stdout']==json.loads(Path(p['oracle']).read_text())[c['oracle']].encode(),'complete24 raw metadata/Array-owner oracle mismatch'
   if 'generated' in c:
    file=Path(c['generated']);assert file.is_file();generated[str(file)]=B.sha(file);runner.inputs=B.task_runner.Inputs(files=[path,*p['files'],*generated],directories=map(Path,p['directories']))
   guard()
  receipt['status']='COMPLETE_METADATA_JS_DEVELOPMENT_PASS' if p['status']=='PREPARED_UNADMITTED_JS' else 'RAW_STATIC_METADATA_CONTROLS_PENDING_DIAGNOSTIC_REVIEW'
 except BaseException as error:receipt['error']=str(error);raise
 finally:
  receipt['logs']=dict(logs.hashes);receipt['generated']=generated;(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
p=argparse.ArgumentParser();p.add_argument('plan');a=p.parse_args();run(a.plan)
