#!/usr/bin/env python3
"""Actual FIFO cursor/mixed-order and 65,537-owned-entity prerequisite controls."""
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import sys
import tempfile
import time

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 't05'))
from run import build, execute, command, CHECK

def load(name):
    spec = importlib.util.spec_from_file_location(name, HERE / (name + '.py'))
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result

CONTRACT = load('commands-bulk-contract')
STAGE = load('storage-stage-run')
NAMES = ['types.bend', 'payload.bend', 'storage.bend', 'identity.bend', 'commands.bend',
         'query.bend', 'storage-stage-fixture.bend', 'commands-bulk-controls.bend',
         'commands-bulk-main.bend', 'commands-mixed-controls.bend']

def expected_mixed():
    lines = []
    for schema in ('Motion', 'Health'):
        w, ops = CONTRACT.fixture(schema)
        result = CONTRACT.apply_model(w, ops, 8)
        lines.append(STAGE.snapshot(result['snapshot']['world'], 1, 3).splitlines()[0])
        lines.append(''.join(f"{e['kind']}:{e['handle']['namespace']}:{e['handle']['id']};" for e in result['changes']))
    return '\n'.join(lines)

def copy_sources(folder, replacement=None):
    folder.mkdir()
    for name in NAMES:
        text = (HERE / name).read_text()
        if name == 'commands.bend' and replacement:
            old, new = replacement
            assert text.count(old) == 1, (old, text.count(old))
            text = text.replace(old, new)
        (folder / name).write_text(text)

def observed(programs, args=()):
    out = []
    timing = []
    for binary in programs:
        start = time.perf_counter()
        out.append(execute(binary, args))
        timing.append(round(time.perf_counter() - start, 6))
    assert out[0] == out[1], out
    return out[0], dict(zip(('nativeSeconds', 'javascriptSeconds'), timing))

def main():
    contract = CONTRACT.run()
    assert contract['rejectedObservations'] == 609
    evidence = {'status': 'PASS', 'scope': 'actual command application prerequisite; no E11 reader or production performance acceptance',
                'runtimeLimitSeconds': 5, 'checkerLimitSeconds': 5,
                'oracleRejectedObservations': contract['rejectedObservations'], 'bulk': [], 'mutants': []}
    with tempfile.TemporaryDirectory(prefix='commands-bulk-') as temporary:
        root = Path(temporary)
        source = root / 'original'
        copy_sources(source)
        bulk = build(source / 'commands-bulk-main.bend', source)
        for schema, number in [('Motion', 0), ('Health', 1)]:
            for count in (1, 17, 65537):
                value, times = observed(bulk, [str(number), str(count)])
                assert value == 'true', (schema, count, value)
                evidence['bulk'].append(dict(schema=schema, count=count, result=value, **times))
                print(schema, count, times, 'PASS', flush=True)
        mixed = build(source / 'commands-mixed-controls.bend', source)
        expected = expected_mixed()
        value, timing = observed(mixed)
        assert value == expected, (value, expected)
        evidence['mixed'] = dict(schemas=['Motion', 'Health'], finalRows=[3,4,6,7], changesPerSchema=12, **timing)
        evidence['mixedOutput'] = value
        mutations = [
            ('skip-lower-target-reset', ('seek_start(Schema,M,A,F,U32.is_lt(target,last),target,before,remaining,changes)', 'seek_start(Schema,M,A,F,False{},target,before,remaining,changes)'), 'mixed'),
            ('skip-equal-target', ('seek_decide(Schema,M,A,F,U32.is_lt(id,target),', 'seek_decide(Schema,M,A,F,U32.is_le(id,target),'), 'mixed'),
            ('reverse-final-events', ('(List.reverse.go(&1,S.Row<M,A,F>,before,remaining),List.reverse(&2,S.Change<Schema>,changes))', '(List.reverse.go(&1,S.Row<M,A,F>,before,remaining),changes)'), 'mixed'),
            ('discard-aux-on-remove', ('RowEdit{Some{S.Row{id,None{},aux,flag,0,0}},', 'RowEdit{Some{S.Row{id,None{},None{},flag,0,0}},'), 'bulk'),
            ('reverse-spawn-pair', ('target,S.MainChanged{S.Handle{namespace,id}} <> S.MainAdded{S.Handle{namespace,id}} <> changes}', 'target,S.MainAdded{S.Handle{namespace,id}} <> S.MainChanged{S.Handle{namespace,id}} <> changes}'), 'mixed'),
        ]
        for name, replacement, lane in mutations:
            folder = root / name
            copy_sources(folder, replacement)
            entry = 'commands-mixed-controls.bend' if lane == 'mixed' else 'commands-bulk-main.bend'
            programs = build(folder / entry, folder)
            value, timing = observed(programs, () if lane == 'mixed' else ('0', '17'))
            assert value != (expected if lane == 'mixed' else 'true'), name
            evidence['mutants'].append(dict(name=name, compiled=True, detectedOnBothBackends=True, **timing))
            print(name, 'DETECTED', flush=True)
    evidence['sources'] = {name: hashlib.sha256((HERE / name).read_bytes()).hexdigest() for name in NAMES + ['commands-bulk-run.py', 'commands-bulk-contract.py', 'COMMANDS-BULK-LAWS-DRAFT.md']}
    (HERE / 'commands-bulk-evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    print('COMMANDS BULK PASS; monotonic batches only, no universal proof or final performance acceptance', flush=True)

if __name__ == '__main__':
    main()
