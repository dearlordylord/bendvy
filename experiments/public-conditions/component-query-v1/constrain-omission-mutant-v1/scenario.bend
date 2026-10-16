import Base
import ./fixture.bend as F
import /tmp/bendvy-component-query-check/experiments/public-conditions/component-query-v1/schema.bend as Model
import ./setup.bend as Setup
import ./observe.bend as Obs
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource.bend as Slot
import /workspace/formal-proofs/bendvy/src/ecs/resource-field.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-schedule.bend as Checked
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/checked-condition-schedule.bend as Error
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

type Session<S:Data> is Type:
  Session{app:F.Application(~S),setup:Maybe<&1,Setup.Owned<S>>,slots:List<F.Input(~S)>}
type Action is Data:
  Checkpoint{label:String}
  Enable{}
  Dispatch{}
  Populate{}
  ThresholdHigh{}
  ThresholdMissing{}
  RestoreThreshold{}
def slots_cons(~S:Data,head:F.Input(~S),text:String,rest:List<F.Input(~S)> & String) -> List<F.Input(~S)> & String:
  match rest:
    case (tail,more):(head <> tail,text ++ ";" ++ more)
def slots_both(~S:Data,a:F.Input(~S) & String,b:List<F.Input(~S)> & String) -> List<F.Input(~S)> & String:
  (head,text)=a
  slots_cons(~S,head,text,b)
def observe_slots(~S:Data,value:List<F.Input(~S)>) -> List<F.Input(~S)> & String:
  match value:
    case []:([],"[]")
    case head <> tail:slots_both(~S,Obs.input(~S,head),observe_slots(~S,tail))
def setup_some(~S:Data,value:Setup.Owned<S> & String) -> Maybe<&1,Setup.Owned<S>> & String:
  match value:
    case (owner,text):(Some{owner},"Some{" ++ text ++ "}")
def setup_observed(~S:Data,value:Maybe<&1,Setup.Owned<S>>) -> Maybe<&1,Setup.Owned<S>> & String:
  match value:
    case None{}:(None{},"None")
    case Some{owner}:setup_some(~S,Obs.owned(~S,owner))
def state_snapshot(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,slots:List<F.Input(~S)>,text:String,value:F.Application(~S) & Maybe<&2,Checked.Description<S,F.Rows()>>) -> Session<S> & String:
  match value:
    case (app,view):(Session{app,setup,slots},text ++ "\nsnapshot=" ++ Obs.snapshot(~S,view) ++ "\n")
def state_owners(~S:Data,app:F.Application(~S),text:String,a:Maybe<&1,Setup.Owned<S>> & String,b:List<F.Input(~S)> & String) -> Session<S> & String:
  (setup,st)=a
  (slots,sl)=b
  state_snapshot(~S,setup,slots,text ++ "\nsetup=" ++ st ++ "\nreturnedThresholdSlots=" ++ sl,F.snapshot(~S,app))
def state_app(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,slots:List<F.Input(~S)>,text:String,value:F.Application(~S) & String) -> Session<S> & String:
  match value:
    case (app,at):state_owners(~S,app,text ++ "\napp=" ++ at,setup_observed(~S,setup),observe_slots(~S,slots))
def state_readout(~S:Data,rest:F.Rest<S>,setup:Maybe<&1,Setup.Owned<S>>,slots:List<F.Input(~S)>,label:String,value:F.World(~S) & F.Readout<S>) -> Session<S> & String:
  match value:
    case (world,readout):state_app(~S,setup,slots,label ++ "\nreadout=" ++ Obs.readout(~S,readout),Obs.app(~S,F.put_world(~S,rest,world)))
def state_taken(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,slots:List<F.Input(~S)>,label:String,value:F.Rest<S> & F.World(~S)) -> Session<S> & String:
  match value:
    case (rest,world):state_readout(~S,rest,setup,slots,label,F.readout(~S,world))
def state(~S:Data,session:Session<S>,label:String) -> Session<S> & String:
  match session:
    case Session{app,setup,slots}:state_taken(~S,setup,slots,label,F.take_world(~S,app))
def dispatched(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,slots:List<F.Input(~S)>,value:Single.RunResult<F.Application(~S),S,Error.Error<String>>) -> Session<S> & String:
  match value:
    case Single.Finished{app,observations}:(Session{app,setup,slots},"Finished:" ++ Obs.run_observations(observations) ++ "\n")
    case Single.Failed{app,error,observations}:(Session{app,setup,slots},"Failed:" ++ Obs.run_error(error) ++ ":" ++ Obs.run_observations(observations) ++ "\n")
    case Single.Rejected{app}:(Session{app,setup,slots},"Rejected\n")
    case Single.Missing{app,requirements}:(Session{app,setup,slots},"AuthoredPlanMissing:" ++ Nat.show(List.length(&2,SP.Requirement<S>,requirements)) ++ "\n")
