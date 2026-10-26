"""Hash-only preparation: create disposable canonical-collector control plans."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import re
import shutil


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def prepare(root, destination, snapshots, current_source_commit, worker_root):
    destination.mkdir(parents=True, exist_ok=False)
    source = root / 'test-fixtures/execution-qualification'
    reference = worker_root / 'test-fixtures/execution-qualification/collect.py'
    if sha(reference) != '0686f61e81b6d563ee6f9128de3f90a74c62e2d9836017d5dda64f8eaff7380c':
        raise RuntimeError('paired worker collector predecessor changed; coordinate new binding')
    for helper in ('task_runner.py', 'receipt-logs.py', 'evidence_boundary.py', 'owned-tool-pins.py'):
        if helper != 'task_runner.py' and (root / 'scripts' / helper).read_bytes() != (worker_root / 'scripts' / helper).read_bytes():
            raise RuntimeError('paired worker helper differs: ' + helper)
    original = json.loads(snapshots.read_text())[0]
    cfg = copy.deepcopy(original['configuration'])
    cfg.update(tools={'python': '/usr/bin/python3.11'}, resource_roots=[], skip_ldd=[])
    prior = original['snapshot']
    selected = copy.deepcopy(prior)
    selected.update(tools=cfg['tools'], resource_roots=[], skip_ldd=[],
                    resolved_libraries={'python': prior['resolved_libraries']['python']})
    probe = bytes.fromhex(selected['resolved_libraries']['python']['stdout'])
    paths = {Path(p).resolve() for p in re.findall(r'(/[^\s()]+)', probe.decode())}
    paths.update(Path(p).resolve() for p in [cfg['ldd'], cfg['taskset'], cfg['tools']['python']])
    selected['pins'] = {str(p): prior['pins'][str(p)] for p in sorted(paths)}
    # Imported discovery is evidence, not newly executed discovery. Runtime verify
    # must reproduce it through the unchanged ToolPins implementation.
    for path, digest in selected['pins'].items():
        if sha(path) != digest:
            raise RuntimeError('existing Python tool snapshot is stale: ' + path)
    names = ['source-drift', 'helper-drift', 'environment', 'interpreter', 'interpreter-flags',
             'wrong-approval', 'nonzero', 'artifact-drift', 'input-drift',
             'oracle', 'cancel', 'receipt-failure']
    manifest = {'status': 'DRAFT_NOT_ADMITTED', 'sourceRoot': str(root),
                'currentSourceCommit': current_source_commit,
                'collectorSubject': {'path': str(source / 'collect.py'), 'sha256': sha(source / 'collect.py')},
                'pairedWorkerCollector': {'path': str(reference), 'sha256': sha(reference),
                    'workerSourceCommit': '99b51d4b20d47f5b525b8803f803586d796d8948',
                    'status': 'COLLECTOR_AND_RUNNER_SUCCESSOR_REQUIRES_WORKER_REBIND'},
                'pairedWorkerPlan': {'path': '/tmp/gh80-worker-admission-v1/plan.json',
                    'sha256': sha('/tmp/gh80-worker-admission-v1/plan.json'),
                    'status': 'STALE_COLLECTOR_AND_RUNNER_BINDING_REQUIRES_SUCCESSOR_AND_REVIEW'},
                'runnerRepair': {'path': str(root / 'scripts/task_runner.py'),
                    'sha256': sha(root / 'scripts/task_runner.py'),
                    'workerPredecessorSHA256': sha(worker_root / 'scripts/task_runner.py'),
                    'workerTreeModified': False},
                'importedSnapshot': {'path': str(snapshots), 'sha256': sha(snapshots)},
                'environment': cfg['env'], 'python': cfg['tools']['python'],
                'output': str(destination / 'results'),
                'cases': [], 'files': {}, 'directories': {},
                'regression': {'timeoutSeconds': 120, 'argv': [cfg['tools']['python'], '-I', '-S', '-B',
                    str(root / 'scripts/test-task-runner.py'), '--source-bindings', str(destination / 'manifest.json'),
                    'Execution.test_frozen_loaders_ignore_matching_bytecode',
                    'Evidence.test_control_regression_failures_keep_terminal_receipt',
                    'Execution.test_caller_cancellation_cleans_owned_command',
                    'Execution.test_runner_cancellation_retains_logs_and_primary_with_secondary_failure',
                    'Execution.test_timeout_keeps_partial_bytes',
                    'Execution.test_owner_surviving_kill_preserves_cancellation',
                    'Execution.test_owner_surviving_kill_preserves_failure_result_and_handle',
                    'Execution.test_timeout_reaps_detached_descendant',
                    'Execution.test_unrelated_and_concurrent_children_survive',
                    'Execution.test_completed_result_survives_stale_poll_before_owner_death',
                    'Execution.test_runner_publication_and_postguard_failure_keep_process_result',
                    'Evidence.test_runner_logs_and_refuses_nonzero',
                    'Evidence.test_inflight_drift_retains_logs',
                    'Evidence.test_timeout_logs_and_tamper']},
                'prerequisites': ['Independent GH80 launch review of this exact control package',
                                  'No overlapping heavy execution; root confirms prior owner terminal']}
    for name in names:
        case = destination / name
        (case / 'scripts').mkdir(parents=True)
        (case / 'resources').mkdir()
        (case / 'resources/token').write_text('original\n')
        (case / 'source.txt').write_text('frozen source\n')
        (case / 'oracle.stdout').write_text('independent expected output\n')
        shutil.copyfile(source / 'collect.py', case / 'collect.py')
        shutil.copyfile(source / 'controls/child.py', case / 'child.py')
        for helper in ('task_runner.py', 'receipt-logs.py', 'evidence_boundary.py', 'owned-tool-pins.py'):
            shutil.copyfile(root / 'scripts' / helper, case / 'scripts' / helper)
        files = {str(p): sha(p) for p in sorted(case.rglob('*')) if p.is_file()}
        files.update(selected['pins'])
        # Reuse the frozen host resolver and stdlib inventory from the original
        # canonical plan; no Bend, Node or Clang resource directories are needed.
        host = json.loads((snapshots.parent / 'draft-plan.json').read_text())
        directories = {k: v for k, v in host['directories'].items()
                       if k in ('/usr/lib/python3.11', '/usr/lib/aarch64-linux-gnu', '/etc/ld.so.conf.d')}
        directories[str(case / 'resources')] = {'token': sha(case / 'resources/token')}
        stages = []
        modes = ['produce', 'artifact-drift', 'consume'] if name == 'artifact-drift' else [
            name if name in ('nonzero', 'input-drift', 'oracle', 'cancel', 'receipt-failure') else 'oracle']
        for index, mode in enumerate(modes):
            stages.append({'label': 'child-' + str(index), 'argv': [cfg['tools']['python'], '-I', '-S', '-B',
                           str(case / 'child.py'), mode, str(case)], 'timeoutSeconds': 5,
                           'expectedExit': 0, 'consumes': ['value'] if mode == 'consume' else [],
                           'produces': ['value'] if mode == 'produce' else [], 'serializesSource': False,
                           **({'oracle': str(case / 'oracle.stdout')} if name == 'oracle' else {})})
        prefixes = ['initial', 'final'] + [s['label'] + suffix for s in stages for suffix in ('-pre', '-post')]
        plan = {'root': str(case), 'output': str(case / 'actual'), 'python': cfg['tools']['python'],
                'environment': cfg['env'], 'files': files, 'aliases': {}, 'directories': directories,
                'presence': {k: v for k, v in host['presence'].items()},
                'toolSnapshots': [{'configuration': cfg, 'snapshot': selected}],
                'labels': [s['label'] for s in stages] + [p + '-tools0-0' for p in prefixes],
                'heavyLock': '/tmp/bendvy-parity-heavy.lock', 'sourceLock': str(case / 'source.lock'),
                'prerequisites': ['Synthetic refusal control only; no ECS qualification claim'],
                'cases': [{'name': name, 'wallSeconds': 40, 'stages': stages}]}
        if name == 'interpreter':
            plan['python'] = '/usr/bin/false'  # Deliberately mismatched interpreter fixture.
            plan['files']['/usr/bin/false'] = sha('/usr/bin/false')
        write(case / 'plan.json', plan)
        write(case / 'control-approval.json', {'planSHA256': '0' * 64 if name == 'wrong-approval' else sha(case / 'plan.json'),
              'verdict': 'APPROVED', 'prerequisitesSatisfied': plan['prerequisites'],
              'scope': 'synthetic approval fixture; real outer admission remains mandatory'})
        manifest['cases'].append({'name': name, 'directory': str(case), 'planSHA256': sha(case / 'plan.json')})
    manifest['files'] = {str(p): sha(p) for p in sorted(destination.rglob('*')) if p.is_file()}
    for p in [source / 'controls/run.py', source / 'controls/prepare.py', source / 'controls/child.py',
              source / 'controls/README.md', source / 'README.md',
              root / 'scripts/task_runner.py', root / 'scripts/test-task-runner.py',
              root / 'scripts/check-python-source.py',
              root / 'scripts/task-runner.md', root / 'scripts/receipt-logs.py', root / 'scripts/evidence_boundary.py']:
        manifest['files'][str(p)] = sha(p)
    manifest['files'].update(selected['pins'])
    for path in [source / 'collect.py', reference, Path('/tmp/gh80-worker-admission-v1/plan.json')]:
        manifest['files'][str(path)] = sha(path)
    manifest['directories'] = {k: v for k, v in host['directories'].items()
                               if k in ('/usr/lib/python3.11', '/usr/lib/aarch64-linux-gnu', '/etc/ld.so.conf.d')}
    write(destination / 'manifest.json', manifest)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--destination', type=Path, required=True)
    parser.add_argument('--tool-snapshots', type=Path, required=True)
    parser.add_argument('--current-source-commit', required=True)
    parser.add_argument('--worker-root', type=Path, required=True)
    args = parser.parse_args()
    prepare(args.root.resolve(), args.destination.resolve(), args.tool_snapshots.resolve(),
            args.current_source_commit, args.worker_root.resolve())
