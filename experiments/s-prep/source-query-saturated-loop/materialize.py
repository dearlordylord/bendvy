#!/usr/bin/env python3
"""Pinned source probe: fixed metadata argument and terminal state transport."""
import argparse,pathlib,json,hashlib,re,shutil
HERE=pathlib.Path(__file__).resolve().parent
EXPECTED='49614f72311af5b03123d536ff301115d28b8886bf516b0d7057a8c52e68ad38'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
closure=lambda p:hashlib.sha256(json.dumps(p,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def materialize(source,output):
 source=source.resolve(strict=True);output=output.absolute();assert not output.exists() and output.is_relative_to(HERE)
 pins={str(p.relative_to(source)):sha(p) for p in source.rglob('*.bend')};manifest=json.loads((source/'overlay.json').read_text());cache=json.loads((source/'cache-specialization.json').read_text());assert len(pins)==29 and closure(pins)==EXPECTED and pins==manifest['sources']==cache['runtimeClosure']==cache['specializedClosure'] and cache==manifest['cacheSpecialization']
 shutil.copytree(source,output);q=output/'experiments/s-integrate/query.bend';old=q.read_text();defs={m.group(1):m.group(0) for m in re.finditer(r'^def ([a-zA-Z_][\w]*)\([^\n]*(?:\n(?!def |type |#)[^\n]*)*',old,re.M)}
 finish='''
def prototype_transport_finish(~M:Type,~A:Type,~F:Data,~O:Data,capacity:U32,depth:Nat,high:U32,state:StructColsState<M,A,F,O>) -> S.Rows<M,A,F> & List<&2,O>:
  match state:
    case StructColsState{main,aux,live,flags,added,changed,values}: (S.Rows{main,aux,S.MetadataColumns{live,flags,added,changed},capacity,depth,high},List.reverse(&2,O,values))
'''
 names=['struct_idx_metadata','struct_cols_live','struct_idx_advance','struct_idx_go','read_rows','each'];copies=[];facts={}
 for family,alias in [('prototype_noaux','prototype_transport_noaux'),('prototype_cont','prototype_transport_general')]:
  assert old.count(family+'_struct_idx_metadata(')==2
  blocks=[]
  for name in names:
   block=defs[family+'_'+name]
   if name=='struct_idx_metadata':
    assert block.count(',value: Bool,result:')==1 and block.count('  match value result:')==1
    line='    case False{} Tuple{flags,_}: StructColsState{main,aux,live,flags,added,changed,values}\n';assert block.count(line)==1
    block=block.replace(',value: Bool,result:',',result:').replace('  match value result:','  match result:').replace(line,'').replace('case True{} Tuple{flags,+flag}:','case Tuple{flags,+flag}:')
   if name=='struct_cols_live':
    assert block.count(',values,live,added,changed,True{},Array.get(')==1
    block=block.replace(',values,live,added,changed,True{},Array.get(',',values,live,added,changed,Array.get(')
    assert 'case Tuple{live,False{}}: StructColsState{main,aux,live,flags,added,changed,values}' in block
   if name=='struct_idx_go':
    before='struct_cols_finish(M,A,F,O,capacity,depth,high,state)';assert block.count(before)==1
    block=block.replace(before,'prototype_transport_finish(~M,~A,~F,~O,capacity,depth,high,state)')
   for n in sorted(names,key=len,reverse=True):block=re.sub(r'\b'+family+'_'+n+r'\b',alias+'_'+n,block)
   blocks.append(block.rstrip())
  facts[family]={'inputDefinitionSHA256':{n:hashlib.sha256(defs[family+'_'+n].encode()).hexdigest() for n in names},'fixedTrueCaller':'struct_cols_live True branch only','liveFalseBranchRetained':True}
  copies.extend(blocks)
 q.write_text(old+finish+'\n'+'\n\n'.join(copies)+'\n')
 m=output/'experiments/s-integrate/measurement-bend.bend';oldm=m.read_text();assert oldm.count('Q.prototype_noaux_each(')==2;m.write_text(oldm.replace('Q.prototype_noaux_each(','Q.prototype_transport_noaux_each('))
 newpins={str(p.relative_to(output)):sha(p) for p in output.rglob('*.bend')};assert [n for n in sorted(pins) if pins[n]!=newpins[n]]==['experiments/s-integrate/measurement-bend.bend','experiments/s-integrate/query.bend']
 cache.update(runtimeClosure=newpins,specializedClosure=newpins.copy(),runtimeClosureSHA256=closure(newpins));manifest.update(sources=newpins,cacheSpecialization=cache)
 receipt={'status':'UNVERIFIED_SOURCE_TRANSPORT_PROBE','inputSources':pins,'sources':newpins,'inputClosureSHA256':closure(pins),'outputClosureSHA256':closure(newpins),'facts':facts,'originalDefinitionsAndClientBodiesPreserved':True,'perRowStateEliminated':False,'terminalStateConstructorEliminated':True,'boolLiteralAllocationClaim':False,'performanceAcceptance':False,'proofAcceptance':False}
 for name,value in [('overlay.json',manifest),('cache-specialization.json',cache),('source-query-transport.json',receipt)]:(output/name).write_text(json.dumps(value,indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();materialize(a.input,a.output)
