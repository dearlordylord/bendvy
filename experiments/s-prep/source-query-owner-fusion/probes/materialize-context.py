#!/usr/bin/env python3
"""Exact source-only frozen continuation query/owner transport probe."""
import argparse,pathlib,json,hashlib,shutil,re
HERE=pathlib.Path(__file__).resolve().parent
EXPECTED='409d87045a832f021c7d7a1aa880ebfd16ff8d2b9eb5035883d96f781a49daad'
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
closure=lambda pins:hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
OLD='@-P: Type -> @-U: Type -> @-get: (P -> Tok -> P & V) -> @-ag: (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O)'
NEW='@-P: Type -> @-U: Type -> @-Ctx: Type -> @-Out: Type -> @-get: (P -> Tok -> P & V) -> @-ag: (U -> U & Maybe<&2,AV>) -> @-done: (Ctx -> P -> U -> O -> Out) -> Ctx -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> Out'
NAMES=['struct_idx_aux','struct_idx_main','struct_idx_selected','struct_idx_metadata','struct_cols_live','struct_idx_advance','struct_idx_go','read_rows','each']
def materialize(source,output):
 source=source.resolve(strict=True);output=output.absolute();assert not output.exists();assert output.is_relative_to(HERE),'Owned overlay must remain beneath experiment folder'
 overlay=json.load(open(source/'overlay.json'));cache=json.load(open(source/'cache-specialization.json'));pins={str(p.relative_to(source)):sha(p) for p in source.rglob('*.bend')};assert pins==overlay['sources']==cache['runtimeClosure']==cache['specializedClosure'];assert cache==overlay['cacheSpecialization'];assert len(pins)==29 and closure(pins)==EXPECTED;shutil.copytree(source,output)
 q=output/'experiments/s-integrate/query.bend';old=q.read_text();defs={m.group(1):m.group(0) for m in re.finditer(r'^def ([a-zA-Z_][\w]*)\([^\n]*(?:\n(?!def |type |#)[^\n]*)*',old,re.M)};assert all(n in defs for n in NAMES)
 support='''\n# Affine opaque transport context, visible only to the trusted query adapter.\ntype PrototypeOwnerReturnCtx<-M: Type,-A: Type,-F: Data,-O: Data> is Type:\n  PrototypeOwnerReturnCtx{index:U32,main:Array<Maybe<M>>,aux:Array<Maybe<A>>,live:Array<Bool>,flags:Array<Maybe<&2,F>>,added:Array<U32>,changed:Array<U32>,values:List<&2,O>}\ndef prototype_owner_return(~M:Type,~A:Type,~F:Data,~O:Data,context:PrototypeOwnerReturnCtx<M,A,F,O>,main:M,aux:Maybe<A>,value:O) -> StructColsState<M,A,F,O>:\n  match context:\n    case PrototypeOwnerReturnCtx{+index,owners,auxes,live,flags,added,changed,values}:\n      StructColsState{Array.set(Maybe<M>,owners,index,Some{main}),Array.set(Maybe<A>,auxes,index,aux),live,flags,added,changed,value <> values}\n'''
 copies=[]
 for name in NAMES:
  text=defs[name];assert OLD in text;new=text.replace(OLD,NEW)
  for n in sorted(NAMES,key=len,reverse=True):new=re.sub(r'\b'+n+r'\b','prototype_owner_'+n,new)
  if name=='struct_idx_aux':
   before='struct_idx_return(M,A,F,O,U32.sub(id,1),main,aux,live,flags,added,changed,values,client(M,Maybe<A>,main_read(~M,~Tok,~V,~main_get),aux_read(~A,~AV,~aux_get),S.Handle{namespace,id},flag,owner,a))'
   after='client(M,Maybe<A>,PrototypeOwnerReturnCtx<M,A,F,O>,StructColsState<M,A,F,O>,main_read(~M,~Tok,~V,~main_get),aux_read(~A,~AV,~aux_get),prototype_owner_return(~M,~A,~F,~O),PrototypeOwnerReturnCtx{U32.sub(id,1),main,aux,live,flags,added,changed,values},S.Handle{namespace,id},flag,owner,a)'
   assert before in new;new=new.replace(before,after)
  copies.append(new.rstrip())
 q.write_text(old+support+'\n'+'\n\n'.join(copies)+'\n')
 m=output/'experiments/s-integrate/measurement-bend.bend';oldm=m.read_text();newdef='''def prototype_owner_handle_client(~Schema:Data,~F:Data,~Owner:Type,~Aux:Type,~Ctx:Type,~Out:Type,~get:Owner -> Unit -> Owner & Unit,~ag:Aux -> Aux & Maybe<&2,Unit>,~done:Ctx -> Owner -> Aux -> S.Handle<Schema> -> Out,context:Ctx,handle:S.Handle<Schema>,flag:Maybe<&2,F>,owner:Owner,aux:Aux) -> Out:\n  done(context,owner,aux,handle)\n''';marker='def first(value:T.Four)';assert oldm.count(marker)==1;newm=oldm.replace(marker,newdef+marker);assert newm.count('  Q.each(')==4;newm='\n'.join(line.replace('Q.each(','Q.prototype_owner_each(') if 'Q.each(' in line and 'handle_client(' in line else line for line in newm.split('\n')).replace('handle_client(~T.MotionSchema,~T.Selected)','prototype_owner_handle_client(~T.MotionSchema,~T.Selected)').replace('handle_client(~T.HealthSchema,~T.Tracked)','prototype_owner_handle_client(~T.HealthSchema,~T.Tracked)');m.write_text(newm)
 newpins={str(p.relative_to(output)):sha(p) for p in output.rglob('*.bend')};changed=sorted(n for n in pins if pins[n]!=newpins[n]);assert changed==['experiments/s-integrate/measurement-bend.bend','experiments/s-integrate/query.bend'];cache.update(runtimeClosure=newpins,specializedClosure=newpins.copy(),runtimeClosureSHA256=closure(newpins));overlay.update(sources=newpins,cacheSpecialization=cache)
 receipt={'status':'SOURCE_CANDIDATE_UNVERIFIED','inputSources':pins,'sources':newpins,'inputClosureSHA256':closure(pins),'outputClosureSHA256':closure(newpins),'changedModules':changed,'originalQueryDefinitionsUnchanged':True,'originalHandleClientUnchanged':True,'originalHeldCallbackAlgorithmsUnchanged':True,'newPrivateClientContract':'opaque affine Ctx, Result, frozen done; generic affine Main/Aux and general getters retained','performanceAcceptance':False,'proofAcceptance':False}
 for n,v in [('overlay.json',overlay),('cache-specialization.json',cache),('source-query-owner-fusion.json',receipt)]:(output/n).write_text(json.dumps(v,indent=2)+'\n')
 return output
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();print(materialize(a.input,a.output))
