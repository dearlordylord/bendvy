"""One guarded Node-only provider-leaf preflight; no installed-tool discovery."""
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


def prepare():
    out = HERE.parents[3] / '.artifacts' / ('snapshot58-reference-cheap-' + str(time.time_ns()))
    out.mkdir(parents=True)
    private = out / 'private-environment.json'
    env = {k: os.environ[k] for k in ('HOME', 'PATH', 'LANG', 'LC_ALL', 'TZ') if k in os.environ}
    env['BEND_NO_TELEMETRY'] = '1'
    private.write_text(json.dumps(env, sort_keys=True) + '\n')
    private.chmod(0o600)
    node, affinity = Path(shutil.which('node')).resolve(), Path(shutil.which('taskset')).resolve()
    reference = ROOT / '.references/bevy-ts/packages/core/src'
    # Literal reference import -> Decode's only runtime import Result.ts.
    files = {SELF, Path(task_runner.__file__).resolve(), ROOT/'scripts/evidence_boundary.py',
             ROOT/'scripts/receipt-logs.py', HERE/'reference.mjs', HERE/'expected-leaf.stdout',
             HERE/'consumer-direction.json', reference/'Decode.ts', reference/'Result.ts',
             ROOT/'.references/sources.json', node, affinity, private}
    direction = json.loads((HERE/'consumer-direction.json').read_text())
    files.update((Path(p) if Path(p).is_absolute() else OWN_ROOT/Path(p)).resolve() for p in direction['sourceFiles'])
    # Join the unchanged source-positive scope; no TypeScript execution credit transferred.
    sources = json.loads((HERE/'source-proposal.json').read_text())
    files.add(HERE/'source-proposal.json')
    files.update((Path(p) if Path(p).is_absolute() else OWN_ROOT/Path(p)).resolve() for p in sources['sourceFiles'])
    files.add(Path(sources['externalCommonLeaf']['path']))
    history = OWN_ROOT/'.artifacts/snapshot58-consumer-development-1791475806491113714'
    files.update(history/name for name in ('plan.json', 'receipt.json', 'stdout.raw', 'stderr.raw', 'source-before.tar.gz'))
    hp = json.loads((history/'plan.json').read_text())
    hr = json.loads((history/'receipt.json').read_text())
    assert hr['status'] == 'DEVELOPMENT_SOURCE_PASS' and hr['exitCode'] == 0 and hr['sourcePinDrift'] == []
    assert hr['planSHA256'] == sha(history/'plan.json')
    files.update(Path(p) for p in hp['sourcePins'])
    assert all(sha(p) == h for p, h in hp['sourcePins'].items())
    assert all(sha(history/name) == row['sha256'] for name, row in hr['logs'].items())
    pins = {str(p): sha(p) for p in sorted(files)}
    plan = {'scope': 'Node-only provider-leaf DEVELOPMENT; not Runtime.snapshot/static Gate/full58',
            'pins': pins, 'configuration': configs(files, env['HOME']),
            'privateEnvironment': str(private), 'environmentSHA256': sha(private),
            'cwd': str(HERE), 'command': {'label': 'reference',
                'argv': [str(affinity), '-c', '5', str(node), str(HERE/'reference.mjs')],
                'capSeconds': 5}, 'expectedOutput': str(HERE/'expected-leaf.stdout'),
            'expectedSHA256': sha(HERE/'expected-leaf.stdout'),
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
            assert configs(plan['pins'], env['HOME']) == plan['configuration']
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
        logs = module.CommandLogs(out, ['reference'])
        command = plan['command']
        with GuardBoundary([('inputs', guard), ('raw', raw_guard)]):
            attempt = {'label': command['label'], 'argv': command['argv'],
                       'capSeconds': command['capSeconds'], 'attemptState': 'ATTEMPTED'}
            record['commands'].append(attempt)
            try:
                result = task_runner.execute_result(command['argv'], command['capSeconds'], env, plan['cwd'], 'split')
            except BaseException as error:
                attempt['exception'] = f'{type(error).__name__}: {error}'
                raise
            attempt.update({k: v for k, v in result.items() if not isinstance(v, bytes)})
            attempt['attemptState'] = 'RETURNED'
            attempt['streams'] = {k: {'bytes': len(result[k]),
                'sha256': hashlib.sha256(result[k]).hexdigest()} for k in ('stdout', 'stderr')}
            logs.record('reference', result['stdout'], result['stderr'])
            raw_guard()
            assert result['failure'] is None and result['exit'] == 0
            assert result['stderr'] == b''
            assert result['stdout'] == Path(plan['expectedOutput']).read_bytes()
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
