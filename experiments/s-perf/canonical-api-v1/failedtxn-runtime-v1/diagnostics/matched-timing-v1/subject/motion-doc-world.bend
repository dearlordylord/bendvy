import Base
import report-doc.bend as Doc
import motion.bend as F
import motion-observe.bend as O
import motion-logical.bend as Logical
import /tmp/bendvy-failedtxn-matched-method/src/ecs/inspector-query.bend as IQ
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import events.bend as E
import physical-owner-observer.bend as Dump
import physical-allocator-observer.bend as Gen
import /tmp/bendvy-failedtxn-matched-method/src/ecs/entity-allocator.bend as A
import /tmp/bendvy-failedtxn-matched-method/src/ecs/entity-key.bend as K
import /tmp/bendvy-failedtxn-matched-method/src/ecs/column.bend as Col
import /tmp/bendvy-failedtxn-matched-method/src/ecs/lifecycle.bend as Life
import /tmp/bendvy-failedtxn-matched-method/src/ecs/indexed-lifecycle.bend as Metadata
import /tmp/bendvy-failedtxn-matched-method/src/ecs/owner-product.bend as Product
import /tmp/bendvy-failedtxn-matched-method/src/ecs/deferred-command.bend as Deferred
import /tmp/bendvy-failedtxn-matched-method/src/ecs/world.bend as W

def lift(~P:Type,observed:P & String) -> P & Doc.Doc:
  (owner,text)=observed
  (owner,Doc.text(text))
def leaf_doc(~P:Type,owner:P,text:Doc.Doc) -> Array<P> & Doc.Doc:
  match text:
    case Doc.Text{value,count}:(ALeaf{owner},Doc.PhysicalLeaf{value,count})
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
def u32_data(+value:U32) -> U32 & Doc.Doc:(value,Doc.text(U32.show(value)))
def u32(value:U32) -> U32 & Doc.Doc:u32_data(value)
def slot(value:A.Slot) -> A.Slot & Doc.Doc:
  match value:
    case A.Slot{+generation,+phase}:(A.Slot{generation,phase},Doc.text(U32.show(generation) ++ ":" ++ Gen.phase(phase)))
def data_leaf(value:Doc.Doc) -> Doc.Doc:
  match value:
    case Doc.Text{value,count}:Doc.PhysicalLeaf{value,count}
    case other:Doc.prefix("leaf:",other)
# Reached allocator/payload metadata arrays are balanced power-of-two storage.
# Detached carry Docs merge consecutive equally sized completed ranges.
def carry_go(fuel:Nat,bits:U32,value:Doc.Doc,stack:List<&2,Doc.Doc>,odd:Bool) -> List<&2,Doc.Doc>:
  match fuel stack odd:
    case 0n, _, _:Doc.text("invalid physical carry fuel") <> []
    case 1n+rest, stack, False{}:value <> stack
    case 1n+rest, left <> tail, True{}:
      +next=U32.shr(bits)
      carry_go(rest,next,Doc.physical_node(left,value),tail,U32.is_eq(U32.and(next,1),1))
    case 1n+rest, [], True{}:Doc.text("invalid physical carry stack") <> []
def carry(+index:U32,value:Doc.Doc,stack:List<&2,Doc.Doc>) -> List<&2,Doc.Doc>:carry_go(1n+U32.to_nat(index),index,value,stack,U32.is_eq(U32.and(index,1),1))
def data_finished(~P:Type,owner:Array<P>,stack:List<&2,Doc.Doc>) -> Array<P> & Doc.Doc:
  match stack:
    case value <> []:(owner,value)
    case _:(owner,Doc.text("invalid physical carry completion"))
def data_scan(~P:Data,~render:P -> Doc.Doc,left:Nat,observed:Array<P> & P,+index:U32,stack:List<&2,Doc.Doc>) -> Array<P> & Doc.Doc:
  match left observed:
    case 0n,(owner,_):(owner,Doc.text("invalid physical scan count"))
    case 1n,(owner,value):data_finished(~P,owner,carry(index,data_leaf(render(value)),stack))
    case 2n+rest,(owner,value):
      +next=U32.add(index,1)
      data_scan(~P,~render,1n+rest,Array.get(P,owner,next),next,carry(index,data_leaf(render(value)),stack))
def data_sized(~P:Data,~render:P -> Doc.Doc,observed:Array<P> & U32) -> Array<P> & Doc.Doc:
  match observed:
    case (owner,count):data_scan(~P,~render,U32.to_nat(count),Array.get(P,owner,0),0,[])
def data_array(~P:Data,~render:P -> Doc.Doc,owner:Array<P>) -> Array<P> & Doc.Doc:data_sized(~P,~render,Array.size(P,owner))
def u32_doc(value:U32) -> Doc.Doc:Doc.text(U32.show(value))
def slot_doc(value:A.Slot) -> Doc.Doc:
  match value:
    case A.Slot{generation,phase}:Doc.text(U32.show(generation) ++ ":" ++ Gen.phase(phase))
