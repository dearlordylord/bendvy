#!/usr/bin/env python3
"""Verify contextual schedule progress; the exact endpoint remains open."""
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
    evidence = {'status': 'PARTIAL: schedule_execution_exact remains OPEN',
                'checker_limit_seconds': 5, 'exact_endpoint_selection': True,
                'checks': [], 'mutants': []}
    for name in ['relation.bend', 'bump.bend', 'invariants.bend', 'transitions.bend', 'controls.bend']:
        for flag in ['--check-only', '--verdict']:
            result = run([CHECK, HERE / name, flag])
            assert 'ALL PROOFS CHECK' in result['output']
            evidence['checks'].append(result)
    result = run([CHECK, HERE / 'LAWS.bend', '--check-only'], 1)
    assert '1 TODO found' in result['output']
    evidence['open_endpoint'] = result
    env = dict(os.environ, BENDTT='/usr/bin/false')
    result = run([CHECK, HERE / 'relation.bend', '--verdict'], 1, env)
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
            for package in ['t11-replacement', 'p-observe-queries', 'p-observe-lookup']:
                shutil.copytree(ROOT / 'experiments' / package, base / package,
                                ignore=shutil.ignore_patterns('__pycache__', 'query-mutant-*'))
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
    evidence['canonical_sources'] = frozen['canonical_sources']
    paths = list(HERE.glob('*.bend')) + [HERE / 'verify.py', HERE / 'PLAN.md']
    paths += list((ROOT / 'experiments/p-observe-queries').glob('*.bend'))
    paths += list((ROOT / 'experiments/p-observe-lookup').glob('*.bend'))
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
