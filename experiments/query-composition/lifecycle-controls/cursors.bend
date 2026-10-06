import Base
import ../../../examples/user-simulation/schema.bend as S
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/lifecycle.bend as L
import ../../../src/ecs/system.bend as Sys
import stamps.bend as A

def reader_outcome(fail: Bool,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,output: Bool) -> Sys.Outcome<W.World<S.Schema,S.Store,F32,S.SimEvent>,U32,Bool>:
  match fail:
    case False{}: Sys.Succeeded{world,output}
    case True{}: Sys.Failed{A.failure(world,handle),1}
def reader_observed(+handle: W.Handle<S.Schema>,cursor: U32,fail: Bool,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & L.Stamp) -> Sys.Outcome<W.World<S.Schema,S.Store,F32,S.SimEvent>,U32,Bool>:
  (world,stamp) = observed
  reader_outcome(fail,world,handle,L.changed(stamp,cursor))
def reader_args(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,rest: U32 & Bool) -> Sys.Outcome<W.World<S.Schema,S.Store,F32,S.SimEvent>,U32,Bool>:
  (cursor,fail) = rest
  reader_observed(handle,cursor,fail,A.stamp(world,handle))
def reader(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,args: (W.Handle<S.Schema> & (U32 & Bool))) -> Sys.Outcome<W.World<S.Schema,S.Store,F32,S.SimEvent>,U32,Bool>:
  (handle,rest) = args
  reader_args(world,handle,rest)
def run_clock(registry: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+cursor: U32,fail: Bool,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & U32) -> Sys.RunResult<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>:
  (world,+clock) = observed
  Sys.run_to_cursor(~S.Schema,~S.Store,~F32,~S.SimEvent,~(W.Handle<S.Schema> & (U32 & Bool)),~U32,~Bool,~reader,registry,world,(handle,(cursor,fail)),clock)
def run_reader(registry: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,fail: Bool) -> Sys.RunResult<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>:
  match registry:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}: run_clock(Sys.Registry{namespace,id,name,access,cursor},handle,cursor,fail,W.clock(~S.Schema,~S.Store,~F32,~S.SimEvent,world))
def outcome_check(outcome: Sys.Outcome<W.World<S.Schema,S.Store,F32,S.SimEvent>,U32,Bool>,+expected: Bool,expectedFail: Bool) -> W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool:
  match outcome:
    case Sys.Failed{world,_}: (world,expectedFail)
    case Sys.Succeeded{world,+actual}: (world,Bool.not(expectedFail) && Bool.or(Bool.and(actual,expected),Bool.and(Bool.not(actual),Bool.not(expected))))
def join_check(registry: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,valid: Bool,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool) -> Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool):
  (world,okay) = observed
  (registry,(world,Bool.and(valid,okay)))
def registry_check(registry: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,outcome: Sys.Outcome<W.World<S.Schema,S.Store,F32,S.SimEvent>,U32,Bool>,+expected: Bool,expectedFail: Bool,expectedCursor: U32) -> Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool):
  match registry:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}: join_check(Sys.Registry{namespace,id,name,access,cursor},U32.is_eq(cursor,expectedCursor),outcome_check(outcome,expected,expectedFail))
def checked(result: Sys.RunResult<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+expected: Bool,expectedFail: Bool,expectedCursor: U32) -> Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool):
  match result:
    case Sys.RegistrationRejected{registry,world,_}: (registry,(world,False{}))
    case Sys.Completed{registry,outcome}: registry_check(registry,outcome,expected,expectedFail,expectedCursor)

def stage6_rest(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool) -> String:
  (world,okay) = observed
  +result = String.append("A-repeat-after-retry:",String.append(A.bool_string(okay),";"))
  String.append(prior,result)
def stage6_join(b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool)) -> String:
  (a,rest) = observed
  stage6_rest(a,b,handle,prior,rest)
def stage6(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage6_join(b,handle,prior,checked(run_reader(a,world,handle,False{}),False{},False{},5))

def stage5_rest(b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool) -> String:
  (world,okay) = observed
  +result = String.append("B-later:",String.append(A.bool_string(okay),";"))
  stage6(a,b,world,handle,String.append(prior,result))
def stage5_join(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool)) -> String:
  (b,rest) = observed
  stage5_rest(b,a,handle,prior,rest)
