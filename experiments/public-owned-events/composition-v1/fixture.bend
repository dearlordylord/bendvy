import Base
import ../ordinary-v1/payload.bend as Payload
import ../../../src/ecs/ordinary-owned-event-query.bend as O
import ../../../src/ecs/ordinary-owned-event.bend as Pub
import ../../../src/ecs/ordinary-owned-event-resource.bend as Res
import ../../../src/ecs/owned-event-storage.bend as Storage
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/ordinary-query-declaration.bend as D
import ../../../src/ecs/ordinary-declaration.bend as I
import ../../../src/ecs/ordinary-schema.bend as Schema
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys

type Token is Data:Token{}
type Args is Data:Args{delta:U32,failValue:U32}
type Error is Data:
  FailedAt{value:U32}
  Missing{}
def view(value:U32) -> U32 & U32:
  +copy=value
  (copy,copy)
def take(~S:Data,column:Col.Column<S,U32>) -> Unit & Col.Column<S,U32>:(Unit{},column)
def put(~S:Data,unit:Unit,column:Col.Column<S,U32>) -> Col.Column<S,U32>:column
def identity(~S:Data) -> I.Declaration<S,U32>:I.component(~S,~U32,"Value")
def domain(~S:Data) -> Pub.Domain<S,Array<U32>>:Pub.domain(~S,~Array<U32>,"Cargo")
def counter(~S:Data) -> Schema.Resource<S,U32>:Schema.resource(~S,~U32,"Counter")
def Ops(H:Type) -> Type:Cap.Write<H,U32,U32> & Cap.ValueWrite<H,U32,U32>
def component(~S:Data) -> D.Declaration<S,Q.Frame<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>,Cap.Write<Q.Frame<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>,U32,U32>>:
  D.write(~S,~U32,~Col.Column<S,U32>,~Storage.Resources<U32,Array<U32>>,~Nat,~Unit,~U32,~Token,~identity(~S),~view,~take(~S),~put(~S))
def resource(~S:Data) -> D.Declaration<S,Q.Frame<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>,Cap.ValueWrite<Q.Frame<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>,U32,U32>>:
  Res.write(~S,~Col.Column<S,U32>,~U32,~Array<U32>,~U32,~counter(~S),~view)
def query(~S:Data) -> D.Declaration<S,Q.Frame<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>,Ops(Q.Frame<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>)>:
  D.pair(~S,~Q.Frame<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>,~Cap.Write<Q.Frame<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>,U32,U32>,~Cap.ValueWrite<Q.Frame<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>,U32,U32>,~component(~S),~resource(~S))
def decision(fail:Bool,value:U32) -> T.Outcome<Error>:
  match fail:
    case True{}:T.Failure{FailedAt{value}}
    case False{}:T.Success{}
def counted(~S:Data,~H:Type,~caps:Ops(H),~J:Type,~emit:Pub.Write<S,Array<U32>,domain(~S),J>,+value:U32,args:Args,stage:J,result:H & U32) -> H & (J & (T.Outcome<Error> & U32)):
  match args result:
    case Args{+delta,+failValue}, (owner,n):
      (Cap.value_set(~H,~U32,~U32,~Pair.snd(Cap.Write<H,U32,U32>,Cap.ValueWrite<H,U32,U32>,caps),Cap.set(~H,~U32,~U32,~Pair.fst(Cap.Write<H,U32,U32>,Cap.ValueWrite<H,U32,U32>,caps),owner,(value + delta : U32)),(n + 1 : U32)),(Pub.emit(~S,~Array<U32>,~domain(~S),~J,~emit,stage,ANode{ALeaf{value},ALeaf{delta}}),(decision(U32.is_eq(value,failValue),value),value)))
def got(~S:Data,~H:Type,~caps:Ops(H),~J:Type,~emit:Pub.Write<S,Array<U32>,domain(~S),J>,args:Args,stage:J,result:H & C.Access<U32>) -> H & (J & (T.Outcome<Error> & U32)):
  match result:
    case (owner,C.Found{value}):counted(~S,~H,~caps,~J,~emit,value,args,stage,Cap.value_get(~H,~U32,~U32,~Pair.snd(Cap.Write<H,U32,U32>,Cap.ValueWrite<H,U32,U32>,caps),owner))
    case (owner,_):(owner,(stage,(T.Failure{Missing{}},0)))
