import Base
import ./change-tick.bend as Tick
import ./deferred-command.bend as Deferred
import ./trace-facts.bend as TraceFacts
import world.bend as W
import column.bend as Col
import component.bend as Cmp
import component-legacy.bend as CmpLegacy
import transaction.bend as T
import resource-legacy.bend as Res
import commands.bend as Cmd
import capabilities.bend as Cap
import lifecycle.bend as L

# Trusted engine row carrier: affine Tx, current handle, first recorded operation
# error and invocation cursor. Ordinary gameplay receives opaque H instead of raw
# Frame fields; constructing one does not establish handle validity or authority.
type Frame<-S: Data,-Store: Type,-R: Type,-E: Data> is Type:
  Frame{tx: T.Tx<W.World<S,Store,R,E>,E>,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: Maybe<&2,Tick.Tick>}
# Execution error separates user-declared failure from a recorded World access
# refusal. A recorded access error takes precedence over the returned user outcome.
type Error<U: Data> is Data:
  UserError{error: U}
  AccessError{error: W.WorldError}
# Trusted closed declaration: capability and membership choices travel together.
# Trusted setup combines grants and membership predicate for one Ops shape.
# Canonical ordinary declarations derive this pair together; raw Plan construction
# does not validate arbitrary callbacks or infer capabilities from metadata.
type Plan<-S: Data,-Store: Type,-R: Type,-E: Data,-Ops: Type -> Type> is Type:
  Plan{caps: Ops(Frame<S,Store,R,E>),select: Frame<S,Store,R,E> -> Frame<S,Store,R,E> & Bool}
# Returned World and traversal outcome with ordered detached Data row outputs.
# Failure returns the rolled-back World and an empty output list, including when
# earlier rows produced values. This is not an affine payload recovery receipt.
type Executed<-World: Type,Error: Data,Out: Data> is Type:
  Executed{world: World,outcome: T.Outcome<Error>,values: List<&2,Out>}
# Family membership modes: Required/Present require Found, Absent requires a live
# entity without the component, Optional admits either live presence state. Invalid
# or foreign/stale handles never satisfy these family selectors.
type Selection is Data:
  Required{}
  Present{}
  Absent{}
  Optional{}

def first_error(previous: Maybe<&2,W.WorldError>,error: W.WorldError) -> Maybe<&2,W.WorldError>:
  match previous:
    case None{}: Some{error}
    case Some{previous}: Some{previous}

def read_join(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,+handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: Maybe<&2,Tick.Tick>,observed: T.Tx<W.World<S,Store,R,E>,E> & Cmp.Access<V>) -> Frame<S,Store,R,E> & Cmp.Access<V>:
  (tx,value) = observed
  (Frame{tx,handle,error,cursor},value)
# Advanced row operation: read the current handle through CmpLegacy.tx_get, returning
# Frame and detached Access<V>. Missing/absent remains an explicit Access result;
# this read alone does not store a new Frame access error.
def get(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Cmp.Access<V>:
  match frame:
    case Frame{tx,+handle,error,cursor}: read_join(~S,~Store,~R,~E,~V,handle,error,cursor,CmpLegacy.tx_get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,tx,handle))
def written(~S: Data,~Store: Type,~R: Type,~E: Data,~C: Type,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: Maybe<&2,Tick.Tick>,result: Cmp.SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>) -> Frame<S,Store,R,E>:
  match result:
    case Cmp.Written{tx}: Frame{tx,handle,error,cursor}
    case Cmp.WriteRejected{tx,_,reason}: Frame{tx,handle,first_error(error,reason),cursor}
    case Cmp.WriteFailure{tx,reason}: Frame{tx,handle,first_error(error,reason),cursor}
# Advanced row write consuming actual C and returning Frame. Refusal records the
# first access error and consumes rejected incoming C without returning a receipt.
# Successful writes journal displaced payload/stamp for transaction rollback.
def set(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,frame: Frame<S,Store,R,E>,replacement: C) -> Frame<S,Store,R,E>:
  match frame:
    case Frame{tx,+handle,error,cursor}: written(~S,~Store,~R,~E,~C,handle,error,cursor,CmpLegacy.tx_set(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,tx,handle,replacement))
