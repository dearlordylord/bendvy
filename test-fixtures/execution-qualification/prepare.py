#!/usr/bin/env python3
"""Freeze existing sources, independently reviewed oracles and tool snapshots."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import sys
import sysconfig


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def closure(entries):
    found = set()
    todo = list(entries)
    while todo:
        path = todo.pop().resolve(strict=True)
        if path in found:
            continue
        found.add(path)
        for line in path.read_text().splitlines():
            words = line.strip().split()
            if len(words) >= 2 and words[0] == 'import':
                if words[1] == 'Base':
                    continue
                if Path(words[1]).is_absolute() or not words[1].endswith('.bend'):
                    raise ValueError('unresolved nonrelative Bend import: ' + line)
                todo.append(path.parent / words[1])
    return found


def prepare(root, snapshots_path, output, destination, source_commit, query_oracle):
    package = Path(__file__).resolve().parent
    groups = json.loads(snapshots_path.read_text())
    env = groups[0]['configuration']['env']
    tools = groups[0]['configuration']['tools']
    cpu = groups[0]['configuration']['cpu']
    taskset = groups[0]['configuration']['taskset']
    cases = [
        ('core', 'examples/parallel-execution/main.bend', 'examples/parallel-execution/expected.stdout'),
        ('query', 'examples/parallel-query/main.bend', str(query_oracle)),
        ('schedule', 'test-fixtures/dependency-schedules/ordinary/main.bend', 'test-fixtures/dependency-schedules/ordinary/expected.stdout'),
        ('schedule-plan', 'test-fixtures/dependency-schedules/plan-controls.bend', 'test-fixtures/dependency-schedules/plan-controls.expected.stdout'),
        ('schedule-admission', 'test-fixtures/dependency-schedules/ordinary/admission-controls.bend', 'test-fixtures/dependency-schedules/ordinary/admission-controls.expected.stdout'),
        ('pair', 'test-fixtures/parallel-systems/main.bend', 'test-fixtures/parallel-systems/expected.stdout'),
    ]
    files = closure([root / entry for _, entry, _ in cases])
    files.update(root / oracle for _, _, oracle in cases)
    files.update(root / name for name in ['examples/parallel-query/oracle.py',
                                         'test-fixtures/parallel-systems/reference.py',
                                         'test-fixtures/dependency-schedules/ordinary/reference.py'])
    files.update(package.glob('*.py'))
    files.add(snapshots_path)
    for name in ['task_runner.py', 'receipt-logs.py', 'evidence_boundary.py', 'owned-tool-pins.py']:
        files.add(root / 'scripts' / name)
    directories = {str(Path(sysconfig.get_path('stdlib')).resolve()): None}
    aliases = {}
    for name in ['/tmp/bendvy-clang19-diagnostic/root',
                 '/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu',
                 '/usr/include', '/usr/lib/gcc', '/usr/lib/aarch64-linux-gnu',
                 '/usr/aarch64-linux-gnu', '/etc/ld.so.conf.d']:
        if Path(name).is_dir():
            directories[name] = None
            aliases[name] = str(Path(name).resolve(strict=True))
    for name in ['/usr/bin/ld', '/usr/bin/as', '/usr/bin/gcc']:
        files.add(Path(name))
        aliases[name] = str(Path(name).resolve(strict=True))
    for group in groups:
        for name, digest in group['snapshot']['pins'].items():
            if sha(name) != digest:
                raise RuntimeError('prepared tool snapshot is stale: ' + name)
            files.add(Path(name))
        config = group['configuration']
        for name in [*config['tools'].values(), config['ldd'], config['taskset'],
                     *config['resource_roots']]:
            aliases[name] = str(Path(name).resolve(strict=True))
        for directory in config['resource_roots']:
            directories[directory] = None
    for name in directories:
        directories[name] = {str(p.relative_to(name)): sha(p)
                             for p in sorted(Path(name).rglob('*')) if p.is_file()}
    frozen_cases = []
    labels = []
    probe_counts = [len(group['configuration']['tools']) - len(group['configuration'].get('skip_ldd', []))
                    for group in groups]

    def probes(prefix):
        for index, count in enumerate(probe_counts):
            labels.extend(f'{prefix}-tools{index}-{number}' for number in range(count))

    probes('initial')
    for name, entry, oracle in cases:
        js, c, native = [name + extension for extension in ['.js', '.c', '.native']]
        artifact = lambda value: '{ARTIFACTS}/' + value
        stages = []

        def stage(suffix, argv, timeout, consumes=(), produces=(), compare=False):
            label = name + '-' + suffix
            stages.append(dict(label=label, argv=argv, timeoutSeconds=timeout,
                               expectedExit=0, consumes=list(consumes), produces=list(produces),
                               serializesSource=suffix.startswith('emit-'),
                               **({'oracle': str(root / oracle)} if compare else {})))
            probes(label + '-pre')
            labels.append(label)
            probes(label + '-post')

        stage('emit-js', [taskset, '-c', str(cpu), tools['bend'], str(root / entry), '-o', artifact(js)], 300, produces=[js])
        stage('js', [taskset, '-c', str(cpu), tools['node'], artifact(js)], 360, consumes=[js], compare=True)
        stage('emit-c', [taskset, '-c', str(cpu), tools['bend'], str(root / entry), '-o', artifact(c)], 300, produces=[c])
        stage('clang', [taskset, '-c', str(cpu), tools['clang_wrapper'], '-O3', artifact(c), '-o', artifact(native), '-pthread', '-lm'], 120, consumes=[c], produces=[native])
        for workers in [1, 4]:
            stage('native' + str(workers), [taskset, '-c', str(cpu), artifact(native), '--threads', str(workers), '--gpu', 'off'], 360, consumes=[native], compare=True)
        frozen_cases.append({'name': name, 'wallSeconds': 900, 'stages': stages})
    probes('final')
    presence_paths = ['/etc/ld.so.cache', '/etc/ld.so.preload', '/etc/ld.so.conf',
                      str(Path(env['HOME']) / '.bend/config'),
                      str(Path(env['HOME']) / '.bend/config.json')]
    plan = dict(schema=1, status='DRAFT_NOT_ADMITTED', sourceCommit=source_commit,
                root=str(root), output=str(output), python=tools['python'],
                environment=env, toolSnapshots=groups, aliases=aliases,
                files={str(path.resolve(strict=True)): sha(path) for path in sorted(files)},
                directories=directories,
                presence={name: sha(name) if Path(name).is_file() else None for name in presence_paths},
                heavyLock='/tmp/bendvy-parity-heavy.lock',
                sourceLock=f'/tmp/bendvy-source-check-{os.getuid()}-cpu-{cpu}.lock',
                labels=labels, cases=frozen_cases,
                pendingCases=['ordinary compatible ready-set successor', 'Rust reference collector',
                              'semantic runtime worker-use diagnostic', 'compile-time authority cohort'],
                prerequisites=['independent launch review of collector and exact plan',
                               'current-source independent full-oracle review for every selected case',
                               'schema and condition authority repairs integrated and source-checked',
                               'one ordinary full-oracle development run per backend retained for each case'])
    destination.write_text(json.dumps(plan, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--tool-snapshots', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--plan', type=Path, required=True)
    parser.add_argument('--source-commit', required=True)
    parser.add_argument('--query-oracle', required=True, type=Path)
    args = parser.parse_args()
    prepare(args.root.resolve(), args.tool_snapshots.resolve(), args.output.resolve(),
            args.plan.resolve(), args.source_commit, args.query_oracle.resolve())


if __name__ == '__main__':
    main()
