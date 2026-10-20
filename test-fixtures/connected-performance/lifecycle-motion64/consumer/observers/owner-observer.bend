import Base
import ../../../../../src/ecs/change-tick.bend as Tick
import ../../../../../src/ecs/clock-state.bend as Clock
import ../../../../../src/ecs/deferred-command.bend as Deferred
import ../../../../../src/ecs/entity-allocator.bend as Alloc
import allocator-observer.bend as Gen
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/indexed-lifecycle.bend as M
import ../../../../../src/ecs/lifecycle.bend as L
import ../../../../../src/ecs/world.bend as W

def leaf(~T:Type,observed:T & String) -> Array<T> & String:
  (value,text)=observed
  (ALeaf{value},"leaf:" ++ text)
def node_join(~T:Type,leftObserved:Array<T> & String,rightObserved:Array<T> & String) -> Array<T> & String:
  (left,text)=leftObserved
  (right,other)=rightObserved
  (ANode{left,right},"node(" ++ text ++ "," ++ other ++ ")")
def array(~T:Type,~project:T -> T & String,value:Array<T>) -> Array<T> & String:
  match value:
    case ALeaf{value}:leaf(~T,project(value))
    case ANode{left,right}:node_join(~T,array(~T,~project,left),array(~T,~project,right))
def u32_data(+value:U32) -> U32 & String:
  (value,U32.show(value))
def u32_value(value:U32) -> U32 & String:
  u32_data(value)
def u32_array(value:Array<U32>) -> Array<U32> & String:
  array(~U32,~u32_value,value)
def bool_data(+value:Bool) -> Bool & String:
  (value,Bool.show(value))
def bool_value(value:Bool) -> Bool & String:
  bool_data(value)
def bool_array(value:Array<Bool>) -> Array<Bool> & String:
  array(~Bool,~bool_value,value)
def optional_done(~Payload:Type,observed:Payload & String) -> Maybe<&1,Payload> & String:
  (owner,text)=observed
  (Some{owner},"some(" ++ text ++ ")")
def optional(~Payload:Type,~project:Payload -> Payload & String,value:Maybe<&1,Payload>) -> Maybe<&1,Payload> & String:
  match value:
    case None{}:(None{},"none")
    case Some{owner}:optional_done(~Payload,project(owner))
def stamp(value:L.Stamp) -> String:
  match value:
    case L.Stamp{added,changed}:Tick.cursor_show(added) ++ ":" ++ Tick.cursor_show(changed)
def entry(value:L.Entry) -> String:
  match value:
    case L.Entry{id,value}:U32.show(id) ++ ":" ++ stamp(value)
def tick_value_data(+value:Maybe<&2,Tick.Tick>) -> Maybe<&2,Tick.Tick> & String:
  (value,Tick.cursor_show(value))
def tick_value(value:Maybe<&2,Tick.Tick>) -> Maybe<&2,Tick.Tick> & String:tick_value_data(value)
def tick_array(value:Array<Maybe<&2,Tick.Tick>>) -> Array<Maybe<&2,Tick.Tick>> & String:
  array(~Maybe<&2,Tick.Tick>,~tick_value,value)
def metadata_join(+capacity:U32,+depth:Nat,+exceptional:List<&2,L.Entry>,observedAdded:Array<Maybe<&2,Tick.Tick>> & String,observedChanged:Array<Maybe<&2,Tick.Tick>> & String) -> M.Metadata & String:
  (added,sa)=observedAdded
  (changed,sc)=observedChanged
  (M.Metadata{added,changed,capacity,depth,exceptional},"added=" ++ sa ++ ";changed=" ++ sc ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";exceptional=" ++ List.show(&2,L.Entry,entry,exceptional))
def metadata(value:M.Metadata) -> M.Metadata & String:
  match value:
    case M.Metadata{added,changed,capacity,depth,exceptional}:metadata_join(capacity,depth,exceptional,tick_array(added),tick_array(changed))
def indexed_join(~S:Data,~P:Type,observedValues:Array<Maybe<&1,P>> & String,observedMeta:M.Metadata & String) -> Col.IndexedOrdinaryCarrier<S,P> & String:
  (values,sv)=observedValues
  (metadata,sm)=observedMeta
  (Col.IndexedOrdinaryOwned{Col.IndexedOrdinaryState{values,metadata}},"owned(values=" ++ sv ++ ";metadata={" ++ sm ++ "})")
def indexed_wrap(~S:Data,~P:Type,observed:Col.IndexedOrdinaryCarrier<S,P> & String) -> Col.IndexedOrdinaryCarrier<S,P> & String:
  (inner,text)=observed
  (Col.IndexedOrdinaryWrapped{inner},"wrapped(" ++ text ++ ")")
