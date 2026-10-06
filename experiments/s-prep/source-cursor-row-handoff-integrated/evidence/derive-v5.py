#!/usr/bin/env python3
"""Pin-checked new source overlay. Never edit consumed source roots."""
from pathlib import Path
import json,hashlib,shutil,argparse,re
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--source',type=Path,default=Path('/tmp/bendvy-slot-host-v1'));p.add_argument('--output',type=Path,required=True);a=p.parse_args();assert not a.output.exists();sha=lambda b:hashlib.sha256(b).hexdigest();m=json.loads((a.source/'overlay.json').read_text());cache=json.loads((a.source/'cache-specialization.json').read_text());pins={str(f.relative_to(a.source)):sha(f.read_bytes()) for f in (a.source/'experiments/s-integrate').glob('*.bend')};assert len(pins)==29 and pins==m['sources'] and m['cacheSpecialization']==cache
expected=json.loads((H/'input-pins.json').read_text());assert pins==expected['sources'] and sha((a.source/'overlay.json').read_bytes())==expected['manifestSHA256'] and sha((a.source/'cache-specialization.json').read_bytes())==expected['cacheSHA256'];shutil.copytree(a.source,a.output)
core=a.output/'experiments/s-integrate';q=(core/'query.bend').read_text();ha=(core/'held-adapter.bend').read_text();mb=(core/'measurement-bend.bend').read_text()
def declaration(source,name):
 matches=list(re.finditer(r'^def '+re.escape(name)+r'\(',source,re.M));assert len(matches)==1,name;start=matches[0].start();nextdef=re.search(r'^(?:def|type|law|proof) ',source[matches[0].end():],re.M);end=matches[0].end()+nextdef.start() if nextdef else len(source);return source[start:end].rstrip()
start=q.index('def prototype_cursor_restore_state(');end=q.index('def prototype_cursor_ids(',start);newq=q[start:end].replace('prototype_cursor_','prototype_handoff_').replace('StructColsState<M,A,F,U32>','PrototypeHandoffState<Schema,M,A,F>').replace('StructColsState{','PrototypeHandoffState{').replace('List<&2,U32>','List<&1,PrototypeHandoffRow<Schema,M>>')
old='PrototypeHandoffState{Array.set(Maybe<M>,main,U32.sub(id,1),Some{owner}),aux,live,flags,added,changed,id <> values}';assert newq.count(old)==1;newq=newq.replace(old,'PrototypeHandoffState{main,aux,live,flags,added,changed,PrototypeHandoffRow{id,owner} <> values}')
newq=newq.replace('def prototype_handoff_finish_forward(-M:Type','def prototype_handoff_finish_forward(-Schema:Data,-M:Type').replace('prototype_handoff_finish_forward(M,A,F,','prototype_handoff_finish_forward(Schema,M,A,F,')
qt='''\n# Private two-phase affine ownership handoff; original query APIs remain unchanged.
type PrototypeHandoffRow<-Schema:Data,-M:Type> is Type:
  PrototypeHandoffRow{id:U32,owner:M}
type PrototypeHandoffState<-Schema:Data,-M:Type,-A:Type,-F:Data> is Type:
  PrototypeHandoffState{main:Array<Maybe<M>>,aux:Array<Maybe<A>>,live:Array<Bool>,flags:Array<Maybe<&2,F>>,added:Array<U32>,changed:Array<U32>,values:List<&1,PrototypeHandoffRow<Schema,M>>}
type PrototypeHandoffBatch<-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data> is Type:
  PrototypeHandoffBatch{world:S.World<Schema,M,A,F,L,Mode>,rows:List<&1,PrototypeHandoffRow<Schema,M>>}
'''+newq+'''
def prototype_handoff_world_return(-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data,namespace:U32,next:U32,pending:List<S.Command<M,A,F>>,ledger:Maybe<L>,mode:Mode,result:S.Rows<M,A,F> & List<&1,PrototypeHandoffRow<Schema,M>>) -> PrototypeHandoffBatch<Schema,M,A,F,L,Mode>:
  match result:
    case (rows,values): PrototypeHandoffBatch{S.World{namespace,next,rows,pending,ledger,mode},values}
def prototype_handoff_each(~Schema:Data,~M:Type,~A:Type,~F:Data,~L:Type,~Mode:Data,selection:Selection,world:S.World<Schema,M,A,F,L,Mode>) -> PrototypeHandoffBatch<Schema,M,A,F,L,Mode>:
  match world:
    case S.World{+namespace,next,rows,pending,ledger,mode}: prototype_handoff_world_return(Schema,M,A,F,L,Mode,namespace,next,pending,ledger,mode,prototype_handoff_read_rows(~Schema,~M,~A,~F,rows,selection,namespace))
def prototype_handoff_recover_go(-Schema:Data,-M:Type,rows:List<&1,PrototypeHandoffRow<Schema,M>>,columns:Array<Maybe<M>>,ids:List<&2,U32>) -> Array<Maybe<M>> & List<&2,U32>:
  match rows:
    case Nil{}: (columns,List.reverse(&2,U32,ids))
    case Con{PrototypeHandoffRow{+id,owner},rest}: prototype_handoff_recover_go(Schema,M,rest,Array.set(Maybe<M>,columns,U32.sub(id,1),Some{owner}),id <> ids)
def prototype_handoff_recover(-Schema:Data,-M:Type,rows:List<&1,PrototypeHandoffRow<Schema,M>>,columns:Array<Maybe<M>>) -> Array<Maybe<M>> & List<&2,U32>:
  prototype_handoff_recover_go(Schema,M,rows,columns,[])
'''

