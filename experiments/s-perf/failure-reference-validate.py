#!/usr/bin/env python3
"""Fresh original/aligned public TS results; each task-owned invocation <=5s."""
import pathlib,sys,json,hashlib,os,importlib.util
os.sched_setaffinity(0,{7})
ROOT=pathlib.Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('runner',ROOT/'experiments/t05/run.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
ref=pathlib.Path('/workspace/formal-proofs/bendvy/experiments/s-integrate/measurement-reference.mjs')
adapter=ROOT/'experiments/s-perf/failure-reference-timing.mjs'
report={'reference_sha256':hashlib.sha256(ref.read_bytes()).hexdigest(),'adapter_sha256':hashlib.sha256(adapter.read_bytes()).hexdigest(),'scope':'TS diagnostic equivalence only; no Bend timing ratio','cases':[]}
for schema in ['Motion','Health']:
 for count in [64,256,1024]:
  row={'schema':schema,'count':count}
  try:
   a=m.command(['node',str(ref),schema,'failed-transaction',str(count)],timeout=5)
   b=m.command(['node',str(adapter),schema,str(count)],timeout=5)
   original=json.loads(a);aligned=json.loads(b)
   row['inner_ms']=aligned['innerMs']
   for key in ['innerMs','experimentalAlignment','peakRssKiB']:aligned.pop(key,None)
   original.pop('peakRssKiB',None)
   assert original==aligned,(schema,count,'complete actual diagnostic difference')
   row['status']='FULL_DIAGNOSTIC_EQUAL'
  except Exception as error:row.update(status='BOUNDED_NEGATIVE',diagnostic=str(error))
  report['cases'].append(row)
(ROOT/'experiments/s-perf/failure-reference-evidence.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
