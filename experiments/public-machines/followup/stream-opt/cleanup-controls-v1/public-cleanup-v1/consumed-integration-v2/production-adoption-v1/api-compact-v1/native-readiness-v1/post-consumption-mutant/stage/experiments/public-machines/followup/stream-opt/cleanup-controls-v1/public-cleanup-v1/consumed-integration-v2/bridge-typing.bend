import Base
import ../../../../../provider.bend as P
import ../../../../../readers.bend as R
import ../current-core/ecs/machine-stream.bend as St
import ../current-core/ecs/world.bend as W
import ../current-core/ecs/system.bend as Sys
import ../adapter.bend as GC
import ../ports.bend as Ports

# Named-parameter bridge typing only; no closed scene/main specialization or runtime credit.
def dispose_streams(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,flowId: U32,levelId: U32) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,fs,ls,frame,tick,trace},events,commands,regs,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,St.dispose(~P.Flow,fs,flowId),St.dispose(~P.Level,ls,levelId),frame,tick,trace},events,commands,regs,nextSystem,clock}
type Cleanup<S: Data> is Type:
  Cleaned{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>}
  CleanupRejected{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,instance: R.Instance<S,(world => input => R.runner(~S,world,input))>}
def remove_ports(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,ports: Ports.Two<S,P.FlowToken,P.LevelToken>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match ports:
    case Ports.Two{St.Reader{_,id},St.Reader{_,jd}}: dispose_streams(~S,world,id,jd)
def generic_cleanup_returned(~S: Data,result: GC.Cleanup<S,P.Store<S>,P.Resources<S>,Unit,R.Input,R.Failure,R.Delivery,(world => input => R.runner(~S,world,input)),Ports.Two<S,P.FlowToken,P.LevelToken>>) -> Cleanup<S>:
  match result:
    case GC.Cleaned{world}: Cleaned{world}
    case GC.CleanupRejected{world,GC.Instance{registry,Ports.Two{flow,level}}}: CleanupRejected{world,R.Instance{registry,flow,level}}
def cleanup(~S: Data,instance: R.Instance<S,(world => input => R.runner(~S,world,input))>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Cleanup<S>:
  match instance:
    case R.Instance{registry,flow,level}:
      generic_cleanup_returned(~S,GC.cleanup(~S,~P.Store<S>,~P.Resources<S>,~Unit,~R.Input,~R.Failure,~R.Delivery,~(world => input => R.runner(~S,world,input)),~Ports.Two<S,P.FlowToken,P.LevelToken>,~(ports => namespace => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,namespace,id)),~(world => ports => remove_ports(~S,world,ports)),GC.Instance{registry,Ports.Two{flow,level}},world))


def main() -> Unit:
  Unit{}
