import Base
import ./payloads.bend as P
import ./declarations.bend as D
import ./bodies.bend as Body
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/deferred-command.bend as Deferred
import ../common/column-observation.bend as Common

def left_store(~S:Data,store:D.LeftStore(~S)) -> String:
  match store:
    case Product.Owner{column,_}:Common.capacity_done(~S,~P.Position,~P.position,Col.capacity(~S,~P.Position,column))
def left_resource(resource:D.LeftResource()) -> String:
  match resource:
    case Product.Owner{payload,_}:Common.projected(~P.Counter,P.counter(payload))
def right_store(~S:Data,store:D.RightStore(~S)) -> String:
  match store:
    case Product.Owner{column,_}:Common.capacity_done(~S,~P.Health,~P.health,Col.capacity(~S,~P.Health,column))
def right_resource(resource:D.RightResource()) -> String:
  match resource:
    case Product.Owner{payload,_}:Common.projected(~P.Score,P.score(payload))
def stores(~S:Data,store:D.Store(~S)) -> String:
  match store:
    case Product.Owner{left,right}:left_store(~S,left) ++ ";" ++ right_store(~S,right)
def resources(resource:D.Resources()) -> String:
  match resource:
    case Product.Owner{left,right}:left_resource(left) ++ ";" ++ right_resource(right)
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Common.key(key)
def observed(~S:Data,result:W.World<S,D.Store(~S),D.Resources(),Unit> & List<&2,W.Handle<S>>) -> String:
  match result:
    case (W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock},live):stores(~S,store) ++ ";" ++ resources(resource) ++ ";live=" ++ List.show(&2,W.Handle<S>,handle(~S),live) ++ ";systems=" ++ List.show(&2,W.RegistrationMeta,Common.registration,registrations) ++ ";tick=" ++ Common.clock(clock) ++ ";allocator=" ++ Common.allocator(allocator) ++ ";namespace=" ++ U32.show(namespace) ++ ";next-system=" ++ U32.show(next) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<S,D.Store(~S),D.Resources(),Unit>>,pending))
def world(~S:Data,value:W.World<S,D.Store(~S),D.Resources(),Unit>) -> String:
  observed(~S,W.handles(~S,~D.Store(~S),~D.Resources(),~Unit,value))
def local_observed(runs:U32,result:Array<U32> & U32) -> String:
  match result:
    case (_,id):U32.show(id) ++ ":" ++ U32.show(runs)
def local(~S:Data,value:Body.Local<S>) -> String:
  match value:
    case Body.Local{token,runs,_}:local_observed(runs,Array.get(U32,token,0))