def body(~S:Data,~H:Type,~caps:Ops(H),~J:Type,~emit:Pub.Write<S,Array<U32>,domain(~S),J>,args:Args,owner:H,stage:J) -> H & (J & (T.Outcome<Error> & U32)):
  got(~S,~H,~caps,~J,~emit,args,stage,Cap.get(~H,~U32,~U32,~Pair.fst(Cap.Write<H,U32,U32>,Cap.ValueWrite<H,U32,U32>,caps),owner))
def World(~S:Data) -> Type:W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>
def Registry(~S:Data) -> Type:O.Registry(~S,~Col.Column<S,U32>,~U32,~Array<U32>,~domain(~S),~Ops,~Args,~Error,~U32,~query(~S),~body(~S))
def define(~S:Data,world:W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>) -> Sys.RegistrationResult<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat,Args & U32,Unit,Pub.Reply<Q.Error<Error>,List<&2,U32>,Array<U32>>,O.runner(~S,~Col.Column<S,U32>,~U32,~Array<U32>,~domain(~S),~Ops,~Args,~Error,~U32,~query(~S),~body(~S))>:
  O.define(~S,~Col.Column<S,U32>,~U32,~Array<U32>,~domain(~S),~Ops,~Args,~Error,~U32,~query(~S),~body(~S),world,"query-publisher")
def run(~S:Data,registry:Registry(~S),world:World(~S),args:Args) -> Sys.RunResult<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat,Args & U32,Unit,Pub.Reply<Q.Error<Error>,List<&2,U32>,Array<U32>>,O.runner(~S,~Col.Column<S,U32>,~U32,~Array<U32>,~domain(~S),~Ops,~Args,~Error,~U32,~query(~S),~body(~S))>:
  O.run(~S,~Col.Column<S,U32>,~U32,~Array<U32>,~domain(~S),~Ops,~Args,~Error,~U32,~query(~S),~body(~S),registry,world,args)
def empty(~S:Data,unit:Unit) -> Col.Column<S,U32>:
  Col.empty(~S,~U32)
def activated(~S:Data,result:W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat> & W.Status) -> W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>:
  match result:
    case (world,_):world
def spawned(~S:Data,result:W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat> & W.Reservation<S>) -> W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>:
  match result:
    case (world,W.Reserved{handle}): activated(~S,W.activate(~S,~Col.Column<S,U32>,~Storage.Resources<U32,Array<U32>>,~Nat,world,handle))
    case (world,_):world
def spawn(~S:Data,world:W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>) -> W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>:
  spawned(~S,W.reserve_id(~S,~Col.Column<S,U32>,~Storage.Resources<U32,Array<U32>>,~Nat,world))
def replaced(~S:Data,result:C.Replacement<W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>,U32>) -> W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>:
  match result:
    case C.Replaced{world,_}:world
    case C.ReplaceRejected{world,_,_}:world
def populated(~S:Data,id:U32,value:U32,named:W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat> & U32) -> W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>:
  (world,ns) = named
  replaced(~S,C.replace(~S,~Col.Column<S,U32>,~Storage.Resources<U32,Array<U32>>,~Nat,~Unit,~U32,~U32,~Token,~take(~S),~put(~S),~view,C.Family{"Value"},world,W.Handle{ns,id},Some{value}))
def populate(~S:Data,world:W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>,id:U32,value:U32) -> W.World<S,Col.Column<S,U32>,Storage.Resources<U32,Array<U32>>,Nat>:
  populated(~S,id,value,W.namespace(~S,~Col.Column<S,U32>,~Storage.Resources<U32,Array<U32>>,~Nat,world))

def resources() -> Storage.Resources<U32,Array<U32>>:Storage.Resources{100,Log.empty(~Array<U32>)}
