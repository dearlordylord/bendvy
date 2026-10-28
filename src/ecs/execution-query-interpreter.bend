import Base
import ./execution-reservation-task.bend as Task
import ./chunk-query.bend as Row
import ./execution-query-lifecycle.bend as Lifecycle
import ./execution-query-store.bend as Store
import ./execution-query-admission.bend as Admission
import ./execution-query-recipe.bend as Recipe
import ./execution-query-identity.bend as Id
import ./execution-query-schema.bend as Schema
import ./execution-query-matches.bend as Match
import ./execution-query.bend as Q
import ./execution-builder.bend as Build
import ./execution-state.bend as State
import ./execution-composer-layout.bend as L
import ./execution-lifecycle-notices.bend as Notice
import ./world.bend as W
import ./change-tick.bend as Tick
import ./chunk-column.bend as Column
import ./execution-query-column.bend as EditColumn

type Frame<-S:Data,-full:L.Layout,-route:L.Route,-R:Type> is Type:
  Frame{namespace:U32,rest:Store.route_rest(~S,full,route),grants:List<&2,Admission.Granted<S,L.columns(~S,full)>>,info:List<&2,Schema.Info>,resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,lifecycleView:Notice.View<S>}
def frame_scope(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,frame:Frame<S,full,route,R>,slot:Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)>) -> State.Scope<S,Store.Storage<S,full>,R>:
  match frame:
    case Frame{namespace,rest,grants,info,resource,handles,tick,prior,+view}:State.Scope{Store.Storage{namespace,Store.put(~S,full,route,rest,slot),grants,info},resource,handles,tick,prior,view}
def matched_view_checked(~V:Data,view:Maybe<&2,V>,matched:Bool) -> Q.GeneralLookup<V>:
  match matched:
    case False{}:Q.NotMatched{}
    case True{}:Q.Matched{view}
def matched_view(~V:Data,~predicate:Maybe<&2,V> -> Bool,presence:Match.Presence,+view:Maybe<&2,V>) -> Q.GeneralLookup<V>:
  matched_view_checked(~V,view,Bool.and(Match.membership(V,presence,view),predicate(view)))
def outside_view(~V:Data,~predicate:Maybe<&2,V> -> Bool,presence:Match.Presence,outside:Bool) -> Q.GeneralLookup<V>:
  match outside:
    case False{}:Q.LookupRefused{}
    case True{}:matched_view(~V,~predicate,presence,None{})
def selected_lookup(~V:Data,~predicate:Maybe<&2,V> -> Bool,presence:Match.Presence,offset:U32,capacity:U32,lookup:Store.Lookup<V>) -> Q.GeneralLookup<V>:
  match lookup:
    case Store.Known{view}:matched_view(~V,~predicate,presence,view)
    case Store.OutsideDomain{}:outside_view(~V,~predicate,presence,U32.is_le(capacity,offset))
def get_returned(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,frame:Frame<S,full,route,R>,offset:U32,capacity:U32,result:Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)> & Store.Lookup<L.view(full,route)>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralLookup<L.view(full,route)>:
  match result:
    case (slot,lookup):(frame_scope(~S,~full,~route,~R,frame,slot),selected_lookup(~L.view(full,route),~predicate,presence,offset,capacity,lookup))
def get_taken(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,namespace:U32,grants:List<&2,Admission.Granted<S,L.columns(~S,full)>>,+info:List<&2,Schema.Info>,resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,+offset:U32,result:Store.route_rest(~S,full,route) & Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralLookup<L.view(full,route)>:
  match result:
    case (rest,slot):get_returned(~S,~full,~route,~R,~presence,~predicate,Frame{namespace,rest,grants,info,resource,handles,tick,prior,view},offset,Admission.capacity(Admission.info_at(route,info)),Store.read_slot(S,L.payload(full,route),L.view(full,route),L.origin(full,route),slot,offset))
def sparse_allowed(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,Store.Storage<S,full>,R>,offset:U32,allowed:Bool) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralLookup<L.view(full,route)>:
  match scope allowed:
    case scope False{}:(scope,Q.NotMatched{})
    case State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,+view} True{}:get_taken(~S,~full,~route,~R,~presence,~predicate,namespace,grants,info,resource,handles,tick,prior,view,offset,Store.take(~S,full,route,columns))
def sparse_bound_done(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,namespace:U32,grants:List<&2,Admission.Granted<S,L.columns(~S,full)>>,info:List<&2,Schema.Info>,resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,offset:U32,result:Store.stores(~S,full) & Bool) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralLookup<L.view(full,route)>:
  match result:
    case (columns,selected):sparse_allowed(~S,~full,~route,~R,~presence,~predicate,State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,view},offset,selected)
def sparse_member(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,Store.Storage<S,full>,R>,+offset:U32,selected:Bool) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralLookup<L.view(full,route)>:
  match scope selected:
    case scope False{}:(scope,Q.NotMatched{})
    case State.Scope{Store.Storage{namespace,columns,grants,+info},resource,handles,+tick,+prior,view} True{}:sparse_bound_done(~S,~full,~route,~R,~presence,~predicate,namespace,grants,info,resource,handles,tick,prior,view,offset,Lifecycle.sparse_bound(~S,~full,info,bound,offset,prior,tick,columns))
