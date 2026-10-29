import Base
import ./change-tick.bend as Tick
import ./lifecycle.bend as Life
import ./execution-state.bend as State
import ./execution-lifecycle-notices.bend as Notice
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
def read_slot_type(-S:Data,layout:Layout.Layout,route:Layout.Route) -> Type:
  Layout.ResourceSlot<S,Layout.stored(layout,route),Layout.key(layout,route),Layout.origin(layout,route)>
def resource_slot(~S:Data,layout:Layout.Layout,route:Layout.Route) -> Type:
  read_slot_type(S,layout,route)
def read_lens_left_taken(-S:Data,-left:Layout.Layout,-right:Layout.Layout,-route:Layout.Route,outer:Layout.resources_generic(S,right),result:Layout.resource_rest_generic(S,left,route) & read_slot_type(S,left,route)) -> Layout.resource_rest_generic(S,Layout.LayoutPair{left,right},Layout.InLeft{route}) & read_slot_type(S,Layout.LayoutPair{left,right},Layout.InLeft{route}):
  match result:
    case (inner,slot):((outer,inner),slot)
def read_lens_left_take(-S:Data,-left:Layout.Layout,-right:Layout.Layout,-route:Layout.Route,take:Layout.resources_generic(S,left) -> Layout.resource_rest_generic(S,left,route) & read_slot_type(S,left,route),owner:Product.Owner<Layout.resources_generic(S,left),Layout.resources_generic(S,right)>) -> Layout.resource_rest_generic(S,Layout.LayoutPair{left,right},Layout.InLeft{route}) & read_slot_type(S,Layout.LayoutPair{left,right},Layout.InLeft{route}):
  match owner:
    case Product.Owner{l,r}:read_lens_left_taken(S,left,right,route,r,take(l))
def read_lens_left_put(-S:Data,-left:Layout.Layout,-right:Layout.Layout,-route:Layout.Route,put:Layout.resource_rest_generic(S,left,route) -> read_slot_type(S,left,route) -> Layout.resources_generic(S,left),rest:Layout.resources_generic(S,right) & Layout.resource_rest_generic(S,left,route),slot:read_slot_type(S,left,route)) -> Product.Owner<Layout.resources_generic(S,left),Layout.resources_generic(S,right)>:
  match rest:
    case (outer,inner):Product.Owner{put(inner,slot),outer}
def read_lens_left(-S:Data,-left:Layout.Layout,-right:Layout.Layout,-route:Layout.Route,lens:Product.Lens<Layout.resources_generic(S,left),read_slot_type(S,left,route),Layout.resource_rest_generic(S,left,route)>) -> Product.Lens<Layout.resources_generic(S,Layout.LayoutPair{left,right}),read_slot_type(S,Layout.LayoutPair{left,right},Layout.InLeft{route}),Layout.resource_rest_generic(S,Layout.LayoutPair{left,right},Layout.InLeft{route})>:
  match lens:
    case Product.Lens{take,put}:Product.Lens{owner => read_lens_left_take(S,left,right,route,take,owner),rest => slot => read_lens_left_put(S,left,right,route,put,rest,slot)}
def read_lens_right_taken(-S:Data,-left:Layout.Layout,-right:Layout.Layout,-route:Layout.Route,outer:Layout.resources_generic(S,left),result:Layout.resource_rest_generic(S,right,route) & read_slot_type(S,right,route)) -> Layout.resource_rest_generic(S,Layout.LayoutPair{left,right},Layout.InRight{route}) & read_slot_type(S,Layout.LayoutPair{left,right},Layout.InRight{route}):
  match result:
    case (inner,slot):((outer,inner),slot)
def read_lens_right_take(-S:Data,-left:Layout.Layout,-right:Layout.Layout,-route:Layout.Route,take:Layout.resources_generic(S,right) -> Layout.resource_rest_generic(S,right,route) & read_slot_type(S,right,route),owner:Product.Owner<Layout.resources_generic(S,left),Layout.resources_generic(S,right)>) -> Layout.resource_rest_generic(S,Layout.LayoutPair{left,right},Layout.InRight{route}) & read_slot_type(S,Layout.LayoutPair{left,right},Layout.InRight{route}):
  match owner:
    case Product.Owner{l,r}:read_lens_right_taken(S,left,right,route,l,take(r))
def read_lens_right_put(-S:Data,-left:Layout.Layout,-right:Layout.Layout,-route:Layout.Route,put:Layout.resource_rest_generic(S,right,route) -> read_slot_type(S,right,route) -> Layout.resources_generic(S,right),rest:Layout.resources_generic(S,left) & Layout.resource_rest_generic(S,right,route),slot:read_slot_type(S,right,route)) -> Product.Owner<Layout.resources_generic(S,left),Layout.resources_generic(S,right)>:
  match rest:
    case (outer,inner):Product.Owner{outer,put(inner,slot)}
