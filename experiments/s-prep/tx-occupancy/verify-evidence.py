#!/usr/bin/env python3
"""Verify committed raw owner records without rerunning workloads or inferring missing cells."""
from replay import HERE,ROOT,R,check
import gzip,json,hashlib,pathlib
p=HERE/'evidence.json';e=json.loads(p.read_text());total=0;physical=0;passed=0
for case in e['cases']:
 values=[]
 for backend,result in case['backends'].items():
  if result['status']!='PASS':continue
  validation=result['freshTSValidation']
  if 'completeValidationFile' in validation:
   packed=(HERE/validation['completeValidationFile']).read_bytes();assert hashlib.sha256(packed).hexdigest()==validation['completeValidationSha256'];full=json.loads(gzip.decompress(packed));assert full['status']=='FULL_VALUES_EQUAL';assert all(full[k]==v for k,v in validation.items() if k not in ['completeValidationFile','completeValidationSha256'])
  raw=(HERE/result['rawRecords']).read_bytes();assert hashlib.sha256(raw).hexdigest()==result['rawSha256'];data=gzip.decompress(raw);records=[json.loads(line) for line in data.splitlines()];measured=check(records,case['workload']);assert measured['physicalPeaks']==result['physicalPeaks'] and measured['transactions']==result['transactions'];result['peakLocations']=measured['peakLocations'];result['verifiedDiagnosticPoints']=sum(len(t) for t in records);result['verifiedPhysicalRecords']=sum(bool(point['counts']) for t in records for point in t);total+=result['verifiedDiagnosticPoints'];physical+=result['verifiedPhysicalRecords'];passed+=1;values.append(data)
 if len(values)==2:assert values[0]==values[1];case['physicalBackendEquality']=True
assert passed==20,(passed,e['cases'])
e['verifiedDiagnosticPoints']=total;e['verifiedPhysicalRecords']=physical;e['verifiedBackendCases']=passed;e['unavailable']={'FailedTxn1024':'Both schemas, both backends: diagnostic full-public replay and independently attempted uninstrumented verbose baseline exceed the unchanged 5s deadline. No validated peak is inferred from partial execution. See deadline-classification.json and quiet attempts.','DenseSparseLifecycle':'Actual workload metric transport untested. Dense/Sparse require the copied measurement-bend IO completion to transport the existing generic meter through diag_strip, followed by unchanged full workload validators on all schemas/sizes/backends. Lifecycle requires actual world-command owner hooks at its direct deferred-command staging/barrier path; no Tx fixture is substituted.','cachedTxSizes':'The actual Tx representation has ordinary List fields and no cached size fields. Physical traversals are checked against independent append/drain transition counts; no cached size measurement is invented.','afterOwnerRetirement':'Commit transfers command/event owners and failure discards staging. Terminal records identify retirement without claiming an inspected empty active Tx owner. Post-transfer world/log occupancy remains a distinct inspection gate.'}
p.write_text(json.dumps(e,indent=2)+'\n')
# Keep only reachable modified baseline sources and verify every frozen file against the executed closure.
closure=e['sources']['readers-diagnostic'];overlay=HERE/'overlay'
for file in list(overlay.glob('*.bend')):
 key='experiments/s-integrate/'+file.name
 if key not in closure:file.unlink();continue
 assert hashlib.sha256(file.read_bytes()).hexdigest()==closure[key],file
pins=json.loads((ROOT/'.references/sources.json').read_text())['sources'];actual={}
for name in ['bevy-ts','bevy','bend2']:
 commit=R.run(['git','-C',pathlib.Path('/workspace/formal-proofs/bendvy/.references')/name,'rev-parse','HEAD'])[0].strip();assert commit==pins[name]['commit'];actual[name]=commit
provenance={'environment':e['environment'],'sourceCommit':e['sourceCommit'],'referencePins':actual,'frozenModifiedSources':{f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in overlay.glob('*.bend')},'replaySources':{f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in HERE.glob('*.py')},'rawDiagnosticPoints':total,'rawPhysicalRecords':physical,'passingBackendCases':passed,'limits':e['limits'],'cpu':e['cpu']}
(HERE/'source-provenance.json').write_text(json.dumps(provenance,indent=2)+'\n');print('PASS',passed,total,physical)
