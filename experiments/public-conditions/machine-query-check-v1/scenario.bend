import Base
import ./fixture.bend as F
import ./schema.bend as Model
import ./setup.bend as Setup
import ./observe.bend as Obs
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-initialization.bend as Init
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as Handlers
import /workspace/formal-proofs/bendvy/src/ecs/resource-field.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-schedule.bend as Checked
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/checked-condition-schedule.bend as Error
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T

type Session<S:Data> is Type:
  Session{app:F.Application(~S),setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S)}
type Action is Data:
  Checkpoint{label:String}
  Enable{}
  Dispatch{}
  Populate{}
  Insert{value:U32}
  Queue{value:U32}
  Apply{}
  Remove{}
  Restore{}
  ForceRequired{}
def setup_some(~S:Data,value:Setup.Owned<S> & String) -> Maybe<&1,Setup.Owned<S>> & String:
  match value:
    case (owner,text):(Some{owner},"Some{" ++ text ++ "}")
def setup_observed(~S:Data,value:Maybe<&1,Setup.Owned<S>>) -> Maybe<&1,Setup.Owned<S>> & String:
  match value:
    case None{}:(None{},"None")
    case Some{owner}:setup_some(~S,Obs.owned(~S,owner))
def state_snapshot(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S),text:String,value:F.Application(~S) & Maybe<&2,Checked.Description<S,F.Rows()>>) -> Session<S> & String:
  match value:
    case (app,view):(Session{app,setup,states,handlers},text ++ "\nsnapshot=" ++ Obs.snapshot(~S,view) ++ "\n")
def state_owners(~S:Data,app:F.Application(~S),text:String,a:Maybe<&1,Setup.Owned<S>> & String,b:List<F.MachineState(~S)> & String,c:F.TransitionOwners(~S) & String) -> Session<S> & String:
  (setup,st)=a
  (states,ss)=b
  (handlers,hs)=c
  state_snapshot(~S,setup,states,handlers,text ++ "\nsetup=" ++ st ++ "\nreturnedStates=" ++ ss ++ "\ntransitionOwners=" ++ hs,F.snapshot(~S,app))
def state_app(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S),text:String,value:F.Application(~S) & String) -> Session<S> & String:
  match value:
    case (app,at):state_owners(~S,app,text ++ "\napp=" ++ at,setup_observed(~S,setup),Obs.states(~S,states),Obs.transition_owners(~S,handlers))
def state_views(~S:Data,rest:F.Rest<S>,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S),label:String,value:F.World(~S) & F.Views<S>) -> Session<S> & String:
  match value:
    case (world,views):state_app(~S,setup,states,handlers,label ++ "\nreadout=" ++ Obs.views(~S,views),Obs.app(~S,F.put_world(~S,rest,world)))
def state_taken(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S),label:String,value:F.Rest<S> & F.World(~S)) -> Session<S> & String:
  match value:
    case (rest,world):state_views(~S,rest,setup,states,handlers,label,F.views(~S,world))
def state(~S:Data,session:Session<S>,label:String) -> Session<S> & String:
  match session:
    case Session{app,setup,states,handlers}:state_taken(~S,setup,states,handlers,label,F.take_world(~S,app))
def dispatched(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S),value:Single.RunResult<F.Application(~S),S,Error.Error<String>>) -> Session<S> & String:
  match value:
    case Single.Finished{app,observations}:(Session{app,setup,states,handlers},"Finished:" ++ Obs.run_observations(observations) ++ "\n")
    case Single.Failed{app,error,observations}:(Session{app,setup,states,handlers},"Failed:" ++ Obs.run_error(error) ++ ":" ++ Obs.run_observations(observations) ++ "\n")
    case Single.Rejected{app}:(Session{app,setup,states,handlers},"Rejected\n")
    case Single.Missing{app,requirements}:(Session{app,setup,states,handlers},"AuthoredPlanMissing:" ++ Nat.show(List.length(&2,SP.Requirement<S>,requirements)) ++ "\n")
def populated(~S:Data,rest:F.Rest<S>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S),value:F.World(~S) & Setup.Owned<S>) -> Session<S> & String:
  match value:
    case (world,owned):(Session{F.put_world(~S,rest,world),Some{owned},states,handlers},"Populated\n")
def populate_world(~S:Data,rest:F.Rest<S>,world:F.World(~S),setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S)) -> Session<S> & String:
  match setup:
    case None{}:populated(~S,rest,states,handlers,Setup.retained(~S,Setup.run(~S,world)))
    case Some{owner}:(Session{F.put_world(~S,rest,world),Some{owner},states,handlers},"UnexpectedRepeatedPopulation\n")
def populate_taken(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S),value:F.Rest<S> & F.World(~S)) -> Session<S> & String:
  match value:
    case (rest,world):populate_world(~S,rest,world,setup,states,handlers)
def inserted(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S),+value:U32,taken:F.Rest<S> & F.World(~S)) -> Session<S> & String:
  match taken:
    case (rest,world):(Session{F.put_world(~S,rest,F.insert(~S,world,value)),setup,states,handlers},"Inserted:" ++ U32.show(value) ++ "\n")
def queued(~S:Data,rest:F.Rest<S>,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S),value:T.Returned<F.World(~S),Unit>) -> Session<S> & String:
  match value:
    case T.Returned{world,T.Success{}}:(Session{F.put_world(~S,rest,world),setup,states,handlers},"QueueSuccess\n")
    case T.Returned{world,T.Failure{_}}:(Session{F.put_world(~S,rest,world),setup,states,handlers},"QueueFailure:Unit\n")