def stage5(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage5_join(a,handle,prior,checked(run_reader(b,world,handle,False{}),True{},False{},5))

def stage4_rest(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool) -> String:
  (world,okay) = observed
  +result = String.append("A-retry:",String.append(A.bool_string(okay),";"))
  stage5(a,b,world,handle,String.append(prior,result))
def stage4_join(b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool)) -> String:
  (a,rest) = observed
  stage4_rest(a,b,handle,prior,rest)
def stage4(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage4_join(b,handle,prior,checked(run_reader(a,world,handle,False{}),True{},False{},5))

def stage3_rest(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool) -> String:
  (world,okay) = observed
  +result = String.append("A-failure:",String.append(A.bool_string(okay),";"))
  stage4(a,b,world,handle,String.append(prior,result))
def stage3_join(b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool)) -> String:
  (a,rest) = observed
  stage3_rest(a,b,handle,prior,rest)
def stage3(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  world = A.write(world,handle)
  stage3_join(b,handle,prior,checked(run_reader(a,world,handle,True{}),True{},True{},1))

def stage2_rest(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool) -> String:
  (world,okay) = observed
  +result = String.append("A-repeat:",String.append(A.bool_string(okay),";"))
  stage3(a,b,world,handle,String.append(prior,result))
def stage2_join(b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool)) -> String:
  (a,rest) = observed
  stage2_rest(a,b,handle,prior,rest)
def stage2(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage2_join(b,handle,prior,checked(run_reader(a,world,handle,False{}),False{},False{},1))

def stage1_rest(b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool) -> String:
  (world,okay) = observed
  +result = String.append("B-independent:",String.append(A.bool_string(okay),";"))
  stage2(a,b,world,handle,String.append(prior,result))
def stage1_join(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool)) -> String:
  (b,rest) = observed
  stage1_rest(b,a,handle,prior,rest)
def stage1(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage1_join(a,handle,prior,checked(run_reader(b,world,handle,False{}),True{},False{},1))

def stage0_rest(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool) -> String:
  (world,okay) = observed
  +result = String.append("A-first:",String.append(A.bool_string(okay),";"))
  stage1(a,b,world,handle,String.append(prior,result))
def stage0_join(b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool)) -> String:
  (a,rest) = observed
  stage0_rest(a,b,handle,prior,rest)
def stage0(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage0_join(b,handle,prior,checked(run_reader(a,world,handle,False{}),True{},False{},1))

def registered_b(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,result: Sys.RegistrationResult<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>) -> String:
  match result:
    case Sys.RegistrationFailed{_}: "register-B:false;"
    case Sys.Registered{world,b}: stage0(a,b,world,handle,"")
def registered_a(+handle: W.Handle<S.Schema>,result: Sys.RegistrationResult<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>) -> String:
  match result:
    case Sys.RegistrationFailed{_}: "register-A:false;"
    case Sys.Registered{world,a}: registered_b(a,handle,Sys.register(~S.Schema,~S.Store,~F32,~S.SimEvent,~(W.Handle<S.Schema> & (U32 & Bool)),~U32,~Bool,~reader,world,"B",["changed"]))
def activated(+handle: W.Handle<S.Schema>,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & W.Status) -> String:
  (world,_) = observed
  world = A.write(world,handle)
  registered_a(handle,Sys.register(~S.Schema,~S.Store,~F32,~S.SimEvent,~(W.Handle<S.Schema> & (U32 & Bool)),~U32,~Bool,~reader,world,"A",["changed"]))
def reserved(result: W.World<S.Schema,S.Store,F32,S.SimEvent> & W.Reservation<S.Schema>) -> String:
  match result:
    case (world,W.ReservationRejected{_}): "reservation:false;"
    case (world,W.Reserved{+handle}): activated(handle,W.activate(~S.Schema,~S.Store,~F32,~S.SimEvent,world,handle))
def created(result: W.Creation<S.Schema,S.Store,F32,S.SimEvent>) -> String:
  match result:
    case W.CreateRejected{_,_}: "creation:false;"
    case W.Created{_,world}: reserved(W.reserve_id(~S.Schema,~S.Store,~F32,~S.SimEvent,world))
def main() -> IO(Unit): IO.print(created(S.create(W.factory(),1.0)))
