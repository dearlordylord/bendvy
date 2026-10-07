"""Verify retained archive/raw/source hashes and diagnostic joins; no model recomputation or child tools."""
import hashlib
import io
import json
import tarfile
from pathlib import Path

import importlib.util

H = Path(__file__).resolve().parent
OUT = H / 'delivery-qualification-v1'
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
controls = json.loads(archives['ordinary-controls']['receipt.json'])
assert controls['status'] == 'ORDINARY_RESOLVER_CONTROLS_COMPLETE_DIAGNOSTICS_AND_PHYSICAL_JS_PASS'
assert len(controls['commands']) == 13 and controls['probeCommandsExecuted'] == 135
assert [c['exit'] for c in controls['commands']] == [0]*5 + [1]*4 + [0]*4
assert all(c['failure'] is None for c in controls['commands'])
classified = json.loads((H / 'authority-diagnostic-classification-v1.json').read_text())
for name, control in classified['controls'].items():
    raw = archives['ordinary-controls'][name + '-source.stderr']
    assert sha(raw) == control['rawStderrSHA256']
    assert not archives['ordinary-controls'][name + '-source.stdout']
for name, digest in controls['logs'].items():
    assert sha(archives['ordinary-controls'][name]) == digest
native = json.loads(archives['native-emission']['receipt.json'])
assert native['status'] == 'WHOLE_MARKER_SCHEMA_A_EMISSION_PASS_NO_NATIVE_RUN'
assert len(native['commands']) == 2 and native['probeCommandsExecuted'] == 25
assert all(c['exit'] == 0 and c['failure'] is None for c in native['commands'])
assert sha(archives['native-emission']['whole-marker-schema-a.c']) == '3baf3905b11c6bd9af28d9d4080a420d7277cc86aebdfdb1909d418cb8867dbd'
print(json.dumps({'status': 'LOSSLESS_ORDINARY13_AND_NATIVE_EMISSION2_VERIFIED',
                  'completeIssue49': False, 'proofCredit': False}))
