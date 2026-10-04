#!/usr/bin/env python3
"""Seven-endpoint proof gate. Incomplete/invalid proofs always return nonzero."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
SUBJECTS = json.loads((HERE / 'subjects.json').read_text())
WRAPPER = ROOT / 'experiments/t01/bend-check'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def law_blocks(text):
    return {match.group(1): match.group(0).rstrip()
            for match in re.finditer(r'(?m)^law (\w+):\n(?:[ \t].*(?:\n|$))+', text)}

def check(flag):
    command = [str(WRAPPER), str(HERE / 'PROOF.bend'), flag]
    child = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                             text=True, start_new_session=True)
    try:
        output = child.communicate(timeout=6)[0]
    except subprocess.TimeoutExpired:
        os.killpg(child.pid, signal.SIGKILL)
        child.communicate()
        raise RuntimeError('checker wrapper failed to enforce its five-second limit')
    return {'command': command, 'exit_code': child.returncode, 'output': output}

def main():
    for path, expected in SUBJECTS['canonical_closure'].items():
        if digest(ROOT / path) != expected:
            raise RuntimeError('approved subject changed: ' + path)
    original = ROOT / 'experiments/t11-replacement/LAWS.bend'
    if digest(original) != SUBJECTS['approved_source_sha256']:
        raise RuntimeError('approved law revision changed')
    selected = law_blocks((HERE / 'LAWS.bend').read_text())
    if list(selected) != SUBJECTS['approved_ids']:
        raise RuntimeError('selection is not exactly the seven approved IDs')
    original_blocks = law_blocks(original.read_text())
    for name, block in selected.items():
        if block != SUBJECTS['exact_blocks'][name] or block != original_blocks[name]:
            raise RuntimeError('approved statement changed: ' + name)
    expected_imports = ['import Base'] + [
        f'import ../t11-replacement/{module}.bend as {alias}'
        for module, alias in [('types','T'),('model','M'),('spec','S'),('runtime','R'),('owned-spec','O')]]
    actual_imports = re.findall(r'(?m)^import .+$', (HERE / 'LAWS.bend').read_text())
    if actual_imports != expected_imports:
        raise RuntimeError('selected law imports differ from the canonical subjects')
    rows = [check('--check-only'), check('--verdict')]
    passed = all(row['exit_code'] == 0 and 'ALL PROOFS CHECK' in row['output'] for row in rows)
    report = {'status': 'PASS: all seven proof endpoints checked' if passed else 'INCOMPLETE: full seven-endpoint proof gate failed',
              'issue': 18, 'approved_ids': SUBJECTS['approved_ids'],
              'approved_source_sha256': SUBJECTS['approved_source_sha256'],
              'canonical_closure_verified': True, 'exact_selection_verified': True,
              'checks': rows, 'checker_limit_seconds': 5,
              'source_hashes': {p.name: digest(p) for p in HERE.iterdir() if p.suffix in ['.bend','.py'] or p.name == 'subjects.json'},
              'base_sha256': digest(Path.home() / '.bend/bend2/base.bend'),
              'compiler_sha256': digest(Path(shutil.which('bend')).resolve()),
              'limits': 'This gate checks exact statements and proof verdicts. Per-endpoint compiling semantic mutants, controls, independent review and ticket acceptance remain separate required gates.'}
    (HERE / 'evidence.json').write_text(json.dumps(report, indent=2) + '\n')
    print(report['status'])
    for row in rows:
        print(row['output'].strip())
    return 0 if passed else 1

if __name__ == '__main__':
    sys.exit(main())