def sparse_granted(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,Store.Storage<S,full>,R>,handle:W.Handle<S>,offset:U32,grant:Maybe<&2,List<&2,W.Handle<S>>>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralLookup<L.view(full,route)>:
  match grant:
    case None{}:(scope,Q.LookupRefused{})
    case Some{handles}:sparse_member(~S,~full,~route,~R,~bound,~presence,~predicate,scope,offset,State.member(~S,handle,handles))
def sparse_physical(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~kind:Recipe.QueryKind,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,Store.Storage<S,full>,R>,handle:W.Handle<S>,checked:Id.Offset<S>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralLookup<L.view(full,route)>:
  match scope checked:
    case State.Scope{Store.Storage{namespace,columns,+grants,info},resource,handles,tick,prior,+view} Id.Physical{_,offset}:sparse_granted(~S,~full,~route,~R,~bound,~presence,~predicate,State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,view},handle,offset,Admission.grant_handles(~S,~L.columns(~S,full),Recipe.Entry{route,kind,bound,presence},grants))
    case scope _:(scope,Q.MissingEntity{})
def sparse_get(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~kind:Recipe.QueryKind,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,Store.Storage<S,full>,R>,+handle:W.Handle<S>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralLookup<L.view(full,route)>:
  match scope:
    case State.Scope{Store.Storage{+namespace,columns,grants,info},resource,+handles,tick,prior,+view}:sparse_physical(~S,~full,~route,~R,~kind,~bound,~presence,~predicate,State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,view},handle,Id.checked_offset(~S,namespace,handles,Column.maximum_capacity(),handle))
def query_row(~S:Data,~V:Data,handle:W.Handle<S>,row:Q.GeneralLookup<V>,tail:Q.GeneralReport<S,V>) -> Q.GeneralReport<S,V>:
  match row tail:
    case Q.Matched{view} Q.SelectedRows{rows}:Q.SelectedRows{Q.GeneralRow{handle,view} <> rows}
    case Q.NotMatched{} tail:tail
    case _ _:Q.SelectionRefused{}
def row_got(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,handle:W.Handle<S>,tail:Q.GeneralReport<S,L.view(full,route)>,result:State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralLookup<L.view(full,route)>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralReport<S,L.view(full,route)>:
  match result:
    case (scope,row):(scope,query_row(~S,~L.view(full,route),handle,row,tail))
def row_tail(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~kind:Recipe.QueryKind,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,+handle:W.Handle<S>,result:State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralReport<S,L.view(full,route)>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralReport<S,L.view(full,route)>:
  match result:
    case (scope,tail):row_got(~S,~full,~route,~R,handle,tail,sparse_get(~S,~full,~route,~R,~kind,~bound,~presence,~predicate,scope,handle))
def sparse_rows(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~kind:Recipe.QueryKind,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,candidates:List<&2,W.Handle<S>>,scope:State.Scope<S,Store.Storage<S,full>,R>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralReport<S,L.view(full,route)>:
  match candidates:
    case []:(scope,Q.SelectedRows{[]})
    case +handle <> rest:row_tail(~S,~full,~route,~R,~kind,~bound,~presence,~predicate,handle,sparse_rows(~S,~full,~route,~R,~kind,~bound,~presence,~predicate,rest,scope))
def sparse_candidates(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~kind:Recipe.QueryKind,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,Store.Storage<S,full>,R>,candidates:Maybe<&2,List<&2,W.Handle<S>>>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralReport<S,L.view(full,route)>:
  match candidates:
    case None{}:(scope,Q.SelectionRefused{})
    case Some{handles}:sparse_rows(~S,~full,~route,~R,~kind,~bound,~presence,~predicate,handles,scope)
def sparse_query(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~kind:Recipe.QueryKind,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,Store.Storage<S,full>,R>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralReport<S,L.view(full,route)>:
  match scope:
    case State.Scope{Store.Storage{namespace,columns,+grants,info},resource,handles,tick,prior,+view}:sparse_candidates(~S,~full,~route,~R,~kind,~bound,~presence,~predicate,State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,view},Admission.grant_handles(~S,~L.columns(~S,full),Recipe.Entry{route,kind,bound,presence},grants))
def edit_returned(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,-Out:Type,frame:Frame<S,full,route,R>,result:Store.Edit<S,L.payload(full,route),L.view(full,route),L.origin(full,route),Out>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralEdit<L.payload(full,route),Out>:
  match result:
    case Store.Edited{slot,out}:(frame_scope(~S,~full,~route,~R,frame,slot),Q.GeneralEdited{out})
    case Store.Unchanged{slot,unused}:(frame_scope(~S,~full,~route,~R,frame,slot),Q.GeneralUnchanged{unused})
def edit_taken(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,-Out:Type,namespace:U32,grants:List<&2,Admission.Granted<S,L.columns(~S,full)>>,info:List<&2,Schema.Info>,resource:R,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,offset:U32,transform:L.payload(full,route) -> L.payload(full,route) & Out,result:Store.route_rest(~S,full,route) & Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralEdit<L.payload(full,route),Out>:
  match result:
    case (rest,slot):edit_returned(~S,~full,~route,~R,Out,Frame{namespace,rest,grants,info,resource,handles,tick,prior,view},Store.edit_slot(~S,~full,~route,Out,slot,offset,tick,transform))
def edit_physical(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,-Out:Type,scope:State.Scope<S,Store.Storage<S,full>,R>,transform:L.payload(full,route) -> L.payload(full,route) & Out,checked:Id.Offset<S>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralEdit<L.payload(full,route),Out>:
  match scope checked:
    case State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,+view} Id.Physical{_,offset}:edit_taken(~S,~full,~route,~R,Out,namespace,grants,info,resource,handles,tick,prior,view,offset,transform,Store.take(~S,full,route,columns))
    case scope _:(scope,Q.GeneralUnchanged{transform})
def edit_matched(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,-Out:Type,handle:W.Handle<S>,transform:L.payload(full,route) -> L.payload(full,route) & Out,result:State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralLookup<L.view(full,route)>) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralEdit<L.payload(full,route),Out>:
  match result:
    case (State.Scope{Store.Storage{+namespace,columns,grants,info},resource,+handles,tick,prior,+view},Q.Matched{_}):edit_physical(~S,~full,~route,~R,Out,State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,view},transform,Id.checked_offset(~S,namespace,handles,Column.maximum_capacity(),handle))
    case (scope,_):(scope,Q.GeneralUnchanged{transform})
def sparse_modify(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,-Out:Type,scope:State.Scope<S,Store.Storage<S,full>,R>,+handle:W.Handle<S>,transform:L.payload(full,route) -> L.payload(full,route) & Out) -> State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralEdit<L.payload(full,route),Out>:
  edit_matched(~S,~full,~route,~R,Out,handle,transform,sparse_get(~S,~full,~route,~R,~Recipe.WriteRows{},~bound,~presence,~predicate,scope,handle))
def sparse_reader(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~kind:Recipe.QueryKind,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool) -> Q.GeneralReader<S,State.Scope<S,Store.Storage<S,full>,R>,L.view(full,route)>:
  Q.GeneralReader{scope=>sparse_query(~S,~full,~route,~R,~kind,~bound,~presence,~predicate,scope),scope=>handle=>sparse_get(~S,~full,~route,~R,~kind,~bound,~presence,~predicate,scope,handle)}
def traverse_selected_handles(~S:Data,~V:Data,rows:List<&2,Q.GeneralRow<S,V>>) -> List<&2,W.Handle<S>>:
  match rows:
    case []:[]
    case Q.GeneralRow{handle,Some{_}} <> rest:handle <> traverse_selected_handles(~S,~V,rest)
    case Q.GeneralRow{_,None{}} <> rest:traverse_selected_handles(~S,~V,rest)
def traverse_selected_offsets(~S:Data,handles:List<&2,W.Handle<S>>) -> List<&2,U32>:
  match handles:
    case []:[]
    case handle <> rest:U32.sub(W.handle_index(~S,handle),1) <> traverse_selected_offsets(~S,rest)
def traverse_members(~S:Data,requested:List<&2,W.Handle<S>>,+selected:List<&2,W.Handle<S>>) -> Bool:
  match requested:
    case []:True{}
    case handle <> rest:Bool.and(State.member(~S,handle,selected),traverse_members(~S,rest,selected))
def traverse_chosen(~S:Data,selected:List<&2,W.Handle<S>>,targets:Q.GeneralTargets<S>) -> List<&2,W.Handle<S>>:
  match targets:
    case Q.AllMatched{}:selected
    case Q.ExplicitHandles{requested}:requested
def traverse_sparse_returned(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,frame:Frame<S,full,route,R>,result:Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)> & (O & (List<&2,Row.Error<E>> & Bool))) -> State.Scope<S,Store.Storage<S,full>,R> & (O & Q.Report<E>):
  match result:
    case (slot,(output,(errors,True{}))):(frame_scope(~S,~full,~route,~R,frame,slot),(output,Q.Completed{errors}))
    case (slot,(output,(_,False{}))):(frame_scope(~S,~full,~route,~R,frame,slot),(output,Q.LayoutRefused{}))
def traverse_sparse_taken(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>),frame:Frame<S,full,route,R>,+selected:List<&2,W.Handle<S>>,tick:Tick.Tick,parallel:Bool,output:O,slot:Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)>) -> State.Scope<S,Store.Storage<S,full>,R> & (O & Q.Report<E>):
  traverse_sparse_returned(~S,~full,~route,~R,~O,~E,frame,Store.traverse_output_slot(~S,~full,~route,~O,~E,~body,~split,~merge,selected,tick,parallel,Row.Selected{traverse_selected_offsets(~S,selected)},slot,output))
def traverse_sparse_split(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>),namespace:U32,grants:List<&2,Admission.Granted<S,L.columns(~S,full)>>,info:List<&2,Schema.Info>,resource:R,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,selected:List<&2,W.Handle<S>>,parallel:Bool,output:O,result:Store.route_rest(~S,full,route) & Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)>) -> State.Scope<S,Store.Storage<S,full>,R> & (O & Q.Report<E>):
  match result:
    case (rest,slot):traverse_sparse_taken(~S,~full,~route,~R,~O,~E,~split,~merge,~body,Frame{namespace,rest,grants,info,resource,handles,tick,prior,view},selected,tick,parallel,output,slot)
def traverse_sparse_admitted(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>),scope:State.Scope<S,Store.Storage<S,full>,R>,output:O,parallel:Bool,checked:Id.TargetCheck<S>,members:Bool) -> State.Scope<S,Store.Storage<S,full>,R> & (O & Q.Report<E>):
  match scope checked members:
    case State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,+view} Id.Targets{[],_} True{}:(State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,view},(output,Q.Completed{[]}))
    case State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,+view} Id.Targets{selected,_} True{}:traverse_sparse_split(~S,~full,~route,~R,~O,~E,~split,~merge,~body,namespace,grants,info,resource,handles,tick,prior,view,selected,parallel,output,Store.take(~S,full,route,columns))
    case scope _ _:(scope,(output,Q.LayoutRefused{}))
