import Base
import ./ordinary-machine-declaration.bend as OD
import ./machine-queue.bend as Q
import ./machine.bend as M
import ./machine-world.bend as MW
import ./transaction.bend as Tx
import ./world.bend as W
import ./capabilities.bend as Cap
# Schema-authored closed lenses/comparator grant operations to an opaque owner.
# The existing declaration remains unchanged; names carry no authority.
def current(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,pair:Tx.Tx<W.World<S,C,R,E>,E> & M.Slot<S,K,V>) -> Tx.Tx<W.World<S,C,R,E>,E> & M.CurrentView<S,K,V>:
  (frame,slot)=pair
  (frame,M.current_view(~S,~K,~V,slot))
def get(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,frame:Tx.Tx<W.World<S,C,R,E>,E>) -> Tx.Tx<W.World<S,C,R,E>,E> & M.CurrentView<S,K,V>:
  current(~S,~K,~V,~C,~R,~E,M.read(~S,~K,~V,~W.World<S,C,R,E>,~E,~MW.take(~S,~K,~V,~C,~R,~E,~take),frame))
def set(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,frame:Tx.Tx<W.World<S,C,R,E>,E>,input:M.QueueInput<V>) -> Tx.Tx<W.World<S,C,R,E>,E>:
  Q.next_declared(~S,~K,~V,~W.World<S,C,R,E>,~E,~MW.take(~S,~K,~V,~C,~R,~E,~take),~MW.put(~S,~K,~V,~C,~R,~E,~put),~same,M.Family{OD.name(~S,~K,~V,~R,~take,declaration)},frame,input)
def read(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~declaration:OD.Declaration<S,K,V,R,take>) -> Cap.ValueRead<Tx.Tx<W.World<S,C,R,E>,E>,M.CurrentView<S,K,V>>:
  Cap.ValueRead{get(~S,~K,~V,~C,~R,~E,~take)}
def write(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>) -> Cap.ValueWrite<Tx.Tx<W.World<S,C,R,E>,E>,M.QueueInput<V>,M.CurrentView<S,K,V>>:
  Cap.ValueWrite{get(~S,~K,~V,~C,~R,~E,~take),set(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration)}
