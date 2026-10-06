import Base
import lifecycle.bend as L
import column.bend as Col
import world.bend as W
import transaction.bend as T

# Caller-authored schema lenses are trusted provisioning. The gameplay callback
# receives only universally quantified provider handles, never these owners.
type Family<-S: Data,-Store: Type,-Rest: Type,-C: Type,-V: Data,-Token: Data,-take: Store -> Rest & Col.Column<S,C>,-put: Rest -> Col.Column<S,C> -> Store,-project: C -> C & V> is Data:
  Family{name: String}
type Access<V: Data> is Data:
  Found{value: V}
  ComponentAbsent{}
  MissingEntity{}
type Replacement<W: Type,C: Type> is Type:
  Replaced{world: W,previous: Maybe<&1,C>}
  ReplaceRejected{world: W,incoming: Maybe<&1,C>,error: W.WorldError}
type Swap<C: Type> is Type:
  Swapped{previous: Maybe<&1,C>}
  SwapRejected{incoming: Maybe<&1,C>}
type SetResult<Tx: Type,C: Type> is Type:
  Written{tx: Tx}
  WriteRejected{tx: Tx,incoming: C,error: W.WorldError}
  WriteFailure{tx: Tx,error: W.WorldError}
type RemoveResult<Tx: Type> is Type:
  Removed{tx: Tx}
  RemoveRejected{tx: Tx,error: W.WorldError}

def define(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,name: String) -> Family<S,Store,Rest,C,V,Token,take,put,project>:
  Family{name}

def access(~V: Data,value: Maybe<&2,V>) -> Access<V>:
  match value:
    case None{}: ComponentAbsent{}
    case Some{value}: Found{value}

def get_projected(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,rest: Rest,observed: Col.Column<S,C> & Maybe<&2,V>) -> Store & Access<V>:
  (column,value) = observed
  (put(rest,column),access(~V,value))

def get_store(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,split: Rest & Col.Column<S,C>) -> Store & Access<V>:
  (rest,column) = split
  get_projected(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,rest,Col.view(~S,~C,~V,~project,column,id))

def get_allowed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,checked: W.World<S,Store,R,E> & Bool,+handle: W.Handle<S>) -> W.World<S,Store,R,E> & Access<V>:
  match checked handle:
    case (world,False{}) _: (world,MissingEntity{})
    case (world,True{}) W.Handle{_,+id}:
      W.with_store(~S,~Store,~R,~E,~Access<V>,(store => get_store(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,take(store))),world)

def get(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Family<S,Store,Rest,C,V,Token,take,put,project>,world: W.World<S,Store,R,E>,+handle: W.Handle<S>) -> W.World<S,Store,R,E> & Access<V>:
  get_allowed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.valid(~S,~Store,~R,~E,world,handle),handle)

def has_access(~V: Data,value: Access<V>) -> Access<Bool>:
  match value:
    case MissingEntity{}: MissingEntity{}
    case ComponentAbsent{}: Found{False{}}
    case Found{_}: Found{True{}}

def has_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,observed: W.World<S,Store,R,E> & Access<V>) -> W.World<S,Store,R,E> & Access<Bool>:
  (world,value) = observed
  (world,has_access(~V,value))

def has(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Family<S,Store,Rest,C,V,Token,take,put,project>,world: W.World<S,Store,R,E>,handle: W.Handle<S>) -> W.World<S,Store,R,E> & Access<Bool>:
  has_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle))

def owner_present(~C: Type,owner: Maybe<&1,C>) -> Maybe<&1,C> & Bool:
  match owner:
    case None{}: (None{},False{})
    case Some{owner}: (Some{owner},True{})

def mark_swapped(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,rest: Rest,column: Col.Column<S,C>,+id: U32,incoming: Bool,tick: U32,observed: Maybe<&1,C> & Bool) -> Store & Swap<C>:
  (previous,wasPresent) = observed
  (put(rest,Col.mark(~S,~C,column,id,incoming,wasPresent,tick)),Swapped{previous})

def swap_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,rest: Rest,+id: U32,incoming: Bool,tick: U32,result: Col.SwapOutcome<S,C>) -> Store & Swap<C>:
  match result:
    case Col.Accepted{column,previous}: mark_swapped(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,rest,column,id,incoming,tick,owner_present(~C,previous))
    case Col.Rejected{column,incoming}: (put(rest,column),SwapRejected{incoming})

def swap_store(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,incoming: Maybe<&1,C>,incomingPresent: Bool,tick: U32,split: Rest & Col.Column<S,C>) -> Store & Swap<C>:
  (rest,column) = split
  swap_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,rest,id,incomingPresent,tick,Col.swap(~S,~C,Col.ensure(~S,~C,column,id),id,incoming))

