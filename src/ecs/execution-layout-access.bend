import Base
import ./change-tick.bend as Tick
import ./lifecycle.bend as Life
import ./execution-state.bend as State
import ./world.bend as W
import ./execution-composer-layout.bend as Layout
import ./execution-access.bend as Access
import ./execution-declaration.bend as Declaration
import ./execution-projection.bend as Projection
import ./owner-product.bend as Product
import ./ordinary-declaration.bend as Identity
import ./ordinary-schema.bend as Schema
import ./chunk-column.bend as Column

def column_taken(~S:Data,~layout:Layout.Layout,~route:Layout.Route,result:Layout.column_rest(~S,layout,route) & Layout.ColumnSlot<S,Layout.stored(layout,route),Layout.key(layout,route),Layout.origin(layout,route)>) -> Layout.column_rest(~S,layout,route) & Column.Column<S,Layout.stored(layout,route)>:
  match result:
    case (rest,Layout.ColumnSlot{column}):(rest,column)
def column_take(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},owner:C) -> Layout.column_rest(~S,layout,route) & Column.Column<S,Layout.stored(layout,route)>:
  column_taken(~S,~layout,~route,Layout.column_take(~S,layout,route,Layout.checked_owner(C,Layout.columns(~S,layout),same,owner)))
def column_put(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},rest:Layout.column_rest(~S,layout,route),column:Column.Column<S,Layout.stored(layout,route)>) -> C:
  Layout.checked_owner(Layout.columns(~S,layout),C,Equal.sym(Type,C,Layout.columns(~S,layout),same),Layout.column_put(~S,layout,route,rest,Layout.ColumnSlot{column}))
def column_lens(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type}) -> Product.Lens<C,Column.Column<S,Layout.stored(layout,route)>,Layout.column_rest(~S,layout,route)>:
  Product.Lens{column_take(~S,~C,~layout,~route,~same),column_put(~S,~C,~layout,~route,~same)}
def resource_slot(~S:Data,layout:Layout.Layout,route:Layout.Route) -> Type:
  Layout.ResourceSlot<S,Layout.stored(layout,route),Layout.key(layout,route),Layout.origin(layout,route)>
def resource_lens(~S:Data,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type}) -> Product.Lens<R,resource_slot(~S,layout,route),Layout.resource_rest(~S,layout,route)>:
  Product.Lens{owner => Layout.resource_take(~S,layout,route,Layout.checked_owner(R,Layout.resources(~S,layout),same,owner)),rest => slot => Layout.checked_owner(Layout.resources(~S,layout),R,Equal.sym(Type,R,Layout.resources(~S,layout),same),Layout.resource_put(~S,layout,route,rest,slot))}
def resource_view(~S:Data,~layout:Layout.Layout,~route:Layout.Route,value:resource_slot(~S,layout,route)) -> resource_slot(~S,layout,route) & Layout.view(layout,route):
  match value:
    case Layout.ResourceSlot{Layout.Viewed{owner,+view},stamp}:(Layout.ResourceSlot{Layout.Viewed{owner,view},stamp},view)
def resource_rewritten(~S:Data,~layout:Layout.Layout,~route:Layout.Route,-Out:Type,tick:Tick.Tick,stamp:Life.Stamp,result:Layout.stored(layout,route) & Out) -> resource_slot(~S,layout,route) & Out:
  match result:
    case (owner,out):(Layout.ResourceSlot{owner,Life.after_write(True{},True{},stamp,tick)},out)
def resource_rewrite(~S:Data,~layout:Layout.Layout,~route:Layout.Route,-Out:Type,tick:Tick.Tick,transform:Layout.payload(layout,route) -> Layout.payload(layout,route) & Out,value:resource_slot(~S,layout,route)) -> resource_slot(~S,layout,route) & Out:
  match value:
    case Layout.ResourceSlot{owner,stamp}:resource_rewritten(~S,~layout,~route,Out,tick,stamp,Layout.rewrite(~layout,~route,Out,transform,owner))
def component_read(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool}) -> Declaration.Declaration<S,C,R,Access.ComponentReads(~S,~Layout.view(layout,route))>:
  Declaration.Declaration{Access.ComponentRead{scope=>handle=>Access.component_get(~S,~C,~R,~Layout.stored(layout,route),~Layout.column_rest(~S,layout,route),~Layout.view(layout,route),~column_lens(~S,~C,~layout,~route,~same),~Layout.read(~Layout.payload(layout,route),~Layout.view(layout,route)),scope,handle)},[Declaration.Access{Layout.key(layout,route),Declaration.ComponentAccess{},Declaration.Exclusive{},Declaration.ReadOnly{}}]}
