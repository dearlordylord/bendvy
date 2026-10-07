"""Read-only complete control evidence verification; no backend/probe execution."""
import gzip,hashlib,io,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;D=H/'delivery-controls-v1';sha=lambda b:hashlib.sha256(b).hexdigest()
m=json.loads((D/'manifest.json').read_text());assert not any(m[k] for k in ['completeIssue49','acceptanceQualified','performanceQualified','proofCredit'])
assert sha((D/'REPORT.md').read_bytes())==m['reportSHA256']
for name,digest in m['source'].items():assert sha((H/name).read_bytes())==digest,name
runs={}
for name,record in m['archives'].items():
 blob=(D/record['archive']).read_bytes();assert sha(blob)==record['sha256'];files={}
 with tarfile.open(fileobj=io.BytesIO(gzip.decompress(blob)),mode='r:') as tar:
  for member in tar:
   assert member.isfile() and not member.name.startswith('/') and '..' not in Path(member.name).parts
   assert member.name not in files and 'private-environment' not in member.name
   raw=tar.extractfile(member).read();files[member.name]=raw;assert record['members'][member.name]=={'sha256':sha(raw),'bytes':len(raw)}
 assert set(files)==set(record['members']);runs[name]=files
 receipt=json.loads(files['receipt.json']);assert receipt['planSHA256']==sha(files['plan.json'])
 for label,digest in receipt['logs'].items():assert sha(files[label])==digest
 for path,digest in receipt.get('probePins',{}).items():assert sha(files[str(Path(path).relative_to(record['historicalDirectory']))])==digest
source=json.loads(runs['positive-source']['receipt.json']);assert all(c['exit']==0 and c['failure'] is None for c in source['commands']) and len(source['commands'])==2
foreign=runs['foreign-js'];receipt=json.loads(foreign['receipt.json']);assert all(c['exit']==0 and c['failure'] is None for c in receipt['commands']) and len(receipt['commands'])==2
actual=json.loads(foreign['consume.stdout']);expected=json.loads((H/'full-foreign-expected.json').read_text());assert actual==expected
assert set(actual)=={'schemaA','schemaB'} and all(len(rows)==7 for rows in actual.values())
assert sha(foreign['foreign.mjs'])=='14833e44f34e855437112c427b0c6f1d8c6df183031e0a19dc61acd1adb73bdb'
negative=runs['negative-diagnostics'];receipt=json.loads(negative['receipt.json']);assert receipt['status']=='FOUR_AUTHORITY_NONZERO_DIAGNOSTICS_RETAINED_UNCLASSIFIED' and all(c['exit']==1 and c['failure'] is None for c in receipt['commands']) and len(receipt['commands'])==4
classified=json.loads((H/'authority-diagnostic-classification-v1.json').read_text());assert classified['collectorReceiptSHA256']==sha(negative['receipt.json']) and not classified['acceptanceQualified'] and not classified['proofCredit']
assert classified['positiveSiblingReceiptSHA256']==sha(runs['positive-source']['receipt.json'])
positive=(H/'full-authority-positive.bend').read_text()
for name,item in classified['controls'].items():
 raw=negative[name+'-source-check.stderr'];assert sha(raw)==item['rawStderrSHA256'] and all(snippet in raw.decode() for snippet in item['intendedErrorSnippets'])
 assert sha(negative[name+'-source-check.stdout'])==item['rawStdoutSHA256']
 assert sha((H/('full-negative-'+name+'.bend')).read_bytes())==item['sourceSHA256']
 assert 'def '+item['matchedPositiveDefinition']+'(' in positive
failed=runs['computed-match-failure'];receipt=json.loads(failed['receipt.json']);assert receipt['failedCommand']['exit']==1 and receipt['failedCommand']['failure'] is None
assert 'a match cannot scrutinize a computed value' in failed['foreign-source-check.stderr'].decode()
print(json.dumps({'status':'LOSSLESS_COMPLETE_FOREIGN_AND_CLASSIFIED_AUTHORITY_CAPSULE_PASS','schemas':2,'foreignRowsPerSchema':7,'exactIntendedSourceRefusals':4,'acceptanceQualified':False,'proofCredit':False}))
