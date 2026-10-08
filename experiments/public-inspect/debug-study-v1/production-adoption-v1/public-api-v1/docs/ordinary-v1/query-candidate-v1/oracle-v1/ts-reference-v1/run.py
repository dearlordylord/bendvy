"""Direct staged Node development observation; no installed-tool qualification."""
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys

ROOT = Path('/workspace/formal-proofs/bendvy')
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'scripts'))
import task_runner
from evidence_boundary import ReceiptBoundary, GuardBoundary


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


LOGS = load('query_logs', ROOT / 'scripts/receipt-logs.py')
STRICT = load('query_strict', ROOT / 'experiments/public-restore/reference-v1/run.py').strict


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inventory(path):
    return {file.relative_to(path).as_posix(): sha(file)
            for file in path.rglob('*') if file.is_file()}


def config_state(paths):
    names = {'package.json', 'tsconfig.json', 'jsconfig.json', '.npmrc'}
    selected = {parent / name for path in paths for parent in [path, *path.parents]
                for name in names}
    states = {}
    for path in selected:
        state = {'kind': 'file', 'sha256': sha(path)} if path.is_file() else {
            'kind': 'directory' if path.is_dir() else 'other' if path.exists() else 'absent'}
        if path.is_symlink():
            state.update(link=os.readlink(path), resolved=str(path.resolve()))
        states[str(path)] = state
    return states


def run(out):
    out.mkdir(parents=True)
    core = ROOT / '.references/bevy-ts/packages/core'
    stage = out / 'stage'
    shutil.copytree(core / 'src', stage / 'reference/src')
    shutil.copyfile(core / 'package.json', stage / 'reference/package.json')
    study = stage / 'study'
    study.mkdir()
    fixture = (HERE / 'reference.ts').read_text()
    original = str(core / 'src/index.ts')
    assert fixture.count(original) == 1
    (study / 'reference.ts').write_text(fixture.replace(original, '../reference/src/index.ts'))
    shutil.copyfile(HERE / 'expected.json', study / 'expected.json')
    (study / 'package.json').write_text('{"type":"module"}\n')
    node = Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node').resolve()
    taskset = Path('/usr/bin/taskset').resolve()
    env = {'HOME': '/home/node', 'PATH': '/usr/bin:/bin', 'LANG': 'C', 'LC_ALL': 'C',
           'TZ': 'UTC', 'BEND_NO_TELEMETRY': '1'}
    files = [Path(__file__), HERE / 'reference.ts', HERE / 'expected.py',
             HERE / 'expected.json', HERE / 'source-basis.json', node, taskset,
             core / 'package.json', Path(task_runner.__file__), Path(LOGS.__file__),
             ROOT / 'scripts/evidence_boundary.py',
             ROOT / 'experiments/public-restore/reference-v1/run.py',
             ROOT / 'experiments/public-simulation/delivery-v1/installed-config.py',
             ROOT / 'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/reference-cheap.py']
    basis = json.loads((HERE / 'source-basis.json').read_text())
    for path, digest in basis['sourceSHA256'].items():
        assert sha(ROOT / path) == digest, path
        files.append(ROOT / path)
    assert sha(HERE / 'reference.ts') == basis['fixtureSHA256']
    assert sha(HERE / 'expected.json') == basis['expectedSHA256']
    assert sha(HERE / 'expected.py') == basis['expectedAuthorSHA256']
    assert inventory(core / 'src') == inventory(stage / 'reference/src')
    assert sha(core / 'package.json') == sha(stage / 'reference/package.json')
    assert (study / 'reference.ts').read_text() == fixture.replace(
        original, '../reference/src/index.ts')
    assert sha(study / 'expected.json') == basis['expectedSHA256']
    inputs = task_runner.Inputs(files=files, directories=[core / 'src', stage])
    configs = config_state([core, HERE, out, study, stage / 'reference', node.parent])
    argv = [str(taskset), '-c', '5', str(node), str(study / 'reference.ts')]
    receipt = {'status': 'INCOMPLETE', 'scope': 'actual pinned TS application development only',
               'argv': argv, 'capSeconds': 5, 'environment': env,
               'inputs': inputs.expected, 'configuration': configs, 'command': None,
               'stageJoins': {'fullCoreSourceAndPackage': 'byte-identical',
                              'fixture': 'sole core import rewrite',
                              'expected': 'byte-identical pre-run oracle'},
               'expectedSha256': sha(HERE / 'expected.json')}
    logs = LOGS.CommandLogs(out, ['reference'])
    runner = task_runner.Runner(logs, inputs=inputs, env=env, cwd=stage)

    def guard():
        inputs.guard()
        assert json.loads((HERE / 'source-basis.json').read_text()) == basis
        for path, digest in basis['sourceSHA256'].items():
            assert sha(ROOT / path) == digest, path
        assert sha(HERE / 'reference.ts') == basis['fixtureSHA256']
        assert sha(HERE / 'expected.py') == basis['expectedAuthorSHA256']
        assert sha(HERE / 'expected.json') == basis['expectedSHA256']
        assert inventory(core / 'src') == inventory(stage / 'reference/src')
        assert sha(core / 'package.json') == sha(stage / 'reference/package.json')
        assert (study / 'reference.ts').read_text() == fixture.replace(
            original, '../reference/src/index.ts')
        assert sha(study / 'expected.json') == basis['expectedSHA256']
        assert config_state([core, HERE, out, study, stage / 'reference', node.parent]) == configs
        logs.guard()
        receipt['rawHashes'] = dict(logs.hashes)

    with ReceiptBoundary(receipt, out / 'receipt.json', [('source/config/raw', guard)]):
        with open('/tmp/bendvy-parity-heavy.lock', 'a') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            guard()
            with GuardBoundary([('source/config/raw', guard)]):
                try:
                    result = runner.run('reference', argv, 5)
                except BaseException as error:
                    result = getattr(error, 'result', None)
                    if isinstance(result, dict):
                        receipt['command'] = {k: v for k, v in result.items()
                                              if k not in ('stdout', 'stderr')}
                    raise
                receipt['command'] = {k: v for k, v in result.items()
                                      if k not in ('stdout', 'stderr')}
        assert result['stderr'] == b''
        STRICT(json.loads(result['stdout']), json.loads((HERE / 'expected.json').read_text()))
        receipt['comparison'] = 'type-sensitive whole public output equal'
        receipt['status'] = 'DEVELOPMENT_PASS'
    print(json.dumps({'status': receipt['status'], 'receipt': str(out / 'receipt.json')}))


if __name__ == '__main__':
    run(Path(sys.argv[1]).resolve())
