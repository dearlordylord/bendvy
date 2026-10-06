#!/usr/bin/env python3
"""Closed-client-only auxiliary column forwarding; no general getter optimization."""
import argparse,pathlib,hashlib,json,shutil,re
HERE=pathlib.Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
closure=lambda p:hashlib.sha256(json.dumps(p,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def materialize(source,output):
 source=source.resolve(strict=True); output=output.absolute(); assert not output.exists() and output.is_relative_to(HERE)
 manifest=json.loads((source/'overlay.json').read_text()); cache=json.loads((source/'cache-specialization.json').read_text()); pins={str(p.relative_to(source)):sha(p) for p in source.rglob('*.bend')}
 assert len(pins)==29 and closure(pins)=='82b42c8126aaab1a9f868a59fed7d9d97bee1f4cd22a1e5ae24ca64c80aab72b'
 assert manifest['sources']==cache['runtimeClosure']==cache['specializedClosure']==pins and manifest['cacheSpecialization']==cache
 shutil.copytree(source,output)
 q=output/'experiments/s-integrate/query.bend'; old=q.read_text(); defs={m.group(1):m.group(0) for m in re.finditer(r'^def ([a-zA-Z_][\w]*)\([^\n]*(?:\n(?!def |type |#)[^\n]*)*',old,re.M)}
 names=['struct_idx_main','struct_idx_selected','struct_idx_metadata','struct_cols_live','struct_idx_advance','struct_idx_go','read_rows','each']
 support='''
def prototype_noaux_read(~A:Type,~AV:Data,owner:Array<Maybe<A>>) -> Array<Maybe<A>> & Maybe<&2,AV>:
  (owner,None{})
def prototype_noaux_done(~M:Type,~A:Type,~F:Data,~O:Data,+index:U32,main:Array<Maybe<M>>,unused:U32,live:Array<Bool>,flags:Array<Maybe<&2,F>>,added:Array<U32>,changed:Array<U32>,values:List<&2,O>,owner:M,aux:Array<Maybe<A>>,value:O) -> StructColsState<M,A,F,O>:
  StructColsState{Array.set(Maybe<M>,main,index,Some{owner}),aux,live,flags,added,changed,value <> values}
'''
 copies=[]
 for name in names:
  text=defs['prototype_cont_'+name]
  if name=='struct_idx_main':
   before='prototype_cont_struct_idx_aux(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,id,namespace,main,owner,live,flags,added,changed,values,flag,Array.swap(Maybe<A>,aux,U32.sub(id,1),None{}))'
   after='client(M,Array<Maybe<A>>,main_read(~M,~Tok,~V,~main_get),prototype_noaux_read(~A,~AV),U32,Array<Maybe<M>>,U32,Array<Bool>,Array<Maybe<&2,F>>,Array<U32>,Array<U32>,List<&2,O>,StructColsState<M,A,F,O>,prototype_noaux_done(~M,~A,~F,~O),U32.sub(id,1),main,0,live,flags,added,changed,values,S.Handle{namespace,id},flag,owner,aux)'
   assert text.count(before)==1; text=text.replace(before,after)
  for n in sorted(names,key=len,reverse=True):text=re.sub(r'\bprototype_cont_'+n+r'\b','prototype_noaux_'+n,text)
  copies.append(text.rstrip())
 q.write_text(old+support+'\n'+'\n\n'.join(copies)+'\n')
 m=output/'experiments/s-integrate/measurement-bend.bend'; oldm=m.read_text(); client=next(x.group(0) for x in re.finditer(r'^def prototype_cont_handle_client\([^\n]*\n[^\n]*',oldm,re.M)); assert client.endswith('  done(c0,c1,c2,c3,c4,c5,c6,c7,owner,aux,handle)')
 assert oldm.count('Q.prototype_cont_each(')==2
 m.write_text(oldm.replace('Q.prototype_cont_each(','Q.prototype_noaux_each('))
 assert client in m.read_text()
 newpins={str(p.relative_to(output)):sha(p) for p in output.rglob('*.bend')};cache.update(runtimeClosure=newpins,specializedClosure=newpins.copy(),runtimeClosureSHA256=closure(newpins)); manifest.update(sources=newpins,cacheSpecialization=cache)
 receipt={'status':'UNVERIFIED_CLOSED_NO_GET_CLIENT_SPECIALIZATION','inputSources':pins,'sources':newpins,'inputClosureSHA256':closure(pins),'outputClosureSHA256':closure(newpins),'closedClientSHA256':hashlib.sha256(client.encode()).hexdigest(),'supportedClient':'measurement.prototype_cont_handle_client exact unchanged body','unsupported':'Any getter-invoking or nonidentity client on this private route','publicGeneralQueryPreserved':True,'performanceAcceptance':False}
 for name,value in [('overlay.json',manifest),('cache-specialization.json',cache),('source-query-owner-fusion.json',receipt)]: (output/name).write_text(json.dumps(value,indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();materialize(a.input,a.output)
