import Base
import ./chunk-column.bend as Col
import ./chunk-query.bend as Q
import ./execution-state.bend as State
import ./execution-declaration.bend as D
import ./execution-projection.bend as Projection
import ./ordinary-declaration.bend as Identity
import ./owner-product.bend as Product
import ./world.bend as W
import ./change-tick.bend as Tick
import ./execution-composer-layout.bend as Layout

type Mode is Data:
  Serial{}
  Parallel{}
type Report<-E:Data> is Data:
  Completed{errors:List<&2,Q.Error<E>>}
  LayoutRefused{}
type Each<-S:Data,-H:Type,-E:Data> is Type:
  Each{run:H -> H & Report<E>}
def Ops(~S:Data,~E:Data,H:Type) -> Type: Each<S,H,E>
def indices(~S:Data,handles:List<&2,W.Handle<S>>) -> List<&2,U32>:
  match handles:
    case []: []
    case handle <> rest: W.handle_index(~S,handle) <> indices(~S,rest)
def report(~E:Data,errors:List<&2,Q.Error<E>>,aligned:Bool) -> Report<E>:
  match aligned:
    case True{}: Completed{errors}
    case False{}: LayoutRefused{}
def returned(~S:Data,~C:Type,~R:Type,~A:Type,~B:Type,~Rest:Type,~E:Data,~lens:Product.Lens<C,Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,Rest>,rest:Rest,resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,result:Q.Run<S,A,B,E>) -> State.Scope<S,C,R> & Report<E>:
  match result:
    case Q.Run{read,write,errors,aligned}: (State.Scope{Product.put_field(~C,~Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,~Rest,lens)(rest,Product.Owner{read,write}),resource,handles,tick},report(~E,errors,aligned))
def taken(~S:Data,~C:Type,~R:Type,~A:Type,~B:Type,~Rest:Type,~V:Data,~E:Data,~lens:Product.Lens<C,Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,Rest>,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,mode:Mode,resource:R,+handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,result:Rest & Product.Owner<Col.Column<S,A>,Col.Column<S,B>>) -> State.Scope<S,C,R> & Report<E>:
  match mode result:
    case Serial{} Tuple{rest,Product.Owner{read,write}}: returned(~S,~C,~R,~A,~B,~Rest,~E,~lens,rest,resource,handles,tick,Q.serial_selected(~S,~A,~B,~V,~E,~project,~body,read,write,0,tick,Q.Selected{indices(~S,handles)}))
    case Parallel{} Tuple{rest,Product.Owner{read,write}}: returned(~S,~C,~R,~A,~B,~Rest,~E,~lens,rest,resource,handles,tick,Q.parallel_selected(~S,~A,~B,~V,~E,~project,~body,read,write,0,tick,Q.Selected{indices(~S,handles)}))
def invoke(~S:Data,~C:Type,~R:Type,~A:Type,~B:Type,~Rest:Type,~V:Data,~E:Data,~lens:Product.Lens<C,Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,Rest>,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,mode:Mode,scope:State.Scope<S,C,R>) -> State.Scope<S,C,R> & Report<E>:
  match scope:
    case State.Scope{store,resource,handles,tick}: taken(~S,~C,~R,~A,~B,~Rest,~V,~E,~lens,~project,~body,mode,resource,handles,tick,Product.get_field(~C,~Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,~Rest,lens)(store))
def declaration(~S:Data,~C:Type,~R:Type,~A:Type,~B:Type,~Rest:Type,~V:Data,~E:Data,~lens:Product.Lens<C,Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,Rest>,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,_:Projection.Affine<A,V,project>,mode:Mode,read:Identity.Declaration<S,A>,write:Identity.Declaration<S,B>) -> D.Declaration<S,C,R,Ops(~S,~E)>:
  D.Declaration{Each{invoke(~S,~C,~R,~A,~B,~Rest,~V,~E,~lens,~project,~body,mode)},[D.Access{Identity.key(~S,~A,read),D.ComponentAccess{},D.Exclusive{},D.ReadOnly{}},D.Access{Identity.key(~S,~B,write),D.ComponentAccess{},D.Exclusive{},D.Writable{}}]}
