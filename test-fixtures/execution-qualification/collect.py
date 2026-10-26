#!/usr/bin/env python3
"""Execute a reviewed frozen correctness plan through the shared runner."""
import argparse
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import signal
import sys
import time


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def snapshot_guard(plan):
    for name, expected in plan['files'].items():
        if sha(name) != expected:
            raise RuntimeError('frozen file changed: ' + name)
    for name, expected in plan['aliases'].items():
        if str(Path(name).resolve(strict=True)) != expected:
            raise RuntimeError('frozen path target changed: ' + name)
    for name, expected in plan['directories'].items():
        actual = {str(p.relative_to(name)): sha(p)
                  for p in sorted(Path(name).rglob('*')) if p.is_file()}
        if actual != expected:
            raise RuntimeError('frozen directory changed: ' + name)
    for name, expected in plan['presence'].items():
        path = Path(name)
        actual = sha(path) if path.is_file() else None
        if actual != expected:
            raise RuntimeError('configuration presence or bytes changed: ' + name)


def metadata(result):
    return {key: value for key, value in result.items()
            if key not in ('stdout', 'stderr')}


def worker_diagnostic(plan, label, expected, stderr, receipt):
    path = Path(plan['root']) / 'test-fixtures/parallel-systems/instrument-workers.py'
    if plan['files'].get(str(path.resolve())) != sha(path):
        raise RuntimeError('worker validator is not a frozen plan input')
    check = {'label': label, 'status': 'FAIL'}
    receipt.setdefault('workerDiagnostics', []).append(check)
    try:
        validator = load('qualified_worker_validator', path)
        check['observed'] = validator.validate(stderr, expected)
    except BaseException as error:
        check['error'] = f'{type(error).__name__}: {error}'
        raise
    check['status'] = 'PASS'


