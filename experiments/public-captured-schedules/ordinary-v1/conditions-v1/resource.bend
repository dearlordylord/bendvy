import Base
import ./state.bend as State
import ../../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/ordinary-captures.bend as Entry
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/local.bend as L
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/ordinary-resource-system.bend as Resource
import ../../../../src/ecs/ordinary-app-local-fields.bend as Ordinary

type Args is Data:
  Args{delta:U32,fail:Bool}
type Error is Data:
  Failed{}
def Ops(~S:Data,H:Type) -> Type:
  Cap.ValueWrite<H,State.Resources<S>,State.Resources<S>>
def outcome(fail:Bool) -> T.Outcome<Error>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{Failed{}}
def changed_returned(~S:Data,delta:U32,result:State.Resources<S> & U32) -> State.Resources<S>:
  (resources,value) = result
  State.counter_write(~S,resources,(value + delta : U32))
def changed(~S:Data,resources:State.Resources<S>,delta:U32) -> State.Resources<S>:
  changed_returned(~S,delta,State.counter_read(~S,resources))
def updated(~S:Data,~H:Type,~caps:Ops(~S,H),pack:Array<U32>,+delta:U32,fail:Bool,result:H & State.Resources<S>) -> H & (Array<U32> & (T.Outcome<Error> & Unit)):
  (owner,resources) = result
  (Cap.value_set(~H,~State.Resources<S>,~State.Resources<S>,~caps,owner,changed(~S,resources,delta)),(P.increment(delta,pack),(outcome(fail),Unit{})))
def body(~S:Data,~H:Type,~caps:Ops(~S,H),pack:Array<U32>,args:Args,owner:H) -> H & (Array<U32> & (T.Outcome<Error> & Unit)):
  match args:
    case Args{delta,fail}:updated(~S,~H,~caps,pack,delta,fail,Cap.value_get(~H,~State.Resources<S>,~State.Resources<S>,~caps,owner))
def duplicated(~S:Data,+value:State.Resources<S>) -> State.Resources<S> & State.Resources<S>:
  (value,value)
def project(~S:Data,value:State.Resources<S>) -> State.Resources<S> & State.Resources<S>:
  duplicated(~S,value)
def declaration(~S:Data) -> Resource.Declaration<S,State.Resources<S>,T.Tx<W.World<S,Col.Column<S,U32>,State.Resources<S>,Unit>,Unit>,Ops(~S,T.Tx<W.World<S,Col.Column<S,U32>,State.Resources<S>,Unit>,Unit>)>:
  Resource.write(~S,~Col.Column<S,U32>,~State.Resources<S>,~Unit,~State.Resources<S>,~project(~S),Schema.resource(~S,~State.Resources<S>,"Counter"))
def Instance(~S:Data) -> Type:
  L.Instance<S,Col.Column<S,U32>,State.Resources<S>,Unit,Array<U32>,Args,Error,Unit,Ordinary.runner(~S,~Col.Column<S,U32>,~State.Resources<S>,~Unit,~Array<U32>,~Args,~Error,~Unit,~Ops(~S),~declaration(~S),~body(~S))>
def define(~S:Data,world:W.World<S,Col.Column<S,U32>,State.Resources<S>,Unit>) -> L.Registered<S,Col.Column<S,U32>,State.Resources<S>,Unit,Array<U32>,Args,Error,Unit,Ordinary.runner(~S,~Col.Column<S,U32>,~State.Resources<S>,~Unit,~Array<U32>,~Args,~Error,~Unit,~Ops(~S),~declaration(~S),~body(~S))>:
  Entry.define(~S,~Col.Column<S,U32>,~State.Resources<S>,~Unit,~Array<U32>,~Args,~Error,~Unit,~Ops(~S),~declaration(~S),~body(~S),world,"resource-counter",ANode{ALeaf{100},ALeaf{101}})
