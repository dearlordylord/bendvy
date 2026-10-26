import Base
import ./execution-state.bend as State
import ./execution-composer-layout.bend as Layout
import ./execution-layout-access.bend as LayoutAccess
import ./execution-declaration.bend as D
import ./execution-access.bend as A
import ./execution-projection.bend as Projection
import ./execution-query.bend as Q

type Book is Type:
  Book{access:List<&2,D.Access>}
def ComponentRead(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{C == Layout.columns(~S,layout) : Type} -> @-valid:{Layout.grant_valid(~layout,~route) == True{} : Bool} -> @-V:Data -> @-project:(Layout.payload(layout,route) -> Layout.payload(layout,route) & V) -> Projection.Affine<Layout.payload(layout,route),V,project> -> B -> B & A.ComponentRead<S,H,V>

def ComponentWrite(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{C == Layout.columns(~S,layout) : Type} -> @-valid:{Layout.grant_valid(~layout,~route) == True{} : Bool} -> @-V:Data -> @-project:(Layout.payload(layout,route) -> Layout.payload(layout,route) & V) -> Projection.Affine<Layout.payload(layout,route),V,project> -> B -> B & A.ComponentWrite<S,H,Layout.payload(layout,route),V>

def ResourceRead(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{R == Layout.resources(~S,layout) : Type} -> @-valid:{Layout.grant_valid(~layout,~route) == True{} : Bool} -> @-V:Data -> @-project:(Layout.payload(layout,route) -> Layout.payload(layout,route) & V) -> Projection.Affine<Layout.payload(layout,route),V,project> -> B -> B & A.ResourceRead<H,V>

def ResourceWrite(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{R == Layout.resources(~S,layout) : Type} -> @-valid:{Layout.grant_valid(~layout,~route) == True{} : Bool} -> @-V:Data -> @-project:(Layout.payload(layout,route) -> Layout.payload(layout,route) & V) -> Projection.Affine<Layout.payload(layout,route),V,project> -> B -> B & A.ResourceWrite<H,Layout.payload(layout,route),V>

def Query(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{C == Layout.columns(~S,layout) : Type} -> @-shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type} -> @-valid:{Layout.query_valid(~layout,~route) == True{} : Bool} -> @-V:Data -> @-Error:Data -> @-project:(Layout.query_input(layout,route) -> Layout.query_input(layout,route) & V) -> @-body:(U32 -> V -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,Error>) -> Projection.Affine<Layout.query_input(layout,route),V,project> -> Q.Mode -> B -> B & Q.Each<S,H,Error>

def Selection(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~Ops:Type -> Type) -> Type:
  @-component_read:ComponentRead(~S,~C,~R,~H,~B) -> @-component_write:ComponentWrite(~S,~C,~R,~H,~B) -> @-resource_read:ResourceRead(~S,~C,~R,~H,~B) -> @-resource_write:ResourceWrite(~S,~C,~R,~H,~B) -> @-query:Query(~S,~C,~R,~H,~B) -> B -> B & Ops(H)
def Builder(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-Ops:(Type -> Type) -> @-selection:Selection(~S,~C,~R,~H,~B,~Ops) -> B -> B & Ops(H)
def Program(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type) -> Type:
  @-H:Type -> @-B:Type -> @-builder:Builder(~S,~C,~R,~H,~B) -> B -> B & Ops(H)
def accumulate(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,book:Book,value:D.Declaration<S,C,R,Ops>) -> Book & Ops(State.Scope<S,C,R>):
  match book value:
    case Book{previous} D.Declaration{caps,access}:(Book{List.append(&2,D.Access,previous,access)},caps)
def component_read_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~V:Data,~project:Layout.payload(layout,route) -> Layout.payload(layout,route) & V,projection:Projection.Affine<Layout.payload(layout,route),V,project>,book:Book) -> Book & A.ComponentRead<S,State.Scope<S,C,R>,V>:
  accumulate(~S,~C,~R,~A.ComponentReads(~S,~V),book,LayoutAccess.component_read(~S,~C,~R,~layout,~route,~same,~valid,~V,~project,projection))

def component_write_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~V:Data,~project:Layout.payload(layout,route) -> Layout.payload(layout,route) & V,projection:Projection.Affine<Layout.payload(layout,route),V,project>,book:Book) -> Book & A.ComponentWrite<S,State.Scope<S,C,R>,Layout.payload(layout,route),V>:
  accumulate(~S,~C,~R,~A.ComponentWrites(~S,~Layout.payload(layout,route),~V),book,LayoutAccess.component_write(~S,~C,~R,~layout,~route,~same,~valid,~V,~project,projection))

def resource_read_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~V:Data,~project:Layout.payload(layout,route) -> Layout.payload(layout,route) & V,projection:Projection.Affine<Layout.payload(layout,route),V,project>,book:Book) -> Book & A.ResourceRead<State.Scope<S,C,R>,V>:
  accumulate(~S,~C,~R,~A.ResourceReads(~V),book,LayoutAccess.resource_read(~S,~C,~R,~layout,~route,~same,~valid,~V,~project,projection))

def resource_write_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~V:Data,~project:Layout.payload(layout,route) -> Layout.payload(layout,route) & V,projection:Projection.Affine<Layout.payload(layout,route),V,project>,book:Book) -> Book & A.ResourceWrite<State.Scope<S,C,R>,Layout.payload(layout,route),V>:
  accumulate(~S,~C,~R,~A.ResourceWrites(~Layout.payload(layout,route),~V),book,LayoutAccess.resource_write(~S,~C,~R,~layout,~route,~same,~valid,~V,~project,projection))

def query_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~V:Data,~Error:Data,~project:Layout.query_input(layout,route) -> Layout.query_input(layout,route) & V,~body:U32 -> V -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,Error>,projection:Projection.Affine<Layout.query_input(layout,route),V,project>,mode:Q.Mode,book:Book) -> Book & Q.Each<S,State.Scope<S,C,R>,Error>:
  accumulate(~S,~C,~R,~Q.Ops(~S,~Error),book,Q.layout_declaration(~S,~C,~R,~layout,~route,~same,~shape,~valid,~V,~Error,~project,~body,projection,mode))

def provision(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,~selection:Selection(~S,~C,~R,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(State.Scope<S,C,R>):
  selection(component_read_build(~S,~C,~R),component_write_build(~S,~C,~R),resource_read_build(~S,~C,~R),resource_write_build(~S,~C,~R),query_build(~S,~C,~R),book)
def compiled(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,result:Book & Ops(State.Scope<S,C,R>)) -> D.Declaration<S,C,R,Ops>:
  match result:
    case (Book{access},caps):D.Declaration{caps,access}
def compile(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,~program:Program(~S,~C,~R,~Ops)) -> D.Declaration<S,C,R,Ops>:
  compiled(~S,~C,~R,~Ops,program(State.Scope<S,C,R>,Book,provision(~S,~C,~R),Book{[]}))
