#!/usr/bin/env python3
"""Indexed Dense/Sparse/Readers: full validation, seven rotated timing/RSS samples."""
import argparse
import datetime
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import signal
import statistics
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / 'experiments/s-integrate'


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


D = module('indexed_dense_validator', BASE / 'measurement-samples-run.py')
R = module('indexed_readers_validator', BASE / 'measurement-samples-readers-run.py')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def stamp():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def child(command, folder, launcher):
    output = folder / 'child-output.txt'
    rss = folder / 'child-rss.json'
    rss.unlink(missing_ok=True)
    start = time.monotonic()
    started = stamp()
    with output.open('w') as stream:
        process = subprocess.Popen([str(launcher), str(rss), *map(str, command)],
                                   stdout=stream, stderr=stream, start_new_session=True)
        try:
            code = process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait()
            return {'status': 'FAIL', 'error': 'five-second process-group deadline',
                    'startedAt': started, 'finishedAt': stamp()}, None
    meta = {'status': 'PASS' if code == 0 else 'FAIL', 'exitCode': code,
            'wholeProcessSeconds': time.monotonic() - start,
            'startedAt': started, 'finishedAt': stamp()}
    text = output.read_text()
    if code != 0:
        meta['error'] = text[-2000:]
        return meta, None
    values = json.loads(rss.read_text())
    assert values['exitCode'] == 0
    meta.update(peakRssKiB=values['childPeakRssKiB'],
                launcherInheritedPeakRssKiB=values['launcherPeakRssKiB'])
    return meta, text


def stats(values):
    return {'raw': values, 'min': min(values), 'median': statistics.median(values),
            'max': max(values)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--overlay', required=True, type=Path)
    parser.add_argument('--build-dir', required=True, type=Path)
    parser.add_argument('--lane', choices=('dense-sparse', 'readers'), required=True)
    parser.add_argument('--cpu', type=int, default=2)
    args = parser.parse_args()
    os.sched_setaffinity(0, {args.cpu})
    args.build_dir.mkdir(parents=True, exist_ok=False)
    validator = D if args.lane == 'dense-sparse' else R
    entry = 'measurement-samples-bend.bend' if validator is D else 'measurement-samples-readers.bend'
    reference = BASE / 'measurement-samples-reference.mjs' if validator is D else ROOT / 'experiments/s-perf/readers-reference.mjs'
    manifest = json.loads((args.overlay / 'overlay.json').read_text())
    evidence = {'status': 'INCOMPLETE', 'lane': args.lane, 'overlay': manifest,
                'startedAt': stamp(), 'cpuAffinity': [args.cpu], 'iterations': 64,
                'warmupWorlds': 1, 'measuredWorlds': 1, 'repetitions': 7,
                'limitsSeconds': {'checker': 5, 'runtime': 5, 'codegen': 30, 'clang': 120},
                'clock': 'Bend IO.now integer ms; TS performance.now; inner interval',
                'rssMethod': 'exec-reset small C launcher wait4(actual child), Linux KiB',
                'isolation': 'affinity only; machine is not exclusively reserved',
                'runnerSHA256': sha(Path(__file__)), 'referenceSHA256': sha(reference),
                'validatorSHA256': sha(Path(validator.__file__)),
                'fullReferenceSHA256': sha(BASE / 'measurement-reference.mjs'),
                'compiler': D.B.command(['bend', 'version']).strip(),
                'node': D.B.command(['node', '--version']).strip(),
                'cases': []}

    def save():
        (args.build_dir / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')

    save()
    try:
        launcher = args.build_dir / 'rss-launcher'
        launcher_source = BASE / 'measurement-samples-rss-launcher.c'
        D.B.command(['clang', '-O2', launcher_source, '-o', launcher], timeout=120)
        evidence['launcherSourceSHA256'] = sha(launcher_source)
        evidence['launcherSHA256'] = sha(launcher)
        programs = D.B.build(args.overlay / 'experiments/s-integrate' / entry, args.build_dir)
        evidence['artifacts'] = {p.name: sha(p) for p in programs}
        workloads = ('dense', 'sparse') if validator is D else ('readers',)
        for schema, number in (('Motion', 0), ('Health', 1)):
            for workload in workloads:
                for count in (64, 256, 1024):
                    sparse = workload == 'sparse'
                    ref = json.loads(D.B.command(['node', BASE / 'measurement-reference.mjs',
                                                 schema, workload, str(count)]))
                    bend_args = [str(number), str(int(sparse)), str(count), '1'] if validator is D else [str(number), str(count)]
                    ts_args = [schema, workload, str(count), '1'] if validator is D else [schema, str(count)]
                    commands = {'Native': [programs[0], *bend_args, '--threads', '1', '--gpu', 'off'],
                                'JS': ['node', programs[1], *bend_args],
                                'TS': ['node', reference, *ts_args]}
                    case = {'schema': schema, 'workload': workload, 'count': count,
                            'commands': {b: list(map(str, c)) for b, c in commands.items()},
                            'verification': {}, 'samples': {b: [] for b in commands}}
                    evidence['cases'].append(case)

                    def run(backend):
                        meta, text = child(commands[backend], args.build_dir, launcher)
                        if text is not None:
                            try:
                                checked = (validator.checked(backend, text, schema, sparse, count, 1, ref)
                                           if validator is D else validator.checked(backend, text, schema, count, ref))
                                meta.update(checked)
                            except (AssertionError, ValueError, KeyError) as error:
                                meta.update(status='FAIL', error=str(error))
                        return meta

                    for backend in commands:
                        case['verification'][backend] = run(backend)
                        save()
                    if not all(v['status'] == 'PASS' for v in case['verification'].values()):
                        case['status'] = 'PREREQUISITE_FAILED'
                        save()
                        print(schema, workload, count, case['status'], flush=True)
                        continue
                    for repetition in range(7):
                        order = ['Native', 'TS', 'JS']
                        offset = repetition % 3
                        order = order[offset:] + order[:offset]
                        for backend in order:
                            sample = run(backend)
                            sample.update(repetition=repetition + 1, backendOrder=order)
                            case['samples'][backend].append(sample)
                            save()
                    complete = all(len(samples) == 7 and all(s['status'] == 'PASS' for s in samples)
                                   for samples in case['samples'].values())
                    case['status'] = 'MEASURED' if complete else 'REPETITION_FAILED'
                    if complete:
                        case['summary'] = {backend: {
                            'milliseconds': stats([s['milliseconds'] for s in samples]),
                            'peakRssKiB': stats([s['peakRssKiB'] for s in samples])}
                            for backend, samples in case['samples'].items()}
                        medians = {b: v['milliseconds']['median'] for b, v in case['summary'].items()}
                        case['ratios'] = {b + '/TS': medians[b] / medians['TS'] for b in ('Native', 'JS')}
                        case['resolutionLimited'] = any(s['milliseconds'] < 10 for s in case['samples']['Native'])
                        case['acceptance'] = 'descriptive only; numerical thresholds unapproved'
                    save()
                    print(schema, workload, count, case['status'], case.get('ratios'), flush=True)
        assert all(sha(args.overlay / p) == value for p, value in manifest['sources'].items()), 'overlay drift'
        evidence['status'] = 'MEASURED' if all(c['status'] == 'MEASURED' for c in evidence['cases']) else 'PARTIAL'
    except Exception as error:
        evidence.update(status='FAIL', error=str(error))
    evidence['finishedAt'] = stamp()
    save()
    print(evidence['status'], evidence.get('error'), flush=True)
    return int(evidence['status'] == 'FAIL')


if __name__ == '__main__':
    sys.exit(main())
