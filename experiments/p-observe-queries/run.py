#!/usr/bin/env python3
"""Exact approved query proofs, kernel gates and own-endpoint semantic mutants."""
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
for name in ['helpers.bend', 'invariants.bend', 'intervals.bend', 'order.bend', 'insertion.bend', 'complete.bend', 'enum-lookup.bend', 'enum-controls.bend', 'contextual.bend', 'controls.bend', 'PROOF.bend']:
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
endpoint_mutants = []
with tempfile.TemporaryDirectory(prefix='bendvy-query-proof-') as tmp:
    mirror = pathlib.Path(tmp)
    dest = mirror / 'experiments/p-observe-queries'
    shutil.copytree(HERE, dest, ignore=shutil.ignore_patterns('evidence.json', '__pycache__'))
    core = mirror / 'experiments/t11-replacement'
    core.mkdir()
    for name in ['types.bend', 'model.bend', 'spec.bend']:
        shutil.copy2(SUBJECTS / name, core / name)
    for name in ['helpers.bend', 'invariants.bend', 'intervals.bend', 'enum-lookup.bend', 'contextual.bend']:
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

# Each unchanged endpoint is isolated against a semantic public-dispatch mutant.
original_laws = (HERE / 'LAWS.bend').read_text()
original_proof = (HERE / 'PROOF.bend').read_text()
law_prefix = original_laws[:original_laws.index('law query_any_complete_ordered:')]
proof_prefix = original_proof[:original_proof.index('# Own endpoint section:')]
ids = [('query_any_complete_ordered','Any','Present'),
       ('query_present_complete_ordered','Present','Absent'),
       ('query_absent_complete_ordered','Absent','Any')]
fixture = 'T.World{7n,4n,[T.Row{3n,30n,False{}},T.Row{1n,10n,True{}},T.Row{0n,5n,False{}}],[]}'
with tempfile.TemporaryDirectory(prefix='bendvy-query-endpoints-') as tmp:
    mirror = pathlib.Path(tmp)
    dest = mirror / 'experiments/p-observe-queries'
    shutil.copytree(HERE,dest,ignore=shutil.ignore_patterns('evidence.json','__pycache__'))
    core = mirror / 'experiments/t11-replacement'
    core.mkdir()
    for filename in ['types.bend','model.bend','spec.bend']:
        shutil.copy2(SUBJECTS / filename,core / filename)
    old_query = 'def query(world: T.World, selection: T.Selection) -> List<&2, T.Row>:\n  match world:\n    case T.World{_, _, rows, _}: query_rows(selection, rows)'
    original_model = (core / 'model.bend').read_text()
    assert original_model.count(old_query) == 1
    for law_id, selection, replacement in ids:
        start = original_laws.index('law '+law_id+':')
        finish = original_laws.find('law ',start+4)
        block = original_laws[start:] if finish == -1 else original_laws[start:finish]
        (dest / 'LAWS.bend').write_text(law_prefix+block)
        start = original_proof.index('# Own endpoint section: '+law_id)
        finish = original_proof.find('# Own endpoint section:',start+1)
        section = original_proof[start:] if finish == -1 else original_proof[start:finish]
        (dest / 'PROOF.bend').write_text(proof_prefix+section)
        premise = 'import Base\nimport ../t11-replacement/types.bend as T\nimport ../t11-replacement/spec.bend as S\n'
        premise += 'def active_premise() -> {True{} == S.admissible(4n,'+fixture+') : Bool}:\n  {==}\n'
        (dest / 'premise.bend').write_text(premise)
        witness = premise.replace('def active_premise()', 'import ../t11-replacement/model.bend as M\n\ndef active_premise()')
        witness += 'def true_instance() -> {M.query('+fixture+',T.'+selection+'{}) == S.query('+fixture+',T.'+selection+'{}) : List<&2,T.Row>}:\n  {==}\n'
        (dest / 'witness.bend').write_text(witness)
        controls = [check(dest / 'PROOF.bend'),check(dest / 'PROOF.bend',True),check(dest / 'premise.bend',True),check(dest / 'witness.bend',True)]
        for row in controls:
            require(row,0,'ALL PROOFS CHECK')
        dispatch = 'def query(world: T.World, selection: T.Selection) -> List<&2, T.Row>:\n  match world selection:\n'
        for sel in ['Any','Present','Absent']:
            target = replacement if sel == selection else sel
            dispatch += '    case T.World{_, _, rows, _} T.'+sel+'{}: query_rows(T.'+target+'{}, rows)\n'
        (core / 'model.bend').write_text(original_model.replace(old_query,dispatch.rstrip()))
        compiling = check(core / 'model.bend')
        require(compiling,0,'ALL PROOFS CHECK')
        active = check(dest / 'premise.bend',True)
        require(active,0,'ALL PROOFS CHECK')
        witness_fail = check(dest / 'witness.bend')
        require(witness_fail,1,'SOME PROOFS FAIL','true_instance')
        proof_fail = check(dest / 'PROOF.bend')
        require(proof_fail,1,'SOME PROOFS FAIL','Laws.'+law_id)
        endpoint_mutants.append({'law_id':law_id,'selection':selection,'mutant_dispatch':replacement,
                                'original_controls':controls,'compiling_mutant':compiling,
                                'active_premise_on_mutant':active,'false_instance':witness_fail,
                                'unchanged_own_endpoint_proof':proof_fail})
        (core / 'model.bend').write_text(original_model)

paths = [SUBJECTS / n for n in ['LAWS.bend', 'types.bend', 'model.bend', 'spec.bend']]
paths += [HERE / n for n in ['LAWS.bend', 'helpers.bend', 'invariants.bend', 'intervals.bend', 'order.bend', 'insertion.bend', 'complete.bend', 'enum-lookup.bend', 'enum-controls.bend', 'PROOF.bend', 'contextual.bend', 'controls.bend', 'attempt.bend', 'run.py']]
paths += [WRAPPER, pathlib.Path('/home/node/.bend/bend2/base.bend'), pathlib.Path(shutil.which('bend')).resolve()]
refs = {}
for name in ['bevy-ts', 'bevy', 'bend2']:
    reference = pathlib.Path('/workspace/formal-proofs/bendvy/.references') / name
    refs[name] = subprocess.check_output(['git', '-C', str(reference), 'rev-parse', 'HEAD'], text=True).strip()
manifest = json.loads((ROOT / '.references/sources.json').read_text())
assert all(refs[name] == manifest['sources'][name]['commit'] for name in refs)
evidence = {'status': 'all three exact approved query endpoints proved and own-endpoint compiling mutants detected',
            'approved_subject_sha256': APPROVED,
            'approved_ids': ['query_any_complete_ordered', 'query_present_complete_ordered', 'query_absent_complete_ordered'],
            'compiler_version': subprocess.check_output(['bend', 'version'], text=True).strip(),
            'reference_commits': refs,
            'hashes': {str(p): digest(p) for p in paths},
            'checks': rows, 'contextual_mutants': mutants, 'endpoint_mutants': endpoint_mutants,
            'completed_endpoint_ids': [row[0] for row in ids],
            'blocked_endpoint_ids': [],
            'integration_contextual_helpers': ['lookup_inside','lookup_below','lookup_above','enumeration_stable','observation_stable'],
            'limit_seconds': 5}
(HERE / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
print('All 3 exact query endpoint proofs/kernel checks and compiling own-section mutants passed.')
