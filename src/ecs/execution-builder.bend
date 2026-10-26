import Base
import ./execution-lifecycle-access.bend as Life
import ./execution-lifecycle-notices.bend as Notice
import ./execution-state.bend as State
import ./execution-composer-layout.bend as Layout
import ./execution-layout-access.bend as LayoutAccess
import ./execution-declaration.bend as D
import ./execution-access.bend as A
import ./execution-query.bend as Q

type Book is Type:
  Book{access:List<&2,D.Access>}
def ComponentRead(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{C == Layout.columns(~S,layout) : Type} -> @-valid:{Layout.grant_valid(~layout,~route) == True{} : Bool} -> B -> B & A.ComponentRead<S,H,Layout.view(layout,route)>

def ComponentWrite(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{C == Layout.columns(~S,layout) : Type} -> @-valid:{Layout.grant_valid(~layout,~route) == True{} : Bool} -> B -> B & A.ComponentWrite<S,H,Layout.payload(layout,route),Layout.view(layout,route)>

def ResourceRead(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{R == Layout.resources(~S,layout) : Type} -> @-valid:{Layout.grant_valid(~layout,~route) == True{} : Bool} -> B -> B & A.ResourceRead<H,Layout.view(layout,route)>

def ResourceWrite(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{R == Layout.resources(~S,layout) : Type} -> @-valid:{Layout.grant_valid(~layout,~route) == True{} : Bool} -> B -> B & A.ResourceWrite<H,Layout.payload(layout,route),Layout.view(layout,route)>

def BasicQuery(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{C == Layout.columns(~S,layout) : Type} -> @-shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type} -> @-valid:{Layout.query_valid(~layout,~route) == True{} : Bool} -> @-Error:Data -> @-body:(U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,Error>) -> Q.Mode -> B -> B & Q.Each<S,H,Error>

def OutputQuery(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{C == Layout.columns(~S,layout) : Type} -> @-shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type} -> @-valid:{Layout.query_valid(~layout,~route) == True{} : Bool} -> @-O:Type -> @-Error:Data -> @-split:(O -> O & O) -> @-merge:(O -> O -> O) -> @-body:Q.OutputBody(~S,~layout,~route,~O,~Error) -> Q.Mode -> B -> B & Q.OutputEach<S,H,O,Error>
def QuerySelection(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~Ops:Type -> Type) -> Type:
  @-basic:BasicQuery(~S,~C,~R,~H,~B) -> @-output:OutputQuery(~S,~C,~R,~H,~B) -> B -> B & Ops(H)
def Query(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-Ops:(Type -> Type) -> @-selection:QuerySelection(~S,~C,~R,~H,~B,~Ops) -> B -> B & Ops(H)

def basic_query_selection(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~Error:Data,~body:U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,Error>,~mode:Q.Mode,~H:Type,~B:Type,~basic:BasicQuery(~S,~C,~R,~H,~B),~output:OutputQuery(~S,~C,~R,~H,~B),book:B) -> B & Q.Each<S,H,Error>:
  basic(layout,route,same,shape,valid,Error,body,mode,book)
def basic_query(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~Error:Data,~body:U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,Error>,~mode:Q.Mode,~H:Type,~B:Type,~query:Query(~S,~C,~R,~H,~B),book:B) -> B & Q.Each<S,H,Error>:
  query(Q.Ops(~S,~Error),basic_query_selection(~S,~C,~R,~layout,~route,~same,~shape,~valid,~Error,~body,~mode,~H,~B),book)
def output_query_selection(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~O:Type,~Error:Data,~split:O -> O & O,~merge:O -> O -> O,~body:Q.OutputBody(~S,~layout,~route,~O,~Error),~mode:Q.Mode,~H:Type,~B:Type,~basic:BasicQuery(~S,~C,~R,~H,~B),~output:OutputQuery(~S,~C,~R,~H,~B),book:B) -> B & Q.OutputEach<S,H,O,Error>:
  output(layout,route,same,shape,valid,O,Error,split,merge,body,mode,book)
def output_query(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~O:Type,~Error:Data,~split:O -> O & O,~merge:O -> O -> O,~body:Q.OutputBody(~S,~layout,~route,~O,~Error),~mode:Q.Mode,~H:Type,~B:Type,~query:Query(~S,~C,~R,~H,~B),book:B) -> B & Q.OutputEach<S,H,O,Error>:
  query(Q.OutputOps(~S,~O,~Error),output_query_selection(~S,~C,~R,~layout,~route,~same,~shape,~valid,~O,~Error,~split,~merge,~body,~mode,~H,~B),book)

def RemovedLifecycle(~S:Data,~WC:Type,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{WC == Layout.columns(~S,layout) : Type} -> @-valid:{Layout.grant_valid(~layout,~route) == True{} : Bool} -> B -> B & Life.Next<S,H,Layout.origin(layout,route),Notice.Removed{Layout.key(layout,route)}>
def DespawnLifecycle(~S:Data,~WC:Type,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  B -> B & Life.Next<S,H,Layout.EmptyLayout{},Notice.Despawned{}>
def LifecycleSelection(~S:Data,~WC:Type,~C:Type,~R:Type,~H:Type,~B:Type,~Ops:Type -> Type) -> Type:
  @-removed:RemovedLifecycle(~S,~WC,~C,~R,~H,~B) -> @-despawned:DespawnLifecycle(~S,~WC,~C,~R,~H,~B) -> B -> B & Ops(H)
def Lifecycle(~S:Data,~WC:Type,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-Ops:(Type -> Type) -> @-selection:LifecycleSelection(~S,~WC,~C,~R,~H,~B,~Ops) -> B -> B & Ops(H)
def removed_lifecycle_selection(~S:Data,~WC:Type,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~H:Type,~B:Type,~removed:RemovedLifecycle(~S,~WC,~C,~R,~H,~B),~despawned:DespawnLifecycle(~S,~WC,~C,~R,~H,~B),book:B) -> B & Life.Next<S,H,Layout.origin(layout,route),Notice.Removed{Layout.key(layout,route)}>:
  removed(layout,route,same,valid,book)
def removed_lifecycle(~S:Data,~WC:Type,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~H:Type,~B:Type,~lifecycle:Lifecycle(~S,~WC,~C,~R,~H,~B),book:B) -> B & Life.Next<S,H,Layout.origin(layout,route),Notice.Removed{Layout.key(layout,route)}>:
  lifecycle(Life.Ops(~S,~(Layout.origin(layout,route)),~(Notice.Removed{Layout.key(layout,route)})),removed_lifecycle_selection(~S,~WC,~C,~R,~layout,~route,~same,~valid,~H,~B),book)
def despawn_lifecycle_selection(~S:Data,~WC:Type,~C:Type,~R:Type,~H:Type,~B:Type,~removed:RemovedLifecycle(~S,~WC,~C,~R,~H,~B),~despawned:DespawnLifecycle(~S,~WC,~C,~R,~H,~B),book:B) -> B & Life.Next<S,H,Layout.EmptyLayout{},Notice.Despawned{}>:
  despawned(book)
def despawn_lifecycle(~S:Data,~WC:Type,~C:Type,~R:Type,~H:Type,~B:Type,~lifecycle:Lifecycle(~S,~WC,~C,~R,~H,~B),book:B) -> B & Life.Next<S,H,Layout.EmptyLayout{},Notice.Despawned{}>:
  lifecycle(Life.Ops(~S,~(Layout.EmptyLayout{}),~(Notice.Despawned{})),despawn_lifecycle_selection(~S,~WC,~C,~R,~H,~B),book)

def Selection(~S:Data,~WC:Type,~C:Type,~R:Type,~H:Type,~B:Type,~Ops:Type -> Type) -> Type:
  @-component_read:ComponentRead(~S,~C,~R,~H,~B) -> @-component_write:ComponentWrite(~S,~C,~R,~H,~B) -> @-resource_read:ResourceRead(~S,~C,~R,~H,~B) -> @-resource_write:ResourceWrite(~S,~C,~R,~H,~B) -> @-query:Query(~S,~C,~R,~H,~B) -> @-lifecycle:Lifecycle(~S,~WC,~C,~R,~H,~B) -> B -> B & Ops(H)
def Builder(~S:Data,~WC:Type,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-Ops:(Type -> Type) -> @-selection:Selection(~S,~WC,~C,~R,~H,~B,~Ops) -> B -> B & Ops(H)
def Program(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Type -> Type) -> Type:
  @-H:Type -> @-B:Type -> @-builder:Builder(~S,~WC,~C,~R,~H,~B) -> B -> B & Ops(H)
def accumulate(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,book:Book,value:D.Declaration<S,C,R,Ops>) -> Book & Ops(State.Scope<S,C,R>):
  match book value:
    case Book{previous} D.Declaration{caps,access}:(Book{List.append(&2,D.Access,previous,access)},caps)
def component_read_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},book:Book) -> Book & A.ComponentRead<S,State.Scope<S,C,R>,Layout.view(layout,route)>:
  accumulate(~S,~C,~R,~A.ComponentReads(~S,~Layout.view(layout,route)),book,LayoutAccess.component_read(~S,~C,~R,~layout,~route,~same,~valid))

def component_write_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},book:Book) -> Book & A.ComponentWrite<S,State.Scope<S,C,R>,Layout.payload(layout,route),Layout.view(layout,route)>:
  accumulate(~S,~C,~R,~A.ComponentWrites(~S,~Layout.payload(layout,route),~Layout.view(layout,route)),book,LayoutAccess.component_write(~S,~C,~R,~layout,~route,~same,~valid))

def resource_read_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},book:Book) -> Book & A.ResourceRead<State.Scope<S,C,R>,Layout.view(layout,route)>:
  accumulate(~S,~C,~R,~A.ResourceReads(~Layout.view(layout,route)),book,LayoutAccess.resource_read(~S,~C,~R,~layout,~route,~same,~valid))

def resource_write_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},book:Book) -> Book & A.ResourceWrite<State.Scope<S,C,R>,Layout.payload(layout,route),Layout.view(layout,route)>:
  accumulate(~S,~C,~R,~A.ResourceWrites(~Layout.payload(layout,route),~Layout.view(layout,route)),book,LayoutAccess.resource_write(~S,~C,~R,~layout,~route,~same,~valid))

def query_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~Error:Data,~body:U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,Error>,mode:Q.Mode,book:Book) -> Book & Q.Each<S,State.Scope<S,C,R>,Error>:
  accumulate(~S,~C,~R,~Q.Ops(~S,~Error),book,Q.layout_declaration(~S,~C,~R,~layout,~route,~same,~shape,~valid,~Error,~body,mode))

