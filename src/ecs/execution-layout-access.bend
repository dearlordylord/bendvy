import Base
import ./execution-composer-layout.bend as Layout
import ./execution-access.bend as Access
import ./execution-declaration.bend as Declaration
import ./execution-projection.bend as Projection
import ./owner-product.bend as Product
import ./ordinary-declaration.bend as Identity
import ./ordinary-schema.bend as Schema
import ./chunk-column.bend as Column

def column_taken(~S:Data,~layout:Layout.Layout,~route:Layout.Route,result:Layout.column_rest(~S,layout,route) & Layout.ColumnSlot<S,Layout.payload(layout,route),Layout.key(layout,route)>) -> Layout.column_rest(~S,layout,route) & Column.Column<S,Layout.payload(layout,route)>:
  match result:
    case (rest,Layout.ColumnSlot{column}):(rest,column)
def column_take(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},owner:C) -> Layout.column_rest(~S,layout,route) & Column.Column<S,Layout.payload(layout,route)>:
  column_taken(~S,~layout,~route,Layout.column_take(~S,layout,route,Layout.checked_owner(C,Layout.columns(~S,layout),same,owner)))
def column_put(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},rest:Layout.column_rest(~S,layout,route),column:Column.Column<S,Layout.payload(layout,route)>) -> C:
  Layout.checked_owner(Layout.columns(~S,layout),C,Equal.sym(Type,C,Layout.columns(~S,layout),same),Layout.column_put(~S,layout,route,rest,Layout.ColumnSlot{column}))
def column_lens(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type}) -> Product.Lens<C,Column.Column<S,Layout.payload(layout,route)>,Layout.column_rest(~S,layout,route)>:
  Product.Lens{column_take(~S,~C,~layout,~route,~same),column_put(~S,~C,~layout,~route,~same)}
def resource_taken(~S:Data,~layout:Layout.Layout,~route:Layout.Route,result:Layout.resource_rest(~S,layout,route) & Layout.ResourceSlot<S,Layout.payload(layout,route),Layout.key(layout,route)>) -> Layout.resource_rest(~S,layout,route) & Layout.payload(layout,route):
  match result:
    case (rest,Layout.ResourceSlot{owner}):(rest,owner)
def resource_take(~S:Data,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},owner:R) -> Layout.resource_rest(~S,layout,route) & Layout.payload(layout,route):
  resource_taken(~S,~layout,~route,Layout.resource_take(~S,layout,route,Layout.checked_owner(R,Layout.resources(~S,layout),same,owner)))
def resource_put(~S:Data,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},rest:Layout.resource_rest(~S,layout,route),owner:Layout.payload(layout,route)) -> R:
  Layout.checked_owner(Layout.resources(~S,layout),R,Equal.sym(Type,R,Layout.resources(~S,layout),same),Layout.resource_put(~S,layout,route,rest,Layout.ResourceSlot{owner}))
def resource_lens(~S:Data,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type}) -> Product.Lens<R,Layout.payload(layout,route),Layout.resource_rest(~S,layout,route)>:
  Product.Lens{resource_take(~S,~R,~layout,~route,~same),resource_put(~S,~R,~layout,~route,~same)}
def component_read(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~V:Data,~project:Layout.payload(layout,route) -> Layout.payload(layout,route) & V,projection:Projection.Affine<Layout.payload(layout,route),V,project>) -> Declaration.Declaration<S,C,R,Access.ComponentReads(~S,~V)>:
  Access.component_read(~S,~C,~R,~Layout.payload(layout,route),~Layout.column_rest(~S,layout,route),~V,~column_lens(~S,~C,~layout,~route,~same),~project,projection,Identity.component(~S,~Layout.payload(layout,route),Layout.key(layout,route)))
def component_write(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~V:Data,~project:Layout.payload(layout,route) -> Layout.payload(layout,route) & V,projection:Projection.Affine<Layout.payload(layout,route),V,project>) -> Declaration.Declaration<S,C,R,Access.ComponentWrites(~S,~Layout.payload(layout,route),~V)>:
  Access.component_write(~S,~C,~R,~Layout.payload(layout,route),~Layout.column_rest(~S,layout,route),~V,~column_lens(~S,~C,~layout,~route,~same),~project,projection,Identity.component(~S,~Layout.payload(layout,route),Layout.key(layout,route)))
def resource_read(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~V:Data,~project:Layout.payload(layout,route) -> Layout.payload(layout,route) & V,projection:Projection.Affine<Layout.payload(layout,route),V,project>) -> Declaration.Declaration<S,C,R,Access.ResourceReads(~V)>:
  Access.resource_read(~S,~C,~R,~Layout.payload(layout,route),~Layout.resource_rest(~S,layout,route),~V,~resource_lens(~S,~R,~layout,~route,~same),~project,projection,Schema.resource(~S,~Layout.payload(layout,route),Layout.key(layout,route)))
def resource_write(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~V:Data,~project:Layout.payload(layout,route) -> Layout.payload(layout,route) & V,projection:Projection.Affine<Layout.payload(layout,route),V,project>) -> Declaration.Declaration<S,C,R,Access.ResourceWrites(~Layout.payload(layout,route),~V)>:
  Access.resource_write(~S,~C,~R,~Layout.payload(layout,route),~Layout.resource_rest(~S,layout,route),~V,~resource_lens(~S,~R,~layout,~route,~same),~project,projection,Schema.resource(~S,~Layout.payload(layout,route),Layout.key(layout,route)))