def each(~S:Data,~H:Type,~E:Data,cap:Each<S,H,E>) -> H -> H & Report<E>:
  match cap:
    case Each{run}: run

def layout_unwrapped(~S:Data,~layout:Layout.Layout,~route:Layout.Route,rest:Layout.subtree_rest(~S,layout,route),selected:Layout.query_pair(~S,~layout,~route)) -> Layout.subtree_rest(~S,layout,route) & Product.Owner<Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}})>,Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})>>:
  match selected:
    case Product.Owner{Layout.ColumnSlot{read},Layout.ColumnSlot{write}}: (rest,Product.Owner{read,write})
def layout_selected(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},result:Layout.subtree_rest(~S,layout,route) & Layout.columns(~S,Layout.subtree(layout,route))) -> Layout.subtree_rest(~S,layout,route) & Product.Owner<Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}})>,Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})>>:
  match result:
    case (rest,selected): layout_unwrapped(~S,~layout,~route,rest,Layout.checked_owner(Layout.columns(~S,Layout.subtree(layout,route)),Layout.query_pair(~S,~layout,~route),shape,selected))
def layout_take(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},owner:C) -> Layout.subtree_rest(~S,layout,route) & Product.Owner<Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}})>,Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})>>:
  layout_selected(~S,~layout,~route,~shape,Layout.subtree_take(~S,layout,route,Layout.checked_owner(C,Layout.columns(~S,layout),same,owner)))
def layout_put(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},rest:Layout.subtree_rest(~S,layout,route),selected:Product.Owner<Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}})>,Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})>>) -> C:
  match selected:
    case Product.Owner{read,write}: Layout.checked_owner(Layout.columns(~S,layout),C,Equal.sym(Type,C,Layout.columns(~S,layout),same),Layout.subtree_put(~S,layout,route,rest,Layout.checked_owner(Layout.query_pair(~S,~layout,~route),Layout.columns(~S,Layout.subtree(layout,route)),Equal.sym(Type,Layout.columns(~S,Layout.subtree(layout,route)),Layout.query_pair(~S,~layout,~route),shape),Product.Owner{Layout.ColumnSlot{read},Layout.ColumnSlot{write}})))
def layout_lens(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type}) -> Product.Lens<C,Product.Owner<Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}})>,Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})>>,Layout.subtree_rest(~S,layout,route)>:
  Product.Lens{layout_take(~S,~C,~layout,~route,~same,~shape),layout_put(~S,~C,~layout,~route,~same,~shape)}
def layout_body(~layout:Layout.Layout,~route:Layout.Route,~E:Data,~body:U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,E>,index:U32,view:Layout.query_view(layout,route),owner:Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})) -> Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}) & Maybe<&2,E>:
  Layout.rewrite(~Layout.subtree(layout,route),~Layout.InRight{Layout.AtLeaf{}},Maybe<&2,E>,body(index,view),owner)
def layout_declaration(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~E:Data,~body:U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,E>,mode:Mode) -> D.Declaration<S,C,R,Ops(~S,~E)>:
  declaration(~S,~C,~R,~Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}}),~Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),~Layout.subtree_rest(~S,layout,route),~Layout.query_view(layout,route),~E,~layout_lens(~S,~C,~layout,~route,~same,~shape),~Layout.read(~Layout.query_input(layout,route),~Layout.query_view(layout,route)),~layout_body(~layout,~route,~E,~body),Projection.trusted_affine(~Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}}),~Layout.query_view(layout,route),~Layout.read(~Layout.query_input(layout,route),~Layout.query_view(layout,route))),mode,Identity.component(~S,~Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}}),Layout.query_read_key(layout,route)),Identity.component(~S,~Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),Layout.query_write_key(layout,route)))
