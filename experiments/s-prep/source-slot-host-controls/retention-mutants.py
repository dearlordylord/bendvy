#!/usr/bin/env python3
"""Ten original E11 compiling mutations, each original authoritative Motion/lane input."""
from pathlib import Path
import argparse,json,re,shutil,hashlib,subprocess,signal,os,importlib.util
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();p=argparse.ArgumentParser();p.add_argument('--adapted',type=Path,required=True);p.add_argument('--original',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only',action='append');a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';parent=json.loads((a.original/'evidence.json').read_text());assert parent['status']=='FRESH_ORIGINAL_SLOT_E11_20_CASES_MUTANTS_PENDING' and len(parent['actual'])==20 and len(parent['publicReference'])==10;ad=json.loads((a.adapted/'adaptation.json').read_text());assert ad['sourcePins']==parent['sourcePins'];core0=a.adapted/'core';assert all(sha(core0/Path(n).name)==h for n,h in ad['sourcePins'].items()) and all(sha(core0/n)==h for n,h in ad['fixturePins'].items());spec=importlib.util.spec_from_file_location('R',ROOT/'experiments/s-integrate/host-retention-run.py');R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R);assert R.comparison_fingerprint()==parent['comparisonFingerprint'];rules=R.mutation_cases();reach=set(json.loads((a.adapted/'source-reachability.json').read_text())['definitions']);actualbatch='host-retention-controls-slice-host-batch-invoker.bend';assert (core0/actualbatch).is_file();r={'status':'INCOMPLETE','scope':'Fresh original E11 ten authoritative Motion/lane compiling mutants; not Health mutant coverage/full22','sourcePins':ad['sourcePins'],'originalReceiptSHA256':sha(a.original/'evidence.json'),'adaptationReceiptSHA256':sha(a.adapted/'adaptation.json'),'recipeSHA256':sha(Path(__file__)),'originalMutationCatalogueSHA256':sha(ROOT/'experiments/s-integrate/host-retention-run.py'),'cases':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
for name,file,old,new,count,lane in rules:
 if a.only and name not in a.only:continue
 folder=a.output/name;folder.mkdir();core=folder/'core';shutil.copytree(core0,core);file=actualbatch if file=='host-batch-invoker.bend' else file;target=core/file;case={'name':name,'subject':file,'input':{'schema':'Motion','lane':lane},'status':'INCOMPLETE','commands':[]};r['cases'].append(case);save()
 def run(cmd,limit,label):
  cmd=list(map(str,cmd));proc=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True);entry={'command':cmd,'limitSeconds':limit};case['commands'].append(entry)
  try:o,_=proc.communicate(timeout=limit)
  except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);o,_=proc.communicate();entry.update(status='TIMEOUT',exit=proc.returncode);(folder/(label+'.txt')).write_text(o);save();raise RuntimeError(label+' timeout')
  (folder/(label+'.txt')).write_text(o);entry.update(exit=proc.returncode,outputSHA256=hashlib.sha256(o.encode()).hexdigest());save();assert proc.returncode==0,o;return o
 try:
  content=target.read_text();assert any(x.startswith(file+':') for x in reach),'Mutation module is not in imported original E11 closure'
  if old is not None:
   assert content.count(old)==count,(name,content.count(old),count);changed=content.replace(old,new)
  else:
   start=content.index('def append(-P:');end=content.index('def append_units(',start);append=content[start:end];assert append.count('append_buffer(P,buffer,tick,values)')==1;append=append.replace('append_buffer(P,buffer,tick,values)','append_units(P,values,tick,buffer)');changed=content[:start]+content[end:];index=changed.index('def append_lifecycle(');changed=changed[:index]+append+changed[index:]
  target.write_text(changed);case.update(originalSHA256=hashlib.sha256(content.encode()).hexdigest(),mutantSHA256=sha(target),changedOccurrences=count,operation='split actual publication into single-value batches' if old is None else 'exact original anchor replacement',mutantSourcePins={n:sha(core/Path(n).name) for n in ad['sourcePins']},fixturePins={n:sha(core/n) for n in ad['fixturePins']});entry=core/'host-retention-controls.bend';checked=run(['bend',entry,'--check-only'],15,'check');assert 'ALL PROOFS CHECK' in checked;run(['bend',entry,'-o',folder/'subject.js'],30,'js-emit');run(['bend',entry,'-o',folder/'subject.c'],30,'c-emit');run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',folder/'subject.c','-pthread','-lm','-o',folder/'subject.native'],120,'clang');ref=next(x for x in parent['publicReference'] if x['schema']=='Motion' and x['lane']==lane);obs=[];outputs=[]
  for backend,cmd in [('JS',['node',folder/'subject.js',0,R.LANES.index(lane)]),('Native',[folder/'subject.native',0,R.LANES.index(lane),'--threads','1','--gpu','off'])]:
   raw=run(cmd,5,backend.lower()+'-run')
   try:R.compare_joined(raw,ref)
   except (AssertionError,ValueError,KeyError) as error:obs.append({'backend':backend,'compiling':True,'difference':str(error),'outputSHA256':hashlib.sha256(raw.encode()).hexdigest()})
   else:raise AssertionError('Compiling original E11 mutant survived '+name+'/'+backend)
   outputs.append(raw)
  assert outputs[0]==outputs[1];case.update(status='DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE',observations=obs,generatedPins={n:sha(folder/n) for n in ['subject.js','subject.c','subject.native']});print(name,'DETECTED',flush=True)
 except Exception as error:case.update(status='FAIL_OR_LIMIT',error=repr(error));print(name,'FAIL',repr(error),flush=True)
 save()
r['status']='FRESH_ACTUAL_SLOT_E11_TEN_MUTANTS_BOTH_BACKENDS_PASS' if len(r['cases'])==10 and all(x['status']=='DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE' for x in r['cases']) else 'PARTIAL_OR_FAILED';save()
