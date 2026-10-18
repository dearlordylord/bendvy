import Base
import world.bend as W
import column.bend as Col
import component.bend as Cmp
import transaction.bend as T
import resource.bend as Res
import commands.bend as Cmd

# Concrete Frame is trusted provisioning. Rank2 gameplay receives arbitrary H.
# Operations are erased closed templates: repeated gets/sets construct fresh
# affine operation applications, never duplicate a captured Type closure.
type Frame<-S: Data,-Store: Type,-R: Type,-E: Data> is Type:
  Frame{tx: T.Tx<W.World<S,Store,R,E>,E>,handle: W.Handle<S>,mainName: String,auxName: String,error: Maybe<&2,W.WorldError>}
type Error<U: Data> is Data:
  UserError{error: U}
  AccessError{error: W.WorldError}

def read_join(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,+handle: W.Handle<S>,+mainName: String,+auxName: String,+error: Maybe<&2,W.WorldError>,observed: T.Tx<W.World<S,Store,R,E>,E> & Cmp.Access<V>) -> Frame<S,Store,R,E> & Cmp.Access<V>:
  (tx,value) = observed
  (Frame{tx,handle,mainName,auxName,error},value)

def get(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Cmp.Access<V>:
  match frame:
    case Frame{tx,+handle,+mainName,+auxName,+error}:
      read_join(~S,~Store,~R,~E,~V,handle,mainName,auxName,error,Cmp.tx_get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,Cmp.Family{mainName},tx,handle))