def allocator_join(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,K.Key>,observed:Array<A.Slot> & Doc.Doc) -> A.Allocator & Doc.Doc:
  (slots,text)=observed
  (A.Allocator{next,high,slots,capacity,depth,free,order},Doc.concat([Doc.text("next=" ++ U32.show(next) ++ ";high=" ++ U32.show(high) ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";slots="),text,Doc.text(";free=" ++ List.show(&2,U32,U32.show,free) ++ ";order=" ++ List.show(&2,K.Key,Gen.key_text,order))]))
def allocator(value:A.Allocator) -> A.Allocator & Doc.Doc:
  match value:
    case A.Allocator{next,high,slots,capacity,depth,free,order}:allocator_join(next,high,capacity,depth,free,order,data_array(~A.Slot,~slot_doc,slots))
def main_join(+frame:U32,observed:Array<U32> & Doc.Doc) -> T.Position & Doc.Doc:
  (values,text)=observed
  (T.Position{values,frame},Doc.wrap("Position{",text,";" ++ U32.show(frame) ++ "}"))
def main(value:T.Position) -> T.Position & Doc.Doc:
  match value:
    case T.Position{values,frame}:main_join(frame,data_array(~U32,~u32_doc,values))
def aux_join(+moving:Bool,observed:Array<U32> & Doc.Doc) -> T.Velocity & Doc.Doc:
  (values,text)=observed
  (T.Velocity{values,moving},Doc.wrap("Velocity{",text,";" ++ Bool.show(moving) ++ "}"))
def aux(value:T.Velocity) -> T.Velocity & Doc.Doc:
  match value:
    case T.Velocity{values,moving}:aux_join(moving,data_array(~U32,~u32_doc,values))
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
  (ALeaf{Some{owner}},Doc.wrap("leaf:some(",text,")"))
type OptionalPhase<P:Type> is Type:
  Take{observed:Array<Maybe<&1,P>> & Maybe<&1,P>}
  Restore{array:Array<Maybe<&1,P>>,observed:P & Doc.Doc}
def optional_failed(~P:Type,owner:Array<Maybe<&1,P>>) -> Array<Maybe<&1,P>> & Doc.Doc:(owner,Doc.text("invalid physical optional scan"))
def optional_scan(~P:Type,~project:P -> P & Doc.Doc,fuel:Nat,phase:OptionalPhase<P>,left:Nat,+index:U32,stack:List<&2,Doc.Doc>) -> Array<Maybe<&1,P>> & Doc.Doc:
  match fuel phase left:
    case 0n,Take{(owner,None{})},_:optional_failed(~P,owner)
    case 0n,Take{(owner,Some{value})},_:optional_failed(~P,Array.set(Maybe<&1,P>,owner,index,Some{value}))
    case 0n,Restore{owner,(value,_)},_:optional_failed(~P,Array.set(Maybe<&1,P>,owner,index,Some{value}))
    case 1n+rest,Take{(owner,None{})},0n:optional_failed(~P,owner)
    case 1n+rest,Take{(owner,Some{value})},0n:optional_failed(~P,Array.set(Maybe<&1,P>,owner,index,Some{value}))
    case 1n+rest,Restore{owner,(value,_)},0n:optional_failed(~P,Array.set(Maybe<&1,P>,owner,index,Some{value}))
    case 1n+rest,Take{(owner,None{})},1n:data_finished(~Maybe<&1,P>,owner,carry(index,Doc.text("leaf:none"),stack))
    case 1n+rest,Take{(owner,None{})},2n+more:
      +next=U32.add(index,1)
      optional_scan(~P,~project,rest,Take{Array.swap(Maybe<&1,P>,owner,next,None{})},1n+more,next,carry(index,Doc.text("leaf:none"),stack))
    case 1n+rest,Take{(owner,Some{value})},1n+more:optional_scan(~P,~project,rest,Restore{owner,project(value)},1n+more,index,stack)
    case 1n+rest,Restore{owner,(value,text)},1n:data_finished(~Maybe<&1,P>,Array.set(Maybe<&1,P>,owner,index,Some{value}),carry(index,Doc.wrap("leaf:some(",text,")"),stack))
    case 1n+rest,Restore{owner,(value,text)},2n+more:
      +next=U32.add(index,1)
      optional_scan(~P,~project,rest,Take{Array.swap(Maybe<&1,P>,Array.set(Maybe<&1,P>,owner,index,Some{value}),next,None{})},1n+more,next,carry(index,Doc.wrap("leaf:some(",text,")"),stack))
def optional_sized(~P:Type,~project:P -> P & Doc.Doc,observed:Array<Maybe<&1,P>> & U32) -> Array<Maybe<&1,P>> & Doc.Doc:
  match observed:
    case (owner,+count):optional_scan(~P,~project,Nat.add(U32.to_nat(count),U32.to_nat(count)),Take{Array.swap(Maybe<&1,P>,owner,0,None{})},U32.to_nat(count),0,[])
