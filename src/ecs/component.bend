import Base
import ./change-tick.bend as Tick
import ./clock-state.bend as Clock
import ./deferred-command.bend as Deferred
import ./entity-key-render.bend as KeyRender
import ./trace-facts.bend as TraceFacts
import lifecycle.bend as L
import column.bend as Col
import world.bend as W
import transaction.bend as T
import entity-key.bend as K
import entity-allocator.bend as A

# Caller-authored schema lenses are trusted provisioning. The gameplay callback
# receives only universally quantified provider handles, never these owners.
# Trusted schema provisioning for one component column and detached Data view V.
# take/put must return the actual affine storage owners; project returns C with V.
# The nominal Token distinguishes families; the display name is not access proof.
type Family<-S: Data,-Store: Type,-Rest: Type,-C: Type,-V: Data,-Token: Data,-take: Store -> Rest & Col.Column<S,C>,-put: Rest -> Col.Column<S,C> -> Store,-project: C -> C & V> is Data:
  Family{name: String}
# Detached read result: Found holds V, ComponentAbsent means a valid entity lacks
# this component, and MissingEntity covers invalid, stale or foreign handles.
type Access<V: Data> is Data:
  Found{value: V}
  ComponentAbsent{}
  MissingEntity{}
# Immediate replacement result retaining World in every branch. Replaced returns
# the displaced actual payload owner; rejection returns the incoming optional owner
# and error. Neither Type payload is copied into detached observation data.
type Replacement<W: Type,C: Type> is Type:
  Replaced{world: W,previous: Maybe<&1,C>}
  ReplaceRejected{world: W,incoming: Maybe<&1,C>,error: W.WorldError}
# Internal storage-adapter result carrying the displaced or rejected owner.
# It is not a handle-validation result or a gameplay capability.
type Swap<C: Type> is Type:
  Swapped{previous: Maybe<&1,C>}
  SwapRejected{incoming: Maybe<&1,C>}
# Transactional write result. Written retains the Tx with its inverse journal;
# WriteRejected additionally returns the actual incoming C. WriteFailure has no
# incoming owner. These results do not themselves commit or finish the transaction.
type SetResult<Tx: Type,C: Type> is Type:
  Written{tx: Tx}
  WriteRejected{tx: Tx,incoming: C,error: W.WorldError}
  WriteFailure{tx: Tx,error: W.WorldError}
# Transactional removal result retaining Tx on success or refusal. The removed
# payload remains in the inverse journal for rollback rather than being returned.
type RemoveResult<Tx: Type> is Type:
  Removed{tx: Tx}
  RemoveRejected{tx: Tx,error: W.WorldError}

# Define trusted column/projection plumbing for this family. This does not insert
# a component, validate an entity or register a gameplay system. Ordinary declaration
# providers expose only the appropriate opaque-owner capabilities to gameplay.
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

def get_world(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,world: W.World<S,Store,R,E>) -> W.World<S,Store,R,E> & Access<V>:
  match world:
    case W.World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:
      W.with_store_finish(~S,~Store,~R,~E,~Access<V>,get_store(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,take(store)),namespace,allocator,resource,events,pending,registrations,nextSystemId,clock)

def get_allowed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,checked: W.World<S,Store,R,E> & Bool,+handle: W.Handle<S>) -> W.World<S,Store,R,E> & Access<V>:
  match checked handle:
    case (world,False{}) _: (world,MissingEntity{})
    case (world,True{}) W.Handle{_,K.EntityKey{+id,_}}:
      get_world(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,world)

def get_checked_fields(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,checked: A.Allocator & Bool,key: K.Key,namespace: U32,store: Store,resource: R,events: List<&2,E>,pending: List<Deferred.Command<W.World<S,Store,R,E>>>,registrations: List<&2,W.RegistrationMeta>,nextSystemId: U32,clock: Clock.State) -> W.World<S,Store,R,E> & Access<V>:
  match checked key:
    case (allocator,False{}) _: (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},MissingEntity{})
    case (allocator,True{}) K.EntityKey{+id,_}:
      W.with_store_finish(~S,~Store,~R,~E,~Access<V>,get_store(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,take(store)),namespace,allocator,resource,events,pending,registrations,nextSystemId,clock)

