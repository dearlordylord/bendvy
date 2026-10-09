"""No-child lossless complete ordinary-handler actual JS evidence verification."""
import gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('handler_parser',HERE/'parse-handlers.py');P=importlib.util.module_from_spec(s);s.loader.exec_module(P)
sha=lambda raw:hashlib.sha256(raw).hexdigest()
manifest=json.loads((HERE/'JS-EVIDENCE-MANIFEST.json').read_text());by_source={}
for row in manifest['members']:
 path=HERE/row['archive'];assert path.is_file()and not path.is_symlink();compressed=path.read_bytes();assert sha(compressed)==row['archiveSHA256'];raw=gzip.decompress(compressed);assert len(raw)==row['bytes']and sha(raw)==row['sha256'];assert row['source']not in by_source;by_source[row['source']]=raw
assert {str(p.relative_to(HERE))for p in (HERE/'js-evidence-v2').rglob('*.gz')}=={r['archive']for r in manifest['members']}
results=json.loads((HERE/'JS-EXECUTION-RESULT.json').read_text());actuals={}
for kind,ids in [('normal','main-identities.json'),('mutant','drop-handlers-identities.json')]:
 root=Path('/tmp/bendvy56-handler-'+kind+'-js-v2');get=lambda name:by_source[str(root/name)];plan_raw=get('plan.json');plan=json.loads(plan_raw);receipt=json.loads(get('receipt.json'));summary=results['cohorts'][kind]
 assert sha(plan_raw)==summary['planSHA256']==receipt['planSHA256'];assert receipt['status']=='DEVELOPMENT_PASS'and not receipt.get('error')and not receipt.get('guardFailures')
 assert len(receipt['commands'])==2 and len(receipt['guards'])==7
 expected=dict(plan['pins']);expected[str(root/'plan.json')]=sha(plan_raw)
 rows={c['label']:c for c in receipt['commands']};assert set(rows)=={'emit','consumer'}
 for command,row in zip(plan['commands'],receipt['commands']):
  assert all(row[k]==v for k,v in command.items())and row['exit']==0 and row['failure']is None
  assert row['argv'][:3]==['/usr/bin/taskset','-c','5']and row['capSeconds']==(30 if row['label']=='emit'else 5)
  assert row['runnerSHA256']==plan['pins']['/workspace/formal-proofs/bendvy/scripts/task_runner.py']
  for stream in ('stdout','stderr'):
   bound=row[stream];raw=by_source[bound['path']];assert sha(raw)==bound['sha256']and len(raw)==bound['bytes']
  assert get(row['label']+'.stderr')==b''
 for index,label in enumerate(['emit-pre','emit-acquired','emit-post','consumer-pre','consumer-acquired','consumer-post','final']):
  if label=='emit-post':
   for stream in ('stdout','stderr'):expected[rows['emit'][stream]['path']]=rows['emit'][stream]['sha256']
   expected[plan['generated']]=receipt['generatedSHA256'];assert sha(by_source[plan['generated']])==receipt['generatedSHA256']
  if label=='consumer-post':
   for stream in ('stdout','stderr'):expected[rows['consumer'][stream]['path']]=rows['consumer'][stream]['sha256']
  bound=receipt['guards'][index];assert bound['path']==str(root/(label+'.guard.json'));raw=by_source[bound['path']];assert sha(raw)==bound['sha256'];guard=json.loads(raw);assert guard['label']==label and guard['unchanged']is True and guard['actualPins']==expected
 oracle=Path(plan['oracle']);assert sha(oracle.read_bytes())==plan['expectedSHA256'];join=json.loads(Path(plan['join']).read_text());inventory=json.loads((HERE/ids).read_text());raw=get('consumer.stdout').decode();value=P.normalize(raw,inventory,join);P.BASE.strict_equal(value,json.loads(oracle.read_text()));actuals[kind]=value
 assert sha(raw.encode())==summary['rawSHA256']and len(raw.encode())==summary['rawBytes']
 if kind=='mutant':assert receipt['unchangedBaselineRejected']is True
assert actuals['normal']['Reported']['report']['previous']==actuals['mutant']['Reported']['report']['previous']
P.BASE.strict_equal(actuals['normal'],json.loads(Path(json.loads(by_source['/tmp/bendvy56-handler-normal-js-v2/plan.json'])['oracle']).read_text()))
print(json.dumps({'actualCohorts':2,'completeModels':'PASS','members':len(manifest['members']),'guards':14,'scope':'JS development only; no Native/public56/performance qualification'},indent=2))