def output_query_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~O:Type,~Error:Data,~split:O -> O & O,~merge:O -> O -> O,~body:Q.OutputBody(~S,~layout,~route,~O,~Error),mode:Q.Mode,book:Book) -> Book & Q.OutputEach<S,State.Scope<S,C,R>,O,Error>:
  accumulate(~S,~C,~R,~Q.OutputOps(~S,~O,~Error),book,Q.output_declaration(~S,~C,~R,~layout,~route,~same,~shape,~valid,~O,~Error,~split,~merge,~body,mode))

def query_provision(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,~selection:QuerySelection(~S,~C,~R,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(State.Scope<S,C,R>):
  selection(query_build(~S,~C,~R),output_query_build(~S,~C,~R),book)
def removed_lifecycle_build(~S:Data,~WC:Type,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},book:Book) -> Book & Life.Next<S,State.Scope<S,C,R>,Layout.origin(layout,route),Notice.Removed{Layout.key(layout,route)}>:
  accumulate(~S,~C,~R,~Life.Ops(~S,~(Layout.origin(layout,route)),~(Notice.Removed{Layout.key(layout,route)})),book,Life.removed(~S,~WC,~C,~R,~layout,~route,~same,~valid))
def despawn_lifecycle_build(~S:Data,~WC:Type,~C:Type,~R:Type,book:Book) -> Book & Life.Next<S,State.Scope<S,C,R>,Layout.EmptyLayout{},Notice.Despawned{}>:
  accumulate(~S,~C,~R,~Life.Ops(~S,~(Layout.EmptyLayout{}),~(Notice.Despawned{})),book,Life.despawned(~S,~C,~R))
def lifecycle_provision(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Type -> Type,~selection:LifecycleSelection(~S,~WC,~C,~R,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(State.Scope<S,C,R>):
  selection(removed_lifecycle_build(~S,~WC,~C,~R),despawn_lifecycle_build(~S,~WC,~C,~R),book)
def provision(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Type -> Type,~selection:Selection(~S,~WC,~C,~R,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(State.Scope<S,C,R>):
  selection(component_read_build(~S,~C,~R),component_write_build(~S,~C,~R),resource_read_build(~S,~C,~R),resource_write_build(~S,~C,~R),query_provision(~S,~C,~R),lifecycle_provision(~S,~WC,~C,~R),book)
def compiled(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,result:Book & Ops(State.Scope<S,C,R>)) -> D.Declaration<S,C,R,Ops>:
  match result:
    case (Book{access},caps):D.Declaration{caps,access}
def compile(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Type -> Type,~program:Program(~S,~WC,~C,~R,~Ops)) -> D.Declaration<S,C,R,Ops>:
  compiled(~S,~C,~R,~Ops,program(State.Scope<S,C,R>,Book,provision(~S,~WC,~C,~R),Book{[]}))
