import Base
import ../../../examples/user-simulation/schema.bend as S
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/lifecycle.bend as L
import ../../../src/ecs/system.bend as Sys
import stamps.bend as A
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/transaction.bend as T

def Ops(H: Type) -> Type: Cap.Write<H,S.Position,S.PositionView>
def selected(frame: Q.Frame<S.Schema,S.Store,F32,S.SimEvent>) -> Q.Frame<S.Schema,S.Store,F32,S.SimEvent> & Bool:
  Q.both(~S.Schema,~S.Store,~F32,~S.SimEvent,~Q.family_match(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,~A.position(),~Q.Required{}),~Q.lifecycle_match(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,~A.position(),~Q.Changed{}),frame)
def plan() -> Q.Plan<S.Schema,S.Store,F32,S.SimEvent,Ops>:
  Q.Plan{Q.write_family(~S.Schema,~S.Store,~F32,~S.SimEvent,~S.PositionRest,~S.Position,~S.PositionView,~S.PositionToken,~S.take_positions,~S.put_positions,~S.project_position,~A.position()),selected}
def decision(fail: Bool) -> T.Outcome<U32>:
  match fail:
    case False{}: T.Success{}
    case True{}: T.Failure{1}
def body(~H: Type,~caps: Ops(H),fail: Bool,ctx: H) -> H & (T.Outcome<U32> & Unit):
  (Cap.set(~H,~S.Position,~S.PositionView,~caps,ctx,S.Position{8.0,ANode{ALeaf{81},ALeaf{82}}}),(decision(fail),Unit{}))
def query_returned(result: Q.Executed<W.World<S.Schema,S.Store,F32,S.SimEvent>,Q.Error<U32>,Unit>) -> Sys.Outcome<W.World<S.Schema,S.Store,F32,S.SimEvent>,U32,Bool>:
  match result:
    case Q.Executed{world,T.Failure{_},_}: Sys.Failed{world,1}
    case Q.Executed{world,T.Success{},values}: Sys.Succeeded{world,Nat.is_lt(0n,List.length(&2,Unit,values))}
def reader_args(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,rest: U32 & Bool) -> Sys.Outcome<W.World<S.Schema,S.Store,F32,S.SimEvent>,U32,Bool>:
  (cursor,fail) = rest
  query_returned(Q.each_since(~S.Schema,~S.Store,~F32,~S.SimEvent,~Ops,~Bool,~U32,~Unit,~plan(),~body,fail,world,cursor))
def reader(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,args: (W.Handle<S.Schema> & (U32 & Bool))) -> Sys.Outcome<W.World<S.Schema,S.Store,F32,S.SimEvent>,U32,Bool>:
  (_,rest) = args
  reader_args(world,rest)
def run_clock(registry: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+cursor: U32,fail: Bool,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & U32) -> Sys.RunResult<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>:
  (world,+clock) = observed
  Sys.run_to_cursor(~S.Schema,~S.Store,~F32,~S.SimEvent,~(W.Handle<S.Schema> & (U32 & Bool)),~U32,~Bool,~reader,registry,world,(handle,(cursor,fail)),clock)
def run_cursor(world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,fail: Bool,observed: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & U32) -> Sys.RunResult<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>:
  (registry,cursor) = observed
  Sys.run_tracked(~S.Schema,~S.Store,~F32,~S.SimEvent,~(W.Handle<S.Schema> & (U32 & Bool)),~U32,~Bool,~reader,registry,world,(handle,(cursor,fail)))
def run_reader(registry: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,fail: Bool) -> Sys.RunResult<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>:
  run_cursor(world,handle,fail,Sys.cursor(~S.Schema,~S.Store,~F32,~S.SimEvent,~(W.Handle<S.Schema> & (U32 & Bool)),~U32,~Bool,~reader,registry))
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

def stage4_rest(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool) -> String:
  (world,okay) = observed
  +result = String.append("self-repeat-after-retry:",String.append(A.bool_string(okay),";"))
  String.append(prior,result)
def stage4_join(b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool)) -> String:
  (a,rest) = observed
  stage4_rest(a,b,handle,prior,rest)
def stage4(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage4_join(b,handle,prior,checked(run_reader(a,world,handle,False{}),False{},False{},5))
def stage3_rest(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool) -> String:
  (world,okay) = observed
  +result = String.append("self-retry:",String.append(A.bool_string(okay),";"))
  stage4(a,b,world,handle,String.append(prior,result))
def stage3_join(b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool)) -> String:
  (a,rest) = observed
  stage3_rest(a,b,handle,prior,rest)
def stage3(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage3_join(b,handle,prior,checked(run_reader(a,world,handle,False{}),True{},False{},5))
def failed_owner(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & String) -> String:
  (world,result) = observed
  stage3(a,b,world,handle,String.append(prior,result))
def failed_stamp(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & String) -> String:
  (world,result) = observed
  failed_owner(a,b,handle,String.append(prior,result),A.owner_check(world,handle))
def stage2_rest(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool) -> String:
  (world,okay) = observed
  +result = String.append("self-failure:",String.append(A.bool_string(okay),";"))
  failed_stamp(a,b,handle,String.append(prior,result),A.checked("failed-self-stamp",1,3,A.stamp(world,handle)))
def stage2_join(b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool)) -> String:
  (a,rest) = observed
  stage2_rest(a,b,handle,prior,rest)
def stage2(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  world = A.write(world,handle)
  stage2_join(b,handle,prior,checked(run_reader(a,world,handle,True{}),True{},True{},2))
def stage1_rest(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool) -> String:
  (world,okay) = observed
  +result = String.append("self-repeat:",String.append(A.bool_string(okay),";"))
  stage2(a,b,world,handle,String.append(prior,result))
def stage1_join(b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool)) -> String:
  (a,rest) = observed
  stage1_rest(a,b,handle,prior,rest)
def stage1(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage1_join(b,handle,prior,checked(run_reader(a,world,handle,False{}),False{},False{},2))
def stage0_rest(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool) -> String:
  (world,okay) = observed
  +result = String.append("self-first:",String.append(A.bool_string(okay),";"))
  stage1(a,b,world,handle,String.append(prior,result))
def stage0_join(b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,+handle: W.Handle<S.Schema>,+prior: String,observed: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader> & (W.World<S.Schema,S.Store,F32,S.SimEvent> & Bool)) -> String:
  (a,rest) = observed
  stage0_rest(a,b,handle,prior,rest)
def stage0(a: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,b: Sys.Registry<S.Schema,S.Store,F32,S.SimEvent,(W.Handle<S.Schema> & (U32 & Bool)),U32,Bool,reader>,world: W.World<S.Schema,S.Store,F32,S.SimEvent>,+handle: W.Handle<S.Schema>,+prior: String) -> String:
  stage0_join(b,handle,prior,checked(run_reader(a,world,handle,False{}),True{},False{},2))
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
