import Base
import owner-observer.bend as Dump
import schema-families.bend as D
import runtime-owners.bend as Consumer
import core/world.bend as W
import core/inspector.bend as I
import core/system.bend as Sys

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
def joined(~S:Data,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,+events:List<&2,U32>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,observedLive:Array<Bool> & String,observedStore:D.Store<S> & String,observedResource:Consumer.Resource<S> & String,observedPending:List<(W.World<S,D.Store<S>,Consumer.Resource<S>,U32> -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32>)> & Nat) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  (live,sl)=observedLive
  (store,ss)=observedStore
  (resource,sr)=observedResource
  (pending,count)=observedPending
  (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},"namespace=" ++ U32.show(namespace) ++ "|nextId=" ++ U32.show(nextId) ++ "|highWater=" ++ U32.show(highWater) ++ "|live=" ++ sl ++ "|capacity=" ++ U32.show(capacity) ++ "|depth=" ++ Nat.show(depth) ++ "|store=" ++ ss ++ "|resource=" ++ sr ++ "|events=" ++ List.show(&2,U32,U32.show,events) ++ "|pending=" ++ Nat.show(count) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ "|nextSystemId=" ++ U32.show(nextSystemId) ++ "|clock=" ++ U32.show(clock))
def world(~S:Data,value:W.World<S,D.Store<S>,Consumer.Resource<S>,U32>) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  match value:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,queued,registrations,nextSystemId,clock}:joined(~S,namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock,Dump.bool_array(live),Dump.store(~S,store),Dump.resource(~S,resource),pending(~W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,queued))
def instance(~S:Data,value:I.Instance<S>) -> I.Instance<S> & String:
  match value:
    case I.Fresh{}:(I.Fresh{},"Fresh")
    case I.Active{+cursor,+registeredAt}:(I.Active{cursor,registeredAt},"Active:" ++ U32.show(cursor) ++ ":" ++ U32.show(registeredAt))
def registry(~S:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,D.Store<S>,Consumer.Resource<S>,U32> -> Args -> Sys.Outcome<W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,Error,Output>,value:Sys.Registry<S,D.Store<S>,Consumer.Resource<S>,U32,Args,Error,Output,runner>) -> Sys.Registry<S,D.Store<S>,Consumer.Resource<S>,U32,Args,Error,Output,runner> & String:
  match value:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}:(Sys.Registry{namespace,id,name,access,cursor},"Registry:" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access) ++ ":" ++ U32.show(cursor))
def main() -> Unit:
  Unit{}
