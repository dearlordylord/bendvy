import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as T

type Schema is Data:
  Schema{}
type Observation is Data:
  Observation{before: U32,id: U32}

def Ops(H: Type) -> Type:
  Cap.Bundle<Cap.ValueWrite<H,Array<U32>,U32>,Cap.Bundle<Cap.ValueRead<H,W.Handle<Schema>>,Cap.Send<H,U32>>>
def project(resource: Array<U32>) -> Array<U32> & U32:
  Array.get(U32,resource,0)
def plan() -> Q.Plan<Schema,Unit,Array<U32>,U32,Ops>:
  Q.Plan{Cap.Bundle{Q.resource_write(~Schema,~Unit,~Array<U32>,~U32,~U32,~project),Cap.Bundle{Q.handle_read(~Schema,~Unit,~Array<U32>,~U32),Q.event_write(~Schema,~Unit,~Array<U32>,~U32)}},Q.all(~Schema,~Unit,~Array<U32>,~U32)}
def decision(fail: Bool) -> T.Outcome<Bool>:
  match fail:
    case True{}: T.Failure{True{}}
    case False{}: T.Success{}
def payload(~H: Type,~caps: Ops(H),fail: Bool,before: U32,observed: H & W.Handle<Schema>) -> H & (T.Outcome<Bool> & Observation):
  match observed:
    case (ctx,W.Handle{_,id}): (Cap.send(~H,~U32,~Cap.second(~Cap.ValueRead<H,W.Handle<Schema>>,~Cap.Send<H,U32>,Cap.second(~Cap.ValueWrite<H,Array<U32>,U32>,~Cap.Bundle<Cap.ValueRead<H,W.Handle<Schema>>,Cap.Send<H,U32>>,caps)),ctx,9),(decision(fail),Observation{before,id}))
def identified(~H: Type,~caps: Ops(H),fail: Bool,observed: H & U32) -> H & (T.Outcome<Bool> & Observation):
  match observed:
    case (ctx,before): payload(~H,~caps,fail,before,Cap.value_read(~H,~W.Handle<Schema>,~Cap.first(~Cap.ValueRead<H,W.Handle<Schema>>,~Cap.Send<H,U32>,Cap.second(~Cap.ValueWrite<H,Array<U32>,U32>,~Cap.Bundle<Cap.ValueRead<H,W.Handle<Schema>>,Cap.Send<H,U32>>,caps)),Cap.value_set(~H,~Array<U32>,~U32,~Cap.first(~Cap.ValueWrite<H,Array<U32>,U32>,~Cap.Bundle<Cap.ValueRead<H,W.Handle<Schema>>,Cap.Send<H,U32>>,caps),ctx,[19 : U32^0n])))
def repeated(~H: Type,~caps: Ops(H),fail: Bool,observed: H & U32) -> H & (T.Outcome<Bool> & Observation):
  match observed:
    case (ctx,_): identified(~H,~caps,fail,Cap.value_get(~H,~Array<U32>,~U32,~Cap.first(~Cap.ValueWrite<H,Array<U32>,U32>,~Cap.Bundle<Cap.ValueRead<H,W.Handle<Schema>>,Cap.Send<H,U32>>,caps),ctx))
def body(~H: Type,~caps: Ops(H),fail: Bool,ctx: H) -> H & (T.Outcome<Bool> & Observation):
  repeated(~H,~caps,fail,Cap.value_get(~H,~Array<U32>,~U32,~Cap.first(~Cap.ValueWrite<H,Array<U32>,U32>,~Cap.Bundle<Cap.ValueRead<H,W.Handle<Schema>>,Cap.Send<H,U32>>,caps),ctx))
def initial() -> W.World<Schema,Unit,Array<U32>,U32>:
  W.World{1,2,2,[True{} : Bool^1n],2,1n,Unit{},[7 : U32^0n],[],[],[],1,0}
def run() -> Q.Executed<W.World<Schema,Unit,Array<U32>,U32>,Q.Error<Bool>,Observation>:
  Q.each(~Schema,~Unit,~Array<U32>,~U32,~Ops,~Bool,~Bool,~Observation,~plan(),~body,False{},initial())

def rows(values: List<&2,Observation>) -> String:
  match values:
    case []: ""
    case Observation{before,id} <> rest: U32.show(before) ++ "@" ++ U32.show(id) ++ "," ++ rows(rest)
def outcome(value: T.Outcome<Q.Error<Bool>>) -> String:
  match value:
    case T.Success{}: "ok"
    case _: "failed"
def resource_report(events: List<&2,U32>,result: T.Outcome<Q.Error<Bool>>,values: List<&2,Observation>,observed: Array<U32> & U32) -> String:
  match observed:
    case (_,value): U32.show(value) ++ "|" ++ Nat.show(List.length(&2,U32,events)) ++ "|" ++ outcome(result) ++ "|" ++ rows(values)
def report(result: Q.Executed<W.World<Schema,Unit,Array<U32>,U32>,Q.Error<Bool>,Observation>) -> String:
  match result:
    case Q.Executed{W.World{_,_,_,_,_,_,_,resource,events,_,_,_,_},result,values}: resource_report(events,result,values,Array.get(U32,resource,0))
def main() -> String:
  report(run())