def read_lens_right(-S:Data,-left:Layout.Layout,-right:Layout.Layout,-route:Layout.Route,lens:Product.Lens<Layout.resources_generic(S,right),read_slot_type(S,right,route),Layout.resource_rest_generic(S,right,route)>) -> Product.Lens<Layout.resources_generic(S,Layout.LayoutPair{left,right}),read_slot_type(S,Layout.LayoutPair{left,right},Layout.InRight{route}),Layout.resource_rest_generic(S,Layout.LayoutPair{left,right},Layout.InRight{route})>:
  match lens:
    case Product.Lens{take,put}:Product.Lens{owner => read_lens_right_take(S,left,right,route,take,owner),rest => slot => read_lens_right_put(S,left,right,route,put,rest,slot)}
def read_lens_left_description(-S:Data,-left:Layout.Layout,-right:Layout.Layout,-route:Layout.Route,result:String & Product.Lens<Layout.resources_generic(S,left),read_slot_type(S,left,route),Layout.resource_rest_generic(S,left,route)>) -> String & Product.Lens<Layout.resources_generic(S,Layout.LayoutPair{left,right}),read_slot_type(S,Layout.LayoutPair{left,right},Layout.InLeft{route}),Layout.resource_rest_generic(S,Layout.LayoutPair{left,right},Layout.InLeft{route})>:
  match result:
    case (key,lens):(key,read_lens_left(S,left,right,route,lens))
def read_lens_right_description(-S:Data,-left:Layout.Layout,-right:Layout.Layout,-route:Layout.Route,result:String & Product.Lens<Layout.resources_generic(S,right),read_slot_type(S,right,route),Layout.resource_rest_generic(S,right,route)>) -> String & Product.Lens<Layout.resources_generic(S,Layout.LayoutPair{left,right}),read_slot_type(S,Layout.LayoutPair{left,right},Layout.InRight{route}),Layout.resource_rest_generic(S,Layout.LayoutPair{left,right},Layout.InRight{route})>:
  match result:
    case (key,lens):(key,read_lens_right(S,left,right,route,lens))
def read_lens(-S:Data,layout:Layout.Layout,route:Layout.Route) -> String & Product.Lens<Layout.resources_generic(S,layout),read_slot_type(S,layout,route),Layout.resource_rest_generic(S,layout,route)>:
  match layout route:
    case Layout.EmptyLayout{} _ :("",Product.Lens{owner => (owner,Layout.ResourceSlot{Layout.Viewed{Unit{},Unit{}},Layout.unknown_stamp()}),rest => slot => rest})
    case Layout.LayoutLeaf{P,V,_,key,policy} Layout.AtLeaf{}:(key,Product.Lens{owner => (Unit{},owner),rest => slot => slot})
    case Layout.ClassifiedLayoutLeaf{P,V,_,key,persistence,policy} Layout.AtLeaf{}:(key,Product.Lens{owner => (Unit{},owner),rest => slot => slot})
    case Layout.LayoutLeaf{P,V,_,key,policy} Layout.InLeft{_}:("",Product.Lens{owner => (owner,Layout.ResourceSlot{Layout.Viewed{Unit{},Unit{}},Layout.unknown_stamp()}),rest => slot => rest})
    case Layout.ClassifiedLayoutLeaf{P,V,_,key,persistence,policy} Layout.InLeft{_}:("",Product.Lens{owner => (owner,Layout.ResourceSlot{Layout.Viewed{Unit{},Unit{}},Layout.unknown_stamp()}),rest => slot => rest})
    case Layout.LayoutLeaf{P,V,_,key,policy} Layout.InRight{_}:("",Product.Lens{owner => (owner,Layout.ResourceSlot{Layout.Viewed{Unit{},Unit{}},Layout.unknown_stamp()}),rest => slot => rest})
    case Layout.ClassifiedLayoutLeaf{P,V,_,key,persistence,policy} Layout.InRight{_}:("",Product.Lens{owner => (owner,Layout.ResourceSlot{Layout.Viewed{Unit{},Unit{}},Layout.unknown_stamp()}),rest => slot => rest})
    case Layout.LayoutPair{left,right} Layout.AtLeaf{}:("",Product.Lens{owner => (owner,Layout.ResourceSlot{Layout.Viewed{Unit{},Unit{}},Layout.unknown_stamp()}),rest => slot => rest})
    case Layout.LayoutPair{left,right} Layout.InLeft{path}:read_lens_left_description(S,left,right,path,read_lens(S,left,path))
    case Layout.LayoutPair{left,right} Layout.InRight{path}:read_lens_right_description(S,left,right,path,read_lens(S,right,path))
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
def read_scope_returned(-S:Data,-C:Type,-R:Type,-P:Type,-Rest:Type,-V:Data,put:Rest -> P -> R,store:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,rest:Rest,notices:Notice.View<S>,result:P & V) -> State.Scope<S,C,R> & V:
  match result:
    case (part,view):(State.Scope{store,put(rest,part),handles,tick,prior,notices},view)
