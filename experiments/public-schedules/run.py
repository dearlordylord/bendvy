#!/usr/bin/env python3
"""Source-bound public schedule observations and compiling mutation controls."""
import hashlib,json,os,pathlib,re,shutil,subprocess,tempfile,time

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
from task_runner import run as _run_command

ROOT=pathlib.Path(__file__).resolve().parents[2]
OUT=ROOT/'.artifacts'/('public-schedules-'+str(time.time_ns()))
OUT.mkdir(parents=True)
receipt={'commands':[], 'cases':[], 'source':{},'limits':{'check':5,'emit':30,'clang':120,'run':5}}
env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(args,cap,expect=0):
 start=time.monotonic();p=_run_command(list(map(str,args)),cwd=ROOT,env=env,capture_output=True,timeout=cap)
 record={'args':list(map(str,args)),'cap':cap,'exit':p.returncode,'elapsed':time.monotonic()-start,'stdout':p.stdout.decode(),'stderr':p.stderr.decode()};receipt['commands'].append(record)
 if expect is not None:assert p.returncode==expect,record
 return p
try:
 def imports(path,seen):
  if path in seen:return
  seen.add(path)
  for name in re.findall(r'^import\s+([^\s]+)',path.read_text(),re.M):
   if name=='Base':continue
   if name.endswith('.bend'):imports((path.parent/name).resolve(),seen)
 dependencies=set();imports(ROOT/'experiments/public-schedules/main.bend',dependencies)
 for p in dependencies | {p for p in (ROOT/'experiments/public-schedules').glob('*') if p.is_file()}:
  receipt['source'][str(p.relative_to(ROOT))]=sha(p)
 expected=run(['node',ROOT/'experiments/public-schedules/reference.mjs'],5).stdout
 assert len(expected.decode().splitlines())==23
 (OUT/'expected.txt').write_bytes(expected)
 for name,fragment in [('negative-affine','consumed more than once'),('negative-schema','Other')]:
  p=run(['timeout','5','bend',ROOT/f'experiments/public-schedules/{name}.bend'],6,1)
  assert fragment in (p.stdout+p.stderr).decode(),p
 for name,replacement,fragment in [
  ('writes-through-read','Cap.value_set(~H,~U32,~U32,~cap,ctx,0)','ValueWrite'),
  ('undeclared-access','W.observe_resource(~Schema,~Unit,~U32,~U32,~U32,~project_counter,ctx)','H')]:
  stage=OUT/name;shutil.copytree(ROOT/'src',stage/'src');shutil.copytree(ROOT/'experiments/public-schedules',stage/'experiments/public-schedules')
  target=stage/'experiments/public-schedules/main.bend';text=target.read_text();old='Cap.value_read(~H,~U32,~cap,ctx)';assert text.count(old)==1;target.write_text(text.replace(old,replacement))
  result=run(['timeout','5','bend',target],6,1);assert fragment in (result.stdout+result.stderr).decode()
 # Runtime namespace mismatch recovers the schedule and world unchanged.
 stage=OUT/'foreign-world';shutil.copytree(ROOT/'src',stage/'src');shutil.copytree(ROOT/'experiments/public-schedules',stage/'experiments/public-schedules')
 target=stage/'experiments/public-schedules/main.bend';text=target.read_text().replace('~Owners,1,"tick",steps','~Owners,2,"tick",steps');target.write_text(text)
 run(['timeout','5','bend',target],6)
 run(['bend',target,'-o',stage/'foreign.js'],30)
 foreign=run(['node',stage/'foreign.js'],5);assert foreign.stdout.count(b'rejected')==8 and b'run:' not in foreign.stdout
 run(['bend',target,'-o',stage/'foreign.c'],30)
 run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',stage/'foreign.c','-pthread','-lm','-o',stage/'foreign'],120)
 nativeForeign=run([stage/'foreign','--threads','1','--gpu','off'],5);assert nativeForeign.stdout==foreign.stdout
 receipt['foreignWorld']='rejected without callbacks; owners/world recovered on repeated calls'
 mutations={
  'order':('~condition,steps,owners,world,namespace,name,steps,[])','~condition,List.reverse(&2,Step,steps),owners,world,namespace,name,steps,[])'),
  'condition':('case False{}: next(owners,world,List.append(&2,Observation,observations,[Skipped{id}]))','case False{}: after_dispatch(~S,~C,~R,~E,~H,~Error,next,dispatch(owners,world,id),namespace,name,all,observations,id)'),
  'implicit-flush':('Finished{Schedule{namespace,name,all,owners},world,observations}','Finished{Schedule{namespace,name,all,owners},W.barrier(~S,~C,~R,~E,world),observations}')}
 for name in ['current',*mutations]:
  stage=OUT/name;shutil.copytree(ROOT/'src',stage/'src');shutil.copytree(ROOT/'experiments/public-schedules',stage/'experiments/public-schedules')
  if name!='current':
   source=stage/'src/ecs/schedule.bend';text=source.read_text();old,new=mutations[name];assert text.count(old)==1,(name,text.count(old));source.write_text(text.replace(old,new))
  main=stage/'experiments/public-schedules/main.bend'
  run(['timeout','5','bend',stage/'src/ecs/schedule.bend'],6)
  run(['timeout','5','bend',main],6)
  for backend,ext in [('JS','js'),('Native','c')]:
   generated=stage/('main.'+ext);run(['bend',main,'-o',generated],30)
   if backend=='Native':
    executable=stage/'main';run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',generated,'-pthread','-lm','-o',executable],120);cmd=[executable,'--threads','1','--gpu','off']
   else:cmd=['node',generated]
   result=run(cmd,5);(stage/(backend+'.stdout')).write_bytes(result.stdout)
   equal=result.stdout==expected
   assert equal==(name=='current'),(name,backend,result.stdout.decode(),expected.decode())
   receipt['cases'].append({'case':name,'backend':backend,'equal':equal,'detected':name!='current' and not equal,'outputSHA':hashlib.sha256(result.stdout).hexdigest(),'artifactSHA':sha(generated)})
 receipt['sourceUnchanged']=all(sha(ROOT/k)==v for k,v in receipt['source'].items());assert receipt['sourceUnchanged']
 receipt['status']='PASS'
finally:
 (OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(OUT)
