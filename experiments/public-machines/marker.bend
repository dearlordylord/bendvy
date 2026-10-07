import Base
import machine.bend as M
import provider.bend as P
import stream.bend as St
import ../../src/ecs/world.bend as W

type Captured is Data:
  Captured{flow: M.Snapshot<P.Flow>,level: M.Snapshot<P.Level>}

# Development model of the oracle's successful enter hooks. These direct
# metadata updates are not registered-system work and cannot support feature
# completion or equivalent-work timing; the owned registered-hook route is
# still required. This probe preserves the observed later-key exception.
def flow_hook(~S: Data,slot: M.Slot<S,P.FlowToken,P.Flow>,level: M.Slot<S,P.LevelToken,P.Level>) -> M.Slot<S,P.FlowToken,P.Flow> & M.Slot<S,P.LevelToken,P.Level>:
  match slot:
    case M.Present{P.Pause{},pending,previous,changed}:
      (M.Present{P.Pause{},M.Queued{P.Boot{},False{}},previous,changed},M.queue(~S,~P.LevelToken,~P.Level,level,P.High{},False{}))
    case slot: (slot,level)

def level_hook(~S: Data,flow: M.Slot<S,P.FlowToken,P.Flow>,level: M.Slot<S,P.LevelToken,P.Level>) -> M.Slot<S,P.FlowToken,P.Flow> & M.Slot<S,P.LevelToken,P.Level>:
  match level:
    case M.Present{P.Middle{},pending,previous,changed}:
      (M.queue(~S,~P.FlowToken,~P.Flow,flow,P.Boot{},False{}),M.Present{P.Middle{},pending,previous,changed})
    case level: (flow,level)

def flow_published(~S: Data,owned: Array<U32>,pair: M.Slot<S,P.FlowToken,P.Flow> & M.Slot<S,P.LevelToken,P.Level>,stream: St.Stream<P.Flow>,levelStream: St.Stream<P.Level>,frame: Nat,tick: Nat,trace: List<&2,String>) -> P.Resources<S>:
  match pair:
    case (M.Present{P.Pause{},pending,previous,changed},level):
      P.Resources{owned,M.Present{P.Pause{},pending,previous,changed},level,stream,levelStream,frame,1n+tick,List.append(&2,String,trace,["Flow"])}
    case (flow,level): P.Resources{owned,flow,level,stream,levelStream,frame,tick,trace}

def flow_applied(~S: Data,resources: P.Resources<S>,result: M.Applied<S,P.FlowToken,P.Flow>,hooks: Bool) -> P.Resources<S>:
  match resources result hooks:
    case P.Resources{owned,_,level,flowStream,levelStream,frame,tick,trace} M.Applied{slot,None{}} _:
      P.Resources{owned,slot,level,flowStream,levelStream,frame,tick,trace}
    case P.Resources{owned,_,level,flowStream,levelStream,frame,+tick,trace} M.Applied{slot,Some{event}} False{}:
      P.Resources{owned,slot,level,St.publish(~P.Flow,flowStream,1n+tick,event),levelStream,frame,1n+tick,trace}
    case P.Resources{owned,_,level,flowStream,levelStream,frame,+tick,trace} M.Applied{slot,Some{event}} True{}:
      flow_published(~S,owned,flow_hook(~S,slot,level),St.publish(~P.Flow,flowStream,1n+tick,event),levelStream,frame,1n+tick,trace)

def level_published(~S: Data,owned: Array<U32>,pair: M.Slot<S,P.FlowToken,P.Flow> & M.Slot<S,P.LevelToken,P.Level>,stream: St.Stream<P.Flow>,levelStream: St.Stream<P.Level>,frame: Nat,tick: Nat,trace: List<&2,String>) -> P.Resources<S>:
  match pair:
    case (flow,M.Present{P.Middle{},pending,previous,changed}):
      P.Resources{owned,flow,M.Present{P.Middle{},pending,previous,changed},stream,levelStream,frame,1n+tick,List.append(&2,String,trace,["Level"])}
    case (flow,level): P.Resources{owned,flow,level,stream,levelStream,frame,tick,trace}

def level_applied(~S: Data,resources: P.Resources<S>,result: M.Applied<S,P.LevelToken,P.Level>,hooks: Bool) -> P.Resources<S>:
  match resources result hooks:
    case P.Resources{owned,flow,_,flowStream,levelStream,frame,tick,trace} M.Applied{slot,None{}} _:
      P.Resources{owned,flow,slot,flowStream,levelStream,frame,tick,trace}
    case P.Resources{owned,flow,_,flowStream,levelStream,frame,+tick,trace} M.Applied{slot,Some{event}} False{}:
      P.Resources{owned,flow,slot,flowStream,St.publish(~P.Level,levelStream,1n+tick,event),frame,1n+tick,trace}
    case P.Resources{owned,flow,_,flowStream,levelStream,frame,+tick,trace} M.Applied{slot,Some{event}} True{}:
      level_published(~S,owned,level_hook(~S,flow,slot),flowStream,St.publish(~P.Level,levelStream,1n+tick,event),frame,1n+tick,trace)

def flow_resource(~S: Data,resources: P.Resources<S>,captured: M.Snapshot<P.Flow>,hooks: Bool) -> P.Resources<S>:
  match resources:
    case P.Resources{owned,+flow,level,flowStream,levelStream,frame,tick,trace}:
      flow_applied(~S,P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace},M.apply_snapshot(~S,~P.FlowToken,~P.Flow,~P.flow_same,flow,captured),hooks)

def level_resource(~S: Data,resources: P.Resources<S>,captured: M.Snapshot<P.Level>,hooks: Bool) -> P.Resources<S>:
  match resources:
    case P.Resources{owned,flow,+level,flowStream,levelStream,frame,tick,trace}:
      level_applied(~S,P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace},M.apply_snapshot(~S,~P.LevelToken,~P.Level,~P.level_same,level,captured),hooks)

def map_resource(~S: Data,effect: P.Resources<S> -> P.Resources<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,effect(resources),events,commands,registrations,nextSystem,clock}

def flow_step(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,captured: M.Snapshot<P.Flow>,hooks: Bool) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  map_resource(~S,(resources => flow_resource(~S,resources,captured,hooks)),world)

def level_step(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,captured: M.Snapshot<P.Level>,hooks: Bool) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  map_resource(~S,(resources => level_resource(~S,resources,captured,hooks)),world)

def capture_resource(~S: Data,resources: P.Resources<S>) -> P.Resources<S> & Captured:
  match resources:
    case P.Resources{owned,+flow,+level,flowStream,levelStream,frame,tick,trace}:
      (P.Resources{owned,M.clear_changed(~S,~P.FlowToken,~P.Flow,flow),M.clear_changed(~S,~P.LevelToken,~P.Level,level),flowStream,levelStream,frame,tick,trace},Captured{M.snapshot(~S,~P.FlowToken,~P.Flow,flow),M.snapshot(~S,~P.LevelToken,~P.Level,level)})

def captured_marker(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & Captured,+hooks: Bool) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match pair:
    case (world,Captured{flow,level}):
      M.run_marker(~S,~W.World<S,P.Store<S>,P.Resources<S>,Unit>,M.Marker{[world => flow_step(~S,world,flow,hooks),world => level_step(~S,world,level,hooks)]},world)

def run(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,hooks: Bool) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  captured_marker(~S,W.observe_resource(~S,~P.Store<S>,~P.Resources<S>,~Unit,~Captured,~(resources => capture_resource(~S,resources)),P.pulse(~S,W.barrier(~S,~P.Store<S>,~P.Resources<S>,~Unit,world))),hooks)
