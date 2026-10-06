#!/usr/bin/env python3
"""Execute the ten frozen Motion raw attempts serially; preserve every failure."""
import argparse, datetime, hashlib, json, sys
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy')
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'))
import supervisor
p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True)
p.add_argument('--output',type=Path,required=True);p.add_argument('--prefix',required=True);p.add_argument('--expected-plan',required=True)
a=p.parse_args();a.output.mkdir(exist_ok=False)
sha=lambda path:hashlib.sha256(Path(path).read_bytes()).hexdigest()
observer=Path(__file__).resolve().parent/'observe.py'
plan=json.loads(a.plan.read_text());assert sha(observer)==plan['observerSHA256']
assert sha(a.plan)==a.expected_plan
before={str(a.plan):sha(a.plan),str(observer):sha(observer),str(Path(__file__).resolve()):sha(__file__)}
deadline=datetime.datetime(2026,10,6,20,25,54,tzinfo=datetime.timezone.utc)
results=[]
for rotation in range(10):
    for schema in ['Motion']:
        output=Path(a.prefix+'-'+schema.lower()+'-r'+str(rotation))
        argv=[sys.executable,str(observer),'--plan',str(a.plan),'--schema',schema,
              '--rotation',str(rotation),'--output',str(output)]
        remaining=(deadline-datetime.datetime.now(datetime.timezone.utc)).total_seconds()
        row={'schema':schema,'rotation':rotation,'output':str(output),'argv':argv,
             'outerLimitSeconds':60,'childLimitSeconds':5}
        if remaining<70:
            row.update(status='NOT_LAUNCHED_DEADLINE',remainingSeconds=remaining)
        else:
            try:
                code,text=supervisor.execute(argv,60)
                outer_failure=None
            except Exception as error:
                code=124 if isinstance(error,TimeoutError) else 1
                text=repr(error);outer_failure='OUTER_TIMEOUT' if code==124 else 'OUTER_FAILED'
            log=a.output/(schema.lower()+'-r'+str(rotation)+'.stdout');log.write_text(text)
            row.update(exit=code,stdoutSHA256=sha(log))
            evidence=output/'evidence.json'
            if evidence.exists():
                receipt=json.loads(evidence.read_text())
                row.update(receiptStatus=receipt['status'],receiptSHA256=sha(evidence),
                           status=receipt['status'] if code==0 else (outer_failure or 'OUTER_FAILED'))
            else:row.update(status='FAILED_NO_RECEIPT')
        results.append(row)
        (a.output/'results.json').write_text(json.dumps({'pinsBefore':before,'attempts':results},indent=2)+'\n')
        print(json.dumps({key:row.get(key) for key in ['schema','rotation','status','exit']}),flush=True)
assert all(sha(path)==pin for path,pin in before.items())
raise SystemExit(0 if len(results)==10 and all(row['status']=='COMPLETE_FIELDS_RAW_DIAGNOSTIC_PASS' for row in results) else 1)
