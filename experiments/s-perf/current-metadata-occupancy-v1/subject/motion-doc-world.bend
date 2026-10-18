import Base
import ../private/occupancy.bend as Occupancy
import motion-report-doc.bend as Doc
import motion.bend as F
import motion-observe.bend as O
import types.bend as T
import events.bend as E
import ../private/observers/owner-observer.bend as Dump
import ../private/observers/allocator-observer.bend as Gen
import ../private/src/ecs/entity-allocator.bend as A
import ../private/src/ecs/entity-key.bend as K
import ../private/src/ecs/column.bend as Col
import ../private/src/ecs/lifecycle.bend as Life
import ../private/src/ecs/indexed-lifecycle.bend as Metadata
import ../private/src/ecs/owner-product.bend as Product
import ../private/src/ecs/deferred-command.bend as Deferred
import ../private/src/ecs/world.bend as W

def lift(~P:Type,observed:P & String) -> P & Doc.Doc:
  (owner,text)=observed
  (owner,Doc.text(text))
def leaf_doc(~P:Type,owner:P,text:Doc.Doc) -> Array<P> & Doc.Doc:
  match text:
    case Doc.Text{value}:(ALeaf{owner},Doc.ScalarLeaf{value})
    case other:(ALeaf{owner},Doc.prefix("leaf:",other))
def leaf(~P:Type,observed:P & Doc.Doc) -> Array<P> & Doc.Doc:
  (owner,text)=observed
  leaf_doc(~P,owner,text)
def node(~P:Type,observedLeft:Array<P> & Doc.Doc,observedRight:Array<P> & Doc.Doc) -> Array<P> & Doc.Doc:
  (left,sl)=observedLeft
  (right,sr)=observedRight
  (ANode{left,right},Doc.physical_node(sl,sr))
def array(~P:Type,~project:P -> P & Doc.Doc,value:Array<P>) -> Array<P> & Doc.Doc:
  match value:
    case ALeaf{value}:leaf(~P,project(value))
    case ANode{left,right}:node(~P,array(~P,~project,left),array(~P,~project,right))
def indexed_leaf_doc(observed:Doc.Doc) -> Doc.Doc:
  match observed:
    case Doc.Text{value}:Doc.ScalarLeaf{value}
    case other:Doc.prefix("leaf:",other)
def indexed_leaf_get(~P:Data,~render:P -> Doc.Doc,observed:Array<P> & P) -> Array<P> & Doc.Doc:
  match observed:
    case (owner,item):(owner,indexed_leaf_doc(render(item)))
def indexed_leaf(~P:Data,~render:P -> Doc.Doc,+index:U32,value:Array<P>) -> Array<P> & Doc.Doc:
  indexed_leaf_get(~P,~render,Array.get(P,value,index))
def indexed_array_right(~P:Data,leftText:Doc.Doc,observed:Array<P> & Doc.Doc) -> Array<P> & Doc.Doc:
  match observed:
    case (owner,rightText):(owner,Doc.physical_node(leftText,rightText))
def indexed_array_left_apply(~P:Data,leftText:Doc.Doc,recurse:Array<P> -> Array<P> & Doc.Doc,owner:Array<P>) -> Array<P> & Doc.Doc:
  indexed_array_right(~P,leftText,recurse(owner))
def indexed_array_left(~P:Data,left:Array<P> & Doc.Doc,recurse:Array<P> -> Array<P> & Doc.Doc) -> Array<P> & Doc.Doc:
  match left:
    case (leftOwner,leftText):indexed_array_left_apply(~P,leftText,recurse,leftOwner)
def indexed_array(~P:Data,~render:P -> Doc.Doc,depth:Nat,+capacity:U32,+start:U32,value:Array<P>) -> Array<P> & Doc.Doc:
  match depth:
    case 0n:indexed_leaf(~P,~render,start,value)
    case 1n++rest:
      +half=U32.shr(capacity)
      +rightStart=U32.add(start,half)
      indexed_array_left(~P,indexed_array(~P,~render,rest,half,start,value),owner => indexed_array(~P,~render,rest,half,rightStart,owner))
def identity_data_render(~P:Data,~render:P -> Doc.Doc,+value:P) -> P & Doc.Doc:(value,render(value))
def indexed_data_array_checked(~P:Data,~render:P -> Doc.Doc,+capacity:U32,depth:Nat,balanced:Bool,value:Array<P>) -> Array<P> & Doc.Doc:
  match balanced:
    case True{}:indexed_array(~P,~render,depth,capacity,0,value)
    case False{}:array(~P,value => identity_data_render(~P,~render,value),value)