# Build a canonical component read grant for the current row. Trusted family
# lenses/projector return their owners; gameplay sees only detached Access<V>.
def read_family(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>) -> Cap.Read<Frame<S,Store,R,E>,V>:
  Cap.Read{get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family)}
# Build current-row component read/write grants. The setter consumes Type C and
# records refusal on Frame; enclosing execution finishes the transaction. No
# automatic incoming-owner recovery is added to the capability signature.
def write_family(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>) -> Cap.Write<Frame<S,Store,R,E>,C,V>:
  Cap.Write{get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family),set(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family)}

def value_join(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: Maybe<&2,Tick.Tick>,observed: T.Tx<W.World<S,Store,R,E>,E> & V) -> Frame<S,Store,R,E> & V:
  (tx,value) = observed
  (Frame{tx,handle,error,cursor},value)
# Advanced whole-resource read through its owner-returning detached projection.
# Preserves the current handle/error/cursor; the projector is trusted provisioning.
def resource_get(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,~project: R -> R & V,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & V:
  match frame:
    case Frame{tx,handle,error,cursor}: value_join(~S,~Store,~R,~E,~V,handle,error,cursor,Res.tx_get(~S,~Store,~R,~E,~V,~project,tx))
# Advanced whole-R replacement, journaling the old owner for rollback. Consumes
# replacement R and returns Frame; selected-field authority needs a narrower grant.
def resource_set(~S: Data,~Store: Type,~R: Type,~E: Data,frame: Frame<S,Store,R,E>,replacement: R) -> Frame<S,Store,R,E>:
  match frame:
    case Frame{tx,handle,error,cursor}: Frame{Res.tx_replace(~S,~Store,~R,~E,tx,replacement),handle,error,cursor}
# Build a detached resource read grant using a trusted owner-returning projector.
def resource_read(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,~project: R -> R & V) -> Cap.ValueRead<Frame<S,Store,R,E>,V>:
  Cap.ValueRead{resource_get(~S,~Store,~R,~E,~V,~project)}
# Build whole-resource read/replacement grants, not a selected-field permission.
# Type R remains owned by the transaction or inverse journal, not copied to V.
def resource_write(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,~project: R -> R & V) -> Cap.ValueWrite<Frame<S,Store,R,E>,R,V>:
  Cap.ValueWrite{resource_get(~S,~Store,~R,~E,~V,~project),resource_set(~S,~Store,~R,~E)}
# Return the current detached handle with Frame. This is an identity projection,
# not a fresh liveness validation or permission to access another entity.
def handle_get(~S: Data,~Store: Type,~R: Type,~E: Data,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & W.Handle<S>:
  match frame:
    case Frame{tx,+handle,error,cursor}: (Frame{tx,handle,error,cursor},handle)
# Build the current-handle read grant without exposing raw Frame or World.
def handle_read(~S: Data,~Store: Type,~R: Type,~E: Data) -> Cap.ValueRead<Frame<S,Store,R,E>,W.Handle<S>>:
  Cap.ValueRead{handle_get(~S,~Store,~R,~E)}
# Advanced row operation staging a Data event in Tx; publication occurs only
# after successful execution finish. This does not synchronize an event Runtime.
def emit(~S: Data,~Store: Type,~R: Type,~E: Data,frame: Frame<S,Store,R,E>,event: E) -> Frame<S,Store,R,E>:
  match frame:
    case Frame{tx,handle,error,cursor}: Frame{T.emit(~W.World<S,Store,R,E>,~E,tx,event),handle,error,cursor}
# Build a Data-event publication grant with transactional staging semantics.
def event_write(~S: Data,~Store: Type,~R: Type,~E: Data) -> Cap.Send<Frame<S,Store,R,E>,E>:
  Cap.Send{emit(~S,~Store,~R,~E)}
def despawn_join(~S: Data,~Store: Type,~R: Type,~E: Data,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: Maybe<&2,Tick.Tick>,observed: T.Tx<W.World<S,Store,R,E>,E> & W.Status) -> Frame<S,Store,R,E>:
  match observed:
    case (tx,W.Accepted{}): Frame{tx,handle,error,cursor}
    case (tx,W.Rejected{reason}): Frame{tx,handle,first_error(error,reason),cursor}
# Advanced row operation staging schema-owned cleanup of the current handle.
# Admission refusal records the first Frame error. Accepted staging is not visible
# until successful finish and an explicit barrier; clear is trusted schema setup.
def despawn(~S: Data,~Store: Type,~R: Type,~E: Data,~clear: Store -> W.Handle<S> -> Store,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E>:
  match frame:
    case Frame{tx,+handle,error,cursor}: despawn_join(~S,~Store,~R,~E,handle,error,cursor,Cmd.tx_despawn_with(~S,~Store,~R,~E,~clear,tx,handle))
# Build a current-row deferred despawn grant using complete schema-owned cleanup.
def command_despawn(~S: Data,~Store: Type,~R: Type,~E: Data,~clear: Store -> W.Handle<S> -> Store) -> Cap.Action<Frame<S,Store,R,E>>:
  Cap.Action{despawn(~S,~Store,~R,~E,~clear)}
def spawn_join(~S: Data,~Store: Type,~R: Type,~E: Data,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: Maybe<&2,Tick.Tick>,observed: T.Tx<W.World<S,Store,R,E>,E> & W.Reservation<S>) -> Frame<S,Store,R,E> & W.Reservation<S>:
  match observed:
    case (tx,W.Reserved{+reserved}): (Frame{tx,handle,error,cursor},W.Reserved{reserved})
    case (tx,W.ReservationRejected{+reason}): (Frame{tx,handle,first_error(error,reason),cursor},W.ReservationRejected{reason})
# Advanced reservation/staging operation consuming possibly-affine Payload.
# Returns Frame and Reservation; refusal records an access error but returns no
# payload receipt. Reserved handles are Pending, not yet live/readable; populate
# runs at the barrier after successful finish, with reserved-id progress retained
# under the ordinary command rollback policy.
def spawn(~S: Data,~Store: Type,~R: Type,~E: Data,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,frame: Frame<S,Store,R,E>,payload: Payload) -> Frame<S,Store,R,E> & W.Reservation<S>:
  match frame:
    case Frame{tx,handle,error,cursor}: spawn_join(~S,~Store,~R,~E,handle,error,cursor,Cmd.tx_spawn(~S,~Store,~R,~E,~Payload,~populate,tx,payload))
# Build a deferred spawn request grant. populate is trusted structural setup and
# must consume the actual payload; the Reservation result is not payload recovery.
def command_spawn(~S: Data,~Store: Type,~R: Type,~E: Data,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>) -> Cap.Request<Frame<S,Store,R,E>,Payload,W.Reservation<S>>:
  Cap.Request{spawn(~S,~Store,~R,~E,~Payload,~populate)}

# Optional means a live entity with either family presence state.
def selected_value(~V: Data,mode: Selection,value: Cmp.Access<V>) -> Bool:
  match mode value:
    case Required{} Cmp.Found{_}: True{}
    case Present{} Cmp.Found{_}: True{}
    case Absent{} Cmp.ComponentAbsent{}: True{}
    case Optional{} Cmp.Found{_}: True{}
    case Optional{} Cmp.ComponentAbsent{}: True{}
    case _ _: False{}

def selected_join(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,mode: Selection,observed: Frame<S,Store,R,E> & Cmp.Access<V>) -> Frame<S,Store,R,E> & Bool:
  (frame,value) = observed
  (frame,selected_value(~V,mode,value))
# Select current-row membership through the canonical component read. Projectors
# may run for present components; the returned Frame owner is threaded onward.
# Selection does not add a write grant or treat MissingEntity as optional absence.
def family_match(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,~mode: Selection,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Bool:
  selected_join(~S,~Store,~R,~E,~V,mode,get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,frame))
# Always select and return Frame unchanged; this predicate itself validates no
# handle. each supplies a live-handle snapshot, unlike a forged raw Frame.
def all(~S: Data,~Store: Type,~R: Type,~E: Data,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Bool:
  (frame,True{})
def and_join(~S: Data,~Store: Type,~R: Type,~E: Data,~right: Frame<S,Store,R,E> -> Frame<S,Store,R,E> & Bool,observed: Frame<S,Store,R,E> & Bool) -> Frame<S,Store,R,E> & Bool:
  match observed:
    case (frame,False{}): (frame,False{})
    case (frame,True{}): right(frame)
# Conjoin predicates left before right, passing the actual returned Frame onward.
# False short-circuits right and preserves the owner returned by left; True passes
# that owner to right. See examples/query-composition/declarations.bend.
def both(~S: Data,~Store: Type,~R: Type,~E: Data,~left: Frame<S,Store,R,E> -> Frame<S,Store,R,E> & Bool,~right: Frame<S,Store,R,E> -> Frame<S,Store,R,E> & Bool,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Bool:
  and_join(~S,~Store,~R,~E,~right,left(frame))

# Advanced closed engine projection of stored grants; consumes Plan without
# invoking operations. This is declaration plumbing, not a gameplay grant builder.
def plan_caps(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,plan: Plan<S,Store,R,E,Ops>) -> Ops(Frame<S,Store,R,E>):
  match plan:
    case Plan{caps,_}: caps
# Advanced closed engine projection of the stored predicate. It does not run
# selection or validate the caller-authored Plan.
def plan_select(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,plan: Plan<S,Store,R,E,Ops>) -> Frame<S,Store,R,E> -> Frame<S,Store,R,E> & Bool:
  match plan:
    case Plan{_,select}: select

def outcome(~U: Data,internal: Maybe<&2,W.WorldError>,user: T.Outcome<U>) -> T.Outcome<Error<U>>:
  match internal user:
    case Some{error} _: T.Failure{AccessError{error}}
    case None{} T.Failure{error}: T.Failure{UserError{error}}
    case None{} T.Success{}: T.Success{}

# Row outputs are committed only when the entire traversal succeeds.
def prepend(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,value: Out,observed: T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>)) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>):
  (tx,result) = observed
  (outcome,values) = result
  (tx,(outcome,value <> values))
def completed(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,next: T.Tx<W.World<S,Store,R,E>,E> -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>),tx: T.Tx<W.World<S,Store,R,E>,E>,value: Out,result: T.Outcome<Error<U>>) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>):
  match result:
    case T.Success{}: prepend(~S,~Store,~R,~E,~U,~Out,value,next(tx))
    case T.Failure{error}: (tx,(T.Failure{error},[]))
def body_returned(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,next: T.Tx<W.World<S,Store,R,E>,E> -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>),observed: Frame<S,Store,R,E> & (T.Outcome<U> & Out)) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>):
  match observed:
    case (Frame{tx,_,internal,_},(user,value)): completed(~S,~Store,~R,~E,~U,~Out,next,tx,value,outcome(~U,internal,user))