def replaced(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,result: W.World<S,Store,R,E> & Swap<C>) -> Replacement<W.World<S,Store,R,E>,C>:
  match result:
    case (world,Swapped{previous}): Replaced{world,previous}
    case (world,SwapRejected{incoming}): ReplaceRejected{world,incoming,W.CapacityExceeded{}}

def replace_clock_advanced(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,incomingPresent: Bool,incoming: Maybe<&1,C>,advanced: W.World<S,Store,R,E> & U32) -> Replacement<W.World<S,Store,R,E>,C>:
  (world,+tick) = advanced
  replaced(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.with_store(~S,~Store,~R,~E,~Swap<C>,(store => swap_store(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,incoming,incomingPresent,tick,take(store))),world))

def replace_clock_checked(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,allowed: Bool,world: W.World<S,Store,R,E>,+id: U32,observed: Maybe<&1,C> & Bool) -> Replacement<W.World<S,Store,R,E>,C>:
  match allowed observed:
    case False{}, (incoming,_): ReplaceRejected{world,incoming,W.CapacityExceeded{}}
    case True{}, (incoming,present): replace_clock_advanced(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,present,incoming,W.advance_clock(~S,~Store,~R,~E,world))

def replace_clock(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,incoming: Maybe<&1,C>,clocked: W.World<S,Store,R,E> & U32) -> Replacement<W.World<S,Store,R,E>,C>:
  (world,tick) = clocked
  replace_clock_checked(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,U32.is_lt(tick,4294967295),world,id,owner_present(~C,incoming))

def replace_allowed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,checked: W.World<S,Store,R,E> & Bool,+handle: W.Handle<S>,incoming: Maybe<&1,C>) -> Replacement<W.World<S,Store,R,E>,C>:
  match checked handle:
    case (world,False{}) _: ReplaceRejected{world,incoming,W.MissingEntity{}}
    case (world,True{}) W.Handle{_,+id}:
      replace_clock(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,incoming,W.clock(~S,~Store,~R,~E,world))

# Ordinary writes require a live entity. Foreign handles are rejected before
# any column access, size computation, allocation or owned replacement move.
def replace(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Family<S,Store,Rest,C,V,Token,take,put,project>,world: W.World<S,Store,R,E>,+handle: W.Handle<S>,incoming: Maybe<&1,C>) -> Replacement<W.World<S,Store,R,E>,C>:
  replace_allowed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.valid(~S,~Store,~R,~E,world,handle),handle,incoming)

# Deferred creation may populate reserved entities before activation. This is
# provisioning/structural command machinery, not a gameplay capability.
def structural_replace(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Family<S,Store,Rest,C,V,Token,take,put,project>,world: W.World<S,Store,R,E>,+handle: W.Handle<S>,incoming: Maybe<&1,C>) -> Replacement<W.World<S,Store,R,E>,C>:
  replace_allowed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.metadata_valid(~S,~Store,~R,~E,world,handle),handle,incoming)

def restore_done(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,result: Replacement<W.World<S,Store,R,E>,C>) -> W.World<S,Store,R,E>:
  match result:
    case Replaced{world,_}: world
    case ReplaceRejected{world,_,_}: world

# Inverse closures own their old component, not a copied payload. Replaying
# drops the replaced current owner exactly once and restores the journal owner.
def restore_swap(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,rest: Rest,result: Col.SwapOutcome<S,C>) -> Store & Unit:
  match result:
    case Col.Accepted{column,_}: (put(rest,column),Unit{})
    case Col.Rejected{column,_}: (put(rest,column),Unit{})

def restore_store(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,incoming: Maybe<&1,C>,split: Rest & Col.Column<S,C>) -> Store & Unit:
  (rest,column) = split
  restore_swap(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,rest,Col.swap(~S,~C,Col.ensure(~S,~C,column,id),id,incoming))

def restore_observed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,observed: W.World<S,Store,R,E> & Unit) -> W.World<S,Store,R,E>:
  (world,_) = observed
  world

def restore_allowed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,checked: W.World<S,Store,R,E> & Bool,handle: W.Handle<S>,incoming: Maybe<&1,C>) -> W.World<S,Store,R,E>:
  match checked handle:
    case (world,False{}) _: world
    case (world,True{}) W.Handle{_,+id}: restore_observed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.with_store(~S,~Store,~R,~E,~Unit,(store => restore_store(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,incoming,take(store))),world))

def restore(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,incoming: Maybe<&1,C>,world: W.World<S,Store,R,E>) -> W.World<S,Store,R,E>:
  restore_allowed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.metadata_valid(~S,~Store,~R,~E,world,handle),handle,incoming)

def lifecycle_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,rest: Rest,observed: Col.Column<S,C> & L.Stamp) -> Store & L.Stamp:
  (column,stamp) = observed
  (put(rest,column),stamp)