def indexed_data_array(~P:Data,~render:P -> Doc.Doc,+capacity:U32,+depth:Nat,value:Array<P>) -> Array<P> & Doc.Doc:
  indexed_data_array_checked(~P,~render,capacity,depth,U32.is_eq(capacity,U32.shln(1,depth)),value)
def u32_data(+value:U32) -> U32 & Doc.Doc:(value,Doc.text(U32.show(value)))
def u32(value:U32) -> U32 & Doc.Doc:u32_data(value)
def u32_render(value:U32) -> Doc.Doc:Doc.text(U32.show(value))
def slot(value:A.Slot) -> A.Slot & Doc.Doc:
  match value:
    case A.Slot{+generation,+phase}:(A.Slot{generation,phase},Doc.text(U32.show(generation) ++ ":" ++ Gen.phase(phase)))
def slot_render(value:A.Slot) -> Doc.Doc:
  match value:
    case A.Slot{generation,phase}:Doc.text(U32.show(generation) ++ ":" ++ Gen.phase(phase))
def allocator_join(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,K.Key>,observed:Array<A.Slot> & Doc.Doc) -> A.Allocator & Doc.Doc:
  (slots,text)=observed
  (A.Allocator{next,high,slots,capacity,depth,free,order},Doc.concat([Doc.text("next=" ++ U32.show(next) ++ ";high=" ++ U32.show(high) ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";slots="),text,Doc.text(";free=" ++ List.show(&2,U32,U32.show,free) ++ ";order=" ++ List.show(&2,K.Key,Gen.key_text,order))]))
def allocator(value:A.Allocator) -> A.Allocator & Doc.Doc:
  match value:
    case A.Allocator{next,high,slots,+capacity,+depth,free,order}:allocator_join(next,high,capacity,depth,free,order,indexed_data_array(~A.Slot,~slot_render,capacity,depth,slots))
def main_join(+frame:U32,observed:Array<U32> & Doc.Doc) -> T.Position & Doc.Doc:
  (values,text)=observed
  (T.Position{values,frame},Doc.wrap("Position{",text,";" ++ U32.show(frame) ++ "}"))
def main(value:T.Position) -> T.Position & Doc.Doc:
  match value:
    case T.Position{values,frame}:main_join(frame,indexed_data_array(~U32,~u32_render,4,2n,values))
def aux_join(+moving:Bool,observed:Array<U32> & Doc.Doc) -> T.Velocity & Doc.Doc:
  (values,text)=observed
  (T.Velocity{values,moving},Doc.wrap("Velocity{",text,";" ++ Bool.show(moving) ++ "}"))
def aux(value:T.Velocity) -> T.Velocity & Doc.Doc:
  match value:
    case T.Velocity{values,moving}:aux_join(moving,indexed_data_array(~U32,~u32_render,4,2n,values))
def flag(value:T.Selected) -> T.Selected & Doc.Doc:
  lift(~T.Selected,O.flag(value))
def optional_join(~P:Type,observed:P & Doc.Doc) -> Maybe<&1,P> & Doc.Doc:
  (owner,text)=observed
  (Some{owner},Doc.wrap("some(",text,")"))
def optional(~P:Type,~project:P -> P & Doc.Doc,value:Maybe<&1,P>) -> Maybe<&1,P> & Doc.Doc:
  match value:
    case None{}:(None{},Doc.text("none"))
    case Some{owner}:optional_join(~P,project(owner))
def some_leaf(~P:Type,observed:P & Doc.Doc) -> Array<Maybe<&1,P>> & Doc.Doc:
  (owner,text)=observed
  (ALeaf{Some{owner}},Doc.wrapped_leaf(text))
def optional_values(~P:Type,~project:P -> P & Doc.Doc,value:Array<Maybe<&1,P>>) -> Array<Maybe<&1,P>> & Doc.Doc:
  match value:
    case ALeaf{None{}}:(ALeaf{None{}},Doc.NoneLeaf{})
    case ALeaf{Some{owner}}:some_leaf(~P,project(owner))
    case ANode{left,right}:node(~Maybe<&1,P>,optional_values(~P,~project,left),optional_values(~P,~project,right))
