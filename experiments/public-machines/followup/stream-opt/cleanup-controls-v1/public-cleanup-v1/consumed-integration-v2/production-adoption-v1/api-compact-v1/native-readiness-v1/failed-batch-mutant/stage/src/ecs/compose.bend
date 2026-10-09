import Base
import ../../experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/world.bend as W
import column.bend as Col
import component.bend as Cmp
import ../../experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/transaction.bend as T
import resource.bend as Res
import commands.bend as Cmd
import capabilities.bend as Cap
import lifecycle.bend as L

type Frame<-S: Data,-Store: Type,-R: Type,-E: Data> is Type:
  Frame{tx: T.Tx<W.World<S,Store,R,E>,E>,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: U32}
type Error<U: Data> is Data:
  UserError{error: U}
  AccessError{error: W.WorldError}
# Trusted closed declaration: capability and membership choices travel together.
type Plan<-S: Data,-Store: Type,-R: Type,-E: Data,-Ops: Type -> Type> is Type:
  Plan{caps: Ops(Frame<S,Store,R,E>),select: Frame<S,Store,R,E> -> Frame<S,Store,R,E> & Bool}
type Executed<-World: Type,Error: Data,Out: Data> is Type:
  Executed{world: World,outcome: T.Outcome<Error>,values: List<&2,Out>}
type Selection is Data:
  Required{}
  Present{}
  Absent{}
  Optional{}

def first_error(previous: Maybe<&2,W.WorldError>,error: W.WorldError) -> Maybe<&2,W.WorldError>:
  match previous:
    case None{}: Some{error}
    case Some{previous}: Some{previous}

def read_join(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,+handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: U32,observed: T.Tx<W.World<S,Store,R,E>,E> & Cmp.Access<V>) -> Frame<S,Store,R,E> & Cmp.Access<V>:
  (tx,value) = observed
  (Frame{tx,handle,error,cursor},value)
def get(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Cmp.Access<V>:
  match frame:
    case Frame{tx,+handle,error,cursor}: read_join(~S,~Store,~R,~E,~V,handle,error,cursor,Cmp.tx_get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,tx,handle))
def written(~S: Data,~Store: Type,~R: Type,~E: Data,~C: Type,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: U32,result: Cmp.SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>) -> Frame<S,Store,R,E>:
  match result:
    case Cmp.Written{tx}: Frame{tx,handle,error,cursor}
    case Cmp.WriteRejected{tx,_,reason}: Frame{tx,handle,first_error(error,reason),cursor}
    case Cmp.WriteFailure{tx,reason}: Frame{tx,handle,first_error(error,reason),cursor}
def set(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,frame: Frame<S,Store,R,E>,replacement: C) -> Frame<S,Store,R,E>:
  match frame:
    case Frame{tx,+handle,error,cursor}: written(~S,~Store,~R,~E,~C,handle,error,cursor,Cmp.tx_set(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,tx,handle,replacement))
def read_family(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>) -> Cap.Read<Frame<S,Store,R,E>,V>:
  Cap.Read{get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family)}
def write_family(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>) -> Cap.Write<Frame<S,Store,R,E>,C,V>:
  Cap.Write{get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family),set(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family)}

def value_join(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: U32,observed: T.Tx<W.World<S,Store,R,E>,E> & V) -> Frame<S,Store,R,E> & V:
  (tx,value) = observed
  (Frame{tx,handle,error,cursor},value)
