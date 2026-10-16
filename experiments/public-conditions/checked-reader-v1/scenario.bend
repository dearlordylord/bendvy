import Base
import ./fixture.bend as F
import ./observe.bend as Obs
import /workspace/formal-proofs/bendvy/experiments/public-conditions/component-query-v1/fixture.bend as Source
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource.bend as Slot
import /workspace/formal-proofs/bendvy/src/ecs/resource-field.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-schedule.bend as Old
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/checked-condition-schedule.bend as Error
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

type Session<S:Data> is Type:Session{app:F.Application(~S),slots:List<F.Input(~S)>}
type Action is Data:
  Checkpoint{label:String}
  Enable{}
  Dispatch{}
  Missing{}
  Positive{}
  Restore{}
  Guards{first:Bool,second:Bool}
def slots_cons(~S:Data,head:F.Input(~S),text:String,value:List<F.Input(~S)> & String) -> List<F.Input(~S)> & String:
  match value:
    case (tail,more):(head <> tail,text ++ ";" ++ more)
def slots_both(~S:Data,head:F.Input(~S) & String,tail:List<F.Input(~S)> & String) -> List<F.Input(~S)> & String:
  (head,text)=head
  slots_cons(~S,head,text,tail)
def observe_slots(~S:Data,value:List<F.Input(~S)>) -> List<F.Input(~S)> & String:
  match value:
    case []:([],"[]")
    case head <> tail:slots_both(~S,Obs.input(~S,head),observe_slots(~S,tail))
def state_snapshot(~S:Data,slots:List<F.Input(~S)>,text:String,value:F.Application(~S) & Maybe<&2,Old.Description<S,F.Rows()>>) -> Session<S> & String:
  match value:
    case (app,view):(Session{app,slots},text ++ "\nsnapshot=" ++ Obs.snapshot(~S,view) ++ "\n")
def state_slots(~S:Data,app:F.Application(~S),text:String,value:List<F.Input(~S)> & String) -> Session<S> & String:
  match value:
    case (slots,rendered):state_snapshot(~S,slots,text ++ "\nreturnedThresholdSlots=" ++ rendered,F.snapshot(~S,app))
def state_app(~S:Data,slots:List<F.Input(~S)>,label:String,value:F.Application(~S) & String) -> Session<S> & String:
  match value:
    case (app,text):state_slots(~S,app,label ++ "\napp=" ++ text,observe_slots(~S,slots))
def state(~S:Data,label:String,value:Session<S>) -> Session<S> & String:
  match value:
    case Session{app,slots}:state_app(~S,slots,label,Obs.app(~S,app))
def dispatched(~S:Data,slots:List<F.Input(~S)>,value:Single.RunResult<F.Application(~S),S,Error.Error<Unit>>) -> Session<S> & String:
  match value:
    case Single.Finished{app,observations}:(Session{app,slots},"Finished:" ++ Obs.run_observations(observations) ++ "\n")
    case Single.Failed{app,error,observations}:(Session{app,slots},"Failed:" ++ Obs.run_error(error) ++ ":" ++ Obs.run_observations(observations) ++ "\n")
    case Single.Rejected{app}:(Session{app,slots},"Rejected\n")
    case Single.Missing{app,requirements}:(Session{app,slots},"AuthoredPlanMissing:" ++ Nat.show(List.length(&2,SP.Requirement<S>,requirements)) ++ "\n")
def exchanged(~S:Data,rest:F.Rest<S>,slots:List<F.Input(~S)>,value:F.World(~S) & F.Input(~S)) -> Session<S> & String:
  match value:
    case (world,previous):(Session{F.put_world(~S,rest,world),previous <> slots},"ThresholdExchanged\n")
def exchange_taken(~S:Data,slots:List<F.Input(~S)>,incoming:F.Input(~S),value:F.Rest<S> & F.World(~S)) -> Session<S> & String:
  match value:
    case (rest,world):exchanged(~S,rest,slots,Field.replace_world(~S,~Array<U32>,~F.Resources(~S),~U32,~F.Input(~S),~((Unit & Array<U32>) & Array<U32>),~Source.input_lens(~S),incoming,world))
def restore(~S:Data,app:F.Application(~S),slots:List<F.Input(~S)>) -> Session<S> & String:
  match slots:
    case []:(Session{app,[]},"UnexpectedMissingReturnedSlot\n")
    case incoming <> tail:exchange_taken(~S,tail,incoming,F.take_world(~S,app))
def action(~S:Data,step:Action,value:Session<S>) -> Session<S> & String:
  match step value:
    case Checkpoint{label} value:state(~S,label,value)
    case Enable{} Session{app,slots}:(Session{F.enabled(~S,app,True{}),slots},"Enabled\n")
    case Dispatch{} Session{app,slots}:dispatched(~S,slots,F.run(~S,app))
    case Missing{} Session{app,slots}:exchange_taken(~S,slots,Slot.Missing{},F.take_world(~S,app))
    case Positive{} Session{app,slots}:exchange_taken(~S,slots,Slot.Present{Source.pair(5)},F.take_world(~S,app))
    case Restore{} Session{app,slots}:restore(~S,app,slots)
    case Guards{+first,+second} Session{app,slots}:(Session{F.guards(~S,first,second,app),slots},"Guards=" ++ Bool.show(first) ++ "," ++ Bool.show(second) ++ "\n")
def continued(~S:Data,next:Session<S> -> String,value:Session<S> & String) -> String:
  match value:
    case (session,text):text ++ next(session)
def actions(~S:Data,steps:List<&2,Action>,session:Session<S>) -> String:
  match steps:
    case []:""
    case step <> tail:continued(~S,(session=>actions(~S,tail,session)),action(~S,step,session))
def program() -> List<&2,Action>:
  [Checkpoint{"disabled"},Enable{},Checkpoint{"enabled"},Dispatch{},Checkpoint{"false-before-reader-barrier-applied"},Dispatch{},Checkpoint{"false-repeat"},Missing{},Guards{False{},False{}},Dispatch{},Checkpoint{"lazy-missing-skipped"},Guards{True{},False{}},Dispatch{},Checkpoint{"reached-missing-refused"},Restore{},Positive{},Dispatch{},Checkpoint{"fast-read-slow-unentered"},Guards{False{},False{}},Dispatch{},Checkpoint{"false-after-fast-preserves"},Guards{True{},True{}},Dispatch{},Checkpoint{"slow-admitted-fast-empty"},Dispatch{},Checkpoint{"both-repeat"},Checkpoint{"terminal-repeat-snapshot"}]
def run(~S:Data,value:Maybe<&1,F.Application(~S)>) -> String:
  match value:
    case None{}:"creation-or-registration-refused\n"
    case Some{app}:actions(~S,program(),Session{F.guards(~S,True{},False{},app),[]})
