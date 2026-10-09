"""Source-only resource successor using the existing five-second capture path."""
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import sys

ROOT = Path('/workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention')
HERE = Path(__file__).resolve().parent
CAPTURE = ROOT / 'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/check-source.py'
RUNNER = ROOT / 'scripts/task_runner.py'
BOUNDARY = ROOT / 'scripts/evidence_boundary.py'


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def prepare(out):
    inventory_path = HERE.parent / 'oracle-v1/inspector-filter-identities.json'
    inventory = json.loads(inventory_path.read_text())
    tools = {'bend': '/home/node/.bend/bin/bend-2.0.35',
             'python': str(Path(sys.executable).resolve(strict=True)),
             'taskset': str(Path('/usr/bin/taskset').resolve(strict=True))}
    pins = dict(inventory['sourceSHA256'])
    for path in [inventory_path, CAPTURE, RUNNER, BOUNDARY, Path(__file__),
                 HERE / 'root-host-20261009.json',
                 Path('/home/node/.bend/bend2/base.bend'), *map(Path, tools.values())]:
        pins[str(path.resolve(strict=True))] = sha(path)
    out = Path(out).resolve()
    plan = {'scope': 'Full repaired mutant source prerequisite only; no JS/Native/performance claim',
            'entrypoint': inventory['entrypoint'], 'sourceModules': len(inventory['sourceSHA256']),
            'pins': pins, 'tools': tools, 'cwd': str(ROOT),
            'environment': {'HOME': '/home/node', 'PATH': '/usr/bin:/bin', 'LANG': 'C',
                            'LC_ALL': 'C', 'TZ': 'UTC', 'BEND_NO_TELEMETRY': '1'},
            'argv': [tools['taskset'], '-c', '11', tools['bend'], inventory['entrypoint'], '--check-only'],
            'capSeconds': 5, 'heavyLock': '/tmp/bendvy-parity-heavy.lock',
            'resourceChange': 'Root sampled CPU5 98.94% busy versus allowed CPU11 0%; retained CPU5 deadlines unchanged'}
    if plan['sourceModules'] != 80 or 11 not in os.sched_getaffinity(0):
        raise ValueError('Exact full scope and allowed source CPU required')
    out.mkdir(exist_ok=False)
    (out / 'plan.json').write_text(json.dumps(plan, indent=2) + '\n')
    print(sha(out / 'plan.json'))


def run(plan_path, admitted_sha):
    plan_path = Path(plan_path).resolve(strict=True)
    if sha(plan_path) != admitted_sha:
        raise ValueError('Admitted source plan changed')
    plan = json.loads(plan_path.read_text())
    if str(Path(sys.executable).resolve(strict=True)) != plan['tools']['python']:
        raise ValueError('Actual source executor interpreter differs')
    if plan['capSeconds'] != 5 or plan['argv'][:3] != [plan['tools']['taskset'], '-c', '11']:
        raise ValueError('Frozen source cap/CPU changed')
    if 11 not in os.sched_getaffinity(0):
        raise ValueError('Source CPU is outside actual allowed affinity')
    out = plan_path.parent / 'capture'
    pins = dict(plan['pins'])
    pins[str(plan_path)] = admitted_sha
    if any(sha(path) != digest for path, digest in pins.items()):
        raise ValueError('Source boundary changed before helper imports')
    capture = load('existing_source_capture', CAPTURE)
    runner = load('existing_source_runner', RUNNER)
    boundary = load('existing_source_boundary', BOUNDARY)
    capture.prepare_attempt(out, list(map(Path, pins)))
    pins[str(out / 'SOURCE.json')] = sha(out / 'SOURCE.json')
    record = {'scope': plan['scope'], 'planSHA256': admitted_sha, 'guards': []}

    def guard(label):
        actual = {path: sha(path) for path in pins}
        unchanged = actual == pins
        target = out / (label + '.guard.json')
        target.write_text(json.dumps({'unchanged': unchanged, 'actualPins': actual}, indent=2) + '\n')
        record['guards'].append({'path': str(target), 'sha256': sha(target)})
        if not unchanged:
            raise ValueError('Source boundary changed: ' + label)

    with boundary.ReceiptBoundary(record, out / 'receipt.json', [('final source boundary', lambda: guard('final'))]):
        guard('pre')
        with boundary.GuardBoundary([('post source boundary', lambda: guard('post'))]):
            with open(plan['heavyLock'], 'a') as lock:
                fcntl.flock(lock, fcntl.LOCK_EX)
                try:
                    guard('acquired')
                    def execute(argv, cap, cwd, capture):
                        if argv != plan['argv'] or cap != 5 or cwd != plan['cwd'] or capture != 'split':
                            raise ValueError('Existing source capture invocation differs')
                        return runner.execute_result(argv, cap, plan['environment'], cwd, capture)
                    result = capture.capture(out, plan['argv'], execute)
                finally:
                    fcntl.flock(lock, fcntl.LOCK_UN)
            for name in ('result.json', 'stdout', 'stderr'):
                pins[str(out / name)] = sha(out / name)
            record['capture'] = {'path': str(out / 'result.json'), 'sha256': sha(out / 'result.json')}
            record['exit'] = result['exit']
            record['failure'] = result['failure']
            if result['exit'] != 0 or result['failure'] is not None:
                raise ValueError('Full source prerequisite did not pass')
        record['status'] = 'SOURCE_PREREQUISITE_PASS'
    print(record['exit'], record['failure'])


if __name__ == '__main__':
    if len(sys.argv) == 3 and sys.argv[1] == 'prepare':
        prepare(sys.argv[2])
    elif len(sys.argv) == 4 and sys.argv[1] == 'run':
        run(sys.argv[2], sys.argv[3])
    else:
        raise SystemExit('prepare OUTPUT | run PLAN ADMITTED_SHA256')
