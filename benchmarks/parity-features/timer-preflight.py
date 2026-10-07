#!/usr/bin/env python3
"""Guarded finite timer protocol controls; no feature measurements."""
import argparse, gzip, hashlib, json, os, pathlib, shutil, subprocess
import preflight, supervise, importlib.util
from stage import inventory
ROOT = preflight.ROOT
HERE = pathlib.Path(__file__).resolve().parent

def fnv(data):
    value = 2166136261
    for byte in data:
        value = ((value ^ byte) * 16777619) & 0xffffffff
    return value

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--stage', type=pathlib.Path, required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    assert not args.output.exists()
    staged = json.loads((args.stage / 'stage.json').read_text())
    stage = args.stage / 'stage'
    source = stage / 'benchmarks/parity-features'
    args.output.mkdir(parents=True)
    tools = {name: pathlib.Path(shutil.which(name)).resolve() for name in ['bend', 'node', 'python3']}
    tools['clang'] = pathlib.Path('/tmp/bendvy-clang19-diagnostic/clang19').resolve()
    spec = importlib.util.spec_from_file_location('feature_tool_pins', HERE / 'tool-pins.py')
    tool_pins = importlib.util.module_from_spec(spec); spec.loader.exec_module(tool_pins)
    installed = tool_pins.snapshot()
    tool_hashes = {str(p): preflight.digest(p) for p in tools.values()}
    artifacts = {}
    receipt = {'status': 'INCOMPLETE', 'scope': 'Finite host timer/capture protocol only; no feature timing or performance verdict', 'stageReceiptSHA': preflight.digest(args.stage / 'stage.json'), 'tools': tool_hashes, 'installedToolResources': installed, 'logs': {}, 'commands': [], 'artifacts': artifacts}
    def guard():
        assert preflight.digest(args.stage / 'stage.json') == receipt['stageReceiptSHA'], 'Stage receipt drift'
        tool_pins.verify(installed)
        assert inventory(stage) == staged['stageInventory'], 'Staged input drift'
        assert preflight.snapshot() == staged['sources'], 'Live project input drift'
        assert preflight.external() == staged['external'], 'External source drift'
        assert all(preflight.digest(pathlib.Path(p)) == h for p, h in tool_hashes.items()), 'Tool drift'
        assert all(preflight.digest(args.output / p) == h for p, h in artifacts.items()), 'Artifact drift'
        assert all(preflight.digest(args.output / p) == h for p, h in receipt['logs'].items()), 'Log drift'
    def run(label, command, cap, good=True):
        guard()
        result = supervise.execute(list(map(str, command)), cap, dict(os.environ, BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root'))
        gzip.open(args.output / (label + '.stdout.gz'), 'wb').write(result.stdout)
        (args.output / (label + '.stderr')).write_bytes(result.stderr)
        for log in [label + '.stdout.gz', label + '.stderr']:
            receipt['logs'][log] = preflight.digest(args.output / log)
        receipt['commands'].append({'label': label, 'command': list(map(str, command)), 'cap': cap, 'exit': result.returncode})
        assert (result.returncode == 0) == good, (label, result.stderr)
        guard()
        return result
    def pin(path):
        artifacts[str(path.relative_to(args.output))] = preflight.digest(path)
    expected = '\nλ🙂\nline\n\x00tail\n'.encode('utf8')
    try:
        for name in ['bend', 'node', 'python3', 'clang']:
            run('version-' + name, [tools[name], 'version' if name == 'bend' else '--version'], 5)
        for subject in ['timer-controls', 'timer-negative']:
            checked = run(subject + '-check', [tools['bend'], source / (subject + '.bend'), '--check-only'], 5, False)
            assert b'defs rely on unsafe or foreign code' in checked.stderr, checked.stderr
            assert b'timing.capture' in checked.stderr, checked.stderr
            for backend in ['JS', 'Native']:
                emitted = args.output / (subject + ('.js' if backend == 'JS' else '.c'))
                assert not emitted.exists(), 'Prospective emit output already exists'
                run(subject + '-emit-' + backend, [tools['bend'], source / (subject + '.bend'), '-o', emitted], 30)
                pin(emitted)
                if backend == 'Native':
                    binary = args.output / subject
                    assert not binary.exists(), 'Prospective compiler output already exists'
                    run(subject + '-compile', [tools['clang'], '-O3', emitted, '-o', binary, '-pthread', '-lm'], 120)
                    pin(binary)
                    command = [binary, '--threads', '1', '--gpu', 'off']
                else:
                    command = [tools['node'], emitted]
                result = run(subject + '-run-' + backend, command, 5, subject != 'timer-negative')
                if subject == 'timer-negative':
                    assert b'feature timer protocol failure' in result.stderr or b'capture outside feature timer' in result.stderr
                else:
                    assert result.stdout == expected, (backend, result.stdout)
                    timer = json.loads(result.stderr)
                    assert timer['bytes'] == len(expected) and timer['digest'] == fnv(expected) and int(timer['elapsedNs']) >= 0
        result = run('timer-controls-TS', [tools['node'], source / 'timer-controls.mjs'], 5)
        assert result.stdout == expected
        timer = json.loads(result.stderr)
        assert timer['bytes'] == len(expected) and timer['digest'] == fnv(expected) and int(timer['elapsedNs']) >= 0
        guard()
        receipt.update(status='PASS', fullOutputHex=expected.hex(), bytes=len(expected), digest=fnv(expected), nativeThreads=1)
    finally:
        (args.output / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps({'status': receipt['status'], 'output': str(args.output)}))

if __name__ == '__main__':
    main()