def get_namespace_fields(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,allowed: Bool,+key: K.Key,allocator: A.Allocator,namespace: U32,store: Store,resource: R,events: List<&2,E>,pending: List<Deferred.Command<W.World<S,Store,R,E>>>,registrations: List<&2,W.RegistrationMeta>,nextSystemId: U32,clock: Clock.State) -> W.World<S,Store,R,E> & Access<V>:
  match allowed:
    case False{}: (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},MissingEntity{})
    case True{}: get_checked_fields(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,A.checked(allocator,key,1),key,namespace,store,resource,events,pending,registrations,nextSystemId,clock)

# Read a detached view while returning World and the actual projected payload to
# its column. Validate namespace, generation and live state before column access;
# invalid/stale/foreign handles yield MissingEntity, not ComponentAbsent.
# See examples/health-decay/schema.bend for family provisioning.
def get(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Family<S,Store,Rest,C,V,Token,take,put,project>,world: W.World<S,Store,R,E>,+handle: W.Handle<S>) -> W.World<S,Store,R,E> & Access<V>:
  match world handle:
    case W.World{+namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock} W.Handle{ns,key}:
      get_namespace_fields(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,U32.is_eq(namespace,ns),key,allocator,namespace,store,resource,events,pending,registrations,nextSystemId,clock)

def has_access(~V: Data,value: Access<V>) -> Access<Bool>:
  match value:
    case MissingEntity{}: MissingEntity{}
    case ComponentAbsent{}: Found{False{}}
    case Found{_}: Found{True{}}

def has_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,observed: W.World<S,Store,R,E> & Access<V>) -> W.World<S,Store,R,E> & Access<Bool>:
  (world,value) = observed
  (world,has_access(~V,value))

# Return presence as Found(Bool), preserving MissingEntity for invalid handles.
# This delegates to get, so the configured projection is evaluated on a present
# payload; it is not a projection-free raw occupancy query.
def has(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Family<S,Store,Rest,C,V,Token,take,put,project>,world: W.World<S,Store,R,E>,handle: W.Handle<S>) -> W.World<S,Store,R,E> & Access<Bool>:
  has_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle))

def owner_present(~C: Type,owner: Maybe<&1,C>) -> Maybe<&1,C> & Bool:
  match owner:
    case None{}: (None{},False{})
    case Some{owner}: (Some{owner},True{})

def mark_swapped(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,rest: Rest,column: Col.Column<S,C>,+id: U32,incoming: Bool,tick: Tick.Tick,observed: Maybe<&1,C> & Bool) -> Store & Swap<C>:
  (previous,wasPresent) = observed
  (put(rest,Col.mark(~S,~C,column,id,incoming,wasPresent,tick)),Swapped{previous})

def swap_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,rest: Rest,+id: U32,incoming: Bool,tick: Tick.Tick,result: Col.SwapOutcome<S,C>) -> Store & Swap<C>:
  match result:
    case Col.Accepted{column,previous}: mark_swapped(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,rest,column,id,incoming,tick,owner_present(~C,previous))
    case Col.Rejected{column,incoming}: (put(rest,column),SwapRejected{incoming})

def swap_store(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,incoming: Maybe<&1,C>,incomingPresent: Bool,tick: Tick.Tick,split: Rest & Col.Column<S,C>) -> Store & Swap<C>:
  (rest,column) = split
  swap_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,rest,id,incomingPresent,tick,Col.swap(~S,~C,Col.ensure(~S,~C,column,id),id,incoming))

def swap_world(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,incoming: Maybe<&1,C>,incomingPresent: Bool,tick: Tick.Tick,world: W.World<S,Store,R,E>) -> W.World<S,Store,R,E> & Swap<C>:
  match world:
    case W.World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:
      W.with_store_finish(~S,~Store,~R,~E,~Swap<C>,swap_store(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,incoming,incomingPresent,tick,take(store)),namespace,allocator,resource,events,pending,registrations,nextSystemId,clock)

def replaced(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,result: W.World<S,Store,R,E> & Swap<C>) -> Replacement<W.World<S,Store,R,E>,C>:
  match result:
    case (world,Swapped{previous}): Replaced{world,previous}
    case (world,SwapRejected{incoming}): ReplaceRejected{world,incoming,W.CapacityExceeded{}}

