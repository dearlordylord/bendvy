#!/usr/bin/env python3
"""Run unchanged Readers observations with physical metrics in a separate TS copy."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


B = load('bounded_ts_physical', ROOT / 'experiments/t05/run.py')
P = load('prepare_ts_physical', HERE / 'ts-occupancy-prepare.py')


def validate(checkpoints):
    assert checkpoints
    for checkpoint in checkpoints:
        metrics = checkpoint['metrics']
        stored = {reader['system']: reader for reader in metrics['readers']}
        names = set(stored)
        for stream in metrics['streams']:
            assert stream['physicalBatches'] == len(stream['ticks']) == len(stream['batchLengths'])
            assert stream['physicalValues'] == sum(stream['batchLengths']) == stream['size']
            for reader in stream['readers']:
                assert reader['system'] in names
                assert reader['streamLastRun'] == stored[reader['system']]['streamLastRun']
                assert reader['registeredAt'] == stored[reader['system']]['registeredAt']
                assert reader['unread'] == sum(length for tick, length in zip(stream['ticks'], stream['batchLengths'])
                                                if tick > reader['streamLastRun'])
                assert reader['lagged'] == (stream['droppedThrough'] > max(reader['streamLastRun'], reader['registeredAt']))
        for log in metrics['lifecycle']:
            assert log['physicalValues'] == len(log['ids']) == len(log['ticks'])
            for reader in log['readers']:
                assert reader['system'] in names
                assert reader['lastRun'] == stored[reader['system']]['lastRun']
                assert reader['registeredAt'] == stored[reader['system']]['registeredAt']
                assert reader['unread'] == sum(tick > reader['lastRun'] for tick in log['ticks'])
                assert reader['lagged'] == (log['droppedThrough'] > max(reader['lastRun'], reader['registeredAt']))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build-dir', required=True, type=Path)
    parser.add_argument('--cpu', type=int, default=4)
    args = parser.parse_args()
    os.sched_setaffinity(0, {args.cpu})
    args.build_dir.mkdir(parents=True, exist_ok=False)
    manifest = P.prepare(args.build_dir / 'reference')
    source = (HERE / 'readers-reference.mjs').read_text()
    source = source.replace("from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts'",
                            'from ' + json.dumps(str(args.build_dir.resolve() / 'reference/packages/core/src/index.ts')))
    source = source.replace("new URL('../../.references/sources.json',import.meta.url)",
                            json.dumps(str(ROOT / '.references/sources.json')))
    old = '  const expected=new Map(),ids=[],transients=[],audit=[],diagnostics=[];'
    assert source.count(old) == 1
    source = source.replace(old, old + '\n  const physical=[];')
    old = "  const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);"
    assert source.count(old) == 1
    source = source.replace(old, '''  const capturePhysical=boundary=>physical.push({boundary,phase,iteration,metrics:runtime.physicalDiagnostics()});
  const tick=(...steps)=>{assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);capturePhysical('schedule-complete');};
  runtime.debug.observe(event=>capturePhysical(event.type));''')
    old = '    initialPublicDiagnostics:diagnostics.slice(0,2),diagnostics,audit,'
    assert source.count(old) == 1
    source = source.replace(old, '    physical,\n' + old)
    adapter = args.build_dir / 'readers-physical.mjs'
    adapter.write_text(source)
    evidence = {'scope': 'separate actual TS Readers diagnostic replay; no timing ratios',
                'status': 'INCOMPLETE', 'manifest': manifest, 'cpuAffinity': [args.cpu],
                'adapterSHA256': hashlib.sha256(source.encode()).hexdigest(), 'cases': [],
                'controls': [], 'runtimeLimitSeconds': 5}
    for schema in ('Motion', 'Health'):
        for count in (64, 256, 1024):
            case = {'schema': schema, 'count': count}
            evidence['cases'].append(case)
            try:
                original = json.loads(B.command(['node', HERE / 'readers-reference.mjs', schema, str(count)]))
                raw = B.command(['node', adapter, schema, str(count)])
                actual = json.loads(raw)
                (args.build_dir / f'{schema}-{count}.json').write_text(raw)
                for label in ('warmup', 'sample'):
                    checkpoints = actual[label].pop('physical')
                    validate(checkpoints)
                    expected = dict(original[label])
                    actual[label].pop('executionMilliseconds')
                    expected.pop('executionMilliseconds')
                    assert actual[label] == expected, 'instrumentation changed authored observations'
                    assert max(c['metrics']['peaks']['stagedCommands'] for c in checkpoints) >= count
                    assert any(s['physicalValues'] > 0 for c in checkpoints for s in c['metrics']['streams'])
                    assert any(len(s['readers']) == 2 for c in checkpoints for s in c['metrics']['streams'])
                    assert any(r['registeredAt'] > 0 for c in checkpoints for r in c['metrics']['readers'])
                    assert any(s['physicalValues'] > 0 and all(r['unread'] == 0 for r in s['readers'])
                               for c in checkpoints for s in c['metrics']['streams'])
                    case[label] = {'checkpoints': len(checkpoints),
                        'peakRetainedPings': max((s['physicalValues'] for c in checkpoints for s in c['metrics']['streams']), default=0),
                        'peakPingBatches': max((s['physicalBatches'] for c in checkpoints for s in c['metrics']['streams']), default=0),
                        'peakPendingCommands': max(c['metrics']['peaks']['pendingCommands'] for c in checkpoints),
                        'peakStagedCommands': max(c['metrics']['peaks']['stagedCommands'] for c in checkpoints),
                        'peakStagedEvents': max(c['metrics']['peaks']['stagedEvents'] for c in checkpoints),
                        'peakComponentInverses': max(c['metrics']['componentInversePeak'] for c in checkpoints),
                        'peakMarkCells': max(c['metrics']['allocatedMarkCells'] for c in checkpoints)}
                case['status'] = 'FULL_OBSERVATIONS_EQUAL_PHYSICAL_CONSISTENT'
            except Exception as error:
                case.update(status='FAIL', error=str(error))
            (args.build_dir / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
            print(schema, count, case['status'], case.get('error'), flush=True)
    # Runtime-executed counter mutations leave the callback data untouched.
    # Physical values are checked against independent cached sizes and stored
    # cursor objects; an empty delivery is not used as a retention assertion.
    mutations = [
        ('cached-size', 'internal/streams.ts', 'size: log?.size ?? 0,', 'size: 0,'),
        ('omitted-batch-values', 'internal/streams.ts',
         'physicalValues: (log?.batches ?? []).reduce',
         'physicalValues: (log?.batches ?? []).slice(1).reduce'),
        ('lost-holder', 'Runtime.ts', 'logPresent: entry.logPresent,\n      readers: entry.readers.map(cursor => {',
         'logPresent: entry.logPresent,\n      readers: entry.readers.slice(1).map(cursor => {'),
    ]
    for label, name, before, after in mutations:
        folder = args.build_dir / label
        shutil.copytree(args.build_dir / 'reference', folder / 'reference')
        modified = folder / 'reference/packages/core/src' / name
        text = modified.read_text()
        assert text.count(before) == 1
        modified.write_text(text.replace(before, after))
        mutated_adapter = folder / 'readers-physical.mjs'
        mutated_adapter.write_text(source.replace(
            str(args.build_dir.resolve() / 'reference/packages/core/src/index.ts'),
            str(folder.resolve() / 'reference/packages/core/src/index.ts')))
        control = {'mutation': label, 'status': 'UNRESOLVED',
                   'mutatedSourceSHA256': hashlib.sha256(modified.read_bytes()).hexdigest()}
        evidence['controls'].append(control)
        try:
            raw = B.command(['node', mutated_adapter, 'Motion', '64'])
            actual = json.loads(raw)
            original = json.loads(B.command(['node', HERE / 'readers-reference.mjs', 'Motion', '64']))
            witnesses = []
            for variant in ('warmup', 'sample'):
                checkpoints = actual[variant].pop('physical')
                expected = dict(original[variant])
                actual[variant].pop('executionMilliseconds')
                expected.pop('executionMilliseconds')
                assert actual[variant] == expected, 'counter mutant changed callback behavior'
                try:
                    validate(checkpoints)
                    assert any(len(s['readers']) == 2 for c in checkpoints for s in c['metrics']['streams'])
                except AssertionError:
                    witnesses.append(variant)
            assert witnesses, 'runtime counter mutant survived'
            control.update(status='DETECTED_CALLBACKS_UNCHANGED', witnesses=witnesses,
                           outputSHA256=hashlib.sha256(raw.encode()).hexdigest())
        except Exception as error:
            control.update(status='FAIL', error=str(error))
        (args.build_dir / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    evidence['status'] = 'PASS' if all(c['status'].startswith('FULL_') for c in evidence['cases']) else 'FAIL'
    if not all(c['status'] == 'DETECTED_CALLBACKS_UNCHANGED' for c in evidence['controls']):
        evidence['status'] = 'FAIL'
    (args.build_dir / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    return int(evidence['status'] != 'PASS')


if __name__ == '__main__':
    sys.exit(main())
