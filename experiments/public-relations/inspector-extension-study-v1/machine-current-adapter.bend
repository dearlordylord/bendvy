import Base
import root-source/inspector.bend as I
import root-source/machine.bend as M
import root-source/machine-world.bend as MW
import root-source/world.bend as W
import root-source/capabilities.bend as Cap

# Study-only typed projection. Closed schema setup owns the lens.
# No requirement validator or foreign-instance policy is selected here.
def projected(~S:Data,~K:Data,~V:Data,~Store:Type,~R:Type,~E:Data,cursor:U32,observed:W.World<S,Store,R,E> & M.Slot<S,K,V>) -> I.Frame<S,Store,R,E> & M.CurrentView<S,K,V>:
  (world,slot)=observed
  (I.Frame{world,cursor},M.current_view(~S,~K,~V,slot))
def current(~S:Data,~K:Data,~V:Data,~Store:Type,~R:Type,~E:Data,~take_resource:R -> R & M.Slot<S,K,V>,frame:I.Frame<S,Store,R,E>) -> I.Frame<S,Store,R,E> & M.CurrentView<S,K,V>:
  match frame:
    case I.Frame{world,cursor}:projected(~S,~K,~V,~Store,~R,~E,cursor,MW.take(~S,~K,~V,~Store,~R,~E,~take_resource,world))
def provide(~S:Data,~K:Data,~V:Data,~Store:Type,~R:Type,~E:Data,~take_resource:R -> R & M.Slot<S,K,V>) -> Cap.ValueRead<I.Frame<S,Store,R,E>,M.CurrentView<S,K,V>>:
  Cap.ValueRead{current(~S,~K,~V,~Store,~R,~E,~take_resource)}
# Gameplay receives only abstract H; projections contain no pending/debug fields.
def get(~H:Type,~S:Data,~K:Data,~V:Data,~cap:Cap.ValueRead<H,M.CurrentView<S,K,V>>,owner:H) -> H & M.CurrentView<S,K,V>:
  Cap.value_read(~H,~M.CurrentView<S,K,V>,~cap,owner)
def tested(~H:Type,~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,value:V,observed:H & M.CurrentView<S,K,V>) -> H & Bool:
  (owner,view)=observed
  (owner,M.is_current(~S,~K,~V,~same,view,value))
def matches(~H:Type,~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,~cap:Cap.ValueRead<H,M.CurrentView<S,K,V>>,owner:H,value:V) -> H & Bool:
  tested(~H,~S,~K,~V,~same,value,get(~H,~S,~K,~V,~cap,owner))
