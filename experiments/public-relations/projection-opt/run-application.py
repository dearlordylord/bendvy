"""Semantic-only wrapper of unchanged reviewed timing.Harness; no comparisons."""
from pathlib import Path
import sys,json,importlib.util,types,time
R=Path(__file__).resolve().parents[3];D=Path(__file__).resolve().parent
sys.path.insert(0,str(R/'experiments/public-relations/timing'));import run as reviewed;import stage
original_sources=stage.sources
for variant in ['baseline','candidate']:
 extras=[Path(__file__).resolve(),D/'prepare-application.py']
 if variant=='candidate':extras.append(D/'candidate'/stage.APP.relative_to(R)/'owned-world.bend')
 def role_sources():
  result=original_sources();result.update({str(path.relative_to(R)):stage.sha(path) for path in extras});return result
 stage.sources=role_sources
 args=types.SimpleNamespace(stage=D/'application-execution-v2'/variant,output=D/'application-results'/(variant+'-'+str(time.time_ns())),cpu=8,timing=False)
 h=reviewed.Harness(args)
 h.labels=['bend-version','bend-guide','original-TS','pure-check','1-TS','1-emit-JS','1-emit-C','1-clang','1-JS','1-Native'];h.r['prospective_labels']=h.labels;h.r['scope']='Complete original public application semantic observations only; baseline/candidate projection helper comparison; no timing qualification.';h.save()
 try:
  app=h.tree/stage.APP.relative_to(R);h.expected=json.loads((app/'expected.json').read_text());sys.path.insert(0,str(app));h.validator=reviewed.load('projection_application_validator',app/'validate.py')
  h.run('bend-version',['bend','version'],5);h.run('bend-guide',['bend','guide'],5)
  actual=h.run('original-TS',['node',app/'reference.mjs'],5);assert [json.loads(line) for line in actual.splitlines()]==h.expected
  h.run('pure-check',['bend',app/'application.bend','--check-only'],5);h.sample(1,'TS','1-TS')
  entry=h.tree/stage.HERE.relative_to(R)/'relations-1.bend'
  h.run('1-emit-JS',['bend',entry,'-o',args.output/'relations-1.js'],30,args.output/'relations-1.js')
  h.run('1-emit-C',['bend',entry,'-o',args.output/'relations-1.c'],30,args.output/'relations-1.c')
  h.run('1-clang',[reviewed.CLANG,'-O3',args.output/'relations-1.c','-pthread','-lm','-o',args.output/'relations-1.native'],120,args.output/'relations-1.native')
  h.r['observations']={role:h.sample(1,role,'1-'+role) for role in ['JS','Native']};h.guard();h.r['status']='COMPLETE_PROJECTION_APPLICATION_SEMANTICS_PASS'
 except Exception as e:h.r['status']='FAIL';h.r['error']=repr(e)
 finally:h.save()
 print(args.output,h.r['status'])
 if h.r['status']=='FAIL':sys.exit(1)
