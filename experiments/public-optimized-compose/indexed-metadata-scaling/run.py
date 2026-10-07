#!/usr/bin/env python3
"""Standalone metadata diagnostics; root schedules all actual execution serially."""
import argparse
import gzip
import hashlib
import json
import os
from pathlib import Path
import shutil
import statistics
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CLANG = Path('/tmp/bendvy-clang19-diagnostic/clang19')
SIZES = [64, 256, 1024]

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def expected(size, scenario):
    rows = [[2, i, i, i + 1] for i in range(1, size + 1)]
    for i in range(1, size + 1):
        rows.extend([[1, i, i, i + 1], [3, i, i, i + 1001],
                     [4, i, i, i + 2001], [5, i, 0, 0], [6, i, i, i + 1]])
    rows.extend([[7, i, i, i + 1] for i in range(1, size + 1)])
    for i in ([0, size + 1, 65536, 131072, 131073, 4294967295] if scenario == 'mixed' else []):
        rows.extend([[8, i, 0, 0], [9, i, 0, 77], [10, i, 0, 0]])
    rows.extend([[11, i, i, i + 1] for i in range(1, size + 1)])
    assert len(rows) == 8 * size + (18 if scenario == 'mixed' else 0)
    return rows

def entry(mode, size, scenario):
    common = 'import Base\nimport ./workload.bend as W\nimport ./providers.bend as P\n'
    function = 'run' if scenario == 'mixed' else 'run_dense'
    if mode == 'legacy':
        expression = f'W.{function}(~List<&2,L.Entry>,~P.legacy_get,~P.legacy_set,~P.legacy_clear,{size},[])'
        return common + 'import ../../../src/ecs/lifecycle.bend as L\n' + f'def main() -> IO(Unit):\n  IO.print(W.render(~List<&2,L.Entry>,{expression}))\n'
    expression = f'W.{function}(~I.Metadata,~P.indexed_get,~P.indexed_set,~P.indexed_clear,{size},I.empty())'
    return common + 'import ../../../src/ecs/indexed-lifecycle.bend as I\n' + f'def main() -> IO(Unit):\n  IO.print(W.render(~I.Metadata,{expression}))\n'

