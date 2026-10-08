"""One guarded whole basicWorld Bend IO development consumer; no installed-tool discovery."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys
import time

ROOT = Path('/workspace/formal-proofs/bendvy')
HERE = Path(__file__).resolve().parent
OWN_ROOT = HERE.parents[3]
SELF = Path(__file__).resolve()
sys.path.insert(0, str(ROOT / 'scripts'))
from evidence_boundary import ReceiptBoundary, GuardBoundary
import task_runner

NAMES = ('package.json', 'tsconfig.json', 'jsconfig.json', '.npmrc', '.node-version',
         '.tool-versions', 'mise.toml', '.mise.toml', 'bend.json', 'bend.jsonc',
         'bender.json', '.bend.json', 'bend.config.json', '.bend', 'check.json')


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def state(path, visited=()):
    path = Path(path)
    if not path.exists() and not path.is_symlink():
        return {'kind': 'absent'}
    resolved = path.resolve()
    if path.is_symlink():
        result = {'kind': 'symlink', 'target': os.readlink(path), 'resolvedPath': str(resolved)}
        result['resolved'] = state(resolved, visited)
        return result
    if path.is_file():
        return {'kind': 'file', 'sha256': sha(path), 'resolvedPath': str(resolved)}
    if path.is_dir():
        if str(resolved) in visited:
            return {'kind': 'directory-cycle', 'resolvedPath': str(resolved)}
        return {'kind': 'directory', 'resolvedPath': str(resolved), 'inventory': {
            child.name: state(child, (*visited, str(resolved)))
            for child in sorted(path.iterdir())}}
    return {'kind': 'other', 'resolvedPath': str(resolved)}


def symlink_targets(value):
    if isinstance(value, dict):
        if value.get('kind') == 'symlink':
            yield Path(value['resolvedPath'])
        for child in value.values():
            yield from symlink_targets(child)
    elif isinstance(value, (list, tuple)):
        for child in value:
            yield from symlink_targets(child)


def configs(paths, home):
    roots = {Path(home)}
    for path in paths:
        p = Path(path)
        roots.update((p.parent, *p.parents))
    queue = list(roots)
    seen = set()
    result = {}
    while queue:
        root = queue.pop()
        if root in seen:
            continue
        seen.add(root)
        for name in NAMES:
            p = root / name
            result[str(p)] = state(p)
            for target in symlink_targets(result[str(p)]):
                queue.extend((target.parent, *target.parents))
    return result


def consumed(entry):
    import re
    pins, joins = {}, []
    def visit(literal):
        literal = Path(literal)
        assert literal.is_file(), ('literal Bend target missing', str(literal))
        source = literal.resolve(strict=True)
        if str(source) in pins:
            return
        pins[str(source)] = sha(source)
        if source.suffix != '.bend':
            return
        for name in re.findall(r'^\s*import\s+([^\s]+)', source.read_text(), re.M):
            name = name.strip(chr(34))
            if name == 'Base':
                target = Path('/home/node/.bend/bend2/base.bend')
            else:
                assert (name.startswith(('.', '/')) or name.endswith('.bend')), ('unclassified Bend import', str(source), name)
                target = Path(name) if Path(name).is_absolute() else source.parent / name
            assert target.is_file(), ('literal import missing', str(target))
            resolved = target.resolve(strict=True)
            joins.append({'source': str(source), 'import': name, 'literal': str(target),
                          'resolved': str(resolved), 'sha256': sha(resolved)})
            visit(target)
    visit(entry)
    return {'sourcePins': pins, 'importJoins': joins}


def strict_equal(actual, expected):
    assert type(actual) is type(expected), ('JSON type mismatch', type(actual).__name__, type(expected).__name__)
    if isinstance(expected, dict):
        assert actual.keys() == expected.keys()
        for key in expected:
            strict_equal(actual[key], expected[key])
    elif isinstance(expected, list):
        assert len(actual) == len(expected)
        for left, right in zip(actual, expected):
            strict_equal(left, right)
    else:
        assert actual == expected


def prepare():
    out = OWN_ROOT / '.artifacts' / ('snapshot58-world-io-cheap-' + str(time.time_ns()))
    out.mkdir(parents=True)
    private = out / 'private-environment.json'
    env = {k: os.environ[k] for k in ('HOME', 'PATH', 'LANG', 'LC_ALL', 'TZ') if k in os.environ}
    env['BEND_NO_TELEMETRY'] = '1'
    private.write_text(json.dumps(env, sort_keys=True) + '\n')
    private.chmod(0o600)
    compiler, affinity = Path(shutil.which('bend')).resolve(), Path(shutil.which('taskset')).resolve()
    entry = HERE / 'consumer-io.bend'
    assert entry.is_file() and '..' not in entry.parts
    closure = consumed(entry)
    proposal = HERE / 'source-proposal.json'
    assert sha(proposal) == '14cc123919effd2533039d76bf8a1157a1ae47de25d684ffbc28798c3f444902'
    assert json.loads((HERE / 'io-proposal.json').read_text())['wrapperSHA256'] == sha(SELF)
    reviewed = json.loads(proposal.read_text())
    assert all(sha(p) == h for p, h in reviewed['files'].items())
    files = {SELF, Path(task_runner.__file__).resolve(), ROOT / 'scripts/evidence_boundary.py',
             ROOT / 'scripts/receipt-logs.py', proposal, HERE / 'source-closure.json', HERE / 'model.py',
             HERE / 'expected-consumer.json', HERE / 'ORACLE-SCOPE.md', HERE / 'PROPOSAL.md',
             compiler, affinity, private, HERE / 'io-proposal.json', *map(Path, closure['sourcePins'])}
    source_history = OWN_ROOT / '.artifacts/snapshot58-world-fixture-source-1791482954716561025'
    hp = json.loads((source_history / 'plan.json').read_text())
    assert json.loads((source_history / 'receipt.json').read_text()) == {
        'exitCode': 137, 'sourcePinDrift': [], 'scope': 'development typing only'}
    assert (source_history / 'stdout.raw').read_bytes() == b'' and (source_history / 'stderr.raw').read_bytes() == b''
    assert all(sha(p) == h for p, h in hp['sourcePins'].items())
    files.update(source_history / name for name in ('plan.json', 'receipt.json', 'stdout.raw', 'stderr.raw'))
    files.update(source_history.glob('*.bend'))
    files.update(map(Path, hp['sourcePins']))
    reference_history = OWN_ROOT / '.artifacts/snapshot58-world-reference-cheap-1791483992999401767'
    assert sha(reference_history / 'plan.json') == '9496ea6e515bbda421bd41ce589ab8791725923fa22c579120079f38d306a666'
    assert sha(reference_history / 'receipt.json') == '1ac935224fe5c959c3379666694bc5e3958de9cc710cdf6fe6fc7881391ed18a'
    tp = json.loads((reference_history / 'plan.json').read_text())
    tr = json.loads((reference_history / 'receipt.json').read_text())
    assert tr['status'] == 'DEVELOPMENT_PASS' and not tr.get('guardFailures')
    assert len(tr['commands']) == 1 and tr['commands'][0]['argv'] == tp['command']['argv']
    assert tr['commands'][0]['capSeconds'] == 5 and tr['commands'][0]['exit'] == 0 and tr['commands'][0]['failure'] is None
    assert tr['logs'] == {'reference.stdout': tp['expectedSHA256'], 'reference.stderr': hashlib.sha256(b'').hexdigest()}
    assert (reference_history / 'reference.stdout').read_bytes() == Path(tp['expectedOutput']).read_bytes()
    assert (reference_history / 'reference.stderr').read_bytes() == b''
    assert all(sha(p) == h for p, h in tp['pins'].items())
    files.update(map(Path, tp['pins']))
    files.update(reference_history / name for name in ('plan.json', 'receipt.json', 'reference.stdout', 'reference.stderr'))
    resource = Path('/home/node/.bend/bend2')
    resource_state = state(resource)
    files.update(p for p in resource.rglob('*') if p.is_file())
    notice = b'bend 2.0.36 is available: run bend update\n'
    assert hashlib.sha256(notice).hexdigest() == '57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
    pins = {str(p): sha(p) for p in sorted(files)}
    plan = {'scope': 'Whole two-schema basicWorld Bend IO DEVELOPMENT; no public Gate/full58 credit',
            'pins': pins, 'configuration': configs((*files, resource / 'base.bend'), env['HOME']),
            'installedResource': str(resource), 'installedMembership': resource_state,
            'consumedClosure': closure, 'privateEnvironment': str(private), 'environmentSHA256': sha(private),
            'cwd': str(HERE), 'command': {'label': 'consumer-io',
                'argv': [str(affinity), '-c', '5', str(compiler), str(entry)], 'capSeconds': 5},
            'expectedOutput': str(HERE / 'expected-consumer.json'), 'expectedSHA256': sha(HERE / 'expected-consumer.json'),
            'noticeHex': notice.hex(), 'noticeSHA256': hashlib.sha256(notice).hexdigest(),
            'runnerSHA256': sha(task_runner.__file__), 'wrapperSHA256': sha(SELF)}
    path = out / 'plan.json'
    path.write_text(json.dumps(plan, indent=2) + '\n')
    print(json.dumps({'plan': str(path), 'sha256': sha(path), 'pinCount': len(pins)}))


def run(path, expected_plan_sha):
    path = Path(path).resolve()
    out = path.parent
    original_plan_sha = expected_plan_sha
    assert isinstance(original_plan_sha, str) and len(original_plan_sha) == 64
    record = {'status': 'INCOMPLETE', 'planSHA256': original_plan_sha,
              'commands': [], 'logs': {}}
    inputs = None
    logs = None
    plan = None

    def guard():
        assert sha(path) == original_plan_sha
        if plan is not None:
            assert all(sha(p) == h for p, h in plan['pins'].items())
            env = json.loads(Path(plan['privateEnvironment']).read_text())
            assert configs((*plan['pins'], str(Path(plan['installedResource']) / 'base.bend')), env['HOME']) == plan['configuration']
            assert state(plan['installedResource']) == plan['installedMembership']
            assert consumed(plan['command']['argv'][4]) == plan['consumedClosure']
        if inputs is not None:
            inputs.guard()

    def raw_guard():
        if logs is not None:
            record['logs'] = dict(logs.hashes)
            logs.guard()

    with ReceiptBoundary(record, out/'receipt.json', [('inputs', guard), ('raw', raw_guard)]):
        assert sha(path) == original_plan_sha
        plan = json.loads(path.read_text())
        guard()
        assert plan['wrapperSHA256'] == sha(SELF)
        assert plan['runnerSHA256'] == sha(task_runner.__file__)
        assert sha(plan['privateEnvironment']) == plan['environmentSHA256']
        assert sha(plan['expectedOutput']) == plan['expectedSHA256']
        env = json.loads(Path(plan['privateEnvironment']).read_text())
        assert not any(k.startswith(('LD_', 'DYLD_', 'NODE_')) for k in env)
        inputs = task_runner.Inputs(files=(*plan['pins'], str(path)))
        spec = importlib.util.spec_from_file_location('snapshot58_logs', ROOT/'scripts/receipt-logs.py')
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        logs = module.CommandLogs(out, ['consumer-io'])
        command = plan['command']
        with GuardBoundary([('inputs', guard), ('raw', raw_guard)]):
            attempt = {'label': command['label'], 'argv': command['argv'],
                       'capSeconds': command['capSeconds'], 'attemptState': 'ATTEMPTED'}
            record['commands'].append(attempt)
            try:
                result = task_runner.execute_result(command['argv'], command['capSeconds'], env, plan['cwd'], 'split')
            except BaseException as error:
                attempt['exception'] = f'{type(error).__name__}: {error}'
                attempt['attemptState'] = 'FAILED'
                failed = getattr(error, 'result', None)
                def retain_failed():
                    if isinstance(failed, dict):
                        attempt.update({k: v for k, v in failed.items() if not isinstance(v, bytes)})
                        attempt['attemptState'] = 'FAILED'
                        attempt['streams'] = {k: {'available': isinstance(failed.get(k), bytes),
                            'bytes': len(failed.get(k, b'')),
                            'sha256': hashlib.sha256(failed.get(k, b'')).hexdigest()}
                            for k in ('stdout', 'stderr') if k not in failed or isinstance(failed[k], bytes)}
                        if any(isinstance(failed.get(k), bytes) for k in ('stdout', 'stderr')):
                            failed_stdout = failed['stdout'] if isinstance(failed.get('stdout'), bytes) else b''
                            failed_stderr = failed['stderr'] if isinstance(failed.get('stderr'), bytes) else b''
                            logs.record('consumer-io', failed_stdout, failed_stderr)
                            record['logs'] = dict(logs.hashes)
                with GuardBoundary([('failed child result/raw retention', retain_failed)]):
                    raise
            attempt.update({k: v for k, v in result.items() if not isinstance(v, bytes)})
            attempt['attemptState'] = 'RETURNED'
            attempt['streams'] = {k: {'bytes': len(result[k]),
                'sha256': hashlib.sha256(result[k]).hexdigest()} for k in ('stdout', 'stderr')}
            logs.record('consumer-io', result['stdout'], result['stderr'])
            raw_guard()
            assert result['failure'] is None and result['exit'] == 0
            notice = bytes.fromhex(plan['noticeHex'])
            assert hashlib.sha256(notice).hexdigest() == plan['noticeSHA256']
            assert result['stderr'] in (b'', notice)
            assert result['stdout'].endswith(b'\n') and not result['stdout'].endswith(b'\n\n')
            strict_equal(json.loads(result['stdout']), json.loads(Path(plan['expectedOutput']).read_bytes()))
        record['status'] = 'DEVELOPMENT_PASS'
    print(json.dumps({'receipt': str(out/'receipt.json'), 'sha256': sha(out/'receipt.json'),
                      'status': record['status']}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=['prepare', 'run'])
    parser.add_argument('plan', nargs='?')
    parser.add_argument('--expected-plan-sha')
    args = parser.parse_args()
    if args.action == 'prepare':
        prepare()
    else:
        run(args.plan, args.expected_plan_sha)