def read_scope_taken(-S:Data,-C:Type,-R:Type,-P:Type,-Rest:Type,-V:Data,put:Rest -> P -> R,project:P -> P & V,store:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,notices:Notice.View<S>,result:Rest & P) -> State.Scope<S,C,R> & V:
  match result:
    case (rest,part):read_scope_returned(S,C,R,P,Rest,V,put,store,handles,tick,prior,rest,notices,project(part))
def read_scope(-S:Data,-C:Type,-R:Type,-P:Type,-Rest:Type,-V:Data,lens:Product.Lens<R,P,Rest>,project:P -> P & V,scope:State.Scope<S,C,R>) -> State.Scope<S,C,R> & V:
  match lens scope:
    case Product.Lens{take,put} State.Scope{store,resource,handles,tick,prior,notices}:read_scope_taken(S,C,R,P,Rest,V,put,project,store,handles,tick,prior,notices,take(resource))
def read_slot_view(-S:Data,-layout:Layout.Layout,-route:Layout.Route,value:read_slot_type(S,layout,route)) -> read_slot_type(S,layout,route) & Layout.view(layout,route):
  match value:
    case Layout.ResourceSlot{Layout.Viewed{owner,+view},stamp}:(Layout.ResourceSlot{Layout.Viewed{owner,view},stamp},view)
def read_checked_lens(-S:Data,-R:Type,-layout:Layout.Layout,-route:Layout.Route,same:{R == Layout.resources_generic(S,layout) : Type},lens:Product.Lens<Layout.resources_generic(S,layout),read_slot_type(S,layout,route),Layout.resource_rest_generic(S,layout,route)>) -> Product.Lens<R,read_slot_type(S,layout,route),Layout.resource_rest_generic(S,layout,route)>:
  %Equal.sym(Type,R,Layout.resources_generic(S,layout),same) : Product.Lens<_,read_slot_type(S,layout,route),Layout.resource_rest_generic(S,layout,route)>
  lens
def resource_read_compiled(-S:Data,-C:Type,-R:Type,-layout:Layout.Layout,-route:Layout.Route,same:{R == Layout.resources_generic(S,layout) : Type},lens:Product.Lens<Layout.resources_generic(S,layout),read_slot_type(S,layout,route),Layout.resource_rest_generic(S,layout,route)>) -> Access.ResourceRead<State.Scope<S,C,R>,Layout.view(layout,route)>:
  Access.ResourceRead{scope => read_scope(S,C,R,read_slot_type(S,layout,route),Layout.resource_rest_generic(S,layout,route),Layout.view(layout,route),read_checked_lens(S,R,layout,route,same,lens),slot => read_slot_view(S,layout,route,slot),scope)}
def resource_read_description(-S:Data,-C:Type,-R:Type,-layout:Layout.Layout,-route:Layout.Route,same:{R == Layout.resources_generic(S,layout) : Type},result:String & Product.Lens<Layout.resources_generic(S,layout),read_slot_type(S,layout,route),Layout.resource_rest_generic(S,layout,route)>) -> String & Access.ResourceRead<State.Scope<S,C,R>,Layout.view(layout,route)>:
  match result:
    case (key,lens):(key,resource_read_compiled(S,C,R,layout,route,same,lens))
def resource_read(-S:Data,-C:Type,-R:Type,layout:Layout.Layout,route:Layout.Route,same:{R == Layout.resources_generic(S,layout) : Type},valid:{Bool.and(Layout.unique(layout),Layout.valid(layout,route)) == True{} : Bool}) -> String & Access.ResourceRead<State.Scope<S,C,R>,Layout.view(layout,route)>:
  resource_read_description(S,C,R,layout,route,same,read_lens(S,layout,route))

def resource_write(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.resource_write_valid(~layout,~route) == True{} : Bool}) -> Declaration.Declaration<S,C,R,Access.ResourceWrites(~Layout.payload(layout,route),~Layout.view(layout,route))>:
  Declaration.Declaration{Access.ResourceWrite{Access.resource_get(~S,~C,~R,~resource_slot(~S,layout,route),~Layout.resource_rest(~S,layout,route),~Layout.view(layout,route),~resource_lens(~S,~R,~layout,~route,~same),~resource_view(~S,~layout,~route)),resource_modify(~S,~C,~R,~layout,~route,~same),resource_own(~S,~C,~R,~layout,~route,~same),resource_own_at(~S,~C,~R,~layout,~route,~same)},[Declaration.Access{Layout.key(layout,route),Declaration.ResourceAccess{},Declaration.Exclusive{},Declaration.Writable{}}]}
