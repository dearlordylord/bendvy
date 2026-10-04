#!/usr/bin/env python3
"""Execute the actual joined Host fixture; finite evidence, not universal refinement."""
import argparse
import hashlib
import importlib.util
import json
import pathlib
import subprocess
import shutil
import sys
import time

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
spec = importlib.util.spec_from_file_location('bounded_build', HERE.parent / 't05/run.py')
B = importlib.util.module_from_spec(spec)
spec.loader.exec_module(B)


def closure(path, seen=None):
    import re
    seen = set() if seen is None else seen
    path = path.resolve()
    if path in seen:
        return seen
    seen.add(path)
    for imported in re.findall(r'^import\s+(\S+)', path.read_text(), re.M):
        if imported.startswith('.'):
            closure(path.parent / imported, seen)
    return seen


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build-dir', type=pathlib.Path, default=pathlib.Path('/tmp/bendvy-host-main'))
    parser.add_argument('--compare-reference', type=pathlib.Path, help='optional already fresh reference; default executes both schema references within 5s each')
    parser.add_argument('--verify-built', action='store_true', help='reexecute only exact artifact hashes from the frozen evidence')
    args = parser.parse_args()
    args.build_dir.mkdir(parents=True, exist_ok=True)
    source = HERE / 'host-fixture.bend'
    entries = [HERE / ('host-' + schema + '-fixture.bend') for schema in ('motion','health')]
    imported = set().union(*(closure(entry) for entry in entries))
    sources = {str(p.relative_to(ROOT)): digest(p) for p in sorted(imported)}
    frozen = json.loads((HERE / 'host-main-evidence.json').read_text())
    assert sources == frozen['sources'], 'frozen original source closure drift'
    for name, expected in frozen['tooling'].items():
        assert digest(ROOT / name) == expected, ('verification tool drift', name)
    assert digest(pathlib.Path(shutil.which('bend'))) == frozen['compilerSHA256'], 'compiler drift'
    assert digest(pathlib.Path.home() / '.bend/bend2/base.bend') == frozen['baseSHA256'], 'Base drift'
    version = B.command(['bend', 'version']).strip()
    assert version == frozen['compiler'], 'compiler version drift'
    started = time.monotonic()
    outputs = ['', '']
    for source in entries:
        if args.verify_built:
            programs = (args.build_dir / (source.stem + '-native'), args.build_dir / (source.stem + '.js'))
            for executable in programs:
                assert digest(executable) == frozen['artifacts'][executable.name], ('artifact drift', executable.name)
        else:
            programs = B.build(source, args.build_dir)
        for index, executable in enumerate(programs):
            outputs[index] += B.execute(executable) + '\n'
    for value, platform in zip(outputs, ('native','javascript')):
        (args.build_dir / (platform + '.jsonl')).write_text(value)
    assert outputs[0] == outputs[1], 'Native/JavaScript full observations differ'
    assert sources == {str(p.relative_to(ROOT)): digest(p) for p in sorted(set().union(*(closure(entry) for entry in entries)))}, 'source changed during execution'
    result = {'status': 'FINITE_NATIVE_JS_MATCH', 'scope': 'actual four-lane E0-E10 joined Host through two schema entrypoints; E11/comparison/mutations are separate required gates', 'compiler': version, 'sources': sources, 'checkerLimitSeconds': 5, 'codegenLimitSeconds': 30, 'clangLimitSeconds': 120, 'runtimeLimitSecondsEach': 5, 'outputSHA256': hashlib.sha256(outputs[0].encode()).hexdigest(), 'elapsedSeconds': round(time.monotonic()-started, 3)}
    reference = args.compare_reference
    if reference is None:
        fresh = []
        for schema in ('Motion','Health'):
            observed = json.loads(B.command(['node', ROOT / 'experiments/s-integrate-trace/reference-main.mjs', '--schema', schema]))
            assert observed['status'].startswith('PASS'), observed['status']
            fresh.append(observed)
            (args.build_dir / ('reference-' + schema.lower() + '.json')).write_text(json.dumps(observed,indent=2)+'\n')
        combined = dict(fresh[0])
        combined['results'] = fresh[0]['results'] + fresh[1]['results']
        reference = args.build_dir / 'reference-fresh.json'
        reference.write_text(json.dumps(combined,indent=2)+'\n')
    decoded = args.build_dir / 'decoded.json'
    B.command([sys.executable,HERE / 'trace-decode.py', args.build_dir / 'native.jsonl',decoded])
    comparison = subprocess.run([sys.executable,HERE / 'trace-compare.py',reference,decoded],capture_output=True,text=True,timeout=5)
    result['comparisonExit'] = comparison.returncode
    result['comparison'] = json.loads(comparison.stdout)
    result['referenceSHA256'] = digest(reference)
    result['referenceAdapterSHA256'] = digest(ROOT / 'experiments/s-integrate-trace/reference-main.mjs')
    result['status'] = 'FINITE_FRESH_REFERENCE_MATCH' if comparison.returncode == 0 else 'JOINED_COMPARISON_INCOMPLETE_OR_DIFFERENT'
    result['scope'] = 'actual E0-E10 four-lane finite refinement; E11/joined mutants/performance/universal refinement remain separate required gates'
    result['artifactMode'] = 'reexecuted frozen artifacts' if args.verify_built else 'compiled and executed in this run'
    result['buildAndRuntimeElapsedSeconds'] = frozen['buildAndRuntimeElapsedSeconds'] if args.verify_built else result['elapsedSeconds']
    result['tooling'] = frozen['tooling']
    result['compilerSHA256'] = frozen['compilerSHA256']
    result['baseSHA256'] = frozen['baseSHA256']
    result['artifacts'] = {program.name: digest(program) for source in entries for program in (args.build_dir / (source.stem + '-native'), args.build_dir / (source.stem + '.js'))}
    (args.build_dir / 'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({key:value for key,value in result.items() if key not in ('sources','tooling','artifacts')},indent=2),flush=True)
    return int(result['status'] != 'FINITE_FRESH_REFERENCE_MATCH')


if __name__ == '__main__':
    sys.exit(main())
