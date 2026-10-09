import Base
import ../../experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/world.bend as W
import column.bend as Col
import component.bend as Cmp
import ../../experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/transaction.bend as T
import provider.bend as Pv
import commands.bend as Cmd

# Main membership is required; these modes apply to the independent aux family.
# Bounded explicit two-family composition is not a general query planner.
type Selection is Data:
  Required{}
  Present{}
  Absent{}
  Optional{}

def main_found(~V: Data,value: Cmp.Access<V>) -> Bool:
  match value:
    case Cmp.Found{_}: True{}
    case _: False{}

def selection_aux(~V: Data,mode: Selection,value: Cmp.Access<V>) -> Bool:
  match mode value:
    case Required{} Cmp.Found{_}: True{}
    case Present{} Cmp.Found{_}: True{}
    case Absent{} Cmp.ComponentAbsent{}: True{}
    case Optional{} Cmp.Found{_}: True{}
    case Optional{} Cmp.ComponentAbsent{}: True{}
    case _ _: False{}

def selected_aux(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,mode: Selection,main: Bool,observed: T.Tx<W.World<S,Store,R,E>,E> & Cmp.Access<V>) -> T.Tx<W.World<S,Store,R,E>,E> & Bool:
  (tx,value) = observed
  (tx,main && selection_aux(~V,mode,value))

def selected_main(~S: Data,~Store: Type,~R: Type,~E: Data,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,mode: Selection,auxFamily: Cmp.Family<S,Store,AuxRest,AuxC,AuxV,AuxToken,aux_take,aux_put,aux_project>,+handle: W.Handle<S>,observed: T.Tx<W.World<S,Store,R,E>,E> & Bool) -> T.Tx<W.World<S,Store,R,E>,E> & Bool:
  match observed:
    case (tx,False{}): (tx,False{})
    case (tx,True{}): selected_aux(~S,~Store,~R,~E,~AuxV,mode,True{},Cmp.tx_get(~S,~Store,~R,~E,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,auxFamily,tx,handle))

def main_join(~S: Data,~Store: Type,~R: Type,~E: Data,~V: Data,observed: T.Tx<W.World<S,Store,R,E>,E> & Cmp.Access<V>) -> T.Tx<W.World<S,Store,R,E>,E> & Bool:
  (tx,value) = observed
  (tx,main_found(~V,value))

def selected(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,mainFamily: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,auxFamily: Cmp.Family<S,Store,AuxRest,AuxC,AuxV,AuxToken,aux_take,aux_put,aux_project>,mode: Selection,tx: T.Tx<W.World<S,Store,R,E>,E>,+handle: W.Handle<S>) -> T.Tx<W.World<S,Store,R,E>,E> & Bool:
  selected_main(~S,~Store,~R,~E,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,mode,auxFamily,handle,main_join(~S,~Store,~R,~E,~V,Cmp.tx_get(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,mainFamily,tx,handle)))

# Name helpers only carry diagnostic metadata, not capability authority.
def main_name(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,family: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>) -> String:
  match family:
    case Cmp.Family{name}: name
def aux_name(~S: Data,~Store: Type,~R: Type,~E: Data,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,family: Cmp.Family<S,Store,AuxRest,AuxC,AuxV,AuxToken,aux_take,aux_put,aux_project>) -> String:
  match family:
    case Cmp.Family{name}: name

def after_run(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,next: T.Tx<W.World<S,Store,R,E>,E> -> T.Tx<W.World<S,Store,R,E>,E> & T.Outcome<Pv.Error<U>>,observed: T.Tx<W.World<S,Store,R,E>,E> & T.Outcome<Pv.Error<U>>) -> T.Tx<W.World<S,Store,R,E>,E> & T.Outcome<Pv.Error<U>>:
  match observed:
    case (tx,T.Success{}): next(tx)
    case (tx,T.Failure{error}): (tx,T.Failure{error})

