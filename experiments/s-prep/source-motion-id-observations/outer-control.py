#!/usr/bin/env python3
"""Infrastructure-only: late outer failure cannot adopt a published PASS."""
import argparse,hashlib,json,runpy,sys,tempfile
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'))
import supervisor
p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();assert not a.output.exists();a.output.mkdir()
planSHA=hashlib.sha256(a.plan.read_bytes()).hexdigest();calls=[]
def fake(argv,timeout):
 out=Path(argv[argv.index('--output')+1]);out.mkdir();rotation=int(argv[argv.index('--rotation')+1])
 (out/'evidence.json').write_text(json.dumps({'schema':'Motion','rotation':rotation,'status':'COMPLETE_FIELDS_RAW_DIAGNOSTIC_PASS'})+'\n')
 calls.append(argv)
 if rotation%3==0:raise TimeoutError('simulated late outer timeout')
 if rotation%3==1:return 1,'simulated late outer exit1'
 raise RuntimeError('simulated owned descendant failure')
supervisor.execute=fake
sys.argv=[str(HERE/'launch.py'),'--plan',str(a.plan),'--output',str(a.output/'launcher'),'--prefix',str(a.output/'attempt'),'--expected-plan',planSHA]
try:runpy.run_path(str(HERE/'launch.py'),run_name='__main__')
except SystemExit as e:assert e.code==1
else:raise AssertionError('late failures accepted')
idx=a.output/'launcher/results.json';d=json.loads(idx.read_text());assert len(calls)==10
assert all(r['status'] in ['OUTER_TIMEOUT','OUTER_FAILED'] and r['receiptStatus']=='COMPLETE_FIELDS_RAW_DIAGNOSTIC_PASS' for r in d['attempts'])
# Same actual summarizer must also refuse to compute qualifying medians.
sys.argv=[str(HERE/'summarize.py'),'--prefix',str(a.output/'attempt'),'--index',str(idx),'--output',str(a.output/'summary.json')]
runpy.run_path(str(HERE/'summarize.py'),run_name='__main__')
s=json.loads((a.output/'summary.json').read_text());assert not s['cohorts']['Motion']['complete'] and 'medianMS' not in s['cohorts']['Motion']
(a.output/'control.json').write_text(json.dumps({'status':'ALL_TEN_LATE_OUTER_FAILURES_REJECTED_AND_NO_MEDIANS','actualChildrenExecuted':0,'scope':'Mocked infrastructure control only; no ECS or performance gate','planSHA256':planSHA,'launcherSHA256':hashlib.sha256((HERE/'launch.py').read_bytes()).hexdigest(),'summarizerSHA256':hashlib.sha256((HERE/'summarize.py').read_bytes()).hexdigest()},indent=2)+'\n')
print('OUTER_FAILURE_CONTROL_PASS_NO_CHILDREN')
