#!/usr/bin/env python3
"""Verify retained ordinary scope fixture evidence; execute no consumer or timing."""
import gzip
import hashlib
import json
import pathlib
import re
import zipfile

HERE = pathlib.Path(__file__).resolve().parent
LABELS = ['scopes-2-check', 'scopes-2-emit-JS', 'scopes-2-emit-Native', 'scopes-2-compile', 'scopes-2-semantic-TS', 'scopes-2-semantic-JS', 'scopes-2-semantic-Native']
BEND = '/home/node/.bend/bin/bend-2.0.35'
NODE = '/home/node/.local/share/mise/installs/node/24.20.0/bin/node'
CLANG = '/tmp/bendvy-clang19-diagnostic/clang19'
SHA = lambda data: hashlib.sha256(data).hexdigest()


def fnv(data):
    value = 2166136261
    for byte in data:
        value = ((value ^ byte) * 16777619) & 0xffffffff
    return value


def expected_commands(stage, output):
    entry = stage + '/stage/feature-harness/scopes-2.bend'
    return [
        (LABELS[0], [BEND, entry, '--check-only'], 5, 1),
        (LABELS[1], [BEND, entry, '-o', output + '/scopes-2.js'], 30, 0),
        (LABELS[2], [BEND, entry, '-o', output + '/scopes-2.c'], 30, 0),
        (LABELS[3], [CLANG, '-O3', output + '/scopes-2.c', '-o', output + '/scopes-2', '-pthread', '-lm'], 120, 0),
        (LABELS[4], [NODE, stage + '/stage/feature-harness/scopes-2.mjs'], 5, 0),
        (LABELS[5], [NODE, output + '/scopes-2.js'], 5, 0),
        (LABELS[6], [output + '/scopes-2', '--threads', '1', '--gpu', 'off'], 5, 0),
    ]


def check_success(receipt, stage, attempt, files, read, expected):
    assert receipt['status'] == 'PASS'
    assert receipt['stageReceiptSHA'] == SHA(read(stage['metadata']))
    assert receipt['features'] == ['scopes'] and receipt['repeatedLifecycles'] == 2
    assert receipt['childEnvironmentFixed'] == {'BEND_NO_TELEMETRY': '1'}
    commands = receipt['commands']
    assert [item['label'] for item in commands] == LABELS
    for item, (label, argv, cap, exit_code) in zip(commands, expected_commands(stage['path'], attempt['path'])):
        assert item == {'label': label, 'command': argv, 'cap': cap, 'exit': exit_code}
    logs = {label + suffix for label in LABELS for suffix in ['.stdout.gz', '.stderr']}
    assert set(receipt['logs']) == logs
    assert set(receipt['artifacts']) == {'scopes-2.js', 'scopes-2.c', 'scopes-2'}
    assert set(files) == logs | set(receipt['artifacts']) | {'receipt.json'}
    for name, digest in {**receipt['logs'], **receipt['artifacts']}.items():
        assert SHA(read(files[name])) == digest
    for tool in [BEND, NODE, CLANG]:
        assert tool in receipt['installedTools']['pins']
        assert re.fullmatch('[0-9a-f]{64}', receipt['installedTools']['pins'][tool])
    for label in LABELS:
        stdout = gzip.decompress(read(files[label + '.stdout.gz']))
        stderr = read(files[label + '.stderr'])
        if label == LABELS[0]:
            assert stdout == b''
            assert b'defs rely on unsafe or foreign code' in stderr and b'timing.capture' in stderr
            assert b'alias App shadows App.run' not in stderr
        elif label in LABELS[1:4]:
            assert stdout == b'' and stderr == b''
        else:
            assert stdout == expected
            region = json.loads(stderr)
            assert set(region) == {'elapsedNs', 'bytes', 'digest'}
            assert isinstance(region['elapsedNs'], str) and re.fullmatch('0|[1-9][0-9]*', region['elapsedNs'])
            assert type(region['bytes']) is int and region['bytes'] == len(expected)
            assert type(region['digest']) is int and region['digest'] == fnv(expected)
    assert len(json.loads(expected)) == 52 and len(expected) == 12932
    assert SHA(expected) == '3a9059f1d8bc5792e813fdd793a2859da60c7270c2a27ae1f6ce2247e825a833'


