#!/usr/bin/env python3
"""Verify the exact schedule endpoint and compiling own-induction mutants."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import tempfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
CHECK = ROOT / 'experiments/t01/bend-check'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(args, expected=0, env=None):
    start = time.monotonic()
    process = subprocess.Popen([str(x) for x in args], stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, text=True,
                               start_new_session=True, env=env)
    try:
        output = process.communicate(timeout=6)[0]
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        process.communicate()
        raise AssertionError('Five-second checker wrapper watchdog failed')
    assert process.returncode == expected, (args, process.returncode, output)
    return {'command': [str(x) for x in args], 'exit_code': process.returncode,
            'elapsed_seconds': round(time.monotonic() - start, 4), 'output': output}


def main():
    frozen = json.loads((HERE / 'subjects.json').read_text())
    for name, digest in frozen['canonical_sources'].items():
        assert sha(ROOT / name) == digest, name
    original = (ROOT / 'experiments/t11-replacement/LAWS.bend').read_text()
    block = re.search(r'^law schedule_execution_exact:\n(?:(?!^law ).*\n)*', original, re.M).group().rstrip()
    assert block == frozen['original_block'] == (HERE / 'LAWS.bend').read_text().split('\n\n', 1)[1].rstrip()
    evidence = {'status': 'PASS: exact schedule_execution_exact proof, kernel, and own-section mutations',
                'checker_limit_seconds': 5, 'exact_endpoint_selection': True,
                'checks': [], 'mutants': []}
    for name in ['relation.bend', 'bump.bend', 'invariants.bend', 'transitions.bend', 'allocation.bend', 'successor.bend', 'context.bend', 'induction.bend', 'barrier.bend', 'schedule.bend', 'PROOF.bend', 'controls.bend', 'endpoint-controls.bend']:
        for flag in ['--check-only', '--verdict']:
            result = run([CHECK, HERE / name, flag])
            assert 'ALL PROOFS CHECK' in result['output']
            evidence['checks'].append(result)
    result = run([CHECK, HERE / 'LAWS.bend', '--check-only'], 1)
    assert '1 TODO found' in result['output']
    evidence['standalone_selected_law_before_proof_import'] = result
    env = dict(os.environ, BENDTT='/usr/bin/false')
    result = run([CHECK, HERE / 'PROOF.bend', '--verdict'], 1, env)
    assert 'mismatch' in result['output']
    evidence['kernel_negative'] = result
    mutants = [
        ('bump-creates-ghost',
         'def bump_rows(+slot: Nat, rows: List<&2, T.Row>) -> List<&2, T.Row>:\n  match rows:\n    case Nil{}: []',
         'def bump_rows(+slot: Nat, rows: List<&2, T.Row>) -> List<&2, T.Row>:\n  match rows:\n    case Nil{}: [T.Row{0n,0n,False{}}]',
         'bump.bend', 'bump_point'),
        ('reserve-does-not-advance',
         'T.Reserved{T.World{id, 1n+next, rows, List.append(&2, T.Command, pending, [T.Spawn{next, value}])}',
         'T.Reserved{T.World{id, next, rows, List.append(&2, T.Command, pending, [T.Spawn{next, value}])}',
         'transitions.bend', 'reserve_related_case'),
    ]
    for label, old, new, entry, location in mutants:
        with tempfile.TemporaryDirectory(prefix='schedule-mutant-', dir=HERE) as tmp:
            base = Path(tmp)
            for package in ['t11-replacement', 'p-observe-queries', 'p-observe-lookup', 'p-observe-flush']:
                shutil.copytree(ROOT / 'experiments' / package, base / package,
                                ignore=shutil.ignore_patterns('__pycache__', '*mutant-*'))
            package = base / 'p-observe-schedule'
            package.mkdir()
            for source in HERE.glob('*.bend'):
                shutil.copy2(source, package / source.name)
            positive = run([CHECK, package / entry, '--verdict'])
            assert 'ALL PROOFS CHECK' in positive['output']
            model = base / 't11-replacement/model.bend'
            text = model.read_text()
            assert text.count(old) == 1
            model.write_text(text.replace(old, new))
            compiled = run([CHECK, model, '--check-only'])
            assert 'ALL PROOFS CHECK' in compiled['output']
            failed = run([CHECK, package / entry, '--check-only'], 1)
            assert f'Location: {location}' in failed['output'], failed
            evidence['mutants'].append({'name': label, 'old': old, 'new': new,
                                        'contextual_definition': location, 'copied_positive': positive,
                                        'compiled_mutant': compiled, 'unchanged_contextual_failure': failed})
    endpoint_mutants = [
        ('implicit-final-flush',
         'def tick(steps: List<&2, T.Step>, +limit: Nat, world: T.World) -> T.World:\n  match steps:\n    case Nil{}: world',
         'def tick(steps: List<&2, T.Step>, +limit: Nat, world: T.World) -> T.World:\n  match steps:\n    case Nil{}: flush(world)',
         '[T.Reserve{5n}]'),
        ('schedule-drops-tail',
         'case Con{step, tail}: tick(tail, limit, M_step(limit, world, step))',
         'case Con{step, tail}: M_step(limit, world, step)',
         '[T.Reserve{5n},T.Barrier{}]'),
    ]
    evidence['endpoint_mutants'] = []
    for label, old, new, steps in endpoint_mutants:
        with tempfile.TemporaryDirectory(prefix='schedule-endpoint-mutant-', dir=HERE) as tmp:
            base = Path(tmp)
            for package_name in ['t11-replacement', 'p-observe-queries', 'p-observe-lookup', 'p-observe-flush']:
                shutil.copytree(ROOT / 'experiments' / package_name, base / package_name,
                                ignore=shutil.ignore_patterns('__pycache__', '*mutant-*'))
            package = base / 'p-observe-schedule'
            package.mkdir()
            for source in HERE.glob('*.bend'):
                shutil.copy2(source, package / source.name)
            unchanged = {source.name: sha(source) for source in package.glob('*.bend')}
            witness = package / 'own-witness.bend'
            witness.write_text('import Base\nimport ../t11-replacement/types.bend as T\n'
                               'import ../t11-replacement/model.bend as M\nimport ../t11-replacement/spec.bend as S\n'
                               'def premise() -> {True{} == S.admissible(4n,T.World{7n,2n,[],[]}) : Bool}: {==}\n'
                               'def exact_schedule_instance() -> S.When(S.admissible(4n,T.World{7n,2n,[],[]}),'
                               f' {{M.observe(M.tick({steps},4n,T.World{{7n,2n,[],[]}})) == '
                               f'S.schedule_observation(4n,T.World{{7n,2n,[],[]}}, {steps}) : T.Observation}}): {{==}}\n')
            positive = run([CHECK, package / 'PROOF.bend', '--verdict'])
            literal_positive = run([CHECK, witness, '--verdict'])
            assert 'ALL PROOFS CHECK' in positive['output']
            assert 'ALL PROOFS CHECK' in literal_positive['output']
            model = base / 't11-replacement/model.bend'
            text = model.read_text()
            assert text.count(old) == 1
            model.write_text(text.replace(old, new))
            compiled = run([CHECK, model, '--check-only'])
            assert 'ALL PROOFS CHECK' in compiled['output']
            for name, digest in unchanged.items():
                assert sha(package / name) == digest, name
            failed = run([CHECK, package / 'PROOF.bend', '--check-only'], 1)
            assert 'Location: schedule_related' in failed['output'], failed
            literal_failed = run([CHECK, witness, '--check-only'], 1)
            assert 'Location: exact_schedule_instance' in literal_failed['output'], literal_failed
            # A separate unchanged premise entry rules out a false-domain control.
            premise = package / 'own-premise.bend'
            premise.write_text(witness.read_text().split('def exact_schedule_instance', 1)[0])
            active = run([CHECK, premise, '--verdict'])
            assert 'ALL PROOFS CHECK' in active['output']
            evidence['endpoint_mutants'].append({'name': label, 'old': old, 'new': new,
                'law_id': 'schedule_execution_exact', 'failure_location': 'schedule_related',
                'failure_scope': 'Dedicated universal induction in the endpoint section; not the final law wrapper',
                'unchanged_proof_hashes': unchanged, 'copied_positive': positive,
                'original_true_premise_instance': literal_positive, 'compiled_mutant': compiled,
                'unchanged_own_section_failure': failed, 'false_endpoint_instance': literal_failed,
                'active_premise_on_mutant': active})
    manifest = json.loads((ROOT / '.references/sources.json').read_text())
    reference_root = ROOT / '.references'
    if not (reference_root / 'bevy-ts/.git').exists():
        reference_root = Path('/workspace/formal-proofs/bendvy/.references')
    evidence['reference_commits'] = {}
    for name, reference in manifest['sources'].items():
        actual = subprocess.run(['git', '-C', str(reference_root / name), 'rev-parse', 'HEAD'],
                                capture_output=True, text=True, check=True).stdout.strip()
        assert actual == reference['commit'], name
        evidence['reference_commits'][name] = actual
    evidence['canonical_sources'] = frozen['canonical_sources']
    paths = list(HERE.glob('*.bend')) + [HERE / 'verify.py', HERE / 'PLAN.md']
    paths += list((ROOT / 'experiments/p-observe-queries').glob('*.bend'))
    paths += list((ROOT / 'experiments/p-observe-lookup').glob('*.bend'))
    paths += list((ROOT / 'experiments/p-observe-flush').glob('*.bend'))
    evidence['source_hashes'] = {str(path.relative_to(ROOT)): sha(path) for path in paths}
    evidence['base_sha256'] = sha(Path.home() / '.bend/bend2/base.bend')
    compiler = Path(shutil.which('bend')).resolve()
    evidence['compiler_path'] = str(compiler)
    evidence['compiler_sha256'] = sha(compiler)
    evidence['compiler_version'] = subprocess.run(['bend', 'version'], capture_output=True, text=True, check=True).stdout.strip()
    (HERE / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    print(evidence['status'])


if __name__ == '__main__':
    main()