def aux_get(~S: Data,~Store: Type,~R: Type,~E: Data,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & Cmp.Access<AuxV>:
  match frame:
    case Frame{tx,+handle,+mainName,+auxName,+error}:
      read_join(~S,~Store,~R,~E,~AuxV,handle,mainName,auxName,error,Cmp.tx_get(~S,~Store,~R,~E,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,Cmp.Family{auxName},tx,handle))

def first_error(previous: Maybe<&2,W.WorldError>,error: W.WorldError) -> Maybe<&2,W.WorldError>:
  match previous:
    case None{}: Some{error}
    case Some{previous}: Some{previous}

def written(~S: Data,~Store: Type,~R: Type,~E: Data,~C: Type,+handle: W.Handle<S>,+mainName: String,+auxName: String,+error: Maybe<&2,W.WorldError>,result: Cmp.SetResult<T.Tx<W.World<S,Store,R,E>,E>,C>) -> Frame<S,Store,R,E>:
  match result:
    case Cmp.Written{tx}: Frame{tx,handle,mainName,auxName,error}
    case Cmp.WriteRejected{tx,_,reason}: Frame{tx,handle,mainName,auxName,first_error(error,reason)}
    case Cmp.WriteFailure{tx,reason}: Frame{tx,handle,mainName,auxName,first_error(error,reason)}

def set(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,frame: Frame<S,Store,R,E>,replacement: C) -> Frame<S,Store,R,E>:
  match frame:
    case Frame{tx,+handle,+mainName,+auxName,+error}:
      written(~S,~Store,~R,~E,~C,handle,mainName,auxName,error,Cmp.tx_set(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,Cmp.Family{mainName},tx,handle,replacement))

def resource_join(~S: Data,~Store: Type,~R: Type,~E: Data,~RV: Data,+handle: W.Handle<S>,+mainName: String,+auxName: String,+error: Maybe<&2,W.WorldError>,observed: T.Tx<W.World<S,Store,R,E>,E> & RV) -> Frame<S,Store,R,E> & RV:
  (tx,value) = observed
  (Frame{tx,handle,mainName,auxName,error},value)

def resource_get(~S: Data,~Store: Type,~R: Type,~E: Data,~RV: Data,~resource_project: R -> R & RV,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E> & RV:
  match frame:
    case Frame{tx,+handle,+mainName,+auxName,+error}:
      resource_join(~S,~Store,~R,~E,~RV,handle,mainName,auxName,error,Res.tx_get(~S,~Store,~R,~E,~RV,~resource_project,tx))

def resource_set(~S: Data,~Store: Type,~R: Type,~E: Data,frame: Frame<S,Store,R,E>,replacement: R) -> Frame<S,Store,R,E>:
  match frame:
    case Frame{tx,+handle,+mainName,+auxName,+error}:
      Frame{Res.tx_replace(~S,~Store,~R,~E,tx,replacement),handle,mainName,auxName,error}

def emit(~S: Data,~Store: Type,~R: Type,~E: Data,frame: Frame<S,Store,R,E>,event: E) -> Frame<S,Store,R,E>:
  match frame:
    case Frame{tx,+handle,+mainName,+auxName,+error}:
      Frame{T.emit(~W.World<S,Store,R,E>,~E,tx,event),handle,mainName,auxName,error}

def despawn_join(~S: Data,~Store: Type,~R: Type,~E: Data,+handle: W.Handle<S>,+mainName: String,+auxName: String,+error: Maybe<&2,W.WorldError>,observed: T.Tx<W.World<S,Store,R,E>,E> & W.Status) -> Frame<S,Store,R,E>:
  match observed:
    case (tx,W.Accepted{}): Frame{tx,handle,mainName,auxName,error}
    case (tx,W.Rejected{reason}): Frame{tx,handle,mainName,auxName,first_error(error,reason)}

def despawn(~S: Data,~Store: Type,~R: Type,~E: Data,~clear: Store -> W.Handle<S> -> Store,frame: Frame<S,Store,R,E>) -> Frame<S,Store,R,E>:
  match frame:
    case Frame{tx,+handle,+mainName,+auxName,+error}:
      despawn_join(~S,~Store,~R,~E,handle,mainName,auxName,error,Cmd.tx_despawn_with(~S,~Store,~R,~E,~clear,tx,handle))

def spawn_join(~S: Data,~Store: Type,~R: Type,~E: Data,+handle: W.Handle<S>,+mainName: String,+auxName: String,+error: Maybe<&2,W.WorldError>,observed: T.Tx<W.World<S,Store,R,E>,E> & W.Reservation<S>) -> Frame<S,Store,R,E> & W.Reservation<S>:
  match observed:
    case (tx,W.Reserved{+reserved}): (Frame{tx,handle,mainName,auxName,error},W.Reserved{reserved})
    case (tx,W.ReservationRejected{+reason}): (Frame{tx,handle,mainName,auxName,first_error(error,reason)},W.ReservationRejected{reason})

def spawn(~S: Data,~Store: Type,~R: Type,~E: Data,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,frame: Frame<S,Store,R,E>,payload: Payload) -> Frame<S,Store,R,E> & W.Reservation<S>:
  match frame:
    case Frame{tx,+handle,+mainName,+auxName,+error}:
      spawn_join(~S,~Store,~R,~E,handle,mainName,auxName,error,Cmd.tx_spawn(~S,~Store,~R,~E,~Payload,~populate,tx,payload))

def outcome(~U: Data,internal: Maybe<&2,W.WorldError>,user: T.Outcome<U>) -> T.Outcome<Error<U>>:
  match internal user:
    case Some{error} _: T.Failure{AccessError{error}}
    case None{} T.Failure{error}: T.Failure{UserError{error}}
    case None{} T.Success{}: T.Success{}

def returned(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,result: Frame<S,Store,R,E> & T.Outcome<U>) -> T.Tx<W.World<S,Store,R,E>,E> & T.Outcome<Error<U>>:
  match result:
    case (Frame{tx,_,_,_,internal},user): (tx,outcome(~U,internal,user))

def run(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,~RV: Data,~resource_project: R -> R & RV,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,~clear: Store -> W.Handle<S> -> Store,~A: Data,~U: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-set: (H -> C -> H) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-resource_get: (H -> H & RV) -> @-resource_set: (H -> R -> H) -> @-emit: (H -> E -> H) -> @-despawn: (H -> H) -> @-spawn: (H -> Payload -> H & W.Reservation<S>) -> A -> W.Handle<S> -> H -> H & T.Outcome<U>,+mainName: String,+auxName: String,tx: T.Tx<W.World<S,Store,R,E>,E>,+handle: W.Handle<S>,args: A) -> T.Tx<W.World<S,Store,R,E>,E> & T.Outcome<Error<U>>:
  returned(~S,~Store,~R,~E,~U,body(Frame<S,Store,R,E>,get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project),set(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project),aux_get(~S,~Store,~R,~E,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project),resource_get(~S,~Store,~R,~E,~RV,~resource_project),resource_set(~S,~Store,~R,~E),emit(~S,~Store,~R,~E),despawn(~S,~Store,~R,~E,~clear),spawn(~S,~Store,~R,~E,~Payload,~populate),args,handle,Frame{tx,handle,mainName,auxName,None{}}))

def read_returned(~S: Data,~Store: Type,~R: Type,~E: Data,~Out: Data,result: Frame<S,Store,R,E> & Out) -> T.Tx<W.World<S,Store,R,E>,E> & Out:
  match result:
    case (Frame{tx,_,_,_,_},value): (tx,value)

def read(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,~RV: Data,~resource_project: R -> R & RV,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,~clear: Store -> W.Handle<S> -> Store,~A: Data,~Out: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-resource_get: (H -> H & RV) -> A -> W.Handle<S> -> H -> H & Out,+mainName: String,+auxName: String,tx: T.Tx<W.World<S,Store,R,E>,E>,+handle: W.Handle<S>,args: A) -> T.Tx<W.World<S,Store,R,E>,E> & Out:
  read_returned(~S,~Store,~R,~E,~Out,body(Frame<S,Store,R,E>,get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project),aux_get(~S,~Store,~R,~E,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project),resource_get(~S,~Store,~R,~E,~RV,~resource_project),args,handle,Frame{tx,handle,mainName,auxName,None{}}))

