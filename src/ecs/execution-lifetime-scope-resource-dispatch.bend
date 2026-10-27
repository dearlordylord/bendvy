import Base
import ./execution-composer-layout.bend as Layout
import ./execution-resource-policy.bend as Policy
import ./execution-lifetime-scope-store.bend as Store
import ./execution-relation-resource-dispatch.bend as Route
import ./execution-relation-resource-publication.bend as Cast
import ./entity-allocator.bend as Allocator
import ./change-tick.bend as Tick
import ./lifecycle.bend as Life

type Outcome<-S:Data> is Data:
  Completed{result:Store.Outcome<S>}
  Undeclared{request:Store.Request<S>}
def Program(~S:Data,~resources:Layout.Layout) -> Type:
  U32 -> U32 -> Allocator.Allocator -> Layout.resources(~S,resources) -> Layout.Route -> Store.Request<S> -> Tick.Tick -> Allocator.Allocator & (Layout.resources(~S,resources) & Outcome<S>)
def empty(~S:Data,~resources:Layout.Layout,_:U32,_:U32,allocator:Allocator.Allocator,owners:Layout.resources(~S,resources),_:Layout.Route,request:Store.Request<S>,_:Tick.Tick) -> Allocator.Allocator & (Layout.resources(~S,resources) & Outcome<S>):
  (allocator,(owners,Undeclared{request}))
def refreshed(~S:Data,~key:String,~origin:Layout.Layout,allocator:Allocator.Allocator,stamp:Life.Stamp,result:Store.Outcome<S>,projected:Store.Store<S> & Store.View<S>) -> Allocator.Allocator & (Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S>,Store.View<S>>,key,origin> & Outcome<S>):
  match projected:
    case (owner,cache):(allocator,(Layout.ResourceSlot{Layout.Viewed{owner,cache},stamp},Completed{result}))
def changed(~S:Data,~key:String,~origin:Layout.Layout,written:Bool,tick:Tick.Tick,stamp:Life.Stamp,cache:Store.View<S>,allocator:Allocator.Allocator,owner:Store.Store<S>,result:Store.Outcome<S>) -> Allocator.Allocator & (Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S>,Store.View<S>>,key,origin> & Outcome<S>):
  match written:
    case False{}:(allocator,(Layout.ResourceSlot{Layout.Viewed{owner,cache},stamp},Completed{result}))
    case True{}:refreshed(~S,~key,~origin,allocator,Life.after_write(True{},True{},stamp,tick),result,Store.project(~S,owner))
def returned(~S:Data,~key:String,~origin:Layout.Layout,tick:Tick.Tick,stamp:Life.Stamp,cache:Store.View<S>,result:Allocator.Allocator & (Store.Store<S> & Store.Outcome<S>)) -> Allocator.Allocator & (Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S>,Store.View<S>>,key,origin> & Outcome<S>):
  match result:
    case (allocator,(owner,Store.Assignment{Store.Assigned{scope,handle}})):changed(~S,~key,~origin,True{},tick,stamp,cache,allocator,owner,Store.Assignment{Store.Assigned{scope,handle}})
    case (allocator,(owner,Store.Assignment{Store.AssignmentRefused{scope,handle,reason}})):changed(~S,~key,~origin,False{},tick,stamp,cache,allocator,owner,Store.Assignment{Store.AssignmentRefused{scope,handle,reason}})
    case (allocator,(owner,Store.Selection{snapshot})):changed(~S,~key,~origin,False{},tick,stamp,cache,allocator,owner,Store.Selection{snapshot})
    case (allocator,(owner,Store.Forgotten{handle})):changed(~S,~key,~origin,True{},tick,stamp,cache,allocator,owner,Store.Forgotten{handle})
    case (allocator,(owner,Store.Refused{request})):changed(~S,~key,~origin,False{},tick,stamp,cache,allocator,owner,Store.Refused{request})
