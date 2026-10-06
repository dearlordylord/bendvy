#!/usr/bin/env python3
"""Exact source-only flat nominal query/owner transport probe."""
import argparse,pathlib,json,hashlib,shutil,re
HERE=pathlib.Path(__file__).resolve().parent
EXPECTED='409d87045a832f021c7d7a1aa880ebfd16ff8d2b9eb5035883d96f781a49daad'
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
closure=lambda pins:hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
OLD='@-P: Type -> @-U: Type -> @-get: (P -> Tok -> P & V) -> @-ag: (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O)'
NEW='@-P: Type -> @-U: Type -> @-get: (P -> Tok -> P & V) -> @-ag: (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> PrototypeOwnerResult<P,U,O>'
NAMES=['struct_idx_return','struct_idx_aux','struct_idx_main','struct_idx_selected','struct_idx_metadata','struct_cols_live','struct_idx_advance','struct_idx_go','read_rows','each']
def materialize(source,output):
 source=source.resolve(strict=True);output=output.absolute();assert not output.exists();assert output.is_relative_to(HERE),'Owned overlay must remain beneath experiment folder'
 overlay=json.load(open(source/'overlay.json'));cache=json.load(open(source/'cache-specialization.json'));pins={str(p.relative_to(source)):sha(p) for p in source.rglob('*.bend')};assert pins==overlay['sources']==cache['runtimeClosure']==cache['specializedClosure'];assert cache==overlay['cacheSpecialization'];assert len(pins)==29 and closure(pins)==EXPECTED;shutil.copytree(source,output)
 q=output/'experiments/s-integrate/query.bend';old=q.read_text();defs={m.group(1):m.group(0) for m in re.finditer(r'^def ([a-zA-Z_][\w]*)\([^\n]*(?:\n(?!def |type |#)[^\n]*)*',old,re.M)};assert all(n in defs for n in NAMES)
 support='''\n# Flat owner return preserves opaque affine Main/Aux and complete Data observation.\ntype PrototypeOwnerResult<-P:Type,-U:Type,-O:Data> is Type:\n  PrototypeOwnerResult{main:P,aux:U,observation:O}\n'''
 copies=[]
 for name in NAMES:
  text=defs[name]
  if name=='struct_idx_return':
   assert 'result: M & (Maybe<A> & O)' in text and 'case (m,(a,value)):' in text
   new=text.replace('result: M & (Maybe<A> & O)','result: PrototypeOwnerResult<M,Maybe<A>,O>').replace('case (m,(a,value)):','case PrototypeOwnerResult{m,a,value}:')
  else:
   assert OLD in text;new=text.replace(OLD,NEW)
  for n in sorted(NAMES,key=len,reverse=True):new=re.sub(r'\b'+n+r'\b','prototype_owner_'+n,new)
  copies.append(new.rstrip())
 q.write_text(old+support+'\n'+'\n\n'.join(copies)+'\n')
 m=output/'experiments/s-integrate/measurement-bend.bend';oldm=m.read_text();newdef='''def prototype_owner_handle_client(~Schema:Data,~F:Data,~Owner:Type,~Aux:Type,~get:Owner -> Unit -> Owner & Unit,~ag:Aux -> Aux & Maybe<&2,Unit>,handle:S.Handle<Schema>,flag:Maybe<&2,F>,owner:Owner,aux:Aux) -> Q.PrototypeOwnerResult<Owner,Aux,S.Handle<Schema>>:\n  Q.PrototypeOwnerResult{owner,aux,handle}\n''';marker='def first(value:T.Four)';assert oldm.count(marker)==1;newm=oldm.replace(marker,newdef+marker);assert newm.count('  Q.each(')==4;newm='\n'.join(line.replace('Q.each(','Q.prototype_owner_each(') if 'Q.each(' in line and 'handle_client(' in line else line for line in newm.split('\n')).replace('handle_client(~T.MotionSchema,~T.Selected)','prototype_owner_handle_client(~T.MotionSchema,~T.Selected)').replace('handle_client(~T.HealthSchema,~T.Tracked)','prototype_owner_handle_client(~T.HealthSchema,~T.Tracked)');m.write_text(newm)
 newpins={str(p.relative_to(output)):sha(p) for p in output.rglob('*.bend')};changed=sorted(n for n in pins if pins[n]!=newpins[n]);assert changed==['experiments/s-integrate/measurement-bend.bend','experiments/s-integrate/query.bend'];cache.update(runtimeClosure=newpins,specializedClosure=newpins.copy(),runtimeClosureSHA256=closure(newpins));overlay.update(sources=newpins,cacheSpecialization=cache)
 receipt={'status':'SOURCE_CANDIDATE_UNVERIFIED','inputSources':pins,'sources':newpins,'inputClosureSHA256':closure(pins),'outputClosureSHA256':closure(newpins),'changedModules':changed,'originalQueryDefinitionsUnchanged':True,'originalHandleClientUnchanged':True,'originalHeldCallbackAlgorithmsUnchanged':True,'newPrivateClientContract':'flat nominal owner result; generic opaque affine Main/Aux and general getters retained','performanceAcceptance':False,'proofAcceptance':False}
 for n,v in [('overlay.json',overlay),('cache-specialization.json',cache),('source-query-owner-fusion.json',receipt)]:(output/n).write_text(json.dumps(v,indent=2)+'\n')
 return output
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();print(materialize(a.input,a.output))
