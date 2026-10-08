import Base
import root-source/world.bend as W
import root-source/machine.bend as M
import root-source/machine-world.bend as MW
import root-source/capabilities.bend as Cap

# Cursor-free condition context is distinct from Inspector.Frame/Instance.
type Context<-S:Data,-Store:Type,-R:Type,-E:Data> is Type:
  Context{world:W.World<S,Store,R,E>}
def projected(~S:Data,~K:Data,~V:Data,~Store:Type,~R:Type,~E:Data,observed:W.World<S,Store,R,E> & M.Slot<S,K,V>) -> Context<S,Store,R,E> & M.CurrentView<S,K,V>:
  (world,slot)=observed
  (Context{world},M.current_view(~S,~K,~V,slot))
def current(~S:Data,~K:Data,~V:Data,~Store:Type,~R:Type,~E:Data,~take_resource:R -> R & M.Slot<S,K,V>,ctx:Context<S,Store,R,E>) -> Context<S,Store,R,E> & M.CurrentView<S,K,V>:
  match ctx:
    case Context{world}:projected(~S,~K,~V,~Store,~R,~E,MW.take(~S,~K,~V,~Store,~R,~E,~take_resource,world))
def provide(~S:Data,~K:Data,~V:Data,~Store:Type,~R:Type,~E:Data,~take_resource:R -> R & M.Slot<S,K,V>) -> Cap.ValueRead<Context<S,Store,R,E>,M.CurrentView<S,K,V>>:
  Cap.ValueRead{current(~S,~K,~V,~Store,~R,~E,~take_resource)}
def finish(~S:Data,~Store:Type,~R:Type,~E:Data,observed:Context<S,Store,R,E> & Bool) -> W.World<S,Store,R,E> & Bool:
  match observed:
    case (Context{world},value):(world,value)