def replace_clock_advanced(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,incomingPresent: Bool,incoming: Maybe<&1,C>,advanced: W.World<S,Store,R,E> & Tick.Tick) -> Replacement<W.World<S,Store,R,E>,C>:
  (world,+tick) = advanced
  replaced(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,swap_world(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,incoming,incomingPresent,tick,world))

def replace_present(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,world:W.World<S,Store,R,E>,id:U32,observed:Maybe<&1,C> & Bool) -> Replacement<W.World<S,Store,R,E>,C>:
  match observed:
    case (incoming,present):replace_clock_advanced(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,present,incoming,W.write_clock(~S,~Store,~R,~E,world))

def replace_allowed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,checked: W.World<S,Store,R,E> & Bool,+handle: W.Handle<S>,incoming: Maybe<&1,C>) -> Replacement<W.World<S,Store,R,E>,C>:
  match checked handle:
    case (world,False{}) _: ReplaceRejected{world,incoming,W.MissingEntity{}}
    case (world,True{}) W.Handle{_,K.EntityKey{+id,_}}:
      replace_present(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,world,id,owner_present(~C,incoming))

# Ordinary writes require a live entity. Foreign handles are rejected before
# any column access, size computation, allocation or owned replacement move.
# Immediately insert/replace with Some(C), or remove with None, on a live handle.
# Return displaced C on success and incoming C on rejection; capacity errors
# remain explicit. This operation is not deferred and has no automatic undo journal.
def replace(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Family<S,Store,Rest,C,V,Token,take,put,project>,world: W.World<S,Store,R,E>,+handle: W.Handle<S>,incoming: Maybe<&1,C>) -> Replacement<W.World<S,Store,R,E>,C>:
  replace_allowed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.valid(~S,~Store,~R,~E,world,handle),handle,incoming)

# Deferred creation may populate reserved entities before activation. This is
# provisioning/structural command machinery, not a gameplay capability.
# Trusted structural adapter permitting metadata-valid reserved entities as well
# as live ones. Retains replacement owners/results like replace; this is not a
# public gameplay bypass for accessing an arbitrary inactive entity.
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

def restore_world(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,incoming: Maybe<&1,C>,world: W.World<S,Store,R,E>) -> W.World<S,Store,R,E> & Unit:
  match world:
    case W.World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:
      W.with_store_finish(~S,~Store,~R,~E,~Unit,restore_store(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,incoming,take(store)),namespace,allocator,resource,events,pending,registrations,nextSystemId,clock)

def restore_observed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,observed: W.World<S,Store,R,E> & Unit) -> W.World<S,Store,R,E>:
  (world,_) = observed
  world

def restore_allowed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,checked: W.World<S,Store,R,E> & Bool,handle: W.Handle<S>,incoming: Maybe<&1,C>) -> W.World<S,Store,R,E>:
  match checked handle:
    case (world,False{}) _: world
    case (world,True{}) W.Handle{_,K.EntityKey{+id,_}}: restore_observed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,restore_world(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,incoming,world))

def restore(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,incoming: Maybe<&1,C>,world: W.World<S,Store,R,E>) -> W.World<S,Store,R,E>:
  restore_allowed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.metadata_valid(~S,~Store,~R,~E,world,handle),handle,incoming)

def lifecycle_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,rest: Rest,observed: Col.Column<S,C> & L.Stamp) -> Store & L.Stamp:
  (column,stamp) = observed
  (put(rest,column),stamp)

def lifecycle_store(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,split: Rest & Col.Column<S,C>) -> Store & L.Stamp:
  (rest,column) = split
  lifecycle_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,rest,Col.lifecycle(~S,~C,column,id))

def lifecycle_world(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,world: W.World<S,Store,R,E>) -> W.World<S,Store,R,E> & L.Stamp:
  match world:
    case W.World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:
      W.with_store_finish(~S,~Store,~R,~E,~L.Stamp,lifecycle_store(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,take(store)),namespace,allocator,resource,events,pending,registrations,nextSystemId,clock)

def lifecycle_allowed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,checked: W.World<S,Store,R,E> & Bool,handle: W.Handle<S>) -> W.World<S,Store,R,E> & L.Stamp:
  match checked handle:
    case (world,False{}) _: (world,L.Stamp{None{},None{}})
    case (world,True{}) W.Handle{_,K.EntityKey{+id,_}}: lifecycle_world(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,world)

