import Base
import ./clock-state.bend as Clock
import ./deferred-command.bend as Deferred
import entity-allocator.bend as Alloc
import machine.bend as M
import world.bend as W

# Closed resource lenses adapt machine slots to the existing actual ECS world.
# No component store or affine resource is projected to Data or copied.
def take_join(~S: Data,~K: Data,~V: Data,~C: Type,~R: Type,~E: Data,
  +ns: U32,allocator:Alloc.Allocator,
  store: C,split: R & M.Slot<S,K,V>,+events: List<&2,E>,commands:List<&1,Deferred.Command<W.World<S,C,R,E>>>,
  +registrations: List<&2,W.RegistrationMeta>,+nextSystem: U32,+clock:Clock.State
) -> W.World<S,C,R,E> & M.Slot<S,K,V>:
  (resources,slot)=split
  (W.World{ns,allocator,store,resources,events,commands,registrations,nextSystem,clock},slot)

def take(~S: Data,~K: Data,~V: Data,~C: Type,~R: Type,~E: Data,
  ~take_resource: R -> R & M.Slot<S,K,V>,world: W.World<S,C,R,E>) -> W.World<S,C,R,E> & M.Slot<S,K,V>:
  match world:
    case W.World{ns,allocator,store,resources,events,commands,registrations,nextSystem,clock}:
      take_join(~S,~K,~V,~C,~R,~E,ns,allocator,store,take_resource(resources),events,commands,registrations,nextSystem,clock)

def put(~S: Data,~K: Data,~V: Data,~C: Type,~R: Type,~E: Data,
  ~put_resource: R -> M.Slot<S,K,V> -> R,world: W.World<S,C,R,E>,slot: M.Slot<S,K,V>) -> W.World<S,C,R,E>:
  match world:
    case W.World{ns,allocator,store,resources,events,commands,registrations,nextSystem,clock}:
      W.World{ns,allocator,store,put_resource(resources,slot),events,commands,registrations,nextSystem,clock}

# ApplyDeferred only drains structural commands. Machine commits require the
# separate marker; callers must not conflate the two public operations.
def structural_flush(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  W.barrier(~S,~C,~R,~E,world)
