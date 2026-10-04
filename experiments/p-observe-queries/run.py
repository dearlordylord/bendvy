#!/usr/bin/env python3
"""Bounded query-proof progress, exact subset and reproducible residual gate."""
import hashlib
import json
import pathlib
import shutil
import subprocess
import tempfile

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
APPROVED = 'e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc'
SUBJECTS = ROOT / 'experiments/t11-replacement'
WRAPPER = ROOT / 'experiments/t01/bend-check'

def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def check(path, kernel=False):
    command = [str(WRAPPER), str(path)] + (['--verdict'] if kernel else [])
    result = subprocess.run(command, capture_output=True, text=True, timeout=7)
    return {'command': command, 'exit_code': result.returncode,
            'output': result.stdout + result.stderr}

def require(row, exit_code, verdict, location=None):
    assert row['exit_code'] == exit_code, row
    assert verdict in row['output'], row
    if location:
        assert f'Location: {location}\n' in row['output'], row

source = (SUBJECTS / 'LAWS.bend').read_text()
assert digest(SUBJECTS / 'LAWS.bend') == APPROVED
block = source[source.index('law query_any_complete_ordered:'):source.index('law lookup_full_exact:')]
subset = (HERE / 'LAWS.bend').read_text()
assert subset[subset.index('law query_any_complete_ordered:'):] == block
assert subset.count('\nlaw ') == 3
rows = []
for name in ['helpers.bend', 'invariants.bend', 'intervals.bend', 'contextual.bend', 'controls.bend']:
    for kernel in [False, True]:
        row = check(HERE / name, kernel)
        require(row, 0, 'ALL PROOFS CHECK')
        rows.append(row)
for kernel in [False, True]:
    row = check(HERE / 'attempt.bend', kernel)
    require(row, 1, 'SOME PROOFS FAIL', 'insert_interval')
    assert '?interval_ordered_insertion' in row['output']
    rows.append(row)

mutants = []
with tempfile.TemporaryDirectory(prefix='bendvy-query-proof-') as tmp:
    mirror = pathlib.Path(tmp)
    dest = mirror / 'experiments/p-observe-queries'
    shutil.copytree(HERE, dest, ignore=shutil.ignore_patterns('evidence.json', '__pycache__'))
    core = mirror / 'experiments/t11-replacement'
    core.mkdir()
    for name in ['types.bend', 'model.bend', 'spec.bend']:
        shutil.copy2(SUBJECTS / name, core / name)
    for name in ['helpers.bend', 'invariants.bend', 'intervals.bend', 'contextual.bend']:
        row = check(dest / name, True)
        require(row, 0, 'ALL PROOFS CHECK')
        rows.append(row)
    mutations = [
        ('zero-count-lookup-emits-row', 'spec.bend',
         'case _: recur(Unit{})', 'case _: Some{row}',
         'helpers.bend', 'at_zero_head'),
        ('eligibility-rejects-present-tag', 'spec.bend',
         'case T.Present{} False{}: False{}', 'case T.Present{} False{}: True{}',
         'invariants.bend', 'eligibility'),
        ('empty-query-emits-ghost', 'model.bend',
         'def query_rows(+selection: T.Selection, rows: List<&2, T.Row>) -> List<&2, T.Row>:\n  match rows:\n    case Nil{}: []',
         'def query_rows(+selection: T.Selection, rows: List<&2, T.Row>) -> List<&2, T.Row>:\n  match rows:\n    case Nil{}: [T.Row{0n,0n,False{}}]',
         'contextual.bend', 'empty_world'),
    ]
    for label, filename, old, new, entry, location in mutations:
        target = core / filename
        original = target.read_text()
        assert original.count(old) == 1
        target.write_text(original.replace(old, new))
        compile_row = check(target)
        require(compile_row, 0, 'ALL PROOFS CHECK')
        fail_row = check(dest / entry)
        require(fail_row, 1, 'SOME PROOFS FAIL', location)
        mutants.append({'name': label, 'scope': 'contextual helper only; not a completed endpoint',
                        'compilation': compile_row, 'unchanged_proof': fail_row})
        target.write_text(original)

paths = [SUBJECTS / n for n in ['LAWS.bend', 'types.bend', 'model.bend', 'spec.bend']]
paths += [HERE / n for n in ['LAWS.bend', 'helpers.bend', 'invariants.bend', 'intervals.bend', 'contextual.bend', 'controls.bend', 'attempt.bend', 'run.py']]
paths += [WRAPPER, pathlib.Path('/home/node/.bend/bend2/base.bend'), pathlib.Path(shutil.which('bend')).resolve()]
refs = {}
for name in ['bevy-ts', 'bevy', 'bend2']:
    reference = pathlib.Path('/workspace/formal-proofs/bendvy/.references') / name
    refs[name] = subprocess.check_output(['git', '-C', str(reference), 'rev-parse', 'HEAD'], text=True).strip()
manifest = json.loads((ROOT / '.references/sources.json').read_text())
assert all(refs[name] == manifest['sources'][name]['commit'] for name in refs)
evidence = {'status': 'partial contextual progress; all three complete endpoints blocked',
            'approved_subject_sha256': APPROVED,
            'approved_ids': ['query_any_complete_ordered', 'query_present_complete_ordered', 'query_absent_complete_ordered'],
            'compiler_version': subprocess.check_output(['bend', 'version'], text=True).strip(),
            'reference_commits': refs,
            'hashes': {str(p): digest(p) for p in paths},
            'checks': rows, 'contextual_mutants': mutants,
            'completed_endpoint_ids': [],
            'blocked_endpoint_ids': ['query_any_complete_ordered', 'query_present_complete_ordered', 'query_absent_complete_ordered'],
            'limit_seconds': 5}
(HERE / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
print('Contextual checker/kernel and compiling controls passed; 3 endpoints remain blocked.')
