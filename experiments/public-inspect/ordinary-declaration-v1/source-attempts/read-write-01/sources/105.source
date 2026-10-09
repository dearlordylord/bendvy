import Base
import ./column.bend as Col
import ./component.bend as F
import ./world.bend as W
import ./transaction.bend as T

type Queued<Tx: Type,C: Type> is Type:
  Queued{tx: Tx}
  QueueRejected{tx: Tx,incoming: Maybe<&1,C>,error: W.WorldError}

# Deferred structural changes own incoming payloads until barrier or discard.
def applied(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,result: F.Replacement<W.World<S,Store,R,E>,C>) -> W.World<S,Store,R,E>:
  match result:
    case F.Replaced{world,_}: world
    case F.ReplaceRejected{world,_,_}: world

def apply(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: F.Family<S,Store,Rest,C,V,Token,take,put,project>,world: W.World<S,Store,R,E>,handle: W.Handle<S>,incoming: Maybe<&1,C>) -> W.World<S,Store,R,E>:
  applied(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,F.replace(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle,incoming))

def queue_checked(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,allowed: Bool,family: F.Family<S,Store,Rest,C,V,Token,take,put,project>,world: W.World<S,Store,R,E>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events: List<&2,E>,handle: W.Handle<S>,incoming: Maybe<&1,C>) -> Queued<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match allowed:
    case False{}: QueueRejected{T.Tx{world,undo,commands,events},incoming,W.MissingEntity{}}
    case True{}: Queued{T.Tx{world,undo,(w => apply(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,w,handle,incoming)) <> commands,events}}

def queue_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: F.Family<S,Store,Rest,C,V,Token,take,put,project>,checked: W.World<S,Store,R,E> & Bool,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events: List<&2,E>,handle: W.Handle<S>,incoming: Maybe<&1,C>) -> Queued<T.Tx<W.World<S,Store,R,E>,E>,C>:
  (world,allowed) = checked
  queue_checked(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,allowed,family,world,undo,commands,events,handle,incoming)

def tx_replace(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: F.Family<S,Store,Rest,C,V,Token,take,put,project>,tx: T.Tx<W.World<S,Store,R,E>,E>,+handle: W.Handle<S>,incoming: Maybe<&1,C>) -> Queued<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match tx:
    case T.Tx{world,undo,commands,events}: queue_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,W.valid(~S,~Store,~R,~E,world,handle),undo,commands,events,handle,incoming)

def tx_insert(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: F.Family<S,Store,Rest,C,V,Token,take,put,project>,tx: T.Tx<W.World<S,Store,R,E>,E>,handle: W.Handle<S>,incoming: C) -> Queued<T.Tx<W.World<S,Store,R,E>,E>,C>:
  tx_replace(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,tx,handle,Some{incoming})

def tx_remove(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: F.Family<S,Store,Rest,C,V,Token,take,put,project>,tx: T.Tx<W.World<S,Store,R,E>,E>,handle: W.Handle<S>) -> Queued<T.Tx<W.World<S,Store,R,E>,E>,C>:
  tx_replace(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,tx,handle,None{})

# Observed removal publishes only after successful barrier application and a real owned slot.
def removal_published(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~record: W.Handle<S> -> E,handle: W.Handle<S>,result: F.Replacement<W.World<S,Store,R,E>,C>) -> W.World<S,Store,R,E>:
  match result:
    case F.Replaced{world,None{}}: world
    case F.Replaced{world,Some{owner}}: W.event_publish(~S,~Store,~R,~E,world,[record(handle)])
    case F.ReplaceRejected{world,_,_}: world

def remove_apply_observed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~record: W.Handle<S> -> E,family: F.Family<S,Store,Rest,C,V,Token,take,put,project>,world: W.World<S,Store,R,E>,+handle: W.Handle<S>,incoming: Maybe<&1,C>) -> W.World<S,Store,R,E>:
  removal_published(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~record,handle,F.replace(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle,incoming))

def removed_queue_checked(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~record: W.Handle<S> -> E,allowed: Bool,family: F.Family<S,Store,Rest,C,V,Token,take,put,project>,world: W.World<S,Store,R,E>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events: List<&2,E>,handle: W.Handle<S>,incoming: Maybe<&1,C>) -> Queued<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match allowed:
    case False{}: QueueRejected{T.Tx{world,undo,commands,events},incoming,W.MissingEntity{}}
    case True{}: Queued{T.Tx{world,undo,(w => remove_apply_observed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~record,family,w,handle,incoming)) <> commands,events}}

def removed_queue_join(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~record: W.Handle<S> -> E,family: F.Family<S,Store,Rest,C,V,Token,take,put,project>,checked: W.World<S,Store,R,E> & Bool,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events: List<&2,E>,handle: W.Handle<S>,incoming: Maybe<&1,C>) -> Queued<T.Tx<W.World<S,Store,R,E>,E>,C>:
  (world,allowed) = checked
  removed_queue_checked(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~record,allowed,family,world,undo,commands,events,handle,incoming)

def tx_remove_observed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~record: W.Handle<S> -> E,family: F.Family<S,Store,Rest,C,V,Token,take,put,project>,tx: T.Tx<W.World<S,Store,R,E>,E>,+handle: W.Handle<S>) -> Queued<T.Tx<W.World<S,Store,R,E>,E>,C>:
  match tx:
    case T.Tx{world,undo,commands,events}: removed_queue_join(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~record,family,W.valid(~S,~Store,~R,~E,world,handle),undo,commands,events,handle,None{})
