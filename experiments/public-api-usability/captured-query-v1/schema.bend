import Base
import ../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../public-audit61/app-a-current-carrier-v1/owner-observer.bend as Dump
import ../../public-audit61/app-a-current-carrier-v1/allocator-observer.bend as Gen
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../src/ecs/ordinary-schema.bend as Schema
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as Tx
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/entity-allocator.bend as Alloc
import ../../../src/ecs/deferred-command.bend as Deferred

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
type Token is Data:Token{}
def Store(~S:Data) -> Type:Col.Column<S,Array<U32>>
def World(~S:Data) -> Type:W.World<S,Store(~S),Unit,Unit>
def empty(~S:Data,_:Unit) -> Store(~S):Col.empty(~S,~Array<U32>)
def take(~S:Data,value:Store(~S)) -> Unit & Store(~S):(Unit{},value)
def put(~S:Data,_:Unit,value:Store(~S)) -> Store(~S):value
def identity(~S:Data) -> Identity.Declaration<S,Array<U32>>:Identity.component(~S,~Array<U32>,"Cells")
def binding(~S:Data) -> Binding.Binding<S,Store(~S),Unit,Array<U32>,P.Tree,Token,take(~S),put(~S),P.observe>:Binding.bind(~S,~Store(~S),~Unit,~Array<U32>,~P.Tree,~Token,~take(~S),~put(~S),~P.observe,identity(~S))
def family(~S:Data) -> C.Family<S,Store(~S),Unit,Array<U32>,P.Tree,Token,take(~S),put(~S),P.observe>:C.Family{Identity.key(~S,~Array<U32>,identity(~S))}
def schema(~S:Data) -> Schema.Schema<S,Store(~S),Unit>:Schema.component(~S,~Array<U32>,identity(~S))
def cells(+start:U32) -> Array<U32>:ANode{ANode{ALeaf{start},ALeaf{U32.add(start,1)}},ANode{ALeaf{U32.add(start,2)},ALeaf{U32.add(start,3)}}}
def populated(~S:Data,result:C.Replacement<World(~S),Array<U32>>) -> World(~S):
  match result:
    case C.Replaced{world,_}:world
    case C.ReplaceRejected{world,_,_}:world
def populate(~S:Data,world:World(~S),handle:W.Handle<S>,value:Array<U32>) -> World(~S):populated(~S,C.replace(~S,~Store(~S),~Unit,~Unit,~Unit,~Array<U32>,~P.Tree,~Token,~take(~S),~put(~S),~P.observe,family(~S),world,handle,Some{value}))
def finished(~S:Data,result:Tx.Returned<World(~S),Unit>) -> World(~S):
  match result:
    case Tx.Returned{world,_}:W.barrier(~S,~Store(~S),~Unit,~Unit,world)
def second(~S:Data,result:Tx.Tx<World(~S),Unit> & W.Reservation<S>) -> World(~S):
  match result:
    case (tx,_):finished(~S,Cmd.tx_finish(~S,~Store(~S),~Unit,~Unit,~Unit,tx,Tx.Success{}))
def first(~S:Data,result:Tx.Tx<World(~S),Unit> & W.Reservation<S>) -> World(~S):
  match result:
    case (tx,_):second(~S,Cmd.tx_spawn(~S,~Store(~S),~Unit,~Unit,~Array<U32>,~populate(~S),tx,cells(1)))
def seed(~S:Data,world:World(~S)) -> World(~S):first(~S,Cmd.tx_spawn(~S,~Store(~S),~Unit,~Unit,~Array<U32>,~populate(~S),Tx.begin(~World(~S),~Unit,world),cells(0)))
def world_join(~S:Data,+ns:U32,resource:Unit,+events:List<&2,Unit>,+registrations:List<&2,W.RegistrationMeta>,+next:U32,+clock:U32,a:Alloc.Allocator & String,c:Store(~S) & String,p:List<Deferred.Command<World(~S)>> & (Nat & String)) -> World(~S) & String:
  match a c p:
    case (allocator,at),(column,ct),(pending,(n,pt)):(W.World{ns,allocator,column,resource,events,pending,registrations,next,clock},"namespace=" ++ U32.show(ns) ++ "|allocator={" ++ at ++ "}|store={" ++ ct ++ "}|resource=Unit|events=" ++ List.show(&2,Unit,_=>"Unit",events) ++ "|pending=" ++ Nat.show(n) ++ ":" ++ pt ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,registrations) ++ "|nextSystem=" ++ U32.show(next) ++ "|clock=" ++ U32.show(clock))
def observe(~S:Data,value:World(~S)) -> World(~S) & String:
  match value:
    case W.World{ns,allocator,column,resource,events,pending,registrations,next,clock}:world_join(~S,ns,resource,events,registrations,next,clock,Gen.allocator(allocator),Dump.column(~S,~Array<U32>,~Dump.u32_array,column),Dump.callbacks(~World(~S),~World(~S),pending))