def indexed_state(~S:Data,~P:Type,~project:P -> P & String,value:Col.IndexedOrdinaryState<S,P>) -> Col.IndexedOrdinaryCarrier<S,P> & String:
  match value:
    case Col.IndexedOrdinaryState{values,meta}:indexed_join(~S,~P,array(~Maybe<&1,P>,~optional(~P,~project),values),metadata(meta))
def indexed(~S:Data,~P:Type,~project:P -> P & String,value:Col.IndexedOrdinaryCarrier<S,P>) -> Col.IndexedOrdinaryCarrier<S,P> & String:
  match value:
    case Col.IndexedOrdinaryOwned{state}:indexed_state(~S,~P,~project,state)
    case Col.IndexedOrdinaryWrapped{inner}:indexed_wrap(~S,~P,indexed(~S,~P,~project,inner))
def indexed_column(~S:Data,~P:Type,observed:Col.IndexedOrdinaryCarrier<S,P> & String) -> Col.Column<S,P> & String:
  (state,text)=observed
  (Col.Indexed{state},"Indexed{" ++ text ++ "}")
def plain_column(~S:Data,~P:Type,+stamps:List<&2,L.Entry>,observed:Array<Maybe<&1,P>> & String) -> Col.Column<S,P> & String:
  (values,text)=observed
  (Col.Column{values,stamps},"Column{values=" ++ text ++ ";stamps=" ++ List.show(&2,L.Entry,entry,stamps) ++ "}")
def column(~S:Data,~P:Type,~project:P -> P & String,value:Col.Column<S,P>) -> Col.Column<S,P> & String:
  match value:
    case Col.Column{values,stamps}:plain_column(~S,~P,stamps,array(~Maybe<&1,P>,~optional(~P,~project),values))
    case Col.Indexed{state}:indexed_column(~S,~P,indexed(~S,~P,~project,state))
    case value:(value,"UNSUPPORTED_PREPARED_COLUMN")
# Opaque callbacks are returned unchanged; this observer never executes them.
def callbacks_count(~A:Type,head:Deferred.Command<A>,kind:String,observed:List<Deferred.Command<A>> & (Nat & String)) -> List<Deferred.Command<A>> & (Nat & String):
  (rest,(count,kinds))=observed
  (head <> rest,(1n+count,kind ++ kinds))
def callbacks_join(~A:Type,~B:Type,head:Deferred.Command<A>,observed:List<Deferred.Command<A>> & (Nat & String)) -> List<Deferred.Command<A>> & (Nat & String):
  match head:
    case Deferred.Raw{apply}:callbacks_count(~A,Deferred.Raw{apply},"Raw;",observed)
    case Deferred.Observed{apply}:callbacks_count(~A,Deferred.Observed{apply},"Observed;",observed)
def callbacks(~A:Type,~B:Type,values:List<Deferred.Command<A>>) -> List<Deferred.Command<A>> & (Nat & String):
  match values:
    case []:([],(0n,"end"))
    case head <> rest:callbacks_join(~A,~B,head,callbacks(~A,~B,rest))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access)
def world_join(~S:Data,~P:Type,~R:Type,~E:Data,~showE:E -> String,+namespace:U32,+events:List<&2,E>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:Clock.State,observedAllocator:Alloc.Allocator & String,observedStore:Col.Column<S,P> & String,observedResource:R & String,observedPending:List<Deferred.Command<W.World<S,Col.Column<S,P>,R,E>>> & (Nat & String)) -> W.World<S,Col.Column<S,P>,R,E> & String:
  (allocator,sa)=observedAllocator
  (store,ss)=observedStore
  (resource,sr)=observedResource
  (pending,(+count,kinds))=observedPending
  (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},"namespace=" ++ U32.show(namespace) ++ "|allocator={" ++ sa ++ "}|store=" ++ ss ++ "|resource=" ++ sr ++ "|events=" ++ List.show(&2,E,showE,events) ++ "|pendingCount=" ++ Nat.show(count) ++ "|pendingEmpty=" ++ Bool.show(Nat.is_eq(count,0n)) ++ "|pendingKinds=" ++ kinds ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ "|nextSystemId=" ++ U32.show(nextSystemId) ++ "|clock=" ++ Tick.show(Clock.now(clock)))
def world(~S:Data,~P:Type,~R:Type,~E:Data,~viewP:P -> P & String,~viewR:R -> R & String,~showE:E -> String,value:W.World<S,Col.Column<S,P>,R,E>) -> W.World<S,Col.Column<S,P>,R,E> & String:
  match value:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}:world_join(~S,~P,~R,~E,~showE,namespace,events,registrations,nextSystemId,clock,Gen.allocator(allocator),column(~S,~P,~viewP,store),viewR(resource),callbacks(~W.World<S,Col.Column<S,P>,R,E>,~W.World<S,Col.Column<S,P>,R,E>,pending))