def selected(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,next: T.Tx<W.World<S,Store,R,E>,E> -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>),observed: Frame<S,Store,R,E> & Bool) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>):
  match observed:
    case (Frame{tx,_,_,_},False{}): next(tx)
    case (frame,True{}): body_returned(~S,~Store,~R,~E,~U,~Out,next,Cap.invoke(~Ops,~A,~(T.Outcome<U> & Out),~body,~Frame<S,Store,R,E>,~plan_caps(~S,~Store,~R,~E,~Ops,plan),args,frame))
type RowResult<U: Data,Out: Data> is Data:
  Skipped{}
  Passed{value: Out}
  Failed{error: Error<U>}
def row_completed(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,tx: T.Tx<W.World<S,Store,R,E>,E>,value: Out,result: T.Outcome<Error<U>>) -> T.Tx<W.World<S,Store,R,E>,E> & RowResult<U,Out>:
  match result:
    case T.Success{}: (tx,Passed{value})
    case T.Failure{error}: (tx,Failed{error})
def row_body_returned(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,observed: Frame<S,Store,R,E> & (T.Outcome<U> & Out)) -> T.Tx<W.World<S,Store,R,E>,E> & RowResult<U,Out>:
  match observed:
    case (Frame{tx,_,internal,_},(user,value)): row_completed(~S,~Store,~R,~E,~U,~Out,tx,value,outcome(~U,internal,user))
