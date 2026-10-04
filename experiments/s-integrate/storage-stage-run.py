#!/usr/bin/env python3
"""Actual owned storage E0/E1/foreign/FIFO slice; not dispatcher acceptance."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import sys
import tempfile

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 't05'))
from run import build, paired, command, CHECK
spec = importlib.util.spec_from_file_location('contract', HERE / 'storage-observation-contracts.py')
contract = importlib.util.module_from_spec(spec)
spec.loader.exec_module(contract)
NAMES = ['types.bend', 'payload.bend', 'storage.bend', 'identity.bend', 'commands.bend',
         'query.bend', 'storage-stage-fixture.bend']


def payload(schema, value, kind):
    if value is None:
        return 'none'
    if kind == 'main':
        if schema == 'Motion':
            return 'position[' + ','.join(map(str, value['coordinates'])) + '];frame=' + str(value['frame'])
        return 'vitals[' + ','.join(map(str, value['levels'])) + '];reserve=' + str(value['reserve']) + ';class=' + str(value['class'])
    if kind == 'aux':
        if schema == 'Motion':
            return 'velocity[' + ','.join(map(str, value['rates'])) + '];moving=' + str(value['moving']).lower()
        return 'armor[' + ','.join(map(str, value['layers'])) + '];grade=' + str(value['grade'])
    return ('selected=' if schema == 'Motion' else 'tracked=') + str(value['group'])


def bundle(schema, row):
    return ';'.join(payload(schema, row[k], k) for k in ('main', 'aux', 'flag'))


def row(w, r, query=False):
    prefix = (str(w['namespace']) + ':') if query else ''
    text = prefix + str(r['id']) + '{' + bundle(w['schema'], r)
    if not query:
        text += ';added=' + str(r['added']) + ';changed=' + str(r['changed'])
    return text + '}'


def snapshot(w, a, c):
    schema = w['schema']
    queued = []
    for cmd in w['pending']:
        if cmd['op'] == 'spawn':
            queued.append('spawn:' + str(cmd['row']['id']) + '{' + bundle(schema, cmd['row']) + '}')
        else:
            queued.append('insertMain:' + str(cmd['id']) + '{' + payload(schema, cmd['main'], 'main') + '}')
    text = ('ns=' + str(w['namespace']) + ';next=' + str(w['next']) + ';rows=[' +
            '|'.join(row(w, r) for r in w['rows']) + '];pending=[' + '|'.join(queued) +
            '];ledger[' + ','.join(map(str, w['ledger']['totals'])) + '];epoch=' + str(w['ledger']['epoch']) + ';mode=' + w['mode'])
    lines = [text]
    for selection in ('required', 'present', 'absent', 'optional'):
        lines.append('[' + '|'.join(row(w, r, True) for r in contract.selected(w, selection)) + ']')
    for entity in (a, c):
        value = contract.lookup(w, contract.handle(w, entity))
        lines.append('Found(' + row(w, value['row'], True) + ')' if value['kind'] == 'Found' else value['kind'])
    return '\n'.join(lines)


def fixtures():
    output = ['factory-next=5']
    checkpoints = {}
    for schema, ns in [('Motion', 1), ('Health', 3)]:
        alpha = contract.world(schema, ns)
        beta = contract.world(schema, ns + 1)
        bundles = [contract.row(schema, 0, 10, True, True), contract.row(schema, 0, 20),
                   contract.row(schema, 0, None, True, True)]
        alpha = contract.reserve_model(alpha, bundles)['afterReserve']['world']
        beta = contract.reserve_model(beta, [contract.row(schema, 0, 90, flag=True)])['afterReserve']['world']
        for label, w, a, c in [('E0-alpha', alpha, 1, 3), ('E0-beta', beta, 1, 1)]:
            output += [schema + '/' + label, snapshot(w, a, c)]
            checkpoints[schema + '/' + label] = copy.deepcopy(w)
        alpha = contract.apply_model(alpha, 1)['world']
        beta = contract.apply_model(beta, 1)['world']
        for label, w, a, c in [('E1-alpha', alpha, 1, 3), ('E1-beta', beta, 1, 1)]:
            output += [schema + '/' + label, snapshot(w, a, c)]
            checkpoints[schema + '/' + label] = copy.deepcopy(w)
        alpha['pending'] = [{'op': 'insert_main', 'id': 1, 'main': contract.main_value(schema, 77)}]
        beta['pending'] = [{'op': 'insert_main', 'id': 1, 'main': contract.main_value(schema, 78)}]
        output += [schema + '/foreign-before-alpha', snapshot(alpha, 1, 3),
                   schema + '/foreign-before-beta', snapshot(beta, 1, 1),
                   'MissingEntity;returned=' + payload(schema, contract.main_value(schema, 600), 'main'),
                   'MissingEntity;returned=' + payload(schema, contract.main_value(schema, 500), 'main'),
                   schema + '/foreign-after-alpha', snapshot(alpha, 1, 3),
                   schema + '/foreign-after-beta', snapshot(beta, 1, 1), 'MissingEntity', 'MissingEntity']
        alpha['pending'] += [{'op': 'insert_main', 'id': 1, 'main': contract.main_value(schema, x)} for x in (80, 81)]
        alpha = contract.apply_model(alpha, 2)['world']
        output += [schema + '/FIFO-alpha', snapshot(alpha, 1, 3)]
    return '\n'.join(output), checkpoints


def check_reference(checkpoints):
    assert command(['node', '--version']).strip() == 'v24.20.0'
    actual = json.loads(command(['node', HERE.parent / 's-integrate-trace' / 'reference-main.mjs']))
    assert actual['status'].startswith('PASS'), actual.get('differences')
    assert actual['reference']['commit'] == '3040a3b2a3f28fa8554d856f9ccb6bf5433fa334'
    compared = 0
    for lane in actual['results']:
        if lane['style'] != 'returned-owner':
            continue
        for name, short in [('E0-pending', 'E0'), ('E1', 'E1')]:
            for side in ('alpha', 'beta'):
                ts = next(x for x in lane['snapshots'] if x['name'] == name and x['world'] == side)
                w = checkpoints[lane['schema'] + '/' + short + '-' + side]
                def normal(r, aux=False):
                    result = {'rawId': r['id'], 'main': r['main'], 'flag': r['flag']}
                    if aux:
                        result['aux'] = r['aux']
                    return result
                for key, selection in [('q', 'required'), ('plus', 'present'), ('minus', 'absent'), ('optional', 'optional')]:
                    got = [{k: v for k, v in x.items() if k != 'label'} for x in ts[key]]
                    assert got == [normal(r, key == 'optional') for r in contract.selected(w, selection)], (lane['schema'], name, side, key)
                assert ts['ledger'] == w['ledger']
                expected_aux = [dict(rawId=r['id'], main=r['main'], aux=r['aux'], flag=r['flag']) for r in w['rows'] if r['aux'] is not None]
                assert [{k: v for k, v in x.items() if k != 'label'} for x in ts['aux']] == expected_aux
                for label, entity in ([('a', 1), ('c', 3)] if side == 'alpha' else [('z', 1)]):
                    assert ts['lookups'][label]['result'] == contract.lookup(w, contract.handle(w, entity))['kind']
                compared += 1
        assert [x['result']['result'] for x in lane['foreignLookupDivergence']] == ['Found', 'Found']
    return {'freshReferenceSnapshotsCompared': compared, 'referenceAdapterSha256': actual['adapterSha256'],
            'referenceCommit': actual['reference']['commit'],
            'foreignLookup': 'TS resolves colliding local entity; Bend MissingEntity checked separately'}


COMMON = '''import Base
import ./types.bend as T
import ./storage.bend as S
import ./query.bend as Q
import ./payload.bend as Payload
import ./storage-stage-fixture.bend as F
'''
W = 'S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>'
ARGS = '~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.PositionToken,~T.PositionView,~T.VelocityView,~String,~T.MotionLedger,~T.MotionMode,~Payload.position_get,~Payload.velocity_get'
SIGNATURE = '(-P: Type,-U: Type,get: P -> T.PositionToken -> P & T.PositionView,get_aux: U -> U & Maybe<&2,T.VelocityView>,handle: S.Handle<T.MotionSchema>,flag: Maybe<&2,T.Selected>,main: P,aux: U) -> P & (U & String):\n'


def controls(folder):
    good = COMMON + 'def good' + SIGNATURE + '  F.motion_client(P,U,get,get_aux,handle,flag,main,aux)\n' + f'def attempt(world: {W}) -> {W} & List<&2,String>:\n  Q.each({ARGS},~good,Q.Required{{}},world)\n'
    positive = folder / 'positive.bend'
    positive.write_text(good)
    assert 'ALL PROOFS CHECK' in command([CHECK, positive, '--check-only'])
    cases = {
        'write-through-read': ('  Payload.position_swap(main,1)\n', ['expected : T.Position', 'observed : P']),
        'undeclared-aux': ('  Payload.velocity_get(main)\n', ['expected : T.Velocity', 'observed : P']),
        'wrong-token': ('  F.motion_client_main(P,U,aux,get_aux,handle,flag,get(main,T.VitalsToken{}))\n', ['expected : T.PositionToken', 'observed : T.VitalsToken']),
        'reconstruction': ('  (T.Position{F.vector(10),7},(aux,""))\n', ['expected : P', 'observed : T.Position']),
        'missing-owner': ('  ("",(aux,""))\n', ['expected : P', 'observed : String']),
        'consumed-owner': ('  ignored = get(main,T.PositionToken{})\n  (main,(aux,""))\n', ['consumed more than once']),
    }
    result = {}
    for name, (body, messages) in cases.items():
        source = folder / (name + '.bend')
        source.write_text(COMMON + 'def bad' + SIGNATURE + body + f'def attempt(world: {W}) -> {W} & List<&2,String>:\n  Q.each({ARGS},~bad,Q.Required{{}},world)\n')
        diagnostic = command([CHECK, source, '--check-only'], expected=1)
        assert 'Location: bad' in diagnostic, diagnostic
        assert all(x in diagnostic for x in messages), diagnostic
        result[name] = {'expectedExit': 1, 'diagnostic': messages, 'location': 'bad'}
    source = folder / 'cross-schema-handle.bend'
    source.write_text(COMMON + f'def bad(world: {W},handle: S.Handle<T.HealthSchema>) -> {W} & T.Access<String>:\n  Q.lookup({ARGS},~F.motion_client,Q.Required{{}},world,handle)\n')
    diagnostic = command([CHECK, source, '--check-only'], expected=1)
    assert 'T.MotionSchema' in diagnostic and 'T.HealthSchema' in diagnostic and 'Location: bad' in diagnostic, diagnostic
    result['cross-schema-handle'] = {'expectedExit': 1, 'diagnostic': ['T.MotionSchema', 'T.HealthSchema'], 'location': 'bad'}
    return result


MUTANTS = {
    'foreign-lookup': ('query.bend', 'U32.is_eq(namespace,foreign)', 'True{}'),
    'foreign-command': ('commands.bend', 'U32.is_eq(namespace,foreign)', 'True{}'),
    'reversed-query-order': ('query.bend', 'value <> values', 'List.append(&2,O,values,[value])'),
    'reversed-command-FIFO': ('commands.bend', 'List.reverse(&1,S.Command<M,A,F>,pending)', 'pending'),
    'constant-namespace': ('identity.bend', 'S.World{namespace,1,[],[],Some{initial_ledger(Unit{})},mode}', 'S.World{1,1,[],[],Some{initial_ledger(Unit{})},mode}'),
}


def main():
    expected, checkpoints = fixtures()
    manifest = json.loads((HERE.parent.parent / '.references' / 'sources.json').read_text())
    reference_heads = {}
    for name, entry in manifest['sources'].items():
        actual = command(['git', '-C', '/workspace/formal-proofs/bendvy/.references/' + name, 'rev-parse', 'HEAD']).strip()
        assert actual == entry['commit'], (name, actual)
        reference_heads[name] = actual
    evidence = {'scope': 'actual owned storage/factory/commands/query stage E0/E1, foreign divergence and FIFO overwrite',
                'limits': {'checkerSeconds': 5, 'runtimeSeconds': 5, 'codegenSeconds': 30, 'clangSeconds': 120},
                'hashes': {n: hashlib.sha256((HERE/n).read_bytes()).hexdigest() for n in NAMES},
                'reference': check_reference(checkpoints), 'mutants': {},
                'referenceHeads': reference_heads, 'compiler': command(['bend', 'version']).strip(),
                'baseSha256': hashlib.sha256((Path.home() / '.bend/bend2/base.bend').read_bytes()).hexdigest(),
                'notEstablished': ['actual dispatcher empty-tick behavior', 'transactions/readers integration',
                                   'full E0-E11 trace', 'universal authority/proof/refinement', 'performance acceptance']}
    with tempfile.TemporaryDirectory(prefix='storage-stage-') as temporary:
        root = Path(temporary)
        for label, replacement in [('original', None), *MUTANTS.items()]:
            folder = root / label
            folder.mkdir()
            for name in NAMES:
                shutil.copyfile(HERE / name, folder / name)
            if replacement:
                file, old, new = replacement
                source = folder / file
                text = source.read_text()
                assert text.count(old) == 1, (label, text.count(old))
                source.write_text(text.replace(old, new))
            else:
                evidence['negativeControls'] = controls(folder)
            value = paired(build(folder / 'storage-stage-fixture.bend', folder))
            if label == 'original':
                assert value == expected, 'Full-field native/JS stage mismatch'
                evidence['originalOutputSha256'] = hashlib.sha256(value.encode()).hexdigest()
                evidence['originalLines'] = len(value.splitlines())
                (HERE / 'storage-stage-observed.txt').write_text(value + '\n')
            else:
                assert value != expected, 'Compiling semantic mutant survived: ' + label
                first = next((i + 1 for i, (a,b) in enumerate(zip(expected.splitlines(), value.splitlines())) if a != b), None)
                evidence['mutants'][label] = {'compiledBothBackends': True, 'firstDifferentLine': first,
                                             'outputSha256': hashlib.sha256(value.encode()).hexdigest(),
                                             'expectedFirstDifference': expected.splitlines()[first-1] if first else None,
                                             'actualFirstDifference': value.splitlines()[first-1] if first else None}
            print(label + ': PASS', flush=True)
    (HERE / 'storage-stage-evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    print('STORAGE STAGE PASS; full integrated dispatcher/readers/runtime/performance remain open')


if __name__ == '__main__':
    main()
