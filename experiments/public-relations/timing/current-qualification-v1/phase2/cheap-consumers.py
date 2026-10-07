"""Two bounded development consumers, not backend/performance qualification."""
from pathlib import Path
import hashlib,json,os,re,runpy,shutil,sys,time
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
sys.path.insert(0,str(ROOT/'scripts'));import task_runner
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def closure(source):
 seen=set();todo=[source]
 while todo:
  p=todo.pop().resolve()
  if p in seen:continue
  seen.add(p)
  if p.suffix=='.bend':
   for line in p.read_text().splitlines():
    if line.startswith('import '):
     name=line.split()[1]
     if name.endswith('.bend'):todo.append(p.parent/name)
    elif line.strip().startswith('import "'):
     q=p.parent/line.strip().split('"')[1]
     if q.exists():todo.append(q)
 return seen

def prepare():
 out=ROOT/'.artifacts'/('relations-phase2-cheap-'+str(time.time_ns()));out.mkdir()
 files=closure(HERE/'driver.bend');files.update([Path(__file__).resolve(),HERE/'reference.mjs',HERE/'oracle.py',HERE/'expected/manifest.json',HERE/'expected/population-64-seed-0.json',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',HERE.parent/'trace-cheap.py'])
 files.update(Path(shutil.which(name)).resolve() for name in ['bend','node','taskset'])
 directories=[Path('/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src')]
 inputs=task_runner.Inputs(files=files,directories=directories);env=dict(os.environ,BEND_NO_TELEMETRY='1');private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600)
 args=['population','64','0','0'];commands=[['ts',['taskset','-c','5','node',str(HERE/'reference.mjs'),*args],5],['bend-io',['taskset','-c','5','bend',str(HERE/'driver.bend'),*args],5]]
 plan={'scope':'development actual complete30 TS and Bend in-process emitted-JS IO consumers only; no installed-tool/proof/backend/timing acceptance','commands':commands,'files':list(map(str,sorted(files))),'directories':list(map(str,directories)),'inputs':inputs.expected,'environmentSHA256':hashlib.sha256(json.dumps(env,sort_keys=True).encode()).hexdigest(),'expected':str(HERE/'expected/population-64-seed-0.json'),'sourceClosureFiles':len(closure(HERE/'driver.bend')),'forcing':'population-derived full traversal before completion; serializer after completion; incomplete refuses normal JSON','setup':'validated input and both registered setup worlds before Begin'}
 (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out)

def execute(out):
 plan=json.loads((out/'plan.json').read_text());env=json.loads((out/'private-environment.json').read_text());assert hashlib.sha256(json.dumps(env,sort_keys=True).encode()).hexdigest()==plan['environmentSHA256']
 inputs=task_runner.Inputs(files=map(Path,plan['files']),directories=map(Path,plan['directories']));assert inputs.expected==plan['inputs']
 logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](out,[x[0] for x in plan['commands']]);runner=task_runner.Runner(logs,inputs=inputs,env=env,cwd=ROOT);expected=json.loads(Path(plan['expected']).read_text());summary=runpy.run_path(str(HERE.parent/'trace-cheap.py'))['force'](expected);receipt={'status':'INCOMPLETE','planSHA256':sha(out/'plan.json'),'commands':[]}
 try:
  for label,argv,seconds in plan['commands']:
   result=runner.run(label,argv,seconds);receipt['commands'].append({'label':label,'exit':result['exit'],'failure':result['failure']});assert result['exit']==0 and result['failure'] is None
   lines=result['stderr'].splitlines();boundaries=[json.loads(line) for line in lines if line.startswith(b'{')];other=[line.decode() for line in lines if not line.startswith(b'{')];assert not other or label=='bend-io' and all(line.startswith('bend ') and ' is available: run bend update' in line for line in other),other
   assert boundaries==[{'boundary':'begin'},{'boundary':'complete-trace-forced',**summary}]
   actual=json.loads(result['stdout']);assert actual==expected,'complete30 oracle mismatch';receipt[label+'Records']=sum(len(root['records']) for root in actual['roots']);receipt[label+'CompilerNotices']=other
   inputs.guard();logs.guard()
  receipt['status']='DEVELOPMENT_COMPLETE30_CONSUMERS_PASS_NOT_DELIVERY'
 except BaseException as error:receipt['error']=str(error);raise
 finally:receipt['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
if __name__=='__main__':
 if len(sys.argv)==1:prepare()
 else:execute(Path(sys.argv[1]).resolve())
