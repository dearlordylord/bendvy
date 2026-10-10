import Base
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/types.bend as T
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/world.bend as Lens
import ../../../systems.bend as Systems
import ../../../bridge.bend as Phase
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-schedule.bend as Ordinary
type Owners<S:Data> is Type:
  Pending{entries:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>}
  Unavailable{entries:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>}
  Selected{positions:List<&2,B.Position<S,T.MachineKey,T.State,U32>>,kept:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>>,active:Phase.Owners<S>,phase:H.Phase}
type MarkerResult<S:Data> is Type:
  MarkerResult{result:B.BundleResult<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,steps:List<&2,Sch.Step>,observations:List<&2,Sch.Observation>}
def applied(~S:Data,positions:List<&2,B.Position<S,T.MachineKey,T.State,U32>>,kept:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>>,result:Phase.Owners<S> & Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>) -> Owners<S> & Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  (active,outcome)=result
  (Selected{positions,kept,active,H.Exit{}},outcome)
def selected(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,partition:B.Partition<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>) -> Owners<S> & Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match partition:
    case B.Partition{positions,kept,handlers}:applied(~S,positions,kept,Phase.captured(~S,handlers,Lens.take(~S,world)))
def targeted(~S:Data,entries:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>,pair:W.World<S,T.Store<S>,T.Resources<S>,Unit> & M.Slot<S,T.MachineKey,T.State>) -> Owners<S> & Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match pair:
    case (world,M.Missing{}):(Unavailable{entries},Sys.Succeeded{Lens.put(~S,world,M.Missing{}),Unit{}})
    case (world,M.Present{current,M.NoPending{},previous,_}):(Pending{entries},Sys.Succeeded{Lens.put(~S,world,M.Present{current,M.NoPending{},previous,False{}}),Unit{}})
    case (world,M.Present{+current,M.Queued{+to,+skip},previous,changed}):selected(~S,Lens.put(~S,world,M.Present{current,M.Queued{to,skip},previous,changed}),B.partition(~S,~T.MachineKey,~T.State,~U32,~T.Store<S>,~T.Resources<S>,~Unit,~Systems.runner(~S),~T.same,entries,current,to))
