#!/usr/bin/env python3
import pathlib,json,hashlib,shutil,argparse
H=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--source',type=pathlib.Path,default=pathlib.Path('/tmp/bendvy-packed-paired-journal-both-v3'));p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();digest=lambda pins:hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
pins={'experiments/s-integrate/'+f.name:sha(f) for f in (a.source/'experiments/s-integrate').glob('*.bend')};assert len(pins)==29 and digest(pins)=='d437d8f7e97ae66764e470c58cada7182715b8724d9dd065d20e55417e01e744'
m=json.loads((a.source/'overlay.json').read_text());c=json.loads((a.source/'cache-specialization.json').read_text());assert m['sources']==pins and m['cacheSpecialization']==c
for k in ['runtimeClosure','specializedClosure']:assert c[k]==pins and c[k+'SHA256']==digest(pins)
assert not a.output.exists();shutil.copytree(a.source,a.output)
folder=a.output/'experiments/s-integrate';q=(folder/'query.bend').read_text();at=q.index('def prototype_identity_restore_state');block=q[at:];assert block.count('def prototype_identity_each(')==1
block=block.replace('prototype_identity_','prototype_cursor_').replace('S.Handle<Schema>','U32').replace('S.Handle{namespace,id} <> values','id <> values')
# Only the new append-only family changes; generic/public query remains identical.
block=block.replace('def prototype_cursor_each(','def prototype_cursor_ids(')
block+='''\ntype PrototypeIdCursor<-Schema:Data> is Type:
  PrototypeIdCursor{namespace:U32,ids:List<&2,U32>}
def prototype_cursor_return(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,namespace:U32,result:S.World<Schema,M,A,F,L,Mode> & List<&2,U32>) -> S.World<Schema,M,A,F,L,Mode> & PrototypeIdCursor<Schema>:
  match result:
    case (world,ids): (world,PrototypeIdCursor{namespace,ids})
def prototype_cursor_each(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,selection:Selection,world:S.World<Schema,M,A,F,L,Mode>) -> S.World<Schema,M,A,F,L,Mode> & PrototypeIdCursor<Schema>:
  match world:
    case S.World{+namespace,next,rows,pending,ledger,mode}: prototype_cursor_return(Schema,M,A,F,L,Mode,namespace,prototype_cursor_ids(~Schema,~M,~A,~F,~L,~Mode,selection,S.World{namespace,next,rows,pending,ledger,mode}))
'''
(folder/'query.bend').write_text(q+'\n'+block)
h=(folder/'held-adapter.bend').read_text();extra=''
for lower,upper in [('motion','Motion'),('health','Health')]:
 family='prototype_packed_prototype_flatfold_motion' if lower=='motion' else 'prototype_packed_prototype_journalledger_health'
 start=h.index('def '+family+'_loop(');end=h.index('\ndef ',start+5)
 loop=h[start:end];entry_start=h.index('def '+family+'(',end);entry_end=h.find('\ndef ',entry_start+5);entry_end=len(h) if entry_end<0 else entry_end
 type_end=h.find('\ntype ',entry_start+5);entry_end=min(entry_end,type_end) if type_end>=0 else entry_end
 entry=h[entry_start:entry_end]
 name='prototype_cursor_flatfold_'+lower
 loop=loop.replace(family+'_loop',name+'_loop').replace('handles:List<&2,S.Handle<T.'+upper+'Schema>>','+namespace:U32,handles:List<&2,U32>')
 loop=loop.replace(name+'_loop(~client,rest,',name+'_loop(~client,namespace,rest,').replace('_step(~client,handle,state)','_step(~client,S.Handle{namespace,handle},state)')
 entry=entry.replace('def '+family+'(','def '+name+'(').replace('handles:List<&2,S.Handle<T.'+upper+'Schema>>','cursor:Q.PrototypeIdCursor<T.'+upper+'Schema>')
 body=entry.index('\n  prototype_packed_');entry=entry[:body]+'\n  match cursor:\n    case Q.PrototypeIdCursor{namespace,handles}: '+entry[body+3:].replace(family+'_loop(~client,handles,',name+'_loop(~client,namespace,handles,')
 extra+='\n'+loop+'\n'+entry+'\n'
(folder/'held-adapter.bend').write_text(h.replace('import Base','import Base\nimport ./query.bend as Q',1)+'\n'+extra)
b=(folder/'measurement-bend.bend').read_text()
for lower,upper in [('motion','Motion'),('health','Health')]:
 for name in ['prototype_packed_'+lower+'_handles','prototype_packed_prototype_flat_'+lower+'_rows','prototype_packed_prototype_flat_'+lower+'_queried']:
  start=b.index('def '+name+'(');end=b.find('\ndef ',start+5);end=len(b) if end<0 else end
  chunk=b[start:end].replace('List<&2,S.Handle<T.'+upper+'Schema>>','Q.PrototypeIdCursor<T.'+upper+'Schema>').replace('Q.prototype_identity_each','Q.prototype_cursor_each').replace('HA.prototype_packed_prototype_flatfold_'+lower+'(','HA.prototype_cursor_flatfold_'+lower+'(')
  b=b[:start]+chunk+b[end:]
(folder/'measurement-bend.bend').write_text(b)
newpins={'experiments/s-integrate/'+f.name:sha(f) for f in folder.glob('*.bend')};m['sources']=newpins
for k in ['runtimeClosure','specializedClosure']:c[k]=newpins;c[k+'SHA256']=digest(newpins)
m['cacheSpecialization']=c
(a.output/'overlay.json').write_text(json.dumps(m,indent=2)+'\n');(a.output/'cache-specialization.json').write_text(json.dumps(c,indent=2)+'\n')
r={'input29':pins,'inputClosure':digest(pins),'output29':newpins,'outputClosure':digest(newpins),'changed':[n for n in pins if pins[n]!=newpins[n]],'recipeSHA256':sha(pathlib.Path(__file__))};(a.output/'cursor-recipe.json').write_text(json.dumps(r,indent=2)+'\n');(H/'output-pins.json').write_text(json.dumps(r,indent=2)+'\n');print(r['outputClosure'])
