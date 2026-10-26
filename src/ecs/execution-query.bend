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

# The output type is selected only inside the registered system body. It remains
# abstract to gameplay, including when it is the framework command-buffer owner.
def OutputBody(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~O:Type,~E:Data) -> Type:
  W.Handle<S> -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> O -> Layout.query_output(layout,route) & (O & Maybe<&2,E>)
type OutputEach<-S:Data,-H:Type,-O:Type,-E:Data> is Type:
  OutputEach{run:H -> O -> H & (O & Report<E>)}
def OutputOps(~S:Data,~O:Type,~E:Data,H:Type) -> Type:OutputEach<S,H,O,E>
def handle_choice(~S:Data,handle:W.Handle<S>,rest:Maybe<&2,W.Handle<S>>,same:Bool) -> Maybe<&2,W.Handle<S>>:
  match same:
    case True{}:Some{handle}
    case False{}:rest
def selected_handle(~S:Data,+index:U32,handles:List<&2,W.Handle<S>>) -> Maybe<&2,W.Handle<S>>:
  match handles:
    case []:None{}
    case +handle <> rest:handle_choice(~S,handle,selected_handle(~S,index,rest),U32.is_eq(index,W.handle_index(~S,handle)))
def output_body_found(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~O:Type,~E:Data,~body:OutputBody(~S,~layout,~route,~O,~E),view:Layout.query_view(layout,route),owner:Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),output:O,found:Maybe<&2,W.Handle<S>>) -> Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}) & (O & Maybe<&2,E>):
  match found:
    case None{}:(owner,(output,None{}))
    case Some{handle}:Layout.rewrite(~Layout.subtree(layout,route),~Layout.InRight{Layout.AtLeaf{}},O & Maybe<&2,E>,payload=>body(handle,view,payload,output),owner)
def output_body(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~O:Type,~E:Data,~body:OutputBody(~S,~layout,~route,~O,~E),handles:List<&2,W.Handle<S>>,index:U32,view:Layout.query_view(layout,route),owner:Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),output:O) -> Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}) & (O & Maybe<&2,E>):
  output_body_found(~S,~layout,~route,~O,~E,~body,view,owner,output,selected_handle(~S,index,handles))
def output_returned(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~O:Type,~E:Data,rest:Layout.subtree_rest(~S,layout,route),resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,result:Q.OutputRun<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}}),Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),O,E>) -> State.Scope<S,C,R> & (O & Report<E>):
  match result:
    case Q.OutputRun{read,write,output,errors,aligned}:(State.Scope{layout_put(~S,~C,~layout,~route,~same,~shape,rest,Product.Owner{read,write}),resource,handles,tick},(output,report(~E,errors,aligned)))
def output_taken(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:OutputBody(~S,~layout,~route,~O,~E),output:O,resource:R,+handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,parallel:Bool,result:Layout.subtree_rest(~S,layout,route) & Product.Owner<Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}})>,Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})>>) -> State.Scope<S,C,R> & (O & Report<E>):
  match result:
    case (rest,Product.Owner{read,write}):output_returned(~S,~C,~R,~layout,~route,~same,~shape,~O,~E,rest,resource,handles,tick,Q.with_output(~S,~Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}}),~Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),~O,~Layout.query_view(layout,route),~List<&2,W.Handle<S>>,~E,~Layout.read(~Layout.query_input(layout,route),~Layout.query_view(layout,route)),~output_body(~S,~layout,~route,~O,~E,~body),~split,~merge,handles,read,write,output,0,tick,Q.Selected{indices(~S,handles)},parallel))
def mode_parallel(mode:Mode) -> Bool:
  match mode:
    case Serial{}:False{}
    case Parallel{}:True{}
def output_invoke(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:OutputBody(~S,~layout,~route,~O,~E),mode:Mode,scope:State.Scope<S,C,R>,output:O) -> State.Scope<S,C,R> & (O & Report<E>):
  match scope:
    case State.Scope{store,resource,handles,tick}:output_taken(~S,~C,~R,~layout,~route,~same,~shape,~O,~E,~split,~merge,~body,output,resource,handles,tick,mode_parallel(mode),layout_take(~S,~C,~layout,~route,~same,~shape,store))
def output_declaration(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~O:Type,~E:Data,~split:O -> O & O,~merge:O -> O -> O,~body:OutputBody(~S,~layout,~route,~O,~E),mode:Mode) -> D.Declaration<S,C,R,OutputOps(~S,~O,~E)>:
  D.Declaration{OutputEach{output_invoke(~S,~C,~R,~layout,~route,~same,~shape,~O,~E,~split,~merge,~body,mode)},[D.Access{Layout.query_read_key(layout,route),D.ComponentAccess{},D.Exclusive{},D.ReadOnly{}},D.Access{Layout.query_write_key(layout,route),D.ComponentAccess{},D.Exclusive{},D.Writable{}}]}
def each_output(~S:Data,~H:Type,~O:Type,~E:Data,cap:OutputEach<S,H,O,E>) -> H -> O -> H & (O & Report<E>):
  match cap:
    case OutputEach{run}:run
