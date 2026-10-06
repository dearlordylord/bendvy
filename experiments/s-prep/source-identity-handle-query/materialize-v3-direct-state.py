#!/usr/bin/env python3
"""Pinned source-only identity handle query probe; originals and fallbacks retained."""
import argparse, hashlib, json, pathlib, re, shutil

HERE = pathlib.Path(__file__).resolve().parent
MODULE = 'experiments/s-integrate/query.bend'
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
    assert cache.get('specializedClosureSHA256', closure(pins)) == closure(pins)
    original = (root / MODULE).read_text()
    assert 'prototype_identity_' not in original
    helpers = """def prototype_identity_restore_state(-Schema:Data,-M:Type,-A:Type,-F:Data,+id:U32,+namespace:U32,aux:Array<Maybe<A>>,live:Array<Bool>,flags:Array<Maybe<&2,F>>,added:Array<U32>,changed:Array<U32>,values:List<&2,S.Handle<Schema>>,result:Array<Maybe<M>> & Maybe<M>) -> StructColsState<M,A,F,S.Handle<Schema>>:
  match result:
    case Tuple{main,None{}}: StructColsState{main,aux,live,flags,added,changed,values}
    case Tuple{main,Some{owner}}: StructColsState{Array.set(Maybe<M>,main,U32.sub(id,1),Some{owner}),aux,live,flags,added,changed,S.Handle{namespace,id} <> values}
def prototype_identity_inspect_state(-Schema:Data,-M:Type,-A:Type,-F:Data,+id:U32,+namespace:U32,main:Array<Maybe<M>>,aux:Array<Maybe<A>>,live:Array<Bool>,flags:Array<Maybe<&2,F>>,added:Array<U32>,changed:Array<U32>,values:List<&2,S.Handle<Schema>>) -> StructColsState<M,A,F,S.Handle<Schema>>:
  prototype_identity_restore_state(Schema,M,A,F,id,namespace,aux,live,flags,added,changed,values,Array.swap(Maybe<M>,main,U32.sub(id,1),None{}))
"""
    full = '~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client'
    clones = []
    for suffix in ['struct_idx_selected','struct_idx_metadata','struct_cols_live','struct_idx_advance','struct_idx_go','read_rows','each']:
        text = definition(original,'prototype_noaux_' + suffix)
        header,body = text.split('\n',1)
        runtime = re.search(r',(?=\+?(?:id|remaining|selection|rows|include|valid):)',header)
        assert runtime, suffix
        end = header.index('~Tok:')
        header = header[:end] + header[runtime.start()+1:]
        text = header + '\n' + body
        text = text.replace(full,'~Schema,~M,~A,~F')
        text = text.replace('~Schema,~M,~A,~F,~L,~Mode,~main_get,~aux_get,~client','~Schema,~M,~A,~F,~L,~Mode')
        # The each header's L/Mode were between the removed templates and client.
        if suffix == 'each':
            text = text.replace('~F: Data,selection:', '~F: Data,~L:Type,~Mode:Data,selection:')
        text = text.replace('prototype_noaux_','prototype_identity_')
        text = re.sub(r'\bO\b','S.Handle<Schema>',text)
        if suffix == 'struct_idx_selected':
            before = 'prototype_identity_struct_idx_main(~Schema,~M,~A,~F,id,namespace,aux,live,flags,added,changed,values,flag,Array.swap(Maybe<M>,main,U32.sub(id,1),None{}))'
            after = 'prototype_identity_inspect_state(Schema,M,A,F,id,namespace,main,aux,live,flags,added,changed,values)'
            text = once(text,before,after)
        clones.append(text)
    source = original + '\n' + helpers + '\n' + ''.join(clones)
    shutil.copytree(root,output)
    (output / MODULE).write_text(source)
    measurement = output / 'experiments/s-integrate/measurement-bend.bend'
    old = measurement.read_text()
    new = old
    for schema,main,aux,flag,ledger,mode in [('Motion','Position','Velocity','Selected','MotionLedger','MotionMode'),('Health','Vitals','Armor','Tracked','HealthLedger','HealthMode')]:
        before = f'Q.prototype_noaux_each(T.{schema}Schema,CC.Cache<T.{main},T.{main}View>,T.{aux},T.{flag},Unit,Unit,Unit,S.Handle<T.{schema}Schema>,CC.Cache<T.{ledger},T.LedgerView>,T.{mode},keep(~CC.Cache<T.{main},T.{main}View>),keep(~T.{aux}),prototype_cont_handle_client(~T.{schema}Schema,~T.{flag}),Q.Required{{}},world)'
        after = f'Q.prototype_identity_each(T.{schema}Schema,CC.Cache<T.{main},T.{main}View>,T.{aux},T.{flag},CC.Cache<T.{ledger},T.LedgerView>,T.{mode},Q.Required{{}},world)'
        new = once(new,before,after)
    measurement.write_text(new)
    pins2 = {str(p.relative_to(output)): sha(p) for p in output.rglob('*.bend')}
    assert set(pins2) == set(pins)
    cache['runtimeClosure'] = cache['specializedClosure'] = pins2
    cache['runtimeClosureSHA256'] = cache['specializedClosureSHA256'] = closure(pins2)
    overlay['sources'] = pins2
    overlay['cacheSpecialization'] = cache
    (output/'overlay.json').write_text(json.dumps(overlay,indent=2)+'\n')
    (output/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n')
    (output/'identity-query.json').write_text(json.dumps({'status':'UNVERIFIED_SOURCE_HYPOTHESIS','source29Pins':pins2,'changedModules':[MODULE,'experiments/s-integrate/measurement-bend.bend']},indent=2)+'\n')
    print(json.dumps({'output':str(output),'sourceClosureSHA256':closure(pins2)}))

if __name__ == '__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--input',type=pathlib.Path,required=True);parser.add_argument('--output',type=pathlib.Path,required=True)
    args=parser.parse_args();materialize(args.input,args.output)
