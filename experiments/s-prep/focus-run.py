#!/usr/bin/env python3
"""One selected frozen Dense/Sparse case: full validation and bounded child RSS.

Default is a one-shot preparation control, not noise qualification or a keep.
Seven repetitions are supported solely for a future explicitly accepted contract.
"""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location('frozen_measurement', ROOT / 'experiments/s-perf/measure-run.py')
M = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(M)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--overlay', type=Path, required=True)
    parser.add_argument('--build-dir', type=Path, required=True)
    parser.add_argument('--schema', choices=('Motion', 'Health'), required=True)
    parser.add_argument('--workload', choices=('dense', 'sparse'), required=True)
    parser.add_argument('--count', type=int, choices=(64, 256, 1024), required=True)
    parser.add_argument('--repetitions', type=int, choices=(1, 7), default=1)
    parser.add_argument('--cpu', type=int, default=2)
    args = parser.parse_args()
    os.sched_setaffinity(0, {args.cpu})
    args.build_dir.mkdir(parents=True, exist_ok=False)
    manifest = json.loads((args.overlay / 'overlay.json').read_text())
    result = {'status': 'INCOMPLETE', 'schema': args.schema, 'workload': args.workload,
              'count': args.count, 'repetitions': args.repetitions, 'cpu': args.cpu,
              'scope': 'Finite full-field evaluation; no contract acceptance, improvement or keep claim',
              'warmup': 'fresh warmup and measured worlds in same child',
              'iterations': 64, 'batch': 1, 'overlay': manifest,
              'runnerSHA256': M.sha(Path(__file__)),
              'protectedRunnerSHA256': M.sha(ROOT / 'experiments/s-perf/measure-run.py'),
              'validatorSHA256': M.sha(Path(M.D.__file__)),
              'startedAt': M.stamp(), 'verification': {}, 'samples': []}

    def save():
        (args.build_dir / 'evidence.json').write_text(json.dumps(result, indent=2) + '\n')

    def unchanged():
        if not all(M.sha(args.overlay / p) == h for p, h in manifest['sources'].items()):
            raise ValueError('candidate source drift')

    try:
        unchanged()
        source = M.BASE / 'measurement-samples-rss-launcher.c'
        launcher = args.build_dir / 'rss-launcher'
        M.D.B.command(['clang', '-O2', source, '-o', launcher], timeout=120)
        programs = M.D.B.build(args.overlay / 'experiments/s-integrate/measurement-samples-bend.bend', args.build_dir)
        result['artifacts'] = {p.name: M.sha(p) for p in programs}
        result['launcherSourceSHA256'] = M.sha(source)
        reference_command = ['node', M.BASE / 'measurement-reference.mjs', args.schema, args.workload, str(args.count)]
        raw = M.D.B.command(reference_command)
        reference = json.loads(raw)
        (args.build_dir / 'reference.json').write_text(raw)
        result['referenceSHA256'] = M.sha(args.build_dir / 'reference.json')
        sparse = args.workload == 'sparse'
        bend_args = [str(int(args.schema == 'Health')), str(int(sparse)), str(args.count), '1']
        commands = {'Native': [programs[0], *bend_args, '--threads', '1', '--gpu', 'off'],
                    'TS': ['node', M.BASE / 'measurement-samples-reference.mjs', args.schema, args.workload, str(args.count), '1'],
                    'JS': ['node', programs[1], *bend_args]}
        result['commands'] = {k: list(map(str, v)) for k, v in commands.items()}

        def run(backend, label):
            folder = args.build_dir / label
            folder.mkdir()
            meta, text = M.child(commands[backend], folder, launcher)
            if text is not None:
                try:
                    meta.update(M.D.checked(backend, text, args.schema, sparse, args.count, 1, reference))
                except (AssertionError, ValueError, KeyError) as error:
                    meta.update(status='FAIL', error=str(error))
            meta.update(backend=backend, rawPath=str(folder / 'child-output.txt'))
            return meta

        for backend in commands:
            result['verification'][backend] = run(backend, 'verify-' + backend)
            save()
        if not all(v['status'] == 'PASS' for v in result['verification'].values()):
            result['status'] = 'PREREQUISITE_FAILED'
        else:
            for repetition in range(args.repetitions):
                order = ['Native', 'TS', 'JS']
                offset = repetition % 3
                for backend in order[offset:] + order[:offset]:
                    sample = run(backend, f'rep-{repetition + 1}-{backend}')
                    sample['repetition'] = repetition + 1
                    result['samples'].append(sample)
                    save()
            complete = len(result['samples']) == args.repetitions * 3 and all(s['status'] == 'PASS' for s in result['samples'])
            result['status'] = 'FINITE_FULL_FIELD_PASS' if complete else 'REPETITION_FAILED'
            result['resolutionLimited'] = any(s.get('milliseconds', 0) < 10 for s in result['samples'] if s['backend'] == 'Native')
            if complete:
                result['summary'] = {b: M.stats([s['milliseconds'] for s in result['samples'] if s['backend'] == b]) for b in commands}
                medians = {b: v['median'] for b, v in result['summary'].items()}
                if medians['TS'] > 0:
                    result['descriptiveRatios'] = {b + '/TS': medians[b] / medians['TS'] for b in ('Native', 'JS')}
                else:
                    result['metricUnavailable'] = 'zero reference interval'
        unchanged()
    except Exception as error:
        result.update(status='FAIL', error=str(error))
    result['finishedAt'] = M.stamp()
    save()
    print(json.dumps({k: result[k] for k in ('status', 'schema', 'workload', 'count', 'repetitions')}, indent=2))
    return int(result['status'] != 'FINITE_FULL_FIELD_PASS')


if __name__ == '__main__':
    sys.exit(main())
