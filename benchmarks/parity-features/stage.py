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
    parser.add_argument('--nested-spawn', action='store_true', help='Reviewed actual spawn+public allocator probe+barrier observations')
    parser.add_argument('--scopes', action='store_true', help='Include the complete matched lifetime-scope IO suite')
    parser.add_argument('--inspect-runtime', action='store_true', help='Include the complete matched runtime Inspector IO suite')
    parser.add_argument('--named-schedules', action='store_true', help='Include complete named-plan lifecycles and separate enabled/disabled scenes')
    args = parser.parse_args()
    assert not args.output.exists(), 'Stage must be fresh'
    sources, external = preflight.snapshot(), preflight.external()
    if args.inspect_runtime:
        directory = 'experiments/public-inspect/graph-stream-public-bridge-v1/feature-timing-v1'
        required = [f'{directory}/main.bend', f'{directory}/reference.mjs']
        required += [f'{directory}/independent-oracle-v1/expected-scale-{scale}.stdout' for scale in [1, 2, 4]]
        assert all(name in sources for name in required), 'Runtime Inspector fixture and complete scale oracles must be frozen before staging'
    if args.named_schedules:
        prefix = 'experiments/public-schedules/named-app-v1/'
        required = [prefix + directory + '/' + name for directory in ['matched-feature-v1', 'debug-overhead-v1'] for name in ['main.bend', 'reference.mjs']]
        required += [prefix + 'matched-feature-v1/independent-oracle-v1/expected-scale-' + str(n) + '.stdout' for n in [1, 2, 4]]
        required += [prefix + 'debug-overhead-v1/independent-oracle-v1/expected-' + mode + '-scale-' + str(n) + '.stdout' for mode in ['enabled', 'disabled'] for n in [1, 2, 4]]
        assert all(name in sources for name in required), 'Named-plan complete and per-mode source/oracles must be frozen before staging'
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
    if args.nested_spawn:
        import importlib.util
        spec=importlib.util.spec_from_file_location('nested_spawn',HERE/'nested-candidate/adapt.py')
        nested_spawn=importlib.util.module_from_spec(spec);spec.loader.exec_module(nested_spawn)
    for name in ['app.bend', 'other.bend']:
        path = stage / 'experiments/public-nested-provision' / name
        before = preflight.digest(path)
        text=workloads.adapt_nested(path.read_text())
        if args.nested_spawn:text=nested_spawn.instrument(text)
        path.write_text(text)
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
            text=original.read_text()
            if args.nested_spawn and feature=='nested':text=nested_spawn.ts(text)
            adapted.write_text(workloads.callable_ts(text))
            changes[str(adapted.relative_to(stage))] = {'source': str(original.relative_to(stage)), 'before': preflight.digest(original), 'after': preflight.digest(adapted), 'purpose': 'Static imports outside timing; unchanged authored statements inside fresh callable lifecycle'}
        for batches in [1, 2, 4]:
            name = f'{feature}-{batches}'
            (harness / (name + '.bend')).write_text(workloads.bend_entry(feature, batches))
            imports = "\n".join(f"import {{run as R{i}}} from './{ref[0]}';" for i, ref in enumerate(refs))
            calls = "".join(f"R{i}();" for i in range(len(refs)))
            (harness / (name + '.mjs')).write_text(f"import {{timed}} from './capture.mjs';\n{imports}\nawait timed(async()=>{{for(let batch=0;batch<{batches};batch++){{{calls}}}}});\n")
    if args.scopes:
        reference = stage / 'experiments/public-scopes/feature-timing-v1/reference.mjs'
        assert reference.is_file(), 'Scope adapter must be integrated before staging'
        before = preflight.digest(reference)
        old = "'../../../.references/bevy-ts/packages/core/src/index.ts'"
        new = json.dumps(str(ROOT / '.references/bevy-ts/packages/core/src/index.ts'))
        reference.write_text(workloads.replace_once(reference.read_text(), old, new))
        changes[str(reference.relative_to(stage))] = {'before': before, 'after': preflight.digest(reference), 'purpose': 'Resolve the pinned canonical TS API; unchanged callable lifecycle'}
        for batches in [1, 2, 4]:
            name = f'scopes-{batches}'
            (harness / (name + '.bend')).write_text(workloads.bend_entry('scopes', batches))
            (harness / (name + '.mjs')).write_text(f"import {{timed}} from './capture.mjs';\nimport {{run}} from '../experiments/public-scopes/feature-timing-v1/reference.mjs';\nawait timed(async()=>{{console.log(run({batches}));}});\n")
    if args.inspect_runtime:
        directory = 'public-inspect/graph-stream-public-bridge-v1/feature-timing-v1'
        reference = stage / 'experiments' / directory / 'reference.mjs'
        assert reference.is_file(), 'Runtime Inspector adapter must be integrated before staging'
        before = preflight.digest(reference)
        old = "'../../../../.references/bevy-ts/packages/core/src/index.ts'"
        new = json.dumps(str(ROOT / '.references/bevy-ts/packages/core/src/index.ts'))
        reference.write_text(workloads.replace_once(reference.read_text(), old, new))
        changes[str(reference.relative_to(stage))] = {'before': before, 'after': preflight.digest(reference), 'purpose': 'Resolve pinned canonical TS API; unchanged complete callable lifecycle'}
        for batches in [1, 2, 4]:
            name = f'inspect-runtime-{batches}'
            (harness / (name + '.bend')).write_text(workloads.bend_entry('inspect-runtime', batches))
            (harness / (name + '.mjs')).write_text(f"import {{timed}} from './capture.mjs';\nimport {{run}} from '../experiments/{directory}/reference.mjs';\nawait timed(async()=>{{console.log(run({batches}));}});\n")
    if args.named_schedules:
        for directory in ['matched-feature-v1', 'debug-overhead-v1']:
            reference = stage / 'experiments/public-schedules/named-app-v1' / directory / 'reference.mjs'
            before = preflight.digest(reference)
            old = "'/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts'"
            reference.write_text(workloads.replace_once(reference.read_text(), old, json.dumps(str(ROOT / '.references/bevy-ts/packages/core/src/index.ts'))))
            changes[str(reference.relative_to(stage))] = {'before': before, 'after': preflight.digest(reference), 'purpose': 'Resolve pinned canonical TS API; unchanged complete lifecycle body'}
        for feature in ['named-schedules', 'named-schedules-enabled', 'named-schedules-disabled']:
            directory = 'matched-feature-v1' if feature == 'named-schedules' else 'debug-overhead-v1'
            for batches in [1, 2, 4]:
                name = f'{feature}-{batches}'
                (harness / (name + '.bend')).write_text(workloads.bend_entry(feature, batches))
                call = f'run({batches})' if feature == 'named-schedules' else f'runMode({batches},{str(feature.endswith("enabled")).lower()})'
                selected = 'run' if feature == 'named-schedules' else 'runMode'
                (harness / (name + '.mjs')).write_text(f"import {{timed}} from './capture.mjs';\nimport {{{selected}}} from '../experiments/public-schedules/named-app-v1/{directory}/reference.mjs';\nawait timed(async()=>{{console.log({call});}});\n")
    assert sources == preflight.snapshot() and external == preflight.external(), 'Live source drift'
    receipt = {'status': 'STAGED_REVIEW_REQUIRED_NO_EXECUTION', 'sources': sources, 'external': external, 'intentionalAdaptations': changes, 'stageInventory': inventory(stage), 'scales': [1, 2, 4], 'nestedSpawn':args.nested_spawn, 'scopes':args.scopes, 'inspectRuntime':args.inspect_runtime, 'namedSchedules':args.named_schedules, 'noticeCacheObserved':preflight.notice_cache(), 'timingScope': 'Full callable lifecycle; static imports/process startup and output flush excluded; no performance verdict'}
    (args.output / 'stage.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps({'status': receipt['status'], 'output': str(args.output)}))

if __name__ == '__main__':
    main()
