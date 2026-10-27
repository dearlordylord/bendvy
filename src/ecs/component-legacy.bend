import Base
import ./component.bend as Component
import ./change-tick.bend as Tick
import ./deferred-command.bend as Deferred
import ./entity-key-render.bend as KeyRender
import ./trace-facts.bend as TraceFacts
import ./lifecycle.bend as L
import ./column.bend as Col
import ./world.bend as W
import ./transaction.bend as T
import ./entity-key.bend as K

# Historical transactional operations over the shared component family types.
def tx_get_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,observed: W.World<S,Store,R,E> & Component.Access<V>) -> T.Tx<W.World<S,Store,R,E>,E> & Component.Access<V>:
  (world,value) = observed
  (T.Tx{world,undo,commands,events,trace},value)

# Read through the current Tx World, preserving its journal, commands, events and
# trace. Returns the same Component.Access distinctions as get; reads do not finish the Tx.
def tx_get(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Component.Family<S,Store,Rest,C,V,Token,take,put,project>,tx: T.Tx<W.World<S,Store,R,E>,E>,handle: W.Handle<S>) -> T.Tx<W.World<S,Store,R,E>,E> & Component.Access<V>:
  match tx:
    case T.Tx{world,undo,commands,events,trace}:
      tx_get_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,undo,commands,events,trace,Component.get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle))

def trace_error(error:W.WorldError) -> String:
  match error:
    case W.MissingEntity{}:"Component.MissingEntity"
    case W.ReservationUnauthorized{}:"ReservationUnauthorized"
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
def family_name(~S:Data,~Store:Type,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,family:Component.Family<S,Store,Rest,C,V,Token,take,put,project>) -> String:
  match family:
    case Component.Family{name}:name
def tx_written(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Component.Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,+stamp: L.Stamp,result: Component.Replacement<W.World<S,Store,R,E>,C>) -> Component.SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match result:
    case Component.Replaced{world,previous}:
      Component.Written{T.Tx{world,(world => Component.restore_stamp(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,handle,stamp,Component.restore(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,previous,world))) <> undo,commands,events,trace_write(~S,trace,family_name(~S,~Store,~Rest,~C,~V,~Token,~take,~put,~project,family),handle,TraceFacts.Attempted{})}}
    case Component.ReplaceRejected{world,Some{incoming},+error}:
      Component.WriteRejected{T.Tx{world,undo,commands,events,trace_refusal(~S,trace,family_name(~S,~Store,~Rest,~C,~V,~Token,~take,~put,~project,family),handle,error)},incoming,error}
    case Component.ReplaceRejected{world,None{},+error}:
      Component.WriteFailure{T.Tx{world,undo,commands,events,trace_refusal(~S,trace,family_name(~S,~Store,~Rest,~C,~V,~Token,~take,~put,~project,family),handle,error)},error}

def tx_set_stamped(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Component.Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,incoming: C,observed: W.World<S,Store,R,E> & L.Stamp) -> Component.SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  (world,stamp) = observed
  tx_written(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,trace,stamp,Component.replace(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle,Some{incoming}))

def stamped_store_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,stamp:L.Stamp,result:Store & Component.Swap<C>) -> Store & (Component.Swap<C> & L.Stamp):
  match result:
    case (store,outcome): (store,(outcome,stamp))

def stamped_column(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,rest:Rest,+id:U32,incoming:C,+tick:Tick.Tick,allowed:Bool,observed:Col.Column<S,C> & L.Stamp) -> Store & (Component.Swap<C> & L.Stamp):
  match allowed observed:
    case False{}, (column,stamp): (put(rest,column),(Component.SwapRejected{Some{incoming}},stamp))
    case True{}, (column,stamp): stamped_store_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,stamp,Component.swap_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,rest,id,True{},tick,Col.swap(~S,~C,Col.ensure(~S,~C,column,id),id,Some{incoming})))