# Restricted grant bundle: no resource replacement, event publication, spawn or
# despawn operation is handed to the universally quantified user callback.
def component_body(~S: Data,~C: Type,~V: Data,~AuxV: Data,~RV: Data,~R: Type,~E: Data,~Payload: Type,~A: Data,~U: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-set: (H -> C -> H) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-resource_get: (H -> H & RV) -> A -> W.Handle<S> -> H -> H & T.Outcome<U>,~H: Type,~get: H -> H & Cmp.Access<V>,~set: H -> C -> H,~aux: H -> H & Cmp.Access<AuxV>,~resource_get: H -> H & RV,~resource_set: H -> R -> H,~emit: H -> E -> H,~despawn: H -> H,~spawn: H -> Payload -> H & W.Reservation<S>,args: A,handle: W.Handle<S>,ctx: H) -> H & T.Outcome<U>:
  body(H,get,set,aux,resource_get,args,handle,ctx)

# Main RW + aux Read + event Write + current-entity Despawn only.
def event_body(~S: Data,~C: Type,~V: Data,~AuxV: Data,~RV: Data,~R: Type,~E: Data,~Payload: Type,~A: Data,~U: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-set: (H -> C -> H) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-emit: (H -> E -> H) -> @-despawn: (H -> H) -> A -> W.Handle<S> -> H -> H & T.Outcome<U>,~H: Type,~get: H -> H & Cmp.Access<V>,~set: H -> C -> H,~aux: H -> H & Cmp.Access<AuxV>,~resource_get: H -> H & RV,~resource_set: H -> R -> H,~emit: H -> E -> H,~despawn: H -> H,~spawn: H -> Payload -> H & W.Reservation<S>,args: A,handle: W.Handle<S>,ctx: H) -> H & T.Outcome<U>:
  body(H,get,set,aux,emit,despawn,args,handle,ctx)