type OptionalPhase<P:Type> is Type:
  Take{observed:Array<Maybe<&1,P>> & Maybe<&1,P>}
  Restore{array:Array<Maybe<&1,P>>,observed:P & Doc.Doc}
def optional_failed(~P:Type,owner:Array<Maybe<&1,P>>) -> Array<Maybe<&1,P>> & Doc.Doc:(owner,Doc.text("invalid physical optional scan"))
def carry_go(fuel:Nat,bits:U32,value:Doc.Doc,stack:List<&2,Doc.Doc>,odd:Bool) -> List<&2,Doc.Doc>:
  match fuel stack odd:
    case 0n,_,_:Doc.text("invalid physical carry fuel") <> []
    case 1n+rest,stack,False{}:value <> stack
    case 1n+rest,left <> tail,True{}:
      +next=U32.shr(bits)
      carry_go(rest,next,Doc.physical_node(left,value),tail,U32.is_eq(U32.and(next,1),1))
    case 1n+rest,[],True{}:Doc.text("invalid physical carry stack") <> []
def carry(+index:U32,value:Doc.Doc,stack:List<&2,Doc.Doc>) -> List<&2,Doc.Doc>:
  carry_go(1n+U32.to_nat(index),index,value,stack,U32.is_eq(U32.and(index,1),1))
def data_finished(~P:Type,owner:Array<P>,stack:List<&2,Doc.Doc>) -> Array<P> & Doc.Doc:
  match stack:
    case value <> []:(owner,value)
    case _:(owner,Doc.text("invalid physical carry completion"))
def optional_scan(~P:Type,~project:P -> P & Doc.Doc,fuel:Nat,phase:OptionalPhase<P>,left:Nat,+index:U32,stack:List<&2,Doc.Doc>) -> Array<Maybe<&1,P>> & Doc.Doc:
  match fuel phase left:
    case 0n,Take{(owner,None{})},_:optional_failed(~P,owner)
    case 0n,Take{(owner,Some{value})},_:optional_failed(~P,Array.set(Maybe<&1,P>,owner,index,Some{value}))
    case 0n,Restore{owner,(value,_)},_:optional_failed(~P,Array.set(Maybe<&1,P>,owner,index,Some{value}))
    case 1n+rest,Take{(owner,None{})},0n:optional_failed(~P,owner)
    case 1n+rest,Take{(owner,Some{value})},0n:optional_failed(~P,Array.set(Maybe<&1,P>,owner,index,Some{value}))
    case 1n+rest,Restore{owner,(value,_)},0n:optional_failed(~P,Array.set(Maybe<&1,P>,owner,index,Some{value}))
    case 1n+rest,Take{(owner,None{})},1n:data_finished(~Maybe<&1,P>,owner,carry(index,Doc.NoneLeaf{},stack))
    case 1n+rest,Take{(owner,None{})},2n+more:
      +next=U32.add(index,1)
      optional_scan(~P,~project,rest,Take{Array.swap(Maybe<&1,P>,owner,next,None{})},1n+more,next,carry(index,Doc.NoneLeaf{},stack))
    case 1n+rest,Take{(owner,Some{value})},1n+more:optional_scan(~P,~project,rest,Restore{owner,project(value)},1n+more,index,stack)
    case 1n+rest,Restore{owner,(value,text)},1n:data_finished(~Maybe<&1,P>,Array.set(Maybe<&1,P>,owner,index,Some{value}),carry(index,Doc.wrapped_leaf(text),stack))
    case 1n+rest,Restore{owner,(value,text)},2n+more:
      +next=U32.add(index,1)
      optional_scan(~P,~project,rest,Take{Array.swap(Maybe<&1,P>,Array.set(Maybe<&1,P>,owner,index,Some{value}),next,None{})},1n+more,next,carry(index,Doc.wrapped_leaf(text),stack))
def optional_sized(~P:Type,~project:P -> P & Doc.Doc,+capacity:U32,value:Array<Maybe<&1,P>>) -> Array<Maybe<&1,P>> & Doc.Doc:
  optional_scan(~P,~project,Nat.add(U32.to_nat(capacity),U32.to_nat(capacity)),Take{Array.swap(Maybe<&1,P>,value,0,None{})},U32.to_nat(capacity),0,[])
def indexed_optional_values_checked(~P:Type,~project:P -> P & Doc.Doc,+capacity:U32,value:Array<Maybe<&1,P>>,supported:Bool) -> Array<Maybe<&1,P>> & Doc.Doc:
  match supported:
    case True{}:optional_sized(~P,~project,capacity,value)
    case False{}:optional_values(~P,~project,value)
