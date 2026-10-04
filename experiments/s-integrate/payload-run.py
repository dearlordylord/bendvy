#!/usr/bin/env python3
"""Actual payload slice: full-field owner reads, inverse swaps, compiled mutants."""
import hashlib
import json
from pathlib import Path
import sys
import tempfile

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 't05'))
from run import build, command, paired


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def expected():
    rows = []
    for label, original, middle, final, tail, metadata in [
        ('position', 20, 30, 50, '21,22,23', '7'),
        ('vitals', 20, 30, 50, '21,22,23', '9:2'),
        ('motionLedger', 101, 201, 301, '101,102,103', '4'),
        ('healthLedger', 101, 201, 301, '101,102,103', '4'),
    ]:
        rows.append(f'{label}:old1={original};between={middle},{tail}:{metadata};'
                    f'old2={middle};after={final},{tail}:{metadata};'
                    f'undo2={final};undo1={middle};restore={original},{tail}:{metadata};')
    rows.extend(['velocity:first=1,2,3,4:True;again=1,2,3,4:True;',
                 'armor:first=1,2,3,4:3;again=1,2,3,4:3;'])
    return '\n'.join(rows)


def main():
    compiler = Path(command(['which', 'bend']).strip())
    assert command(['bend', 'version']).strip() == 'bend 2.0.34'
    command(['bend', 'guide'])
    evidence = {
        'scope': 'Actual payload helpers only; no integrated dispatcher/TS parity/proof/performance claim',
        'compiler_sha256': digest(compiler),
        'base_sha256': digest(Path.home() / '.bend/bend2/base.bend'),
        'limits_seconds': {'checker': 5, 'codegen': 30, 'clang': 120, 'runtime': 5},
        'ordinary_interpreter_attempt': {'exit': 137, 'limit_seconds': 5,
            'result': 'Failed initial coordinator attempt; not a passing checker/runtime observation'},
        'expected': expected(), 'mutants': {},
    }
    with tempfile.TemporaryDirectory(prefix='integrate-payload-') as directory:
        folder = Path(directory)
        actual = paired(build(HERE / 'payload-controls.bend', folder), quoted=True)
        assert actual == expected(), (actual, expected())
        evidence['actual_native_js'] = actual
        source = (HERE / 'payload.bend').read_text()
        for name in ['position', 'vitals', 'motion_ledger', 'health_ledger']:
            mutant = folder / name
            mutant.mkdir()
            for filename in ['types.bend', 'payload-controls.bend']:
                (mutant / filename).write_bytes((HERE / filename).read_bytes())
            start = source.index(f'def {name}_swap(')
            stop = source.find('\ndef ', start + 1)
            if stop == -1:
                stop = len(source)
            segment = source[start:stop]
            assert segment.count('Array.swap(U32,array,0,value)') == 1
            changed = segment.replace('Array.swap(U32,array,0,value)',
                                      'Array.swap(U32,array,1,value)')
            (mutant / 'payload.bend').write_text(source[:start] + changed + source[stop:])
            wrong = paired(build(mutant / 'payload-controls.bend', mutant), quoted=True)
            assert wrong != actual, name
            correct_rows, wrong_rows = actual.splitlines(), wrong.splitlines()
            differences = [i for i, (a, b) in enumerate(zip(correct_rows, wrong_rows)) if a != b]
            assert differences == [['position', 'vitals', 'motion_ledger', 'health_ledger'].index(name)]
            index = differences[0]
            evidence['mutants'][name + '-wrong-slot'] = {
                'checker': 'PASS', 'native_js_agree': True,
                'expected': correct_rows[index], 'actual': wrong_rows[index],
            }
    evidence['source_sha256'] = {name: digest(HERE / name) for name in
        ['types.bend', 'payload.bend', 'payload-controls.bend', 'payload-run.py', 'PAYLOAD-LAWS-DRAFT.md']}
    (HERE / 'payload-evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    print('PASS: six complete payload rows, retained owners, four compiling wrong-slot mutants')


if __name__ == '__main__':
    main()
