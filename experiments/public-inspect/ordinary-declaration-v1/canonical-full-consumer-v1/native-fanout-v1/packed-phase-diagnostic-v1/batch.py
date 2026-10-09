"""Execute exactly admitted diagnostic DAG once, through unchanged owned-child runner."""
import hashlib,json,runpy,sys
from pathlib import Path
root=Path(__file__).resolve().parent
manifest=root/'BATCH.json';expected=sys.argv[1]
assert hashlib.sha256(manifest.read_bytes()).hexdigest()==expected
batch=json.loads(manifest.read_text());out=root/'batch-receipt.json'
assert not out.exists() and not out.is_symlink()
record={'scope':batch['scope'],'batchSHA256':expected,'cohorts':[],'full47':'HELD_UNATTEMPTED'}
try:
    for row in batch['cohorts']:
        planpath=Path(row['plan']);assert hashlib.sha256(planpath.read_bytes()).hexdigest()==row['sha256']
        record['cohorts'].append({'name':row['name'],'state':'COHORT_ENTERED','planSHA256':row['sha256']})
        if row['name']=='full47':record['full47']='COHORT_ENTERED; terminal receipt determines actual child attempt'
        sys.argv=[str(root/'collect.py'),str(planpath),row['sha256']]
        runpy.run_path(str(root/'collect.py'),run_name='__main__')
        receipt=json.loads((planpath.parent/'receipt.json').read_text())
        assert receipt['status']=='PACKED_COMPILER_DIAGNOSTIC_PASS'
        record['cohorts'][-1].update({'state':'DIAGNOSTIC_PASS','receipt':str(planpath.parent/'receipt.json'),'receiptSHA256':hashlib.sha256((planpath.parent/'receipt.json').read_bytes()).hexdigest(),'compilerOutcome':receipt['compilerOutcome']})
        if row['name']=='full47':record['full47']='ATTEMPTED_DIAGNOSTIC_ONLY'
    record['status']='DIAGNOSTIC_BATCH_PASS'
except BaseException as error:
    record['status']='INCOMPLETE';record['failure']=type(error).__name__+': '+str(error)
    if record['cohorts']:
        current=record['cohorts'][-1];current['state']='INCOMPLETE'
        failed=Path(batch['cohorts'][len(record['cohorts'])-1]['plan']).parent/'receipt.json'
        if failed.is_file():
            current['receipt']=str(failed);current['receiptSHA256']=hashlib.sha256(failed.read_bytes()).hexdigest()
            fact=json.loads(failed.read_text())
            attempted=any(c['label']=='source-copy-emit' for c in fact.get('commands',[]))
            if current['name']=='full47':record['full47']='ATTEMPTED_DIAGNOSTIC_INCOMPLETE' if attempted else 'HELD_UNATTEMPTED; pre-child refusal'
    raise
finally:
    with out.open('x') as stream:json.dump(record,stream,indent=2);stream.write('\n')