def slot(~S:Data,~key:String,~origin:Layout.Layout,namespace:U32,allocator:Allocator.Allocator,value:Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S>,Store.View<S>>,key,origin>,request:Store.Request<S>,tick:Tick.Tick) -> Allocator.Allocator & (Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S>,Store.View<S>>,key,origin> & Outcome<S>):
  match value:
    case Layout.ResourceSlot{Layout.Viewed{owner,cache},stamp}:returned(~S,~key,~origin,tick,stamp,cache,Store.apply(~S,namespace,allocator,owner,request))
def restored(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~payload:{Layout.payload(resources,route) == Store.Store<S> : Type},~view:{Layout.view(resources,route) == Store.View<S> : Data},rest:Layout.resource_rest(~S,resources,route),result:Allocator.Allocator & (Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S>,Store.View<S>>,Layout.key(resources,route),Layout.origin(resources,route)> & Outcome<S>)) -> Allocator.Allocator & (Layout.resources(~S,resources) & Outcome<S>):
  match result:
    case (allocator,(value,result)):(allocator,(Layout.resource_put(~S,resources,route,rest,Cast.slot(~S,~Layout.key(resources,route),~Layout.origin(resources,route),~Store.Store<S>,~Layout.payload(resources,route),~Store.View<S>,~Layout.view(resources,route),Equal.sym(Type,Layout.payload(resources,route),Store.Store<S>,payload),Equal.sym(Data,Layout.view(resources,route),Store.View<S>,view),value)),result))
def taken(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~payload:{Layout.payload(resources,route) == Store.Store<S> : Type},~view:{Layout.view(resources,route) == Store.View<S> : Data},namespace:U32,allocator:Allocator.Allocator,request:Store.Request<S>,tick:Tick.Tick,result:Layout.resource_rest(~S,resources,route) & Layout.ResourceSlot<S,Layout.stored(resources,route),Layout.key(resources,route),Layout.origin(resources,route)>) -> Allocator.Allocator & (Layout.resources(~S,resources) & Outcome<S>):
  match result:
    case (rest,value):restored(~S,~resources,~route,~payload,~view,rest,slot(~S,~Layout.key(resources,route),~Layout.origin(resources,route),namespace,allocator,Cast.slot(~S,~Layout.key(resources,route),~Layout.origin(resources,route),~Layout.payload(resources,route),~Store.Store<S>,~Layout.view(resources,route),~Store.View<S>,payload,view,value),request,tick))
def namespaced(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~payload:{Layout.payload(resources,route) == Store.Store<S> : Type},~view:{Layout.view(resources,route) == Store.View<S> : Data},same:Bool,namespace:U32,allocator:Allocator.Allocator,owners:Layout.resources(~S,resources),request:Store.Request<S>,tick:Tick.Tick) -> Allocator.Allocator & (Layout.resources(~S,resources) & Outcome<S>):
  match same:
    case False{}:(allocator,(owners,Completed{Store.Refused{request}}))
    case True{}:taken(~S,~resources,~route,~payload,~view,namespace,allocator,request,tick,Layout.resource_take(~S,resources,route,owners))
def selected(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~payload:{Layout.payload(resources,route) == Store.Store<S> : Type},~view:{Layout.view(resources,route) == Store.View<S> : Data},matches:Bool,previous:Program(~S,~resources),+expected:U32,+actual:U32,allocator:Allocator.Allocator,owners:Layout.resources(~S,resources),requested:Layout.Route,request:Store.Request<S>,tick:Tick.Tick) -> Allocator.Allocator & (Layout.resources(~S,resources) & Outcome<S>):
  match matches:
    case False{}:previous(expected,actual,allocator,owners,requested,request,tick)
    case True{}:namespaced(~S,~resources,~route,~payload,~view,U32.is_eq(expected,actual),actual,allocator,owners,request,tick)
def extend(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~payload:{Layout.payload(resources,route) == Store.Store<S> : Type},~view:{Layout.view(resources,route) == Store.View<S> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedLifetimeScope{S} : Policy.Policy},previous:Program(~S,~resources)) -> Program(~S,~resources):
  expected => actual => allocator => owners => +requested => request => tick => selected(~S,~resources,~route,~payload,~view,Route.route_equal(requested,route),previous,expected,actual,allocator,owners,requested,request,tick)