def resource_get(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,~project: R -> R & V,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & V:
  match frame:
    case Frame{tx,handle,error,cursor}: value_join(~S,~Store,~R,~E,~V,handle,error,cursor,Res.tx_get(~S,~Store,~R,~E,~V,~project,tx))
def resource_set(~S: Data,~Store: Type,~R: Type,~E: Data,frame: Frame<S,Store,R,E>,replacement: R) -> Frame<S,Store,R,E>:
  match frame:
    case Frame{tx,handle,error,cursor}: Frame{Res.tx_replace(~S,~Store,~R,~E,tx,replacement),handle,error,cursor}
def resource_read(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,~project: R -> R & V) -> Cap.ValueRead<Frame<S,Store,R,E>,V>:
  Cap.ValueRead{resource_get(~S,~Store,~R,~E,~V,~project)}
def resource_write(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,~project: R -> R & V) -> Cap.ValueWrite<Frame<S,Store,R,E>,R,V>:
  Cap.ValueWrite{resource_get(~S,~Store,~R,~E,~V,~project),resource_set(~S,~Store,~R,~E)}
def handle_get(~S: Data,~Store: Type,~R: Type,~E: Data,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & W.Handle<S>:
  match frame:
    case Frame{tx,+handle,error,cursor}: (Frame{tx,handle,error,cursor},handle)
def handle_read(~S: Data,~Store: Type,~R: Type,~E: Data) -> Cap.ValueRead<Frame<S,Store,R,E>,W.Handle<S>>:
  Cap.ValueRead{handle_get(~S,~Store,~R,~E)}
def emit(~S: Data,~Store: Type,~R: Type,~E: Data,frame: Frame<S,Store,R,E>,event: E) -> Frame<S,Store,R,E>:
  match frame:
    case Frame{tx,handle,error,cursor}: Frame{T.emit(~W.World<S,Store,R,E>,~E,tx,event),handle,error,cursor}
def event_write(~S: Data,~Store: Type,~R: Type,~E: Data) -> Cap.Send<Frame<S,Store,R,E>,E>:
  Cap.Send{emit(~S,~Store,~R,~E)}
def despawn_join(~S: Data,~Store: Type,~R: Type,~E: Data,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: U32,observed: T.Tx<W.World<S,Store,R,E>,E> & W.Status) -> Frame<S,Store,R,E>:
  match observed:
    case (tx,W.Accepted{}): Frame{tx,handle,error,cursor}
    case (tx,W.Rejected{reason}): Frame{tx,handle,first_error(error,reason),cursor}
def despawn(~S: Data,~Store: Type,~R: Type,~E: Data,~clear: Store -> W.Handle<S> -> Store,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E>:
  match frame:
    case Frame{tx,+handle,error,cursor}: despawn_join(~S,~Store,~R,~E,handle,error,cursor,Cmd.tx_despawn_with(~S,~Store,~R,~E,~clear,tx,handle))
def command_despawn(~S: Data,~Store: Type,~R: Type,~E: Data,~clear: Store -> W.Handle<S> -> Store) -> Cap.Action<Frame<S,Store,R,E>>:
  Cap.Action{despawn(~S,~Store,~R,~E,~clear)}
def spawn_join(~S: Data,~Store: Type,~R: Type,~E: Data,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: U32,observed: T.Tx<W.World<S,Store,R,E>,E> & W.Reservation<S>) -> Frame<S,Store,R,E> & W.Reservation<S>:
  match observed:
    case (tx,W.Reserved{+reserved}): (Frame{tx,handle,error,cursor},W.Reserved{reserved})
    case (tx,W.ReservationRejected{+reason}): (Frame{tx,handle,first_error(error,reason),cursor},W.ReservationRejected{reason})
def spawn(~S: Data,~Store: Type,~R: Type,~E: Data,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,frame: Frame<S,Store,R,E>,payload: Payload) -> Frame<S,Store,R,E> & W.Reservation<S>:
  match frame:
    case Frame{tx,handle,error,cursor}: spawn_join(~S,~Store,~R,~E,handle,error,cursor,Cmd.tx_spawn(~S,~Store,~R,~E,~Payload,~populate,tx,payload))
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
def family_match(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,~mode: Selection,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Bool:
  selected_join(~S,~Store,~R,~E,~V,mode,get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,frame))
def all(~S: Data,~Store: Type,~R: Type,~E: Data,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Bool:
  (frame,True{})
def and_join(~S: Data,~Store: Type,~R: Type,~E: Data,~right: Frame<S,Store,R,E> -> Frame<S,Store,R,E> & Bool,observed: Frame<S,Store,R,E> & Bool) -> Frame<S,Store,R,E> & Bool:
  match observed:
    case (frame,False{}): (frame,False{})
    case (frame,True{}): right(frame)
def both(~S: Data,~Store: Type,~R: Type,~E: Data,~left: Frame<S,Store,R,E> -> Frame<S,Store,R,E> & Bool,~right: Frame<S,Store,R,E> -> Frame<S,Store,R,E> & Bool,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Bool:
  and_join(~S,~Store,~R,~E,~right,left(frame))

def plan_caps(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,plan: Plan<S,Store,R,E,Ops>) -> Ops(Frame<S,Store,R,E>):
  match plan:
    case Plan{caps,_}: caps
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
def run_handles(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),handles: List<&2,W.Handle<S>>,+args: A,+cursor: U32,tx: T.Tx<W.World<S,Store,R,E>,E>) -> T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>):
  match handles:
    case []: (tx,(T.Success{},[]))
    case handle <> rest: selected(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,(tx => run_handles(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,rest,args,cursor,tx)),plan_select(~S,~Store,~R,~E,~Ops,plan)(Frame{tx,handle,None{},cursor}))
def finish_returned(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,values: List<&2,Out>,returned: T.Returned<W.World<S,Store,R,E>,Error<U>>) -> Executed<W.World<S,Store,R,E>,Error<U>,Out>:
  match returned:
    case T.Returned{world,T.Success{}}: Executed{world,T.Success{},values}
    case T.Returned{world,T.Failure{error}}: Executed{world,T.Failure{error},[]}
def finished(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,~Out: Data,observed: T.Tx<W.World<S,Store,R,E>,E> & (T.Outcome<Error<U>> & List<&2,Out>)) -> Executed<W.World<S,Store,R,E>,Error<U>,Out>:
  match observed:
    case (tx,(result,values)): finish_returned(~S,~Store,~R,~E,~U,~Out,values,Cmd.tx_finish(~S,~Store,~R,~E,~Error<U>,tx,result))
def reserved(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,cursor: U32,observed: W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> Executed<W.World<S,Store,R,E>,Error<U>,Out>:
  (world,handles) = observed
  finished(~S,~Store,~R,~E,~U,~Out,run_handles(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,handles,args,cursor,T.begin(~W.World<S,Store,R,E>,~E,world)))
# Snapshot live handles in ascending order; deferred commands stay invisible.
def each(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,world: W.World<S,Store,R,E>) -> Executed<W.World<S,Store,R,E>,Error<U>,Out>:
  reserved(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,0,W.handles(~S,~Store,~R,~E,world))

# Explicit schema-typed target and owned payload for a deferred insert grant.
type Insert<-S: Data,-C: Type> is Type:
  Insert{target: W.Handle<S>,value: C}

def insert_apply(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,+target: W.Handle<S>,value: C,world: W.World<S,Store,R,E>) -> W.World<S,Store,R,E>:
  Cmp.restore_done(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,Cmp.replace(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,target,Some{value}))
def insert_checked(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,current: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: U32,+target: W.Handle<S>,value: C,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events: List<&2,E>,observed: W.World<S,Store,R,E> & Bool) -> Frame<S,Store,R,E>:
  match observed:
    case (world,False{}): Frame{T.Tx{world,undo,commands,events},current,first_error(error,W.MissingEntity{}),cursor}
    case (world,True{}): Frame{T.stage(~W.World<S,Store,R,E>,~E,T.Tx{world,undo,commands,events},(world => insert_apply(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,target,value,world))),current,error,cursor}
def insert(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,frame: Frame<S,Store,R,E>,request: Insert<S,C>) -> Frame<S,Store,R,E>:
  match frame request:
    case Frame{T.Tx{world,undo,commands,events},current,error,cursor} Insert{+target,value}: insert_checked(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family,current,error,cursor,target,value,undo,commands,events,W.valid(~S,~Store,~R,~E,world,target))
def command_insert(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>) -> Cap.Send<Frame<S,Store,R,E>,Insert<S,C>>:
  Cap.Send{insert(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family)}

def each_since(~S: Data,~Store: Type,~R: Type,~E: Data,~Ops: Type -> Type,~A: Data,~U: Data,~Out: Data,~plan: Plan<S,Store,R,E,Ops>,~body: @-H: Type -> @-caps: Ops(H) -> A -> H -> H & (T.Outcome<U> & Out),args: A,world: W.World<S,Store,R,E>,cursor: U32) -> Executed<W.World<S,Store,R,E>,Error<U>,Out>:
  reserved(~S,~Store,~R,~E,~Ops,~A,~U,~Out,~plan,~body,args,cursor,W.handles(~S,~Store,~R,~E,world))

# Since cursor is runtime reader state; it lives in the affine row frame.
type LifecycleSelection is Data:
  Added{}
  Changed{}
def lifecycle_selected(mode: LifecycleSelection,stamp: L.Stamp,cursor: U32) -> Bool:
  match mode:
    case Added{}: L.added(stamp,cursor)
    case Changed{}: L.changed(stamp,cursor)
def lifecycle_join(~S: Data,~Store: Type,~R: Type,~E: Data,~mode: LifecycleSelection,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,+cursor: U32,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events: List<&2,E>,observed: W.World<S,Store,R,E> & L.Stamp) -> Frame<S,Store,R,E> & Bool:
  (world,stamp) = observed
  (Frame{T.Tx{world,undo,commands,events},handle,error,cursor},lifecycle_selected(mode,stamp,cursor))
def lifecycle_match(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,~mode: LifecycleSelection,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Bool:
  match frame:
    case Frame{T.Tx{world,undo,commands,events},+handle,error,cursor}: lifecycle_join(~S,~Store,~R,~E,~mode,handle,error,cursor,undo,commands,events,Cmp.lifecycle(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle))
def clock_join(~S: Data,~Store: Type,~R: Type,~E: Data,handle: W.Handle<S>,error: Maybe<&2,W.WorldError>,cursor: U32,undo: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands: List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events: List<&2,E>,observed: W.World<S,Store,R,E> & U32) -> Frame<S,Store,R,E> & U32:
  (world,clock) = observed
  (Frame{T.Tx{world,undo,commands,events},handle,error,cursor},clock)
def clock_get(~S: Data,~Store: Type,~R: Type,~E: Data,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & U32:
  match frame:
    case Frame{T.Tx{world,undo,commands,events},handle,error,cursor}: clock_join(~S,~Store,~R,~E,handle,error,cursor,undo,commands,events,W.clock(~S,~Store,~R,~E,world))
def clock_read(~S: Data,~Store: Type,~R: Type,~E: Data) -> Cap.ValueRead<Frame<S,Store,R,E>,U32>:
  Cap.ValueRead{clock_get(~S,~Store,~R,~E)}