# Read this component slot's lifecycle stamp while returning World. Invalid live
# handle validation yields Stamp(None,None); no detached component payload is returned.
def lifecycle(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Family<S,Store,Rest,C,V,Token,take,put,project>,world: W.World<S,Store,R,E>,+handle: W.Handle<S>) -> W.World<S,Store,R,E> & L.Stamp:
  lifecycle_allowed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.valid(~S,~Store,~R,~E,world,handle),handle)

def restore_stamp_store(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,stamp: L.Stamp,split: Rest & Col.Column<S,C>) -> Store & Unit:
  (rest,column) = split
  (put(rest,Col.restore_stamp(~S,~C,column,id,stamp)),Unit{})

def restore_stamp_world(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id: U32,stamp: L.Stamp,world: W.World<S,Store,R,E>) -> W.World<S,Store,R,E> & Unit:
  match world:
    case W.World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:
      W.with_store_finish(~S,~Store,~R,~E,~Unit,restore_stamp_store(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,stamp,take(store)),namespace,allocator,resource,events,pending,registrations,nextSystemId,clock)

def restore_stamp_done(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,observed: W.World<S,Store,R,E> & Unit) -> W.World<S,Store,R,E>:
  (world,_) = observed
  world

def restore_stamp(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+handle: W.Handle<S>,stamp: L.Stamp,world: W.World<S,Store,R,E>) -> W.World<S,Store,R,E>:
  match handle:
    case W.Handle{_,K.EntityKey{+id,_}}: restore_stamp_done(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,restore_stamp_world(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,stamp,world))

def tx_get_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,observed: W.World<S,Store,R,E> & Access<V>) -> T.Tx<W.World<S,Store,R,E>,E> & Access<V>:
  (world,value) = observed
  (T.Tx{world,undo,commands,events,trace},value)

# Read through the current Tx World, preserving its journal, commands, events and
# trace. Returns the same Access distinctions as get; reads do not finish the Tx.
def tx_get(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Family<S,Store,Rest,C,V,Token,take,put,project>,tx: T.Tx<W.World<S,Store,R,E>,E>,handle: W.Handle<S>) -> T.Tx<W.World<S,Store,R,E>,E> & Access<V>:
  match tx:
    case T.Tx{world,undo,commands,events,trace}:
      tx_get_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,undo,commands,events,trace,get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle))

def trace_error(error:W.WorldError) -> String:
  match error:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def trace_handle(~S:Data,handle:W.Handle<S>) -> String:
  match handle:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ KeyRender.show(key)
def trace_write(~S:Data,state:TraceFacts.State,name:String,handle:W.Handle<S>,result:TraceFacts.FactResult) -> TraceFacts.State:
  match state:
    case TraceFacts.Off{}:TraceFacts.Off{}
    case TraceFacts.On{facts}:TraceFacts.On{TraceFacts.Fact{TraceFacts.ComponentValue{},name,TraceFacts.WriteOperation{},Some{trace_handle(~S,handle)},TraceFacts.OpaqueValue{},TraceFacts.OpaqueValue{},result} <> facts}
def trace_refusal(~S:Data,state:TraceFacts.State,name:String,handle:W.Handle<S>,error:W.WorldError) -> TraceFacts.State:
  match state:
    case TraceFacts.Off{}:TraceFacts.Off{}
    case TraceFacts.On{facts}:TraceFacts.On{TraceFacts.Fact{TraceFacts.ComponentValue{},name,TraceFacts.WriteOperation{},Some{trace_handle(~S,handle)},TraceFacts.OpaqueValue{},TraceFacts.OpaqueValue{},TraceFacts.Refused{trace_error(error)}} <> facts}
def family_name(~S:Data,~Store:Type,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,family:Family<S,Store,Rest,C,V,Token,take,put,project>) -> String:
  match family:
    case Family{name}:name
def tx_written(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,+stamp: L.Stamp,result: Replacement<W.World<S,Store,R,E>,C>) -> SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match result:
    case Replaced{world,previous}:
      Written{T.Tx{world,(world => restore_stamp(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,handle,stamp,restore(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,previous,world))) <> undo,commands,events,trace_write(~S,trace,family_name(~S,~Store,~Rest,~C,~V,~Token,~take,~put,~project,family),handle,TraceFacts.Attempted{})}}
    case ReplaceRejected{world,Some{incoming},+error}:
      WriteRejected{T.Tx{world,undo,commands,events,trace_refusal(~S,trace,family_name(~S,~Store,~Rest,~C,~V,~Token,~take,~put,~project,family),handle,error)},incoming,error}
    case ReplaceRejected{world,None{},+error}:
      WriteFailure{T.Tx{world,undo,commands,events,trace_refusal(~S,trace,family_name(~S,~Store,~Rest,~C,~V,~Token,~take,~put,~project,family),handle,error)},error}

