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
    amendments = SUBJECTS.get('approved_amendments', {})
    if set(amendments) != {'owned_runtime_schedule_correspondence'}:
        raise RuntimeError('unexpected approved amendment selection')
    for name, block in selected.items():
        historical = SUBJECTS['exact_blocks'][name]
        if historical != original_blocks[name]:
            raise RuntimeError('historical approved statement changed: ' + name)
        expected = historical
        if name in amendments:
            amendment = amendments[name]
            for prefix in ['proposal', 'decision']:
                if digest(ROOT / amendment[prefix + '_path']) != amendment[prefix + '_sha256']:
                    raise RuntimeError('approved amendment provenance changed: ' + prefix)
            if amendment['decision'] != 'APPROVE':
                raise RuntimeError('amendment has no approval')
            proposed = law_blocks((ROOT / amendment['proposal_path']).read_text())
            if list(proposed) != [name]:
                raise RuntimeError('amendment contains unexpected subjects')
            expected = historical.replace('for -world: R.World', 'for world: R.World')
            if expected == historical or proposed[name] != expected:
                raise RuntimeError('amendment differs beyond approved affine binder')
        if block != expected:
            raise RuntimeError('selected approved statement changed: ' + name)
    support = SUBJECTS['approved_support']
    if support['ids'] != ['u32_increment_no_wrap', 'u32_comparison_agrees_nat'] or support['decision'] != 'APPROVE':
        raise RuntimeError('unexpected supporting approval')
    for prefix in ['proposal', 'decision']:
        if digest(ROOT / support[prefix + '_path']) != support[prefix + '_sha256']:
            raise RuntimeError('support approval provenance changed: ' + prefix)
    support_blocks = law_blocks((ROOT / support['proposal_path']).read_text())
    if list(support_blocks) != support['ids']:
        raise RuntimeError('support selection changed')
    for name, block in support_blocks.items():
        if block != original_blocks[name]:
            raise RuntimeError('support statement changed: ' + name)
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
              'approved_amendments': amendments, 'approved_support': support,
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
