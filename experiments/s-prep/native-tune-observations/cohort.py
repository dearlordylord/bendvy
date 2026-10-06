#!/usr/bin/env python3
"""Root-only fixed reviewed cohort with finite deadline and preserved20 rows."""
import argparse,datetime,hashlib,json,sys
from pathlib import Path
sys.path.insert(0,'/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates')
import supervisor
DEADLINE=datetime.datetime(2026,10,6,20,25,54,tzinfo=datetime.timezone.utc)
p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True);p.add_argument('--prefix',required=True);a=p.parse_args()
plan=json.loads(a.plan.read_text());assert plan['pins'][str(Path(__file__).resolve())]==hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
index=Path(a.prefix+'-index.json');assert not index.exists()
rows=[{'schema':s,'rotation':r,'status':'NOT_LAUNCHED'} for s in ['Motion','Health'] for r in range(10)]
def save():index.write_text(json.dumps({'deadlineUTC':DEADLINE.isoformat(),'outerSeconds':60,'minimumRemainingSeconds':70,'planSHA256':hashlib.sha256(a.plan.read_bytes()).hexdigest(),'rows':rows},indent=2)+'\n')
save()
for row in rows:
 schema=row['schema'];rotation=row['rotation'];output=Path(a.prefix+'-'+schema.lower()+'-r'+str(rotation));assert not output.exists()
 remaining=(DEADLINE-datetime.datetime.now(datetime.timezone.utc)).total_seconds()
 if remaining<70:
  row.update(status='NOT_LAUNCHED_DEADLINE',remainingSeconds=remaining);save();continue
 argv=[sys.executable,str(Path(__file__).with_name('observe.py')),'--plan',str(a.plan),'--schema',schema,'--rotation',str(rotation),'--output',str(output)]
 row.update(status='RUNNING',argv=argv);save()
 try:
  code,log=supervisor.execute(argv,60);result={'exit':code,'timeout':False,'output':log}
 except Exception as error:
  result={'exit':124 if isinstance(error,TimeoutError) else 1,'timeout':isinstance(error,TimeoutError),'error':repr(error)}
 outer=Path(str(output)+'-outer.json');outer.write_text(json.dumps({'argv':argv,'outerSeconds':60,**result},indent=2)+'\n')
 receipt=output/'evidence.json';row.update(status=('OUTER_TIMEOUT' if result['timeout'] else 'OUTER_FAILURE') if result['exit'] else 'FAILED_NO_RECEIPT',receiptMissing=not receipt.exists(),outerReceipt=str(outer),**result)
 if receipt.exists():
  current=json.loads(receipt.read_text());row.update(reportedReceiptStatus=current['status'],receipt=str(receipt),receiptSHA256=hashlib.sha256(receipt.read_bytes()).hexdigest())
  if result['exit']==0 and not result['timeout']:row['status']=current['status']
  else:row['status']='OUTER_TIMEOUT' if result['timeout'] else 'OUTER_FAILURE'
 save()
sys.exit(0 if all(x['status']=='COMPLETE_FIELDS_RAW_DIAGNOSTIC_PASS' for x in rows) else 1)