def memory_entry(mode, size):
    # Separate representation diagnostic, never compared as normative trace/timing work.
    common = 'import Base\nimport ./workload.bend as W\nimport ./providers.bend as P\nimport ../../../src/ecs/lifecycle.bend as L\n'
    if mode == 'legacy':
        return common + f'def main() -> IO(Unit):\n  IO.print(Nat.show(List.length(&2,L.Entry,L.set(W.seed(~List<&2,L.Entry>,~P.legacy_set,U32.to_nat({size}),1,[]),131072,L.Stamp{{0,77}}))))\n'
    return common + 'import ../../../src/ecs/indexed-lifecycle.bend as I\n' + f'def report(observed:I.Metadata & U32) -> IO(Unit):\n  match observed:\n    case (_,capacity): IO.print(U32.show(capacity))\ndef main() -> IO(Unit):\n  report(P.indexed_capacity(I.set(W.seed(~I.Metadata,~P.indexed_set,U32.to_nat({size}),1,I.empty()),131072,L.Stamp{{0,77}})))\n'

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--cpu', type=int, default=0)
    p.add_argument('--samples', type=int, default=5)
    p.add_argument('--scenario', choices=['dense', 'mixed'], default='dense', help='Run separate invocations so high-water growth does not mask dense scaling.')
    p.add_argument('--include-4096', action='store_true', help='Explicit reported limit probe; failure is retained.')
    p.add_argument('--profiles', action='store_true', help='Separate matched Node CPU/allocation runs, after timing; default off.')
    a = p.parse_args()
    assert a.samples > 0
    out = a.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    stage = out / 'stage'
    local = HERE.relative_to(ROOT)
    receipt = {'status': 'INCOMPLETE', 'scope': 'Metadata-only equal-work diagnostic. No TS/product/full-ECS qualification or regression acceptance.',
               'sizes': SIZES + ([4096] if a.include_4096 else []), 'cpu': a.cpu, 'scenario': a.scenario,
               'runtimeCapSeconds': 5, 'checkerCapSeconds': 5, 'commands': [], 'cases': {},
               'timingLimit': 'Whole fresh child process includes startup, complete JSON formatting and stdout. No steady-state speedup inference.',
               'memoryLimit': 'Capacity slots/list entries are representation evidence, not measured RSS or cumulative allocation. Node heap profiles are sampled allocations including collected objects.'}
    def save():
        (out / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    def root_sources():
        # Recompute inventory, not just hashes of the original paths: additions
        # and removals are source drift too. Include foreign/core support files.
        paths = sorted(f for f in (ROOT / 'src/ecs').rglob('*') if f.is_file())
        paths += [HERE / n for n in ['workload.bend', 'providers.bend', 'run.py']]
        return {str(f.relative_to(ROOT)): sha(f) for f in paths}
    def stage_sources():
        return {str(f.relative_to(stage)): sha(f) for f in sorted(stage.rglob('*')) if f.is_file()}
    def generated_sources():
        return {label: sha(stage / local / (label + '.bend'))
                for label in receipt.get('generatedWorkloadSources', {})}
    def assert_source_binding(checkpoint):
        assert root_sources() == receipt['sources'], 'Root source inventory/hash drift at ' + checkpoint
        assert generated_sources() == receipt.get('generatedWorkloadSources', {}), 'Generated workload source drift at ' + checkpoint
        expected_stage = dict(receipt['sources'])
        expected_stage.update({str(local / (label + '.bend')): digest
                               for label, digest in receipt.get('generatedWorkloadSources', {}).items()})
        assert stage_sources() == expected_stage, 'Staged source inventory/hash drift at ' + checkpoint
        receipt.setdefault('sourceBindingChecks', []).append(checkpoint)
        save()
    def run(cmd, cap, name):
        started = time.perf_counter()
        try:
            r = subprocess.run(list(map(str, cmd)), cwd=stage, text=True, capture_output=True, timeout=cap)
        except subprocess.TimeoutExpired as e:
            stdout = e.stdout or b''
            stderr = e.stderr or b''
            if isinstance(stdout, bytes): stdout = stdout.decode(errors='replace')
            if isinstance(stderr, bytes): stderr = stderr.decode(errors='replace')
            (out / (name + '.stdout')).write_text(stdout)
            (out / (name + '.stderr')).write_text(stderr)
            receipt['commands'].append({'command': list(map(str, cmd)), 'capSeconds': cap, 'timedOut': True,
                                        'seconds': time.perf_counter() - started, 'stdoutSHA256': sha(out / (name + '.stdout'))})
            save()
            raise
        elapsed = time.perf_counter() - started
        with gzip.open(out / (name + '.stdout.gz'), 'wt') as f: f.write(r.stdout)
        (out / (name + '.stderr')).write_text(r.stderr)
        receipt['commands'].append({'command': list(map(str, cmd)), 'capSeconds': cap, 'exit': r.returncode,
                                    'seconds': elapsed, 'stdoutSHA256': hashlib.sha256(r.stdout.encode()).hexdigest(),
                                    'stderrSHA256': hashlib.sha256(r.stderr.encode()).hexdigest()})
        save()
        assert r.returncode == 0, (name, r.returncode, r.stderr)
        return r.stdout, elapsed
    try:
        # Freeze root bytes BEFORE copying; a raced copy cannot become the
        # reported source merely because hashes were taken after the copy.
        receipt['sources'] = root_sources()
        receipt['profileRunner'] = {str(f.relative_to(ROOT)): sha(f) for f in [(HERE.parent / 'node-profiles/run.py'), (HERE.parent / 'node-profiles/summarize.py')]}
        save()
        shutil.copytree(ROOT / 'src/ecs', stage / 'src/ecs')
        (stage / local).mkdir(parents=True)
        for name in ['workload.bend', 'providers.bend', 'run.py']:
            shutil.copy2(HERE / name, stage / local / name)
        assert_source_binding('immediately-after-copy')
        os.environ['BENDVY_CLANG19_ROOT'] = '/tmp/bendvy-clang19-diagnostic/root'
        receipt['versions'] = {k: run(cmd, 5, 'version-' + k)[0].strip() for k, cmd in [('bend', ['bend', 'version']), ('node', ['node', '--version']), ('clang', [CLANG, '--version'])]}
        def build(mode, size, memory=False):
            label = f'{mode}-{size}' + ('-capacity' if memory else '')
            src = stage / local / (label + '.bend')
            src.write_text(memory_entry(mode, size) if memory else entry(mode, size, a.scenario))
            receipt.setdefault('generatedWorkloadSources', {})[label] = sha(src)
            assert_source_binding('before-build-' + label)
            run(['bend', src, '--check-only'], 5, label + '-check')
            run(['bend', src, '-o', out / (label + '.js')], 30, label + '-emit-js')
            run(['bend', src, '-o', out / (label + '.c')], 30, label + '-emit-c')
            run([CLANG, '-O3', out / (label + '.c'), '-o', out / (label + '.native'), '-pthread', '-lm'], 120, label + '-clang')
            return label, {'JS': ['taskset', '-c', a.cpu, 'node', out / (label + '.js')], 'Native': ['taskset', '-c', a.cpu, out / (label + '.native')]}
        for size in receipt['sizes']:
            data = receipt['cases'][str(size)] = {'status': 'INCOMPLETE', 'expectedOperations': len(expected(size, a.scenario)), 'samples': {}, 'capacity': {}}
            executables = {}
            for mode in ['legacy', 'indexed']:
                label, executables[mode] = build(mode, size)
                for backend, cmd in executables[mode].items():
                    stdout, _ = run(cmd, 5, label + '-' + backend + '-semantic')
                    assert json.loads(stdout) == expected(size, a.scenario), (label, backend, 'complete trace mismatch')
                caplabel, caps = build(mode, size, True)
                for backend, cmd in caps.items():
                    stdout, _ = run(cmd, 5, caplabel + '-' + backend)
                    value = json.loads(stdout)
                    assert value == (size + 1 if mode == 'legacy' else 131072)
                    data['capacity'][mode + '-' + backend] = {'value': value, 'unit': 'listEntries' if mode == 'legacy' else 'slotsPerTickArray', 'scalarTickSlots': 2 * value if mode == 'indexed' else None}
            data['completeEqualOutputs'] = True
            # Only collect timing after BOTH modes/BOTH backends match the full oracle.
            for backend in ['JS', 'Native']:
                samples = {mode: [] for mode in executables}
                for index in range(a.samples):
                    for mode in (['legacy', 'indexed'] if index % 2 == 0 else ['indexed', 'legacy']):
                        stdout, elapsed = run(executables[mode][backend], 5, f'{mode}-{size}-{backend}-timing-{index}')
                        assert json.loads(stdout) == expected(size, a.scenario)
                        samples[mode].append(elapsed)
                data['samples'][backend] = {mode: {'seconds': values, 'medianSeconds': statistics.median(values)} for mode, values in samples.items()}
            if a.profiles:
                for mode in ['legacy', 'indexed']:
                    profile_out = out / f'{mode}-{size}-profiles'
                    run(['python3', ROOT / 'experiments/public-optimized-compose/node-profiles/run.py', '--generated', out / f'{mode}-{size}.js', '--expected', out / f'{mode}-{size}-JS-semantic.stdout.gz', '--output', profile_out, '--iterations', '1', '--cpu', a.cpu], 20, f'{mode}-{size}-profile-wrapper')
                    run(['python3', ROOT / 'experiments/public-optimized-compose/node-profiles/summarize.py', profile_out], 5, f'{mode}-{size}-profile-summary')
                    data.setdefault('profiles', {})[mode] = str(profile_out.relative_to(out))
            data['status'] = 'PASS'
            save()
        assert_source_binding('final-acceptance')
        assert {str(f.relative_to(ROOT)): sha(f) for f in [(HERE.parent / 'node-profiles/run.py'), (HERE.parent / 'node-profiles/summarize.py')]} == receipt['profileRunner'], 'Profile runner drift'
        receipt['artifactSHA256'] = {str(f.relative_to(out)): sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name != 'receipt.json'}
        receipt['status'] = 'PASS'
    except Exception as e:
        receipt['status'] = 'ERROR'
        receipt['error'] = repr(e)
        raise
    finally:
        save()
    print(json.dumps({'status': receipt['status'], 'output': str(out)}))

if __name__ == '__main__':
    main()
