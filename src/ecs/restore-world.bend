import ./deferred-command.bend as Deferred
import Base
import ./world.bend as W
import ./entity-allocator.bend as Alloc

# Internal owner adapter. Pending commands are discarded, never invoked.
# The namespace, live payload owners and registration cursors are preserved.
def cancel_pending(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  match world:
    case W.World{namespace,allocator,store,resource,events,_,registrations,nextSystemId,clock}:W.World{namespace,Alloc.abandon_pending(allocator),store,resource,events,[],registrations,nextSystemId,clock}
def progress_join(~S:Data,~C:Type,~R:Type,~E:Data,namespace:U32,store:C,resource:R,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,observed:Alloc.Allocator & Bool) -> W.World<S,C,R,E> & Bool:
  match observed:
    case (allocator,accepted):(W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},accepted)
def advance_floor(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>,floor:U32) -> W.World<S,C,R,E> & Bool:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}:progress_join(~S,~C,~R,~E,namespace,store,resource,events,pending,registrations,nextSystemId,clock,Alloc.advance_floor(allocator,floor))

def room(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>,floor:U32,needed:Nat) -> W.World<S,C,R,E> & Bool:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}:progress_join(~S,~C,~R,~E,namespace,store,resource,events,pending,registrations,nextSystemId,clock,Alloc.restore_room(allocator,floor,needed))
