"""Portable #58 Native development supplement verification; no backend launch."""
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
BASE = HERE.parent

def read_archive(path, index):
    result = {}
    with tarfile.open(fileobj=io.BytesIO(path.read_bytes()), mode='r:gz') as archive:
        for member in archive:
            assert member.isfile() and not member.name.startswith('/') and '..' not in Path(member.name).parts
            assert member.name not in result
            result[member.name] = archive.extractfile(member).read()
    assert result.keys() == index.keys()
    assert {name: hashlib.sha256(data).hexdigest() for name, data in result.items()} == index
    return result

def main():
    selected = json.loads((HERE / 'FILES.json').read_bytes())
    for name, digest in selected['files'].items():
        assert hashlib.sha256((HERE / name).read_bytes()).hexdigest() == digest
    spec = importlib.util.spec_from_file_location('snapshot_development', BASE / 'verify-development.py')
    previous = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(previous)
    previous.main()
    contents = read_archive(HERE / 'evidence.tar.gz', json.loads((HERE / 'index.json').read_bytes())['members'])
    prior = read_archive(BASE / 'development-evidence.tar.gz', json.loads((BASE / 'development-evidence-index.json').read_bytes())['members'])
    receipt = json.loads(contents['receipt.json'])
    js = json.loads(prior['development/js-direct-v2/receipt.json'])
    assert receipt['status'] == 'DEVELOPMENT_PASS' and not receipt.get('guardFailures')
    assert receipt['exactFullJsOutputMatch'] is True
    assert receipt['environment']['BEND_NO_TELEMETRY'] == '1'
    assert receipt['environment']['BENDVY_CLANG19_ROOT'] == '/tmp/bendvy-clang19-diagnostic/root'
    assert [row['label'] for row in receipt['commands']] == ['emit', 'build', 'consumer']
    assert [row['capSeconds'] for row in receipt['commands']] == [30, 120, 5]
    for command in receipt['commands']:
        assert command['exit'] == 0 and command['failure'] is None
        assert command['argv'][:3][-2:] == ['-c', '5']
        for name in ('stdout', 'stderr'):
            stream = command[name]
            content = contents[Path(stream['path']).name]
            assert hashlib.sha256(content).hexdigest() == stream['sha256'] and len(content) == stream['bytes']
        assert contents[Path(command['stderr']['path']).name] == b''
    assert receipt['commands'][1]['argv'][3] == '/tmp/bendvy-clang19-diagnostic/clang19'
    assert receipt['commands'][1]['argv'][4] == '-O3'
    assert receipt['commands'][1]['argv'][-2:] == ['-pthread', '-lm']
    assert receipt['commands'][2]['argv'][-4:] == ['--threads', '1', '--gpu', 'off']
    basis = json.loads((HERE / 'authorized-command-basis.json').read_bytes())
    assert [row['capSeconds'] for row in basis] == [30, 120, 5]
    assert basis[1]['argv'][3:5] == receipt['commands'][1]['argv'][3:5]
    assert basis[1]['argv'][-2:] == receipt['commands'][1]['argv'][-2:]
    assert basis[2]['argv'][-4:] == receipt['commands'][2]['argv'][-4:]
    actual = contents['consumer.stdout']
    assert actual == prior['development/js-direct-v2/consumer.stdout']
    expected = json.loads((BASE / 'independent-oracle-v2.json').read_bytes())
    previous.same(json.loads(actual), expected)
    assert receipt['completeOracleSHA256'] == '9682fe82bd7aa2cc54c9b6feb731616497231a6e8a8065fc7a40f1c68d4d9bcf'
    native_sources = receipt['sourceStage']['sources']
    assert {row['source']: row['sourceSHA256'] for row in native_sources} == {
        row['source']: row['sourceSHA256'] for row in js['sourceStage']['sources']}
    assert len(native_sources) == 23 and len(receipt['sourceStage']['importJoins']) == 82
    for row in native_sources:
        assert hashlib.sha256(contents['sources/' + Path(row['copy']).name]).hexdigest() == row['copySHA256']
    print('PASS: Native development whole oracle and byte-identical JS, same sources; no full delivery/tool/performance qualification')

if __name__ == '__main__':
    main()