qt+='''
type PrototypeHandoffArrayShape is Data:
  PrototypeHandoffArrayShape{size:U32,balanced:Bool}
def prototype_handoff_array_combine(-T:Type,left:Array<T> & PrototypeHandoffArrayShape,right:Array<T> & PrototypeHandoffArrayShape) -> Array<T> & PrototypeHandoffArrayShape:
  match left right:
    case Tuple{xs,PrototypeHandoffArrayShape{+ls,lb}} Tuple{ys,PrototypeHandoffArrayShape{rs,rb}}: (ANode{xs,ys},PrototypeHandoffArrayShape{U32.shl(ls),Bool.and(U32.is_eq(ls,rs),Bool.and(lb,rb))})
def prototype_handoff_array_inspect(-T:Type,array:Array<T>) -> Array<T> & PrototypeHandoffArrayShape:
  match array:
    case ALeaf{owner}: (ALeaf{owner},PrototypeHandoffArrayShape{1,True{}})
    case ANode{xs,ys}: prototype_handoff_array_combine(T,prototype_handoff_array_inspect(T,xs),prototype_handoff_array_inspect(T,ys))
'''
append=[]
for lane,Schema,Main,Aux,Flag,Mode,Ledger,internal,oldprefix in [
 ('motion','T.MotionSchema','P.PrototypeMotionMainSlot','T.Velocity','T.Selected','T.MotionMode','CC.Cache<T.MotionLedger,T.LedgerView>','CC.Cache<T.MotionLedger,T.LedgerView>','prototype_packed_prototype_flatfold_motion'),
 ('health','T.HealthSchema','P.PrototypeHealthMainSlot','T.Armor','T.Tracked','T.HealthMode','CC.Cache<T.HealthLedger,T.LedgerView>','PrototypeJournalLedger<T.LedgerView>','prototype_packed_prototype_journalledger_health')]:
 old=declaration(ha,'prototype_cursor_flatfold_'+lane);client=old.split(',cursor:',1)[0].split('(~client:',1)[1];C='~client:'+client
 W=f'S.World<{Schema},{Main},{Aux},{Flag},{Ledger},{Mode}>';Cmd=f'S.Command<{Main},{Aux},{Flag}>';Tx=f'X.PrototypeFlatTx<{Schema},{W},{Cmd}>';State=f'PrototypeFlatFold<{Schema},{Main},{Aux},{Flag},{internal},{Mode}>';Row=f'Q.PrototypeHandoffRow<{Schema},{Main}>';Batch=f'Q.PrototypeHandoffBatch<{Schema},{Main},{Aux},{Flag},{Ledger},{Mode}>'
 context=f'+ns:U32,next:U32,aux:Array<Maybe<{Aux}>>,metadata:S.MetadataColumns<{Flag}>,capacity:U32,depth:Nat,high:U32,pending:List<{Cmd}>,ledger:Maybe<{internal}>,mode:{Mode},selected:S.Handle<{Schema}>,undo:X.PrototypeFlatInverse<{Schema}>,commands:List<{Cmd}>,pings:List<&2,U32>,marks:X.PrototypeFlatMark<{Schema}>,total:U32'
 fields='ns,next,columns,aux,metadata,capacity,depth,high,pending,ledger,mode,selected,undo,commands,pings,marks,total'
 append.append(f'''
# Private {lane} producer/drain owns all evacuated columns and future affine rows.
def prototype_handoff_{lane}_recovered({C},{context},result:Array<Maybe<{Main}>> & List<&2,U32>) -> {State}:
  match result:
    case (columns,ids): prototype_cursor_flatfold_{lane}_loop(~client,ns,ids,PrototypeFlatFold{{{fields}}})
def prototype_handoff_{lane}_drain({C},rows:List<&1,{Row}>,state:{State}) -> {State}:
  match rows state:
    case Nil{{}} state: state
    case Con{{Q.PrototypeHandoffRow{{id,owner}},rest}} PrototypeFlatFold{{+ns,next,columns,aux,metadata,capacity,depth,high,pending,Some{{ledger}},mode,_,undo,commands,pings,marks,total}}:
      prototype_handoff_{lane}_drain(~client,rest,{oldprefix}_taken(~client,(columns,Some{{owner}}),ledger,ns,next,aux,metadata,capacity,depth,high,pending,mode,S.Handle{{ns,id}},undo,commands,pings,marks,total))
    case Con{{row,rest}} PrototypeFlatFold{{ns,next,columns,aux,metadata,capacity,depth,high,pending,None{{}},mode,selected,undo,commands,pings,marks,total}}:
      prototype_handoff_{lane}_recovered(~client,ns,next,aux,metadata,capacity,depth,high,pending,None{{}},mode,selected,undo,commands,pings,marks,total,Q.prototype_handoff_recover({Schema},{Main},Con{{row,rest}},columns))
def prototype_handoff_{lane}_ready({C},selected:S.Handle<{Schema}>,undo:X.PrototypeFlatInverse<{Schema}>,commands:List<{Cmd}>,pings:List<&2,U32>,marks:X.PrototypeFlatMark<{Schema}>,total:U32,batch:{Batch}) -> {Tx} & U32:
  match batch:
    case Q.PrototypeHandoffBatch{{world,rows}}: {oldprefix}_finish(prototype_handoff_{lane}_drain(~client,rows,{oldprefix}_pack(X.PrototypeFlatTx{{world,selected,undo,commands,pings,marks}},total)))
def prototype_handoff_{lane}_original({C},selected:S.Handle<{Schema}>,undo:X.PrototypeFlatInverse<{Schema}>,commands:List<{Cmd}>,pings:List<&2,U32>,marks:X.PrototypeFlatMark<{Schema}>,total:U32,result:{W} & Q.PrototypeIdCursor<{Schema}>) -> {Tx} & U32:
  match result:
    case (world,cursor): prototype_cursor_flatfold_{lane}(~client,cursor,X.PrototypeFlatTx{{world,selected,undo,commands,pings,marks}},total)
def prototype_handoff_{lane}_shape_chosen({C},selection:Q.Selection,selected:S.Handle<{Schema}>,undo:X.PrototypeFlatInverse<{Schema}>,commands:List<{Cmd}>,pings:List<&2,U32>,marks:X.PrototypeFlatMark<{Schema}>,total:U32,valid:Bool,world:{W}) -> {Tx} & U32:
  match valid:
    case False{{}}: prototype_handoff_{lane}_original(~client,selected,undo,commands,pings,marks,total,Q.prototype_cursor_each({Schema},{Main},{Aux},{Flag},{Ledger},{Mode},selection,world))
    case True{{}}: prototype_handoff_{lane}_ready(~client,selected,undo,commands,pings,marks,total,Q.prototype_handoff_each({Schema},{Main},{Aux},{Flag},{Ledger},{Mode},selection,world))
def prototype_handoff_{lane}_shape({C},selection:Q.Selection,ns:U32,next:U32,aux:Array<Maybe<{Aux}>>,metadata:S.MetadataColumns<{Flag}>,+capacity:U32,depth:Nat,high:U32,pending:List<{Cmd}>,ledger:{Ledger},mode:{Mode},selected:S.Handle<{Schema}>,undo:X.PrototypeFlatInverse<{Schema}>,commands:List<{Cmd}>,pings:List<&2,U32>,marks:X.PrototypeFlatMark<{Schema}>,total:U32,result:Array<Maybe<{Main}>> & Q.PrototypeHandoffArrayShape) -> {Tx} & U32:
  match result:
    case (columns,Q.PrototypeHandoffArrayShape{{size,balanced}}): prototype_handoff_{lane}_shape_chosen(~client,selection,selected,undo,commands,pings,marks,total,Bool.and(balanced,(capacity <= size : U32)),S.World{{ns,next,S.Rows{{columns,aux,metadata,capacity,depth,high}},pending,Some{{ledger}},mode}})
def prototype_handoff_flatfold_{lane}({C},selection:Q.Selection,owner:{Tx},total:U32) -> {Tx} & U32:
  match owner:
    case X.PrototypeFlatTx{{S.World{{ns,next,rows,pending,None{{}},mode}},selected,undo,commands,pings,marks}}:
      prototype_handoff_{lane}_original(~client,selected,undo,commands,pings,marks,total,Q.prototype_cursor_each({Schema},{Main},{Aux},{Flag},{Ledger},{Mode},selection,S.World{{ns,next,rows,pending,None{{}},mode}}))
    case X.PrototypeFlatTx{{S.World{{ns,next,S.Rows{{columns,aux,metadata,capacity,depth,high}},pending,Some{{ledger}},mode}},selected,undo,commands,pings,marks}}:
      prototype_handoff_{lane}_shape(~client,selection,ns,next,aux,metadata,capacity,depth,high,pending,ledger,mode,selected,undo,commands,pings,marks,total,Q.prototype_handoff_array_inspect(Maybe<{Main}>,columns))
''')
# New private invoke; existing body/callback algorithms and public Host family stay byte-exact.
mbappend=[]
for lane,Schema,Main,Aux,Flag,Mode,Ledger in [('motion','T.MotionSchema','CP.PrototypeMotionMainSlot','T.Velocity','T.Selected','T.MotionMode','CC.Cache<T.MotionLedger,T.LedgerView>'),('health','T.HealthSchema','CP.PrototypeHealthMainSlot','T.Armor','T.Tracked','T.HealthMode','CC.Cache<T.HealthLedger,T.LedgerView>')]:
 original=declaration(mb,'prototype_packed_'+lane+'_invoke');name='prototype_handoff_'+lane+'_invoke';original=original.replace('prototype_packed_'+lane+'_invoke(',name+'(',1)
 oldcall='prototype_packed_prototype_flat_'+lane+'_queried(sparse,total,count,logs,bindings,name,step,prior,events,audit,run,clock,prototype_packed_'+lane+'_handles(world))';W=f'S.World<{Schema},{Main},{Aux},{Flag},{Ledger},{Mode}>';Cmd=f'S.Command<{Main},{Aux},{Flag}>'
 newcall=f'prototype_packed_prototype_flat_{lane}_updated(sparse,count,logs,bindings,name,step,prior,events,audit,run,clock,prototype_packed_prototype_flat_{lane}_rows_next(HA.prototype_handoff_flatfold_{lane}(~SC.{lane}_body,Q.Required{{}},X.prototype_flat_pack(~{Schema},~{W},~{Cmd},X.tx_begin({W},S.Handle<{Schema}>,{Cmd},world,S.Handle{{0,0}})),total),0))'
 assert original.count(oldcall)==1;original=original.replace(oldcall,newcall);mbappend.append(original)
 # Declare appended functions before tick: original tick is the only redirected source declaration.
 tick=declaration(mb,'prototype_packed_'+lane+'_tick');newtick=tick.replace('prototype_packed_'+lane+'_invoke,',name+',');assert tick!=newtick;mb=mb.replace(tick,newtick)
 # Insert before tick to avoid forward references, preserving all other declarations exactly.
 pos=mb.index('def prototype_packed_'+lane+'_tick(');mb=mb[:pos]+original+'\n\n'+mb[pos:]
(core/'query.bend').write_text(q+'\n'+qt);(core/'held-adapter.bend').write_text(ha+'\n'+''.join(append));(core/'measurement-bend.bend').write_text(mb)
newpins={str(f.relative_to(a.output)):sha(f.read_bytes()) for f in core.glob('*.bend')};digest=sha(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode());cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins;cache['runtimeClosureSHA256']=digest;cache['specializedClosureSHA256']=digest;m['sources']=newpins;m['cacheSpecialization']=cache;m['privateHandoff']={'base':'4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c','changed':['query.bend','held-adapter.bend','measurement-bend.bend'],'closure':digest};(a.output/'overlay.json').write_text(json.dumps(m,indent=2)+'\n');(a.output/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n');(a.output/'handoff-source-pins.json').write_text(json.dumps({'input':expected,'output':newpins,'closure':digest,'recipeSHA256':sha(Path(__file__).read_bytes())},indent=2)+'\n');print(json.dumps({'output':str(a.output),'closure':digest,'changes':[k for k in pins if pins[k]!=newpins[k]]}))
