"""Read/hash archived complete independent caller JSON and source joins; no children."""
import hashlib
import io
import json
import tarfile
from pathlib import Path
H = Path(__file__).resolve().parent
sha = lambda b: hashlib.sha256(b).hexdigest()
OUT = H/'delivery-v1'; m=json.loads((OUT/'manifest.json').read_text())
assert all(not m[k] for k in ['completeIssue49','proofCredit','nativeQualified','productionAdopted','performanceQualified'])
for n,h in m['source'].items(): assert sha((H/n).read_bytes())==h
assert sha((OUT/'REPORT.md').read_bytes())==m['reportSHA256']
a=m['archive'];blob=(OUT/a['name']).read_bytes();assert sha(blob)==a['sha256'];d={}
with tarfile.open(fileobj=io.BytesIO(blob),mode='r:gz') as t:
    assert set(t.getnames())==set(a['members'])
    for n,item in a['members'].items():
        assert 'private-environment' not in n
        data=t.extractfile(n).read();assert sha(data)==item['sha256'] and len(data)==item['bytes'];d[n]=data
p=json.loads(d['plan.json']);r=json.loads(d['receipt.json'])
assert sha(d['plan.json'])==m['planSHA256']==r['planSHA256'] and sha(d['receipt.json'])==m['receiptSHA256']
assert r['status']=='INDEPENDENT_CALLER_FOURTEEN_COMPLETE_JS_OBSERVATIONS_PASS'
assert len(r['commands'])==len(p['commands'])==2 and r['probeCommandsExecuted']==25
assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
for n,h in p['inventory'].items(): assert sha(d['stage/'+n])==h
assert {n[6:] for n in d if n.startswith('stage/')}==set(p['inventory'])
expected_probes={str(Path(a['historicalDirectory'])/'execution-probes'/(label+suffix)) for label in p['executionProbeLabels'] for suffix in ['.json','.stdout','.stderr']}
assert len(p['executionProbeLabels'])==25 and set(r['probePins'])==expected_probes
for path,h in r['probePins'].items(): assert sha(d[str(Path(path).relative_to(a['historicalDirectory']))])==h
assert set(r['logs'])=={c['label']+suffix for c in p['commands'] for suffix in ['.stdout','.stderr']}
for n,h in r['logs'].items():assert sha(d[n])==h
assert not d['caller-emit.stderr'] and not d['caller-consume.stderr']
for path,h in r['generated'].items():assert sha(d[str(Path(path).relative_to(a['historicalDirectory']))])==h
fixture='stage/experiments/public-machine-handlers/candidate-v1/public-caller-v1/'
expected=json.loads(d[fixture+'expected-draft.json'])['rows'];observed=json.loads(d['caller-consume.stdout'])
assert len(expected)==len(observed)==14 and observed==expected
review=json.loads((H/'source-review-manifest.json').read_text())
assert p['sourceReviewManifestSHA256']==sha((H/'source-review-manifest.json').read_bytes())
for n,h in review['stageClosure'].items():assert sha(d['stage/'+n])==h
for n in ['types.bend','world.bend','systems.bend','application.bend','main.bend','consumer.mjs','expected-draft.json']:
    assert d[fixture+n]==(H/n).read_bytes()
for schema in ['A','B']:
    retry=observed[schema+'_retry'];refused=observed[schema+'_missing_reader']
    assert retry['publications']==refused['publications']==[['Boot','Play']]
    assert refused['deliveries']==[] and refused['registryCursors'][-1]==0 and refused['streamReader'] is None
    assert observed[schema+'_condition_false']==observed[schema+'_initial']
print('FINITE_INDEPENDENT_CALLER_FOURTEEN_JS_JSON_AND_SOURCE_BYTE_JOINS_VERIFIED')
