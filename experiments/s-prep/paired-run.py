#!/usr/bin/env python3
"""Future focused evaluator: two pinned reference and two actual candidate cohorts.

This tool does not create Autoresearch state or authorize its own execution.
Default is one-shot construction/control; --repetitions 7 needs accepted authority.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import random
import shutil
import signal
import statistics
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
EDITABLE = ('experiments/s-integrate/storage.bend', 'experiments/s-integrate/query.bend')
BASELINE = '56b72f6'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def bootstrap(reference, candidate, *, seed=23):
    if not reference or not candidate or any(not math.isfinite(x) or x <= 0 for x in reference + candidate):
        raise ValueError('complete positive durations required; no sentinel metrics')
    rng = random.Random(seed)
    shifts = []
    for _ in range(10000):
        r = statistics.median(rng.choices(reference, k=len(reference)))
        c = statistics.median(rng.choices(candidate, k=len(candidate)))
        shifts.append(c / r - 1)
    shifts.sort()
    return {'medianRelativeShift': statistics.median(candidate) / statistics.median(reference) - 1,
            'percentile95Low': shifts[250], 'percentile95High': shifts[9749],
            'method': '10000 independent median bootstrap draws, seed23; observational uncertainty, no causal guarantee'}


def compare(cohorts):
    refs = [c for c in cohorts if c['role'] == 'reference']
    candidates = [c for c in cohorts if c['role'] == 'candidate']
    if len(refs) != 2 or len(candidates) != 2:
        raise ValueError('two complete reference and candidate cohorts required')
    for c in cohorts:
        d = c['evidence']
        if d['status'] != 'FINITE_FULL_FIELD_PASS' or d['repetitions'] != 7 or d['resolutionLimited']:
            return {'status': 'UNQUALIFIED', 'reason': 'failed/incomplete/resolution-limited cohort'}
        for backend in ('Native', 'TS', 'JS'):
            samples = [x for x in d['samples'] if x['backend'] == backend]
            if (len(samples) != 7 or {x.get('repetition') for x in samples} != set(range(1, 8))
                    or any(x['status'] != 'PASS' or not math.isfinite(x.get('milliseconds', float('nan')))
                           or x['milliseconds'] <= 0 for x in samples)):
                return {'status': 'UNQUALIFIED', 'reason': 'missing full-field sample'}
    contrasts = []
    reference = {b: [s['milliseconds'] for c in refs for s in c['evidence']['samples'] if s['backend'] == b] for b in ('Native', 'TS', 'JS')}
    for c in candidates:
        raw = {b: [s['milliseconds'] for s in c['evidence']['samples'] if s['backend'] == b] for b in reference}
        contrasts.append({b: bootstrap(reference[b], raw[b]) for b in raw})
    return {'status': 'COMPLETE_COMPARISON', 'contrasts': contrasts,
            'scope': 'No keep authority. All correctness/noise/contract decisions remain separate.'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--overlay', type=Path, required=True)
    parser.add_argument('--build-dir', type=Path, required=True)
    parser.add_argument('--repetitions', choices=(1, 7), type=int, default=1)
    parser.add_argument('--cpu', type=int, default=2)
    args = parser.parse_args()
    args.build_dir.mkdir(parents=True, exist_ok=False)
    result = {'status': 'INCOMPLETE', 'repetitions': args.repetitions,
              'baseline': BASELINE, 'runnerSHA256': sha(Path(__file__)),
              'metric': 'JS authored inner milliseconds, lower is better',
              'contractAccepted': False, 'cohorts': []}
    started = time.monotonic()

    def save():
        (args.build_dir / 'paired-evidence.json').write_text(json.dumps(result, indent=2) + '\n')

    try:
        manifest = json.loads((args.overlay / 'overlay.json').read_text())
        for p, h in manifest['sources'].items():
            if sha(args.overlay / p) != h:
                raise ValueError('candidate overlay drift')
        reference = args.build_dir / 'reference-overlay'
        shutil.copytree(args.overlay, reference)
        ref_manifest = dict(manifest)
        ref_manifest['sources'] = dict(manifest['sources'])
        for path in EDITABLE:
            content = subprocess.check_output(['git', '-C', str(ROOT), 'show', f'{BASELINE}:experiments/s-perf/candidate/{Path(path).name}'], timeout=5)
            (reference / path).write_bytes(content)
            ref_manifest['sources'][path] = sha(reference / path)
        ref_manifest['scope'] = 'Pinned #20 reference; only two declared candidate subjects differ'
        (reference / 'overlay.json').write_text(json.dumps(ref_manifest, indent=2) + '\n')
        # Reject unexpected drift in supposedly protected baseline modules.
        pinned = json.loads((ROOT / 'experiments/s-perf/main-evidence.json').read_text())['overlay']['sources']
        if set(manifest['sources']) != set(pinned):
            raise ValueError('source closure changed; explicit scope transition required')
        for path, h in pinned.items():
            if path not in EDITABLE and manifest['sources'][path] != h:
                raise ValueError(f'protected source drift: {path}')
        for index, role in enumerate(('reference', 'candidate', 'reference', 'candidate'), 1):
            folder = args.build_dir / f'{index}-{role}'
            command = [sys.executable, str(ROOT / 'experiments/s-prep/focus-run.py'), '--overlay', str(reference if role == 'reference' else args.overlay), '--build-dir', str(folder), '--schema', 'Health', '--workload', 'dense', '--count', '256', '--repetitions', str(args.repetitions), '--cpu', str(args.cpu)]
            # Outer bound covers existing bounded check/build/sample phases. It
            # does not extend any checker/runtime/codegen/compiler child limit.
            process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, start_new_session=True)
            try:
                out, err = process.communicate(timeout=330)
            except subprocess.TimeoutExpired:
                import os
                os.killpg(process.pid, signal.SIGKILL)
                process.communicate()
                raise RuntimeError('bounded evaluator cohort deadline')
            record = {'role': role, 'command': command, 'exitCode': process.returncode,
                      'stdout': out, 'stderr': err}
            if (folder / 'evidence.json').exists():
                record['evidence'] = json.loads((folder / 'evidence.json').read_text())
                record['evidenceSHA256'] = sha(folder / 'evidence.json')
            result['cohorts'].append(record)
            save()
            if process.returncode or record.get('evidence', {}).get('status') != 'FINITE_FULL_FIELD_PASS':
                raise RuntimeError('full-field cohort failed; no metric')
        for p, h in manifest['sources'].items():
            if sha(args.overlay / p) != h:
                raise ValueError('candidate overlay changed during cohorts')
        result['status'] = 'FINITE_CONTROL_PASS' if args.repetitions == 1 else 'COMPLETE_COMPARISON'
        if args.repetitions == 7:
            result['comparison'] = compare(result['cohorts'])
            if result['comparison']['status'] != 'COMPLETE_COMPARISON':
                result['status'] = 'UNQUALIFIED'
        if result['status'] == 'COMPLETE_COMPARISON':
            medians = [c['evidence']['summary']['JS']['median'] for c in result['cohorts'] if c['role'] == 'candidate']
            result['metricJSInnerMilliseconds'] = statistics.median(medians)
        else:
            result['metricUnavailable'] = 'one-shot/unqualified/failed evidence is not a qualified metric'
    except Exception as error:
        result.update(status='FAIL', error=str(error), metricUnavailable='evaluation failed before qualified metric')
    result['wallSeconds'] = time.monotonic() - started
    save()
    print(json.dumps({k:v for k,v in result.items() if k != 'cohorts'}, indent=2))
    return int(result['status'] not in ('FINITE_CONTROL_PASS', 'COMPLETE_COMPARISON'))


if __name__ == '__main__':
    sys.exit(main())
