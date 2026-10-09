import Base
import provider.bend as P
import gameplay.bend as G
import context.bend as Ctx
import ../../../../../../bendvy/src/ecs/machine.bend as M
import marker.bend as Marker
import ../../../../../../bendvy/src/ecs/world.bend as W
import ../../../../../../bendvy/src/ecs/system.bend as Sys

# Each actual registration is owned once, even across many marker invocations.
type Owners<S: Data,-runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>> is Type:
  Owners{flow: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,runner>,level: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,runner>}
type Provision<S: Data,-runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>> is Type:
  Provisioned{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,owners: Owners<S,runner>}
  ProvisionFailed{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>}

def registered_level(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,flow: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,runner>,result: Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,runner>) -> Provision<S,runner>:
  match result:
    case Sys.Registered{world,level}: Provisioned{world,Owners{flow,level}}
    case Sys.RegistrationFailed{world}: ProvisionFailed{world}
def registered_flow(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,result: Sys.RegistrationResult<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,runner>) -> Provision<S,runner>:
  match result:
    case Sys.Registered{world,flow}: registered_level(~S,~runner,flow,Sys.register(~S,~P.Store<S>,~P.Resources<S>,~Unit,~G.HookOperation,~String,~Unit,~runner,world,"level-hook",["machine.Flow.next"]))
    case Sys.RegistrationFailed{world}: ProvisionFailed{world}
def provision(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Provision<S,runner>:
  registered_flow(~S,~runner,Sys.register(~S,~P.Store<S>,~P.Resources<S>,~Unit,~G.HookOperation,~String,~Unit,~runner,world,"flow-hook",["machine.Flow.next","machine.Level.next"]))

def trace(~S: Data,label: String,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,rows},events,commands,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,List.append(&2,String,rows,[label])},events,commands,registrations,nextSystem,clock}

def run_result(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,other: Sys.Registry<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,runner>,isFlow: Bool,result: Sys.RunResult<S,P.Store<S>,P.Resources<S>,Unit,G.HookOperation,String,Unit,runner>) -> Owners<S,runner> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match isFlow result:
    case True{}, Sys.Completed{actual,outcome}: (Owners{actual,other},outcome)
    case False{}, Sys.Completed{actual,outcome}: (Owners{other,actual},outcome)
    case True{}, Sys.RegistrationRejected{actual,world,_}: (Owners{actual,other},Sys.Failed{world,"HookRegistrationRejected"})
    case False{}, Sys.RegistrationRejected{actual,world,_}: (Owners{other,actual},Sys.Failed{world,"HookRegistrationRejected"})

def run_hook(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,owners: Owners<S,runner>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,operation: G.HookOperation) -> Owners<S,runner> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match owners operation:
    case Owners{flow,level}, G.FlowEnter{}:
      run_result(~S,~runner,level,True{},Sys.run(~S,~P.Store<S>,~P.Resources<S>,~Unit,~G.HookOperation,~String,~Unit,~runner,flow,world,G.FlowEnter{}))
    case Owners{flow,level}, G.LevelEnter{}:
      run_result(~S,~runner,flow,False{},Sys.run(~S,~P.Store<S>,~P.Resources<S>,~Unit,~G.HookOperation,~String,~Unit,~runner,level,world,G.LevelEnter{}))

def hook_completed(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,label: String,result: Owners<S,runner> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>) -> Owners<S,runner> & W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match result:
    case (owners,Sys.Succeeded{world,_}): (owners,trace(~S,label,world))
    case (owners,Sys.Failed{world,error}): (owners,trace(~S,"HOOK_FAILED:" ++ error,world))

# These selected enter schedules run only for a newly published transition.
# Failure is explicitly observed; it is not a claim of #49 marker atomicity.
def invoke_flow(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,owners: Owners<S,runner>,checked: W.World<S,P.Store<S>,P.Resources<S>,Unit> & M.Slot<S,P.FlowToken,P.Flow>,enabled: Bool) -> Owners<S,runner> & W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match checked enabled:
    case (world,M.Present{P.Pause{},_,_,True{}}), True{}: hook_completed(~S,~runner,"Flow",run_hook(~S,~runner,owners,world,G.FlowEnter{}))
    case (world,_), _: (owners,world)
def invoke_level(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,owners: Owners<S,runner>,checked: W.World<S,P.Store<S>,P.Resources<S>,Unit> & M.Slot<S,P.LevelToken,P.Level>,enabled: Bool) -> Owners<S,runner> & W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match checked enabled:
    case (world,M.Present{P.Middle{},_,_,True{}}), True{}: hook_completed(~S,~runner,"Level",run_hook(~S,~runner,owners,world,G.LevelEnter{}))
    case (world,_), _: (owners,world)

def flow_step(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,owners: Owners<S,runner>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,captured: M.Snapshot<P.Flow>,enabled: Bool) -> Owners<S,runner> & W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  invoke_flow(~S,~runner,owners,P.flow_take(~S,Marker.flow_step(~S,world,captured,False{})),enabled)
def level_step(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,owners: Owners<S,runner>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,captured: M.Snapshot<P.Level>,enabled: Bool) -> Owners<S,runner> & W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  invoke_level(~S,~runner,owners,P.level_take(~S,Marker.level_step(~S,world,captured,False{})),enabled)

def captured_marker(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,owners: Owners<S,runner>,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & Marker.Captured,+enabled: Bool) -> Owners<S,runner> & W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match pair:
    case (world,Marker.Captured{flow,level}):
      M.run_owned_marker(~S,~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~Owners<S,runner>,M.OwnedMarker{[h => w => flow_step(~S,~runner,h,w,flow,enabled),h => w => level_step(~S,~runner,h,w,level,enabled)]},owners,world)
def run(~S: Data,~runner: W.World<S,P.Store<S>,P.Resources<S>,Unit> -> G.HookOperation -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>,owners: Owners<S,runner>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,enabled: Bool) -> Owners<S,runner> & W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  captured_marker(~S,~runner,owners,W.observe_resource(~S,~P.Store<S>,~P.Resources<S>,~Unit,~Marker.Captured,~(resources => Marker.capture_resource(~S,resources)),P.pulse(~S,W.barrier(~S,~P.Store<S>,~P.Resources<S>,~Unit,world))),enabled)
