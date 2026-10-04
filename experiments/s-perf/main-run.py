#!/usr/bin/env python3
"""Run the actual indexed E0-E10 pipeline against a fresh two-schema TS trace."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('bounded', ROOT / 'experiments/t05/run.py')
B = importlib.util.module_from_spec(spec)
spec.loader.exec_module(B)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--overlay', required=True, type=Path)
    parser.add_argument('--build-dir', required=True, type=Path)
    args = parser.parse_args()
    if os.environ.get('BENDVY_CPU') and hasattr(os, 'sched_setaffinity'):
        os.sched_setaffinity(0, {int(os.environ['BENDVY_CPU'])})
    args.build_dir.mkdir(parents=True, exist_ok=False)
    manifest = json.loads((args.overlay / 'overlay.json').read_text())
    result = {'status': 'INCOMPLETE', 'overlay': manifest, 'cases': [],
              'limitsSeconds': {'checker': 5, 'runtime': 5, 'codegen': 30, 'clang': 120}}
    started = time.monotonic()
    try:
        output = [[], []]
        for schema in ('motion', 'health'):
            entry = args.overlay / f'experiments/s-integrate/host-{schema}-fixture.bend'
            programs = B.build(entry, args.build_dir)
            for index, program in enumerate(programs):
                output[index].append(B.execute(program) + '\n')
                result['cases'].append({'schema': schema, 'backend': index,
                                        'artifactSHA256': sha(program), 'status': 'PASS'})
        output = [''.join(parts) for parts in output]
        assert output[0] == output[1], 'full Native/JS observations differ'
        for platform, value in zip(('native', 'javascript'), output):
            (args.build_dir / f'{platform}.jsonl').write_text(value)
        references = []
        for schema in ('Motion', 'Health'):
            references.append(json.loads(B.command([
                'node', ROOT / 'experiments/s-integrate-trace/reference-main.mjs',
                '--schema', schema])))
        assert all(r['status'].startswith('PASS') for r in references)
        reference = dict(references[0])
        reference['results'] = references[0]['results'] + references[1]['results']
        reference_path = args.build_dir / 'reference.json'
        reference_path.write_text(json.dumps(reference) + '\n')
        decoded = args.build_dir / 'decoded.json'
        B.command([sys.executable, ROOT / 'experiments/s-integrate/trace-decode.py',
                   args.build_dir / 'native.jsonl', decoded])
        comparison = subprocess.run([
            sys.executable, ROOT / 'experiments/s-integrate/trace-compare.py',
            reference_path, decoded], capture_output=True, text=True, timeout=5)
        result['comparison'] = json.loads(comparison.stdout)
        assert comparison.returncode == 0, 'fresh reference comparison failed'
        assert all(sha(args.overlay / name) == digest
                   for name, digest in manifest['sources'].items()), 'overlay changed'
        result.update(status='FINITE_FRESH_REFERENCE_MATCH',
                      outputSHA256=hashlib.sha256(output[0].encode()).hexdigest(),
                      referenceSHA256=sha(reference_path))
    except Exception as error:
        result.update(status='FAIL', error=str(error))
    result['elapsedSeconds'] = round(time.monotonic() - started, 3)
    (args.build_dir / 'evidence.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: v for k, v in result.items() if k != 'overlay'}, indent=2))
    return int(result['status'] != 'FINITE_FRESH_REFERENCE_MATCH')


if __name__ == '__main__':
    sys.exit(main())