def apply(~S:Data,owners:Owners<S>,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> Owners<S> & Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match owners:
    case Pending{entries}:targeted(~S,entries,Lens.take(~S,Phase.tick(~S,world)))
    case owners:(owners,Sys.Succeeded{world,Unit{}})
def phase_returned(~S:Data,positions:List<&2,B.Position<S,T.MachineKey,T.State,U32>>,kept:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>>,phase:H.Phase,result:Phase.Owners<S> & Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>) -> Owners<S> & Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  (active,outcome)=result
  (Selected{positions,kept,active,phase},outcome)
def exit(~S:Data,owners:Owners<S>,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> Owners<S> & Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match owners:
    case Selected{positions,kept,active,_}:phase_returned(~S,positions,kept,H.Exit{},Phase.exit(~S,active,world))
    case owners:(owners,Sys.Succeeded{world,Unit{}})
def transition(~S:Data,owners:Owners<S>,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> Owners<S> & Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match owners:
    case Selected{positions,kept,active,_}:phase_returned(~S,positions,kept,H.Transition{},Phase.transition(~S,active,world))
    case owners:(owners,Sys.Succeeded{world,Unit{}})
def enter(~S:Data,owners:Owners<S>,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> Owners<S> & Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match owners:
    case Selected{positions,kept,active,_}:phase_returned(~S,positions,kept,H.Enter{},Phase.enter(~S,active,world))
    case owners:(owners,Sys.Succeeded{world,Unit{}})
def swapped(~S:Data,items:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>) -> List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>:
  match items:
    case first <> second <> rest:second <> first <> rest
    case items:items
def reordered(~S:Data,result:B.BundleResult<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>) -> B.BundleResult<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>:
  match result:
    case B.Returned{B.Bundle{namespace,items},world,status}:B.Returned{B.Bundle{namespace,swapped(~S,items)},world,status}
    case result:result
def recovered(~S:Data,namespace:U32,positions:List<&2,B.Position<S,T.MachineKey,T.State,U32>>,kept:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>>,active:Phase.Owners<S>,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,status:B.Status<U32>) -> B.BundleResult<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>:
  match active:
    case Phase.Owners{handlers,_}:reordered(~S,B.recovered(~S,~T.MachineKey,~T.State,~U32,~T.Store<S>,~T.Resources<S>,~Unit,~Systems.runner(~S),namespace,B.recover(~S,~T.MachineKey,~T.State,~U32,~T.Store<S>,~T.Resources<S>,~Unit,~Systems.runner(~S),positions,kept,handlers),world,status))
def finished(~S:Data,namespace:U32,owners:Owners<S>,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,error:Maybe<&2,String>) -> B.BundleResult<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>:
  match owners error:
    case Pending{entries} None{}:B.Returned{B.Bundle{namespace,entries},world,B.Completed{}}
    case Pending{entries} Some{_}:B.Returned{B.Bundle{namespace,entries},world,B.ForeignBundle{}}
    case Unavailable{entries} _:B.Returned{B.Bundle{namespace,entries},world,B.MachineUnavailable{}}
    case Selected{positions,kept,active,_} None{}:recovered(~S,namespace,positions,kept,active,world,B.Completed{})
    case Selected{positions,kept,active,phase} Some{error}:recovered(~S,namespace,positions,kept,active,world,B.HandlerFailed{phase,error})
def returned(~S:Data,result:Sch.RunResult<S,T.Store<S>,T.Resources<S>,Unit,Owners<S>,String>) -> MarkerResult<S>:
  match result:
    case Sch.Finished{Sch.Schedule{namespace,_,steps,owners},world,observations}:MarkerResult{finished(~S,namespace,owners,world,None{}),steps,observations}
    case Sch.Failed{Sch.Schedule{namespace,_,steps,owners},world,error,observations}:MarkerResult{finished(~S,namespace,owners,world,Some{error}),steps,observations}
    case Sch.Rejected{Sch.Schedule{namespace,_,steps,owners},world}:MarkerResult{finished(~S,namespace,owners,world,Some{"schedule-rejected"}),steps,[]}
def installed(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,built:Sch.Build<S,T.Store<S>,T.Resources<S>,Unit,Owners<S>>) -> MarkerResult<S>:
  match built:
    case Sch.Built{schedule}:returned(~S,Ordinary.run(~S,~T.Store<S>,~T.Resources<S>,~Unit,~Owners<S>,~String,~apply(~S),~exit(~S),~transition(~S),~enter(~S),schedule,world))
    case Sch.Invalid{owners}:MarkerResult{finished(~S,0,owners,world,Some{"invalid"}),[],[]}
def checked(~S:Data,namespace:U32,entries:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>,pair:W.World<S,T.Store<S>,T.Resources<S>,Unit> & List<&2,U32>) -> MarkerResult<S>:
  match pair:
    case (world,[]):installed(~S,world,Ordinary.install(~S,~T.Store<S>,~T.Resources<S>,~Unit,~Owners<S>,~String,Ordinary.declare(~S,"handler-bundle-global-marker"),namespace,Pending{entries}))
    case (world,missing):MarkerResult{B.Returned{B.Bundle{namespace,entries},world,B.MissingRequirements{missing}},[],[]}
def gathered(~S:Data,~has:W.World<S,T.Store<S>,T.Resources<S>,Unit> -> U32 -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & Bool,namespace:U32,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,pair:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>> & List<&2,U32>) -> MarkerResult<S>:
  (entries,needs)=pair
  checked(~S,namespace,entries,B.missing(~S,~T.Store<S>,~T.Resources<S>,~Unit,~U32,~has,B.collect(~U32,~U32.is_eq,needs,[]),world))
def allowed(~S:Data,~has:W.World<S,T.Store<S>,T.Resources<S>,Unit> -> U32 -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & Bool,yes:Bool,namespace:U32,entries:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> MarkerResult<S>:
  match yes:
    case False{}:MarkerResult{B.Returned{B.Bundle{namespace,entries},world,B.ForeignBundle{}},[],[]}
    case True{}:gathered(~S,~has,namespace,world,B.requirements(~S,~T.MachineKey,~T.State,~U32,~T.Store<S>,~T.Resources<S>,~Unit,~Systems.runner(~S),entries))
def named(~S:Data,~has:W.World<S,T.Store<S>,T.Resources<S>,Unit> -> U32 -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & Bool,+namespace:U32,entries:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>,pair:W.World<S,T.Store<S>,T.Resources<S>,Unit> & U32) -> MarkerResult<S>:
  (world,actual)=pair
  allowed(~S,~has,U32.is_eq(namespace,actual),namespace,entries,world)
def run(~S:Data,~has:W.World<S,T.Store<S>,T.Resources<S>,Unit> -> U32 -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & Bool,bundle:B.Bundle<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> MarkerResult<S>:
  match bundle:
    case B.Bundle{namespace,entries}:named(~S,~has,namespace,entries,W.namespace(~S,~T.Store<S>,~T.Resources<S>,~Unit,world))