def queue_taken(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S),value:U32,taken:F.Rest<S> & F.World(~S)) -> Session<S> & String:
  match taken:
    case (rest,world):queued(~S,rest,setup,states,handlers,F.queue(~S,world,value))
def transition_returned(~S:Data,rest:F.Rest<S>,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,text:String,value:F.TransitionResult<S>) -> Session<S> & String:
  match value:
    case F.TransitionResult{_,Handlers.Completed{handlers,world}}:(Session{F.put_world(~S,rest,world),setup,states,handlers},"Applied:" ++ text ++ "\n")
    case F.TransitionResult{_,Handlers.Stopped{handlers,world,_,_}}:(Session{F.put_world(~S,rest,world),setup,states,handlers},"Stopped:" ++ text ++ "\n")
def transition_observed(~S:Data,rest:F.Rest<S>,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,value:F.TransitionResult<S> & String) -> Session<S> & String:
  match value:
    case (result,text):transition_returned(~S,rest,setup,states,text,result)
def apply_taken(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S),taken:F.Rest<S> & F.World(~S)) -> Session<S> & String:
  match taken:
    case (rest,world):transition_observed(~S,rest,setup,states,Obs.transition_result(~S,F.transition(~S,handlers,world)))
def exchanged(~S:Data,rest:F.Rest<S>,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S),value:F.World(~S) & F.MachineState(~S)) -> Session<S> & String:
  match value:
    case (world,previous):(Session{F.put_world(~S,rest,world),setup,previous <> states,handlers},"MachineStateExchanged\n")
def exchange_taken(~S:Data,setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S),incoming:F.MachineState(~S),taken:F.Rest<S> & F.World(~S)) -> Session<S> & String:
  match taken:
    case (rest,world):exchanged(~S,rest,setup,states,handlers,Field.replace_world(~S,~Model.Store(~S),~F.Resources(~S),~Unit,~F.MachineState(~S),~(Unit & F.BaseResources(~S)),~F.machine_lens(~S),incoming,world))
def restored(~S:Data,app:F.Application(~S),setup:Maybe<&1,Setup.Owned<S>>,states:List<F.MachineState(~S)>,handlers:F.TransitionOwners(~S)) -> Session<S> & String:
  match states:
    case []:(Session{app,setup,[],handlers},"UnexpectedNoReturnedState\n")
    case incoming <> rest:exchange_taken(~S,setup,rest,handlers,incoming,F.take_world(~S,app))
def action(~S:Data,step:Action,session:Session<S>) -> Session<S> & String:
  match step session:
    case Checkpoint{label} session:state(~S,session,label)
    case Enable{} Session{app,setup,states,handlers}:(Session{F.enable(~S,app,True{}),setup,states,handlers},"Enabled\n")
    case Dispatch{} Session{app,setup,states,handlers}:dispatched(~S,setup,states,handlers,F.run(~S,app))
    case Populate{} Session{app,setup,states,handlers}:populate_taken(~S,setup,states,handlers,F.take_world(~S,app))
    case Insert{value} Session{app,setup,states,handlers}:inserted(~S,setup,states,handlers,value,F.take_world(~S,app))
    case Queue{value} Session{app,setup,states,handlers}:queue_taken(~S,setup,states,handlers,value,F.take_world(~S,app))
    case Apply{} Session{app,setup,states,handlers}:apply_taken(~S,setup,states,handlers,F.take_world(~S,app))
    case Remove{} Session{app,setup,states,handlers}:exchange_taken(~S,setup,states,handlers,Init.empty(~S,~F.FlowToken,~U32),F.take_world(~S,app))
    case Restore{} Session{app,setup,states,handlers}:restored(~S,app,setup,states,handlers)
    case ForceRequired{} Session{app,setup,states,handlers}:(Session{F.bypass(~S,app,True{}),setup,states,handlers},"ExplicitRequiredBypassEnabled\n")
def continued(~S:Data,next:Session<S> -> String,value:Session<S> & String) -> String:
  match value:
    case (session,text):text ++ next(session)
def actions(~S:Data,steps:List<&2,Action>,session:Session<S>) -> String:
  match steps:
    case []:""
    case step <> rest:continued(~S,(session=>actions(~S,rest,session)),action(~S,step,session))
def program() -> List<&2,Action>:
  [Checkpoint{"missing-disabled"},Enable{},Populate{},Dispatch{},Checkpoint{"missing-lazy-skipped"},Insert{0},Dispatch{},Checkpoint{"mode0-true"},Queue{1},Checkpoint{"queued1-current0"},Dispatch{},Checkpoint{"queued1-still-true"},Apply{},Checkpoint{"mode1-applied"},Dispatch{},Checkpoint{"mode1-false"},Queue{0},Checkpoint{"queued0-current1"},Apply{},Checkpoint{"mode0-applied"},Dispatch{},Checkpoint{"mode0-true-again"},Remove{},Checkpoint{"removed-state-returned"},Dispatch{},ForceRequired{},Dispatch{},Checkpoint{"required-missing-refused"},Restore{},Dispatch{},Checkpoint{"terminal-restored-mode0"}]
def run(~S:Data,value:Maybe<&1,F.Application(~S)>) -> String:
  match value:
    case None{}:"creation-or-registration-refused\n"
    case Some{app}:actions(~S,program(),Session{app,None{},[],F.transition_owners(~S)})
