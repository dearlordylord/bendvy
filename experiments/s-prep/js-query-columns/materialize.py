#!/usr/bin/env python3
"""Keep affine metadata fields in indexed query loop; rebuild at final boundary."""
import argparse,hashlib,json,re,shutil
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();manifest=json.loads((a.input/'overlay.json').read_text());assert len(manifest['sources'])==29;assert all(sha(a.input/n)==h for n,h in manifest['sources'].items());input_cache=json.loads((a.input/'cache-specialization.json').read_text());assert manifest['cacheSpecialization']==input_cache;assert input_cache['runtimeClosure']==manifest['sources'];assert input_cache['specializedClosure']==manifest['sources'];assert input_cache['runtimeClosureSHA256']==hashlib.sha256(json.dumps(dict(sorted(manifest['sources'].items())),separators=(',',':')).encode()).hexdigest();assert not a.output.exists();shutil.copytree(a.input,a.output)
f=a.output/'experiments/s-integrate/query.bend';source=f.read_text();start=source.index('type StructIdxState<');end=source.index('\ndef each_return(',start);block=source[start:end];old=block
state='''type StructColsState<-M: Type,-A: Type,-F: Data,-O: Data> is Type:
  StructColsState{main: Array<Maybe<M>>,aux: Array<Maybe<A>>,live: Array<Bool>,flags: Array<Maybe<&2,F>>,added: Array<U32>,changed: Array<U32>,values: List<&2,O>}
'''
# Keep original finish constructor and order anchor as a live boundary adapter.
finishStart=block.index('def struct_idx_finish(');finishEnd=block.index('\ndef struct_idx_go(',finishStart);finish=block[finishStart:finishEnd]
block=block[:finishStart]+block[finishEnd:]
block=block.replace('StructIdxState','StructColsState')
# Restore old state declaration; new internal state is private to this traversal.
declEnd=block.index('def struct_idx_return(');block=old[:old.index('def struct_idx_return(')]+state+block[declEnd:]
block=block.replace('metadata: S.MetadataColumns<F>','live: Array<Bool>,flags: Array<Maybe<&2,F>>,added: Array<U32>,changed: Array<U32>')
block=block.replace('main,aux,metadata,','main,aux,live,flags,added,changed,').replace('main,owner,metadata,','main,owner,live,flags,added,changed,').replace('aux,metadata,','aux,live,flags,added,changed,')
block=block.replace('Array.set(Maybe<A>,aux,index,a),metadata,value','Array.set(Maybe<A>,aux,index,a),live,flags,added,changed,value')
# Replace the membership wrapper consumption with direct affine array results.
mstart=block.index('def struct_idx_metadata(');mend=block.index('\ndef struct_idx_advance(',mstart);oldMeta=block[mstart:mend];header=oldMeta.split('\n',1)[0];header=header.replace('result: S.MetadataColumns<F> & S.Membership<F>','live: Array<Bool>,added: Array<U32>,changed: Array<U32>,value: Bool,result: Array<Maybe<&2,F>> & Maybe<&2,F>')
call='~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client'
body=f'''\n  match value result:
    case False{{}} Tuple{{flags,_}}: StructColsState{{main,aux,live,flags,added,changed,values}}
    case True{{}} Tuple{{flags,+flag}}: struct_idx_selected({call},selected(F,selection,flag),id,namespace,main,aux,live,flags,added,changed,values,flag)
'''
liveHeader=header.replace('def struct_idx_metadata(','def struct_cols_live(').replace('id: U32','+id: U32').replace('live: Array<Bool>,added: Array<U32>,changed: Array<U32>,value: Bool,result: Array<Maybe<&2,F>> & Maybe<&2,F>','flags: Array<Maybe<&2,F>>,added: Array<U32>,changed: Array<U32>,result: Array<Bool> & Bool')
liveBody=f'''\n  match result:
    case (live,value): struct_idx_metadata({call},id,namespace,selection,main,aux,values,live,added,changed,value,Array.get(Maybe<&2,F>,flags,U32.sub(id,1)))
'''
block=block[:mstart]+header+body+liveHeader+liveBody+block[mend:]
needle=f'struct_idx_metadata({call},id,namespace,selection,main,aux,values,S.metadata_membership(F,metadata,U32.sub(id,1)))';assert block.count(needle)==1;block=block.replace(needle,f'struct_cols_live({call},id,namespace,selection,main,aux,values,flags,added,changed,Array.get(Bool,live,U32.sub(id,1)))')
# Original order-sensitive finish stays reachable through one final repack.
newFinish='''def struct_cols_finish(-M: Type,-A: Type,-F: Data,-O: Data,capacity: U32,depth: Nat,high: U32,state: StructColsState<M,A,F,O>) -> S.Rows<M,A,F> & List<&2,O>:
  match state:
    case StructColsState{main,aux,live,flags,added,changed,values}: struct_idx_finish(M,A,F,O,capacity,depth,high,StructIdxState{main,aux,S.MetadataColumns{live,flags,added,changed},values})
'''
gstart=block.index('def struct_idx_go(');block=block[:gstart]+finish+'\n'+newFinish+block[gstart:];block=block.replace('case 0n: struct_idx_finish(M,A,F,O,capacity,depth,high,state)','case 0n: struct_cols_finish(M,A,F,O,capacity,depth,high,state)')
# Source row destructuring supplies columns directly only at the query boundary.
block=block.replace('case S.Rows{main,aux,live,flags,added,changed,capacity,depth,+high}:','case S.Rows{main,aux,S.MetadataColumns{live,flags,added,changed},capacity,depth,+high}:')
block=old[:old.index('def struct_idx_return(')]+block[block.index('type StructColsState<'):];
assert 'S.metadata_membership(' not in block;assert block.count('List.reverse(&2,O,values)')==1
f.write_text(source[:start]+block+source[end:]);manifest['sources']['experiments/s-integrate/query.bend']=sha(f);manifest['queryColumnFusion']={'recipeSHA256':sha(Path(__file__)),'originalQuerySHA256':hashlib.sha256(source.encode()).hexdigest(),'scope':'Original capacity/live/flag predicates, callback and per-row owner restoration; four affine metadata arrays carried through loop; original live finish/order anchor retained'};(a.output/'overlay.json').write_text(json.dumps(manifest,indent=2)+'\n')
cache=json.loads((a.output/'cache-specialization.json').read_text());cache['runtimeClosure']['experiments/s-integrate/query.bend']=sha(f);cache['specializedClosure']['experiments/s-integrate/query.bend']=sha(f);cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(dict(sorted(cache['runtimeClosure'].items())),separators=(',',':')).encode()).hexdigest();(a.output/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n');manifest['cacheSpecialization']=cache;(a.output/'overlay.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(manifest['queryColumnFusion']))
