import Base
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/indexed-lifecycle.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

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
    case L.Stamp{added,changed}:U32.show(added) ++ ":" ++ U32.show(changed)
def entry(value:L.Entry) -> String:
  match value:
    case L.Entry{id,value}:U32.show(id) ++ ":" ++ stamp(value)
def metadata_join(+capacity:U32,+depth:Nat,+exceptional:List<&2,L.Entry>,observedAdded:Array<U32> & String,observedChanged:Array<U32> & String) -> M.Metadata & String:
  (added,sa)=observedAdded
  (changed,sc)=observedChanged
  (M.Metadata{added,changed,capacity,depth,exceptional},"added=" ++ sa ++ ";changed=" ++ sc ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";exceptional=" ++ List.show(&2,L.Entry,entry,exceptional))
def metadata(value:M.Metadata) -> M.Metadata & String:
  match value:
    case M.Metadata{added,changed,capacity,depth,exceptional}:metadata_join(capacity,depth,exceptional,u32_array(added),u32_array(changed))
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
def callbacks_join(~A:Type,~B:Type,head:A -> B,observed:List<(A -> B)> & Nat) -> List<(A -> B)> & Nat:
  (rest,count)=observed
  (head <> rest,1n+count)
def callbacks(~A:Type,~B:Type,values:List<(A -> B)>) -> List<(A -> B)> & Nat:
  match values:
    case []:([],0n)
    case head <> rest:callbacks_join(~A,~B,head,callbacks(~A,~B,rest))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access)
def world_join(~S:Data,~P:Type,~R:Type,~E:Data,~showE:E -> String,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,+events:List<&2,E>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,observedLive:Array<Bool> & String,observedStore:Col.Column<S,P> & String,observedResource:R & String,observedPending:List<(W.World<S,Col.Column<S,P>,R,E> -> W.World<S,Col.Column<S,P>,R,E>)> & Nat) -> W.World<S,Col.Column<S,P>,R,E> & String:
  (live,sl)=observedLive
  (store,ss)=observedStore
  (resource,sr)=observedResource
  (pending,+count)=observedPending
  (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},"namespace=" ++ U32.show(namespace) ++ "|nextId=" ++ U32.show(nextId) ++ "|highWater=" ++ U32.show(highWater) ++ "|live=" ++ sl ++ "|capacity=" ++ U32.show(capacity) ++ "|depth=" ++ Nat.show(depth) ++ "|store=" ++ ss ++ "|resource=" ++ sr ++ "|events=" ++ List.show(&2,E,showE,events) ++ "|pendingCount=" ++ Nat.show(count) ++ "|pendingEmpty=" ++ Bool.show(Nat.is_eq(count,0n)) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ "|nextSystemId=" ++ U32.show(nextSystemId) ++ "|clock=" ++ U32.show(clock))
def world(~S:Data,~P:Type,~R:Type,~E:Data,~viewP:P -> P & String,~viewR:R -> R & String,~showE:E -> String,value:W.World<S,Col.Column<S,P>,R,E>) -> W.World<S,Col.Column<S,P>,R,E> & String:
  match value:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:world_join(~S,~P,~R,~E,~showE,namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock,bool_array(live),column(~S,~P,~viewP,store),viewR(resource),callbacks(~W.World<S,Col.Column<S,P>,R,E>,~W.World<S,Col.Column<S,P>,R,E>,pending))

def mixed_store_join(~S:Data,~P:Type,rest:Unit,observed:Col.Column<S,P> & String) -> Product.Owner<Col.Column<S,P>,Unit> & String:
  match observed:
    case (column,text):(Product.Owner{column,rest},"product(" ++ text ++ ",Unit)")
def mixed_store(~S:Data,~P:Type,~project:P -> P & String,value:Product.Owner<Col.Column<S,P>,Unit>) -> Product.Owner<Col.Column<S,P>,Unit> & String:
  match value:
    case Product.Owner{left,right}:mixed_store_join(~S,~P,right,column(~S,~P,~project,left))
def mixed_resource_join(rest:Unit,observed:Array<U32> & String) -> Product.Owner<Unit,Array<U32>> & String:
  match observed:
    case (array,text):(Product.Owner{rest,array},"product(Unit," ++ text ++ ")")
def mixed_resource(value:Product.Owner<Unit,Array<U32>>) -> Product.Owner<Unit,Array<U32>> & String:
  match value:
    case Product.Owner{left,right}:mixed_resource_join(left,u32_array(right))

def mixed_world_join(~S:Data,~P:Type,~R:Type,~E:Data,~showE:E -> String,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,+events:List<&2,E>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,observedLive:Array<Bool> & String,observedStore:Product.Owner<Col.Column<S,P>,Unit> & String,observedResource:R & String,observedPending:List<(W.World<S,Product.Owner<Col.Column<S,P>,Unit>,R,E> -> W.World<S,Product.Owner<Col.Column<S,P>,Unit>,R,E>)> & Nat) -> W.World<S,Product.Owner<Col.Column<S,P>,Unit>,R,E> & String:
  (live,sl)=observedLive
  (store,ss)=observedStore
  (resource,sr)=observedResource
  (pending,+count)=observedPending
  (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},"namespace=" ++ U32.show(namespace) ++ "|nextId=" ++ U32.show(nextId) ++ "|highWater=" ++ U32.show(highWater) ++ "|live=" ++ sl ++ "|capacity=" ++ U32.show(capacity) ++ "|depth=" ++ Nat.show(depth) ++ "|store=" ++ ss ++ "|resource=" ++ sr ++ "|events=" ++ List.show(&2,E,showE,events) ++ "|pendingCount=" ++ Nat.show(count) ++ "|pendingEmpty=" ++ Bool.show(Nat.is_eq(count,0n)) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ "|nextSystemId=" ++ U32.show(nextSystemId) ++ "|clock=" ++ U32.show(clock))
def mixed_world(~S:Data,~P:Type,~R:Type,~E:Data,~viewP:P -> P & String,~viewR:R -> R & String,~showE:E -> String,value:W.World<S,Product.Owner<Col.Column<S,P>,Unit>,R,E>) -> W.World<S,Product.Owner<Col.Column<S,P>,Unit>,R,E> & String:
  match value:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:mixed_world_join(~S,~P,~R,~E,~showE,namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock,bool_array(live),mixed_store(~S,~P,~viewP,store),viewR(resource),callbacks(~W.World<S,Product.Owner<Col.Column<S,P>,Unit>,R,E>,~W.World<S,Product.Owner<Col.Column<S,P>,Unit>,R,E>,pending))
