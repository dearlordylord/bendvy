import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as S
type Schema is Data:
  Schema{}
type Error is Data:
  Error{}
def empty(u: Unit) -> Unit:
  Unit{}
def plus(+v: U32) -> U32 & U32:
  ((v + 1 : U32),v)
def done(result: W.World<Schema,Unit,U32,U32> & U32) -> S.Outcome<W.World<Schema,Unit,U32,U32>,Error,Unit>:
  (world,old) = result
  S.Succeeded{world,Unit{}}
def body(world: W.World<Schema,Unit,U32,U32>,args: Unit) -> S.Outcome<W.World<Schema,Unit,U32,U32>,Error,Unit>:
  done(W.observe_resource(~Schema,~Unit,~U32,~U32,~U32,~(x => plus(x)),world))
def project(+v: U32) -> U32 & U32:
  (v,v)
def value(result: W.World<Schema,Unit,U32,U32> & U32) -> U32:
  (world,v) = result
  v
def final_outcome(outcome: S.Outcome<W.World<Schema,Unit,U32,U32>,Error,Unit>) -> U32:
  match outcome:
    case S.Failed{_,_}: 999
    case S.Succeeded{world,_}: value(W.observe_resource(~Schema,~Unit,~U32,~U32,~U32,~(x => project(x)),world))
def final(result: S.RunResult<Schema,Unit,U32,U32,Unit,Error,Unit,body>) -> U32:
  match result:
    case S.RegistrationRejected{_,_,_}: 998
    case S.Completed{_,outcome}: final_outcome(outcome)
def second_outcome(registry: S.Registry<Schema,Unit,U32,U32,Unit,Error,Unit,body>,outcome: S.Outcome<W.World<Schema,Unit,U32,U32>,Error,Unit>) -> U32:
  match outcome:
    case S.Failed{_,_}: 997
    case S.Succeeded{world,_}: final(S.run_to_cursor(~Schema,~Unit,~U32,~U32,~Unit,~Error,~Unit,~body,registry,world,Unit{},2))
def second(result: S.RunResult<Schema,Unit,U32,U32,Unit,Error,Unit,body>) -> U32:
  match result:
    case S.RegistrationRejected{_,_,_}: 996
    case S.Completed{registry,outcome}: second_outcome(registry,outcome)
def registered(result: S.RegistrationResult<Schema,Unit,U32,U32,Unit,Error,Unit,body>) -> U32:
  match result:
    case S.RegistrationFailed{_}: 995
    case S.Registered{world,registry}: second(S.run(~Schema,~Unit,~U32,~U32,~Unit,~Error,~Unit,~body,S.Registry{1,999,"user",["resource.write"],0},world,Unit{}))
def created(result: W.Creation<Schema,Unit,U32,U32>) -> U32:
  match result:
    case W.CreateRejected{_,_}: 994
    case W.Created{_,world}: registered(S.register(~Schema,~Unit,~U32,~U32,~Unit,~Error,~Unit,~body,world,"user",["resource.write"]))
def main() -> U32:
  created(W.create(~Schema,~Unit,~U32,~U32,~empty,W.factory(),0))