def traverse_sparse_validate(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>),scope:State.Scope<S,Store.Storage<S,full>,R>,output:O,parallel:Bool,selected:List<&2,W.Handle<S>>,+requested:List<&2,W.Handle<S>>) -> State.Scope<S,Store.Storage<S,full>,R> & (O & Q.Report<E>):
  match scope:
    case State.Scope{Store.Storage{+namespace,columns,grants,info},resource,+handles,tick,prior,+view}:traverse_sparse_admitted(~S,~full,~route,~R,~O,~E,~split,~merge,~body,State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,view},output,parallel,Id.targets_offsets(~S,requested,Id.target_offsets(~S,namespace,handles,requested)),traverse_members(~S,requested,selected))
def traverse_sparse_choose(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>),scope:State.Scope<S,Store.Storage<S,full>,R>,output:O,parallel:Bool,+selected:List<&2,W.Handle<S>>,targets:Q.GeneralTargets<S>) -> State.Scope<S,Store.Storage<S,full>,R> & (O & Q.Report<E>):
  traverse_sparse_validate(~S,~full,~route,~R,~O,~E,~split,~merge,~body,scope,output,parallel,selected,traverse_chosen(~S,selected,targets))
def traverse_sparse_queried(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>),output:O,parallel:Bool,targets:Q.GeneralTargets<S>,result:State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralReport<S,L.view(full,route)>) -> State.Scope<S,Store.Storage<S,full>,R> & (O & Q.Report<E>):
  match result:
    case (scope,Q.SelectionRefused{}):(scope,(output,Q.LayoutRefused{}))
    case (scope,Q.SelectedRows{rows}):traverse_sparse_choose(~S,~full,~route,~R,~O,~E,~split,~merge,~body,scope,output,parallel,traverse_selected_handles(~S,~L.view(full,route),rows),targets)
