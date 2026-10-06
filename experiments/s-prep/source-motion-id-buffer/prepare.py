import pathlib,json,hashlib,shutil
P=pathlib.Path;b=P('/tmp/bendvy-slot-host-concrete-owner-v3');o=P('/tmp/bendvy-slot-host-motion-id-buffer-v10');sha=lambda x:hashlib.sha256(x).hexdigest();dig=lambda d:sha(json.dumps(d,sort_keys=True,separators=(',',':')).encode());m=json.loads((b/'overlay.json').read_text());pins=m['sources'];c=json.loads((b/'cache-specialization.json').read_text());assert dig(pins)=='a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55';assert c==m['cacheSpecialization'];assert c['runtimeClosure']==c['specializedClosure']==pins;assert c['runtimeClosureSHA256']==c['specializedClosureSHA256']==dig(pins);assert not o.exists();assert all(not(b/n).is_symlink()and sha((b/n).read_bytes())==h for n,h in pins.items());shutil.copytree(b,o)
q=o/'experiments/s-integrate/query.bend';old=q.read_text();start=old.index('type PrototypeConcreteMotionHandoffRows');end=old.index('type PrototypeConcreteHealthHandoffRows');s=old[start:end].replace('PrototypeConcreteMotion','PrototypeSplitMotion').replace('ConcreteMotion','SplitMotion').replace('prototype_concrete_motion','prototype_split_motion')
s=s.replace('SplitMotionHandoffCon{id:U32,owner:CP.PrototypeMotionMainSlot,rest:PrototypeSplitMotionHandoffRows}','SplitMotionHandoffCon{owner:CP.PrototypeMotionMainSlot,rest:PrototypeSplitMotionHandoffRows}')
pos=s.index('type PrototypeSplitMotionHandoffState');prefix=s[:pos];tail=s[pos:].replace('PrototypeSplitMotionHandoffRows','PrototypeSplitMotionHandoffBundle')
bundle='type PrototypeSplitMotionHandoffBundle is Type:\n  PrototypeSplitMotionHandoffBundle{rows:PrototypeSplitMotionHandoffRows,buffer:Array<U32>,count:U32}\ndef prototype_split_motion_prepend(id:U32,owner:CP.PrototypeMotionMainSlot,bundle:PrototypeSplitMotionHandoffBundle) -> PrototypeSplitMotionHandoffBundle:\n  match bundle:\n    case PrototypeSplitMotionHandoffBundle{rows,buffer,+count}: PrototypeSplitMotionHandoffBundle{SplitMotionHandoffCon{owner,rows},Array.set(U32,buffer,count,id),U32.add(count,1)}\n'
s=prefix+bundle+tail
s=s.replace('SplitMotionHandoffCon{id,owner,values}','prototype_split_motion_prepend(id,owner,values)')
s=s.replace('selection: Selection,namespace: U32) -> S.Rows<CP.PrototypeMotionMainSlot,A,F> & PrototypeSplitMotionHandoffBundle:', 'selection: Selection,namespace: U32,buffer:Array<U32>) -> S.Rows<CP.PrototypeMotionMainSlot,A,F> & PrototypeSplitMotionHandoffBundle:')
s=s.replace('changed,SplitMotionHandoffNil{}})','changed,PrototypeSplitMotionHandoffBundle{SplitMotionHandoffNil{},buffer,0}})')
s=s.replace('selection:Selection,world:S.World<T.MotionSchema,CP.PrototypeMotionMainSlot,A,F,L,Mode>)','buffer:Array<U32>,selection:Selection,world:S.World<T.MotionSchema,CP.PrototypeMotionMainSlot,A,F,L,Mode>)').replace('rows,selection,namespace))','rows,selection,namespace,buffer))')
start=s.index('def prototype_split_motion_handoff_recover_go(')
s=s[:start]+'''def prototype_split_motion_recover_id(next:Array<U32> -> U32 -> Array<Maybe<CP.PrototypeMotionMainSlot>> -> List<&2,U32> -> Array<Maybe<CP.PrototypeMotionMainSlot>> & List<&2,U32>,owner:CP.PrototypeMotionMainSlot,count:U32,columns:Array<Maybe<CP.PrototypeMotionMainSlot>>,ids:List<&2,U32>,pair:Array<U32> & U32) -> Array<Maybe<CP.PrototypeMotionMainSlot>> & List<&2,U32>:
  match pair:
    case (buffer,+id): next(buffer,count,Array.set(Maybe<CP.PrototypeMotionMainSlot>,columns,U32.sub(id,1),Some{owner}),id <> ids)
def prototype_split_motion_handoff_recover_go(rows:PrototypeSplitMotionHandoffRows,buffer:Array<U32>,+count:U32,columns:Array<Maybe<CP.PrototypeMotionMainSlot>>,ids:List<&2,U32>) -> Array<Maybe<CP.PrototypeMotionMainSlot>> & List<&2,U32>:
  match rows:
    case SplitMotionHandoffNil{}: (columns,List.reverse(&2,U32,ids))
    case SplitMotionHandoffCon{owner,rest}: prototype_split_motion_recover_id(buf => n => cols => acc => prototype_split_motion_handoff_recover_go(rest,buf,n,cols,acc),owner,U32.sub(count,1),columns,ids,Array.get(U32,buffer,U32.sub(count,1)))
def prototype_split_motion_handoff_recover(bundle:PrototypeSplitMotionHandoffBundle,columns:Array<Maybe<CP.PrototypeMotionMainSlot>>) -> Array<Maybe<CP.PrototypeMotionMainSlot>> & List<&2,U32>:
  match bundle:
    case PrototypeSplitMotionHandoffBundle{rows,buffer,count}: prototype_split_motion_handoff_recover_go(rows,buffer,count,columns,[])
'''
q.write_text(old+'\n'+s)
h=o/'experiments/s-integrate/held-adapter.bend';original=h.read_text();start=original.index('def prototype_handoff_motion_drain(');end=original.index('def prototype_handoff_motion_original(',start);part=original[start:end].replace('prototype_handoff_motion_drain','prototype_split_motion_drain').replace('prototype_handoff_motion_ready','prototype_split_motion_ready').replace('Q.PrototypeConcreteMotionHandoffRows','Q.PrototypeSplitMotionHandoffRows').replace('Q.PrototypeConcreteMotionHandoffBatch','Q.PrototypeSplitMotionHandoffBatch').replace('Q.ConcreteMotionHandoff','Q.SplitMotionHandoff')
part=part.replace('rows:Q.PrototypeSplitMotionHandoffRows,state:','rows:Q.PrototypeSplitMotionHandoffRows,buffer:Array<U32>,+count:U32,state:')
# A successful owner goes through one explicit buffer read before original taken helper.
caseStart=part.index('    case Q.SplitMotionHandoffCon{id,owner,rest}');caseEnd=part.index('def prototype_split_motion_ready',caseStart)
head=part[:caseStart]
body='''    case Q.SplitMotionHandoffCon{owner,rest} PrototypeFlatFold{+ns,next,columns,aux,metadata,capacity,depth,high,pending,Some{ledger},mode,_,undo,commands,pings,marks,total}:
      prototype_split_motion_drain_id(~client,buf => n => st => prototype_split_motion_drain(~client,rest,buf,n,st),owner,ledger,U32.sub(count,1),PrototypeFlatFold{ns,next,columns,aux,metadata,capacity,depth,high,pending,None{},mode,S.Handle{ns,0},undo,commands,pings,marks,total},Array.get(U32,buffer,U32.sub(count,1)))
    case Q.SplitMotionHandoffCon{owner,rest} PrototypeFlatFold{ns,next,columns,aux,metadata,capacity,depth,high,pending,None{},mode,selected,undo,commands,pings,marks,total}:
      prototype_handoff_motion_recovered(~client,ns,next,aux,metadata,capacity,depth,high,pending,None{},mode,selected,undo,commands,pings,marks,total,Q.prototype_split_motion_handoff_recover(Q.PrototypeSplitMotionHandoffBundle{Q.SplitMotionHandoffCon{owner,rest},buffer,count},columns))
'''
client=original[original.index('def prototype_handoff_motion_drain(')+len('def prototype_handoff_motion_drain('):];client=client[:client.index(',rows:')]
fold='PrototypeFlatFold<T.MotionSchema,P.PrototypeMotionMainSlot,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>'
helper=f'def prototype_split_motion_drain_id({client},resume:Array<U32> -> U32 -> {fold} -> {fold},owner:P.PrototypeMotionMainSlot,ledger:CC.Cache<T.MotionLedger,T.LedgerView>,+count:U32,state:{fold},pair:Array<U32> & U32) -> {fold}:\n  match state pair:\n    case PrototypeFlatFold{{+ns,next,columns,aux,metadata,capacity,depth,high,pending,_,mode,_,undo,commands,pings,marks,total}} Tuple{{buffer,+id}}:\n      resume(buffer,count,prototype_packed_prototype_flatfold_motion_taken(~client,(columns,Some{{owner}}),ledger,ns,next,aux,metadata,capacity,depth,high,pending,mode,S.Handle{{ns,id}},undo,commands,pings,marks,total))\n'
# Forward declaration/mutual recursion unsupported? Bend permits helper-call recursion as originals.
ready=part[caseEnd:].replace('case Q.PrototypeSplitMotionHandoffBatch{world,rows}:','case Q.PrototypeSplitMotionHandoffBatch{world,Q.PrototypeSplitMotionHandoffBundle{rows,buffer,count}}:').replace('(~client,rows,prototype_packed','(~client,rows,buffer,count,prototype_packed')
new=original+'\n'+helper+head+body+ready
# Guard buffer before producer; original shape helper receives physical main size.
start=original.index('def prototype_handoff_motion_shape_chosen(');end=original.index('def prototype_handoff_flatfold_motion(',start);shape=original[start:end].replace('prototype_handoff_motion_shape_chosen','prototype_split_motion_shape_chosen').replace('prototype_handoff_motion_shape','prototype_split_motion_shape')
shape=shape.replace('total:U32,valid:Bool,world:','total:U32,buffer:Array<U32>,valid:Bool,world:').replace('prototype_handoff_motion_ready(~client','prototype_split_motion_ready(~client').replace('Q.prototype_concrete_motion_handoff_each(T.Velocity','Q.prototype_split_motion_handoff_each(T.Velocity').replace('T.MotionMode,selection,world))','T.MotionMode,buffer,selection,world))')
# restore buffer accidentally inserted into false ordinary fallback
shape=shape.replace('Q.prototype_cursor_each(T.MotionSchema,P.PrototypeMotionMainSlot,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,buffer,selection,world)','Q.prototype_cursor_each(T.MotionSchema,P.PrototypeMotionMainSlot,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,selection,world)')
shape=shape.replace('+capacity:U32,depth:Nat','+capacity:U32,+depth:Nat')
# main+IDs guard through explicit buffer size result before Q call
shape=shape.replace('prototype_split_motion_shape_chosen(~client,selection,selected,undo,commands,pings,marks,total,(capacity <= size : U32),S.World{ns,next,S.Rows{columns,aux,metadata,capacity,depth,high},pending,Some{ledger},mode})','prototype_split_motion_buffer_guard(~client,selection,selected,undo,commands,pings,marks,total,capacity,size,S.World{ns,next,S.Rows{columns,aux,metadata,capacity,depth,high},pending,Some{ledger},mode},Array.size(U32,Array.new(U32,depth,0)))')
header,returnType=shape.splitlines()[0].rsplit(') -> ',1);ret=' -> '+returnType.removesuffix(':')
guard=header.replace('prototype_split_motion_shape_chosen','prototype_split_motion_buffer_guard').replace('buffer:Array<U32>,valid:Bool,world:','+capacity:U32,+mainSize:U32,world:')+ ',result:Array<U32> & U32)'+ret+':\n  match result:\n    case (buffer,size): prototype_split_motion_shape_chosen(~client,selection,selected,undo,commands,pings,marks,total,buffer,Bool.and((capacity <= mainSize : U32),(capacity <= size : U32)),world)\n'
# header already ends )
guard=guard.replace('>,result:Array', '>,result:Array')
guard=guard.replace('>,result', '>,result').replace('>),result','>,result')
split=shape.index('def prototype_split_motion_shape(');new+='\n'+shape[:split]+'\n'+guard+'\n'+shape[split:]
# Only redirect Motion entry's Some/Main guard route; everything else stays v3.
needle='prototype_handoff_motion_shape(~client,selection,ns,next,aux,metadata,capacity,depth,high,pending,ledger,mode,selected,undo,commands,pings,marks,total,Array.size(Maybe<P.PrototypeMotionMainSlot>,columns))';assert new.count(needle)==1;extra=new[len(original):];redirected=original.replace(needle,needle.replace('prototype_handoff_motion_shape','prototype_split_motion_shape'));at=redirected.index('def prototype_handoff_flatfold_motion(');new=redirected[:at]+extra+'\n'+redirected[at:];h.write_text(new)
newpins={n:sha((o/n).read_bytes())for n in pins};c.update(runtimeClosure=newpins,specializedClosure=newpins,runtimeClosureSHA256=dig(newpins),specializedClosureSHA256=dig(newpins));m.update(sources=newpins,cacheSpecialization=c)
for name,d in [('overlay.json',m),('cache-specialization.json',c)]:(o/name).write_text(json.dumps(d,indent=2)+'\n')
r={'producerSHA256':sha(P(__file__).read_bytes()),'inputSources':pins,'sources':newpins,'sourceClosureSHA256':dig(newpins),'baseClosure':dig(pins),'scope':'Motion-only split ID buffer; private alignment invariant, no malformed exported Batch recovery claim'};(o/'split-id-recipe.json').write_text(json.dumps(r,indent=2)+'\n');print(dig(newpins))
