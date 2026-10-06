import Base
import full-functional.bend as F
import ../../src/ecs/component.bend as C
import ../../src/ecs/provider.bend as Pv
import ../../src/ecs/query.bend as Q
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T

def after_second(~H: Type,~get: H -> H & C.Access<U32>,~aux: H -> H & C.Access<U32>,~resource_get: H -> H & U32,first: U32,observed: H & C.Access<U32>) -> H & U32:
  match observed:
    case (ctx,C.Found{second}): (ctx,(first + second : U32))
    case (ctx,_): (ctx,997)
def after_first(~H: Type,~get: H -> H & C.Access<U32>,~aux: H -> H & C.Access<U32>,~resource_get: H -> H & U32,observed: H & C.Access<U32>) -> H & U32:
  match observed:
    case (ctx,C.Found{first}): after_second(~H,~get,~aux,~resource_get,first,get(ctx))
    case (ctx,_): (ctx,998)
def reader(~H: Type,~get: H -> H & C.Access<U32>,~aux: H -> H & C.Access<U32>,~resource_get: H -> H & U32,args: Bool,handle: W.Handle<F.Game>,ctx: H) -> H & U32:
  after_first(~H,~get,~aux,~resource_get,get(ctx))
def values(result: F.World() & List<&2,U32>) -> List<&2,U32>:
  match result:
    case (_,values): values
def main() -> List<&2,U32>:
  values(Q.each_read(~F.Game,~F.Store,~F.Res,~F.GameEvent,~Unit,~F.Cell,~U32,~F.Token,~F.take,~F.put,~F.project,~Unit,~F.Cell,~U32,~F.Token,~F.take,~F.put,~F.project,~U32,~F.resource_project,~F.Cell,~F.populate,~F.clear,~Bool,~U32,~reader,F.family(),F.family(),Q.Optional{},F.initial(),False{}))