def stamped_store(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+id:U32,incoming:C,+tick:Tick.Tick,allowed:Bool,split:Rest & Col.Column<S,C>) -> Store & (Component.Swap<C> & L.Stamp):
  match split:
    case (rest,column): stamped_column(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,rest,id,incoming,tick,allowed,Col.lifecycle(~S,~C,column,id))

def stamped_replaced(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,observed:W.World<S,Store,R,E> & (Component.Swap<C> & L.Stamp)) -> Component.Replacement<W.World<S,Store,R,E>,C> & L.Stamp:
  match observed:
    case (world,(Component.Swapped{previous},stamp)): (Component.Replaced{world,previous},stamp)
    case (world,(Component.SwapRejected{incoming},stamp)): (Component.ReplaceRejected{world,incoming,W.CapacityExceeded{}},stamp)

def stamped_clocked(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,world:W.World<S,Store,R,E>,id:U32,incoming:C,tick:Tick.Tick) -> Component.Replacement<W.World<S,Store,R,E>,C> & L.Stamp:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle}:
      stamped_replaced(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.with_store_finish(~S,~Store,~R,~E,~(Component.Swap<C> & L.Stamp),stamped_store(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,incoming,tick,True{},take(store)),namespace,allocator,resource,events,pending,registrations,nextSystemId,clock,lifecycle))

def stamped_advanced(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,id:U32,incoming:C,advanced:W.World<S,Store,R,E> & Tick.Tick) -> Component.Replacement<W.World<S,Store,R,E>,C> & L.Stamp:
  (world,tick)=advanced
  stamped_clocked(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,world,id,incoming,tick)

def stamped_world(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,id:U32,incoming:C,world:W.World<S,Store,R,E>) -> Component.Replacement<W.World<S,Store,R,E>,C> & L.Stamp:
  stamped_advanced(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,incoming,W.write_clock(~S,~Store,~R,~E,world))

def stamped_allowed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,checked:W.World<S,Store,R,E> & Bool,handle:W.Handle<S>,incoming:C) -> Component.Replacement<W.World<S,Store,R,E>,C> & L.Stamp:
  match checked handle:
    case (world,False{}) _: (Component.ReplaceRejected{world,Some{incoming},W.MissingEntity{}},L.Stamp{None{},None{}})
    case (world,True{}) W.Handle{_,K.EntityKey{+id,_}}: stamped_world(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,incoming,world)

def tx_set_fused(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family:Component.Family<S,Store,Rest,C,V,Token,take,put,project>,+handle:W.Handle<S>,undo:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events:List<&2,E>,trace:TraceFacts.State,observed:Component.Replacement<W.World<S,Store,R,E>,C> & L.Stamp) -> Component.SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match observed:
    case (result,stamp): tx_written(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,trace,stamp,result)

# Write an actual possibly-affine Type payload into the current Tx World and
# journal the old payload and stamp for rollback. Successful writes are visible
# within this Tx immediately; finish decides commit versus inverse replay. Refusal
# returns the incoming owner through Component.WriteRejected. Ordinary rollback is not a
# receipt returning every newly written payload; use explicit recovery APIs for that.
def tx_set(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Component.Family<S,Store,Rest,C,V,Token,take,put,project>,tx: T.Tx<W.World<S,Store,R,E>,E>,+handle: W.Handle<S>,incoming: C) -> Component.SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match tx:
    case T.Tx{world,undo,commands,events,trace}:
      tx_set_fused(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,trace,stamped_allowed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.valid(~S,~Store,~R,~E,world,handle),handle,incoming))

def tx_removed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Component.Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,+stamp: L.Stamp,result: Component.Replacement<W.World<S,Store,R,E>,C>) -> Component.RemoveResult<T.Tx<W.World<S,Store,R,E>,E>>:
  match result:
    case Component.Replaced{world,previous}:
      Component.Removed{T.Tx{world,(world => Component.restore_stamp(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,handle,stamp,Component.restore(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,previous,world))) <> undo,commands,events,trace}}
    case Component.ReplaceRejected{world,_,error}:
      Component.RemoveRejected{T.Tx{world,undo,commands,events,trace},error}

