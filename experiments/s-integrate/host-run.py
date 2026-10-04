#!/usr/bin/env python3
"""Execute the actual joined Host fixture; finite evidence, not universal refinement."""
import argparse
import hashlib
import importlib.util
import json
import pathlib
import subprocess
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
    parser.add_argument('--compare-reference', type=pathlib.Path)
    args = parser.parse_args()
    args.build_dir.mkdir(parents=True, exist_ok=True)
    source = HERE / 'host-fixture.bend'
    sources = {str(p.relative_to(ROOT)): digest(p) for p in sorted(closure(source))}
    version = B.command(['bend', 'version']).strip()
    started = time.monotonic()
    programs = B.build(source, args.build_dir)
    outputs = []
    for executable, platform in zip(programs, ('native', 'javascript')):
        value = B.execute(executable)
        (args.build_dir / (platform + '.jsonl')).write_text(value + '\n')
        outputs.append(value)
    assert outputs[0] == outputs[1], 'Native/JavaScript full observations differ'
    assert sources == {str(p.relative_to(ROOT)): digest(p) for p in sorted(closure(source))}, 'source changed during execution'
    result = {'status': 'FINITE_NATIVE_JS_MATCH', 'scope': 'actual four-lane E0-E9 joined Host; E10/E11/comparison/mutations are separate required gates', 'compiler': version, 'sources': sources, 'checkerLimitSeconds': 5, 'codegenLimitSeconds': 30, 'clangLimitSeconds': 120, 'runtimeLimitSecondsEach': 5, 'outputSHA256': hashlib.sha256(outputs[0].encode()).hexdigest(), 'elapsedSeconds': round(time.monotonic()-started, 3)}
    if args.compare_reference:
        decoded = args.build_dir / 'decoded.json'
        B.command([sys.executable,HERE / 'trace-decode.py', args.build_dir / 'native.jsonl',decoded])
        comparison = subprocess.run([sys.executable,HERE / 'trace-compare.py',args.compare_reference,decoded],capture_output=True,text=True,timeout=5)
        result['comparisonExit'] = comparison.returncode
        result['comparison'] = json.loads(comparison.stdout)
        if comparison.returncode:
            result['status'] = 'JOINED_COMPARISON_INCOMPLETE_OR_DIFFERENT'
    (args.build_dir / 'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({key:value for key,value in result.items() if key != 'sources'},indent=2),flush=True)
    return int(result['status'] != 'FINITE_NATIVE_JS_MATCH')


if __name__ == '__main__':
    sys.exit(main())
