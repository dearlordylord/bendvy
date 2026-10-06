#!/usr/bin/env python3
"""Pinned private frozen continuation, independently opaque context arguments."""
import argparse,pathlib,hashlib,json,shutil,re
HERE=pathlib.Path(__file__).resolve().parent
EXPECTED='409d87045a832f021c7d7a1aa880ebfd16ff8d2b9eb5035883d96f781a49daad'
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
closure=lambda p:hashlib.sha256(json.dumps(p,sort_keys=True,separators=(',',':')).encode()).hexdigest()
OLD='@-P: Type -> @-U: Type -> @-get: (P -> Tok -> P & V) -> @-ag: (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O)'
CTX=' -> '.join('@-C'+str(i)+(': Data' if i==0 else ': Type') for i in range(8))
CTX_ARGS=' -> '.join('C'+str(i) for i in range(8))
DONE_ARGS='@+_:C0 -> '+' -> '.join('C'+str(i) for i in range(1,8))
NEW='@-P: Type -> @-U: Type -> @-get: (P -> Tok -> P & V) -> @-ag: (U -> U & Maybe<&2,AV>) -> '+CTX+' -> @-Out: Type -> @-done: ('+DONE_ARGS+' -> P -> U -> O -> Out) -> '+CTX_ARGS+' -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> Out'
NAMES=['struct_idx_aux','struct_idx_main','struct_idx_selected','struct_idx_metadata','struct_cols_live','struct_idx_advance','struct_idx_go','read_rows','each']
def materialize(source,output):
 source=source.resolve(strict=True);output=output.absolute();assert not output.exists() and output.is_relative_to(HERE)
 overlay=json.load(open(source/'overlay.json'));cache=json.load(open(source/'cache-specialization.json'));pins={str(p.relative_to(source)):sha(p) for p in source.rglob('*.bend')};assert pins==overlay['sources']==cache['runtimeClosure']==cache['specializedClosure'];assert cache==overlay['cacheSpecialization'];assert len(pins)==29 and closure(pins)==EXPECTED;shutil.copytree(source,output)
 q=output/'experiments/s-integrate/query.bend';old=q.read_text();defs={m.group(1):m.group(0) for m in re.finditer(r'^def ([a-zA-Z_][\w]*)\([^\n]*(?:\n(?!def |type |#)[^\n]*)*',old,re.M)}
 support='''\ndef prototype_cont_done(~M:Type,~A:Type,~F:Data,~O:Data,+index:U32,main:Array<Maybe<M>>,aux:Array<Maybe<A>>,live:Array<Bool>,flags:Array<Maybe<&2,F>>,added:Array<U32>,changed:Array<U32>,values:List<&2,O>,owner:M,aux_owner:Maybe<A>,value:O) -> StructColsState<M,A,F,O>:
  StructColsState{Array.set(Maybe<M>,main,index,Some{owner}),Array.set(Maybe<A>,aux,index,aux_owner),live,flags,added,changed,value <> values}
'''
 copies=[]
 for name in NAMES:
  text=defs[name];assert OLD in text;new=text.replace(OLD,NEW)
  if name=='struct_idx_aux':
   before='case (aux,a): struct_idx_return(M,A,F,O,U32.sub(id,1),main,aux,live,flags,added,changed,values,client(M,Maybe<A>,main_read(~M,~Tok,~V,~main_get),aux_read(~A,~AV,~aux_get),S.Handle{namespace,id},flag,owner,a))'
   after='case (aux,a): client(M,Maybe<A>,main_read(~M,~Tok,~V,~main_get),aux_read(~A,~AV,~aux_get),U32,Array<Maybe<M>>,Array<Maybe<A>>,Array<Bool>,Array<Maybe<&2,F>>,Array<U32>,Array<U32>,List<&2,O>,StructColsState<M,A,F,O>,prototype_cont_done(~M,~A,~F,~O),U32.sub(id,1),main,aux,live,flags,added,changed,values,S.Handle{namespace,id},flag,owner,a)'
   assert new.count(before)==1;new=new.replace(before,after)
  for n in sorted(NAMES,key=len,reverse=True):new=re.sub(r'\b'+n+r'\b','prototype_cont_'+n,new)
  copies.append(new.rstrip())
 q.write_text(old+support+'\n'+'\n\n'.join(copies)+'\n')
 m=output/'experiments/s-integrate/measurement-bend.bend';oldm=m.read_text();types=','.join('~C'+str(i)+(':Data' if i==0 else ':Type') for i in range(8));params=','.join('c'+str(i)+':C'+str(i) for i in range(8));forward=','.join('c'+str(i) for i in range(8))
 newdef='def prototype_cont_handle_client(~Schema:Data,~F:Data,~Owner:Type,~Aux:Type,~get:Owner -> Unit -> Owner & Unit,~ag:Aux -> Aux & Maybe<&2,Unit>,'+types+',~Out:Type,~done:'+DONE_ARGS+' -> Owner -> Aux -> S.Handle<Schema> -> Out,'+params+',handle:S.Handle<Schema>,flag:Maybe<&2,F>,owner:Owner,aux:Aux) -> Out:\n  done('+forward+',owner,aux,handle)\n'
 marker='def first(value:T.Four)';assert oldm.count(marker)==1;newm=oldm.replace(marker,newdef+marker);assert newm.count('  Q.each(')==4;newm='\n'.join(line.replace('Q.each(','Q.prototype_cont_each(') if 'Q.each(' in line and 'handle_client(' in line else line for line in newm.split('\n')).replace('handle_client(~T.MotionSchema,~T.Selected)','prototype_cont_handle_client(~T.MotionSchema,~T.Selected)').replace('handle_client(~T.HealthSchema,~T.Tracked)','prototype_cont_handle_client(~T.HealthSchema,~T.Tracked)');m.write_text(newm)
 newpins={str(p.relative_to(output)):sha(p) for p in output.rglob('*.bend')};changed=sorted(n for n in pins if pins[n]!=newpins[n]);assert changed==['experiments/s-integrate/measurement-bend.bend','experiments/s-integrate/query.bend'];cache.update(runtimeClosure=newpins,specializedClosure=newpins.copy(),runtimeClosureSHA256=closure(newpins));overlay.update(sources=newpins,cacheSpecialization=cache)
 receipt={'status':'UNVERIFIED_SEPARATE_SOURCE_CONTINUATION','inputSources':pins,'sources':newpins,'inputClosureSHA256':closure(pins),'outputClosureSHA256':closure(newpins),'changedModules':changed,'contextRecordConstructors':0,'publicHeadersAndOriginalCallbackAlgorithmsUnchanged':True,'performanceAcceptance':False,'proofAcceptance':False}
 for n,v in [('overlay.json',overlay),('cache-specialization.json',cache),('source-query-owner-fusion.json',receipt)]:(output/n).write_text(json.dumps(v,indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();materialize(a.input,a.output)
