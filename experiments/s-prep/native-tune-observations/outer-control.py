#!/usr/bin/env python3
"""Finite runner control only: no compiler, runtime, or measurement children."""
import hashlib,json,runpy,sys,tempfile,types
from pathlib import Path
HERE=Path(__file__).resolve().parent
with tempfile.TemporaryDirectory(prefix='tune-outer-control-') as root:
 root=Path(root);plan=root/'plan.json';plan.write_text(json.dumps({'pins':{str((HERE/'cohort.py').resolve()):hashlib.sha256((HERE/'cohort.py').read_bytes()).hexdigest()}}))
 calls=[]
 def fake(argv,limit):
  assert limit==60;calls.append(argv);output=Path(argv[-1]);output.mkdir()
  # Simulate a receipt published before its outer command failed.
  (output/'evidence.json').write_text(json.dumps({'status':'COMPLETE_FIELDS_RAW_DIAGNOSTIC_PASS'}))
  if len(calls)%3==0:raise RuntimeError('child left owned descendants')
  if len(calls)%3==1:raise TimeoutError('child deadline')
  return 1,'failed after receipt'
 sys.modules['supervisor']=types.SimpleNamespace(execute=fake)
 sys.argv=[str(HERE/'cohort.py'),'--plan',str(plan),'--prefix',str(root/'cohort')]
 try:runpy.run_path(str(HERE/'cohort.py'),run_name='__main__')
 except SystemExit as result:assert result.code==1
 rows=json.loads((root/'cohort-index.json').read_text())['rows']
 assert len(rows)==20
 if calls:
  for row in rows:
   if row['status']=='NOT_LAUNCHED_DEADLINE':continue
   assert row['status'] in ['OUTER_TIMEOUT','OUTER_FAILURE']
   assert row['reportedReceiptStatus']=='COMPLETE_FIELDS_RAW_DIAGNOSTIC_PASS'
  print('OUTER_FAILURE_CANNOT_QUALIFY_PASS_CONTROL',len(calls),'simulated attempts; no children executed')
 else:print('DEADLINE_REFUSAL_CONTROL_PASS; no children executed')