def lifecycle_store(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,split: Rest & Col.Column<S,C>) -> Store & L.Stamp:
  (rest,column) = split
  lifecycle_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,rest,Col.lifecycle(~S,~C,column,id))

def lifecycle_allowed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,checked: W.World<S,Store,R,E> & Bool,handle: W.Handle<S>) -> W.World<S,Store,R,E> & L.Stamp:
  match checked handle:
    case (world,False{}) _: (world,L.Stamp{0,0})
    case (world,True{}) W.Handle{_,+id}: W.with_store(~S,~Store,~R,~E,~L.Stamp,(store => lifecycle_store(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,take(store))),world)

def lifecycle(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Family<S,Store,Rest,C,V,Token,take,put,project>,world: W.World<S,Store,R,E>,+handle: W.Handle<S>) -> W.World<S,Store,R,E> & L.Stamp:
  lifecycle_allowed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.valid(~S,~Store,~R,~E,world,handle),handle)

def restore_stamp_store(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,stamp: L.Stamp,split: Rest & Col.Column<S,C>) -> Store & Unit:
  (rest,column) = split
  (put(rest,Col.restore_stamp(~S,~C,column,id,stamp)),Unit{})

def restore_stamp_done(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,observed: W.World<S,Store,R,E> & Unit) -> W.World<S,Store,R,E>:
  (world,_) = observed
  world

def restore_stamp(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+handle: W.Handle<S>,stamp: L.Stamp,world: W.World<S,Store,R,E>) -> W.World<S,Store,R,E>:
  match handle:
    case W.Handle{_,+id}: restore_stamp_done(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.with_store(~S,~Store,~R,~E,~Unit,(store => restore_stamp_store(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,stamp,take(store))),world))

def tx_get_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events: List<&2,E>,observed: W.World<S,Store,R,E> & Access<V>) -> T.Tx<W.World<S,Store,R,E>,E> & Access<V>:
  (world,value) = observed
  (T.Tx{world,undo,commands,events},value)

def tx_get(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Family<S,Store,Rest,C,V,Token,take,put,project>,tx: T.Tx<W.World<S,Store,R,E>,E>,handle: W.Handle<S>) -> T.Tx<W.World<S,Store,R,E>,E> & Access<V>:
  match tx:
    case T.Tx{world,undo,commands,events}:
      tx_get_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,undo,commands,events,get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle))

def tx_written(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events: List<&2,E>,+stamp: L.Stamp,result: Replacement<W.World<S,Store,R,E>,C>) -> SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match result:
    case Replaced{world,previous}:
      Written{T.Tx{world,(world => restore_stamp(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,handle,stamp,restore(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,previous,world))) <> undo,commands,events}}
    case ReplaceRejected{world,Some{incoming},error}:
      WriteRejected{T.Tx{world,undo,commands,events},incoming,error}
    case ReplaceRejected{world,None{},error}:
      WriteFailure{T.Tx{world,undo,commands,events},error}

def tx_set_stamped(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events: List<&2,E>,incoming: C,observed: W.World<S,Store,R,E> & L.Stamp) -> SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  (world,stamp) = observed
  tx_written(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,stamp,replace(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle,Some{incoming}))

def tx_set(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Family<S,Store,Rest,C,V,Token,take,put,project>,tx: T.Tx<W.World<S,Store,R,E>,E>,+handle: W.Handle<S>,incoming: C) -> SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match tx:
    case T.Tx{world,undo,commands,events}:
      tx_set_stamped(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,incoming,lifecycle(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle))

def tx_removed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events: List<&2,E>,+stamp: L.Stamp,result: Replacement<W.World<S,Store,R,E>,C>) -> RemoveResult<T.Tx<W.World<S,Store,R,E>,E>>:
  match result:
    case Replaced{world,previous}:
      Removed{T.Tx{world,(world => restore_stamp(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,handle,stamp,restore(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,previous,world))) <> undo,commands,events}}
    case ReplaceRejected{world,_,error}:
      RemoveRejected{T.Tx{world,undo,commands,events},error}

def tx_remove_stamped(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events: List<&2,E>,observed: W.World<S,Store,R,E> & L.Stamp) -> RemoveResult<T.Tx<W.World<S,Store,R,E>,E>>:
  (world,stamp) = observed
  tx_removed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,stamp,replace(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle,None{}))

def tx_remove(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Family<S,Store,Rest,C,V,Token,take,put,project>,tx: T.Tx<W.World<S,Store,R,E>,E>,+handle: W.Handle<S>) -> RemoveResult<T.Tx<W.World<S,Store,R,E>,E>>:
  match tx:
    case T.Tx{world,undo,commands,events}:
      tx_remove_stamped(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,lifecycle(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle))
