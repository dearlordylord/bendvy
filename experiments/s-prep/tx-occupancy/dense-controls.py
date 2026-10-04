#!/usr/bin/env python3
from replay import ROOT,HERE,R,P,metrics,check,load
import pathlib,tempfile,json,hashlib,gzip
D=load('dense_prepare_controls',HERE/'prepare-dense.py');C=load('chunk_controls',HERE/'prepare-chunks.py')
evidence=json.loads((HERE/'dense-evidence.json').read_text());case=evidence['cases'][0];assert (case['schema'],case['workload'],case['count'])==('Health','dense',256);reference=case['backends']['JS'];assert reference['status']=='PASS'
subjects={'inverse-zero':('Nat.show(List.length(&2,Inverse<H>,undo))','Nat.show(0n)'), 'marks-zero':('Nat.show(List.length(&2,H,marks))','Nat.show(0n)'), 'mark-drain-zero':('Nat.show(List.length(&2,S.Handle<Schema>,rest))','Nat.show(0n)'), 'reversed-records':('String.join(List.reverse(&2,String,meter),"")','String.join(meter,"")')};results=[]
with tempfile.TemporaryDirectory(prefix='prep22-dense-controls-') as directory:
 root=pathlib.Path(directory);dest=R.materialize(root);P.prepare(dest);D.prepare(dest);C.prepare(dest);entry=dest/'measurement-bend.bend';assert {str(pathlib.Path(p).relative_to(root)):h for p,h in R.closure(entry).items()}==evidence['sources']['dense-diagnostic'];p=dest/'transaction.bend';original=p.read_text()
 for name,(old,new) in subjects.items():
  assert old in original;p.write_text(original.replace(old,new));record={'name':name,'sourceSha256':hashlib.sha256(p.read_bytes()).hexdigest()}
  try:
   assert 'ALL PROOFS CHECK' in ''.join(R.run(['taskset','-c','8','bend',entry,'--check-only']));js=root/(name+'.js');R.run(['taskset','-c','8','bend',entry,'-o',js],30);text=R.run(['taskset','-c','8','node',js,'1','0','256'])[0];public=json.loads('\n'.join(l for l in text.splitlines() if not l.startswith('txdiag:')));public.pop('milliseconds');assert hashlib.sha256(json.dumps(public,separators=(',',':')).encode()).hexdigest()==reference['publicSha256'],'public semantic fields changed'
   try:check(metrics(text),'dense')
   except AssertionError as exc:record.update(status='DETECTED',oracleFailure=str(exc),fullPublicMatch=True,generatedJsSha256=hashlib.sha256(js.read_bytes()).hexdigest())
   else:record.update(status='SURVIVED',fullPublicMatch=True)
  except Exception as exc:record.update(status='INVALID_OR_UNAVAILABLE',error=str(exc))
  results.append(record);print(name,record['status'],flush=True)
(HERE/'dense-mutation-evidence.json').write_text(json.dumps(results,indent=2)+'\n')
assert all(r['status']=='DETECTED' for r in results)
# Independent raw verification, including both backends and actual peak locations.
points=0
for case in evidence['cases']:
 values=[]
 for backend,v in case['backends'].items():
  if v['status']!='PASS':continue
  packed=(HERE/v['rawRecords']).read_bytes();assert hashlib.sha256(packed).hexdigest()==v['rawSha256'];raw=gzip.decompress(packed);records=[json.loads(l) for l in raw.splitlines()];actual=check(records,'dense');assert actual['physicalPeaks']==v['physicalPeaks'];v['peakLocations']=actual['peakLocations'];v['diagnosticPoints']=sum(len(t) for t in records);points+=v['diagnosticPoints'];values.append(raw)
 if len(values)==2:assert values[0]==values[1];case['physicalBackendEquality']=True
evidence['verifiedDiagnosticPoints']=points;(HERE/'dense-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');print('PASS raw',points)
