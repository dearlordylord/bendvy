import Base
import ./payload.bend as P
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/local.bend as L
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/ordinary-schema.bend as Schema
import ../../../src/ecs/ordinary-resource-system.bend as Resource
import ../../../src/ecs/ordinary-app-local-fields.bend as Ordinary

type Args is Data:
  Args{delta:U32,fail:Bool}
type Error is Data:
  Failed{}
def Ops(H:Type) -> Type:
  Cap.ValueWrite<H,U32,U32>
def outcome(fail:Bool) -> T.Outcome<Error>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{Failed{}}
def updated(~H:Type,~caps:Ops(H),pack:P.Pack,+delta:U32,fail:Bool,result:H & U32) -> H & (P.Pack & (T.Outcome<Error> & Unit)):
  (owner,value) = result
  (Cap.value_set(~H,~U32,~U32,~caps,owner,(value + delta : U32)),(P.update(delta,pack),(outcome(fail),Unit{})))
# Authored body sees only ordinary declared operations, never World or Tx.
def body(~H:Type,~caps:Ops(H),pack:P.Pack,args:Args,owner:H) -> H & (P.Pack & (T.Outcome<Error> & Unit)):
  match args:
    case Args{delta,fail}:updated(~H,~caps,pack,delta,fail,Cap.value_get(~H,~U32,~U32,~caps,owner))
def duplicated(+value:U32) -> U32 & U32:
  (value,value)
def project(value:U32) -> U32 & U32:
  duplicated(value)
def declaration(~S:Data) -> Resource.Declaration<S,U32,T.Tx<W.World<S,Unit,U32,Unit>,Unit>,Ops(T.Tx<W.World<S,Unit,U32,Unit>,Unit>)>:
  Resource.write(~S,~Unit,~U32,~Unit,~U32,~project,Schema.resource(~S,~U32,"Counter"))
def runner(~S:Data,world:W.World<S,Unit,U32,Unit>,pack:P.Pack,args:Args) -> L.Outcome<W.World<S,Unit,U32,Unit>,P.Pack,Error,Unit>:
  Ordinary.runner(~S,~Unit,~U32,~Unit,~P.Pack,~Args,~Error,~Unit,~Ops,~declaration(~S),~body,world,pack,args)
