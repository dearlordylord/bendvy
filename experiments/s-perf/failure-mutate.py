#!/usr/bin/env python3
"""Compiling actual mutations with intended guard/full-observation counterexamples."""
import pathlib,sys,os,json,shutil,tempfile,hashlib,importlib.util
os.sched_setaffinity(0,{7});H=pathlib.Path(__file__).resolve().parent;R=H.parents[1];sys.path.insert(0,str(R/'experiments/t05'));from run import command,execute
spec=importlib.util.spec_from_file_location('validation',H/'failure-validate.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
M=[('fourth-owned-payload','measurement-failure-callbacks.bend','case True{}: 400','case True{}: 40','quiet service own-write/reservation/ping full-field guard',24),('reader-failed-completion','readers.bend','case T.Failure{_}: readers','case T.Failure{_}: completed(readers,run)','quiet reader full-field guard',23),('historical-lookup-omission','measurement-failure-observe.bend',',bindings),failed))),',',bindings),[]))),','quiet observation full-field guard',22),('clock-record-corruption','measurement-failure-host.bend','E.FailureRead{i,name,count,messages,lag,D.clock_tick(clock),','E.FailureRead{i,name,count,messages,lag,U32.add(D.clock_tick(clock),1),',None,0),('lost-audit-effect','dispatcher.bend','Recorded{text <> effects}','Recorded{effects}',None,0)]
report={'cpu':7,'limits_seconds':{'checker':5,'codegen':30,'runtime':5,'reference':5},'mutants':[],'source_sha256':{str(p.relative_to(H)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(H.rglob('*.bend'))}}
for name,file,old,new,diagnostic,expected in M:
 row={'name':name,'file':file,'original':old,'replacement':new,'controls':[]}
 with tempfile.TemporaryDirectory(prefix='failure-quiet-mutant-') as td:
  d=pathlib.Path(td);shutil.copytree(H/'failure-overlay',d/'failure-overlay')
  for helper in ['failure-checks.bend','failure-service-guard.bend']:shutil.copyfile(H/helper,d/helper)
  p=d/'failure-overlay/experiments/s-integrate'/file;s=p.read_text();assert s.count(old)>0,(name,old);row['replacements']=s.count(old);p.write_text(s.replace(old,new))
  subject=d/'failure-overlay/experiments/s-integrate/measurement-failure-driver.bend'
  try:
   out=command(['bend',subject,'--check-only']);assert 'ALL PROOFS CHECK' in out;row['checker']='PASS';command(['bend',subject,'-o',d/'mutant.js'],timeout=30)
   for idx,schema in enumerate(['Motion','Health']):
    control={'schema':schema,'count':64,'iterations':64}
    try:
     out=command(['node',d/'mutant.js',str(idx),'64','64'],expected=expected)
     if diagnostic:
      assert diagnostic in out,('wrong-reason failure',out);control.update(status='SEMANTIC_COUNTEREXAMPLE',diagnostic=diagnostic,actual_exit=expected)
     else:
      ref=json.loads(command(['node','/workspace/formal-proofs/bendvy/experiments/s-integrate/measurement-reference.mjs',schema,'failed-transaction','64']))
      try:V.validate(out,ref)
      except (AssertionError,IndexError) as exc:control.update(status='SEMANTIC_COUNTEREXAMPLE',diagnostic=str(exc),actual_exit=0)
      else:control['status']='SURVIVED'
    except Exception as exc:control.update(status='FAILED_OR_UNRESOLVED',diagnostic=str(exc))
    row['controls'].append(control)
  except Exception as exc:row.update(status='FAILED_OR_UNRESOLVED',diagnostic=str(exc))
 report['mutants'].append(row);(H/'failure-mutation-evidence.json').write_text(json.dumps(report,indent=2)+'\n');print(name,row.get('status',row['controls']),flush=True)
report['status']='BOUNDED_ATTEMPTS_COMPLETE';(H/'failure-mutation-evidence.json').write_text(json.dumps(report,indent=2)+'\n')
