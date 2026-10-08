import Base
import removal-publication.bend as P
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/removals.bend as Rm

def deactivated(~S:Data,~Store:Type,~R:Type,~E:Data,~F:Data,~encode:P.Notice<S,F> -> E,+handle:W.Handle<S>,+tick:U32,result:W.World<S,Store,R,E> & W.Status) -> W.World<S,Store,R,E>:
  match result:
    case (world,W.Accepted{}):W.event_publish(~S,~Store,~R,~E,world,[encode(P.Notice{tick,Rm.Despawned{handle}})])
    case (world,W.Rejected{_}):world
def cleanup(~S:Data,~Store:Type,~R:Type,~E:Data,~F:Data,~clear:Store -> W.Handle<S> -> Store & List<&2,Rm.Record<S,F>>,~encode:P.Notice<S,F> -> E,+handle:W.Handle<S>,clocked:W.World<S,Store,R,E> & U32) -> W.World<S,Store,R,E>:
  (world,+tick)=clocked
  deactivated(~S,~Store,~R,~E,~F,~encode,handle,tick,W.deactivate(~S,~Store,~R,~E,P.remove(~S,~Store,~R,~E,~F,~clear,~encode,world,handle),handle))
def checked(~S:Data,~Store:Type,~R:Type,~E:Data,~F:Data,~clear:Store -> W.Handle<S> -> Store & List<&2,Rm.Record<S,F>>,~encode:P.Notice<S,F> -> E,+handle:W.Handle<S>,valid:W.World<S,Store,R,E> & Bool) -> W.World<S,Store,R,E>:
  match valid:
    case (world,False{}):world
    case (world,True{}):cleanup(~S,~Store,~R,~E,~F,~clear,~encode,handle,W.clock(~S,~Store,~R,~E,world))
# Live-only trusted internal application. Pending activation/cancellation policy
# is deliberately outside this candidate. Closed clear owns all declared families.
def despawn(~S:Data,~Store:Type,~R:Type,~E:Data,~F:Data,~clear:Store -> W.Handle<S> -> Store & List<&2,Rm.Record<S,F>>,~encode:P.Notice<S,F> -> E,world:W.World<S,Store,R,E>,+handle:W.Handle<S>) -> W.World<S,Store,R,E>:
  checked(~S,~Store,~R,~E,~F,~clear,~encode,handle,W.valid(~S,~Store,~R,~E,world,handle))
