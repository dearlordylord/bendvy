"""Verify archived full Native source/C/raw joins without child tools or proof claims."""
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
OUT = H / 'delivery-adoption-native-v1'
sha = lambda data: hashlib.sha256(data).hexdigest()
manifest = json.loads((OUT / 'manifest.json').read_text())
assert not any(manifest[k] for k in ['completeIssue49', 'proofCredit', 'productionAdopted',
                                    'mutationQualified', 'performanceQualified'])
for name, digest in manifest['source'].items():
    assert sha((H / name).read_bytes()) == digest
assert sha((OUT / 'REPORT.md').read_bytes()) == manifest['reportSHA256']
for kind in ['source', 'js']:
    blob = (H / f'delivery-adoption-{kind}-v1/manifest.json').read_bytes()
    assert sha(blob) == manifest[kind + 'CapsuleManifestSHA256']
jsManifest = json.loads((H / 'delivery-adoption-js-v1/manifest.json').read_text())
jsBlob = (H / 'delivery-adoption-js-v1' / jsManifest['archive']['name']).read_bytes()
assert sha(jsBlob) == jsManifest['archive']['sha256']
with tarfile.open(fileobj=io.BytesIO(jsBlob), mode='r:gz') as tar:
    jsPlan = json.load(tar.extractfile('plan.json'))
archives = {}
for label, a in manifest['archives'].items():
    blob = (OUT / a['archive']).read_bytes()
    assert sha(blob) == a['sha256']
    with tarfile.open(fileobj=io.BytesIO(blob), mode='r:gz') as tar:
        assert set(tar.getnames()) == set(a['members'])
        members = {}
        for name, recorded in a['members'].items():
            assert 'private-environment' not in name
            data = tar.extractfile(name).read()
            assert sha(data) == recorded['sha256'] and len(data) == recorded['bytes']
            members[name] = data
    archives[label] = members
    plan = json.loads(members['plan.json'])
    receipt = json.loads(members['receipt.json'])
    assert receipt['planSHA256'] == sha(members['plan.json'])
    assert receipt['probeCommandsExecuted'] == (65 if label == 'normal' else 35)
    assert len(receipt['commands']) == (6 if label == 'normal' else 3)
    assert all(c['exit'] == 0 and c['failure'] is None for c in receipt['commands'])
    for relative, digest in plan['inventory'].items():
        assert sha(members['stage/' + relative]) == digest
    for relative, digest in jsPlan['inventory'].items():
        assert sha(members['stage/' + relative]) == digest
    for path, digest in jsPlan['pins'].items():
        assert plan['pins'][path] == digest
    for path, digest in receipt['probePins'].items():
        assert sha(members[str(Path(path).relative_to(a['historicalDirectory']))]) == digest
    for path, digest in receipt['generated'].items():
        if Path(path).suffix == '.c':
            assert sha(members[str(Path(path).relative_to(a['historicalDirectory']))]) == digest
    for name, digest in receipt['logs'].items():
        assert sha(members[name]) == digest
    assert all(not members[c['label'] + '.stderr'] for c in plan['commands'])
f = 'stage/experiments/public-machine-handlers/candidate-v1/'
normal = archives['normal']
expected = json.loads(normal[f + 'full-expected.json'])['bend']
names = [f'schema{s}_{phase}{position}{suffix}' for s in ['A', 'B']
         for phase in ['exit', 'transition', 'enter'] for position in [0, 1]
         for suffix in ['', '_missing']]
assert set(names) == set(expected)
for schema in ['A', 'B']:
    wanted = ('\n'.join(n + '|[' + ', '.join(expected[n]) + ']' for n in names
                        if n.startswith('schema' + schema + '_')) + '\n').encode()
    assert normal['schema-' + schema.lower() + '-run.stdout'] == wanted
wanted = ('\n'.join(n + '|[' + ', '.join(expected[n]) + ']' for n in names) + '\n').encode()
assert normal['full96-and12-union.stdout'] == wanted
assert normal['schema-a-run.stdout'] + normal['schema-b-run.stdout'] == wanted
nr = json.loads(normal['receipt.json'])
assert nr['status'] == 'PROPOSED_HANDLER_EXTRACTION_NORMAL_NATIVE_FULL96_AND12_UNION_PASS'
assert nr['unionSHA256'] == sha(wanted)
foreign = archives['foreign']
fr = json.loads(foreign['receipt.json'])
assert fr['status'] == 'PROPOSED_HANDLER_EXTRACTION_NATIVE_FOREIGN_TWO_SCHEMAS_COMPLETE7_ROWS_EACH_PASS'
expected = json.loads(foreign[f + 'full-foreign-expected.json'])
assert set(expected) == {'schemaA', 'schemaB'} and all(len(v) == 7 for v in expected.values())
assert foreign['foreign-run.stdout'] == ('\n'.join(expected['schemaA'] + expected['schemaB']) + '\n').encode()
assert sha(foreign[f + 'full-foreign-native.bend']) == manifest['source']['full-foreign-native.bend']
print('FINITE_RELOCATED_HANDLER_NATIVE_FULL96_AND12_PLUS_FOREIGN14_BYTE_JOINS_VERIFIED')