def run_selected(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,~RV: Data,~resource_project: R -> R & RV,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,~clear: Store -> W.Handle<S> -> Store,~A: Data,~U: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-set: (H -> C -> H) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-resource_get: (H -> H & RV) -> @-resource_set: (H -> R -> H) -> @-emit: (H -> E -> H) -> @-despawn: (H -> H) -> @-spawn: (H -> Payload -> H & W.Reservation<S>) -> A -> W.Handle<S> -> H -> H & T.Outcome<U>,+mainName: String,+auxName: String,+handle: W.Handle<S>,args: A,next: T.Tx<W.World<S,Store,R,E>,E> -> T.Tx<W.World<S,Store,R,E>,E> & T.Outcome<Pv.Error<U>>,observed: T.Tx<W.World<S,Store,R,E>,E> & Bool) -> T.Tx<W.World<S,Store,R,E>,E> & T.Outcome<Pv.Error<U>>:
  match observed:
    case (tx,False{}): next(tx)
    case (tx,True{}): after_run(~S,~Store,~R,~E,~U,next,Pv.run(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,~RV,~resource_project,~Payload,~populate,~clear,~A,~U,~body,mainName,auxName,tx,handle,args))

def run_handles(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,~RV: Data,~resource_project: R -> R & RV,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,~clear: Store -> W.Handle<S> -> Store,~A: Data,~U: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-set: (H -> C -> H) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-resource_get: (H -> H & RV) -> @-resource_set: (H -> R -> H) -> @-emit: (H -> E -> H) -> @-despawn: (H -> H) -> @-spawn: (H -> Payload -> H & W.Reservation<S>) -> A -> W.Handle<S> -> H -> H & T.Outcome<U>,handles: List<&2,W.Handle<S>>,+mainFamily: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,+auxFamily: Cmp.Family<S,Store,AuxRest,AuxC,AuxV,AuxToken,aux_take,aux_put,aux_project>,+mode: Selection,+args: A,tx: T.Tx<W.World<S,Store,R,E>,E>) -> T.Tx<W.World<S,Store,R,E>,E> & T.Outcome<Pv.Error<U>>:
  match handles:
    case []: (tx,T.Success{})
    case +handle <> rest:
      run_selected(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,~RV,~resource_project,~Payload,~populate,~clear,~A,~U,~body,main_name(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,mainFamily),aux_name(~S,~Store,~R,~E,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,auxFamily),handle,args,(tx => run_handles(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,~RV,~resource_project,~Payload,~populate,~clear,~A,~U,~body,rest,mainFamily,auxFamily,mode,args,tx)),selected(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,mainFamily,auxFamily,mode,tx,handle))

def finished(~S: Data,~Store: Type,~R: Type,~E: Data,~U: Data,observed: T.Tx<W.World<S,Store,R,E>,E> & T.Outcome<Pv.Error<U>>) -> T.Returned<W.World<S,Store,R,E>,Pv.Error<U>>:
  (tx,result) = observed
  Cmd.tx_finish(~S,~Store,~R,~E,~Pv.Error<U>,tx,result)

