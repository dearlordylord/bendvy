import pathlib,json,sys,os,tempfile,shutil
os.sched_setaffinity(0,{7});H=pathlib.Path(__file__).resolve().parent;R=H.parents[2];sys.path.insert(0,str(R/'experiments/t05'));from run import command
report={'limits_seconds':{'checker':5,'codegen':30,'runtime':5},'protocol':'same-process warmup and measured worlds','mutants':[]}
for name,file,old,new,intended in [('fourth-owned-payload','measurement-failure-callbacks.bend','case True{}: 400','case True{}: 40','Reserved'),('failed-reader-completion','readers.bend','case T.Failure{_}: readers','case T.Failure{_}: completed(readers,run)','FailureRead')]:
 row={'name':name,'controls':[]}
 with tempfile.TemporaryDirectory(prefix='prep22-warmup-mutant-') as tmp:
  d=pathlib.Path(tmp);shutil.copytree(H/'materialized',d/'materialized');p=d/'materialized/overlay/experiments/s-integrate'/file;s=p.read_text();assert s.count(old)==1;p.write_text(s.replace(old,new))
  try:
   row['checker']=command(['bend',d/'materialized/overlay/experiments/s-integrate/measurement-failure-driver.bend','--check-only']);command(['bend',d/'materialized/overlay/experiments/s-integrate/measurement-failure-driver.bend','-o',d/'mutant.js'],timeout=30);row['codegen']='PASS'
   for i,schema in enumerate(['Motion','Health']):
    control={'schema':schema}
    try:
     out=command(['node',d/'mutant.js',str(i),'64','64']);f=d/'out.txt';f.write_text(out);actual=json.loads(command(['node',H/'materialized/failure-quiet-decode.mjs',schema,f]));expected=json.loads(command(['node',H/'materialized/failure-quiet-decode.mjs',schema,pathlib.Path('/tmp/bendvy-prep22-warmup')/f'{schema}-64-TS.txt']));difference=next(({'index':i,'actual':a,'expected':b} for i,(a,b) in enumerate(zip(actual['events'],expected['events'])) if a!=b),None);assert difference and difference['actual']['kind']==intended,difference;assert actual['effects']==expected['effects'];control.update(status='SEMANTIC_COUNTEREXAMPLE',actual_exit=0,first_difference=difference)
    except Exception as e:control.update(status='FAILED_OR_UNRESOLVED',diagnostic=str(e))
    row['controls'].append(control)
  except Exception as e:row.update(status='FAILED_OR_UNRESOLVED',diagnostic=str(e))
 report['mutants'].append(row);(H/'mutation-evidence.json').write_text(json.dumps(report,indent=2)+'\n');print(name,[c['status'] for c in row['controls']],flush=True)
