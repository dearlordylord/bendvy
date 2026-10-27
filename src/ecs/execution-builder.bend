import Base
import ./execution-relation-failure-provider.bend as FailureProvider
import ./execution-relation-failure-access.bend as FailureAccess
import ./execution-relation-store.bend as RelationStore
import ./execution-resource-policy.bend as Policy
import ./relation-types.bend as T
import ./execution-reservation-task.bend as Effect
import ./execution-lifecycle-access.bend as Life
import ./execution-lifecycle-notices.bend as Notice
import ./execution-state.bend as State
import ./execution-composer-layout.bend as Layout
import ./execution-layout-access.bend as LayoutAccess
import ./execution-declaration.bend as D
import ./execution-access.bend as A
import ./execution-query.bend as Q
import ./execution-query-recipe.bend as Recipe
import ./execution-query-matches.bend as Match
import ./execution-query-store.bend as Store
import ./execution-resource-recipe.bend as Resources
import ./execution-resource-store.bend as ResourceStore
import ./execution-resource-access.bend as ResourceAccess

type Book is Type:
  Book{access:List<&2,D.Access>,queryRecipes:List<&2,Recipe.Entry>,resourceRecipes:List<&2,Resources.Entry>,supported:Bool}
def ComponentRead(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{C == Layout.columns(~S,layout) : Type} -> @-valid:{Layout.grant_valid(~layout,~route) == True{} : Bool} -> B -> B & A.ComponentRead<S,H,Layout.view(layout,route)>

def ComponentWrite(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{C == Layout.columns(~S,layout) : Type} -> @-valid:{Layout.grant_valid(~layout,~route) == True{} : Bool} -> B -> B & A.ComponentWrite<S,H,Layout.payload(layout,route),Layout.view(layout,route)>

def BasicResourceRead(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @layout:Layout.Layout -> @+route:Layout.Route -> @same:{R == Layout.resources(~S,layout) : Type} -> @valid:{Bool.and(Layout.unique(layout),Layout.valid(layout,route)) == True{} : Bool} -> B -> B & A.ResourceRead<H,Layout.view(layout,route)>

def BasicResourceWrite(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{R == Layout.resources(~S,layout) : Type} -> @-valid:{Layout.resource_write_valid(~layout,~route) == True{} : Bool} -> B -> B & A.ResourceWrite<H,Layout.payload(layout,route),Layout.view(layout,route)>

def GeneralResourceRead(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-full:Layout.Layout -> @-route:Layout.Route -> @-valid:{Layout.grant_valid(~full,~route) == True{} : Bool} -> @-model:ResourceStore.Model -> @-local:{R == ResourceStore.owner(~S,full,model) : Type} -> B -> B & ResourceAccess.Reader<H,Layout.view(full,route)>
def FailureRead(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-full:Layout.Layout -> @-route:Layout.Route -> @-valid:{Layout.grant_valid(~full,~route) == True{} : Bool} -> @-descriptor:T.Descriptor<S> -> @-payload:{Layout.payload(full,route) == RelationStore.Store<S,descriptor> : Type} -> @-view:{Layout.view(full,route) == RelationStore.View<S,descriptor> : Data} -> @-protected:{Layout.policy(full,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy} -> @-local:Layout.Layout -> @-selected:Layout.Route -> @-same:{R == Layout.resources(~S,local) : Type} -> @-localvalid:{Layout.grant_valid(~local,~selected) == True{} : Bool} -> @-slot:{LayoutAccess.resource_slot(~S,local,selected) == FailureProvider.Slot(~S,~full,~route,~descriptor) : Type} -> B -> B & FailureAccess.Read<S,descriptor,full,route,H>
def GeneralFailureRead(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-full:Layout.Layout -> @-route:Layout.Route -> @-valid:{Layout.grant_valid(~full,~route) == True{} : Bool} -> @-descriptor:T.Descriptor<S> -> @-payload:{Layout.payload(full,route) == RelationStore.Store<S,descriptor> : Type} -> @-view:{Layout.view(full,route) == RelationStore.View<S,descriptor> : Data} -> @-protected:{Layout.policy(full,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy} -> @-model:ResourceStore.Model -> @-local:{R == ResourceStore.owner(~S,full,model) : Type} -> B -> B & FailureAccess.Read<S,descriptor,full,route,H>
def ResourceReadSelection(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~Ops:Type -> Type) -> Type:
  @-basic:BasicResourceRead(~S,~C,~R,~H,~B) -> @-general:GeneralResourceRead(~S,~C,~R,~H,~B) -> @-failure:FailureRead(~S,~C,~R,~H,~B) -> @-general_failure:GeneralFailureRead(~S,~C,~R,~H,~B) -> B -> B & Ops(H)
def ResourceRead(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-Ops:(Type -> Type) -> @-selection:ResourceReadSelection(~S,~C,~R,~H,~B,~Ops) -> B -> B & Ops(H)
def basic_resource_read_selection(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~basic:BasicResourceRead(~S,~C,~R,~H,~B),~general:GeneralResourceRead(~S,~C,~R,~H,~B),~failure:FailureRead(~S,~C,~R,~H,~B),~general_failure:GeneralFailureRead(~S,~C,~R,~H,~B),book:B) -> B & A.ResourceRead<H,Layout.view(layout,route)>:
  basic(layout,route,same,valid,book)
def basic_resource_read(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~resource:ResourceRead(~S,~C,~R,~H,~B),book:B) -> B & A.ResourceRead<H,Layout.view(layout,route)>:
  resource(A.ResourceReads(~Layout.view(layout,route)),basic => general => failure => general_failure => selected => basic(layout,route,same,valid,selected),book)
def GeneralResourceWrite(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-full:Layout.Layout -> @-route:Layout.Route -> @-valid:{Layout.resource_write_valid(~full,~route) == True{} : Bool} -> @-model:ResourceStore.Model -> @-local:{R == ResourceStore.owner(~S,full,model) : Type} -> B -> B & ResourceAccess.Writer<H,Layout.payload(full,route),Layout.view(full,route)>
def ResourceWriteSelection(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~Ops:Type -> Type) -> Type:
  @-basic:BasicResourceWrite(~S,~C,~R,~H,~B) -> @-general:GeneralResourceWrite(~S,~C,~R,~H,~B) -> B -> B & Ops(H)
def ResourceWrite(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-Ops:(Type -> Type) -> @-selection:ResourceWriteSelection(~S,~C,~R,~H,~B,~Ops) -> B -> B & Ops(H)
def basic_resource_write_selection(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.resource_write_valid(~layout,~route) == True{} : Bool},~basic:BasicResourceWrite(~S,~C,~R,~H,~B),~general:GeneralResourceWrite(~S,~C,~R,~H,~B),book:B) -> B & A.ResourceWrite<H,Layout.payload(layout,route),Layout.view(layout,route)>:
  basic(layout,route,same,valid,book)
def basic_resource_write(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.resource_write_valid(~layout,~route) == True{} : Bool},~resource:ResourceWrite(~S,~C,~R,~H,~B),book:B) -> B & A.ResourceWrite<H,Layout.payload(layout,route),Layout.view(layout,route)>:
  resource(A.ResourceWrites(~Layout.payload(layout,route),~Layout.view(layout,route)),basic_resource_write_selection(~S,~C,~R,~H,~B,~layout,~route,~same,~valid),book)

def BasicQuery(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{C == Layout.columns(~S,layout) : Type} -> @-shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type} -> @-valid:{Layout.query_valid(~layout,~route) == True{} : Bool} -> @-Error:Data -> @-body:(U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,Error>) -> Q.Mode -> B -> B & Q.Each<S,H,Error>

def OutputQuery(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-layout:Layout.Layout -> @-route:Layout.Route -> @-same:{C == Layout.columns(~S,layout) : Type} -> @-shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type} -> @-valid:{Layout.query_valid(~layout,~route) == True{} : Bool} -> @-O:Type -> @-Error:Data -> @-split:(O -> O & O) -> @-merge:(O -> O -> O) -> @-body:Q.OutputBody(~S,~layout,~route,~O,~Error) -> Q.Mode -> B -> B & Q.OutputEach<S,H,O,Error>
def GeneralQuery(~S:Data,~WC:Type,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-full:Layout.Layout -> @-route:Layout.Route -> @-same:{WC == Layout.columns(~S,full) : Type} -> @-valid:{Layout.grant_valid(~full,~route) == True{} : Bool} -> @-model:Store.StorageModel -> @-local:{C == Store.owner(~S,full,model) : Type} -> @-kind:Recipe.QueryKind -> @-bound:Recipe.Bound -> @-presence:Match.Presence -> @-predicate:(Maybe<&2,Layout.view(full,route)> -> Bool) -> B -> B & Q.GeneralOps(~S,~Layout.payload(full,route),~Layout.view(full,route),kind,H)
def QuerySelection(~S:Data,~WC:Type,~C:Type,~R:Type,~H:Type,~B:Type,~Ops:Type -> Type) -> Type:
  @-basic:BasicQuery(~S,~C,~R,~H,~B) -> @-output:OutputQuery(~S,~C,~R,~H,~B) -> @-general:GeneralQuery(~S,~WC,~C,~R,~H,~B) -> B -> B & Ops(H)
def Query(~S:Data,~WC:Type,~C:Type,~R:Type,~H:Type,~B:Type) -> Type:
  @-Ops:(Type -> Type) -> @-selection:QuerySelection(~S,~WC,~C,~R,~H,~B,~Ops) -> B -> B & Ops(H)

def basic_query_selection(~S:Data,~WC:Type,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~Error:Data,~body:U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,Error>,~mode:Q.Mode,~H:Type,~B:Type,~basic:BasicQuery(~S,~C,~R,~H,~B),~output:OutputQuery(~S,~C,~R,~H,~B),~general:GeneralQuery(~S,~WC,~C,~R,~H,~B),book:B) -> B & Q.Each<S,H,Error>:
  basic(layout,route,same,shape,valid,Error,body,mode,book)
def basic_query(~S:Data,~WC:Type,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~Error:Data,~body:U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,Error>,~mode:Q.Mode,~H:Type,~B:Type,~query:Query(~S,~WC,~C,~R,~H,~B),book:B) -> B & Q.Each<S,H,Error>:
  query(Q.Ops(~S,~Error),basic_query_selection(~S,~WC,~C,~R,~layout,~route,~same,~shape,~valid,~Error,~body,~mode,~H,~B),book)
def output_query_selection(~S:Data,~WC:Type,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~O:Type,~Error:Data,~split:O -> O & O,~merge:O -> O -> O,~body:Q.OutputBody(~S,~layout,~route,~O,~Error),~mode:Q.Mode,~H:Type,~B:Type,~basic:BasicQuery(~S,~C,~R,~H,~B),~output:OutputQuery(~S,~C,~R,~H,~B),~general:GeneralQuery(~S,~WC,~C,~R,~H,~B),book:B) -> B & Q.OutputEach<S,H,O,Error>:
  output(layout,route,same,shape,valid,O,Error,split,merge,body,mode,book)
def output_query(~S:Data,~WC:Type,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~O:Type,~Error:Data,~split:O -> O & O,~merge:O -> O -> O,~body:Q.OutputBody(~S,~layout,~route,~O,~Error),~mode:Q.Mode,~H:Type,~B:Type,~query:Query(~S,~WC,~C,~R,~H,~B),book:B) -> B & Q.OutputEach<S,H,O,Error>:
  query(Q.OutputOps(~S,~O,~Error),output_query_selection(~S,~WC,~C,~R,~layout,~route,~same,~shape,~valid,~O,~Error,~split,~merge,~body,~mode,~H,~B),book)

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

def Selection(~S:Data,~WC:Type,~C:Type,~R:Type,~Permit:Data,~H:Type,~B:Type,~Ops:Data -> Type -> Type) -> Type:
  @-component_read:ComponentRead(~S,~C,~R,~H,~B) -> @-component_write:ComponentWrite(~S,~C,~R,~H,~B) -> @-resource_read:ResourceRead(~S,~C,~R,~H,~B) -> @-resource_write:ResourceWrite(~S,~C,~R,~H,~B) -> @-query:Query(~S,~WC,~C,~R,~H,~B) -> @-lifecycle:Lifecycle(~S,~WC,~C,~R,~H,~B) -> B -> B & Ops(Permit,H)
def Builder(~S:Data,~WC:Type,~C:Type,~R:Type,~Permit:Data,~H:Type,~B:Type) -> Type:
  @-Ops:(Data -> Type -> Type) -> @-selection:Selection(~S,~WC,~C,~R,~Permit,~H,~B,~Ops) -> B -> B & Ops(Permit,H)
def Program(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Data -> Type -> Type) -> Type:
  @-Permit:Data -> @-H:Type -> @-B:Type -> @-builder:Builder(~S,~WC,~C,~R,~Permit,~H,~B) -> B -> B & Ops(Permit,H)
# Trusted compiler kernel. Ordinary application Programs never receive token.
def FrameworkProgram(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Data -> Type -> Type) -> Type:
  @-Permit:Data -> @-token:Permit -> @-H:Type -> @-B:Type -> @-builder:Builder(~S,~WC,~C,~R,~Permit,~H,~B) -> B -> B & Ops(Permit,H)
def framework_program(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Data -> Type -> Type,~ordinary:Program(~S,~WC,~C,~R,~Ops),~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Builder(~S,~WC,~C,~R,~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  ordinary(Permit,H,B,builder,book)

def accumulate(-S:Data,-C:Type,-R:Type,-Ops:Type -> Type,book:Book,value:D.Declaration<S,C,R,Ops>) -> Book & Ops(State.Scope<S,C,R>):
  match book value:
    case Book{previous,queries,resources,supported} D.Declaration{caps,access}:(Book{List.append(&2,D.Access,previous,access),queries,resources,supported},caps)
def component_read_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},book:Book) -> Book & A.ComponentRead<S,State.Scope<S,C,R>,Layout.view(layout,route)>:
  accumulate(S,C,R,A.ComponentReads(~S,~Layout.view(layout,route)),book,LayoutAccess.component_read(~S,~C,~R,~layout,~route,~same,~valid))

def component_write_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},book:Book) -> Book & A.ComponentWrite<S,State.Scope<S,C,R>,Layout.payload(layout,route),Layout.view(layout,route)>:
  accumulate(S,C,R,A.ComponentWrites(~S,~Layout.payload(layout,route),~Layout.view(layout,route)),book,LayoutAccess.component_write(~S,~C,~R,~layout,~route,~same,~valid))

def record_resource(book:Book,entry:Resources.Entry) -> Book:
  match book:
    case Book{access,queries,resources,supported}:Book{access,queries,entry <> resources,supported}
def resource_book(book:Book,entry:Resources.Entry,access:D.Access,available:Bool) -> Book:
  match book:
    case Book{previous,queries,resources,supported}:Book{access <> previous,queries,entry <> resources,Bool.and(supported,available)}
def resource_read_recorded(-S:Data,-C:Type,-R:Type,-layout:Layout.Layout,+route:Layout.Route,book:Book,result:String & A.ResourceRead<State.Scope<S,C,R>,Layout.view(layout,route)>) -> Book & A.ResourceRead<State.Scope<S,C,R>,Layout.view(layout,route)>:
  match result:
    case (+key,cap):(resource_book(book,Resources.Entry{route,key,Resources.ReadOnly{}},D.Access{key,D.ResourceAccess{},D.Exclusive{},D.ReadOnly{}},True{}),cap)
def resource_read_build(-S:Data,-C:Type,-R:Type,layout:Layout.Layout,+route:Layout.Route,same:{R == Layout.resources_generic(S,layout) : Type},valid:{Bool.and(Layout.unique(layout),Layout.valid(layout,route)) == True{} : Bool},book:Book) -> Book & A.ResourceRead<State.Scope<S,C,R>,Layout.view(layout,route)>:
  resource_read_recorded(S,C,R,layout,route,book,LayoutAccess.resource_read(S,C,R,layout,route,same,valid))

def resource_write_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~valid:{Layout.resource_write_valid(~layout,~route) == True{} : Bool},book:Book) -> Book & A.ResourceWrite<State.Scope<S,C,R>,Layout.payload(layout,route),Layout.view(layout,route)>:
  accumulate(S,C,R,A.ResourceWrites(~Layout.payload(layout,route),~Layout.view(layout,route)),record_resource(book,Resources.Entry{route,Layout.key(layout,route),Resources.Writable{}}),LayoutAccess.resource_write(~S,~C,~R,~layout,~route,~same,~valid))

def resource_read_unsupported(~S:Data,~C:Type,~R:Type,~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~model:ResourceStore.Model,~local:{R == ResourceStore.owner(~S,full,model) : Type},book:Book) -> Book & ResourceAccess.Reader<State.Scope<S,C,R>,Layout.view(full,route)>:
  (resource_book(book,Resources.Entry{route,Layout.key(full,route),Resources.ReadOnly{}},D.Access{Layout.key(full,route),D.ResourceAccess{},D.SharedView{},D.ReadOnly{}},False{}),ResourceAccess.UnsupportedReader{})
def failure_read_build(~S:Data,~C:Type,~R:Type,~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(full,route) == RelationStore.Store<S,descriptor> : Type},~view:{Layout.view(full,route) == RelationStore.View<S,descriptor> : Data},~protected:{Layout.policy(full,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},~local:Layout.Layout,~selected:Layout.Route,~same:{R == Layout.resources(~S,local) : Type},~localvalid:{Layout.grant_valid(~local,~selected) == True{} : Bool},~slot:{LayoutAccess.resource_slot(~S,local,selected) == FailureProvider.Slot(~S,~full,~route,~descriptor) : Type},book:Book) -> Book & FailureAccess.Read<S,descriptor,full,route,State.Scope<S,C,R>>:
  accumulate(S,C,R,FailureAccess.Ops(~S,~descriptor,~full,~route),book,D.Declaration{FailureProvider.whole(~S,~C,~R,~full,~route,~valid,~descriptor,~payload,~view,~protected,~local,~selected,~same,~localvalid,~slot),[D.Access{Layout.key(full,route),D.ResourceAccess{},D.SharedView{},D.ReadOnly{}}]})
def general_failure_read_build(~S:Data,~C:Type,~R:Type,~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(full,route) == RelationStore.Store<S,descriptor> : Type},~view:{Layout.view(full,route) == RelationStore.View<S,descriptor> : Data},~protected:{Layout.policy(full,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},~model:ResourceStore.Model,~local:{R == ResourceStore.owner(~S,full,model) : Type},book:Book) -> Book & FailureAccess.Read<S,descriptor,full,route,State.Scope<S,C,R>>:
  (resource_book(book,Resources.Entry{route,Layout.key(full,route),Resources.ReadOnly{}},D.Access{Layout.key(full,route),D.ResourceAccess{},D.SharedView{},D.ReadOnly{}},True{}),FailureProvider.general(~S,~C,~R,~full,~route,~valid,~descriptor,~payload,~view,~protected,~model,~local))
def resource_read_provision(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,~selection:ResourceReadSelection(~S,~C,~R,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(State.Scope<S,C,R>):
  selection(resource_read_build(S,C,R),resource_read_unsupported(~S,~C,~R),failure_read_build(~S,~C,~R),general_failure_read_build(~S,~C,~R),book)
def resource_write_unsupported(~S:Data,~C:Type,~R:Type,~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.resource_write_valid(~full,~route) == True{} : Bool},~model:ResourceStore.Model,~local:{R == ResourceStore.owner(~S,full,model) : Type},book:Book) -> Book & ResourceAccess.Writer<State.Scope<S,C,R>,Layout.payload(full,route),Layout.view(full,route)>:
  (resource_book(book,Resources.Entry{route,Layout.key(full,route),Resources.Writable{}},D.Access{Layout.key(full,route),D.ResourceAccess{},D.Exclusive{},D.Writable{}},False{}),ResourceAccess.UnsupportedWriter{})
def resource_write_provision(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,~selection:ResourceWriteSelection(~S,~C,~R,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(State.Scope<S,C,R>):
  selection(resource_write_build(~S,~C,~R),resource_write_unsupported(~S,~C,~R),book)
def query_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~Error:Data,~body:U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,Error>,mode:Q.Mode,book:Book) -> Book & Q.Each<S,State.Scope<S,C,R>,Error>:
  accumulate(S,C,R,Q.Ops(~S,~Error),book,Q.layout_declaration(~S,~C,~R,~layout,~route,~same,~shape,~valid,~Error,~body,mode))

def output_query_build(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~O:Type,~Error:Data,~split:O -> O & O,~merge:O -> O -> O,~body:Q.OutputBody(~S,~layout,~route,~O,~Error),mode:Q.Mode,book:Book) -> Book & Q.OutputEach<S,State.Scope<S,C,R>,O,Error>:
  accumulate(S,C,R,Q.OutputOps(~S,~O,~Error),book,Q.output_declaration(~S,~C,~R,~layout,~route,~same,~shape,~valid,~O,~Error,~split,~merge,~body,mode))

def unsupported_caps(~S:Data,~P:Type,~V:Data,~H:Type,kind:Recipe.QueryKind) -> Q.GeneralOps(~S,~P,~V,kind,H):
  match kind:
    case Recipe.ReadRows{}:Q.UnsupportedReader{}
    case Recipe.WriteRows{}:Q.UnsupportedWriter{}
def general_book(book:Book,recipe:Recipe.Entry,access:List<&2,D.Access>,available:Bool) -> Book:
  match book:
    case Book{previous,recipes,resources,supported}:Book{List.append(&2,D.Access,access,previous),recipe <> recipes,resources,Bool.and(supported,available)}
def general_access(key:String,kind:Recipe.QueryKind) -> D.Access:
  match kind:
    case Recipe.ReadRows{}:D.Access{key,D.ComponentAccess{},D.SharedView{},D.ReadOnly{}}
    case Recipe.WriteRows{}:D.Access{key,D.ComponentAccess{},D.Exclusive{},D.Writable{}}
def bound_access(~full:Layout.Layout,selection:Recipe.Bound) -> List<&2,D.Access>:
  match selection:
    case Recipe.AllLive{}:[]
    case Recipe.With{route}:[D.Access{Layout.key(full,route),D.ComponentAccess{},D.SharedView{},D.ReadOnly{}}]
    case Recipe.Without{route}:[D.Access{Layout.key(full,route),D.ComponentAccess{},D.SharedView{},D.ReadOnly{}}]
    case Recipe.Changed{route}:[D.Access{Layout.key(full,route),D.ComponentAccess{},D.SharedView{},D.ReadOnly{}}]
    case Recipe.And{left,right}:List.append(&2,D.Access,bound_access(~full,left),bound_access(~full,right))
    case Recipe.Or{left,right}:List.append(&2,D.Access,bound_access(~full,left),bound_access(~full,right))
def general_unsupported(~S:Data,~WC:Type,~C:Type,~R:Type,~full:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,full) : Type},~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~model:Store.StorageModel,~local:{C == Store.owner(~S,full,model) : Type},~kind:Recipe.QueryKind,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,Layout.view(full,route)> -> Bool,book:Book) -> Book & Q.GeneralOps(~S,~Layout.payload(full,route),~Layout.view(full,route),kind,State.Scope<S,C,R>):
  (general_book(book,Recipe.Entry{route,kind,bound,presence},general_access(Layout.key(full,route),kind) <> bound_access(~full,bound),False{}),unsupported_caps(~S,~Layout.payload(full,route),~Layout.view(full,route),~State.Scope<S,C,R>,kind))
def query_provision(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Type -> Type,~selection:QuerySelection(~S,~WC,~C,~R,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(State.Scope<S,C,R>):
  selection(query_build(~S,~C,~R),output_query_build(~S,~C,~R),general_unsupported(~S,~WC,~C,~R),book)
def removed_lifecycle_build(~S:Data,~WC:Type,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},book:Book) -> Book & Life.Next<S,State.Scope<S,C,R>,Layout.origin(layout,route),Notice.Removed{Layout.key(layout,route)}>:
  accumulate(S,C,R,Life.Ops(~S,~(Layout.origin(layout,route)),~(Notice.Removed{Layout.key(layout,route)})),book,Life.removed(~S,~WC,~C,~R,~layout,~route,~same,~valid))
def despawn_lifecycle_build(~S:Data,~WC:Type,~C:Type,~R:Type,book:Book) -> Book & Life.Next<S,State.Scope<S,C,R>,Layout.EmptyLayout{},Notice.Despawned{}>:
  accumulate(S,C,R,Life.Ops(~S,~(Layout.EmptyLayout{}),~(Notice.Despawned{})),book,Life.despawned(~S,~C,~R))
def lifecycle_provision(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Type -> Type,~selection:LifecycleSelection(~S,~WC,~C,~R,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(State.Scope<S,C,R>):
  selection(removed_lifecycle_build(~S,~WC,~C,~R),despawn_lifecycle_build(~S,~WC,~C,~R),book)
def provision(~S:Data,~WC:Type,~C:Type,~R:Type,~Permit:Data,~Ops:Data -> Type -> Type,~selection:Selection(~S,~WC,~C,~R,~Permit,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(Permit,State.Scope<S,C,R>):
  selection(component_read_build(~S,~C,~R),component_write_build(~S,~C,~R),resource_read_provision(~S,~C,~R),resource_write_provision(~S,~C,~R),query_provision(~S,~WC,~C,~R),lifecycle_provision(~S,~WC,~C,~R),book)
def compilation_checked(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Data -> Type -> Type,caps:Ops(Effect.Granted,State.Scope<S,C,R>),access:List<&2,D.Access>,recipes:List<&2,Recipe.Entry>,resources:List<&2,Resources.Entry>,supported:Bool) -> D.Compilation<S,WC,C,R,Ops>:
  match supported:
    case True{}:D.Supported{D.Declaration{caps,access},D.Recipes{Recipe.brand(S,WC,recipes),resources}}
    case False{}:D.Unsupported{caps,access,D.Recipes{Recipe.brand(S,WC,recipes),resources}}
def compiled(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Data -> Type -> Type,result:Book & Ops(Effect.Granted,State.Scope<S,C,R>)) -> D.Compilation<S,WC,C,R,Ops>:
  match result:
    case (Book{access,recipes,resources,supported},caps):compilation_checked(~S,~WC,~C,~R,~Ops,caps,access,recipes,resources,supported)
def compile_framework(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Data -> Type -> Type,~program:FrameworkProgram(~S,~WC,~C,~R,~Ops)) -> D.Compilation<S,WC,C,R,Ops>:
  compiled(~S,~WC,~C,~R,~Ops,program(Effect.Granted,Effect.Granted{},State.Scope<S,C,R>,Book,provision(~S,~WC,~C,~R,~Effect.Granted),Book{[],[],[],True{}}))


def compile(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Data -> Type -> Type,~program:Program(~S,~WC,~C,~R,~Ops)) -> D.Compilation<S,WC,C,R,Ops>:
  compile_framework(~S,~WC,~C,~R,~Ops,~framework_program(~S,~WC,~C,~R,~Ops,~program))
def general_selection(~S:Data,~WC:Type,~C:Type,~R:Type,~full:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,full) : Type},~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~model:Store.StorageModel,~local:{C == Store.owner(~S,full,model) : Type},~kind:Recipe.QueryKind,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,Layout.view(full,route)> -> Bool,~H:Type,~B:Type,~basic:BasicQuery(~S,~C,~R,~H,~B),~output:OutputQuery(~S,~C,~R,~H,~B),~general:GeneralQuery(~S,~WC,~C,~R,~H,~B),book:B) -> B & Q.GeneralOps(~S,~Layout.payload(full,route),~Layout.view(full,route),kind,H):
  general(full,route,same,valid,model,local,kind,bound,presence,predicate,book)
def general_query(~S:Data,~WC:Type,~C:Type,~R:Type,~full:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,full) : Type},~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~model:Store.StorageModel,~local:{C == Store.owner(~S,full,model) : Type},~kind:Recipe.QueryKind,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,Layout.view(full,route)> -> Bool,~H:Type,~B:Type,~query:Query(~S,~WC,~C,~R,~H,~B),book:B) -> B & Q.GeneralOps(~S,~Layout.payload(full,route),~Layout.view(full,route),kind,H):
  query(Q.GeneralOps(~S,~Layout.payload(full,route),~Layout.view(full,route),kind),general_selection(~S,~WC,~C,~R,~full,~route,~same,~valid,~model,~local,~kind,~bound,~presence,~predicate,~H,~B),book)
# Trusted interpretation dictionary; the closed Program remains the sole grant
# source. This callback cannot supply an unrelated Book or metadata catalog.
def GeneralProvider(~S:Data,~WC:Type,~C:Type,~R:Type) -> Type:
  @-full:Layout.Layout -> @-route:Layout.Route -> @-same:{WC == Layout.columns(~S,full) : Type} -> @-valid:{Layout.grant_valid(~full,~route) == True{} : Bool} -> @-model:Store.StorageModel -> @-local:{C == Store.owner(~S,full,model) : Type} -> @-kind:Recipe.QueryKind -> @-bound:Recipe.Bound -> @-presence:Match.Presence -> @-predicate:(Maybe<&2,Layout.view(full,route)> -> Bool) -> Q.GeneralOps(~S,~Layout.payload(full,route),~Layout.view(full,route),kind,State.Scope<S,C,R>)
def general_build(~S:Data,~WC:Type,~C:Type,~R:Type,~provider:GeneralProvider(~S,~WC,~C,~R),~full:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,full) : Type},~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~model:Store.StorageModel,~local:{C == Store.owner(~S,full,model) : Type},~kind:Recipe.QueryKind,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,Layout.view(full,route)> -> Bool,book:Book) -> Book & Q.GeneralOps(~S,~Layout.payload(full,route),~Layout.view(full,route),kind,State.Scope<S,C,R>):
  (general_book(book,Recipe.Entry{route,kind,bound,presence},general_access(Layout.key(full,route),kind) <> bound_access(~full,bound),True{}),provider(full,route,same,valid,model,local,kind,bound,presence,predicate))
def query_provision_with(~S:Data,~WC:Type,~C:Type,~R:Type,~provider:GeneralProvider(~S,~WC,~C,~R),~Ops:Type -> Type,~selection:QuerySelection(~S,~WC,~C,~R,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(State.Scope<S,C,R>):
  selection(query_build(~S,~C,~R),output_query_build(~S,~C,~R),general_build(~S,~WC,~C,~R,~provider),book)
def provision_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~Permit:Data,~provider:GeneralProvider(~S,~WC,~C,~R),~Ops:Data -> Type -> Type,~selection:Selection(~S,~WC,~C,~R,~Permit,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(Permit,State.Scope<S,C,R>):
  selection(component_read_build(~S,~C,~R),component_write_build(~S,~C,~R),resource_read_provision(~S,~C,~R),resource_write_provision(~S,~C,~R),query_provision_with(~S,~WC,~C,~R,~provider),lifecycle_provision(~S,~WC,~C,~R),book)
def compile_framework_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~provider:GeneralProvider(~S,~WC,~C,~R),~Ops:Data -> Type -> Type,~program:FrameworkProgram(~S,~WC,~C,~R,~Ops)) -> D.Compilation<S,WC,C,R,Ops>:
  compiled(~S,~WC,~C,~R,~Ops,program(Effect.Granted,Effect.Granted{},State.Scope<S,C,R>,Book,provision_with_general(~S,~WC,~C,~R,~Effect.Granted,~provider),Book{[],[],[],True{}}))

# These dictionaries interpret the same closed selections; they add no grants.

def compile_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~provider:GeneralProvider(~S,~WC,~C,~R),~Ops:Data -> Type -> Type,~program:Program(~S,~WC,~C,~R,~Ops)) -> D.Compilation<S,WC,C,R,Ops>:
  compile_framework_with_general(~S,~WC,~C,~R,~provider,~Ops,~framework_program(~S,~WC,~C,~R,~Ops,~program))
def ResourceReadProvider(~S:Data,~C:Type,~R:Type) -> Type:
  @-full:Layout.Layout -> @-route:Layout.Route -> @-valid:{Layout.grant_valid(~full,~route) == True{} : Bool} -> @-model:ResourceStore.Model -> @-local:{R == ResourceStore.owner(~S,full,model) : Type} -> ResourceAccess.Reader<State.Scope<S,C,R>,Layout.view(full,route)>
def ResourceWriteProvider(~S:Data,~C:Type,~R:Type) -> Type:
  @-full:Layout.Layout -> @-route:Layout.Route -> @-valid:{Layout.resource_write_valid(~full,~route) == True{} : Bool} -> @-model:ResourceStore.Model -> @-local:{R == ResourceStore.owner(~S,full,model) : Type} -> ResourceAccess.Writer<State.Scope<S,C,R>,Layout.payload(full,route),Layout.view(full,route)>
def general_resource_read_selection(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~model:ResourceStore.Model,~local:{R == ResourceStore.owner(~S,full,model) : Type},~basic:BasicResourceRead(~S,~C,~R,~H,~B),~general:GeneralResourceRead(~S,~C,~R,~H,~B),~failure:FailureRead(~S,~C,~R,~H,~B),~general_failure:GeneralFailureRead(~S,~C,~R,~H,~B),book:B) -> B & ResourceAccess.Reader<H,Layout.view(full,route)>:
  general(full,route,valid,model,local,book)
def general_resource_read(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~model:ResourceStore.Model,~local:{R == ResourceStore.owner(~S,full,model) : Type},~resource:ResourceRead(~S,~C,~R,~H,~B),book:B) -> B & ResourceAccess.Reader<H,Layout.view(full,route)>:
  resource(ResourceAccess.Reads(~Layout.view(full,route)),general_resource_read_selection(~S,~C,~R,~H,~B,~full,~route,~valid,~model,~local),book)
def general_resource_write_selection(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.resource_write_valid(~full,~route) == True{} : Bool},~model:ResourceStore.Model,~local:{R == ResourceStore.owner(~S,full,model) : Type},~basic:BasicResourceWrite(~S,~C,~R,~H,~B),~general:GeneralResourceWrite(~S,~C,~R,~H,~B),book:B) -> B & ResourceAccess.Writer<H,Layout.payload(full,route),Layout.view(full,route)>:
  general(full,route,valid,model,local,book)
def general_resource_write(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.resource_write_valid(~full,~route) == True{} : Bool},~model:ResourceStore.Model,~local:{R == ResourceStore.owner(~S,full,model) : Type},~resource:ResourceWrite(~S,~C,~R,~H,~B),book:B) -> B & ResourceAccess.Writer<H,Layout.payload(full,route),Layout.view(full,route)>:
  resource(ResourceAccess.Writes(~Layout.payload(full,route),~Layout.view(full,route)),general_resource_write_selection(~S,~C,~R,~H,~B,~full,~route,~valid,~model,~local),book)
def resource_read_with(~S:Data,~C:Type,~R:Type,~provider:ResourceReadProvider(~S,~C,~R),~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~model:ResourceStore.Model,~local:{R == ResourceStore.owner(~S,full,model) : Type},book:Book) -> Book & ResourceAccess.Reader<State.Scope<S,C,R>,Layout.view(full,route)>:
  (resource_book(book,Resources.Entry{route,Layout.key(full,route),Resources.ReadOnly{}},D.Access{Layout.key(full,route),D.ResourceAccess{},D.SharedView{},D.ReadOnly{}},True{}),provider(full,route,valid,model,local))
def resource_write_with(~S:Data,~C:Type,~R:Type,~provider:ResourceWriteProvider(~S,~C,~R),~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.resource_write_valid(~full,~route) == True{} : Bool},~model:ResourceStore.Model,~local:{R == ResourceStore.owner(~S,full,model) : Type},book:Book) -> Book & ResourceAccess.Writer<State.Scope<S,C,R>,Layout.payload(full,route),Layout.view(full,route)>:
  (resource_book(book,Resources.Entry{route,Layout.key(full,route),Resources.Writable{}},D.Access{Layout.key(full,route),D.ResourceAccess{},D.Exclusive{},D.Writable{}},True{}),provider(full,route,valid,model,local))
def resource_read_provision_with(~S:Data,~C:Type,~R:Type,~provider:ResourceReadProvider(~S,~C,~R),~Ops:Type -> Type,~selection:ResourceReadSelection(~S,~C,~R,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(State.Scope<S,C,R>):
  selection(resource_read_build(S,C,R),resource_read_with(~S,~C,~R,~provider),failure_read_build(~S,~C,~R),general_failure_read_build(~S,~C,~R),book)
def resource_write_provision_with(~S:Data,~C:Type,~R:Type,~provider:ResourceWriteProvider(~S,~C,~R),~Ops:Type -> Type,~selection:ResourceWriteSelection(~S,~C,~R,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(State.Scope<S,C,R>):
  selection(resource_write_build(~S,~C,~R),resource_write_with(~S,~C,~R,~provider),book)
def provision_with_interpreters(~S:Data,~WC:Type,~C:Type,~R:Type,~Permit:Data,~queryProvider:GeneralProvider(~S,~WC,~C,~R),~readProvider:ResourceReadProvider(~S,~C,~R),~writeProvider:ResourceWriteProvider(~S,~C,~R),~Ops:Data -> Type -> Type,~selection:Selection(~S,~WC,~C,~R,~Permit,~State.Scope<S,C,R>,~Book,~Ops),book:Book) -> Book & Ops(Permit,State.Scope<S,C,R>):
  selection(component_read_build(~S,~C,~R),component_write_build(~S,~C,~R),resource_read_provision_with(~S,~C,~R,~readProvider),resource_write_provision_with(~S,~C,~R,~writeProvider),query_provision_with(~S,~WC,~C,~R,~queryProvider),lifecycle_provision(~S,~WC,~C,~R),book)
def compile_framework_with_interpreters(~S:Data,~WC:Type,~C:Type,~R:Type,~queryProvider:GeneralProvider(~S,~WC,~C,~R),~readProvider:ResourceReadProvider(~S,~C,~R),~writeProvider:ResourceWriteProvider(~S,~C,~R),~Ops:Data -> Type -> Type,~program:FrameworkProgram(~S,~WC,~C,~R,~Ops)) -> D.Compilation<S,WC,C,R,Ops>:
  compiled(~S,~WC,~C,~R,~Ops,program(Effect.Granted,Effect.Granted{},State.Scope<S,C,R>,Book,provision_with_interpreters(~S,~WC,~C,~R,~Effect.Granted,~queryProvider,~readProvider,~writeProvider),Book{[],[],[],True{}}))

def compile_with_interpreters(~S:Data,~WC:Type,~C:Type,~R:Type,~queryProvider:GeneralProvider(~S,~WC,~C,~R),~readProvider:ResourceReadProvider(~S,~C,~R),~writeProvider:ResourceWriteProvider(~S,~C,~R),~Ops:Data -> Type -> Type,~program:Program(~S,~WC,~C,~R,~Ops)) -> D.Compilation<S,WC,C,R,Ops>:
  compile_framework_with_interpreters(~S,~WC,~C,~R,~queryProvider,~readProvider,~writeProvider,~Ops,~framework_program(~S,~WC,~C,~R,~Ops,~program))