def each_reserved(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,~RV: Data,~resource_project: R -> R & RV,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,~clear: Store -> W.Handle<S> -> Store,~A: Data,~U: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-set: (H -> C -> H) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-resource_get: (H -> H & RV) -> @-resource_set: (H -> R -> H) -> @-emit: (H -> E -> H) -> @-despawn: (H -> H) -> @-spawn: (H -> Payload -> H & W.Reservation<S>) -> A -> W.Handle<S> -> H -> H & T.Outcome<U>,mainFamily: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,auxFamily: Cmp.Family<S,Store,AuxRest,AuxC,AuxV,AuxToken,aux_take,aux_put,aux_project>,mode: Selection,args: A,observed: W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> T.Returned<W.World<S,Store,R,E>,Pv.Error<U>>:
  (world,handles) = observed
  finished(~S,~Store,~R,~E,~U,run_handles(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,~RV,~resource_project,~Payload,~populate,~clear,~A,~U,~body,handles,mainFamily,auxFamily,mode,args,T.begin(~W.World<S,Store,R,E>,~E,world)))

def each_rw_read(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,~RV: Data,~resource_project: R -> R & RV,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,~clear: Store -> W.Handle<S> -> Store,~A: Data,~U: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-set: (H -> C -> H) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-resource_get: (H -> H & RV) -> @-resource_set: (H -> R -> H) -> @-emit: (H -> E -> H) -> @-despawn: (H -> H) -> @-spawn: (H -> Payload -> H & W.Reservation<S>) -> A -> W.Handle<S> -> H -> H & T.Outcome<U>,mainFamily: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,auxFamily: Cmp.Family<S,Store,AuxRest,AuxC,AuxV,AuxToken,aux_take,aux_put,aux_project>,mode: Selection,world: W.World<S,Store,R,E>,args: A) -> T.Returned<W.World<S,Store,R,E>,Pv.Error<U>>:
  each_reserved(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,~RV,~resource_project,~Payload,~populate,~clear,~A,~U,~body,mainFamily,auxFamily,mode,args,W.handles(~S,~Store,~R,~E,world))

# Read-only gameplay receives no component/resource setter, event writer or command.
def read_prepend(~S: Data,~Store: Type,~R: Type,~E: Data,~Out: Data,value: Out,observed: T.Tx<W.World<S,Store,R,E>,E> & List<&2,Out>) -> T.Tx<W.World<S,Store,R,E>,E> & List<&2,Out>:
  (tx,values) = observed
  (tx,value <> values)

def read_added(~S: Data,~Store: Type,~R: Type,~E: Data,~Out: Data,next: T.Tx<W.World<S,Store,R,E>,E> -> T.Tx<W.World<S,Store,R,E>,E> & List<&2,Out>,observed: T.Tx<W.World<S,Store,R,E>,E> & Out) -> T.Tx<W.World<S,Store,R,E>,E> & List<&2,Out>:
  (tx,value) = observed
  read_prepend(~S,~Store,~R,~E,~Out,value,next(tx))
def read_selected(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,~RV: Data,~resource_project: R -> R & RV,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,~clear: Store -> W.Handle<S> -> Store,~A: Data,~Out: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-resource_get: (H -> H & RV) -> A -> W.Handle<S> -> H -> H & Out,+mainName: String,+auxName: String,+handle: W.Handle<S>,args: A,next: T.Tx<W.World<S,Store,R,E>,E> -> T.Tx<W.World<S,Store,R,E>,E> & List<&2,Out>,observed: T.Tx<W.World<S,Store,R,E>,E> & Bool) -> T.Tx<W.World<S,Store,R,E>,E> & List<&2,Out>:
  match observed:
    case (tx,False{}): next(tx)
    case (tx,True{}): read_added(~S,~Store,~R,~E,~Out,next,Pv.read(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,~RV,~resource_project,~Payload,~populate,~clear,~A,~Out,~body,mainName,auxName,tx,handle,args))

def read_handles(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,~RV: Data,~resource_project: R -> R & RV,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,~clear: Store -> W.Handle<S> -> Store,~A: Data,~Out: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-resource_get: (H -> H & RV) -> A -> W.Handle<S> -> H -> H & Out,handles: List<&2,W.Handle<S>>,+mainFamily: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,+auxFamily: Cmp.Family<S,Store,AuxRest,AuxC,AuxV,AuxToken,aux_take,aux_put,aux_project>,+mode: Selection,+args: A,tx: T.Tx<W.World<S,Store,R,E>,E>) -> T.Tx<W.World<S,Store,R,E>,E> & List<&2,Out>:
  match handles:
    case []: (tx,[])
    case +handle <> rest:
      read_selected(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,~RV,~resource_project,~Payload,~populate,~clear,~A,~Out,~body,main_name(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,mainFamily),aux_name(~S,~Store,~R,~E,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,auxFamily),handle,args,(tx => read_handles(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,~RV,~resource_project,~Payload,~populate,~clear,~A,~Out,~body,rest,mainFamily,auxFamily,mode,args,tx)),selected(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,mainFamily,auxFamily,mode,tx,handle))

def read_world(~S: Data,~Store: Type,~R: Type,~E: Data,~Out: Data,observed: T.Tx<W.World<S,Store,R,E>,E> & List<&2,Out>) -> W.World<S,Store,R,E> & List<&2,Out>:
  match observed:
    case (T.Tx{world,_,_,_},values): (world,values)

def read_reserved(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,~RV: Data,~resource_project: R -> R & RV,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,~clear: Store -> W.Handle<S> -> Store,~A: Data,~Out: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-resource_get: (H -> H & RV) -> A -> W.Handle<S> -> H -> H & Out,mainFamily: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,auxFamily: Cmp.Family<S,Store,AuxRest,AuxC,AuxV,AuxToken,aux_take,aux_put,aux_project>,mode: Selection,args: A,observed: W.World<S,Store,R,E> & List<&2,W.Handle<S>>) -> W.World<S,Store,R,E> & List<&2,Out>:
  (world,handles) = observed
  read_world(~S,~Store,~R,~E,~Out,read_handles(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,~RV,~resource_project,~Payload,~populate,~clear,~A,~Out,~body,handles,mainFamily,auxFamily,mode,args,T.begin(~W.World<S,Store,R,E>,~E,world)))

def each_read(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,~RV: Data,~resource_project: R -> R & RV,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,~clear: Store -> W.Handle<S> -> Store,~A: Data,~Out: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-resource_get: (H -> H & RV) -> A -> W.Handle<S> -> H -> H & Out,mainFamily: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,auxFamily: Cmp.Family<S,Store,AuxRest,AuxC,AuxV,AuxToken,aux_take,aux_put,aux_project>,mode: Selection,world: W.World<S,Store,R,E>,args: A) -> W.World<S,Store,R,E> & List<&2,Out>:
  read_reserved(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,~RV,~resource_project,~Payload,~populate,~clear,~A,~Out,~body,mainFamily,auxFamily,mode,args,W.handles(~S,~Store,~R,~E,world))

# Main RW + aux Read + resource Read, with no other user capability grant.
def each_rw_read_resource(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,~RV: Data,~resource_project: R -> R & RV,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,~clear: Store -> W.Handle<S> -> Store,~A: Data,~U: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-set: (H -> C -> H) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-resource_get: (H -> H & RV) -> A -> W.Handle<S> -> H -> H & T.Outcome<U>,mainFamily: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,auxFamily: Cmp.Family<S,Store,AuxRest,AuxC,AuxV,AuxToken,aux_take,aux_put,aux_project>,mode: Selection,world: W.World<S,Store,R,E>,args: A) -> T.Returned<W.World<S,Store,R,E>,Pv.Error<U>>:
  each_rw_read(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,~RV,~resource_project,~Payload,~populate,~clear,~A,~U,~Pv.component_body(~S,~C,~V,~AuxV,~RV,~R,~E,~Payload,~A,~U,~body),mainFamily,auxFamily,mode,world,args)

# Resource capabilities and spawn are absent from this callback contract.
def each_rw_read_events(~S: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S,C>,~put: Rest -> Col.Column<S,C> -> Store,~project: C -> C & V,~AuxRest: Type,~AuxC: Type,~AuxV: Data,~AuxToken: Data,~aux_take: Store -> AuxRest & Col.Column<S,AuxC>,~aux_put: AuxRest -> Col.Column<S,AuxC> -> Store,~aux_project: AuxC -> AuxC & AuxV,~RV: Data,~resource_project: R -> R & RV,~Payload: Type,~populate: W.World<S,Store,R,E> -> W.Handle<S> -> Payload -> W.World<S,Store,R,E>,~clear: Store -> W.Handle<S> -> Store,~A: Data,~U: Data,~body: @-H: Type -> @-get: (H -> H & Cmp.Access<V>) -> @-set: (H -> C -> H) -> @-aux: (H -> H & Cmp.Access<AuxV>) -> @-emit: (H -> E -> H) -> @-despawn: (H -> H) -> A -> W.Handle<S> -> H -> H & T.Outcome<U>,mainFamily: Cmp.Family<S,Store,Rest,C,V,Token,take,put,project>,auxFamily: Cmp.Family<S,Store,AuxRest,AuxC,AuxV,AuxToken,aux_take,aux_put,aux_project>,mode: Selection,world: W.World<S,Store,R,E>,args: A) -> T.Returned<W.World<S,Store,R,E>,Pv.Error<U>>:
  each_rw_read(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~AuxRest,~AuxC,~AuxV,~AuxToken,~aux_take,~aux_put,~aux_project,~RV,~resource_project,~Payload,~populate,~clear,~A,~U,~Pv.event_body(~S,~C,~V,~AuxV,~RV,~R,~E,~Payload,~A,~U,~body),mainFamily,auxFamily,mode,world,args)
