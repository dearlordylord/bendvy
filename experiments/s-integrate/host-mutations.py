#!/usr/bin/env python3
"""Compiling semantic mutations at the actual four-lane Host, with explicit scope."""
import argparse
import hashlib
import importlib.util
import json
import os
import pathlib
import re
import shutil
import sys
import tempfile

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
sys.path.insert(0, str(HERE.parent / 't05'))
from run import build, execute, command, CHECK


def module(name):
    spec = importlib.util.spec_from_file_location(name, HERE / (name + '.py'))
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


DECODE, COMPARE = module('trace-decode'), module('trace-compare')
MUTATIONS = [
    ('query-order', 'query.bend', 'List.reverse(&2,O,values)', 'values', 'snapshots'),
    ('suppressed-setter', 'payload.bend', 'position_swapped(frame,Array.swap(U32,array,0,value))', 'position_swapped(frame,Array.get(U32,array,0))', 'ownWrites'),
    ('inverse-order', 'transaction.bend', 'Reverted{unwind(W,H,restore_main,restore_ledger,undo,world)}', 'Reverted{unwind(W,H,restore_main,restore_ledger,List.reverse(&2,Inverse<H>,undo),world)}', 'snapshots'),
    ('failed-cursor', 'readers.bend', 'case T.Failure{_}: readers', 'case T.Failure{_}: completed(readers,run)', 'reads'),
    ('other-reader-routing', 'readers.bend', 'case False{}: head <> tail', 'case False{}: value <> tail', 'reads'),
    ('skip-change-cursor', 'readers.bend', 'T.ReaderState{registered,last,now}', 'T.ReaderState{registered,now,now}', 'reads'),
    ('reset-capture', 'capture.bend', 'Array.set(U32,array,0,U32.add(count,1))', 'Array.set(U32,array,0,count)', 'dispatches'),
    ('reversed-command-FIFO', 'commands.bend', 'apply_many(Schema,M,A,F,List.reverse(&1,S.Command<M,A,F>,pending),namespace,tick,(rows,[]))', 'apply_many(Schema,M,A,F,pending,namespace,tick,(rows,[]))', 'snapshots'),
    ('implicit-flush', 'dispatcher.bend', 'run(W,H,presence,invoke,barrier,transition,nodes,Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode})', 'run(W,H,presence,invoke,barrier,transition,nodes,deferred(W,H,barrier,Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}))', 'snapshots'),
    ('failed-publication-leak', 'transaction.bend', 'case Tx{world,_,undo,_,_,_}: Reverted{unwind(W,H,restore_main,restore_ledger,undo,world)}', 'case Tx{world,_,undo,commands,pings,marks}: Committed{unwind(W,H,restore_main,restore_ledger,undo,world),List.reverse(&1,C,commands),List.reverse(&2,U32,pings),marks}', 'reads'),
    ('failed-change-stamp', 'transaction.bend', 'case Tx{world,_,undo,_,_,_}: Reverted{unwind(W,H,restore_main,restore_ledger,undo,world)}', 'case Tx{world,_,undo,_,_,marks}: Committed{unwind(W,H,restore_main,restore_ledger,undo,world),[],[],marks}', 'reads'),
    ('reissued-failed-reservation', 'transaction.bend', 'case Reverted{world}: (world,[])', 'case Reverted{world}: (storage_rewind(Schema,M,A,F,L,Mode,world),[])', 'rawReservations'),
]


def closure(entrypoints):
    names, pending = set(), list(entrypoints)
    while pending:
        name = pending.pop()
        if name in names:
            continue
        names.add(name)
        pending.extend(re.findall(r'^import \./(\S+\.bend)', (HERE / name).read_text(), re.M))
    return sorted(names)


