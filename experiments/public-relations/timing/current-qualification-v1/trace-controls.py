"""Two forcing boundary falsifiers, cheap JS only; no timing qualification."""
from pathlib import Path
import hashlib,json,os,re,runpy,shutil,sys,time
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'scripts'));import task_runner
spec=runpy.run_path(str(HERE/'trace-cheap.py'));closure=spec['closure'];force=spec['force'];sha=spec['sha']
def main():
 out=ROOT/'.artifacts'/('relations-trace-forcing-controls-'+str(time.time_ns()));out.mkdir();files=set()
 for name in ['last-leaf','moved-walk']:closure(HERE/('trace-emitted-'+name+'.bend'),files)
 files.update([Path(__file__).resolve(),HERE/'trace-cheap.py',HERE/'trace-boundary.js',HERE/'trace-boundary.c',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'experiments/public-relations/promotion-stage/application/next-version/v1/expected.json']);files.update(Path(shutil.which(n)).resolve() for n in ['bend','node','taskset']);dirs=[Path('/home/node/.bend/bend2')];env=dict(os.environ,BEND_NO_TELEMETRY='1');inputs=task_runner.Inputs(files=files,directories=dirs);expected=json.loads((ROOT/'experiments/public-relations/promotion-stage/application/next-version/v1/expected.json').read_text());summary=force(expected);mutated=json.loads(json.dumps(expected));mutated[-1]['records'][-1]['systemResult']=1;commands=[{'label':'mutant-pure-check','argv':['taskset','-c','5','bend',str(HERE/'trace-last-leaf.bend'),'--check-only'],'seconds':5}]
 for name in ['last-leaf','moved-walk']:
  js=out/(name+'.js');commands.extend([dict(label=name+'-emit',argv=['taskset','-c','5','bend',str(HERE/('trace-emitted-'+name+'.bend')),'-o',str(js)],seconds=30,generated=str(js)),dict(label=name+'-run',argv=['taskset','-c','5','node',str(js)],seconds=5,control=name)])
 plan=dict(files=list(map(str,sorted(files))),directories=list(map(str,dirs)),inputs=inputs.expected,commands=commands,normalSummary=summary,lastLeafSummary=force(mutated),environmentSHA256=hashlib.sha256(json.dumps(env,sort_keys=True).encode()).hexdigest(),scope='Complete public trace and completion forcing only; no timer/backend Native/comparative acceptance');(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](out,[c['label'] for c in commands]);runner=task_runner.Runner(logs,inputs=inputs,env=env,cwd=ROOT);r=dict(status='INCOMPLETE',planSHA256=sha(out/'plan.json'),commands=[]);generated={}
 try:
  for c in commands:
   x=runner.run(c['label'],c['argv'],c['seconds']);r['commands'].append(dict(label=c['label'],exit=x['exit'],failure=x['failure']));assert x['exit']==0 and x['failure'] is None
   if c['label']=='mutant-pure-check':assert b'ALL PROOFS CHECK' in x['stdout'] and b'SOME PROOFS FAIL' not in x['stdout']
   if 'generated' in c:generated[c['generated']]=sha(c['generated']);runner.inputs=task_runner.Inputs(files=[*files,*generated],directories=dirs)
   if 'control' in c:
    actual=json.loads(x['stdout']);boundaries=[json.loads(line) for line in x['stderr'].splitlines()]
    if c['control']=='last-leaf':assert actual==mutated and actual!=expected;assert boundaries==[dict(boundary='begin'),dict(boundary='complete-trace-forced',**force(mutated))] and force(mutated)!=summary;r['lastLeaf']='FALSIFIED: one final leaf changes completion control and complete oracle'
    else:assert actual==expected;assert boundaries==[dict(boundary='begin'),dict(boundary='complete-trace-forced',nodes=0,characters=0,sum=0),dict(boundary='complete-trace-forced',**summary)];r['movedWalk']='FALSIFIED: unforced first completion despite unchanged complete output'
   runner.inputs.guard();logs.guard()
  r['status']='BOTH_JS_FORCING_BOUNDARY_FALSIFIERS_PASS_NO_TIMING_VERDICT'
 except BaseException as e:r['error']=str(e);raise
 finally:r['generated']=generated;r['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
if __name__=='__main__':main()
