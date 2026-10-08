import Base
import types.bend as T
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/machine.bend as M
# machine-world imports are installed into the immutable caller stage only.
import ../../../../src/ecs/machine-world.bend as MW

def take_resource(~S:Data,resources:T.Resources<S>) -> T.Resources<S> & M.Slot<S,T.MachineKey,T.State>:
  match resources:
    case T.Resources{owned,+slot,stream,reader,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog}:
      (T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog},slot)
def put_resource(~S:Data,resources:T.Resources<S>,slot:M.Slot<S,T.MachineKey,T.State>) -> T.Resources<S>:
  match resources:
    case T.Resources{owned,_,stream,reader,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog}:
      T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog}
def take(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & M.Slot<S,T.MachineKey,T.State>:
  MW.take(~S,~T.MachineKey,~T.State,~T.Store<S>,~T.Resources<S>,~Unit,~(r => take_resource(~S,r)),world)
def put(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,slot:M.Slot<S,T.MachineKey,T.State>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  MW.put(~S,~T.MachineKey,~T.State,~T.Store<S>,~T.Resources<S>,~Unit,~(r => s => put_resource(~S,r,s)),world,slot)
