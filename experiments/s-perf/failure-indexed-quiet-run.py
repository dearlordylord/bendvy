#!/usr/bin/env python3
"""Compact sink feasibility only; full diagnostic acceptance remains separate."""
import pathlib,json,os,sys,re,hashlib
os.sched_setaffinity(0,{7});H=pathlib.Path(__file__).resolve().parent;R=H.parents[1];sys.path.insert(0,str(R/'experiments/t05'));from run import execute
F=pathlib.Path('/tmp/bendvy-perf-failure-indexed-quiet');report={'scope':'Exact byte-identical authored loops with full-value guards; final compact counts do NOT prove full output correspondence and do not replace missing1024 diagnostic acceptance','ratio_acceptance':False,'results':[],'body_pins':json.loads((H/'failure-quiet-body-pins.json').read_text())}
for idx,schema in enumerate(['Motion','Health']):
 for count in [64,256,1024]:
  outputs=[]
  for backend,program in [('NativeO3',F/'driver-native'),('JS',F/'driver.js')]:
   case={'schema':schema,'count':count,'backend':backend}
   try:
    text=execute(program,[str(idx),str(count),'64']);assert 'FAILURE-AUDIT-COUNT:192' in text;assert 'FAILURE-COUNTS:' in text
    case.update(status='COMPACT_FULL_GUARDS_RETURNED',output=text);outputs.append(re.sub(r'FAILURE-TIMING:\d+','FAILURE-TIMING:<measured>',text))
   except Exception as error:case.update(status='BOUNDED_NEGATIVE',diagnostic=str(error))
   report['results'].append(case);(H/'failure-indexed-quiet-runtime-evidence.json').write_text(json.dumps(report,indent=2)+'\n');print(schema,count,backend,case['status'],flush=True)
  if len(outputs)==2:assert outputs[0]==outputs[1],(schema,count,'compact backend difference')
