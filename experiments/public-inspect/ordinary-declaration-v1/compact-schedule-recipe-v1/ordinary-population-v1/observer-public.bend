import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import ./setup-public.bend as Setup
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/consumer/owner-observer.bend as O
def store_join(~S:Data,~P:Type,rest:Unit,left:Col.Column<S,P> & String,right:Col.Column<S,P> & String) -> Setup.store(~S,~P) & String:
  (a,sa)=left
  (b,sb)=right
  (Product.Owner{a,Product.Owner{b,rest}},"product(" ++ sa ++ ",product(" ++ sb ++ ",Unit))")
def observed_store(~S:Data,~P:Type,~view:P -> P & String,value:Setup.store(~S,~P)) -> Setup.store(~S,~P) & String:
  match value:
    case Product.Owner{a,Product.Owner{b,rest}}:store_join(~S,~P,rest,O.column(~S,~P,~view,a),O.column(~S,~P,~view,b))
def resource_join(rest:Unit,result:Product.Owner<Unit,Array<U32>> & String) -> Setup.resources(~Array<U32>) & String:
  match result:
    case (right,text):(Product.Owner{rest,right},"product(Unit," ++ text ++ ")")
def resource(value:Setup.resources(~Array<U32>)) -> Setup.resources(~Array<U32>) & String:
  match value:
    case Product.Owner{left,right}:resource_join(left,O.mixed_resource(right))
def mixed_world_join(~S:Data,~P:Type,~R:Type,~E:Data,~showE:E -> String,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,+events:List<&2,E>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,observedLive:Array<Bool> & String,observedStore:Setup.store(~S,~P) & String,observedResource:R & String,observedPending:List<(W.World<S,Setup.store(~S,~P),R,E> -> W.World<S,Setup.store(~S,~P),R,E>)> & Nat) -> W.World<S,Setup.store(~S,~P),R,E> & String:
  (live,sl)=observedLive
  (store,ss)=observedStore
  (resource,sr)=observedResource
  (pending,+count)=observedPending
  (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},"namespace=" ++ U32.show(namespace) ++ "|nextId=" ++ U32.show(nextId) ++ "|highWater=" ++ U32.show(highWater) ++ "|live=" ++ sl ++ "|capacity=" ++ U32.show(capacity) ++ "|depth=" ++ Nat.show(depth) ++ "|store=" ++ ss ++ "|resource=" ++ sr ++ "|events=" ++ List.show(&2,E,showE,events) ++ "|pendingCount=" ++ Nat.show(count) ++ "|pendingEmpty=" ++ Bool.show(Nat.is_eq(count,0n)) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,O.registration,registrations) ++ "|nextSystemId=" ++ U32.show(nextSystemId) ++ "|clock=" ++ U32.show(clock))
def mixed_world(~S:Data,~P:Type,~R:Type,~E:Data,~viewP:P -> P & String,~viewR:R -> R & String,~showE:E -> String,value:W.World<S,Setup.store(~S,~P),R,E>) -> W.World<S,Setup.store(~S,~P),R,E> & String:
  match value:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:mixed_world_join(~S,~P,~R,~E,~showE,namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock,O.bool_array(live),observed_store(~S,~P,~viewP,store),viewR(resource),O.callbacks(~W.World<S,Setup.store(~S,~P),R,E>,~W.World<S,Setup.store(~S,~P),R,E>,pending))
