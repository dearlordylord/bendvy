#!/usr/bin/env python3
"""Pinned source-only Main Array transport probe; originals and fallbacks retained."""
import argparse, hashlib, json, pathlib, re, shutil

HERE = pathlib.Path(__file__).resolve().parent
MODULE = 'experiments/s-integrate/held-adapter.bend'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
closure = lambda pins: hashlib.sha256(json.dumps(pins, sort_keys=True, separators=(',', ':')).encode()).hexdigest()

def once(source, old, new):
    assert source.count(old) == 1, (old, source.count(old))
    return source.replace(old, new, 1)

def definition(source, name):
    m = re.search(r'^def ' + re.escape(name) + r'\(', source, re.M)
    assert m, name
    tail = source[m.start():]
    stop = re.search(r'\n(?:def |type )', tail)
    return tail[:stop.start() + 1] if stop else tail

def materialize(root, output):
    root = root.resolve(strict=True)
    output = output.absolute()
    assert not output.exists() and not output.is_relative_to(root)
    assert not any(p.is_symlink() for p in root.rglob('*'))
    pins = {str(p.relative_to(root)): sha(p) for p in root.rglob('*.bend')}
    assert len(pins) == 29 and pins == json.loads((HERE / 'input-pins.json').read_text())
    overlay = json.loads((root / 'overlay.json').read_text())
    cache = json.loads((root / 'cache-specialization.json').read_text())
    assert overlay['cacheSpecialization'] == cache
    assert overlay['sources'] == cache['runtimeClosure'] == cache['specializedClosure'] == pins
    assert cache['runtimeClosureSHA256'] == closure(pins)
    original = (root / MODULE).read_text()
    assert 'prototype_mainarray_' not in original and 'PrototypeMainArray' not in original
    source = original
    clones = []
    for schema in ['motion', 'health']:
        motion = schema == 'motion'
        prefix = 'prototype_flatrows_motion_' if motion else 'prototype_journalledger_health_'
        newprefix = 'prototype_mainarray_' + schema + '_'
        owner = ('PrototypeFlatRowOwner<T.Position,T.PositionView,T.MotionLedger,T.LedgerView,T.MotionSchema>' if motion else
                 'PrototypeJournalLedgerRowOwner<T.Vitals,T.VitalsView,T.LedgerView,T.HealthSchema>')
        ctor = 'PrototypeFlatRowOwner' if motion else 'PrototypeJournalLedgerRowOwner'
        newowner = 'PrototypeMainArrayMotionOwner' if motion else 'PrototypeMainArrayHealthOwner'
        array = 'coordinates' if motion else 'levels'
        scalars = 'frame' if motion else 'reserve,class'
        expanded = array + ',' + scalars
        newtype = ('type PrototypeMainArrayMotionOwner is Type:\n'
                   '  PrototypeMainArrayMotionOwner{coordinates:Array<U32>,frame:U32,main_cached:T.PositionView,ledger_raw:T.MotionLedger,ledger_cached:T.LedgerView,handle:S.Handle<T.MotionSchema>,undo:X.PrototypeFlatInverse<T.MotionSchema>,marks:X.PrototypeFlatMark<T.MotionSchema>}\n' if motion else
                   'type PrototypeMainArrayHealthOwner is Type:\n'
                   '  PrototypeMainArrayHealthOwner{levels:Array<U32>,reserve:U32,class:U32,main_cached:T.VitalsView,totals:Array<U32>,epoch:U32,ledger_cached:T.LedgerView,handle:S.Handle<T.HealthSchema>,undo:X.PrototypeFlatInverse<T.HealthSchema>,marks:X.PrototypeFlatMark<T.HealthSchema>}\n')
        clones.append(newtype)
        ledgerdone = 'setledger_fused_done' if motion else 'setledger_done'
        names = ['get', 'ledger', 'set_fused_done', 'set', ledgerdone, 'setledger', 'invoke']
        for name in names:
            body = definition(original, prefix + name)
            body = body.replace(owner, newowner).replace(ctor + '{', newowner + '{')
            for n in names:
                body = body.replace(prefix + n + '(', newprefix + n + '(')
                body = body.replace(prefix + n + ',', newprefix + n + ',')
            if name == 'get':
                raw = 'raw' if motion else 'main_raw'
                body = body.replace(newowner + '{' + raw + ',', newowner + '{' + expanded + ',')
            elif name == 'ledger':
                body = body.replace(newowner + '{main_raw,', newowner + '{' + expanded + ',')
            elif name == 'set_fused_done':
                nominal = 'T.Position' if motion else 'T.Vitals'
                scalarparams = 'frame:U32,' if motion else 'reserve:U32,class:U32,'
                body = once(body, 'def ' + newprefix + name + '(', 'def ' + newprefix + name + '(' + scalarparams)
                body = once(body, 'value:U32,result:' + nominal + ' & U32', '+value:U32,result:Array<U32> & U32')
                body = once(body, 'Tuple{raw,old}', 'Tuple{' + array + ',old}')
                body = once(body, newowner + '{raw,P.', newowner + '{Array.set(U32,' + array + ',0,value),' + scalars + ',P.')
            elif name == 'set':
                body = once(body, newowner + '{raw,cached,', newowner + '{' + expanded + ',cached,')
                rawswap = 'P.prototype_position_raw_swap(raw,value)' if motion else 'P.prototype_vitals_raw_swap(raw,value)'
                body = once(body, rawswap, 'Array.get(U32,' + array + ',0)')
                # Declaration is distinct from the one runtime done call.
                body = once(body, newprefix + 'set_fused_done(', newprefix + 'set_fused_done(' + scalars + ',')
            elif name == ledgerdone:
                nominal = 'T.Position' if motion else 'T.Vitals'
                scalarparams = 'frame:U32,' if motion else 'reserve:U32,class:U32,'
                body = once(body, 'main_raw:' + nominal + ',', array + ':Array<U32>,' + scalarparams)
                body = once(body, newowner + '{main_raw,', newowner + '{' + expanded + ',')
            elif name == 'setledger':
                body = once(body, newowner + '{main_raw,', newowner + '{' + expanded + ',')
                body = once(body, newprefix + ledgerdone + '(main_raw,', newprefix + ledgerdone + '(' + expanded + ',')
            clones.append(body.rstrip() + '\n')
        oldreturn = ('prototype_flatfold_motion_returned' if motion else 'prototype_journalledger_health_returned')
        returned = definition(original, oldreturn)
        returned = returned.replace(owner, newowner).replace(ctor + '{', newowner + '{')
        returned = once(returned, 'def ' + oldreturn + '(', 'def ' + newprefix + 'returned(')
        returned = once(returned, newowner + '{main_raw,', newowner + '{' + expanded + ',')
        nominal = 'T.Position' if motion else 'T.Vitals'
        returned = once(returned, 'Some{CC.Cache{main_raw,main_cached}}', 'Some{CC.Cache{' + nominal + '{' + expanded + '},main_cached}}')
        clones.append(returned.rstrip() + '\n')
        oldtaken = 'prototype_flatfold_motion_taken' if motion else 'prototype_journalledger_health_taken'
        taken = definition(original, oldtaken)
        success = ('case (columns,Some{CC.Cache{main_raw,main_cached}}) CC.Cache{ledger_raw,ledger_cached}: ' if motion else
                   'case (columns,Some{CC.Cache{main_raw,main_cached}}) PrototypeJournalLedger{totals,epoch,ledger_cached}: ')
        newsuccess = success.replace('CC.Cache{main_raw,main_cached}', 'CC.Cache{' + nominal + '{' + expanded + '},main_cached}')
        changed = once(taken, success, newsuccess)
        changed = once(changed, oldreturn + '(' + prefix + 'invoke(~client,' + ctor + '{main_raw,',
                       newprefix + 'returned(' + newprefix + 'invoke(~client,' + newowner + '{' + expanded + ',')
        source = once(source, taken, changed)
    source += '\n# Private full-shape affine Main Array transport diagnostic.\n' + '\n'.join(clones)
    assert all(line in source.splitlines() for line in original.splitlines() if line.startswith(('def ', 'type ')))
    shutil.copytree(root, output)
    (output / MODULE).write_text(source)
    newpins = {str(p.relative_to(output)): sha(p) for p in output.rglob('*.bend')}
    assert [k for k in pins if pins[k] != newpins[k]] == [MODULE]
    cache['runtimeClosure'] = newpins
    cache['specializedClosure'] = newpins.copy()
    cache['runtimeClosureSHA256'] = closure(newpins)
    overlay['sources'] = newpins
    overlay['cacheSpecialization'] = cache
    receipt = {'status': 'UNVERIFIED_SOURCE_HYPOTHESIS', 'inputPins': pins, 'outputPins': newpins,
               'changedModules': [MODULE], 'recipeSHA256': sha(pathlib.Path(__file__)),
               'prediction': 'Main nominal construction relocates write-to-return (net0 single-write); one payload Tuple/write removed; owner widens1/2 fields',
               'performanceAcceptance': False, 'productionAdoption': False}
    for name, data in [('overlay.json', overlay), ('cache-specialization.json', cache), ('main-array-transport.json', receipt)]:
        (output / name).write_text(json.dumps(data, indent=2) + '\n')
    return output

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=pathlib.Path, required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    print(materialize(args.input, args.output))
