import Base
import ./payloads.bend as P
import ./declarations.bend as D
import ./body.bend as Body
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/deferred-command.bend as Deferred
import ../../test-fixtures/common/column-observation.bend as Common

def store(~S:Data,value:D.Store(~S)) -> String:
  match value:
    case Product.Owner{Layout.ColumnSlot{position},Layout.ColumnSlot{label}}:"positions=" ++ Common.capacity_done(~S,~P.Position,~P.position,Col.capacity(~S,~P.Position,position)) ++ ";labels=" ++ Common.capacity_done(~S,~P.Label,~P.label,Col.capacity(~S,~P.Label,label))
def resources(~S:Data,value:D.Resources(~S)) -> String:
  match value:
    case Product.Owner{Layout.ResourceSlot{counter},Layout.ResourceSlot{secret}}:"counter=" ++ Common.projected(~P.Counter,P.counter(counter)) ++ ";secret=" ++ Common.projected(~P.Secret,P.secret(secret))
def world(~S:Data,value:W.World<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match value:
    case W.World{namespace,allocator,components,resource,events,pending,registrations,next,clock}:"namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ Common.allocator(allocator) ++ "};" ++ store(~S,components) ++ ";" ++ resources(~S,resource) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<S,D.Store(~S),D.Resources(~S),Unit>>,pending)) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Common.registration,registrations) ++ ";next-system=" ++ U32.show(next) ++ ";clock=" ++ Common.clock(clock)
def local_token(runs:U32,handle:String,result:Array<U32> & U32) -> String:
  match result:
    case (_,id):U32.show(id) ++ ":" ++ U32.show(runs) ++ ":" ++ handle
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Common.key(key)
def local(~S:Data,value:Body.Local<S>) -> String:
  match value:
    case Body.Local{token,runs,entity}:local_token(runs,handle(~S,entity),Array.get(U32,token,0))
def system(namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>) -> String:
  "namespace=" ++ U32.show(namespace) ++ ",id=" ++ U32.show(id) ++ ",name=" ++ name ++ ",access=" ++ List.show(&2,String,value=>value,access) ++ ",cursor=" ++ Tick.cursor_show(cursor)