def tx_set_stamped(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,incoming: C,observed: W.World<S,Store,R,E> & L.Stamp) -> SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  (world,stamp) = observed
  tx_written(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,trace,stamp,replace(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle,Some{incoming}))

def stamped_store_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,stamp:L.Stamp,result:Store & Swap<C>) -> Store & (Swap<C> & L.Stamp):
  match result:
    case (store,outcome): (store,(outcome,stamp))

def stamped_column(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,rest:Rest,+id:U32,incoming:C,+tick:Tick.Tick,allowed:Bool,observed:Col.Column<S,C> & L.Stamp) -> Store & (Swap<C> & L.Stamp):
  match allowed observed:
    case False{}, (column,stamp): (put(rest,column),(SwapRejected{Some{incoming}},stamp))
    case True{}, (column,stamp): stamped_store_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,stamp,swap_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,rest,id,True{},tick,Col.swap(~S,~C,Col.ensure(~S,~C,column,id),id,Some{incoming})))

def stamped_store(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id:U32,incoming:C,+tick:Tick.Tick,allowed:Bool,split:Rest & Col.Column<S,C>) -> Store & (Swap<C> & L.Stamp):
  match split:
    case (rest,column): stamped_column(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,rest,id,incoming,tick,allowed,Col.lifecycle(~S,~C,column,id))

def stamped_replaced(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,observed:W.World<S,Store,R,E> & (Swap<C> & L.Stamp)) -> Replacement<W.World<S,Store,R,E>,C> & L.Stamp:
  match observed:
    case (world,(Swapped{previous},stamp)): (Replaced{world,previous},stamp)
    case (world,(SwapRejected{incoming},stamp)): (ReplaceRejected{world,incoming,W.CapacityExceeded{}},stamp)

def stamped_clocked(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,world:W.World<S,Store,R,E>,id:U32,incoming:C,tick:Tick.Tick) -> Replacement<W.World<S,Store,R,E>,C> & L.Stamp:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}:
      stamped_replaced(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.with_store_finish(~S,~Store,~R,~E,~(Swap<C> & L.Stamp),stamped_store(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,incoming,tick,True{},take(store)),namespace,allocator,resource,events,pending,registrations,nextSystemId,clock))

def stamped_advanced(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,id:U32,incoming:C,advanced:W.World<S,Store,R,E> & Tick.Tick) -> Replacement<W.World<S,Store,R,E>,C> & L.Stamp:
  (world,tick)=advanced
  stamped_clocked(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,world,id,incoming,tick)

def stamped_world(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,id:U32,incoming:C,world:W.World<S,Store,R,E>) -> Replacement<W.World<S,Store,R,E>,C> & L.Stamp:
  stamped_advanced(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,incoming,W.write_clock(~S,~Store,~R,~E,world))

def stamped_allowed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,checked:W.World<S,Store,R,E> & Bool,handle:W.Handle<S>,incoming:C) -> Replacement<W.World<S,Store,R,E>,C> & L.Stamp:
  match checked handle:
    case (world,False{}) _: (ReplaceRejected{world,Some{incoming},W.MissingEntity{}},L.Stamp{None{},None{}})
    case (world,True{}) W.Handle{_,K.EntityKey{+id,_}}: stamped_world(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,incoming,world)

def tx_set_fused(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family:Family<S,Store,Rest,C,V,Token,take,put,project>,+handle:W.Handle<S>,undo:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events:List<&2,E>,trace:TraceFacts.State,observed:Replacement<W.World<S,Store,R,E>,C> & L.Stamp) -> SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match observed:
    case (result,stamp): tx_written(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,trace,stamp,result)

