"""Check retained finite source/archive/raw joins without tools or runtime claims."""
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
OUT = H / 'delivery-adoption-source-v1'
sha = lambda data: hashlib.sha256(data).hexdigest()
manifest = json.loads((OUT / 'manifest.json').read_text())
assert not any(manifest[k] for k in ['completeIssue49', 'proofCredit',
                                    'runtimeQualified', 'productionAdopted'])
for name, digest in manifest['source'].items():
    assert sha((H / name).read_bytes()) == digest
assert sha((OUT / 'REPORT.md').read_bytes()) == manifest['reportSHA256']
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
assert receipt['status'] == 'PROPOSED_HANDLER_EXTRACTION_SEVEN_SOURCE_CONTROLS_PASS_NO_RUNTIME'
assert receipt['probeCommandsExecuted'] == 75
assert len(receipt['commands']) == len(plan['commands']) == 7
for relative, digest in plan['inventory'].items():
    assert sha(members['stage/' + relative]) == digest
for relative, binding in plan['sourceMapping'].items():
    assert sha(members['stage/' + relative]) == binding.get('proposedSHA256', binding['sha256'])
    assert plan['pins'][binding['original']] == binding['sha256']
for path, digest in receipt['probePins'].items():
    relative = Path(path).relative_to(a['historicalDirectory'])
    assert sha(members[str(relative)]) == digest
for name, digest in receipt['logs'].items():
    assert sha(members[name]) == digest
for command, result in zip(plan['commands'], receipt['commands']):
    assert result['failure'] is None and result['exit'] == command['expected']
    stdout = members[command['label'] + '.stdout']
    stderr = members[command['label'] + '.stderr']
    if command['expected'] == 0:
        assert not stderr and len(stdout) == 58
        assert sha(stdout) == command['expectedStdoutSHA256']
    else:
        assert not stdout and sha(stderr) == command['expectedStderrSHA256']
        assert all(part.encode() in stderr for part in command['diagnostic'])
print('FINITE_PROPOSED_EXTRACTION_SEVEN_SOURCE_CONTROLS_ARCHIVE_VERIFIED_NO_RUNTIME')