def traverse_sparse(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>),mode:Q.Mode,scope:State.Scope<S,Store.Storage<S,full>,R>,output:O,targets:Q.GeneralTargets<S>) -> State.Scope<S,Store.Storage<S,full>,R> & (O & Q.Report<E>):
  match mode:
    case Q.Serial{}:traverse_sparse_queried(~S,~full,~route,~R,~O,~E,~split,~merge,~body,output,False{},targets,sparse_query(~S,~full,~route,~R,~Recipe.WriteRows{},~bound,~presence,~predicate,scope))
    case Q.Parallel{}:traverse_sparse_queried(~S,~full,~route,~R,~O,~E,~split,~merge,~body,output,True{},targets,sparse_query(~S,~full,~route,~R,~Recipe.WriteRows{},~bound,~presence,~predicate,scope))
    case _:(scope,(output,Q.LayoutRefused{}))
def sparse_caps_direct(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,kind:Recipe.QueryKind) -> Q.GeneralOps(~S,~L.payload(full,route),~L.view(full,route),kind,State.Scope<S,Store.Storage<S,full>,R>):
  match kind:
    case Recipe.ReadRows{}:sparse_reader(~S,~full,~route,~R,~Recipe.ReadRows{},~bound,~presence,~predicate)
    case Recipe.WriteRows{}:Q.GeneralWriter{sparse_reader(~S,~full,~route,~R,~Recipe.WriteRows{},~bound,~presence,~predicate),Out=>scope=>handle=>transform=>sparse_modify(~S,~full,~route,~R,~bound,~presence,~predicate,Out,scope,handle,transform)}
def sparse_caps(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,same:{C == Store.Storage<S,full> : Type},kind:Recipe.QueryKind) -> Q.GeneralOps(~S,~L.payload(full,route),~L.view(full,route),kind,State.Scope<S,C,R>):
  %Equal.sym(Type,C,Store.Storage<S,full>,same) : Q.GeneralOps(~S,~L.payload(full,route),~L.view(full,route),kind,State.Scope<S,_,R>)
  sparse_caps_direct(~S,~full,~route,~R,~bound,~presence,~predicate,kind)
type WholeFrame<-S:Data,-full:L.Layout,-route:L.Route,-R:Type> is Type:
  WholeFrame{rest:L.column_rest(~S,full,route),resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,lifecycleView:Notice.View<S>}
def whole_scope(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,frame:WholeFrame<S,full,route,R>,column:Column.Column<S,L.stored(full,route)>) -> State.Scope<S,L.columns(~S,full),R>:
  match frame:
    case WholeFrame{rest,resource,handles,tick,prior,+view}:State.Scope{L.column_put(~S,full,route,rest,L.ColumnSlot{column}),resource,handles,tick,prior,view}
