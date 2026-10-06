import Base
import full-functional.bend as F
import ../../src/ecs/component.bend as C
import ../../src/ecs/provider.bend as Pv
import ../../src/ecs/query.bend as Q
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T

def checked(~H: Type,~get: H -> H & C.Access<U32>,~set: H -> F.Cell -> H,~aux: H -> H & C.Access<U32>,~resource_get: H -> H & U32,observed: H & C.Access<U32>) -> H & T.Outcome<F.CanaryError>:
  match observed:
    case (ctx,C.Found{208}): (ctx,T.Success{})
    case (ctx,_): (ctx,T.Failure{F.CanaryRejected{}})
def repeated(~H: Type,~get: H -> H & C.Access<U32>,~set: H -> F.Cell -> H,~aux: H -> H & C.Access<U32>,~resource_get: H -> H & U32,observed: H & C.Access<U32>) -> H & T.Outcome<F.CanaryError>:
  match observed:
    case (ctx,C.Found{208}): checked(~H,~get,~set,~aux,~resource_get,get(ctx))
    case (ctx,_): (ctx,T.Failure{F.CanaryRejected{}})
def before(~H: Type,~get: H -> H & C.Access<U32>,~set: H -> F.Cell -> H,~aux: H -> H & C.Access<U32>,~resource_get: H -> H & U32,observed: H & C.Access<U32>) -> H & T.Outcome<F.CanaryError>:
  match observed:
    case (ctx,C.Found{107}): repeated(~H,~get,~set,~aux,~resource_get,get(set(ctx,F.Cell{[8 : U32^1n],2})))
    case (ctx,_): (ctx,T.Failure{F.CanaryRejected{}})
def body(~H: Type,~get: H -> H & C.Access<U32>,~set: H -> F.Cell -> H,~aux: H -> H & C.Access<U32>,~resource_get: H -> H & U32,args: Bool,handle: W.Handle<F.Game>,ctx: H) -> H & T.Outcome<F.CanaryError>:
  before(~H,~get,~set,~aux,~resource_get,get(ctx))
def main() -> List<&2,U32>:
  F.finished(Q.each_rw_read_resource(~F.Game,~F.Store,~F.Res,~F.GameEvent,~Unit,~F.Cell,~U32,~F.Token,~F.take,~F.put,~F.project,~Unit,~F.Cell,~U32,~F.Token,~F.take,~F.put,~F.project,~U32,~F.resource_project,~F.Cell,~F.populate,~F.clear,~Bool,~F.CanaryError,~body,F.family(),F.family(),Q.Optional{},F.initial(),False{}))
