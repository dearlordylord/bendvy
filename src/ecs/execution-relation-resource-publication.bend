import Base
import ./execution-composer-layout.bend as Layout
import ./execution-relation-store.bend as Store
import ./execution-relation-operation.bend as O
import ./execution-relation-publication.bend as Publication
import ./execution-relation-context.bend as Context
import ./relation-types.bend as T
import ./entity-allocator.bend as Allocator
import ./change-tick.bend as Tick

# These casts use supplied forward schema/payload/view equalities. No layout is
# inferred from P, R, a string key, a cursor, or an entity index.
def slot(~S:Data,~key:String,~origin:Layout.Layout,~FromP:Type,~ToP:Type,~FromV:Data,~ToV:Data,~payload:{FromP == ToP : Type},~view:{FromV == ToV : Data},value:Layout.ResourceSlot<S,Layout.Viewed<FromP,FromV>,key,origin>) -> Layout.ResourceSlot<S,Layout.Viewed<ToP,ToV>,key,origin>:
  %payload : Layout.ResourceSlot<S,Layout.Viewed<_,ToV>,key,origin>
  %view : Layout.ResourceSlot<S,Layout.Viewed<FromP,_>,key,origin>
  value
def restored(~S:Data,~WR:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},~route:Layout.Route,~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},rest:Layout.resource_rest(~S,resources,route),result:Allocator.Allocator & (Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(resources,route),Layout.origin(resources,route)> & Store.Receipt<S>)) -> Allocator.Allocator & (WR & Store.Receipt<S>):
  match result:
    case (allocator,(selected,receipt)):(allocator,(Layout.checked_owner(Layout.resources(~S,resources),WR,Equal.sym(Type,WR,Layout.resources(~S,resources),same),Layout.resource_put(~S,resources,route,rest,slot(~S,~Layout.key(resources,route),~Layout.origin(resources,route),~Store.Store<S,descriptor>,~Layout.payload(resources,route),~Store.View<S,descriptor>,~Layout.view(resources,route),~Equal.sym(Type,Layout.payload(resources,route),Store.Store<S,descriptor>,payload),~Equal.sym(Data,Layout.view(resources,route),Store.View<S,descriptor>,view),selected))),receipt))
def taken(~S:Data,~WR:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},~route:Layout.Route,~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},namespace:U32,allocator:Allocator.Allocator,operation:O.Operation<S>,tick:Tick.Tick,result:Layout.resource_rest(~S,resources,route) & Layout.ResourceSlot<S,Layout.stored(resources,route),Layout.key(resources,route),Layout.origin(resources,route)>) -> Allocator.Allocator & (WR & Store.Receipt<S>):
  match result:
    case (rest,selected):restored(~S,~WR,~resources,~same,~route,~descriptor,~payload,~view,rest,Publication.apply(~S,~descriptor,~Layout.key(resources,route),~Layout.origin(resources,route),namespace,allocator,slot(~S,~Layout.key(resources,route),~Layout.origin(resources,route),~Layout.payload(resources,route),~Store.Store<S,descriptor>,~Layout.view(resources,route),~Store.View<S,descriptor>,~payload,~view,selected),operation,tick))
def checked(~S:Data,~WR:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},allowed:Bool,namespace:U32,allocator:Allocator.Allocator,owners:WR,operation:O.Operation<S>,tick:Tick.Tick) -> Allocator.Allocator & (WR & Store.Receipt<S>):
  match allowed:
    case False{}:(allocator,(owners,Store.Refused{operation,Store.NamespaceMismatch{}}))
    case True{}:taken(~S,~WR,~resources,~same,~route,~descriptor,~payload,~view,namespace,allocator,operation,tick,Layout.resource_take(~S,resources,route,Layout.checked_owner(WR,Layout.resources(~S,resources),same,owners)))
# The canonical command interpreter supplies actual namespace/allocator/resources
# from one World. The closed relation grant must also verify protected policy.
def apply(~S:Data,~WR:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},context:Context.Context<S,WR,resources,same>,+namespace:U32,allocator:Allocator.Allocator,owners:WR,operation:O.Operation<S>,tick:Tick.Tick) -> Allocator.Allocator & (WR & Store.Receipt<S>):
  match context:
    case Context.Context{expected}:checked(~S,~WR,~resources,~same,~route,~valid,~descriptor,~payload,~view,U32.is_eq(expected,namespace),namespace,allocator,owners,operation,tick)