def whole_cached(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,frame:WholeFrame<S,full,route,R>,+offset:U32,capacity:U32,result:Column.Column<S,L.stored(full,route)> & List<&2,Match.Row<L.view(full,route)>>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match result:
    case (column,rows):(whole_scope(~S,~full,~route,~R,frame,column),selected_lookup(~L.view(full,route),~predicate,presence,offset,capacity,Store.cached_lookup(L.view(full,route),rows,offset)))
def whole_taken(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,offset:U32,capacity:U32,result:L.column_rest(~S,full,route) & L.ColumnSlot<S,L.stored(full,route),L.key(full,route),L.origin(full,route)>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match result:
    case (rest,L.ColumnSlot{column}):whole_cached(~S,~full,~route,~R,~presence,~predicate,WholeFrame{rest,resource,handles,tick,prior,view},offset,capacity,Schema.cache_column(S,L.payload(full,route),L.view(full,route),column,0))
def whole_described_allowed(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,L.columns(~S,full),R>,offset:U32,capacity:U32,allowed:Bool) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match scope allowed:
    case scope False{}:(scope,Q.NotMatched{})
    case State.Scope{columns,resource,handles,tick,prior,+view} True{}:whole_taken(~S,~full,~route,~R,~presence,~predicate,resource,handles,tick,prior,view,offset,capacity,L.column_take(~S,full,route,columns))
def whole_bound_done(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,offset:U32,capacity:U32,result:L.columns(~S,full) & Bool) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match result:
    case (columns,selected):whole_described_allowed(~S,~full,~route,~R,~presence,~predicate,State.Scope{columns,resource,handles,tick,prior,view},offset,capacity,selected)
def whole_described(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,resource:R,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,+prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,+offset:U32,result:Schema.Description<S,full>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match result:
    case Schema.Description{columns,+info,True{}}:whole_bound_done(~S,~full,~route,~R,~presence,~predicate,resource,handles,tick,prior,view,offset,Admission.capacity(Admission.info_at(route,info)),Lifecycle.whole_bound(~S,~full,info,bound,offset,prior,tick,columns))
    case Schema.Description{columns,_,False{}}:(State.Scope{columns,resource,handles,tick,prior,view},Q.LookupRefused{})
def whole_physical(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,L.columns(~S,full),R>,checked:Id.Offset<S>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match scope checked:
    case State.Scope{columns,resource,handles,tick,prior,+view} Id.Physical{_,offset}:whole_described(~S,~full,~route,~R,~bound,~presence,~predicate,resource,handles,tick,prior,view,offset,Schema.describe(~S,full,L.AtLeaf{},columns))
    case scope _:(scope,Q.MissingEntity{})
def whole_get(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,L.columns(~S,full),R>,handle:W.Handle<S>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match scope:
    case State.Scope{columns,resource,+handles,tick,prior,+view}:whole_physical(~S,~full,~route,~R,~bound,~presence,~predicate,State.Scope{columns,resource,handles,tick,prior,view},Id.captured_offset(~S,handles,handle))
def whole_edit_returned(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,-Out:Type,frame:WholeFrame<S,full,route,R>,result:EditColumn.Edit<S,L.stored(full,route),L.payload(full,route),Out>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralEdit<L.payload(full,route),Out>:
  match result:
    case EditColumn.Edited{column,out}:(whole_scope(~S,~full,~route,~R,frame,column),Q.GeneralEdited{out})
    case EditColumn.Unchanged{column,unused}:(whole_scope(~S,~full,~route,~R,frame,column),Q.GeneralUnchanged{unused})
def whole_edit_taken(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,-Out:Type,resource:R,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,offset:U32,transform:L.payload(full,route) -> L.payload(full,route) & Out,result:L.column_rest(~S,full,route) & L.ColumnSlot<S,L.stored(full,route),L.key(full,route),L.origin(full,route)>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralEdit<L.payload(full,route),Out>:
  match result:
    case (rest,L.ColumnSlot{column}):whole_edit_returned(~S,~full,~route,~R,Out,WholeFrame{rest,resource,handles,tick,prior,view},EditColumn.edit(~S,~full,~route,Out,column,offset,tick,transform))
def whole_edit_physical(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,-Out:Type,scope:State.Scope<S,L.columns(~S,full),R>,transform:L.payload(full,route) -> L.payload(full,route) & Out,checked:Id.Offset<S>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralEdit<L.payload(full,route),Out>:
  match scope checked:
    case State.Scope{columns,resource,handles,tick,prior,+view} Id.Physical{_,offset}:whole_edit_taken(~S,~full,~route,~R,Out,resource,handles,tick,prior,view,offset,transform,L.column_take(~S,full,route,columns))
    case scope _:(scope,Q.GeneralUnchanged{transform})
def whole_edit_matched(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,-Out:Type,handle:W.Handle<S>,transform:L.payload(full,route) -> L.payload(full,route) & Out,result:State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralEdit<L.payload(full,route),Out>:
  match result:
    case (State.Scope{columns,resource,+handles,tick,prior,+view},Q.Matched{_}):whole_edit_physical(~S,~full,~route,~R,Out,State.Scope{columns,resource,handles,tick,prior,view},transform,Id.captured_offset(~S,handles,handle))
    case (scope,_):(scope,Q.GeneralUnchanged{transform})
def whole_modify(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,-Out:Type,scope:State.Scope<S,L.columns(~S,full),R>,+handle:W.Handle<S>,transform:L.payload(full,route) -> L.payload(full,route) & Out) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralEdit<L.payload(full,route),Out>:
  whole_edit_matched(~S,~full,~route,~R,Out,handle,transform,whole_get(~S,~full,~route,~R,~bound,~presence,~predicate,scope,handle))

def whole_row_got(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,handle:W.Handle<S>,tail:Q.GeneralReport<S,L.view(full,route)>,result:State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralReport<S,L.view(full,route)>:
  match result:
    case (scope,row):(scope,query_row(~S,~L.view(full,route),handle,row,tail))
def whole_row_tail(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,+handle:W.Handle<S>,result:State.Scope<S,L.columns(~S,full),R> & Q.GeneralReport<S,L.view(full,route)>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralReport<S,L.view(full,route)>:
  match result:
    case (scope,tail):whole_row_got(~S,~full,~route,~R,handle,tail,whole_get(~S,~full,~route,~R,~bound,~presence,~predicate,scope,handle))
def whole_rows(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,candidates:List<&2,W.Handle<S>>,scope:State.Scope<S,L.columns(~S,full),R>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralReport<S,L.view(full,route)>:
  match candidates:
    case []:(scope,Q.SelectedRows{[]})
    case +handle <> rest:whole_row_tail(~S,~full,~route,~R,~bound,~presence,~predicate,handle,whole_rows(~S,~full,~route,~R,~bound,~presence,~predicate,rest,scope))
def whole_query(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,L.columns(~S,full),R>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralReport<S,L.view(full,route)>:
  match scope:
    case State.Scope{columns,resource,+handles,tick,prior,+view}:whole_rows(~S,~full,~route,~R,~bound,~presence,~predicate,handles,State.Scope{columns,resource,handles,tick,prior,view})

def whole_reader(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool) -> Q.GeneralReader<S,State.Scope<S,L.columns(~S,full),R>,L.view(full,route)>:
  Q.GeneralReader{scope=>whole_query(~S,~full,~route,~R,~bound,~presence,~predicate,scope),scope=>handle=>whole_get(~S,~full,~route,~R,~bound,~presence,~predicate,scope,handle)}
def whole_caps_direct(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,kind:Recipe.QueryKind) -> Q.GeneralOps(~S,~L.payload(full,route),~L.view(full,route),kind,State.Scope<S,L.columns(~S,full),R>):
  match kind:
    case Recipe.ReadRows{}:whole_reader(~S,~full,~route,~R,~bound,~presence,~predicate)
    case Recipe.WriteRows{}:Q.GeneralWriter{whole_reader(~S,~full,~route,~R,~bound,~presence,~predicate),Out=>scope=>handle=>transform=>whole_modify(~S,~full,~route,~R,~bound,~presence,~predicate,Out,scope,handle,transform)}
def whole_caps(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,same:{C == L.columns(~S,full) : Type},kind:Recipe.QueryKind) -> Q.GeneralOps(~S,~L.payload(full,route),~L.view(full,route),kind,State.Scope<S,C,R>):
  %Equal.sym(Type,C,L.columns(~S,full),same) : Q.GeneralOps(~S,~L.payload(full,route),~L.view(full,route),kind,State.Scope<S,_,R>)
  whole_caps_direct(~S,~full,~route,~R,~bound,~presence,~predicate,kind)
def model_caps(~S:Data,~WC:Type,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,~same:{WC == L.columns(~S,full) : Type},~valid:{L.grant_valid(~full,~route) == True{} : Bool},~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,model:Store.StorageModel,local:{C == Store.owner(~S,full,model) : Type},kind:Recipe.QueryKind) -> Q.GeneralOps(~S,~L.payload(full,route),~L.view(full,route),kind,State.Scope<S,C,R>):
  match model:
    case Store.Whole{}:whole_caps(~S,~full,~route,~C,~R,~bound,~presence,~predicate,local,kind)
    case Store.Sparse{}:sparse_caps(~S,~full,~route,~C,~R,~bound,~presence,~predicate,local,kind)
def ordinary_provider(~S:Data,~WC:Type,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,~same:{WC == L.columns(~S,full) : Type},~valid:{L.grant_valid(~full,~route) == True{} : Bool},~model:Store.StorageModel,~local:{C == Store.owner(~S,full,model) : Type},~kind:Recipe.QueryKind,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool) -> Q.GeneralOps(~S,~L.payload(full,route),~L.view(full,route),kind,State.Scope<S,C,R>):
  model_caps(~S,~WC,~C,~R,~full,~route,~same,~valid,~bound,~presence,~predicate,model,local,kind)

def sparse_output_caps_direct(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>)) -> Q.GeneralOutputWriter<S,State.Scope<S,Store.Storage<S,full>,R>,L.payload(full,route),L.view(full,route),O,E>:
  Q.GeneralOutputWriter{sparse_reader(~S,~full,~route,~R,~Recipe.WriteRows{},~bound,~presence,~predicate),Out=>scope=>handle=>transform=>sparse_modify(~S,~full,~route,~R,~bound,~presence,~predicate,Out,scope,handle,transform),traverse_sparse(~S,~full,~route,~R,~bound,~presence,~predicate,~O,~E,~split,~merge,~body)}
def sparse_output_caps(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>),~C:Type,same:{C == Store.Storage<S,full> : Type}) -> Q.GeneralOutputWriter<S,State.Scope<S,C,R>,L.payload(full,route),L.view(full,route),O,E>:
  %Equal.sym(Type,C,Store.Storage<S,full>,same) : Q.GeneralOutputWriter<S,State.Scope<S,_,R>,L.payload(full,route),L.view(full,route),O,E>
  sparse_output_caps_direct(~S,~full,~route,~R,~bound,~presence,~predicate,~O,~E,~split,~merge,~body)
def whole_output_caps_direct(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>)) -> Q.GeneralOutputWriter<S,State.Scope<S,L.columns(~S,full),R>,L.payload(full,route),L.view(full,route),O,E>:
  Q.GeneralOutputWriter{whole_reader(~S,~full,~route,~R,~bound,~presence,~predicate),Out=>scope=>handle=>transform=>whole_modify(~S,~full,~route,~R,~bound,~presence,~predicate,Out,scope,handle,transform),mode=>scope=>output=>targets=>(scope,(output,Q.LayoutRefused{}))}
def whole_output_caps(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>),~C:Type,same:{C == L.columns(~S,full) : Type}) -> Q.GeneralOutputWriter<S,State.Scope<S,C,R>,L.payload(full,route),L.view(full,route),O,E>:
  %Equal.sym(Type,C,L.columns(~S,full),same) : Q.GeneralOutputWriter<S,State.Scope<S,_,R>,L.payload(full,route),L.view(full,route),O,E>
  whole_output_caps_direct(~S,~full,~route,~R,~bound,~presence,~predicate,~O,~E,~split,~merge,~body)
def output_model_caps(~S:Data,~WC:Type,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,~same:{WC == L.columns(~S,full) : Type},~valid:{L.grant_valid(~full,~route) == True{} : Bool},~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>),model:Store.StorageModel,local:{C == Store.owner(~S,full,model) : Type}) -> Q.GeneralOutputWriter<S,State.Scope<S,C,R>,L.payload(full,route),L.view(full,route),O,E>:
  match model:
    case Store.Whole{}:whole_output_caps(~S,~full,~route,~R,~bound,~presence,~predicate,~O,~E,~split,~merge,~body,~C,local)
    case Store.Sparse{}:sparse_output_caps(~S,~full,~route,~R,~bound,~presence,~predicate,~O,~E,~split,~merge,~body,~C,local)
def output_provider(~S:Data,~WC:Type,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,~same:{WC == L.columns(~S,full) : Type},~valid:{L.grant_valid(~full,~route) == True{} : Bool},~model:Store.StorageModel,~local:{C == Store.owner(~S,full,model) : Type},~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>)) -> Q.GeneralOutputWriter<S,State.Scope<S,C,R>,L.payload(full,route),L.view(full,route),O,E>:
  output_model_caps(~S,~WC,~C,~R,~full,~route,~same,~valid,~bound,~presence,~predicate,~O,~E,~split,~merge,~body,model,local)

def task_selected_handles(~S:Data,~V:Data,rows:List<&2,Q.GeneralRow<S,V>>) -> List<&2,W.Handle<S>>:
  match rows:
    case []:[]
    case Q.GeneralRow{handle,Some{_}} <> rest:handle <> task_selected_handles(~S,~V,rest)
    case Q.GeneralRow{_,None{}} <> rest:task_selected_handles(~S,~V,rest)

def task_selected_offsets(~S:Data,handles:List<&2,W.Handle<S>>) -> List<&2,U32>:
  match handles:
    case []:[]
    case handle <> rest:U32.sub(W.handle_index(~S,handle),1) <> task_selected_offsets(~S,rest)

def task_sparse_returned(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,frame:Frame<S,full,route,R>,result:Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)> & (O & (List<&2,Row.Error<E>> & Bool))) -> State.Scope<S,Store.Storage<S,full>,R> & (O & Q.Report<E>):
  match result:
    case (slot,(output,(errors,True{}))):(frame_scope(~S,~full,~route,~R,frame,slot),(output,Q.Completed{errors}))
    case (slot,(output,(_,False{}))):(frame_scope(~S,~full,~route,~R,frame,slot),(output,Q.LayoutRefused{}))

def task_sparse_taken(~S:Data,~Permit:Data,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:Q.TaskGeneralBody(~S,~Permit,~L.payload(full,route),~L.view(full,route),~O,~E),namespace:U32,grants:List<&2,Admission.Granted<S,L.columns(~S,full)>>,info:List<&2,Schema.Info>,resource:R,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,+prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,+selected:List<&2,W.Handle<S>>,+mode:Q.Mode,output:O,result:Store.route_rest(~S,full,route) & Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)>) -> Task.Task<S,Permit,State.Scope<S,Store.Storage<S,full>,R> & (O & Q.Report<E>)>:
  match result:
    case (rest,slot):Task.TBind{Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)> & (O & (List<&2,Row.Error<E>> & Bool)),Store.task_output_slot(~S,~Permit,~full,~route,~O,~E,~body,~split,~merge,selected,tick,Q.mode_parallel(mode),Q.selection(mode,task_selected_offsets(~S,selected),prior),slot,output),result=>Task.TDone{task_sparse_returned(~S,~full,~route,~R,~O,~E,Frame{namespace,rest,grants,info,resource,handles,tick,prior,view},result)}}

def task_sparse_selected(~S:Data,~Permit:Data,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:Q.TaskGeneralBody(~S,~Permit,~L.payload(full,route),~L.view(full,route),~O,~E),mode:Q.Mode,output:O,result:State.Scope<S,Store.Storage<S,full>,R> & Q.GeneralReport<S,L.view(full,route)>) -> Task.Task<S,Permit,State.Scope<S,Store.Storage<S,full>,R> & (O & Q.Report<E>)>:
  match result:
    case (scope,Q.SelectionRefused{}):Task.TDone{(scope,(output,Q.LayoutRefused{}))}
    case (State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,+view},Q.SelectedRows{rows}):task_sparse_taken(~S,~Permit,~full,~route,~R,~O,~E,~split,~merge,~body,namespace,grants,info,resource,handles,tick,prior,view,task_selected_handles(~S,~L.view(full,route),rows),mode,output,Store.take(~S,full,route,columns))

def task_sparse_targets(~S:Data,~Permit:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:Q.TaskGeneralBody(~S,~Permit,~L.payload(full,route),~L.view(full,route),~O,~E),mode:Q.Mode,scope:State.Scope<S,Store.Storage<S,full>,R>,output:O,checked:Id.TargetCheck<S>) -> Task.Task<S,Permit,State.Scope<S,Store.Storage<S,full>,R> & (O & Q.Report<E>)>:
  match checked:
    case Id.Refused{_}:Task.TDone{(scope,(output,Q.LayoutRefused{}))}
    case Id.Targets{_,_}:task_sparse_selected(~S,~Permit,~full,~route,~R,~O,~E,~split,~merge,~body,mode,output,sparse_query(~S,~full,~route,~R,~Recipe.WriteRows{},~bound,~presence,~predicate,scope))

def task_sparse_invoke(~S:Data,~Permit:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:Q.TaskGeneralBody(~S,~Permit,~L.payload(full,route),~L.view(full,route),~O,~E),mode:Q.Mode,scope:State.Scope<S,Store.Storage<S,full>,R>,output:O) -> Task.Task<S,Permit,State.Scope<S,Store.Storage<S,full>,R> & (O & Q.Report<E>)>:
  match scope:
    case State.Scope{Store.Storage{+namespace,columns,grants,info},resource,+handles,tick,prior,+view}:task_sparse_targets(~S,~Permit,~full,~route,~R,~bound,~presence,~predicate,~O,~E,~split,~merge,~body,mode,State.Scope{Store.Storage{namespace,columns,grants,info},resource,handles,tick,prior,view},output,Id.targets(~S,namespace,handles))

def task_sparse_caps(~S:Data,~Permit:Data,~full:L.Layout,~route:L.Route,~C:Type,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:Q.TaskGeneralBody(~S,~Permit,~L.payload(full,route),~L.view(full,route),~O,~E),mode:Q.Mode,same:{C == Store.Storage<S,full> : Type}) -> Q.TaskOutputEach<S,Permit,State.Scope<S,C,R>,O,E>:
  %Equal.sym(Type,C,Store.Storage<S,full>,same) : Q.TaskOutputEach<S,Permit,State.Scope<S,_,R>,O,E>
  Q.TaskOutputEach{task_sparse_invoke(~S,~Permit,~full,~route,~R,~bound,~presence,~predicate,~O,~E,~split,~merge,~body,mode)}

def task_model_caps(~S:Data,~Permit:Data,~WC:Type,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,~same:{WC == L.columns(~S,full) : Type},~valid:{L.grant_valid(~full,~route) == True{} : Bool},~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:Q.TaskGeneralBody(~S,~Permit,~L.payload(full,route),~L.view(full,route),~O,~E),mode:Q.Mode,model:Store.StorageModel,local:{C == Store.owner(~S,full,model) : Type}) -> Q.TaskOutputEach<S,Permit,State.Scope<S,C,R>,O,E>:
  match model:
    case Store.Whole{}:Q.TaskOutputEach{scope=>output=>Task.TDone{(scope,(output,Q.LayoutRefused{}))}}
    case Store.Sparse{}:task_sparse_caps(~S,~Permit,~full,~route,~C,~R,~bound,~presence,~predicate,~O,~E,~split,~merge,~body,mode,local)

def task_provider_dictionary(~S:Data,~WC:Type,~C:Type,~R:Type,~Permit:Data,~full:L.Layout,~route:L.Route,~same:{WC == L.columns(~S,full) : Type},~valid:{L.grant_valid(~full,~route) == True{} : Bool},~model:Store.StorageModel,~local:{C == Store.owner(~S,full,model) : Type},~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:Q.TaskGeneralBody(~S,~Permit,~L.payload(full,route),~L.view(full,route),~O,~E),mode:Q.Mode) -> Q.TaskOutputEach<S,Permit,State.Scope<S,C,R>,O,E>:
  task_model_caps(~S,~Permit,~WC,~C,~R,~full,~route,~same,~valid,~bound,~presence,~predicate,~O,~E,~split,~merge,~body,mode,model,local)

def provider_dictionary(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Type,~selection:Build.GeneralProviderSelection(~S,~WC,~C,~R,~Ops)) -> Ops:
  selection(ordinary_provider(~S,~WC,~C,~R),output_provider(~S,~WC,~C,~R),task_provider_dictionary(~S,~WC,~C,~R))
