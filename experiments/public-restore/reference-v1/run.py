"""One source-guarded Node restore development reference; no tool qualification."""
import fcntl
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

ROOT = Path('/workspace/formal-proofs/bendvy')
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT/'scripts'))
import task_runner
from evidence_boundary import ReceiptBoundary, GuardBoundary


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


LOGS = load('restore_logs', ROOT/'scripts/receipt-logs.py')
CONFIG = load('restore_config', ROOT/'experiments/public-simulation/delivery-v1/installed-config.py')
COMMON = load('snapshot_reference', ROOT/'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/reference-cheap.py')


def strict(actual, expected, path='$'):
    assert type(actual) is type(expected), ('type', path)
    if isinstance(expected, dict):
        assert actual.keys() == expected.keys(), ('keys', path, actual.keys(), expected.keys())
        for key in expected: strict(actual[key], expected[key], path+'.'+key)
    elif isinstance(expected, list):
        assert len(actual) == len(expected), ('length', path, len(actual), len(expected))
        for index, (a, e) in enumerate(zip(actual, expected)): strict(a, e, path+f'[{index}]')
    else:
        assert actual == expected, ('value', path, actual, expected)


def run(out):
    out.mkdir(parents=True)
    logs = LOGS.CommandLogs(out, ['restore-reference'])
    env = CONFIG.environment()
    node = Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node')
    affinity = Path('/usr/bin/taskset')
    files = [HERE/'reference.mjs', HERE/'oracle.py', HERE/'expected.json', Path(__file__),
             node, affinity, Path(task_runner.__file__), Path(LOGS.__file__),
             ROOT/'scripts/evidence_boundary.py', Path(CONFIG.__file__), Path(COMMON.__file__)]
    source = ROOT/'.references/bevy-ts/packages/core/src'
    inputs = task_runner.Inputs(files=files, directories=[source])
    configs = COMMON.configs([*files, source], env['HOME'])
    command = [str(affinity), '-c', '5', str(node), str(HERE/'reference.mjs')]
    receipt = {'status': 'INCOMPLETE', 'scope': 'Pinned TS source development reference only; '
               'no Bend policy, full #59 or installed-tool qualification',
               'argv': command, 'capSeconds': 5, 'environment': env,
               'environmentSha256': hashlib.sha256(json.dumps(env, sort_keys=True,
                  separators=(',', ':'), ensure_ascii=True).encode()).hexdigest(),
               'inputs': inputs.expected, 'configuration': configs, 'command': None,
               'preExecutionExpectedSha256': hashlib.sha256((HERE/'expected.json').read_bytes()).hexdigest()}
    runner = task_runner.Runner(logs, inputs=inputs, env=env, cwd=HERE)

    def guard():
        inputs.guard()
        assert COMMON.configs([*files, source], env['HOME']) == configs
        logs.guard()
        receipt["rawHashes"] = dict(logs.hashes)

    with ReceiptBoundary(receipt, out/'receipt.json', [('source/config/raw', guard)]):
        with open('/tmp/bendvy-parity-heavy.lock', 'a') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            guard()
            with GuardBoundary([('source/config/raw', guard)]):
                try:
                    result = runner.run('restore-reference', command, 5)
                except BaseException as error:
                    result = getattr(error, 'result', None)
                    if isinstance(result, dict):
                        receipt['command'] = {key: value for key, value in result.items()
                                              if key not in ('stdout', 'stderr')}
                    raise
                receipt['command'] = {key: value for key, value in result.items()
                                      if key not in ('stdout', 'stderr')}
        # Raw logs already retained. A mismatch cannot erase or rewrite them.
        strict(json.loads(result['stdout']), json.loads((HERE/'expected.json').read_text()))
        receipt['comparison'] = 'type-sensitive whole output equal'
        receipt['rawHashes'] = dict(logs.hashes)
        receipt['status'] = 'DEVELOPMENT_PASS'
    print(json.dumps({'receipt': str(out/'receipt.json'), 'status': receipt['status']}))


if __name__ == '__main__':
    run(Path(sys.argv[1]).resolve())
