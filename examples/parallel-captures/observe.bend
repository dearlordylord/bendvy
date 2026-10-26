import Base
import ../../src/ecs/execution-composer-layout.bend as Layout
import ./payloads.bend as P
import ./declarations.bend as D
import ./bodies.bend as Body
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/deferred-command.bend as Deferred
import ../../test-fixtures/common/column-observation.bend as Common

def inspected(~P:Type,+cache:String,result:P & String) -> Layout.Viewed<P,String> & String:
  match result:
    case (owner,value):(Layout.Viewed{owner,cache},value ++ "/cache=" ++ cache)
def inspect(~P:Type,~project:P -> P & String,value:Layout.Viewed<P,String>) -> Layout.Viewed<P,String> & String:
  match value:
    case Layout.Viewed{owner,cache}:inspected(~P,cache,project(owner))
def left_resource(~S:Data,resource:D.LeftResource(~S)) -> String:
  match resource:
    case Layout.ResourceSlot{payload}:Common.projected(~Layout.Viewed<P.Counter,String>,inspect(~P.Counter,~P.counter,payload))
def right_resource(~S:Data,resource:D.RightResource(~S)) -> String:
  match resource:
    case Layout.ResourceSlot{payload}:Common.projected(~Layout.Viewed<P.Score,String>,inspect(~P.Score,~P.score,payload))
def resources(~S:Data,resource:D.Resources(~S)) -> String:
  match resource:
    case Product.Owner{left,right}:left_resource(~S,left) ++ ";" ++ right_resource(~S,right)
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Common.key(key)
def observed(~S:Data,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & List<&2,W.Handle<S>>) -> String:
  match result:
    case (W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock,lifecycle},live):resources(~S,resource) ++ ";live=" ++ List.show(&2,W.Handle<S>,handle(~S),live) ++ ";systems=" ++ List.show(&2,W.RegistrationMeta,Common.registration,registrations) ++ ";tick=" ++ Common.clock(clock) ++ ";allocator=" ++ Common.allocator(allocator) ++ ";namespace=" ++ U32.show(namespace) ++ ";next-system=" ++ U32.show(next) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<S,D.Store(~S),D.Resources(~S),Unit>>,pending))
def world(~S:Data,value:W.World<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  observed(~S,W.handles(~S,~D.Store(~S),~D.Resources(~S),~Unit,value))
