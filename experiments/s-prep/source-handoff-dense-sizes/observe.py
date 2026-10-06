#!/usr/bin/env python3
"""Read a prospectively pinned cohort and compare complete Dense observations.

Raw diagnosis only: this does not create a canonical packet or authorize a keep.
The plan binds every consumed source/build/recipe file and executable argv.
"""
import argparse
import hashlib
import importlib.util
import json
import math
import os
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'experiments/s-prep/fivehour-connected-gates'))
import supervisor


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def verify(pins):
    for path, expected in pins.items():
        if digest(path) != expected:
            raise ValueError('input drift: ' + path)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--plan', type=Path, required=True)
    parser.add_argument('--schema', choices=['Motion', 'Health'], required=True)
    parser.add_argument('--count', type=int, choices=[64,1024], required=True)
    parser.add_argument('--rotation', type=int, choices=range(7), required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(exist_ok=False)
    os.sched_setaffinity(0, {11})
    receipt = {'status': 'INCOMPLETE', 'scope': 'Raw Dense diagnosis; no keep, noise qualification or full-matrix acceptance',
               'schema': args.schema, 'count': args.count, 'rotation': args.rotation, 'CPU': 11,
               'planSHA256': digest(args.plan), 'commands': []}

    def save():
        (args.output / 'evidence.json').write_text(json.dumps(receipt, indent=2) + '\n')

    peaks = {}
    rss_wrapper = ROOT / 'experiments/s-prep/source-handoff-observations/child-rss.py'

    def run(role, argv):
        if argv[0] in ['node', 'git']:
            argv = [str(Path(shutil.which(argv[0])).resolve()), *argv[1:]]
        env = {'PATH': '/usr/local/bin:/usr/bin:/bin', 'LANG': 'C.UTF-8', 'LC_ALL': 'C.UTF-8'}
        measured = role in ['TS','JS','Native']
        rss_path = args.output / (role + '-rss.json')
        executed = [sys.executable, str(rss_wrapper), '--receipt', str(rss_path), '--', *argv] if measured else argv
        code, output = supervisor.execute(executed, 5, env=env)
        if measured and code == 0:
            rss = json.loads(rss_path.read_text())
            assert rss['status'] == 'CHILD_PEAK_RSS_PASS' and rss['argv'] == argv
            assert rss['environment'] == env and rss['exit'] == 0 and not rss['timeout']
            assert rss['childLimitSeconds'] == 5
            peak = rss['peakRSSKiB']
            assert isinstance(peak, int) and not isinstance(peak, bool) and peak > 0
            peaks[role] = peak

        log = args.output / (role + '.txt')
        log.write_text(output)
        receipt['commands'].append({'role': role, 'argv': argv, 'limitSeconds': 5,
                                    'environment': env, 'executedArgv': executed, 'exit': code, 'outputSHA256': digest(log)})
        if measured and rss_path.exists():
            receipt['commands'][-1].update(rssPath=str(rss_path), rssSHA256=digest(rss_path))
        save()
        if code:
            raise ValueError(role + ' failed: ' + output[-1000:])
        return output

    try:
        plan = json.loads(args.plan.read_text())
        assert plan['scope'] == 'RAW_SOURCE_HANDOFF_DENSE_SIZES_DIAGNOSTIC'
        assert plan['counts'] == [64,1024] and plan['iterations'] == 64 and plan['batch'] == 64
        assert plan['observerSHA256'] == digest(__file__)
        pins = plan['pins']
        verify(pins)
        reference = ROOT / '.references/bevy-ts'
        assert run('reference-head', ['git', '-C', str(reference), 'rev-parse', 'HEAD']).strip() == '3040a3b2a3f28fa8554d856f9ccb6bf5433fa334'
        assert not run('reference-clean', ['git', '-C', str(reference), 'status', '--porcelain', '--untracked-files=all', '--', 'packages/core/src']).strip()
        required = [Path(__file__), ROOT / 'experiments/s-prep/source-handoff-dense-sizes/prepare-ts.py',
                    ROOT / 'experiments/s-integrate/measurement-samples-reference.mjs',
                    ROOT / 'experiments/s-integrate/measurement-bend-run.py',
                    ROOT / 'experiments/s-prep/fivehour-connected-gates/supervisor.py', rss_wrapper]
        assert all(str(path) in pins for path in required)
        assert str(Path(shutil.which('node')).resolve()) in pins
        assert str(Path(shutil.which('git')).resolve()) in pins
        assert str(Path(sys.executable).resolve()) in pins
        assert all(str(path) in pins for path in (reference / 'packages/core/src').rglob('*') if path.is_file())
        roles = plan['schemas'][args.schema][str(args.count)]['roles']
        assert len(roles) == 2 and {r['name'] for r in roles} == {'JS','Native'}
        for role in roles:
            assert role['argv'] and all(isinstance(arg, str) for arg in role['argv'])
            if role['name'] == 'JS':
                assert len(role['argv']) == 2 and role['argv'][0] == 'node'
            else:
                assert role['argv'][1:] == ['--threads', '1', '--gpu', 'off']
            program = role['argv'][1] if role['argv'][0] == 'node' else role['argv'][0]
            assert program in pins
        ts_path = args.output / 'reference.mjs'
        run('prepare-ts', [sys.executable, str(required[1]), '--source', str(required[2]),
                           '--output', str(ts_path), '--schema', args.schema, '--batch', '64', '--count', str(args.count)])
        generated_pin = digest(ts_path)
        argv = {r['name']: r['argv'] for r in roles}
        argv['TS'] = ['node', str(ts_path)]
        order = ['TS'] + [r['name'] for r in roles]
        shift = args.rotation % 3
        order = order[shift:] + order[:shift]
        if 3 <= args.rotation < 6:
            order.reverse()
        receipt['executionOrder'] = order
        outputs = {role: run(role, argv[role]) for role in order}
        ts = json.loads(outputs['TS'])
        assert (ts['schema'], ts['count'], ts['iterations'], ts['batch']) == (args.schema, args.count, 64, 64)
        assert len(ts['samples']) == 64
        spec = importlib.util.spec_from_file_location('validator', required[3])
        validator = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(validator)
        clocks = {'TS': ts['batchMilliseconds']}
        for role in order:
            if role == 'TS':
                continue
            lines = outputs[role].splitlines()
            records = [line for line in lines if line.startswith('{')]
            elapsed = [line for line in lines if line.startswith('BATCH-MILLISECONDS:')]
            assert len(records) == 65 and len(elapsed) == 1
            for line, world in zip(records, [ts['warmup'], *ts['samples']]):
                validator.validate(line, args.schema, False, args.count, world)
                assert validator.normalized(json.loads(line), args.schema) == world['final']
            clocks[role] = float(elapsed[0].split(':', 1)[1])
        assert all(isinstance(value, (int, float)) and not isinstance(value, bool)
                   and math.isfinite(value) and value >= 0 for value in clocks.values())
        verify(pins)
        assert digest(args.plan) == receipt['planSHA256'] and digest(ts_path) == generated_pin
        for command in receipt['commands']:
            if 'rssPath' in command:
                assert digest(command['rssPath']) == command['rssSHA256']
        assert set(peaks) == set(clocks)
        receipt.update(status='COMPLETE_FIELDS_RAW_DIAGNOSTIC_PASS', phaseMS=clocks, peakRSSKiB=peaks,
                       RSSScope='Fresh Linux one-child whole-process peak; not aggregate process-tree or active-Tx memory',
                       fullWorldsPerRole=65)
    except Exception as error:
        receipt.update(status='FAIL', error=repr(error))
    finally:
        save()
    print(json.dumps({key: receipt.get(key) for key in ['status', 'schema', 'count', 'phaseMS', 'error']}))
    return 0 if receipt['status'] == 'COMPLETE_FIELDS_RAW_DIAGNOSTIC_PASS' else 1


if __name__ == '__main__':
    sys.exit(main())
