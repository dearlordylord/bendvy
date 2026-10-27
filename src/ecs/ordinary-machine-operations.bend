import Base
import ./ordinary-machine-declaration.bend as OD
import ./machine-queue-legacy.bend as Q
import ./machine.bend as M
import ./machine-legacy.bend as LegacyMachine
import ./machine-world.bend as MW
import ./transaction.bend as Tx
import ./world.bend as W
import ./capabilities.bend as Cap
# Schema-authored closed lenses/comparator grant operations to an opaque owner.
# The existing declaration remains unchanged; names carry no authority.
def current(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,pair:Tx.Tx<W.World<S,C,R,E>,E> & M.Slot<S,K,V>) -> Tx.Tx<W.World<S,C,R,E>,E> & M.CurrentView<S,K,V>:
  (frame,slot)=pair
  (frame,M.current_view(~S,~K,~V,slot))
# Advanced transactional read of the committed machine CurrentView through
# the trusted nominal slot lens, returning the transaction owner. Queued targets
# are not committed current state; a missing slot remains explicit.
def get(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,frame:Tx.Tx<W.World<S,C,R,E>,E>) -> Tx.Tx<W.World<S,C,R,E>,E> & M.CurrentView<S,K,V>:
  current(~S,~K,~V,~C,~R,~E,LegacyMachine.read(~S,~K,~V,~W.World<S,C,R,E>,~E,~MW.take(~S,~K,~V,~C,~R,~E,~take),frame))
# Stage a Set or Reset next-state request in the current ECS transaction.
# Returns the transaction owner; the slot change is journaled for rollback.
# Does not execute handlers or immediately change committed state: transition
# markers apply queued work. Vocabulary metadata is not a membership validator.
def set(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,frame:Tx.Tx<W.World<S,C,R,E>,E>,input:M.QueueInput<V>) -> Tx.Tx<W.World<S,C,R,E>,E>:
  Q.next_declared(~S,~K,~V,~W.World<S,C,R,E>,~E,~MW.take(~S,~K,~V,~C,~R,~E,~take),~MW.put(~S,~K,~V,~C,~R,~E,~put),~same,M.Family{OD.name(~S,~K,~V,~R,~take,declaration)},frame,input)
# Declare current-state read access to the nominal machine slot.
# The resulting capability threads the transaction owner and exposes only
# CurrentView; building it does not read state or grant next-state writes.
def read(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~declaration:OD.Declaration<S,K,V,R,take>) -> Cap.ValueRead<Tx.Tx<W.World<S,C,R,E>,E>,M.CurrentView<S,K,V>>:
  Cap.ValueRead{get(~S,~K,~V,~C,~R,~E,~take)}
# Declare current-state reads plus Set/Reset next-state requests for one
# nominal slot. take/put/comparator are trusted schema setup. Requests are
# journaled by set and later processed at explicit transition markers, with
# existing exit/transition/enter failure boundaries. Does not grant raw resources.
def write(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>) -> Cap.ValueWrite<Tx.Tx<W.World<S,C,R,E>,E>,M.QueueInput<V>,M.CurrentView<S,K,V>>:
  Cap.ValueWrite{get(~S,~K,~V,~C,~R,~E,~take),set(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration)}
