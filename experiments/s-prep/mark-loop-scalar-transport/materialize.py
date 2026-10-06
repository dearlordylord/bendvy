#!/usr/bin/env python3
import argparse,hashlib,json,pathlib,shutil,re
p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args()
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
manifest=json.loads((a.input/'overlay.json').read_text());assert len(manifest['sources'])==29 and all(h(a.input/n)==v for n,v in manifest['sources'].items());shutil.copytree(a.input,a.output)
file=a.output/'experiments/s-integrate/transaction.bend';old=file.read_text();start=old.index('def prototype_storage_mark_loop(');end=old.index('def storage_mark_all(',start);block=old[start:end];header=block.split('\n')[0];needle='transport: Array<Bool> & Array<U32>';assert header.count(needle)==1;header=header.replace(needle,'live: Array<Bool>,changed: Array<U32>')
args='Schema,M,A,F,L,Mode,rest,namespace,next,main,aux,flags,added,'
tail=',capacity,depth,high,pending,ledger,mode,tick)'
recurse=lambda changed:'prototype_storage_mark_loop('+args+'live,'+changed+tail
generic='-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,'
fields=header[header.index('marks:'):header.index(') ->')]
call='Schema,M,A,F,L,Mode,rest,namespace,next,main,aux,flags,added,'
tail=',capacity,depth,high,pending,ledger,mode,tick)'
rec=lambda change:'prototype_storage_mark_loop('+call+'live,'+change+tail
helper_header=lambda name,extra:'def '+name+'('+generic+extra+fields+') -> S.World<Schema,M,A,F,L,Mode>:'
# Dedicated computed-scrutinee observers; no continuation closures or transported pair.
live_header=helper_header('prototype_storage_mark_scalar_live','+id: U32,')
live_header=live_header.replace('live: Array<Bool>,changed: Array<U32>','changed: Array<U32>,result: Array<Bool> & Bool')
live_body=live_header+'\n  match result:\n    case Tuple{live,False{}}: '+rec('changed')+'\n    case Tuple{live,True{}}: '+rec('Array.set(U32,changed,U32.sub(id,1),tick)')+'\n'
# Helpers name their retained remaining marks `rest`, matching the direct recursion arguments.
live_body=live_body.replace('marks: List','rest: List')
guard_header=helper_header('prototype_storage_mark_scalar_guard','valid: Bool,+id: U32,').replace('marks: List','rest: List')
guard_call='prototype_storage_mark_scalar_live(Schema,M,A,F,L,Mode,id,rest,namespace,next,main,aux,flags,added,changed,Array.get(Bool,live,U32.sub(id,1))'+tail
# tail starts comma and ends right paren; Array.get above is already closed.
guard_body=guard_header+'\n  match valid:\n    case False{}: '+rec('changed')+'\n    case True{}: '+guard_call+'\n'
valid='Bool.and(U32.is_eq(namespace,foreign),Bool.and((0 < id : U32),Bool.and((id <= capacity : U32),(id <= high : U32))))'
loop_call='prototype_storage_mark_scalar_guard(Schema,M,A,F,L,Mode,'+valid+',id,rest,namespace,next,main,aux,flags,added,live,changed'+tail
new=live_body+guard_body+header+'\n  match marks:\n    case Nil{}: S.World{namespace,next,S.Rows{main,aux,S.MetadataColumns{live,flags,added,changed},capacity,depth,high},pending,ledger,mode}\n    case Con{S.Handle{foreign,+id},rest}: '+loop_call+'\n'
changed=old[:start]+new+old[end:];before='marks,namespace,next,main,aux,flags,added,(live,changed),capacity';after='marks,namespace,next,main,aux,flags,added,live,changed,capacity';assert changed.count(before)==1;changed=changed.replace(before,after,1);file.write_text(changed)
# No unrelated definition/body changes: only private loop and its single public entry call.
assert changed[:start]==old[:start];assert 'prototype_storage_mark_guard(' not in new
names={str(f.relative_to(a.output)):h(f) for f in a.output.rglob('*.bend')};assert len(names)==29;assert [n for n in names if names[n]!=manifest['sources'][n]]==['experiments/s-integrate/transaction.bend']
manifest['sources']=names;manifest['overrides']['experiments/s-integrate/transaction.bend']='mark-loop-scalar-transport'
cache=json.loads((a.output/'cache-specialization.json').read_text());cache['runtimeClosure']=names;cache['specializedClosure']=names;manifest['cacheSpecialization']=cache;(a.output/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n');(a.output/'overlay.json').write_text(json.dumps(manifest,indent=2)+'\n')
(a.output/'scalar-mark-transport.json').write_text(json.dumps({'baselineManifestSHA256':h(a.input/'overlay.json'),'baselineSourcePins':json.loads((a.input/'overlay.json').read_text())['sources'],'sourcePins':names,'changedModule':'transaction.bend','unchangedPublicHeaders':True,'actualMarkMutationAnchor':'case Tuple{live,True{}}: direct recursive call with Array.set(U32,changed,U32.sub(id,1),tick)','retainedOldGuardHelpersUnused':True},indent=2)+'\n')
