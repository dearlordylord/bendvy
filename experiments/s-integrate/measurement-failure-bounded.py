#!/usr/bin/env python3
"""CPU7 supplementary bounded originals and compiling decision-path mutations."""
import os,pathlib,sys,json,hashlib,importlib.util,tempfile,shutil,re,time
os.sched_setaffinity(0,{7})
H=pathlib.Path(__file__).resolve().parent;ROOT=H.parent.parent
sys.path.insert(0,str(H.parent/'t05'));from run import command,execute
s=importlib.util.spec_from_file_location('oracle',H/'measurement-failure-oracle.py');O=importlib.util.module_from_spec(s);s.loader.exec_module(O)
F=pathlib.Path('/tmp/bendvy-measurement-failure');report={'cpu':7,'limits_seconds':{'checker':5,'runtime':5,'reference':5,'codegen':30,'clang':120},'source_commit':command(['git','rev-parse','HEAD']).strip(),'base_commit':'9bdcb55fd654fffbff9a8310b466f909f23ce809','results':[],'mutants':[]}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def closure(p,seen):
 if p in seen:return
 seen.add(p)
 for ref in re.findall(r'^import (\./\S+\.bend)',p.read_text(),re.M):closure((p.parent/ref).resolve(),seen)
files=set();closure((H/'measurement-failure-driver.bend').resolve(),files)
if '--mutants-only' in sys.argv:
 report=json.loads((H/'measurement-failure-bounded-evidence.json').read_text());report['mutants']=[];report['mutation_replay_note']='Original stages retained unchanged; mutations replayed with first-difference diagnostic and CPU7 original JS controls.'
report['oracle_sha256']=sha(H/'measurement-failure-oracle.py')
report['subject_sha256']={str(p.relative_to(ROOT)):sha(p) for p in sorted(files)}
def save(): (H/'measurement-failure-bounded-evidence.json').write_text(json.dumps(report,indent=2)+'\n')
def reference(schema,count):
 p=pathlib.Path('/workspace/formal-proofs/bendvy/experiments/s-integrate/measurement-reference.mjs');assert sha(p)==sha(H/p.name)
 return json.loads(command(['node',p,schema,'failed-transaction',str(count)]))
for idx,schema in enumerate(['Motion','Health']):
 for count in ([] if '--mutants-only' in sys.argv else [256,1024]):
  row={'schema':schema,'count':count,'backend':'javascript','iterations':64}
  try:
   ref=reference(schema,count);out=execute(F/'driver.js',[str(idx),str(count),'64']);(F/f'{schema}-{count}-javascript.txt').write_text(out);row['validation']=O.validate(out,ref);row['status']='FULL_VALUES_EQUAL'
  except Exception as e:row.update(status='FAILED_OR_UNRESOLVED',diagnostic=str(e))
  report['results'].append(row);save();print(schema,count,row['status'],flush=True)
if '--mutants-only' not in sys.argv:
 try:
  command(['clang','-std=c11','-O3',F/'driver.c','-lpthread','-lm','-o',F/'driver-o3'],timeout=120);report['optimized_build']={'status':'COMPILED','c_sha256':sha(F/'driver.c'),'binary_sha256':sha(F/'driver-o3')}
 except Exception as e:report['optimized_build']={'status':'FAILED_OR_UNRESOLVED','diagnostic':str(e)}
 save();print('O3',report['optimized_build']['status'],flush=True)
 if report['optimized_build']['status']=='COMPILED':
  for idx,schema in enumerate(['Motion','Health']):
   for count in [64,256,1024]:
    row={'schema':schema,'count':count,'backend':'native-O3','iterations':64}
    try:
     ref=reference(schema,count);out=execute(F/'driver-o3',[str(idx),str(count),'64']);row['validation']=O.validate(out,ref);row['status']='FULL_VALUES_EQUAL'
    except Exception as e:row.update(status='FAILED_OR_UNRESOLVED',diagnostic=str(e))
    report['results'].append(row);save();print(schema,count,'O3',row['status'],flush=True)
mutations=[('inverse-order','transaction.bend','restore_ledger,undo,world)','restore_ledger,List.reverse(&2,Inverse<H>,undo),world)'),('second-write','measurement-failure-callbacks.bend','U32.add(x,30)','U32.add(x,10)'),('fourth-cell','measurement-failure-callbacks.bend','case True{}: 400','case True{}: 40'),('reader-failure-advance','readers.bend','case T.Failure{_}: readers','case T.Failure{_}: completed(readers,run)')]
report['original_cpu7_javascript_controls']=[]
for idx,schema in enumerate(['Motion','Health']):
 out=execute(F/'driver.js',[str(idx),'64','64']);validated=O.validate(out,reference(schema,64));report['original_cpu7_javascript_controls'].append({'schema':schema,'status':'FULL_VALUES_EQUAL','output_sha256':hashlib.sha256(out.encode()).hexdigest(),'full_row_fields_checked':validated.get('full_row_fields_checked')});save()
for name,file,old,new in mutations:
 row={'name':name,'file':file,'original':old,'replacement':new,'controls':[]}
 with tempfile.TemporaryDirectory(prefix='failure-mutant-') as td:
  d=pathlib.Path(td)
  # Copy exact complete import closure; external helper paths rewritten to originals.
  for p in files:
   dest=d/p.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True)
   text=p.read_text()
   def rewrite(m):
    orig=(p.parent/m[1]).resolve();target=d/orig.relative_to(ROOT) if orig in files else orig
    return 'import '+('./' if not os.path.relpath(target,dest.parent).startswith('.') else '')+os.path.relpath(target,dest.parent)
   text=re.sub(r'^import (\./\S+\.bend)',rewrite,text,flags=re.M)
   if p.name==file:
    assert text.count(old)==1,(file,old);text=text.replace(old,new)
   dest.write_text(text)
  subject=d/'experiments/s-integrate/measurement-failure-driver.bend'
  try:
   checked=command([H.parent/'t01'/'bend-check',subject,'--check-only']);assert 'ALL PROOFS CHECK' in checked;row['checker']='PASS'
   command(['bend',subject,'-o',d/'mutant.js'],timeout=30)
   for idx,schema in enumerate(['Motion','Health']):
    control={'schema':schema,'count':64,'iterations':64}
    try:
     out=execute(d/'mutant.js',[str(idx),'64','64']);control['output_sha256']=hashlib.sha256(out.encode()).hexdigest();ref=reference(schema,64)
     try:O.validate(out,ref)
     except AssertionError as e:control.update(status='SEMANTIC_COUNTEREXAMPLE',diagnostic=str(e))
     else:control['status']='SURVIVED'
    except Exception as e:control.update(status='FAILED_OR_UNRESOLVED',diagnostic=str(e))
    row['controls'].append(control)
  except Exception as e:row.update(status='FAILED_OR_UNRESOLVED',diagnostic=str(e))
 report['mutants'].append(row);save();print(name,row.get('status',row['controls']),flush=True)
assert report['subject_sha256']=={str(p.relative_to(ROOT)):sha(p) for p in sorted(files)},'subjects changed'
report['artifact_sha256']={p.name:sha(p) for p in [F/'driver-native',F/'driver.js',F/'driver.c']};report['status']='BOUNDED_ATTEMPTS_COMPLETE';save()