def selected_row(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,observed: Frame<S,Store,R,E> & Bool) -> T.Tx<W.World<S,Store,R,E>,E> & RowResult<U,Out>:
  match observed:
    case (Frame{tx,_,_,_},False{}): (tx,Skipped{})
    case (frame,True{}): row_body_returned(~S,~Store,~R,~E,~U,~Out,Cap.invoke(~Ops,~A,~(T.Outcome<U> & Out),~body,~Frame<S,Store,R,E>,~plan_caps(~S,~Store,~R,~E,~Ops,plan),args,frame))
# Finish each row before the next; keep successful values in reverse order.
def run_handles_acc(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),handles: List<&2,W.Handle<S>>,+args: A,+cursor: Maybe<&2,Tick.Tick>,values: List<&2,Out>,observed: T.Tx<W.World<S,Store,R,E>,E> & RowResult<U,Out>) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>):
  match handles observed:
    case _ Tuple{tx,Failed{error}}: (tx,(T.Failure{error},List.reverse(&2,Out,values)))
    case Nil{} Tuple{tx,Skipped{}}: (tx,(T.Success{},List.reverse(&2,Out,values)))
    case Nil{} Tuple{tx,Passed{value}}: (tx,(T.Success{},List.reverse(&2,Out,value <> values)))
    case Con{handle,rest} Tuple{tx,Skipped{}}: run_handles_acc(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,rest,args,cursor,values,selected_row(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,plan_select(~S,~Store,~R,~E,~Ops,plan)(Frame{tx,handle,None{},cursor})))
    case Con{handle,rest} Tuple{tx,Passed{value}}: run_handles_acc(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,rest,args,cursor,value <> values,selected_row(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,plan_select(~S,~Store,~R,~E,~Ops,plan)(Frame{tx,handle,None{},cursor})))