def differences(reference, observed, channels):
    expected = {lane['lane']: lane for lane in reference['results']}
    actual = {lane['lane']: lane for lane in observed['results']}
    assert expected.keys() == actual.keys() == COMPARE.LANES
    result = []
    for lane in sorted(expected):
        for channel in channels:
            COMPARE.difference(expected[lane][channel], actual[lane][channel], lane + '.' + channel, result)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--stage', choices=['complete', 'E0-E9'], default='complete')
    parser.add_argument('--only', action='append', choices=[row[0] for row in MUTATIONS])
    parser.add_argument('--output', type=pathlib.Path, default=HERE / 'host-mutation-evidence.json')
    parser.add_argument('--optimization', choices=['O0', 'O3'], default='O3')
    parser.add_argument('--cpu', type=int)
    args = parser.parse_args()
    if args.cpu is not None:
        os.sched_setaffinity(0, {args.cpu})
    channels = [key for key in COMPARE.CHANNELS if args.stage == 'complete' or key != 'provisioning']
    reference_text = command(['node', ROOT / 'experiments/s-integrate-trace/reference-main.mjs'])
    reference = json.loads(reference_text)
    assert not reference.get('defect') and not reference.get('differences')
    split = ['host-motion-fixture.bend', 'host-health-fixture.bend']
    entrypoints = split if all((HERE / name).exists() for name in split) else ['host-fixture.bend']
    names = closure(entrypoints)
    frozen = {name: (HERE / name).read_text() for name in names}
    evidence = {'scope': args.stage, 'fullTaskAcceptance': False, 'checkerLimitSeconds': 5,
                'runtimeLimitSeconds': 5, 'referenceSHA256': hashlib.sha256(reference_text.encode()).hexdigest(),
                'nativeOptimization': args.optimization, 'cpuAffinity': sorted(os.sched_getaffinity(0)),
                'entrypoints': entrypoints,
                'decoderSHA256': hashlib.sha256((HERE / 'trace-decode.py').read_bytes()).hexdigest(),
                'comparatorSHA256': hashlib.sha256((HERE / 'trace-compare.py').read_bytes()).hexdigest(),
                'sources': {name: hashlib.sha256(frozen[name].encode()).hexdigest() for name in names},
                'channels': channels, 'original': None, 'mutants': []}
    with tempfile.TemporaryDirectory(prefix='host-mutations-') as temporary:
        base = pathlib.Path(temporary)
        cases = [None] + [row for row in MUTATIONS if not args.only or row[0] in args.only]
        for mutation in cases:
            label = mutation[0] if mutation else 'original'
            folder = base / label
            folder.mkdir()
            for name in names:
                source = frozen[name]
                if mutation and name == mutation[1]:
                    assert source.count(mutation[2]) == 1, (label, source.count(mutation[2]))
                    source = source.replace(mutation[2], mutation[3])
                    if label == 'skip-change-cursor':
                        old = 'def skip_found(+key: U32,now: U32,'
                        assert source.count(old) == 1
                        source = source.replace(old, 'def skip_found(+key: U32,+now: U32,')
                    if label == 'reissued-failed-reservation':
                        helper = '''def storage_rewind(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,world:S.World<Schema,M,A,F,L,Mode>) -> S.World<Schema,M,A,F,L,Mode>:
  match world:
    case S.World{ns,next,rows,pending,ledger,mode}: S.World{ns,U32.sub(next,1),rows,pending,ledger,mode}
'''
                        source = source.replace('def storage_commit(', helper + '\ndef storage_commit(')
                (folder / name).write_text(source)
            programs = []
            for entrypoint in entrypoints:
                source = folder / entrypoint
                if args.optimization == 'O3':
                    programs.append(build(source, folder))
                else:
                    checked = command([CHECK, source, '--check-only'])
                    assert 'ALL PROOFS CHECK' in checked
                    native_c = folder / (source.stem + '.c')
                    native = folder / (source.stem + '-native')
                    javascript = folder / (source.stem + '.js')
                    command(['bend', source, '-o', native_c], timeout=30)
                    command(['clang', '-std=c11', '-O0', native_c, '-lpthread', '-lm', '-o', native], timeout=120)
                    command(['bend', source, '-o', javascript], timeout=30)
                    programs.append((native, javascript))
            print(label, 'compiled actual entrypoints: Native ' + args.optimization + ' and JS', flush=True)
            observations = []
            for index, backend in enumerate(['native', 'javascript']):
                raw = '\n'.join(execute(pair[index]) for pair in programs)
                try:
                    decoded = DECODE.decode(raw)
                except ValueError as error:
                    if label != 'reissued-failed-reservation' or str(error) != 'reserved handle reissued':
                        raise
                    seen, repeated = {}, []
                    lane = None
                    for line in raw.splitlines():
                        if not line.startswith(('{', '[')):
                            continue
                        value = json.loads(line)
                        if isinstance(value, dict) and value.get('kind') == 'Lane':
                            lane = value['schema'] + '/' + value['style']
                            seen = {}
                        elif isinstance(value, list):
                            for event in value:
                                if event['kind'] != 'Reserved':
                                    continue
                                key = event['handle']['namespace'], event['handle']['id']
                                if key in seen:
                                    repeated.append({'lane': lane, 'earlier': seen[key], 'reissued': event})
                                seen[key] = event
                    assert len(repeated) == 4, repeated
                    observations.append({'backend': backend, 'compiling': True,
                        'outputSHA256': hashlib.sha256(raw.encode()).hexdigest(),
                        'witness': {'path': repeated[0]['lane'] + '.rawReservations',
                                    'error': str(error), 'actual': repeated[0]}})
                    continue
                diff = differences(reference, decoded, channels)
                if mutation:
                    intended = [item for item in diff if ('.' + mutation[4]) in item['path']]
                    if label == 'failed-publication-leak':
                        intended = [item for item in intended if '.messages' in item['path']]
                    assert intended, (label, backend, diff[:5])
                    witness = intended[0]
                    if label == 'failed-publication-leak':
                        match = re.match(r'^(.*)\.reads\[(\d+)\]', witness['path'])
                        lane, at = match[1], int(match[2])
                        actual_read = next(row for row in decoded['results'] if row['lane'] == lane)['reads'][at]
                        expected_read = next(row for row in reference['results'] if row['lane'] == lane)['reads'][at]
                        witness = {**witness, 'step': actual_read['step'], 'who': actual_read['who'],
                                   'expectedMessages': expected_read['messages'], 'actualMessages': actual_read['messages']}
                    observations.append({'backend': backend, 'compiling': True,
                                         'outputSHA256': hashlib.sha256(raw.encode()).hexdigest(),
                                         'differenceCount': len(diff), 'witness': witness})
                else:
                    assert not diff, diff[:10]
                    observations.append({'backend': backend, 'fullSelectedChannelsEqual': True,
                                         'outputSHA256': hashlib.sha256(raw.encode()).hexdigest()})
            if mutation:
                evidence['mutants'].append({'name': label, 'observations': observations})
                print(label, 'DETECTED on Native and JS', flush=True)
            else:
                evidence['original'] = observations
                print('actual Host original selected channels PASS', flush=True)
            args.output.write_text(json.dumps(evidence, indent=2) + '\n')
    print('HOST MUTATIONS PASS; scope=' + args.stage, flush=True)


if __name__ == '__main__':
    main()
