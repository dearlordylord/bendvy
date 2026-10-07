import Base
import full-provider.bend as P
import full-actions.bend as A
import handlers-tracked.bend as H
import ../../public-machines/machine.bend as M
import ../../public-machines/stream.bend as St
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys

type MarkerResult<S:Data,-failure:H.Phase -> U32 -> Bool> is Type:
  MarkerResult{world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,flow:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,status:String}
def level_published_resource(~S:Data,resource:P.Resources<S>,event:M.Transition<P.Level>) -> P.Resources<S>:
  match resource:
    case P.Resources{owned,flow,level,stream,levelStream,frame,+tick,trace,aux}: P.Resources{owned,flow,level,stream,St.publish(~P.Level,levelStream,1n+tick,event),frame,1n+tick,trace,aux}
def level_published(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,event:M.Transition<P.Level>) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>:
  P.map_resources(~S,(resource => level_published_resource(~S,resource,event)),world)
def level_result(~S:Data,~failure:H.Phase -> U32 -> Bool,flow:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,result:H.HandlerResult<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>) -> MarkerResult<S,failure>:
  match result:
    case H.Completed{owners,world}: MarkerResult{world,flow,owners,"ok"}
    case H.Stopped{owners,world,_,error}: MarkerResult{world,flow,owners,error}
def after_flow(~S:Data,~failure:H.Phase -> U32 -> Bool,level:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,captured:M.Snapshot<P.Level>,result:H.HandlerResult<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>) -> MarkerResult<S,failure>:
  match result:
    case H.Stopped{flow,world,_,error}: MarkerResult{world,flow,level,error}
    case H.Completed{flow,world}: level_result(~S,~failure,flow,H.run(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,~P.Level,~A.level_runner(~S),~P.LevelToken,~(world => P.level_take(~S,world)),~(world => slot => P.level_put(~S,world,slot)),~(world => event => level_published(~S,world,event)),~P.level_same,level,world,captured))
def captured(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,levelRegistry:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>) -> MarkerResult<S,failure>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,+flow,+level,flowStream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock}:
      after_flow(~S,~failure,levelRegistry,M.snapshot(~S,~P.LevelToken,~P.Level,level),A.apply(~S,~failure,owners,W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,M.clear_changed(~S,~P.FlowToken,~P.Flow,flow),M.clear_changed(~S,~P.LevelToken,~P.Level,level),flowStream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock},M.snapshot(~S,~P.FlowToken,~P.Flow,flow)))
def marker(~S:Data,~failure:H.Phase -> U32 -> Bool,owners:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Flow,A.runner(~S,~failure)>,levelRegistry:H.Owners<S,P.Store<S>,P.Resources<S>,P.Ping,P.Level,A.level_runner(~S)>,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>) -> MarkerResult<S,failure>:
  captured(~S,~failure,owners,levelRegistry,P.pulse(~S,W.barrier(~S,~P.Store<S>,~P.Resources<S>,~P.Ping,world)))
