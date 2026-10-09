import Base
import provider.bend as P
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/ports.bend as Ports
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def dispose_streams(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,flowId: U32,levelId: U32) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,fs,ls,frame,tick,trace},events,commands,regs,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,St.dispose(~P.Flow,fs,flowId),St.dispose(~P.Level,ls,levelId),frame,tick,trace},events,commands,regs,nextSystem,clock}
def remove_ports(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,ports: Ports.Two<S,P.FlowToken,P.LevelToken>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match ports:
    case Ports.Two{St.Reader{_,id},St.Reader{_,jd}}: dispose_streams(~S,world,id,jd)
