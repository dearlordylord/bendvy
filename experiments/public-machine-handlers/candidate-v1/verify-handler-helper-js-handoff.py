"""Verify retained actual JS/oracle/source byte joins; no tools, proof or Native claim."""
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
OUT = H / 'delivery-handler-helper-js-v1'
sha = lambda data: hashlib.sha256(data).hexdigest()
manifest = json.loads((OUT / 'manifest.json').read_text())
assert not any(manifest[k] for k in ['completeIssue49', 'proofCredit', 'productionAdopted',
                                    'nativeQualified', 'performanceQualified'])
for name, digest in manifest['source'].items():
    assert sha((H / name).read_bytes()) == digest
assert sha((OUT / 'REPORT.md').read_bytes()) == manifest['reportSHA256']
sourceManifest = (H / 'delivery-handler-helper-source-v1/manifest.json').read_bytes()
assert sha(sourceManifest) == manifest['sourceCapsuleManifestSHA256']
sm = json.loads(sourceManifest)
sourceBlob = (H / 'delivery-handler-helper-source-v1' / sm['archive']['name']).read_bytes()
assert sha(sourceBlob) == sm['archive']['sha256']
with tarfile.open(fileobj=io.BytesIO(sourceBlob), mode='r:gz') as tar:
    sourcePlan = json.load(tar.extractfile('plan.json'))
    sourceReceipt = json.load(tar.extractfile('receipt.json'))
a = manifest['archive']
blob = (OUT / a['name']).read_bytes()
assert sha(blob) == a['sha256']
with tarfile.open(fileobj=io.BytesIO(blob), mode='r:gz') as tar:
    assert set(tar.getnames()) == set(a['members'])
    members = {}
    for name, recorded in a['members'].items():
        assert 'private-environment' not in name
        data = tar.extractfile(name).read()
        assert sha(data) == recorded['sha256'] and len(data) == recorded['bytes']
        members[name] = data
plan = json.loads(members['plan.json'])
receipt = json.loads(members['receipt.json'])
assert receipt['planSHA256'] == sha(members['plan.json'])
assert receipt['status'] == 'STAGED_HANDLER_HELPERS_FULL96_AND12_PLUS_FOREIGN_JS_PASS'
assert receipt['probeCommandsExecuted'] == 45 and len(receipt['commands']) == 4
assert all(c['exit'] == 0 and c['failure'] is None for c in receipt['commands'])
for relative, digest in plan['inventory'].items():
    assert sha(members['stage/' + relative]) == digest
for relative, digest in sourcePlan['inventory'].items():
    assert sha(members['stage/' + relative]) == digest
assert sourceReceipt['status'] == 'DEVELOPMENT_HANDLER_HELPERS_SEVEN_SOURCE_DIAGNOSTICS_PASS_NO_FINAL_RESOLVER_OR_RUNTIME'
assert sourceReceipt['probeCommandsExecuted'] == 0
for path, digest in sourcePlan['pins'].items():
    assert plan['pins'][path] == digest
for path, digest in receipt['probePins'].items():
    assert sha(members[str(Path(path).relative_to(a['historicalDirectory']))]) == digest
for path, digest in receipt['generated'].items():
    assert sha(members[str(Path(path).relative_to(a['historicalDirectory']))]) == digest
for name, digest in receipt['logs'].items():
    assert sha(members[name]) == digest
assert all(not members[c['label'] + '.stderr'] for c in plan['commands'])
f = 'stage/experiments/public-machine-handlers/candidate-v1/'
expected = json.loads(members[f + 'full-expected.json'])['bend']
names = [f'schema{s}_{phase}{position}{suffix}' for s in ['A', 'B']
         for phase in ['exit', 'transition', 'enter'] for position in [0, 1]
         for suffix in ['', '_missing']]
assert set(names) == set(expected)
assert sum(len(expected[n]) for n in names if not n.endswith('_missing')) == 96
missing = [n for n in names if n.endswith('_missing')]
assert len(missing) == 12
assert all(len(expected[n]) == 4 and expected[n][-1] == 'status|MissingRuntimeRequirements'
           for n in missing)
wanted = {'observations': [n + '|[' + ', '.join(expected[n]) + ']' for n in names]}
assert json.loads(members['full96-and12-consume.stdout']) == wanted
foreign = json.loads(members[f + 'full-foreign-expected.json'])
assert set(foreign) == {'schemaA', 'schemaB'} and all(len(v) == 7 for v in foreign.values())
assert json.loads(members['foreign-two-schemas-consume.stdout']) == foreign
referencePrefix = 'historical-selected-reference/'
delivery = json.loads(members[referencePrefix + 'delivery-manifest.json'])
reference = members[referencePrefix + 'reference-v3.mjs']
selected = plan['selectedReference']
assert sha(reference) == selected['referenceSHA256'] == delivery['files']['experiments/public-machine-handlers/reference-v3.mjs']
assert sha(members[referencePrefix + 'delivery-manifest.json']) == selected['manifestSHA256']
portable = json.loads(members[referencePrefix + 'portable-reference-v1/manifest.json'])
assert sha(members[referencePrefix + 'portable-reference-v1/objects.tar.gz']) == portable['archive']['sha256']
print('FINITE_RELOCATED_HANDLER_FULL96_AND12_PLUS_FOREIGN_JS_BYTE_JOINS_VERIFIED_NO_NATIVE')
