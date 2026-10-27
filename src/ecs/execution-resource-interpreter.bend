import Base
import ./execution-resource-store.bend as Store
import ./execution-resource-access.bend as A
import ./execution-composer-layout.bend as L
import ./execution-layout-access.bend as Access
import ./execution-state.bend as State
import ./execution-lifecycle-notices.bend as Notice
import ./world.bend as W
import ./change-tick.bend as Tick

type Frame<-S:Data,-full:L.Layout,-route:L.Route,-C:Type> is Type:
  Frame{rest:L.resource_rest(~S,full,route),columns:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>}
def scope(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,frame:Frame<S,full,route,C>,slot:Access.resource_slot(~S,full,route)) -> State.Scope<S,C,L.resources(~S,full)>:
  match frame:
    case Frame{rest,columns,handles,tick,prior,view}:State.Scope{columns,L.resource_put(~S,full,route,rest,slot),handles,tick,prior,view}
def read_taken(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,columns:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,result:L.resource_rest(~S,full,route) & Access.resource_slot(~S,full,route)) -> State.Scope<S,C,L.resources(~S,full)> & Store.Lookup<L.view(full,route)>:
  match result:
    case (rest,L.ResourceSlot{L.Viewed{owner,+cache},+stamp}):(scope(~S,~full,~route,~C,Frame{rest,columns,handles,tick,prior,view},L.ResourceSlot{L.Viewed{owner,cache},stamp}),Store.Viewed{cache,stamp})
def whole_get_checked(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,source:State.Scope<S,C,L.resources(~S,full)>,valid:Bool) -> State.Scope<S,C,L.resources(~S,full)> & Store.Lookup<L.view(full,route)>:
  match source valid:
    case source False{}:(source,Store.LookupRefused{})
    case State.Scope{columns,resources,handles,tick,prior,view} True{}:read_taken(~S,~full,~route,~C,columns,handles,tick,prior,view,L.resource_take(~S,full,route,resources))
def whole_get(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,source:State.Scope<S,C,L.resources(~S,full)>) -> State.Scope<S,C,L.resources(~S,full)> & Store.Lookup<L.view(full,route)>:
  whole_get_checked(~S,~full,~route,~C,source,L.valid(full,route))
def write_returned(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,-Out:Type,frame:Frame<S,full,route,C>,result:Access.resource_slot(~S,full,route) & Out) -> State.Scope<S,C,L.resources(~S,full)> & Store.Edit<L.payload(full,route),Out>:
  match result:
    case (slot,out):(scope(~S,~full,~route,~C,frame,slot),Store.Edited{out})
def write_taken(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,-Out:Type,columns:C,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,transform:L.payload(full,route) -> L.payload(full,route) & Out,result:L.resource_rest(~S,full,route) & Access.resource_slot(~S,full,route)) -> State.Scope<S,C,L.resources(~S,full)> & Store.Edit<L.payload(full,route),Out>:
  match result:
    case (rest,slot):write_returned(~S,~full,~route,~C,Out,Frame{rest,columns,handles,tick,prior,view},Access.resource_rewrite(~S,~full,~route,Out,tick,transform,slot))
def whole_own_checked(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,-Out:Type,source:State.Scope<S,C,L.resources(~S,full)>,transform:L.payload(full,route) -> L.payload(full,route) & Out,valid:Bool) -> State.Scope<S,C,L.resources(~S,full)> & Store.Edit<L.payload(full,route),Out>:
  match source valid:
    case source False{}:(source,Store.Unchanged{transform})
    case State.Scope{columns,resources,handles,tick,prior,view} True{}:write_taken(~S,~full,~route,~C,Out,columns,handles,tick,prior,view,transform,L.resource_take(~S,full,route,resources))
def whole_own(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,-Out:Type,source:State.Scope<S,C,L.resources(~S,full)>,transform:L.payload(full,route) -> L.payload(full,route) & Out) -> State.Scope<S,C,L.resources(~S,full)> & Store.Edit<L.payload(full,route),Out>:
  whole_own_checked(~S,~full,~route,~C,Out,source,transform,L.valid(full,route))
def whole_own_at(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,-Out:Type,source:State.Scope<S,C,L.resources(~S,full)>,transform:Tick.Tick -> L.payload(full,route) -> L.payload(full,route) & Out) -> State.Scope<S,C,L.resources(~S,full)> & Store.Edit<L.payload(full,route),Out>:
  match source:
    case State.Scope{columns,resources,handles,+tick,prior,view}:whole_own(~S,~full,~route,~C,Out,State.Scope{columns,resources,handles,tick,prior,view},transform(tick))
def whole_reader(~S:Data,~C:Type,~full:L.Layout,~route:L.Route) -> A.Reader<State.Scope<S,C,L.resources(~S,full)>,L.view(full,route)>:
  A.Reader{whole_get(~S,~full,~route,~C)}
def whole_writer(~S:Data,~C:Type,~full:L.Layout,~route:L.Route) -> A.Writer<State.Scope<S,C,L.resources(~S,full)>,L.payload(full,route),L.view(full,route)>:
  A.Writer{whole_reader(~S,~C,~full,~route),whole_own(~S,~full,~route,~C),whole_own_at(~S,~full,~route,~C)}
def read_caps(~S:Data,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,model:Store.Model,local:{R == Store.owner(~S,full,model) : Type}) -> A.Reader<State.Scope<S,C,R>,L.view(full,route)>:
  match model:
    case Store.Whole{}:%Equal.sym(Type,R,L.resources(~S,full),local) : A.Reader<State.Scope<S,C,_>,L.view(full,route)>
      whole_reader(~S,~C,~full,~route)
    case Store.Sparse{}:%Equal.sym(Type,R,Store.Storage<S,full>,local) : A.Reader<State.Scope<S,C,_>,L.view(full,route)>
      A.reader(~S,~full,~route,~C)
def write_caps(~S:Data,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,model:Store.Model,local:{R == Store.owner(~S,full,model) : Type}) -> A.Writer<State.Scope<S,C,R>,L.payload(full,route),L.view(full,route)>:
  match model:
    case Store.Whole{}:%Equal.sym(Type,R,L.resources(~S,full),local) : A.Writer<State.Scope<S,C,_>,L.payload(full,route),L.view(full,route)>
      whole_writer(~S,~C,~full,~route)
    case Store.Sparse{}:%Equal.sym(Type,R,Store.Storage<S,full>,local) : A.Writer<State.Scope<S,C,_>,L.payload(full,route),L.view(full,route)>
      A.writer(~S,~full,~route,~C)
# Closed ordinary framework dictionary; callers select no independent grants.
def read_dictionary(~S:Data,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,~valid:{L.grant_valid(~full,~route) == True{} : Bool},~model:Store.Model,~local:{R == Store.owner(~S,full,model) : Type}) -> A.Reader<State.Scope<S,C,R>,L.view(full,route)>:
  read_caps(~S,~C,~R,~full,~route,model,local)
def write_dictionary(~S:Data,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,~valid:{L.grant_valid(~full,~route) == True{} : Bool},~model:Store.Model,~local:{R == Store.owner(~S,full,model) : Type}) -> A.Writer<State.Scope<S,C,R>,L.payload(full,route),L.view(full,route)>:
  write_caps(~S,~C,~R,~full,~route,model,local)
