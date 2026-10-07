"""Verify selected historical bytes and complete independent models; no child tools."""
import hashlib
import io
import json
import tarfile
from pathlib import Path

import importlib.util

H = Path(__file__).resolve().parent
OUT = H / 'delivery-mutants-v1'
sha = lambda data: hashlib.sha256(data).hexdigest()
manifest = json.loads((OUT / 'manifest.json').read_text())
assert not any(manifest[k] for k in ['completeIssue49', 'acceptanceQualified',
                                    'performanceQualified', 'proofCredit'])
for name, digest in manifest['source'].items():
    assert sha((H / name).read_bytes()) == digest, name
assert sha((OUT / 'REPORT.md').read_bytes()) == manifest['reportSHA256']
archives = {}
for label, archive in manifest['archives'].items():
    blob = (OUT / archive['archive']).read_bytes()
    assert sha(blob) == archive['sha256'], label
    with tarfile.open(fileobj=io.BytesIO(blob), mode='r:gz') as tar:
        assert set(tar.getnames()) == set(archive['members']), label
        members = {}
        for name, recorded in archive['members'].items():
            assert 'private-environment' not in name
            data = tar.extractfile(name).read()
            assert len(data) == recorded['bytes'] and sha(data) == recorded['sha256'], name
            members[name] = data
        archives[label] = members
spec = importlib.util.spec_from_file_location('mutant_model', H / 'full-mutant-oracle.py')
model = importlib.util.module_from_spec(spec)
spec.loader.exec_module(model)
members = archives['complete-js']
receipt = json.loads(members['receipt.json'])
assert receipt['status'] == 'THREE_COMPLETE96_AND12_VARIANTS_REACHED_BOTH_SCHEMA_SEMANTIC_WITNESSES'
assert len(receipt['commands']) == 6
assert all(c['exit'] == 0 and c['failure'] is None for c in receipt['commands'])
for variant in model.VARIANTS:
    expected = json.loads((H / ('full-mutant-' + variant + '-expected.json')).read_text())
    assert expected['bend'] == model.model(variant)
    raw = members[variant + '-consume.stdout']
    actual = json.loads(raw)
    assert actual['status'] == 'REACHED_COMPLETE_TWO_SCHEMA_SEMANTIC_MUTANT_KILLED'
    assert len(actual['observations']) == 24 and len(actual['witnesses']) == 2
    names = [f'schema{s}_{phase}{position}{suffix}' for s in ['A', 'B']
             for phase in ['exit', 'transition', 'enter'] for position in [0, 1]
             for suffix in ['', '_missing']]
    assert actual['observations'] == [name + '|[' + ', '.join(expected['bend'][name]) + ']'
                                      for name in names]
    assert sha(raw) == receipt['logs'][variant + '-consume.stdout']
    assert all(not members[variant + '-' + step + '.stderr'] for step in ['emit', 'consume'])
    assert {w['name'].split('_')[0] for w in actual['witnesses']} == {'schemaA', 'schemaB'}
    assert all(w['normal'] != w['actual'] for w in actual['witnesses'])
print(json.dumps({'status': 'LOSSLESS_THREE_FULL_VARIANT_MODELS_AND_WITNESSES_VERIFIED',
                  'archives': len(archives), 'completeVariants': 3,
                  'acceptanceQualified': False, 'proofCredit': False}))
