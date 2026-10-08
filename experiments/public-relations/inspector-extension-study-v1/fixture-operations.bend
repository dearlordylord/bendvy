import Base
import fixture-state.bend as State
import root-source/world.bend as W
import root-source/machine.bend as M
import root-source/machine-world.bend as MW
import root-source/transaction.bend as Tx

def flow_take(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & M.Slot<S,State.FlowToken,U32>:
  MW.take(~S,~State.FlowToken,~U32,~State.Store<S>,~State.Resources<S>,~U32,~State.flow(~S),world)
def level_take(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & M.Slot<S,State.LevelToken,U32>:
  MW.take(~S,~State.LevelToken,~U32,~State.Store<S>,~State.Resources<S>,~U32,~State.level(~S),world)
def flow_put(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,slot:M.Slot<S,State.FlowToken,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  MW.put(~S,~State.FlowToken,~U32,~State.Store<S>,~State.Resources<S>,~U32,~State.put_flow(~S),world,slot)
def level_put(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,slot:M.Slot<S,State.LevelToken,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  MW.put(~S,~State.LevelToken,~U32,~State.Store<S>,~State.Resources<S>,~U32,~State.put_level(~S),world,slot)
def queue(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,flow:U32,level:U32) -> Tx.Tx<W.World<S,State.Store<S>,State.Resources<S>,U32>,U32>:
  M.write(~S,~State.LevelToken,~U32,~W.World<S,State.Store<S>,State.Resources<S>,U32>,~U32,~level_take(~S),~level_put(~S),M.write(~S,~State.FlowToken,~U32,~W.World<S,State.Store<S>,State.Resources<S>,U32>,~U32,~flow_take(~S),~flow_put(~S),Tx.begin(~W.World<S,State.Store<S>,State.Resources<S>,U32>,~U32,world),flow,False{}),level,False{})
def enqueue_commands(~S:Data,commands:List<&1,(W.World<S,State.Store<S>,State.Resources<S>,U32> -> W.World<S,State.Store<S>,State.Resources<S>,U32>)>,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  match commands:
    case []:world
    case command <> rest:enqueue_commands(~S,rest,W.enqueue(~S,~State.Store<S>,~State.Resources<S>,~U32,world,command))
def enqueue(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,commands:List<&1,(W.World<S,State.Store<S>,State.Resources<S>,U32> -> W.World<S,State.Store<S>,State.Resources<S>,U32>)>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  enqueue_commands(~S,commands,world)
def outcome(failed:Bool) -> Tx.Outcome<String>:
  match failed:
    case False{}:Tx.Success{}
    case True{}:Tx.Failure{"failed-next"}
def publish(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,events:List<&2,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  W.event_publish(~S,~State.Store<S>,~State.Resources<S>,~U32,world,events)
def finish(~S:Data,tx:Tx.Tx<W.World<S,State.Store<S>,State.Resources<S>,U32>,U32>,failed:Bool) -> Tx.Returned<W.World<S,State.Store<S>,State.Resources<S>,U32>,String>:
  Tx.finish(~W.World<S,State.Store<S>,State.Resources<S>,U32>,~U32,~String,~enqueue(~S),~publish(~S),tx,outcome(failed))
def flow_published(~S:Data,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & Unit) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  (world,_)=result
  world
def flow_resources(~S:Data,tick:Nat,event:M.Transition<U32>,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock}:flow_published(~S,W.observe_resource_finish(~S,~State.Store<S>,~State.Resources<S>,~U32,~Unit,State.flow_event(~S,tick,event,resources),ns,next,high,live,capacity,depth,store,events,commands,registrations,nextSystem,clock))
def flow_clocked(~S:Data,event:M.Transition<U32>,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & U32) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  (world,tick)=result
  flow_resources(~S,U32.to_nat(tick),event,world)
def flow_notice(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,event:Maybe<&2,M.Transition<U32>>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  match event:
    case None{}:world
    case Some{event}:flow_clocked(~S,event,W.advance_clock(~S,~State.Store<S>,~State.Resources<S>,~U32,world))
def flow_applied(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,applied:M.Applied<S,State.FlowToken,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  match applied:
    case M.Applied{slot,event}:flow_notice(~S,flow_put(~S,world,slot),event)
def flow_apply(~S:Data,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & M.Slot<S,State.FlowToken,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  (world,+slot)=result
  flow_applied(~S,world,M.apply_snapshot(~S,~State.FlowToken,~U32,~U32.is_eq,slot,M.snapshot(~S,~State.FlowToken,~U32,slot)))
def flow_step(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  flow_apply(~S,flow_take(~S,world))
def level_published(~S:Data,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & Unit) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  (world,_)=result
  world
def level_resources(~S:Data,tick:Nat,event:M.Transition<U32>,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock}:level_published(~S,W.observe_resource_finish(~S,~State.Store<S>,~State.Resources<S>,~U32,~Unit,State.level_event(~S,tick,event,resources),ns,next,high,live,capacity,depth,store,events,commands,registrations,nextSystem,clock))
def level_clocked(~S:Data,event:M.Transition<U32>,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & U32) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  (world,tick)=result
  level_resources(~S,U32.to_nat(tick),event,world)
def level_notice(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,event:Maybe<&2,M.Transition<U32>>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  match event:
    case None{}:world
    case Some{event}:level_clocked(~S,event,W.advance_clock(~S,~State.Store<S>,~State.Resources<S>,~U32,world))
def level_applied(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,applied:M.Applied<S,State.LevelToken,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  match applied:
    case M.Applied{slot,event}:level_notice(~S,level_put(~S,world,slot),event)
def level_apply(~S:Data,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & M.Slot<S,State.LevelToken,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  (world,+slot)=result
  level_applied(~S,world,M.apply_snapshot(~S,~State.LevelToken,~U32,~U32.is_eq,slot,M.snapshot(~S,~State.LevelToken,~U32,slot)))
def level_step(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  level_apply(~S,level_take(~S,world))
# Marker publishes every Applied.event to its separate existing machine stream.
# Inspector itself receives no stream capability; retention acceptance is separate.
def marker(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32>:
  M.run_marker(~S,~W.World<S,State.Store<S>,State.Resources<S>,U32>,M.Marker{[flow_step(~S),level_step(~S)]},world)