# Internal owned traversal adapter for an already-open transaction. Execute the
# supplied list in order and return Tx plus outcome/outputs; unlike each, this does
# not enumerate handles or finish/commit. Ordinary callers use each/each_since.
def run_handles(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),handles: List<&2,W.Handle<S>>,args: A,cursor: Maybe<&2,Tick.Tick>,tx: T.Tx<W.World<S,Store,R,E>,E>) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>):
  run_handles_acc(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,handles,args,cursor,[],(tx,Skipped{}))
def finish_returned(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,values: List<&2,Out>,returned: T.Returned<W.World<S,Store,R,E>,Error<U>>) -> Executed<W.World<S,Store,R,E>,Error<U>,Out>:
  match returned:
    case T.Returned{world,T.Success{}}: Executed{world,T.Success{},values}
    case T.Returned{world,T.Failure{error}}: Executed{world,T.Failure{error},[]}
def finished(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,observed: T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>)) -> Executed<W.World<S,Store,R,E>,Error<U>,Out>:
  match observed:
    case (tx,(result,values)): finish_returned(~S,~Store,~R,~E,~U,~Out,values,Cmd.tx_finish(~S,~Store,~R,~E,~Error<U>,tx,result))
# Advanced engine adapter: execute a supplied handle list within one new Tx and
# finish it, using cursor for every row. Preserves supplied order without itself
# validating list provenance; hierarchy adapters perform their own live filtering.
def scope_finished(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,owned:Bool,result:Executed<W.World<S,Store,R,E>,Error<U>,Out>) -> Executed<W.World<S,Store,R,E>,Error<U>,Out>:
  match result:
    case Executed{world,outcome,values}:Executed{W.finish_run(~S,~Store,~R,~E,owned,world),outcome,values}