def collect(plan_path, approval_path, output):
    output.mkdir(parents=True, exist_ok=False)
    receipt_path = output / 'receipt.json'
    receipt = {'status': 'INCOMPLETE', 'planSHA256': sha(plan_path),
               'commands': [], 'artifacts': {}, 'cases': [],
               'scope': 'finite public-consumer correctness; no concurrency or speedup claim'}
    boundary_entered = False
    try:
        plan = json.loads(plan_path.read_text())
        if str(output) != plan['output']:
            raise RuntimeError('output directory differs from the plan')
        approval = json.loads(approval_path.read_text())
        receipt['approvalSHA256'] = sha(approval_path)
        if approval['planSHA256'] != receipt['planSHA256'] or approval['verdict'] != 'APPROVED':
            raise RuntimeError('approval does not select this exact plan')
        if sorted(approval['prerequisitesSatisfied']) != sorted(plan['prerequisites']):
            raise RuntimeError('approval does not resolve every launch prerequisite')
        if Path(sys.executable).resolve() != Path(plan['python']).resolve():
            raise RuntimeError('collector interpreter differs from the plan')
        if not (sys.flags.isolated and sys.flags.no_site and sys.dont_write_bytecode):
            raise RuntimeError('launch the pinned interpreter with -I -S -B')
        if dict(os.environ) != plan['environment']:
            raise RuntimeError('collector environment differs from the plan')
        if sha(__file__) != plan['files'][str(Path(__file__).resolve())]:
            raise RuntimeError('collector bytes differ from the plan')
        snapshot_guard(plan)
        root = Path(plan['root'])
        runner_module = load('qualified_runner', root / 'scripts/task_runner.py')
        logs_module = load('qualified_logs', root / 'scripts/receipt-logs.py')
        boundary_module = load('qualified_boundary', root / 'scripts/evidence_boundary.py')
        pins_module = load('qualified_pins', root / 'scripts/owned-tool-pins.py')
        logs_dir = output / 'logs'
        logs_dir.mkdir()
        artifacts_dir = output / 'artifacts'
        artifacts_dir.mkdir()
        logs = logs_module.CommandLogs(logs_dir, plan['labels'])
        inputs = runner_module.Inputs(files=plan['files'], directories=plan['directories'])
        runner = runner_module.Runner(logs, inputs=inputs,
                                      env=plan['environment'], cwd=plan['root'])
        artifacts = receipt['artifacts']
        case_deadline = None

        def artifact_guard():
            actual = {str(p.resolve()): sha(p) for p in sorted(artifacts_dir.rglob('*'))
                      if p.is_file()}
            receipt['observedArtifactFiles'] = actual
            if actual != artifacts:
                raise RuntimeError('generated artifact bytes or membership changed')

        def log_guard():
            receipt['rawLogs'] = dict(logs.hashes)
            logs.guard()

        def invoke(label, argv, timeout, expected=0, env=None):
            if case_deadline is not None:
                timeout = min(timeout, case_deadline - time.monotonic())
                if timeout <= 0:
                    raise TimeoutError('case deadline before command: ' + label)
            if env is not None and env != runner.env:
                selected = runner_module.Runner(logs, inputs=inputs, env=env, cwd=plan['root'])
            else:
                selected = runner
            snapshot_guard(plan)
            artifact_guard()
            try:
                result = selected.run(label, argv, timeout, expected)
            except BaseException as error:
                result = getattr(error, 'result', None)
                if result is not None:
                    receipt['commands'].append(dict(label=label, **metadata(result)))
                raise
            receipt['commands'].append(dict(label=label, **metadata(result)))
            return result

        def verify_tools(prefix):
            for index, group in enumerate(plan['toolSnapshots']):
                expected = json.loads(json.dumps(group['snapshot']))
                for streams in expected['resolved_libraries'].values():
                    streams['stdout'] = bytes.fromhex(streams['stdout'])
                    streams['stderr'] = bytes.fromhex(streams['stderr'])
                count = 0

                def execute(argv, timeout, env):
                    nonlocal count
                    label = f'{prefix}-tools{index}-{count}'
                    count += 1
                    return invoke(label, argv, timeout, expected=None, env=env)

                pins_module.verify(expected, execute=execute, **group['configuration'])

        checks = [('source-tool-config', lambda: snapshot_guard(plan)),
                  ('inputs', inputs.guard), ('raw-logs', log_guard),
                  ('generated-artifacts', artifact_guard)]
        with boundary_module.ReceiptBoundary(receipt, receipt_path, checks):
            boundary_entered = True
            lock_path = Path(plan['heavyLock'])
            with lock_path.open('a') as heavy_lock:
                fcntl.flock(heavy_lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                verify_tools('initial')
                for case in plan['cases']:
                    deadline = time.monotonic() + case['wallSeconds']
                    case_deadline = deadline
                    for stage in case['stages']:
                        verify_tools(stage['label'] + '-pre')
                        artifact_guard()
                        for consumed in stage['consumes']:
                            if str((artifacts_dir / consumed).resolve()) not in artifacts:
                                raise RuntimeError('unregistered consuming input: ' + consumed)
                        remaining = deadline - time.monotonic()
                        if remaining <= 0:
                            raise TimeoutError('case deadline before command: ' + case['name'])
                        argv = [word.replace('{ARTIFACTS}', str(artifacts_dir))
                                for word in stage['argv']]
                        with Path(plan['sourceLock']).open('a') as source_lock:
                            if stage['serializesSource']:
                                while True:
                                    try:
                                        fcntl.flock(source_lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                                        break
                                    except BlockingIOError:
                                        if time.monotonic() >= deadline:
                                            raise TimeoutError('case deadline waiting for source CPU')
                                        time.sleep(0.05)
                            result = invoke(stage['label'], argv,
                                            min(stage['timeoutSeconds'], remaining),
                                            stage['expectedExit'])
                        for produced in stage['produces']:
                            path = (artifacts_dir / produced).resolve()
                            if not path.is_relative_to(artifacts_dir.resolve()):
                                raise RuntimeError('artifact escapes planned directory')
                            if str(path) in artifacts or not path.is_file():
                                raise RuntimeError('artifact missing or already registered')
                            artifacts[str(path)] = sha(path)
                        artifact_guard()
                        for token in stage.get('diagnosticContains', []):
                            if token.encode() not in result['stdout'] + result['stderr']:
                                raise RuntimeError('missing intended diagnostic: ' + token)
                        oracle = stage.get('oracle')
                        if oracle and result['stdout'] != Path(oracle).read_bytes():
                            raise RuntimeError('complete oracle differs: ' + stage['label'])
                        if 'workerDiagnostic' in stage:
                            worker_diagnostic(plan, stage['label'], stage['workerDiagnostic'],
                                              result['stderr'], receipt)
                        verify_tools(stage['label'] + '-post')
                    receipt['cases'].append({'name': case['name'], 'status': 'PASS'})
                    case_deadline = None
                verify_tools('final')
                receipt['rawLogs'] = dict(logs.hashes)
                receipt['status'] = 'PASS'
    except BaseException as error:
        if not boundary_entered:
            receipt['error'] = f'{type(error).__name__}: {error}'
            receipt_path.write_text(json.dumps(receipt, indent=2) + '\n')
        raise


def main():
    def cancel(signum, frame):
        raise KeyboardInterrupt('collector cancelled by signal ' + str(signum))

    signal.signal(signal.SIGTERM, cancel)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plan', required=True, type=Path)
    parser.add_argument('--approval', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    collect(args.plan.resolve(), args.approval.resolve(), args.output.resolve())


if __name__ == '__main__':
    main()
