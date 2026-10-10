import Base
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as Check
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-world.bend as MW
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

# Private public-source projection candidate. Closed schema setup owns the lens.
# No requirement validator or foreign-instance policy is selected here.
def advanced(~S:Data,~K:Data,~V:Data,~Store:Type,~R:Type,~E:Data,cursor:U32,slot:M.Slot<S,K,V>,observed:W.World<S,Store,R,E> & U32) -> I.Frame<S,Store,R,E> & M.CurrentView<S,K,V>:
  (world,clock)=observed
  (I.Frame{world,cursor},M.current_view(~S,~K,~V,slot))
def projected(~S:Data,~K:Data,~V:Data,~Store:Type,~R:Type,~E:Data,cursor:U32,observed:W.World<S,Store,R,E> & M.Slot<S,K,V>) -> I.Frame<S,Store,R,E> & M.CurrentView<S,K,V>:
  (world,slot)=observed
  advanced(~S,~K,~V,~Store,~R,~E,cursor,slot,W.advance_clock(~S,~Store,~R,~E,world))
def current(~S:Data,~K:Data,~V:Data,~Store:Type,~R:Type,~E:Data,~take_resource:R -> R & M.Slot<S,K,V>,frame:I.Frame<S,Store,R,E>) -> I.Frame<S,Store,R,E> & M.CurrentView<S,K,V>:
  match frame:
    case I.Frame{world,cursor}:projected(~S,~K,~V,~Store,~R,~E,cursor,MW.take(~S,~K,~V,~Store,~R,~E,~take_resource,world))
def provide(~S:Data,~K:Data,~V:Data,~Store:Type,~R:Type,~E:Data,~take_resource:R -> R & M.Slot<S,K,V>) -> Cap.ValueRead<I.Frame<S,Store,R,E>,M.CurrentView<S,K,V>>:
  Cap.ValueRead{current(~S,~K,~V,~Store,~R,~E,~take_resource)}

def check_projected(~S:Data,~K:Data,~V:Data,~Store:Type,~R:Type,~E:Data,observed:W.World<S,Store,R,E> & M.Slot<S,K,V>) -> Check.Frame<S,Store,R,E> & M.CurrentView<S,K,V>:
  (world,slot)=observed
  (Check.Frame{world},M.current_view(~S,~K,~V,slot))
def check_current(~S:Data,~K:Data,~V:Data,~Store:Type,~R:Type,~E:Data,~take_resource:R -> R & M.Slot<S,K,V>,ctx:Check.Frame<S,Store,R,E>) -> Check.Frame<S,Store,R,E> & M.CurrentView<S,K,V>:
  match ctx:
    case Check.Frame{world}:check_projected(~S,~K,~V,~Store,~R,~E,MW.take(~S,~K,~V,~Store,~R,~E,~take_resource,world))
def check_provide(~S:Data,~K:Data,~V:Data,~Store:Type,~R:Type,~E:Data,~take_resource:R -> R & M.Slot<S,K,V>) -> Cap.ValueRead<Check.Frame<S,Store,R,E>,M.CurrentView<S,K,V>>:
  Cap.ValueRead{check_current(~S,~K,~V,~Store,~R,~E,~take_resource)}