def indexed_optional_values_sized(~P:Type,~project:P -> P & Doc.Doc,+capacity:U32,+depth:Nat,result:Array<Maybe<&1,P>> & U32) -> Array<Maybe<&1,P>> & Doc.Doc:
  match result:
    case (owner,+actual):indexed_optional_values_checked(~P,~project,capacity,owner,U32.is_eq(actual,capacity) && U32.is_gt(capacity,0) && U32.is_le(capacity,131072) && Nat.is_le(depth,17n) && U32.is_eq(capacity,U32.shln(1,depth)))
def indexed_optional_values(~P:Type,~project:P -> P & Doc.Doc,+capacity:U32,+depth:Nat,value:Array<Maybe<&1,P>>) -> Array<Maybe<&1,P>> & Doc.Doc:
  indexed_optional_values_sized(~P,~project,capacity,depth,Array.size(Maybe<&1,P>,value))
def metadata_shape(value:Metadata.Metadata) -> Metadata.Metadata & (U32 & Nat):
  match value:
    case Metadata.Metadata{added,changed,+capacity,+depth,exceptional}:(Metadata.Metadata{added,changed,capacity,depth,exceptional},(capacity,depth))
def plain(~P:Type,+stamps:List<&2,Life.Entry>,observed:Array<Maybe<&1,P>> & Doc.Doc) -> Col.Column<T.MotionSchema,P> & Doc.Doc:
  (values,text)=observed
  (Col.Column{values,stamps},Doc.wrap("Column{values=",text,";stamps=" ++ List.show(&2,Life.Entry,Dump.entry,stamps) ++ "}"))