def component_modify(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},transform:Layout.payload(layout,route) -> Layout.payload(layout,route) & Layout.view(layout,route)) -> State.Scope<S,C,R> -> W.Handle<S> -> State.Scope<S,C,R> & Maybe<&2,Layout.view(layout,route)>:
  Access.component_modify_once(~S,~C,~R,~Layout.stored(layout,route),~Layout.column_rest(~S,layout,route),~Layout.view(layout,route),~column_lens(~S,~C,~layout,~route,~same),Layout.rewrite(~layout,~route,Layout.view(layout,route),transform))
def component_write(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool}) -> Declaration.Declaration<S,C,R,Access.ComponentWrites(~S,~Layout.payload(layout,route),~Layout.view(layout,route))>:
  Declaration.Declaration{Access.ComponentWrite{scope=>handle=>Access.component_get(~S,~C,~R,~Layout.stored(layout,route),~Layout.column_rest(~S,layout,route),~Layout.view(layout,route),~column_lens(~S,~C,~layout,~route,~same),~Layout.read(~Layout.payload(layout,route),~Layout.view(layout,route)),scope,handle),component_modify(~S,~C,~R,~layout,~route,~same),scope=>handle=>Access.component_checked_get(~S,~C,~R,~Layout.stored(layout,route),~Layout.column_rest(~S,layout,route),~Layout.view(layout,route),~column_lens(~S,~C,~layout,~route,~same),~Layout.read(~Layout.payload(layout,route),~Layout.view(layout,route)),scope,handle)},[Declaration.Access{Layout.key(layout,route),Declaration.ComponentAccess{},Declaration.Exclusive{},Declaration.Writable{}}]}
def resource_modify(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},transform:Layout.payload(layout,route) -> Layout.payload(layout,route) & Layout.view(layout,route)) -> State.Scope<S,C,R> -> State.Scope<S,C,R> & Layout.view(layout,route):
  Access.resource_own_at(~S,~C,~R,~resource_slot(~S,layout,route),~Layout.resource_rest(~S,layout,route),~resource_lens(~S,~R,~layout,~route,~same),Layout.view(layout,route),tick => resource_rewrite(~S,~layout,~route,Layout.view(layout,route),tick,transform))
def resource_own(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},-Out:Type,transform:Layout.payload(layout,route) -> Layout.payload(layout,route) & Out) -> State.Scope<S,C,R> -> State.Scope<S,C,R> & Out:
  Access.resource_own_at(~S,~C,~R,~resource_slot(~S,layout,route),~Layout.resource_rest(~S,layout,route),~resource_lens(~S,~R,~layout,~route,~same),Out,tick => resource_rewrite(~S,~layout,~route,Out,tick,transform))
def resource_own_at(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},-Out:Type,transform:Tick.Tick -> Layout.payload(layout,route) -> Layout.payload(layout,route) & Out) -> State.Scope<S,C,R> -> State.Scope<S,C,R> & Out:
  Access.resource_own_at(~S,~C,~R,~resource_slot(~S,layout,route),~Layout.resource_rest(~S,layout,route),~resource_lens(~S,~R,~layout,~route,~same),Out,+tick => resource_rewrite(~S,~layout,~route,Out,tick,transform(tick)))
def resource_read(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool}) -> Declaration.Declaration<S,C,R,Access.ResourceReads(~Layout.view(layout,route))>:
  Declaration.Declaration{Access.ResourceRead{Access.resource_get(~S,~C,~R,~resource_slot(~S,layout,route),~Layout.resource_rest(~S,layout,route),~Layout.view(layout,route),~resource_lens(~S,~R,~layout,~route,~same),~resource_view(~S,~layout,~route))},[Declaration.Access{Layout.key(layout,route),Declaration.ResourceAccess{},Declaration.Exclusive{},Declaration.ReadOnly{}}]}
def resource_write(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool}) -> Declaration.Declaration<S,C,R,Access.ResourceWrites(~Layout.payload(layout,route),~Layout.view(layout,route))>:
  Declaration.Declaration{Access.ResourceWrite{Access.resource_get(~S,~C,~R,~resource_slot(~S,layout,route),~Layout.resource_rest(~S,layout,route),~Layout.view(layout,route),~resource_lens(~S,~R,~layout,~route,~same),~resource_view(~S,~layout,~route)),resource_modify(~S,~C,~R,~layout,~route,~same),resource_own(~S,~C,~R,~layout,~route,~same),resource_own_at(~S,~C,~R,~layout,~route,~same)},[Declaration.Access{Layout.key(layout,route),Declaration.ResourceAccess{},Declaration.Exclusive{},Declaration.Writable{}}]}
