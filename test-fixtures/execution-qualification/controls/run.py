"""Reviewed-only isolated orchestration controls for the unchanged collector."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import sys


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def check_case(name, case, result):
    require(result['exit'] != 0 or result['failure'] is not None, 'collector falsely accepted control')
    receipt_path = case / 'actual/receipt.json'
    if name == 'receipt-failure':
        require(receipt_path.is_dir(), 'publication obstruction was not reached')
        require(b'IsADirectoryError' in result['stderr'], 'publication error not propagated')
        for suffix, expected in (('.stdout', b'control stdout\n'), ('.stderr', b'control stderr\n')):
            require((case / 'actual/logs' / ('child-0' + suffix)).read_bytes() == expected,
                    'publication failure lost actual child raw stream')
        return {'innerReceipt': 'UNPUBLISHABLE', 'semanticVerdict': 'EXPECTED_REFUSAL'}
    receipt = json.loads(receipt_path.read_text())
    require(receipt['status'] == 'INCOMPLETE', 'false successful inner receipt')
    if name == 'cancel':
        identity = json.loads((case / 'child-identity.json').read_text())
        proc = Path('/proc') / str(identity['pid']) / 'stat'
        require(not proc.exists() or proc.read_text().rsplit(')', 1)[1].split()[19] != identity['start'],
                'owned cancelled child survived')
    errors = {'source-drift': 'frozen file changed', 'helper-drift': 'frozen file changed',
              'environment': 'environment differs', 'interpreter': 'interpreter differs', 'interpreter-flags': '-I -S -B',
              'wrong-approval': 'approval does not select', 'nonzero': 'unexpected command exit: 7',
              'artifact-drift': 'generated artifact bytes or membership changed',
              'input-drift': 'command input bytes or membership changed',
              'oracle': 'complete oracle differs', 'cancel': 'KeyboardInterrupt'}
    require(errors[name] in receipt.get('error', ''), 'wrong refusal boundary: ' + receipt.get('error', ''))
    if name in ('source-drift', 'helper-drift', 'environment', 'interpreter', 'interpreter-flags', 'wrong-approval'):
        require(not receipt['commands'], 'bootstrap refusal executed commands')
        require(not (case / 'actual/logs').exists(), 'bootstrap refusal created command logs')
    else:
        label = 'child-1' if name == 'artifact-drift' else 'child-0'
        commands = [c for c in receipt['commands'] if c['label'] == label]
        require(len(commands) == 1, 'actual child terminal metadata unavailable')
        if name == 'cancel':
            require(commands[0]['exit'] == -9, 'actual killed child exit unavailable')
            require('_Cancelled' in (commands[0]['failure'] or ''), 'owner cancellation result unavailable')
        else:
            require(commands[0]['exit'] == (7 if name == 'nonzero' else 0), 'actual child exit lost')
        for suffix, expected in (('.stdout', b'control stdout\n'), ('.stderr', b'control stderr\n')):
            path = case / 'actual/logs' / (label + suffix)
            require(path.read_bytes() == expected, 'raw child stream lost or altered: ' + suffix)
            require(receipt['rawLogs'][path.name] == sha(path), 'raw log receipt digest mismatch')
        if name == 'artifact-drift':
            require(not (case / 'consumed').exists(), 'changed artifact reached consuming child')
            path = case / 'actual/artifacts/value'
            require(path.read_bytes() == b'changed\n', 'changed artifact not preserved')
            require(receipt['observedArtifactFiles'][str(path)] == sha(path), 'changed artifact hash absent')
        if name == 'input-drift':
            require((case / 'resources/token').read_text() == 'changed\n', 'drift not reached')
    return {'innerReceiptSHA256': sha(receipt_path), 'semanticVerdict': 'EXPECTED_REFUSAL'}


def run(manifest_path, admission_path, output):
    # This harness is itself new orchestration: do not invoke before independent
    # admission. Synthetic inner approval files never authorize this entry.
    manifest = json.loads(manifest_path.read_text())
    admission = json.loads(admission_path.read_text())
    require(str(output) == manifest['output'], 'outer output differs from admitted manifest')
    require(admission['manifestSHA256'] == sha(manifest_path) and admission['verdict'] == 'APPROVED',
            'independent admission does not select exact control package')
    require(sorted(admission['prerequisitesSatisfied']) == sorted(manifest['prerequisites']),
            'independent admission leaves prerequisites unresolved')
    require(dict(os.environ) == manifest['environment'], 'outer environment differs')
    require(str(Path(sys.executable).resolve()) == manifest['python'], 'outer interpreter differs')
    require(sys.flags.isolated and sys.flags.no_site and sys.dont_write_bytecode, 'use -I -S -B')
    for path, digest in manifest['files'].items():
        require(sha(path) == digest, 'control package drift before entry: ' + path)
    root = Path(manifest['sourceRoot'])
    runner_module = load('control_runner', root / 'scripts/task_runner.py')
    logs_module = load('control_logs', root / 'scripts/receipt-logs.py')
    boundary_module = load('control_boundary', root / 'scripts/evidence_boundary.py')
    output.mkdir(parents=True, exist_ok=False)
    logs_dir = output / 'logs'
    logs_dir.mkdir()
    logs = logs_module.CommandLogs(logs_dir, ['runner-regressions'] + [c['name'] for c in manifest['cases']])
    # Disposable cases deliberately mutate. Only the immutable harness/helper and
    # host closure belongs to the outer Runner's postguards.
    package = manifest_path.parent
    immutable = [p for p in manifest['files'] if not Path(p).is_relative_to(package)]
    inputs = runner_module.Inputs(files=immutable + [str(manifest_path), str(admission_path)],
                                  directories=manifest['directories'])
    runner = runner_module.Runner(logs, inputs=inputs, env=manifest['environment'], cwd=root)
    receipt = {'status': 'INCOMPLETE', 'manifestSHA256': sha(manifest_path), 'cases': [],
               'scope': 'canonical collector refusal controls; no qualification consumers'}
    with boundary_module.ReceiptBoundary(receipt, output / 'receipt.json',
                                         [('immutable-inputs', inputs.guard), ('outer-raw-logs', logs.guard)]):
        regression = manifest['regression']
        result = runner.run('runner-regressions', regression['argv'], regression['timeoutSeconds'])
        receipt['regression'] = {k: v for k, v in result.items() if k not in ('stdout', 'stderr')}
        for control in manifest['cases']:
            name, case = control['name'], Path(control['directory'])
            argv = [manifest['python'], '-I', '-S', '-B', str(case / 'collect.py'),
                    '--plan', str(case / 'plan.json'), '--approval', str(case / 'control-approval.json'),
                    '--output', str(case / 'actual')]
            env = dict(manifest['environment'])
            if name in ('source-drift', 'helper-drift'):
                path = case / ('source.txt' if name == 'source-drift' else 'scripts/task_runner.py')
                with path.open('a') as stream:
                    stream.write('\n# deliberate isolated drift\n')
            elif name == 'environment':
                env['CONTROL_UNPLANNED'] = '1'
            elif name == 'interpreter-flags':
                argv.remove('-I')
            selected = runner_module.Runner(logs, inputs=inputs, env=env, cwd=root)
            result = None
            observation = {'name': name, 'semanticVerdict': 'FAIL'}
            try:
                result = selected.run(name, argv, 55, expected=None)
                observation.update(check_case(name, case, result))
            except BaseException as error:
                result = getattr(error, 'result', result)
                observation['error'] = f'{type(error).__name__}: {error}'
            if result is not None:
                observation['collectorResult'] = {k: v for k, v in result.items() if k not in ('stdout', 'stderr')}
            receipt['cases'].append(observation)
        receipt['rawLogs'] = dict(logs.hashes)
        require(all(c['semanticVerdict'] == 'EXPECTED_REFUSAL' for c in receipt['cases']),
                'one or more collector refusal controls failed; retain all evidence')
        receipt['status'] = 'PASS'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--admission', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    try:
        run(args.manifest.resolve(), args.admission.resolve(), args.output.resolve())
    except BaseException as error:
        # Bootstrap failures also get terminal evidence when publication works.
        # Never overwrite an existing terminal receipt or claim a failed write.
        args.output.mkdir(parents=True, exist_ok=True)
        terminal = args.output / 'receipt.json'
        if not terminal.exists():
            terminal.write_text(json.dumps({'status': 'INCOMPLETE',
                'error': f'{type(error).__name__}: {error}'}, indent=2) + '\n')
        raise