def populated(~S:Data,rest:F.Rest<S>,slots:List<F.Input(~S)>,value:F.World(~S) & Setup.Owned<S>) -> Session<S> & String:
  match value:
    case (world,owned):(Session{F.put_world(~S,rest,world),Some{owned},slots},"Populated\n")
def populate_world(~S:Data,rest:F.Rest<S>,world:F.World(~S),setup:Maybe<&1,Setup.Owned<S>>,slots:List<F.Input(~S)>) -> Session<S> & String:
  match setup:
    case None{}:populated(~S,rest,slots,Setup.retained(~S,Setup.run(~S,world)))
    case Some{owner}:(Session{F.put_world(~S,rest,world),Some{owner},slots},"UnexpectedRepeatedPopulation\n")
def populate_taken(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,slots:List<F.Input(~S)>,value:F.Rest<S> & F.World(~S)) -> Session<S> & String:
  match value:
    case (rest,world):populate_world(~S,rest,world,setup,slots)
def threshold_returned(~S:Data,rest:F.Rest<S>,setup:Maybe<&1,Setup.Owned<S>>,slots:List<F.Input(~S)>,value:F.World(~S) & F.Input(~S)) -> Session<S> & String:
  match value:
    case (world,previous):(Session{F.put_world(~S,rest,world),setup,previous <> slots},"ThresholdExchanged\n")
def threshold_taken(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,slots:List<F.Input(~S)>,incoming:F.Input(~S),value:F.Rest<S> & F.World(~S)) -> Session<S> & String:
  match value:
    case (rest,world):threshold_returned(~S,rest,setup,slots,Field.replace_world(~S,~Model.Store(~S),~F.Resources(~S),~Unit,~F.Input(~S),~((Unit & Array<U32>) & Array<U32>),~F.input_lens(~S),incoming,world))
def restore(~S:Data,app:F.Application(~S),setup:Maybe<&1,Setup.Owned<S>>,slots:List<F.Input(~S)>) -> Session<S> & String:
  match slots:
    case []:(Session{app,setup,[]},"UnexpectedNoReturnedThreshold\n")
    case incoming <> rest:threshold_taken(~S,setup,rest,incoming,F.take_world(~S,app))
def action(~S:Data,step:Action,session:Session<S>) -> Session<S> & String:
  match step session:
    case Checkpoint{label} session:state(~S,session,label)
    case Enable{} Session{app,setup,slots}:(Session{F.enable(~S,app,True{}),setup,slots},"Enabled\n")
    case Dispatch{} Session{app,setup,slots}:dispatched(~S,setup,slots,F.run(~S,app))
    case Populate{} Session{app,setup,slots}:populate_taken(~S,setup,slots,F.take_world(~S,app))
    case ThresholdHigh{} Session{app,setup,slots}:threshold_taken(~S,setup,slots,Slot.Present{F.pair(50)},F.take_world(~S,app))
    case ThresholdMissing{} Session{app,setup,slots}:threshold_taken(~S,setup,slots,Slot.Missing{},F.take_world(~S,app))
    case RestoreThreshold{} Session{app,setup,slots}:restore(~S,app,setup,slots)
def continued(~S:Data,next:Session<S> -> String,value:Session<S> & String) -> String:
  match value:
    case (session,text):text ++ next(session)
def actions(~S:Data,steps:List<&2,Action>,session:Session<S>) -> String:
  match steps:
    case []:""
    case step <> rest:continued(~S,(session=>actions(~S,rest,session)),action(~S,step,session))
def program() -> List<&2,Action>:
  [Checkpoint{"empty-disabled"},Enable{},Checkpoint{"empty-enabled"},Checkpoint{"empty-enabled-repeat"},Dispatch{},Checkpoint{"empty-skipped"},ThresholdHigh{},Populate{},Checkpoint{"populated-high-threshold"},Dispatch{},Checkpoint{"threshold-false"},RestoreThreshold{},Checkpoint{"returned-threshold-restored"},Dispatch{},Checkpoint{"threshold-true"},Dispatch{},Checkpoint{"threshold-true-repeat"},ThresholdMissing{},Checkpoint{"threshold-missing"},Dispatch{},Checkpoint{"missing-refused"},RestoreThreshold{},Checkpoint{"returned-threshold-recovered"},Dispatch{},Checkpoint{"terminal"}]
def run(~S:Data,value:Maybe<&1,F.Application(~S)>) -> String:
  match value:
    case None{}:"creation-or-registration-refused\n"
    case Some{app}:actions(~S,program(),Session{app,None{},[]})