def verify(directory=HERE):
    directory = pathlib.Path(directory)
    delivery = json.loads((directory / 'DELIVERY.json').read_text())
    for name, digest in delivery['files'].items():
        assert SHA((directory / name).read_bytes()) == digest, name
    manifest = json.loads((directory / 'MANIFEST.json').read_text())
    result = json.loads((directory / 'RESULT.json').read_text())
    with zipfile.ZipFile(directory / 'EVIDENCE.zip') as archive:
        assert len(archive.namelist()) == len(set(archive.namelist()))
        assert set(archive.namelist()) == set(manifest['members'])
        contents = {name: archive.read(name) for name in archive.namelist()}
    for name, entry in manifest['members'].items():
        assert SHA(contents[name]) == entry['sha256'] and len(contents[name]) == entry['bytes']
    read = contents.__getitem__
    for stage in manifest['stages'].values():
        meta = json.loads(read(stage['metadata']))
        assert meta['scopes'] is True and meta['scales'] == [1, 2, 4]
        for metadata_key, binding_key in [('stageInventory', 'files'), ('sources', 'sources'), ('external', 'external')]:
            assert set(meta[metadata_key]) == set(stage[binding_key])
            for name, digest in meta[metadata_key].items():
                assert SHA(read(stage[binding_key][name])) == digest
    assert set(manifest['stages']) == set(manifest['attempts']) == {'attempt1', 'attempt2'}
    first = manifest['attempts']['attempt1']
    failed = json.loads(read(first['receipt']))
    assert first['outerExit'] == 1 and first['originalSession'] == 22204
    assert failed['status'] == 'INCOMPLETE' and failed['artifacts'] == {}
    assert failed['stageReceiptSHA'] == SHA(read(manifest['stages']['attempt1']['metadata']))
    label, argv, cap, exit_code = expected_commands(manifest['stages']['attempt1']['path'], first['path'])[0]
    assert failed['commands'] == [{'label': label, 'command': argv, 'cap': cap, 'exit': exit_code}]
    assert set(first['files']) == {'receipt.json', label + '.stdout.gz', label + '.stderr'}
    assert set(failed['logs']) == {label + '.stdout.gz', label + '.stderr'}
    for name, digest in failed['logs'].items():
        assert SHA(read(first['files'][name])) == digest
    assert gzip.decompress(read(first['files'][label + '.stdout.gz'])) == b''
    assert b'alias App shadows App.run' in read(first['files'][label + '.stderr'])
    oracle = manifest['oracle']
    generated = json.loads(read(oracle['GENERATED-HASHES.json']))
    for name, digest in generated.items():
        assert SHA(read(oracle[name])) == digest
    for scale, count in [(1, 26), (2, 52), (4, 104)]:
        assert len(json.loads(read(oracle[f'expected-scale-{scale}.stdout']))) == count
    second = manifest['attempts']['attempt2']
    assert second['outerExit'] == 0 and second['originalSession'] == 5492
    successful = json.loads(read(second['receipt']))
    assert second['files']['receipt.json'] == second['receipt']
    check_success(successful, manifest['stages']['attempt2'], second, second['files'], read, read(oracle['expected-scale-2.stdout']))
    assert result['comparisons'] == 0 and result['freshRun']['outerCPU'] == 3
    assert result['historicalAttempt']['status'] == 'INCOMPLETE'
    return {'status': 'PASS_RETAINED_SCOPE_FIXTURE_SEMANTICS_NOT_PERFORMANCE', 'members': len(contents), 'roles': 3, 'recordsPerRole': 52, 'bytesPerRole': 12932}


def selftest(directory=HERE):
    import copy
    directory = pathlib.Path(directory)
    manifest = json.loads((directory / 'MANIFEST.json').read_text())
    with zipfile.ZipFile(directory / 'EVIDENCE.zip') as archive:
        contents = {name: archive.read(name) for name in archive.namelist()}
    stage = manifest['stages']['attempt2']
    attempt = manifest['attempts']['attempt2']
    original = json.loads(contents[attempt['receipt']])
    expected = contents[manifest['oracle']['expected-scale-2.stdout']]
    check_success(original, stage, attempt, attempt['files'], contents.__getitem__, expected)
    cases = []
    def reject(name, mutate):
        receipt = copy.deepcopy(original)
        bodies = dict(contents)
        mutate(receipt, bodies)
        try:
            check_success(receipt, stage, attempt, attempt['files'], bodies.__getitem__, expected)
        except (AssertionError, KeyError, ValueError, TypeError):
            cases.append({'name': name, 'status': 'REJECTED'})
        else:
            raise AssertionError('Accepted invalid evidence: ' + name)
    reject('missing-consumer', lambda r, b: r['commands'].pop())
    reject('duplicate-command', lambda r, b: r['commands'].append(r['commands'][-1]))
    reject('reordered-commands', lambda r, b: r['commands'].reverse())
    reject('wrong-command-argv', lambda r, b: r['commands'][3]['command'].append('-O0'))
    reject('wrong-command-cap', lambda r, b: r['commands'][3].update(cap=121))
    reject('missing-published-stream', lambda r, b: r['logs'].pop(LABELS[-1] + '.stdout.gz'))
    reject('missing-native-artifact', lambda r, b: r['artifacts'].pop('scopes-2'))
    reject('wrong-stage-binding', lambda r, b: r.update(stageReceiptSHA='0' * 64))
    reject('wrong-lifecycle-count', lambda r, b: r.update(repeatedLifecycles=1))
    def clock(receipt, bodies, mutation):
        name = LABELS[-1] + '.stderr'
        member = attempt['files'][name]
        region = json.loads(bodies[member])
        mutation(region)
        bodies[member] = json.dumps(region).encode()
        receipt['logs'][name] = SHA(bodies[member])
    reject('missing-clock-value', lambda r, b: clock(r, b, lambda c: c.pop('elapsedNs')))
    reject('wrong-clock-digest', lambda r, b: clock(r, b, lambda c: c.update(digest=0)))
    reject('nondecimal-clock-value', lambda r, b: clock(r, b, lambda c: c.update(elapsedNs='1.5')))
    return {'status': 'PASS', 'scope': 'Retained verifier enforcement only; no compiler, consumer, comparison or profile', 'negativeControls': cases, 'count': len(cases)}


if __name__ == '__main__':
    import sys
    print(json.dumps(selftest() if '--selftest' in sys.argv[1:] else verify(), sort_keys=True))