def reserved_scoped(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,cursor: Maybe<&2,Tick.Tick>,handles:List<&2,W.Handle<S>>,admitted:W.World<S,Store,R,E> & Bool) -> Executed<W.World<S,Store,R,E>,Error<U>,Out>:
  (world,owned)=admitted
  scope_finished(~S,~Store,~R,~E,~U,~Out,owned,finished(~S,~Store,~R,~E,~U,~Out,run_handles(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,handles,args,cursor,T.begin(~W.World<S,Store,R,E>,~E,world))))
def reserved(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,cursor: Maybe<&2,Tick.Tick>,observed: W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> Executed<W.World<S,Store,R,E>,Error<U>,Out>:
  (world,handles)=observed
  reserved_scoped(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,cursor,handles,W.ensure_run(~S,~Store,~R,~E,world))
# Snapshot live handles in allocator-visible order; deferred commands stay invisible.
# Snapshot allocator-visible live handles, then select and execute rows in that
# order within ONE enclosing transaction, with no prior cursor. Later reads observe
# earlier immediate writes; stop after the first selected-row failure, rollback
# recorded writes and suppress all outputs/staged publications/commands on failure.
# Success returns ordered Data outputs and enqueues commands without applying a
# barrier. User bodies receive only Ops(H), not raw World storage. Arbitrary trusted
# selectors/projectors or external effects are outside universal rollback claims.
# See examples/query-composition/declarations.bend and gameplay.bend.
def each(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,world: W.World<S,Store,R,E>) -> Executed<W.World<S,Store,R,E>,Error<U>,Out>:
  reserved(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,None{},W.handles(~S,~Store,~R,~E,world))

# Explicit schema-typed target and owned payload for a deferred insert grant.
# Owned explicit-target request for a deferred component insert. The detached
# handle plus actual Type C are consumed; the request is not itself admission.
type Insert<-S: Data,-C: Type> is Type:
  Insert{target: W.Handle<S>,value: C}

def insert_apply(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,+target: W.Handle<S>,value: C,world: W.World<S,Store,R,E>) -> W.World<S,Store,R,E>:
  Cmp.restore_done(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,Cmp.replace(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,target,Some{value}))
def insert_checked(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,current: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: Maybe<&2,Tick.Tick>,+target: W.Handle<S>,value: C,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,observed: W.World<S,Store,R,E> & Bool) -> Frame<S,Store,R,E>:
  match observed:
    case (world,False{}): Frame{T.Tx{world,undo,commands,events,trace},current,first_error(error,W.MissingEntity{}),cursor}
    case (world,True{}): Frame{T.stage(~W.World<S,Store,R,E>,~E,T.Tx{world,undo,commands,events,trace},(world => insert_apply(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,target,value,world))),current,error,cursor}
# Advanced deferred insertion for an explicitly supplied currently live target.
# Invalid/foreign/stale admission records MissingEntity and consumes the payload.
# Accepted work is staged, then rechecks live replacement at barrier application;
# application refusal does not return an incoming-owner receipt through this API.
def insert(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,frame: Frame<S,Store,R,E>,request: Insert<S,C>) -> Frame<S,Store,R,E>:
  match frame request:
    case Frame{T.Tx{world,undo,commands,events,trace},current,error,cursor} Insert{+target,value}: insert_checked(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,current,error,cursor,target,value,undo,commands,events,trace,W.valid(~S,~Store,~R,~E,world,target))
# Build a family-specific deferred insert grant. This does not grant arbitrary
# family access or promise insertion into a merely Pending spawn handle.
def command_insert(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>) -> Cap.Send<Frame<S,Store,R,E>,Insert<S,C>>:
  Cap.Send{insert(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family)}

# As each, with an explicit invocation cursor used by lifecycle predicates.
# This does not automatically advance a registered reader, and does not itself
# filter rows unless Plan.select contains lifecycle_match or another predicate.
def each_since(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,world: W.World<S,Store,R,E>,cursor: Maybe<&2,Tick.Tick>) -> Executed<W.World<S,Store,R,E>,Error<U>,Out>:
  reserved(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,cursor,W.handles(~S,~Store,~R,~E,world))

# Since cursor is runtime reader state; it lives in the affine row frame.
# Added/Changed select component lifecycle stamps relative to Frame.cursor.
# They grant no additional access and are not automatic reader advancement.
type LifecycleSelection is Data:
  Added{}
  Changed{}
def lifecycle_selected(mode: LifecycleSelection,stamp: L.Stamp,cursor: Maybe<&2,Tick.Tick>,this:Tick.Tick) -> Bool:
  match mode:
    case Added{}: L.added(stamp,cursor,this)
    case Changed{}: L.changed(stamp,cursor,this)
def lifecycle_clocked(~S: Data,~Store: Type,~R: Type,~E: Data,~mode: LifecycleSelection,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,+cursor: Maybe<&2,Tick.Tick>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,stamp:L.Stamp,observed: W.World<S,Store,R,E> & Tick.Tick) -> Frame<S,Store,R,E> & Bool:
  (world,this)=observed
  (Frame{T.Tx{world,undo,commands,events,trace},handle,error,cursor},lifecycle_selected(mode,stamp,cursor,this))
def lifecycle_join(~S: Data,~Store: Type,~R: Type,~E: Data,~mode: LifecycleSelection,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,+cursor: Maybe<&2,Tick.Tick>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,observed: W.World<S,Store,R,E> & L.Stamp) -> Frame<S,Store,R,E> & Bool:
  (world,stamp)=observed
  lifecycle_clocked(~S,~Store,~R,~E,~mode,handle,error,cursor,undo,commands,events,trace,stamp,W.execution_clock(~S,~Store,~R,~E,world))
# Compare this family slot stamp against the supplied invocation cursor and
# return Frame with Bool. Does not project the payload or create a gameplay grant;
# combine with membership predicates when actual presence is required.
def lifecycle_match(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,~mode: LifecycleSelection,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Bool:
  match frame:
    case Frame{T.Tx{world,undo,commands,events,trace},+handle,error,cursor}: lifecycle_join(~S,~Store,~R,~E,~mode,handle,error,cursor,undo,commands,events,trace,Cmp.lifecycle(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle))
def clock_join(~S: Data,~Store: Type,~R: Type,~E: Data,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: Maybe<&2,Tick.Tick>,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<Deferred.Command<W.World<S,Store,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,observed: W.World<S,Store,R,E> & Tick.Tick) -> Frame<S,Store,R,E> & Tick.Tick:
  (world,clock) = observed
  (Frame{T.Tx{world,undo,commands,events,trace},handle,error,cursor},clock)
# Advanced detached read of the current transaction World tick; does not advance
# it or change Frame.cursor.
def clock_get(~S: Data,~Store: Type,~R: Type,~E: Data,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Tick.Tick:
  match frame:
    case Frame{T.Tx{world,undo,commands,events,trace},handle,error,cursor}: clock_join(~S,~Store,~R,~E,handle,error,cursor,undo,commands,events,trace,W.clock(~S,~Store,~R,~E,world))
# Build a current-World tick read grant, not a clock-advance capability.
def clock_read(~S: Data,~Store: Type,~R: Type,~E: Data) -> Cap.ValueRead<Frame<S,Store,R,E>,Tick.Tick>:
  Cap.ValueRead{clock_get(~S,~Store,~R,~E)}

# Trace-aware advanced setter with the same consumption/error behavior as set.
# When tracing is enabled, trusted projection/rendering annotates before/after
# Data views; disabled tracing skips that presentation work.
def set_displayed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,~display:V -> String,frame: Frame<S,Store,R,E>,replacement: C) -> Frame<S,Store,R,E>:
  match frame:
    case Frame{tx,+handle,error,cursor}: written(~S,~Store,~R,~E,~C,handle,error,cursor,CmpLegacy.tx_set_displayed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~display,family,tx,handle,replacement))
# Build component grants whose setter uses the supplied detached display function
# for enabled tracing. This is presentation, not additional mutation authority.
def write_family_displayed(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,~display:V -> String) -> Cap.Write<Frame<S,Store,R,E>,C,V>:
  Cap.Write{get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family),set_displayed(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,~display)}

