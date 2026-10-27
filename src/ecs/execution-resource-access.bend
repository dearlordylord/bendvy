import Base
import ./execution-resource-store.bend as Store
import ./execution-resource-recipe.bend as Recipe
import ./execution-composer-layout.bend as L
import ./execution-state.bend as State
import ./execution-lifecycle-notices.bend as Notice
import ./world.bend as W
import ./change-tick.bend as Tick

type Reader<-H:Type,-V:Data> is Type:
  Reader{get:H -> H & Store.Lookup<V>}
  UnsupportedReader{}
type Writer<-H:Type,-P:Type,-V:Data> is Type:
  Writer{read:Reader<H,V>,own:@-Out:Type -> H -> (P -> P & Out) -> H & Store.Edit<P,Out>,own_at:@-Out:Type -> H -> (Tick.Tick -> P -> P & Out) -> H & Store.Edit<P,Out>}
  UnsupportedWriter{}
def Reads(~V:Data,H:Type) -> Type:Reader<H,V>
def Writes(~P:Type,~V:Data,H:Type) -> Type:Writer<H,P,V>
type Frame<-S:Data,-full:L.Layout,-route:L.Route,-C:Type> is Type:
  Frame{namespace:U32,rest:Store.route_rest(~S,full,route),recipes:List<&2,Recipe.Entry>,columns:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>}
def scope(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,frame:Frame<S,full,route,C>,slot:Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)>) -> State.Scope<S,C,Store.Storage<S,full>>:
  match frame:
    case Frame{namespace,rest,recipes,columns,handles,tick,prior,view}:State.Scope{columns,Store.Storage{namespace,Store.put(~S,full,route,rest,slot),recipes},handles,tick,prior,view}
def view_namespace(~S:Data,view:Notice.View<S>) -> U32:
  match view:
    case Notice.View{namespace,_,_}:namespace
def read_returned(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,frame:Frame<S,full,route,C>,result:Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)> & Store.Lookup<L.view(full,route)>) -> State.Scope<S,C,Store.Storage<S,full>> & Store.Lookup<L.view(full,route)>:
  match result:
    case (slot,view):(scope(~S,~full,~route,~C,frame,slot),view)
def read_taken(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,namespace:U32,recipes:List<&2,Recipe.Entry>,columns:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,result:Store.route_rest(~S,full,route) & Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)>) -> State.Scope<S,C,Store.Storage<S,full>> & Store.Lookup<L.view(full,route)>:
  match result:
    case (rest,slot):read_returned(~S,~full,~route,~C,Frame{namespace,rest,recipes,columns,handles,tick,prior,view},Store.read(S,L.payload(full,route),L.view(full,route),L.origin(full,route),slot))
def read_checked(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,source:State.Scope<S,C,Store.Storage<S,full>>,valid:Bool) -> State.Scope<S,C,Store.Storage<S,full>> & Store.Lookup<L.view(full,route)>:
  match source valid:
    case source False{}:(source,Store.LookupRefused{})
    case State.Scope{columns,Store.Storage{namespace,slots,recipes},handles,tick,prior,view} True{}:read_taken(~S,~full,~route,~C,namespace,recipes,columns,handles,tick,prior,view,Store.take(~S,full,route,slots))
def get(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,source:State.Scope<S,C,Store.Storage<S,full>>) -> State.Scope<S,C,Store.Storage<S,full>> & Store.Lookup<L.view(full,route)>:
  match source:
    case State.Scope{columns,Store.Storage{+namespace,slots,+recipes},handles,tick,prior,+view}:read_checked(~S,~full,~route,~C,State.Scope{columns,Store.Storage{namespace,slots,recipes},handles,tick,prior,view},Bool.and(U32.is_eq(namespace,view_namespace(~S,view)),Bool.and(L.valid(full,route),Recipe.uses(Recipe.at(route,recipes)))))
def edit_returned(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,-Out:Type,frame:Frame<S,full,route,C>,result:Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)> & Store.Edit<L.payload(full,route),Out>) -> State.Scope<S,C,Store.Storage<S,full>> & Store.Edit<L.payload(full,route),Out>:
  match result:
    case (slot,out):(scope(~S,~full,~route,~C,frame,slot),out)
def edit_taken(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,-Out:Type,namespace:U32,recipes:List<&2,Recipe.Entry>,columns:C,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,transform:L.payload(full,route) -> L.payload(full,route) & Out,result:Store.route_rest(~S,full,route) & Store.Slot<S,L.payload(full,route),L.view(full,route),L.origin(full,route)>) -> State.Scope<S,C,Store.Storage<S,full>> & Store.Edit<L.payload(full,route),Out>:
  match result:
    case (rest,slot):edit_returned(~S,~full,~route,~C,Out,Frame{namespace,rest,recipes,columns,handles,tick,prior,view},Store.edit(~S,~full,~route,Out,tick,slot,transform))
def edit_checked(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,-Out:Type,source:State.Scope<S,C,Store.Storage<S,full>>,transform:L.payload(full,route) -> L.payload(full,route) & Out,valid:Bool) -> State.Scope<S,C,Store.Storage<S,full>> & Store.Edit<L.payload(full,route),Out>:
  match source valid:
    case source False{}:(source,Store.Unchanged{transform})
    case State.Scope{columns,Store.Storage{namespace,slots,recipes},handles,tick,prior,view} True{}:edit_taken(~S,~full,~route,~C,Out,namespace,recipes,columns,handles,tick,prior,view,transform,Store.take(~S,full,route,slots))
def own(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,-Out:Type,source:State.Scope<S,C,Store.Storage<S,full>>,transform:L.payload(full,route) -> L.payload(full,route) & Out) -> State.Scope<S,C,Store.Storage<S,full>> & Store.Edit<L.payload(full,route),Out>:
  match source:
    case State.Scope{columns,Store.Storage{+namespace,slots,+recipes},handles,tick,prior,+view}:edit_checked(~S,~full,~route,~C,Out,State.Scope{columns,Store.Storage{namespace,slots,recipes},handles,tick,prior,view},transform,Bool.and(U32.is_eq(namespace,view_namespace(~S,view)),Bool.and(L.valid(full,route),Recipe.writes(Recipe.at(route,recipes)))))
def own_at(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,-Out:Type,source:State.Scope<S,C,Store.Storage<S,full>>,transform:Tick.Tick -> L.payload(full,route) -> L.payload(full,route) & Out) -> State.Scope<S,C,Store.Storage<S,full>> & Store.Edit<L.payload(full,route),Out>:
  match source:
    case State.Scope{columns,resource,handles,+tick,prior,view}:own(~S,~full,~route,~C,Out,State.Scope{columns,resource,handles,tick,prior,view},transform(tick))
def reader(~S:Data,~full:L.Layout,~route:L.Route,~C:Type) -> Reader<State.Scope<S,C,Store.Storage<S,full>>,L.view(full,route)>:
  Reader{get(~S,~full,~route,~C)}
def writer(~S:Data,~full:L.Layout,~route:L.Route,~C:Type) -> Writer<State.Scope<S,C,Store.Storage<S,full>>,L.payload(full,route),L.view(full,route)>:
  Writer{reader(~S,~full,~route,~C),own(~S,~full,~route,~C),own_at(~S,~full,~route,~C)}
