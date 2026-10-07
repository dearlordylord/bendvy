#!/usr/bin/env python3
"""Prepare source-bound staged workloads. No builds, executions or verdicts."""
import argparse, hashlib, json, pathlib, shutil
import preflight, workloads
ROOT = preflight.ROOT
HERE = pathlib.Path(__file__).resolve().parent

def inventory(directory):
    return {str(p.relative_to(directory)): preflight.digest(p) for p in sorted(directory.rglob('*')) if p.is_file()}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    assert not args.output.exists(), 'Stage must be fresh'
    sources, external = preflight.snapshot(), preflight.external()
    args.output.mkdir(parents=True)
    stage = args.output / 'stage'
    stage.mkdir()
    for name, digest in sources.items():
        src = ROOT / name
        dst = stage / name
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        assert preflight.digest(dst) == digest
    harness = stage / 'feature-harness'
    harness.mkdir()
    for name in ['timing.bend', 'timing.c', 'timing.js', 'capture.mjs']:
        shutil.copy2(HERE / name, harness / name)
    changes = {}
    for name in ['app.bend', 'other.bend']:
        path = stage / 'experiments/public-nested-provision' / name
        before = preflight.digest(path)
        path.write_text(workloads.adapt_nested(path.read_text()))
        changes[str(path.relative_to(stage))] = {'before': before, 'after': preflight.digest(path), 'purpose': 'Common missing-resource refusal without supplemental Bend-only repair; service-only repair retained'}
    for name in ['driver.bend', 'added-controls.bend']:
        path = stage / 'experiments/public-schedule-readers' / name
        before = preflight.digest(path)
        text = path.read_text()
        assert text.count('IO.print(') == {'driver.bend': 1, 'added-controls.bend': 3}[name], (name, 'capture seam drift')
        path.write_text('import ../../feature-harness/timing.bend as Bench\n' + text.replace('IO.print(', 'Bench.capture('))
        changes[str(path.relative_to(stage))] = {'before': before, 'after': preflight.digest(path), 'purpose': 'Capture complete materialized output rather than flush in timed region'}
    nested = stage / 'experiments/public-nested-provision/feature-reference.mjs'
    nested.write_text(workloads.nested_ts((stage / 'experiments/public-nested-provision/reference.mjs').read_text()))
    references = {
        'nested': [('nested-reference.mjs', nested)] * 2,
        'readers': [('readers-reference.mjs', stage / 'experiments/public-schedule-readers/reference.mjs'), ('added-reference.mjs', stage / 'experiments/public-schedule-readers/added-reference.mjs')],
        'fragments': [('fragments-reference.mjs', stage / 'experiments/public-schema-fragments/application-reference.mjs')],
    }
    for feature in workloads.FEATURES:
        refs = references[feature]
        for name, original in refs:
            adapted = harness / name
            adapted.write_text(workloads.callable_ts(original.read_text()))
            changes[str(adapted.relative_to(stage))] = {'source': str(original.relative_to(stage)), 'before': preflight.digest(original), 'after': preflight.digest(adapted), 'purpose': 'Static imports outside timing; unchanged authored statements inside fresh callable lifecycle'}
        for batches in [1, 2, 4]:
            name = f'{feature}-{batches}'
            (harness / (name + '.bend')).write_text(workloads.bend_entry(feature, batches))
            imports = "\n".join(f"import {{run as R{i}}} from './{ref[0]}';" for i, ref in enumerate(refs))
            calls = "".join(f"R{i}();" for i in range(len(refs)))
            (harness / (name + '.mjs')).write_text(f"import {{timed}} from './capture.mjs';\n{imports}\nawait timed(async()=>{{for(let batch=0;batch<{batches};batch++){{{calls}}}}});\n")
    assert sources == preflight.snapshot() and external == preflight.external(), 'Live source drift'
    receipt = {'status': 'STAGED_REVIEW_REQUIRED_NO_EXECUTION', 'sources': sources, 'external': external, 'intentionalAdaptations': changes, 'stageInventory': inventory(stage), 'scales': [1, 2, 4], 'timingScope': 'Full callable lifecycle; static imports/process startup and output flush excluded; no performance verdict'}
    (args.output / 'stage.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps({'status': receipt['status'], 'output': str(args.output)}))

if __name__ == '__main__':
    main()