def balanced_optional_values(~P:Type,~project:P -> P & Doc.Doc,owner:Array<Maybe<&1,P>>) -> Array<Maybe<&1,P>> & Doc.Doc:optional_sized(~P,~project,Array.size(Maybe<&1,P>,owner))
def optional_values(~P:Type,~project:P -> P & Doc.Doc,value:Array<Maybe<&1,P>>) -> Array<Maybe<&1,P>> & Doc.Doc:
  match value:
    case ALeaf{None{}}:(ALeaf{None{}},Doc.text("leaf:none"))
    case ALeaf{Some{owner}}:some_leaf(~P,project(owner))
    case ANode{left,right}:node(~Maybe<&1,P>,optional_values(~P,~project,left),optional_values(~P,~project,right))
def plain(~P:Type,+stamps:List<&2,Life.Entry>,observed:Array<Maybe<&1,P>> & Doc.Doc) -> Col.Column<T.MotionSchema,P> & Doc.Doc:
  (values,text)=observed
  (Col.Column{values,stamps},Doc.wrap("Column{values=",text,";stamps=" ++ List.show(&2,Life.Entry,Dump.entry,stamps) ++ "}"))
def metadata_join(+capacity:U32,+depth:Nat,+exceptional:List<&2,Life.Entry>,observedAdded:Array<U32> & Doc.Doc,observedChanged:Array<U32> & Doc.Doc) -> Metadata.Metadata & Doc.Doc:
  (added,sa)=observedAdded
  (changed,sc)=observedChanged
  (Metadata.Metadata{added,changed,capacity,depth,exceptional},Doc.concat([Doc.text("added="),sa,Doc.text(";changed="),sc,Doc.text(";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";exceptional=" ++ List.show(&2,Life.Entry,Dump.entry,exceptional))]))
def metadata(value:Metadata.Metadata) -> Metadata.Metadata & Doc.Doc:
  match value:
    case Metadata.Metadata{added,changed,capacity,depth,exceptional}:metadata_join(capacity,depth,exceptional,data_array(~U32,~u32_doc,added),data_array(~U32,~u32_doc,changed))
def indexed_join(~P:Type,observedValues:Array<Maybe<&1,P>> & Doc.Doc,observedMetadata:Metadata.Metadata & Doc.Doc) -> Col.IndexedOrdinaryCarrier<T.MotionSchema,P> & Doc.Doc:
  (values,sv)=observedValues
  (stored,sm)=observedMetadata
  (Col.IndexedOrdinaryOwned{Col.IndexedOrdinaryState{values,stored}},Doc.concat([Doc.text("owned(values="),sv,Doc.text(";metadata={"),sm,Doc.text("})")]))
def indexed_wrap(~P:Type,observed:Col.IndexedOrdinaryCarrier<T.MotionSchema,P> & Doc.Doc) -> Col.IndexedOrdinaryCarrier<T.MotionSchema,P> & Doc.Doc:
  (owner,text)=observed
  (Col.IndexedOrdinaryWrapped{owner},Doc.wrap("wrapped(",text,")"))
def indexed(~P:Type,~project:P -> P & Doc.Doc,value:Col.IndexedOrdinaryCarrier<T.MotionSchema,P>) -> Col.IndexedOrdinaryCarrier<T.MotionSchema,P> & Doc.Doc:
  match value:
    case Col.IndexedOrdinaryOwned{Col.IndexedOrdinaryState{values,stored}}:indexed_join(~P,balanced_optional_values(~P,~project,values),metadata(stored))
    case Col.IndexedOrdinaryWrapped{inner}:indexed_wrap(~P,indexed(~P,~project,inner))
def indexed_column(~P:Type,observed:Col.IndexedOrdinaryCarrier<T.MotionSchema,P> & Doc.Doc) -> Col.Column<T.MotionSchema,P> & Doc.Doc:
  (owner,text)=observed
  (Col.Indexed{owner},Doc.wrap("Indexed{",text,"}"))
def column(~P:Type,~project:P -> P & Doc.Doc,~legacy:P -> P & String,value:Col.Column<T.MotionSchema,P>) -> Col.Column<T.MotionSchema,P> & Doc.Doc:
  match value:
    case Col.Column{values,stamps}:plain(~P,stamps,balanced_optional_values(~P,~project,values))
    case Col.Indexed{carrier}:indexed_column(~P,indexed(~P,~project,carrier))
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

def row_doc(value:IQ.ProjectedRow<T.MotionSchema,Logical.Value()>) -> Doc.Doc:Doc.text(O.row(value))
def rows_observed(observed:F.World() & Logical.Rows()) -> F.World() & Doc.Doc:
  match observed:
    case (world,rows):(world,Doc.show(~IQ.ProjectedRow<T.MotionSchema,Logical.Value()>,~row_doc,rows))
def rows(world:F.World()) -> F.World() & Doc.Doc:rows_observed(Logical.rows(world))
