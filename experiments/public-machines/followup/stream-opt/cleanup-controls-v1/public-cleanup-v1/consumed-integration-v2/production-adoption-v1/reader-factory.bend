import Base
import reader-cleanup-ports.bend as PortOps
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/system.bend as Sys
import followup/observations.bend as F
import slots.bend as Slots
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/system-instance.bend as Managed
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/system-cleanup.bend as Cleanup
import provider.bend as P
import readers.bend as R
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/ports.bend as Ports
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/machine-stream.bend as St
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/world.bend as W

# Schema-specific ordinary API: adapters are bound here once, not supplied by callers.
def create(~S: Data,+namespace: U32,+id: U32,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & Ports.Two<S,P.FlowToken,P.LevelToken>:
  (world,Ports.Two{St.Reader{namespace,id},St.Reader{namespace,id}})

def register(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,+name: String) -> Managed.Registration<S,P.Store<S>,P.Resources<S>,Unit,R.Input,R.Failure,R.Delivery,(world => input => R.runner(~S,world,input)),Ports.Two<S,P.FlowToken,P.LevelToken>,(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),(world => ports => PortOps.remove_ports(~S,world,ports))>:
  Managed.register(~S,~P.Store<S>,~P.Resources<S>,~Unit,~R.Input,~R.Failure,~R.Delivery,~(world => input => R.runner(~S,world,input)),~Ports.Two<S,P.FlowToken,P.LevelToken>,~(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),~(world => ports => PortOps.remove_ports(~S,world,ports)),~(ns => id => world => create(~S,ns,id,world)),world,name,["transition.Flow.read","transition.Level.read"])

def dispose(~S: Data,instance: Managed.Instance<S,P.Store<S>,P.Resources<S>,Unit,R.Input,R.Failure,R.Delivery,(world => input => R.runner(~S,world,input)),Ports.Two<S,P.FlowToken,P.LevelToken>,(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),(world => ports => PortOps.remove_ports(~S,world,ports))>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Managed.Disposal<S,P.Store<S>,P.Resources<S>,Unit,R.Input,R.Failure,R.Delivery,(world => input => R.runner(~S,world,input)),Ports.Two<S,P.FlowToken,P.LevelToken>,(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),(world => ports => PortOps.remove_ports(~S,world,ports))>:
  Managed.dispose(~S,~P.Store<S>,~P.Resources<S>,~Unit,~R.Input,~R.Failure,~R.Delivery,~(world => input => R.runner(~S,world,input)),~Ports.Two<S,P.FlowToken,P.LevelToken>,~(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),~(world => ports => PortOps.remove_ports(~S,world,ports)),instance,world)

def invoke(~S: Data,instance: Managed.Instance<S,P.Store<S>,P.Resources<S>,Unit,R.Input,R.Failure,R.Delivery,(world => input => R.runner(~S,world,input)),Ports.Two<S,P.FlowToken,P.LevelToken>,(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),(world => ports => PortOps.remove_ports(~S,world,ports))>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,fails: Bool) -> Managed.RunResult<S,P.Store<S>,P.Resources<S>,Unit,R.Input,R.Failure,R.Delivery,(world => input => R.runner(~S,world,input)),Ports.Two<S,P.FlowToken,P.LevelToken>,(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),(world => ports => PortOps.remove_ports(~S,world,ports))>:
  match instance:
    case Managed.Instance{Cleanup.Instance{registry,Ports.Two{St.Reader{+ns,+id},St.Reader{+other,+jd}}}}:
      Managed.run(~S,~P.Store<S>,~P.Resources<S>,~Unit,~R.Input,~R.Failure,~R.Delivery,~(world => input => R.runner(~S,world,input)),~Ports.Two<S,P.FlowToken,P.LevelToken>,~(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),~(world => ports => PortOps.remove_ports(~S,world,ports)),Managed.bind(~S,~P.Store<S>,~P.Resources<S>,~Unit,~R.Input,~R.Failure,~R.Delivery,~(world => input => R.runner(~S,world,input)),~Ports.Two<S,P.FlowToken,P.LevelToken>,~(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),~(world => ports => PortOps.remove_ports(~S,world,ports)),registry,Ports.Two{St.Reader{ns,id},St.Reader{other,jd}}),world,R.Input{ns,id,other,jd,fails})

# Concrete ordinary schema instance retains the factory-bound managed owner.
type Instance<S: Data> is Type:
  Instance{owned: Managed.Instance<S,P.Store<S>,P.Resources<S>,Unit,R.Input,R.Failure,R.Delivery,(world => input => R.runner(~S,world,input)),Ports.Two<S,P.FlowToken,P.LevelToken>,(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),(world => ports => PortOps.remove_ports(~S,world,ports))>}
type Provision<S: Data> is Type:
  Provisioned{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,instance: Instance<S>}
  ProvisionFailed{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>}
type Returned<S: Data> is Type:
  Returned{instance: Instance<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,delivery: Maybe<&2,R.Delivery>,status: String}
type Disposal<S: Data> is Type:
  Cleaned{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>}
  CleanupRejected{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,instance: Instance<S>}

def provisioned(~S: Data,result: Managed.Registration<S,P.Store<S>,P.Resources<S>,Unit,R.Input,R.Failure,R.Delivery,(world => input => R.runner(~S,world,input)),Ports.Two<S,P.FlowToken,P.LevelToken>,(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),(world => ports => PortOps.remove_ports(~S,world,ports))>) -> Provision<S>:
  match result:
    case Managed.RegistrationFailed{world}: ProvisionFailed{world}
    case Managed.Registered{world,owned}: Provisioned{world,Instance{owned}}
def provision(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,+name: String) -> Provision<S>:
  provisioned(~S,register(~S,world,name))
def invoked(~S: Data,result: Managed.RunResult<S,P.Store<S>,P.Resources<S>,Unit,R.Input,R.Failure,R.Delivery,(world => input => R.runner(~S,world,input)),Ports.Two<S,P.FlowToken,P.LevelToken>,(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),(world => ports => PortOps.remove_ports(~S,world,ports))>) -> Returned<S>:
  match result:
    case Managed.Completed{owned,Sys.Succeeded{world,delivery}}: Returned{Instance{owned},world,Some{delivery},"ok"}
    case Managed.Completed{owned,Sys.Failed{world,R.Failure{error,delivery}}}: Returned{Instance{owned},world,delivery,error}
    case Managed.RegistrationRejected{owned,world,_}: Returned{Instance{owned},world,None{},"reader-registration-rejected"}
def invoke_owned(~S: Data,instance: Instance<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,fails: Bool) -> Returned<S>:
  match instance:
    case Instance{owned}: invoked(~S,invoke(~S,owned,world,fails))
def disposed_owned(~S: Data,result: Managed.Disposal<S,P.Store<S>,P.Resources<S>,Unit,R.Input,R.Failure,R.Delivery,(world => input => R.runner(~S,world,input)),Ports.Two<S,P.FlowToken,P.LevelToken>,(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),(world => ports => PortOps.remove_ports(~S,world,ports))>) -> Disposal<S>:
  match result:
    case Managed.Disposed{world}: Cleaned{world}
    case Managed.Rejected{world,owned}: CleanupRejected{world,Instance{owned}}
def dispose_owned(~S: Data,instance: Instance<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Disposal<S>:
  match instance:
    case Instance{owned}: disposed_owned(~S,dispose(~S,owned,world))

def legacy_returned(~S: Data,instance: R.Instance<S,(world => input => R.runner(~S,world,input))>) -> Instance<S>:
  match instance:
    case R.Instance{registry,flow,level}: Instance{Managed.bind(~S,~P.Store<S>,~P.Resources<S>,~Unit,~R.Input,~R.Failure,~R.Delivery,~(world => input => R.runner(~S,world,input)),~Ports.Two<S,P.FlowToken,P.LevelToken>,~(ports => ns => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,ns,id)),~(world => ports => PortOps.remove_ports(~S,world,ports)),registry,Ports.Two{flow,level})}
def viewed(~S: Data,pair: Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>> & String) -> Instance<S> & String:
  match pair:
    case (Slots.Entry{_,instance},view): (legacy_returned(~S,instance),view)
def view(~S: Data,instance: Instance<S>) -> Instance<S> & String:
  match instance:
    case Instance{Managed.Instance{Cleanup.Instance{registry,Ports.Two{flow,level}}}}: viewed(~S,F.reader(~S,Slots.Entry{99,R.Instance{registry,flow,level}}))
def skipped(~S: Data,pair: R.Instance<S,(world => input => R.runner(~S,world,input))> & W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Instance<S> & W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match pair:
    case (instance,world): (legacy_returned(~S,instance),world)
def skip(~S: Data,instance: Instance<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Instance<S> & W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match instance:
    case Instance{Managed.Instance{Cleanup.Instance{registry,Ports.Two{flow,level}}}}: skipped(~S,R.skip(~S,~(world => input => R.runner(~S,world,input)),R.Instance{registry,flow,level},world))
