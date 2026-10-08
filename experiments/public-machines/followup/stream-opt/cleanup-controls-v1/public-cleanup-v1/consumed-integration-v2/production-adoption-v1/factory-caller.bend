import Base
import reader-cleanup-ports.bend as PortOps
import reader-factory.bend as Factory
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/system-instance.bend as Managed
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/system-cleanup.bend as Cleanup
import provider.bend as P
import readers.bend as R
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/ports.bend as Ports
import followup/stream-opt/cleanup-controls-v1/caller-core.bend as Core
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/machine-stream.bend as St
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/world.bend as W

type Attempt<S: Data> is Type:
  RegistrationFailed{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>}
  Invoked{result: Managed.RunResult<S,P.Store<S>,P.Resources<S>,Unit,R.Input,R.Failure,R.Delivery,(world => input => R.runner(~S,world,input)),Ports.Two<S,P.FlowToken,P.LevelToken>,(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),(world => ports => PortOps.remove_ports(~S,world,ports))>}

def registered(~S: Data,fails: Bool,result: Managed.Registration<S,P.Store<S>,P.Resources<S>,Unit,R.Input,R.Failure,R.Delivery,(world => input => R.runner(~S,world,input)),Ports.Two<S,P.FlowToken,P.LevelToken>,(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),(world => ports => PortOps.remove_ports(~S,world,ports))>) -> Attempt<S>:
  match result:
    case Managed.RegistrationFailed{world}: RegistrationFailed{world}
    case Managed.Registered{world,instance}: Invoked{Factory.invoke(~S,instance,world,fails)}

# Application callers provide only schema/world/name/failure input, never adapters.
def start(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,+name: String,fails: Bool) -> Attempt<S>:
  registered(~S,fails,Factory.register(~S,world,name))

def main() -> Unit:
  Unit{}