def finish_returned_observed(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,values:List<&2,Out>,result:T.Returned<W.World<S,Store,R,E>,Error<U>> & TraceFacts.State) -> Executed<W.World<S,Store,R,E>,Error<U>,Out> & TraceFacts.State:
  match result:
    case (returned,trace):(finish_returned(~S,~Store,~R,~E,~U,~Out,values,returned),trace)

def finished_observed(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,observed: T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>)) -> Executed<W.World<S,Store,R,E>,Error<U>,Out> & TraceFacts.State:
  match observed:
    case (tx,(result,values)): finish_returned_observed(~S,~Store,~R,~E,~U,~Out,values,T.finish_observed(~W.World<S,Store,R,E>,~E,~Error<U>,~Cmd.enqueue(~S,~Store,~R,~E),~Cmd.publish(~S,~Store,~R,~E),tx,result))
# Trace-aware advanced supplied-list execution adapter. Retains the same one-Tx
# finish and output-clearing behavior as reserved, returning actual trace state
# separately; operation facts do not assert that failed writes committed.
def scope_observed(~S:Data,~Store:Type,~R:Type,~E:Data,~U:Data,~Out:Data,owned:Bool,result:Executed<W.World<S,Store,R,E>,Error<U>,Out> & TraceFacts.State) -> Executed<W.World<S,Store,R,E>,Error<U>,Out> & TraceFacts.State:
  (executed,trace)=result
  (scope_finished(~S,~Store,~R,~E,~U,~Out,owned,executed),trace)