def tx_remove_stamped(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Component.Family<S,Store,Rest,C,V,Token,take,put,project>,+handle: W.Handle<S>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,observed: W.World<S,Store,R,E> & L.Stamp) -> Component.RemoveResult<T.Tx<W.World<S,Store,R,E>,E>>:
  (world,stamp) = observed
  tx_removed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,trace,stamp,Component.replace(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle,None{}))

# Remove from a live entity within Tx, journaling the previous owner/stamp for
# rollback. Removing an already absent component can succeed; invalid handles or
# capacity refusal return Component.RemoveRejected. Finish is still the caller's choice.
def tx_remove(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,+family: Component.Family<S,Store,Rest,C,V,Token,take,put,project>,tx: T.Tx<W.World<S,Store,R,E>,E>,+handle: W.Handle<S>) -> Component.RemoveResult<T.Tx<W.World<S,Store,R,E>,E>>:
  match tx:
    case T.Tx{world,undo,commands,events,trace}:
      tx_remove_stamped(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,undo,commands,events,trace,Component.lifecycle(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle))

def displayed_access(~V:Data,~display:V -> String,value:Component.Access<V>) -> TraceFacts.Value:
  match value:
    case Component.Found{value}:TraceFacts.DisplayedValue{display(value)}
    case Component.ComponentAbsent{}:TraceFacts.UnavailableValue{}
    case Component.MissingEntity{}:TraceFacts.UnavailableValue{}
def displayed_written(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,before:TraceFacts.Value,after:TraceFacts.Value,result:Component.SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>) -> Component.SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match result:
    case Component.Written{tx}:Component.Written{T.annotate_newest(~W.World<S,Store,R,E>,~E,tx,before,after)}
    case Component.WriteRejected{tx,incoming,error}:Component.WriteRejected{T.annotate_newest(~W.World<S,Store,R,E>,~E,tx,before,after),incoming,error}
    case Component.WriteFailure{tx,error}:Component.WriteFailure{T.annotate_newest(~W.World<S,Store,R,E>,~E,tx,before,after),error}
def displayed_viewed(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~display:V -> String,family:Component.Family<S,Store,Rest,C,V,Token,take,put,project>,handle:W.Handle<S>,incoming:C & V,observed:T.Tx<W.World<S,Store,R,E>,E> & Component.Access<V>) -> Component.SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match incoming observed:
    case (incoming,after), (tx,before):displayed_written(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,displayed_access(~V,~display,before),TraceFacts.DisplayedValue{display(after)},tx_set(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,tx,handle,incoming))
def displayed_enabled(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~display:V -> String,+family:Component.Family<S,Store,Rest,C,V,Token,take,put,project>,+handle:W.Handle<S>,incoming:C,observed:T.Tx<W.World<S,Store,R,E>,E> & Bool) -> Component.SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match observed:
    case (tx,False{}):tx_set(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,tx,handle,incoming)
    case (tx,True{}):displayed_viewed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~display,family,handle,project(incoming),tx_get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,tx,handle))
# Trace-aware tx_set: when tracing is enabled, project the current and incoming
# values and render detached V strings to annotate the attempted write/refusal.
# Disabled tracing delegates directly without these presentation reads. Ownership
# and write results remain those of tx_set; project/display are trusted adapters.
def tx_set_displayed(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,~display:V -> String,family:Component.Family<S,Store,Rest,C,V,Token,take,put,project>,tx:T.Tx<W.World<S,Store,R,E>,E>,handle:W.Handle<S>,incoming:C) -> Component.SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>:
  displayed_enabled(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~display,family,handle,incoming,T.trace_enabled(~W.World<S,Store,R,E>,~E,tx))
