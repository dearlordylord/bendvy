import Base
import ../../public-machines/machine.bend as M
import full-provider.bend as P
import full-observe.bend as O
import event-stream.bend as ES
import ../../public-machines/stream.bend as St
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys

type Input is Data:
  Input{id:U32,name:String,fail:Bool}
type View is Data:
  View{ping:Ev.Reading<P.Ping>,flow:Ev.Reading<M.Transition<P.Flow>>,level:Ev.Reading<M.Transition<P.Level>>}
def values_text(view:View) -> String:
  match view:
    case View{Ev.Reading{ping,a},Ev.Reading{flow,b},Ev.Reading{level,c}}:
      "ping=" ++ List.show(&2,P.Ping,O.ping,ping) ++ ";flow=" ++ List.show(&2,M.Transition<P.Flow>,(value => O.transition(~P.Flow,~O.flow,value)),flow) ++ ";level=" ++ List.show(&2,M.Transition<P.Level>,(value => O.transition(~P.Level,~O.level,value)),level) ++ ";lagged=" ++ O.bool(a) ++ "," ++ O.bool(b) ++ "," ++ O.bool(c)
def activate_resource(~S:Data,resource:P.Resources<S>,+id:U32) -> P.Resources<S> & View:
  match resource:
    case P.Resources{owned,flow,level,+flowStream,+levelStream,frame,+tick,trace,P.Aux{locals,+ping,attempts,deliveries,phase,position,enabled}}:
      +ping=ES.activate(~P.Ping,ping,id,Nat.sub(tick,1n))
      +flowStream=St.activate(~P.Flow,flowStream,id,Nat.sub(tick,1n))
      +levelStream=St.activate(~P.Level,levelStream,id,Nat.sub(tick,1n))
      (P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,P.Aux{locals,ping,attempts,deliveries,phase,position,enabled}},View{ES.observe(~P.Ping,ping,id,tick),St.observe(~P.Flow,flowStream,id,tick),St.observe(~P.Level,levelStream,id,tick)})
def active_join(~S:Data,pair:P.Resources<S> & View,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & View:
  match pair world:
    case (resource,view), W.World{ns,next,high,live,capacity,depth,store,_,events,commands,registrations,nextSystem,clock}:
      (W.World{ns,next,high,live,capacity,depth,store,resource,events,commands,registrations,nextSystem,clock},view)
def activate(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,id:U32) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & View:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resource,events,commands,registrations,nextSystem,clock}:
      active_join(~S,activate_resource(~S,resource,id),W.World{ns,next,high,live,capacity,depth,store,P.initial_resources(~S),events,commands,registrations,nextSystem,clock})
def complete_resource(~S:Data,resource:P.Resources<S>,+id:U32,+cursor:Nat) -> P.Resources<S>:
  match resource:
    case P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,P.Aux{locals,ping,attempts,deliveries,phase,position,enabled}}:
      P.Resources{owned,flow,level,St.complete(~P.Flow,flowStream,id,cursor,True{}),St.complete(~P.Level,levelStream,id,cursor,True{}),frame,tick,trace,P.Aux{locals,ES.complete(~P.Ping,ping,id,cursor,True{}),attempts,deliveries,phase,position,enabled}}
def complete(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,id:U32,cursor:Nat) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>:
  P.map_resources(~S,(resource => complete_resource(~S,resource,id,cursor)),world)
def record_delivery_resource(~S:Data,resource:P.Resources<S>,text:String) -> P.Resources<S>:
  match resource:
    case P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,P.Aux{locals,ping,attempts,deliveries,phase,position,enabled}}:
      P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,P.Aux{locals,ping,attempts,List.append(&2,String,deliveries,[text]),phase,position,enabled}}
def delivery(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,text:String) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>:
  P.map_resources(~S,(resource => record_delivery_resource(~S,resource,text)),world)
def failed_input(fail:Bool) -> Bool: fail
def reader_outcome(~S:Data,id:U32,failed:Bool,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>:
  match failed world:
    case True{}, world: Sys.Failed{world,"reader-failed"}
    case False{}, W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,flowStream,levelStream,frame,+tick,trace,aux},events,commands,registrations,nextSystem,clock}:
      Sys.Succeeded{complete(~S,W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock},id,tick),Unit{}}
def returned(~S:Data,+id:U32,name:String,failed:Bool,pair:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & View) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>:
  (world,view)=pair
  reader_outcome(~S,id,failed,delivery(~S,world,name ++ "|" ++ values_text(view)))
def runner(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,input:Input) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,String,Unit>:
  match input:
    case Input{+id,name,fail}: returned(~S,id,name,fail,activate(~S,P.pulse(~S,world),id))

def record_attempt_resource(~S:Data,resource:P.Resources<S>,text:String) -> P.Resources<S>:
  match resource:
    case P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,P.Aux{locals,ping,attempts,deliveries,phase,position,enabled}}:
      P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,P.Aux{locals,ping,List.append(&2,String,attempts,[text]),deliveries,phase,position,enabled}}
def attempted(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,text:String) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>:
  P.map_resources(~S,(resource => record_attempt_resource(~S,resource,text)),world)
def hook_recorded(~S:Data,name:String,attempt:U32,active:String,pair:W.World<S,P.Store<S>,P.Resources<S>,P.Ping> & View) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>:
  match pair:
    case (W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,+flow,+level,stream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock},view):
      attempted(~S,W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,stream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock},name ++ "|" ++ values_text(view) ++ ";local=" ++ U32.show(attempt) ++ ";current=" ++ O.slot(~S,~P.FlowToken,~P.Flow,~O.flow,flow) ++ "," ++ O.slot(~S,~P.LevelToken,~P.Level,~O.level,level) ++ ";active=" ++ active)
def before_hook(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>,id:U32,name:String,attempt:U32,active:String) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>:
  hook_recorded(~S,name,attempt,active,activate(~S,P.pulse(~S,world),id))
def published_resource(~S:Data,resource:P.Resources<S>,event:P.Ping) -> P.Resources<S>:
  match resource:
    case P.Resources{owned,flow,level,stream,levelStream,frame,+tick,trace,P.Aux{locals,ping,attempts,deliveries,phase,position,enabled}}:
      P.Resources{owned,flow,level,stream,levelStream,frame,1n+tick,trace,P.Aux{locals,ES.publish(~P.Ping,ping,1n+tick,event),attempts,deliveries,phase,position,enabled}}
def hook_succeeded(~S:Data,id:U32,event:P.Ping,world:W.World<S,P.Store<S>,P.Resources<S>,P.Ping>) -> W.World<S,P.Store<S>,P.Resources<S>,P.Ping>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,stream,levelStream,frame,+tick,trace,aux},events,commands,registrations,nextSystem,clock}:
      P.map_resources(~S,(resource => published_resource(~S,resource,event)),complete(~S,W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,stream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock},id,tick))