# Write an actual possibly-affine Type payload into the current Tx World and
# journal the old payload and stamp for rollback. Successful writes are visible
# within this Tx immediately; finish decides commit versus inverse replay. Refusal
# returns the incoming owner through WriteRejected. Ordinary rollback is not a
# receipt returning every newly written payload; use explicit recovery APIs for that.
def tx_set(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Family<S,Store,Rest,C,V,Token,take,put,project>,tx: T.Tx<W.World<S,Store,R,E>,E>,+handle: W.Handle<S>,incoming: C) -> SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match tx:
    case T.Tx{world,undo,commands,events,trace}:
      tx_set_fused(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,trace,stamped_allowed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.valid(~S,~Store,~R,~E,world,handle),handle,incoming))

def tx_removed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,+stamp: L.Stamp,result: Replacement<W.World<S,Store,R,E>,C>) -> RemoveResult<T.Tx<W.World<S,Store,R,E>,E>>:
  match result:
    case Replaced{world,previous}:
      Removed{T.Tx{world,(world => restore_stamp(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,handle,stamp,restore(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,previous,world))) <> undo,commands,events,trace}}
    case ReplaceRejected{world,_,error}:
      RemoveRejected{T.Tx{world,undo,commands,events,trace},error}

def tx_remove_stamped(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,observed: W.World<S,Store,R,E> & L.Stamp) -> RemoveResult<T.Tx<W.World<S,Store,R,E>,E>>:
  (world,stamp) = observed
  tx_removed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,trace,stamp,replace(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle,None{}))

# Remove from a live entity within Tx, journaling the previous owner/stamp for
# rollback. Removing an already absent component can succeed; invalid handles or
# capacity refusal return RemoveRejected. Finish is still the caller's choice.
def tx_remove(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Family<S,Store,Rest,C,V,Token,take,put,project>,tx: T.Tx<W.World<S,Store,R,E>,E>,+handle: W.Handle<S>) -> RemoveResult<T.Tx<W.World<S,Store,R,E>,E>>:
  match tx:
    case T.Tx{world,undo,commands,events,trace}:
      tx_remove_stamped(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,trace,lifecycle(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle))

def displayed_access(~V:Data,~display:V -> String,value:Access<V>) -> TraceFacts.Value:
  match value:
    case Found{value}:TraceFacts.DisplayedValue{display(value)}
    case ComponentAbsent{}:TraceFacts.UnavailableValue{}
    case MissingEntity{}:TraceFacts.UnavailableValue{}
def displayed_written(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,before:TraceFacts.Value,after:TraceFacts.Value,result:SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>) -> SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match result:
    case Written{tx}:Written{T.annotate_newest(~W.World<S,Store,R,E>,~E,tx,before,after)}
    case WriteRejected{tx,incoming,error}:WriteRejected{T.annotate_newest(~W.World<S,Store,R,E>,~E,tx,before,after),incoming,error}
    case WriteFailure{tx,error}:WriteFailure{T.annotate_newest(~W.World<S,Store,R,E>,~E,tx,before,after),error}
def displayed_viewed(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~display:V -> String,family:Family<S,Store,Rest,C,V,Token,take,put,project>,handle:W.Handle<S>,incoming:C & V,observed:T.Tx<W.World<S,Store,R,E>,E> & Access<V>) -> SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match incoming observed:
    case (incoming,after), (tx,before):displayed_written(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,displayed_access(~V,~display,before),TraceFacts.DisplayedValue{display(after)},tx_set(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,tx,handle,incoming))
def displayed_enabled(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~display:V -> String,+family:Family<S,Store,Rest,C,V,Token,take,put,project>,+handle:W.Handle<S>,incoming:C,observed:T.Tx<W.World<S,Store,R,E>,E> & Bool) -> SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match observed:
    case (tx,False{}):tx_set(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,tx,handle,incoming)
    case (tx,True{}):displayed_viewed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~display,family,handle,project(incoming),tx_get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,tx,handle))
# Trace-aware tx_set: when tracing is enabled, project the current and incoming
# values and render detached V strings to annotate the attempted write/refusal.
# Disabled tracing delegates directly without these presentation reads. Ownership
# and write results remain those of tx_set; project/display are trusted adapters.
def tx_set_displayed(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~display:V -> String,family:Family<S,Store,Rest,C,V,Token,take,put,project>,tx:T.Tx<W.World<S,Store,R,E>,E>,handle:W.Handle<S>,incoming:C) -> SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  displayed_enabled(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~display,family,handle,incoming,T.trace_enabled(~W.World<S,Store,R,E>,~E,tx))
