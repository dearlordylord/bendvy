#!/usr/bin/env python3
"""Two compiling actual semantic mutants; full lossless comparison, not hash-only kills."""
import pathlib,json,sys,os,shutil,tempfile,hashlib
os.sched_setaffinity(0,{7});H=pathlib.Path(__file__).resolve().parent;R=H.parents[1];sys.path.insert(0,str(R/'experiments/t05'));from run import command
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
report={'cpu':7,'backend':'JS','limits_seconds':{'checker':5,'codegen':30,'runtime':5,'decoder':5},'codec_sha256':sha(H/'failure-quiet-codec.bend'),'mutants':[]}
for name,file,old,new,intended in [('fourth-owned-payload','measurement-failure-callbacks.bend','case True{}: 400','case True{}: 40','Reserved'),('failed-reader-completion','readers.bend','case T.Failure{_}: readers','case T.Failure{_}: completed(readers,run)','FailureRead')]:
 row={'name':name,'file':file,'original':old,'replacement':new,'controls':[]}
 with tempfile.TemporaryDirectory(prefix='failure-fair-mutant-') as temporary:
  d=pathlib.Path(temporary)
  for overlay in ['failure-quiet-overlay','failure-indexed-overlay']:shutil.copytree(H/overlay,d/overlay)
  for helper in ['failure-quiet-codec.bend','failure-indexed-checks.bend','failure-indexed-service-guard.bend']:shutil.copyfile(H/helper,d/helper)
  p=d/'failure-quiet-overlay/experiments/s-integrate'/file;s=p.read_text();assert s.count(old)==1,(name,s.count(old));p.write_text(s.replace(old,new));row['mutant_sha256']=sha(p)
  subject=d/'failure-quiet-overlay/experiments/s-integrate/measurement-failure-driver.bend'
  try:
   checked=command(['bend',subject,'--check-only']);assert 'ALL PROOFS CHECK' in checked;row['checker']='PASS';command(['bend',subject,'-o',d/'mutant.js'],timeout=30)
   for idx,schema in enumerate(['Motion','Health']):
    control={'schema':schema,'count':64,'iterations':64}
    try:
     text=command(['node',d/'mutant.js',str(idx),'64','64']);f=d/'out.txt';f.write_text(text);actual=json.loads(command(['node',H/'failure-quiet-decode.mjs',schema,f]));original=pathlib.Path('/tmp/bendvy-perf-failure-quiet-fair')/f'{schema}-64-TS.txt';expected=json.loads(command(['node',H/'failure-quiet-decode.mjs',schema,original]));difference=next(({'index':i,'actual':a,'expected':b} for i,(a,b) in enumerate(zip(actual['events'],expected['events'])) if a!=b),None);assert difference is not None,'mutant survived';assert difference['actual']['kind']==intended,('wrong semantic decision path',difference);assert actual['effects']==expected['effects'],'unexpected Audit mutation'
     control.update(status='SEMANTIC_COUNTEREXAMPLE',actual_exit=0,first_difference=difference)
    except Exception as error:control.update(status='FAILED_OR_UNRESOLVED',diagnostic=str(error))
    row['controls'].append(control)
  except Exception as error:row.update(status='FAILED_OR_UNRESOLVED',diagnostic=str(error))
 report['mutants'].append(row);(H/'failure-quiet-mutation-evidence.json').write_text(json.dumps(report,indent=2)+'\n');print(name,row.get('checker'),[x['status'] for x in row['controls']],flush=True)
assert all(x.get('checker')=='PASS' and len(x['controls'])==2 and all(c['status']=='SEMANTIC_COUNTEREXAMPLE' for c in x['controls']) for x in report['mutants']),'mutation gate incomplete'
