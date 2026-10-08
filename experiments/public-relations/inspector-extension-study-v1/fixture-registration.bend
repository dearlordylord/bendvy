import Base
import fixture-state.bend as State
import fixture-consumer.bend as Consumer
import root-source/world.bend as W
import root-source/system.bend as Sys
import root-source/schedule.bend as Sch

# Actual source registration/build seams; all refusal owners retained.
type GateResult<S:Data> is Type:
  Registered{result:Sys.RegistrationResult<S,State.Store<S>,State.Resources<S>,U32,Unit,String,Unit,Consumer.runner(~S)>}
def register(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> GateResult<S>:
  Registered{Sys.register(~S,~State.Store<S>,~State.Resources<S>,~U32,~Unit,~String,~Unit,~Consumer.runner(~S),world,"InspectorMachineBody",[])}
type BuiltGate<S:Data> is Type:
  Ran{result:Sch.RunResult<S,State.Store<S>,State.Resources<S>,U32,Consumer.Holder<S>,String>}
  Invalid{world:W.World<S,State.Store<S>,State.Resources<S>,U32>,holder:Consumer.Holder<S>}
def built(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,result:Sch.Build<S,State.Store<S>,State.Resources<S>,U32,Consumer.Holder<S>>) -> BuiltGate<S>:
  match result:
    case Sch.Built{schedule}:Ran{Consumer.run_schedule(~S,schedule,world)}
    case Sch.Invalid{holder}:Invalid{world,holder}
def namespaced(~S:Data,holder:Consumer.Holder<S>,+id:U32,condition:U32,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & U32) -> BuiltGate<S>:
  (world,namespace)=result
  built(~S,world,Sch.build(~S,~State.Store<S>,~State.Resources<S>,~U32,~Consumer.Holder<S>,namespace,"InspectorMachineGate",[Sch.System{id,condition}],[id],holder))
def identified(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,condition:U32,result:Sys.Registry<S,State.Store<S>,State.Resources<S>,U32,Unit,String,Unit,Consumer.runner(~S)> & U32) -> BuiltGate<S>:
  (registry,id)=result
  namespaced(~S,Consumer.Holder{registry},id,condition,W.namespace(~S,~State.Store<S>,~State.Resources<S>,~U32,world))
def gate(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,holder:Consumer.Holder<S>,condition:U32) -> BuiltGate<S>:
  match holder:
    case Consumer.Holder{registry}:identified(~S,world,condition,Sys.identity(~S,~State.Store<S>,~State.Resources<S>,~U32,~Unit,~String,~Unit,~Consumer.runner(~S),registry))
# Both nominal schemas instantiate the same application without erasing grants.
def workshop(world:W.World<State.Workshop,State.Store<State.Workshop>,State.Resources<State.Workshop>,U32>) -> GateResult<State.Workshop>:
  register(~State.Workshop,world)
def garden(world:W.World<State.Garden,State.Store<State.Garden>,State.Resources<State.Garden>,U32>) -> GateResult<State.Garden>:
  register(~State.Garden,world)