def reserved_observed_scoped(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),trace:TraceFacts.State,args: A,cursor: Maybe<&2,Tick.Tick>,handles:List<&2,W.Handle<S>>,admitted:W.World<S,Store,R,E> & Bool) -> Executed<W.World<S,Store,R,E>,Error<U>,Out> & TraceFacts.State:
  (world,owned)=admitted
  scope_observed(~S,~Store,~R,~E,~U,~Out,owned,finished_observed(~S,~Store,~R,~E,~U,~Out,run_handles(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,handles,args,cursor,T.begin_with_trace(~W.World<S,Store,R,E>,~E,world,trace))))
def reserved_observed(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),trace:TraceFacts.State,args: A,cursor: Maybe<&2,Tick.Tick>,observed: W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> Executed<W.World<S,Store,R,E>,Error<U>,Out> & TraceFacts.State:
  (world,handles)=observed
  reserved_observed_scoped(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,trace,args,cursor,handles,W.ensure_run(~S,~Store,~R,~E,world))
# Snapshot live handles in allocator-visible order; deferred commands stay invisible.
# As each_since with supplied operation trace state returned alongside Executed.
# Tracing does not change capability authority or apply pending commands. Facts
# may include attempted/refused operations; inspect execution outcome separately.
def each_since_observed(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),trace:TraceFacts.State,args: A,world: W.World<S,Store,R,E>,cursor: Maybe<&2,Tick.Tick>) -> Executed<W.World<S,Store,R,E>,Error<U>,Out> & TraceFacts.State:
  reserved_observed(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,trace,args,cursor,W.handles(~S,~Store,~R,~E,world))
