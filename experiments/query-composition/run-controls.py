#!/usr/bin/env python3
"""Replay actual public Bend capability controls against a frozen source copy."""
import argparse
import hashlib
import json
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNED = Path('experiments/query-composition/public-controls')

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--source-root', type=Path, default=ROOT)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    cases = json.loads((ROOT / OWNED / 'cases.json').read_text())
    library = {str(p.relative_to(args.source_root)): sha(p)
               for p in sorted((args.source_root / 'src/ecs').glob('*.bend'))}
    results = []
    with tempfile.TemporaryDirectory(prefix='query-public-controls-') as temp:
        stage = Path(temp)
        shutil.copytree(args.source_root / 'src/ecs', stage / 'src/ecs')
        shutil.copytree(ROOT / OWNED, stage / OWNED)
        for case in cases:
            source = stage / OWNED / case['file']
            command = ['timeout', '5', 'bend', str(OWNED / case['file'])]
            proc = subprocess.run(command, cwd=stage, text=True,
                                  stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            text = proc.stdout
            (args.output / (case['name'] + '.log')).write_text(text)
            reject = case.get('reject')
            if reject:
                passed = (proc.returncode == 1 and 'expected :' in text and
                          'observed :' in text and all(term in text for term in reject))
            else:
                passed = proc.returncode == 0 and text.strip() == case['expected']
            results.append({'name': case['name'], 'command': command,
                            'source_sha256': sha(source), 'exit': proc.returncode,
                            'passed': passed, 'log': case['name'] + '.log'})
    receipt = {'format': 1, 'limit_seconds': 5,
               'version': subprocess.check_output(['bend', 'version'], text=True).strip(),
               'runner_sha256': sha(Path(__file__)), 'library': library,
               'cases_sha256': sha(ROOT / OWNED / 'cases.json'), 'results': results}
    (args.output / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps({'passed': sum(r['passed'] for r in results), 'total': len(results)}))
    raise SystemExit(0 if all(r['passed'] for r in results) else 1)

if __name__ == '__main__':
    main()