def metadata_join(+capacity:U32,+depth:Nat,+exceptional:List<&2,Life.Entry>,observedAdded:Array<U32> & Doc.Doc,observedChanged:Array<U32> & Doc.Doc) -> Metadata.Metadata & Doc.Doc:
  (added,sa)=observedAdded
  (changed,sc)=observedChanged
  (Metadata.Metadata{added,changed,capacity,depth,exceptional},Doc.concat([Doc.text("added="),sa,Doc.text(";changed="),sc,Doc.text(";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";exceptional=" ++ List.show(&2,Life.Entry,Dump.entry,exceptional))]))
def metadata(value:Metadata.Metadata) -> Metadata.Metadata & Doc.Doc:
  match value:
    case Metadata.Metadata{added,changed,+capacity,+depth,exceptional}:metadata_join(capacity,depth,exceptional,indexed_data_array(~U32,~u32_render,capacity,depth,added),indexed_data_array(~U32,~u32_render,capacity,depth,changed))
def indexed_join(~P:Type,observedValues:Array<Maybe<&1,P>> & Doc.Doc,observedMetadata:Metadata.Metadata & Doc.Doc) -> Col.IndexedOrdinaryCarrier<T.MotionSchema,P> & Doc.Doc:
  (values,sv)=observedValues
  (stored,sm)=observedMetadata
  (Col.IndexedOrdinaryOwned{Col.IndexedOrdinaryState{values,stored}},Doc.concat([Doc.text("owned(values="),sv,Doc.text(";metadata={"),sm,Doc.text("})")]))
def indexed_wrap(~P:Type,observed:Col.IndexedOrdinaryCarrier<T.MotionSchema,P> & Doc.Doc) -> Col.IndexedOrdinaryCarrier<T.MotionSchema,P> & Doc.Doc:
  (owner,text)=observed
  (Col.IndexedOrdinaryWrapped{owner},Doc.wrap("wrapped(",text,")"))
def indexed_owned_metadata(~P:Type,~project:P -> P & Doc.Doc,values:Array<Maybe<&1,P>>,observed:Metadata.Metadata & (U32 & Nat)) -> Col.IndexedOrdinaryCarrier<T.MotionSchema,P> & Doc.Doc:
  match observed:
    case (stored,(capacity,depth)):indexed_join(~P,indexed_optional_values(~P,~project,capacity,depth,values),metadata(stored))
def indexed_owned(~P:Type,~project:P -> P & Doc.Doc,value:Col.IndexedOrdinaryState<T.MotionSchema,P>) -> Col.IndexedOrdinaryCarrier<T.MotionSchema,P> & Doc.Doc:
  match value:
    case Col.IndexedOrdinaryState{values,stored}:
      indexed_owned_metadata(~P,~project,values,metadata_shape(stored))
def indexed(~P:Type,~project:P -> P & Doc.Doc,value:Col.IndexedOrdinaryCarrier<T.MotionSchema,P>) -> Col.IndexedOrdinaryCarrier<T.MotionSchema,P> & Doc.Doc:
  match value:
    case Col.IndexedOrdinaryOwned{state}:indexed_owned(~P,~project,state)
    case Col.IndexedOrdinaryWrapped{inner}:indexed_wrap(~P,indexed(~P,~project,inner))
def indexed_column(~P:Type,observed:Col.IndexedOrdinaryCarrier<T.MotionSchema,P> & Doc.Doc) -> Col.Column<T.MotionSchema,P> & Doc.Doc:
  (owner,text)=observed
  (Col.Indexed{owner},Doc.wrap("Indexed{",text,"}"))
def monitored_column(~P:Type,samples:List<&2,Occupancy.Sample>,observed:Col.Column<T.MotionSchema,P> & Doc.Doc) -> Col.Column<T.MotionSchema,P> & Doc.Doc:
  match observed:
    case (inner,text):(Col.Monitored{inner,samples},text)
def column(~P:Type,~project:P -> P & Doc.Doc,~legacy:P -> P & String,value:Col.Column<T.MotionSchema,P>) -> Col.Column<T.MotionSchema,P> & Doc.Doc:
  match value:
    case Col.Column{values,stamps}:plain(~P,stamps,optional_values(~P,~project,values))
    case Col.Indexed{carrier}:indexed_column(~P,indexed(~P,~project,carrier))
    case Col.Monitored{inner,samples}:monitored_column(~P,samples,column(~P,~project,~legacy,inner))
    case other:lift(~Col.Column<T.MotionSchema,P>,Dump.column(~T.MotionSchema,~P,~legacy,other))

def store_join(observedMain:Col.Column<T.MotionSchema,T.Position> & Doc.Doc,observedAux:Col.Column<T.MotionSchema,T.Velocity> & Doc.Doc,observedFlag:Col.Column<T.MotionSchema,T.Selected> & Doc.Doc) -> F.Store() & Doc.Doc:
  (main,sm)=observedMain
  (aux,sa)=observedAux
  (flag,sf)=observedFlag
  (Product.Owner{main,Product.Owner{aux,flag}},Doc.concat([Doc.text("main={"),sm,Doc.text("};aux={"),sa,Doc.text("};flag={"),sf,Doc.text("}")]))
def store(value:F.Store()) -> F.Store() & Doc.Doc:
  match value:
    case Product.Owner{mc,Product.Owner{ac,fc}}:store_join(column(~T.Position,~main,~O.main,mc),column(~T.Velocity,~aux,~O.aux,ac),column(~T.Selected,~flag,~O.flag,fc))
def resources(value:F.Resources()) -> F.Resources() & Doc.Doc:
  lift(~F.Resources(),O.resources(value))
def world_join(+namespace:U32,+events:List<&2,E.event_type()>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,observedAllocator:A.Allocator & Doc.Doc,observedStore:F.Store() & Doc.Doc,observedResource:F.Resources() & Doc.Doc,observedPending:List<Deferred.Command<F.World()>> & (Nat & String)) -> F.World() & Doc.Doc:
  (allocator,sa)=observedAllocator
  (stored,ss)=observedStore
  (resource,sr)=observedResource
  (pending,(count,kinds))=observedPending
  (W.World{namespace,allocator,stored,resource,events,pending,registrations,nextSystem,clock},Doc.concat([Doc.text("namespace=" ++ U32.show(namespace) ++ "|allocator={"),sa,Doc.text("}|store={"),ss,Doc.text("}|resource={"),sr,Doc.text("}|events=" ++ List.show(&2,E.event_type(),O.event,events) ++ "|pending=" ++ Nat.show(count) ++ ":" ++ kinds ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,registrations) ++ "|nextSystem=" ++ U32.show(nextSystem) ++ "|clock=" ++ U32.show(clock))]))
def world(value:F.World()) -> F.World() & Doc.Doc:
  match value:
    case W.World{namespace,allocated,stored,resource,events,pending,registrations,nextSystem,clock}:world_join(namespace,events,registrations,nextSystem,clock,allocator(allocated),store(stored),resources(resource),Dump.callbacks(~F.World(),~F.World(),pending))
