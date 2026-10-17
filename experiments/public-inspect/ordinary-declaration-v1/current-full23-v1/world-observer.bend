import Base
import owner-observer.bend as Dump
import schema-families.bend as D
import runtime-owners.bend as Consumer
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/inspector.bend as I
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/entity-key.bend as Key
import ../../../../src/ecs/entity-allocator.bend as Alloc
import ../../../../src/ecs/deferred-command.bend as Deferred

def allocator_phase(value:Alloc.Phase) -> String:
  match value:
    case Alloc.Consumed{}:"Consumed"
    case Alloc.Pending{}:"Pending"
    case Alloc.Live{}:"Live"
    case Alloc.DeadRetained{}:"DeadRetained"
    case Alloc.Free{}:"Free"
def allocator_slot(value:Alloc.Slot) -> Alloc.Slot & String:
  match value:
    case Alloc.Slot{+generation,+phase}:(Alloc.Slot{generation,phase},U32.show(generation) ++ ":" ++ allocator_phase(phase))
def key_text(value:Key.Key) -> String:
  match value:
    case Key.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
def allocator_join(+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,Key.Key>,value:Array<Alloc.Slot> & String) -> Alloc.Allocator & String:
  (slots,text)=value
  (Alloc.Allocator{next,high,slots,capacity,depth,free,order},"allocator{next=" ++ U32.show(next) ++ ";high=" ++ U32.show(high) ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";slots=" ++ text ++ ";free=" ++ List.show(&2,U32,U32.show,free) ++ ";order=" ++ List.show(&2,Key.Key,key_text,order) ++ "}")
def allocator(value:Alloc.Allocator) -> Alloc.Allocator & String:
  match value:
    case Alloc.Allocator{next,high,slots,capacity,depth,free,order}:allocator_join(next,high,capacity,depth,free,order,Dump.array(~Alloc.Slot,~allocator_slot,slots))
type PendingView is Data:
  PendingView{count:Nat,text:String}
def pending_join(~World:Type,head:Deferred.Command<World>,label:String,observed:List<Deferred.Command<World>> & PendingView) -> List<Deferred.Command<World>> & PendingView:
  match observed:
    case (rest,PendingView{count,text}):(head <> rest,PendingView{1n+count,label ++ "," ++ text})
def pending(~World:Type,values:List<Deferred.Command<World>>) -> List<Deferred.Command<World>> & PendingView:
  match values:
    case []:([],PendingView{0n,"end"})
    case Deferred.Raw{apply} <> rest:pending_join(~World,Deferred.Raw{apply},"Raw(opaque)",pending(~World,rest))
    case Deferred.Observed{apply} <> rest:pending_join(~World,Deferred.Observed{apply},"Observed(opaque)",pending(~World,rest))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access)
def world_format(namespace:U32,nextSystemId:U32,clock:U32,sa:String,ss:String,sr:String,eventsText:String,registrationsText:String,pendingInfo:PendingView) -> String:
  match pendingInfo:
    case PendingView{count,text}:"namespace=" ++ U32.show(namespace) ++ "|allocator=" ++ sa ++ "|store=" ++ ss ++ "|resource=" ++ sr ++ "|events=" ++ eventsText ++ "|pending=" ++ Nat.show(count) ++ "|pendingKinds=" ++ text ++ "|registrations=" ++ registrationsText ++ "|nextSystemId=" ++ U32.show(nextSystemId) ++ "|clock=" ++ U32.show(clock)
def joined(~S:Data,+namespace:U32,+events:List<&2,U32>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,observedAllocator:Alloc.Allocator & String,observedStore:D.Store<S> & String,observedResource:Consumer.Resource<S> & String,observedPending:List<Deferred.Command<W.World<S,D.Store<S>,Consumer.Resource<S>,U32>>> & PendingView) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  (allocator,sa)=observedAllocator
  (store,ss)=observedStore
  (resource,sr)=observedResource
  (pending,info)=observedPending
  (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},world_format(namespace,nextSystemId,clock,sa,ss,sr,List.show(&2,U32,U32.show,events),List.show(&2,W.RegistrationMeta,registration,registrations),info))
def world(~S:Data,value:W.World<S,D.Store<S>,Consumer.Resource<S>,U32>) -> W.World<S,D.Store<S>,Consumer.Resource<S>,U32> & String:
  match value:
    case W.World{namespace,alloc,store,resource,events,queued,registrations,nextSystemId,clock}:joined(~S,namespace,events,registrations,nextSystemId,clock,allocator(alloc),Dump.store(~S,store),Dump.resource(~S,resource),pending(~W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,queued))
def instance(~S:Data,value:I.Instance<S>) -> I.Instance<S> & String:
  match value:
    case I.Fresh{}:(I.Fresh{},"Fresh")
    case I.Active{+cursor,+registeredAt}:(I.Active{cursor,registeredAt},"Active:" ++ U32.show(cursor) ++ ":" ++ U32.show(registeredAt))
def registry(~S:Data,~Args:Type,~Error:Data,~Output:Type,~runner:W.World<S,D.Store<S>,Consumer.Resource<S>,U32> -> Args -> Sys.Outcome<W.World<S,D.Store<S>,Consumer.Resource<S>,U32>,Error,Output>,value:Sys.Registry<S,D.Store<S>,Consumer.Resource<S>,U32,Args,Error,Output,runner>) -> Sys.Registry<S,D.Store<S>,Consumer.Resource<S>,U32,Args,Error,Output,runner> & String:
  match value:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}:(Sys.Registry{namespace,id,name,access,cursor},"Registry:" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access) ++ ":" ++ U32.show(cursor))
def main() -> Unit:
  Unit{}
