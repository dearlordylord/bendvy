import Base
import owner-observer.bend as Dump
import schema-families.bend as D
import runtime-owners.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

def pending_join(~World:Type,head:World -> World,observed:List<(World -> World)> & Nat) -> List<(World -> World)> & Nat:
  (rest,count)=observed
  (head <> rest,1n+count)
def pending(~World:Type,values:List<(World -> World)>) -> List<(World -> World)> & Nat:
  match values:
    case []:([],0n)
    case head <> rest:pending_join(~World,head,pending(~World,rest))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access)
type Observed<S:Data> is Type:
  Observed{world:W.World<S,D.Store<S>,Consumer.Resource(~S),U32>,sl:String,ss:String,sr:String,count:Nat}
def finish(~S:Data,value:Observed<S>) -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & String:
  match value:
    case Observed{world,sl,ss,sr,count}:
      match world:
        case W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,queued,+registrations,+nextSystemId,+clock}:(W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,queued,registrations,nextSystemId,clock},"namespace=" ++ U32.show(namespace) ++ "|nextId=" ++ U32.show(nextId) ++ "|highWater=" ++ U32.show(highWater) ++ "|live=" ++ sl ++ "|capacity=" ++ U32.show(capacity) ++ "|depth=" ++ Nat.show(depth) ++ "|store=" ++ ss ++ "|resource=" ++ sr ++ "|events=" ++ List.show(&2,U32,U32.show,events) ++ "|pending=" ++ Nat.show(count) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ "|nextSystemId=" ++ U32.show(nextSystemId) ++ "|clock=" ++ U32.show(clock))
def pending_done(~S:Data,namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,store:D.Store<S>,resource:Consumer.Resource(~S),events:List<&2,U32>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,pair:List<(W.World<S,D.Store<S>,Consumer.Resource(~S),U32> -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32>)> & Nat) -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & Nat:
  (queued,observed)=pair
  (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,queued,registrations,nextSystemId,clock},observed)
def pending_world(~S:Data,world:W.World<S,D.Store<S>,Consumer.Resource(~S),U32>) -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & Nat:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,queued,registrations,nextSystemId,clock}:pending_done(~S,namespace,nextId,highWater,live,capacity,depth,store,resource,events,registrations,nextSystemId,clock,pending(~W.World<S,D.Store<S>,Consumer.Resource(~S),U32>,queued))
def pending_acc(~S:Data,sl:String,ss:String,sr:String,count:Nat,pair:W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & Nat) -> Observed<S>:
  (world,observed)=pair
  Observed{world,sl,ss,sr,observed}
def observe_pending(~S:Data,value:Observed<S>) -> Observed<S>:
  match value:
    case Observed{world,sl,ss,sr,count}:pending_acc(~S,sl,ss,sr,count,pending_world(~S,world))
def resource_done(~S:Data,namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,store:D.Store<S>,events:List<&2,U32>,queued:List<(W.World<S,D.Store<S>,Consumer.Resource(~S),U32> -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32>)>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,pair:Consumer.Resource(~S) & String) -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & String:
  (resource,observed)=pair
  (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,queued,registrations,nextSystemId,clock},observed)
def resource_world(~S:Data,world:W.World<S,D.Store<S>,Consumer.Resource(~S),U32>) -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & String:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,queued,registrations,nextSystemId,clock}:resource_done(~S,namespace,nextId,highWater,live,capacity,depth,store,events,queued,registrations,nextSystemId,clock,Dump.resource(~S,resource))
def resource_acc(~S:Data,sl:String,ss:String,sr:String,count:Nat,pair:W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & String) -> Observed<S>:
  (world,observed)=pair
  Observed{world,sl,ss,observed,count}
def observe_resource(~S:Data,value:Observed<S>) -> Observed<S>:
  match value:
    case Observed{world,sl,ss,sr,count}:resource_acc(~S,sl,ss,sr,count,resource_world(~S,world))
def store_done(~S:Data,namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,resource:Consumer.Resource(~S),events:List<&2,U32>,queued:List<(W.World<S,D.Store<S>,Consumer.Resource(~S),U32> -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32>)>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,pair:D.Store<S> & String) -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & String:
  (store,observed)=pair
  (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,queued,registrations,nextSystemId,clock},observed)
def store_world(~S:Data,world:W.World<S,D.Store<S>,Consumer.Resource(~S),U32>) -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & String:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,queued,registrations,nextSystemId,clock}:store_done(~S,namespace,nextId,highWater,live,capacity,depth,resource,events,queued,registrations,nextSystemId,clock,Dump.store(~S,store))
def store_acc(~S:Data,sl:String,ss:String,sr:String,count:Nat,pair:W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & String) -> Observed<S>:
  (world,observed)=pair
  Observed{world,sl,observed,sr,count}
def observe_store(~S:Data,value:Observed<S>) -> Observed<S>:
  match value:
    case Observed{world,sl,ss,sr,count}:store_acc(~S,sl,ss,sr,count,store_world(~S,world))
def live_done(~S:Data,namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,store:D.Store<S>,resource:Consumer.Resource(~S),events:List<&2,U32>,queued:List<(W.World<S,D.Store<S>,Consumer.Resource(~S),U32> -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32>)>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,pair:Array<Bool> & String) -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & String:
  (live,observed)=pair
  (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,queued,registrations,nextSystemId,clock},observed)
def live_world(~S:Data,world:W.World<S,D.Store<S>,Consumer.Resource(~S),U32>) -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & String:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,queued,registrations,nextSystemId,clock}:live_done(~S,namespace,nextId,highWater,capacity,depth,store,resource,events,queued,registrations,nextSystemId,clock,Dump.bool_array(live))
def live_acc(~S:Data,sl:String,ss:String,sr:String,count:Nat,pair:W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & String) -> Observed<S>:
  (world,observed)=pair
  Observed{world,observed,ss,sr,count}
def observe_live(~S:Data,value:Observed<S>) -> Observed<S>:
  match value:
    case Observed{world,sl,ss,sr,count}:live_acc(~S,sl,ss,sr,count,live_world(~S,world))
def world(~S:Data,value:W.World<S,D.Store<S>,Consumer.Resource(~S),U32>) -> W.World<S,D.Store<S>,Consumer.Resource(~S),U32> & String:
  finish(~S,observe_pending(~S,observe_resource(~S,observe_store(~S,observe_live(~S,Observed{value,"","","",0n})))))
def instance(~S:Data,value:I.Instance<S>) -> I.Instance<S> & String:
  match value:
    case I.Fresh{}:(I.Fresh{},"Fresh")
    case I.Active{+cursor,+registeredAt}:(I.Active{cursor,registeredAt},"Active:" ++ U32.show(cursor) ++ ":" ++ U32.show(registeredAt))
def registry(~S:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,D.Store<S>,Consumer.Resource(~S),U32> -> Args -> Sys.Outcome<W.World<S,D.Store<S>,Consumer.Resource(~S),U32>,Error,Output>,value:Sys.Registry<S,D.Store<S>,Consumer.Resource(~S),U32,Args,Error,Output,runner>) -> Sys.Registry<S,D.Store<S>,Consumer.Resource(~S),U32,Args,Error,Output,runner> & String:
  match value:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}:(Sys.Registry{namespace,id,name,access,cursor},"Registry:" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access) ++ ":" ++ U32.show(cursor))
def main() -> Unit:
  Unit{}
