import Base
import ../../src/ecs/execution-prepared.bend as Prep
import ../../src/ecs/execution-compiled-binding.bend as Compiled
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-composer-schema.bend as Schema
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/execution-inspector-commands.bend as Inspector
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/execution-parallel-registration.bend as Part
import ../../test-fixtures/execution-query-partitions/ordinary-whole-other-shape.bend as Run
import ../../test-fixtures/execution-query-partitions/ordinary-combined-main.bend as Setup
import ../../test-fixtures/execution-query-partitions/schema.bend as S
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-generalized-publication.bend as Publication
import ../../src/ecs/execution-generalized-root-application.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as RootApp
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-resource-program.bend as ResourceProgram
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as System
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick

def Ops(Permit:Data,H:Type,Q:Type) -> Type:Permission.EntityCommands<Q,S.SchemaA,S.layout_b(),Permit>
type User is Type:
  User{bundle:Maybe<&1,Removed.Removed(S.layout_b())>,calls:U32}
def granted(~Permit:Data,~H:Type,~Q:Type,~B:Type,~K:Type,book:B,result:K & Permission.EntityCommands<Q,S.SchemaA,S.layout_b(),Permit>) -> B & (K & Ops(Permit,H,Q)):
  (book,result)
def declaration(~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S.SchemaA,L.payload(S.layout_b(),L.InLeft{L.AtLeaf{}})>,~B:Type,~builder:Build.Builder(~S.SchemaA,~Run.WC(),~Run.CombinedColumns(),~Run.CombinedResources(),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S.SchemaA,~S.layout_b(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S.SchemaA,~Run.combined_resources(),~Q,~K),~scopes:Permission.ScopeGrant(~S.SchemaA,~Run.combined_resources(),~Q,~K),book:B,permission:K) -> B & (K & Ops(Permit,H,Q)):
  granted(~Permit,~H,~Q,~B,~K,book,entity(permission))
def spawned(~Permit:Data,~H:Type,~Q:Type,scope:H,+calls:U32,result:Q & Buffer.SpawnAdmission<S.SchemaA,Removed.Removed(S.layout_b())>) -> Task.Task<S.SchemaA,Permit,H & (Q & (User & Sys.Completion<String,Maybe<&2,U32>>))>:
  match result:
    case (queue,Buffer.SpawnQueued{_}):Task.TDone{(scope,(queue,(User{None{},calls},Sys.BodyError{"author-after-spawn",Some{calls}})))}
    case (queue,Buffer.SpawnRejected{bundle,_}):Task.TDone{(scope,(queue,(User{Some{bundle},calls},Sys.BodyError{"spawn-refused",Some{calls}})))}
def author(~Permit:Data,~H:Type,~Q:Type,~caps:Ops(Permit,H,Q),scope:H,queue:Q,user:User) -> Task.Task<S.SchemaA,Permit,H & (Q & (User & Sys.Completion<String,Maybe<&2,U32>>))>:
  match user:
    case User{None{},+calls}:Task.TDone{(scope,(queue,(User{None{},U32.add(calls,1)},Sys.Success{Some{calls}})))}
    case User{Some{bundle},calls}:Task.bind(S.SchemaA,Permit,Q & Buffer.SpawnAdmission<S.SchemaA,Removed.Removed(S.layout_b())>,H & (Q & (User & Sys.Completion<String,Maybe<&2,U32>>)),Permission.spawn_field(~Q,~S.SchemaA,~S.layout_b(),~Permit,caps)(queue,bundle),result => spawned(~Permit,~H,~Q,scope,U32.add(calls,1),result))
def body(~Permit:Data,~H:Type,~Q:Type,~caps:Ops(Permit,H,Q),~commands:Local.Commands<Q,S.SchemaA,L.payload(S.layout_b(),L.InLeft{L.AtLeaf{}})>,scope:H,queue:Q,user:User) -> Task.Task<S.SchemaA,Permit,H & (Q & (User & Sys.Completion<String,Maybe<&2,U32>>))>:
  author(~Permit,~H,~Q,~caps,scope,queue,user)
def kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~Run.WC(),~Run.CombinedColumns(),~Run.CombinedResources(),~Permit,~H,~B),book:B) -> B & Cmd.ScopedOps(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~L.InLeft{L.AtLeaf{}},~Ops,Permit,H):
  Cmd.program_for_buffer(~S.SchemaA,~Run.CombinedColumns(),~Run.CombinedResources(),~S.layout_b(),~Run.combined_resources(),~L.InLeft{L.AtLeaf{}},~Ops,~declaration,~Permit,~token,~H,~B,~builder,book)
def compilation() -> D.Compilation<S.SchemaA,Run.WC(),Run.CombinedColumns(),Run.CombinedResources(),Cmd.ScopedOps(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~L.InLeft{L.AtLeaf{}},~Ops)>:
  ResourceProgram.compile_framework(~S.SchemaA,~Run.WC(),~Run.CombinedColumns(),~Run.CombinedResources(),~Cmd.ScopedOps(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~L.InLeft{L.AtLeaf{}},~Ops),~kernel)
def AuthorNode() -> Type:Author.Node(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,~L.InLeft{L.AtLeaf{}},~Ops,~User,~String,~Maybe<&2,U32>,~declaration,~body)
def Nodes() -> Type:Product.Owner<AuthorNode(),Run.CombinedRightNode(False{})>
def GuardCompilation() -> Type:D.Compilation<S.SchemaA,Run.WC(),Run.WC(),L.resources(~S.SchemaA,Run.combined_resources()),Run.RootGuardOps>
def Guard() -> Type:Scope.CompiledBinding<GuardCompilation(),Run.RootGuard()>
def guard_construction() -> GuardCompilation():
  ResourceProgram.compile_framework(~S.SchemaA,~Run.WC(),~Run.WC(),~L.resources(~S.SchemaA,Run.combined_resources()),~Run.RootGuardOps,~Run.root_guard_kernel)
def guard_dispatch() -> Conditions.Dispatch(~Run.CombinedWorld(),~Guard(),~String):
  Conditions.retained_leaf_dispatch(~S.SchemaA,~Run.WC(),~L.resources(~S.SchemaA,Run.combined_resources()),~Unit,~Run.RootGuardOps,~U32,~String,~Run.root_guard_kernel,~Run.root_guard_body,~guard_construction())
def ScheduledApplication() -> Type:RootApp.Scheduled<App.State<Root.Storage<S.SchemaA,S.layout_b(),Run.combined_resources(),Unit>,Nodes(),Guard(),U32>>
def CapturedContext() -> Data:Context.Context<S.SchemaA,L.resources(~S.SchemaA,Run.combined_resources()),Run.combined_resources(),{==}>
def Application() -> Type:Context.Bound<S.SchemaA,L.resources(~S.SchemaA,Run.combined_resources()),Run.combined_resources(),{==},ScheduledApplication()>
def dispatch(nodes:Nodes(),world:Run.CombinedWorld(),ids:List<&2,U32>) -> IO(Execution.RunResult<S.SchemaA,S.layout_b(),Run.combined_resources(),Unit,Nodes(),String,Maybe<&2,U32>>):
  match nodes:
    case Product.Owner{left,right}:Tree.run_generalized(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,~String,~Maybe<&2,U32>,AuthorNode(),Run.CombinedRightNode(False{}),ids,world,Tree.GeneralizedPair{Author.compile(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,~L.InLeft{L.AtLeaf{}},~Ops,~User,~String,~Maybe<&2,U32>,~declaration,~body,~compilation(),left),Tree.compile_retained_generalized_leaf(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,~String,~Maybe<&2,U32>,~Run.CombinedRightOps,~Run.CombinedLocal,~Run.combined_right_kernel(False{}),~Run.combined_right_body,~Run.combined_right_compiled(~False{}),right)})
def pending_result(right:Run.CombinedRightNode(False{}),result:Run.CombinedWorld() & (AuthorNode() & Bool)) -> Run.CombinedWorld() & (Nodes() & Bool):
  match result:
    case (world,(left,pending)):(world,(Product.Owner{left,right},pending))
def pending(ids:List<&2,U32>,world:Run.CombinedWorld(),nodes:Nodes()) -> Run.CombinedWorld() & (Nodes() & Bool):
  match nodes:
    case Product.Owner{left,right}:pending_result(right,Author.pending(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,~L.InLeft{L.AtLeaf{}},~Ops,~User,~String,~Maybe<&2,U32>,~declaration,~body,ids,world,left))
def published(right:Run.CombinedRightNode(False{}),result:Run.CombinedWorld() & AuthorNode()) -> Run.CombinedWorld() & Nodes():
  match result:
    case (world,left):(world,Product.Owner{left,right})
def publish(ids:List<&2,U32>,tick:Tick.Tick,world:Run.CombinedWorld(),nodes:Nodes()) -> Run.CombinedWorld() & Nodes():
  match nodes:
    case Product.Owner{left,right}:published(right,Author.publish(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,~L.InLeft{L.AtLeaf{}},~Ops,~User,~String,~Maybe<&2,U32>,~declaration,~body,~{==},~Cmd.checked_relations(~S.SchemaA,~Run.combined_resources(),Cmd.compiled_permission(~S.SchemaA,~Run.CombinedColumns(),~Run.CombinedResources(),~S.layout_b(),~Run.combined_resources(),~L.InLeft{L.AtLeaf{}},~Ops,compilation())),~Cmd.construction_selection(~S.SchemaA,~Run.CombinedColumns(),~Run.CombinedResources(),~S.layout_b(),~Run.combined_resources(),~L.InLeft{L.AtLeaf{}},~Ops,compilation()),ids,tick,world,left))
def collected(right:Run.CombinedRightNode(False{}),result:AuthorNode() & List<&2,U32>) -> Nodes() & List<&2,U32>:
  match result:
    case (left,ids):(Product.Owner{left,right},ids)
def collect(ids:List<&2,U32>,nodes:Nodes()) -> Nodes() & List<&2,U32>:
  match nodes:
    case Product.Owner{left,right}:collected(right,Author.collect(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,~L.InLeft{L.AtLeaf{}},~Ops,~User,~String,~Maybe<&2,U32>,~declaration,~body,ids,left))
def apply(ids:List<&2,U32>,world:Run.CombinedWorld(),nodes:Nodes()) -> Run.CombinedWorld() & (Nodes() & List<&2,U32>):
  Publication.apply(~S.SchemaA,~Run.WC(),~L.resources(~S.SchemaA,Run.combined_resources()),~Unit,~Nodes(),~pending,~publish,~collect,ids,world,nodes)
def handle_first(first:Bool,count:U32,error:String) -> U32 & Exec.Handling:
  match first:
    case True{}:(1,Exec.Escalate{})
    case False{}:Run.root_handle(count,error)
def handle_count(+count:U32,error:String) -> U32 & Exec.Handling:
  handle_first(U32.is_eq(count,0),count,error)
def handle(count:U32,error:String) -> U32 & Exec.Handling:
  handle_count(count,error)
def run(app:Application()) -> IO(Application() & Context.RunReport<App.Report<String,Maybe<&2,U32>>>):
  Root.run_bound(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,~Nodes(),~Guard(),~U32,~String,~Maybe<&2,U32>,~dispatch,~guard_dispatch(),~handle,~apply,app)

def Compilation() -> Type:D.Compilation<S.SchemaA,Run.WC(),Run.CombinedColumns(),Run.CombinedResources(),Cmd.ScopedOps(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~L.InLeft{L.AtLeaf{}},~Ops)>
def Owner() -> Type:Cmd.Owner<S.SchemaA,Run.CombinedColumns(),Run.CombinedResources(),Unit,S.layout_b(),Run.combined_resources(),L.InLeft{L.AtLeaf{}},Ops,User,String,Maybe<&2,U32>,declaration,body>
def Binding() -> Type:Scope.CompiledBinding<Compilation(),Owner()>
def Peer() -> Type:Sys.Owner<S.SchemaA,Run.WC(),Run.CombinedColumns(),Run.CombinedResources(),Unit,Run.CombinedRightOps,Run.CombinedLocal,String,Maybe<&2,U32>,Run.combined_right_kernel(False{}),Run.combined_right_body>
def PeerCompilation() -> Type:D.Compilation<S.SchemaA,Run.WC(),Run.CombinedColumns(),Run.CombinedResources(),Run.CombinedRightOps>
def PeerBinding() -> Type:Scope.CompiledBinding<PeerCompilation(),Peer()>
def configure_scheduled(+final:Bool,app:ScheduledApplication()) -> ScheduledApplication():
  match app:
    case RootApp.Scheduled{state,plan,bindings,rules,RootApp.Deferred{systems,Settings.Settings{_,_,ignored,explicit},unapplied}}:RootApp.Scheduled{state,plan,bindings,rules,RootApp.Deferred{systems,Settings.Settings{False{},final,ignored,explicit},unapplied}}
def configure(+final:Bool,bound:Application()) -> Application():
  match bound:
    case Context.Bound{context,app}:Context.Bound{context,configure_scheduled(final,app)}
def pending_text(value:Inspector.Pending<S.SchemaA>) -> String:
  match value:
    case Inspector.Spawn{handle}:"spawn:" ++ U32.show(W.handle_index(~S.SchemaA,handle))
    case _:"other"
def receipt_text(value:Inspector.Receipt<S.SchemaA>) -> String:
  match value:
    case Inspector.Spawned{handle}:"spawned:" ++ U32.show(W.handle_index(~S.SchemaA,handle))
    case Inspector.SpawnRefused{handle,_}:"spawn-refused:" ++ U32.show(W.handle_index(~S.SchemaA,handle))
    case _:"other"
def RawOwner() -> Type:Cmd.System(~S.SchemaA,~Run.CombinedColumns(),~Run.CombinedResources(),~Unit,~S.layout_b(),~Run.combined_resources(),~L.InLeft{L.AtLeaf{}},~Ops,~User,~String,~Maybe<&2,U32>,~declaration,~body)
def RawBinding() -> Type:Scope.CompiledBinding<Compilation(),RawOwner()>
def Evidence() -> Data:Author.AdmissionEvidence(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,~L.InLeft{L.AtLeaf{}},~Ops,~User,~String,~Maybe<&2,U32>,~declaration,~body)
def PrepPermit() -> Data:Author.PrepPermit(~S.SchemaA,~S.layout_b())
def snapshot_returned(compilation:Compilation(),namespace:U32,id:U32,name:String,last:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,user:User,permission:Permission.Permission,result:Buffer.Buffer<S.SchemaA,L.payload(S.layout_b(),L.InLeft{L.AtLeaf{}}),Removed.Removed(S.layout_b())> & Inspector.Snapshot<S.SchemaA>) -> RawBinding() & String:
  match user result:
    case User{bundle,+calls}, (queue,Inspector.Snapshot{pending,receipts}):(Scope.CompiledBinding{compilation,Sys.Owner{namespace,id,name,last,cursor,Local.Local{User{bundle,calls},queue,permission}}},"pending=" ++ List.show(&2,Inspector.Pending<S.SchemaA>,pending_text,pending) ++ ";receipts=" ++ List.show(&2,Inspector.Receipt<S.SchemaA>,receipt_text,receipts) ++ ";author-cursor=" ++ Tick.cursor_show(cursor) ++ ";calls=" ++ U32.show(calls))
def snapshot_binding(binding:Scope.CompiledBinding<Compilation(),Cmd.System(~S.SchemaA,~Run.CombinedColumns(),~Run.CombinedResources(),~Unit,~S.layout_b(),~Run.combined_resources(),~L.InLeft{L.AtLeaf{}},~Ops,~User,~String,~Maybe<&2,U32>,~declaration,~body)>) -> RawBinding() & String:
  match binding:
    case Scope.CompiledBinding{compilation,Sys.Owner{namespace,id,name,last,cursor,Local.Local{user,queue,permission}}}:snapshot_returned(compilation,namespace,id,name,last,cursor,user,permission,Inspector.snapshot(S.SchemaA,L.payload(S.layout_b(),L.InLeft{L.AtLeaf{}}),Removed.Removed(S.layout_b()),queue))
def snapshot_rebuilt(rebuild:RawBinding() -> AuthorNode(),result:RawBinding() & String) -> AuthorNode() & String:
  match result:
    case (binding,text):(rebuild(binding),text)
def snapshot_ready(namespace:U32,permits:List<&2,PrepPermit()>,provenance:Prep.Provenance<PrepPermit()>,evidence:Maybe<&2,Evidence()>,binding:RawBinding()) -> AuthorNode():
  match binding:
    case Scope.CompiledBinding{compilation,owner}:Leaf.Prepared{Execution.HeldReady{Compiled.Binding{compilation,Prep.Prepared{namespace,owner,permits,provenance},evidence}}}
def snapshot_inventory(provenance:Prep.Provenance<PrepPermit()>,evidence:Maybe<&2,Evidence()>,binding:RawBinding()) -> AuthorNode():
  match binding:
    case Scope.CompiledBinding{compilation,owner}:Leaf.Prepared{Execution.HeldInventory{compilation,Prep.Inventory{owner,provenance},evidence}}
def snapshot(node:AuthorNode()) -> AuthorNode() & String:
  match node:
    case Leaf.Uninspected{binding}:snapshot_rebuilt(binding => Leaf.Uninspected{binding},snapshot_binding(binding))
    case Leaf.Inspected{binding,evidence,id,valid}:snapshot_rebuilt(binding => Leaf.Inspected{binding,evidence,id,valid},snapshot_binding(binding))
    case Leaf.Prepared{Execution.HeldReady{Compiled.Binding{compilation,Prep.Prepared{namespace,owner,permits,provenance},evidence}}}:snapshot_rebuilt(binding => snapshot_ready(namespace,permits,provenance,evidence,binding),snapshot_binding(Scope.CompiledBinding{compilation,owner}))
    case Leaf.Prepared{Execution.HeldInventory{compilation,Prep.Inventory{owner,provenance},evidence}}:snapshot_rebuilt(binding => snapshot_inventory(provenance,evidence,binding),snapshot_binding(Scope.CompiledBinding{compilation,owner}))
def storage_text(storage:Root.Storage<S.SchemaA,S.layout_b(),Run.combined_resources(),Unit>) -> Root.Storage<S.SchemaA,S.layout_b(),Run.combined_resources(),Unit> & String:
  match storage:
    case Root.Present{W.World{+namespace,allocator,store,resources,events,pending,registrations,next,+clock,lifecycle},displaced}:(Root.Present{W.World{namespace,allocator,store,resources,events,pending,registrations,next,clock,lifecycle},displaced},"namespace=" ++ U32.show(namespace) ++ ";clock=" ++ Tick.cursor_show(Some{Clock.now(clock)}))
    case storage:(storage,"inventory-retained")
def observed_storage(rebuild:Root.Storage<S.SchemaA,S.layout_b(),Run.combined_resources(),Unit> -> ScheduledApplication(),text:String,result:Root.Storage<S.SchemaA,S.layout_b(),Run.combined_resources(),Unit> & String) -> ScheduledApplication() & String:
  match result:
    case (storage,stateText):(rebuild(storage),text ++ ";" ++ stateText)
def observed(left:AuthorNode() & String,right:Run.CombinedRightNode(False{}),storage:Root.Storage<S.SchemaA,S.layout_b(),Run.combined_resources(),Unit>,guards:Guard(),handler:U32,stateBindings:List<&2,App.Binding>,plan:Plan.Build<String>,bindings:List<&2,App.Binding>,rules:Part.Rules,settings:RootApp.Deferred) -> ScheduledApplication() & String:
  match left:
    case (left,text):observed_storage(storage => RootApp.Scheduled{App.State{storage,Product.Owner{left,right},guards,handler,stateBindings},plan,bindings,rules,settings},text,storage_text(storage))
def observe_scheduled(app:ScheduledApplication()) -> ScheduledApplication() & String:
  match app:
    case RootApp.Scheduled{App.State{storage,Product.Owner{left,right},guards,handler,stateBindings},plan,bindings,rules,settings}:observed(snapshot(left),right,storage,guards,handler,stateBindings,plan,bindings,rules,settings)
def shield_value(+label:String,+cache:U32,result:Array<U32> & U32) -> L.Viewed<S.Shield,U32> & String:
  match result:
    case (values,value):(L.Viewed{S.Shield{label,values},cache},label ++ ":" ++ U32.show(value) ++ "/cache:" ++ U32.show(cache))
def shield(value:L.Viewed<S.Shield,U32>) -> L.Viewed<S.Shield,U32> & String:
  match value:
    case L.Viewed{S.Shield{label,values},cache}:shield_value(label,cache,Array.get(U32,values,0))
def shield_column(-Rest:Type,rest:Rest,result:Column.Column<S.SchemaA,L.Viewed<S.Shield,U32>> & Maybe<&2,String>) -> Product.Owner<L.columns(~S.SchemaA,S.shields()),Rest> & String:
  match result:
    case (column,Some{text}):(Product.Owner{L.ColumnSlot{column},rest},text)
    case (column,None{}):(Product.Owner{L.ColumnSlot{column},rest},"absent")
def shield_store(store:Run.WC()) -> Run.WC() & String:
  # The scene's twenty initial handles precede the observed Spawned handle 21.
  # This trusted terminal storage observation does not grant gameplay access.
  match store:
    case Product.Owner{L.ColumnSlot{column},rest}:shield_column(L.columns(~S.SchemaA,L.LayoutPair{S.positions(),S.changed_origin()}),rest,Column.view(~S.SchemaA,~L.Viewed<S.Shield,U32>,~String,~shield,column,20))
def final_world(result:Run.CombinedWorld() & String) -> IO(Unit):
  match result:
    case (_,text):IO.print("cmd-spawn-payload=" ++ text)
def final_storage(storage:Root.Storage<S.SchemaA,S.layout_b(),Run.combined_resources(),Unit>) -> IO(Unit):
  match storage:
    case Root.Present{world,_}:final_world(W.with_store(~S.SchemaA,~Run.WC(),~L.resources(~S.SchemaA,Run.combined_resources()),~Unit,~String,shield_store,world))
    case _:IO.print("cmd-final-inventory-retained")
def final_peer(storage:Root.Storage<S.SchemaA,S.layout_b(),Run.combined_resources(),Unit>,owner:Peer()) -> IO(Unit):
  match owner:
    case Sys.Owner{_,_,_,_,cursor,Run.CombinedLocal{token}}:IO.bind(Unit,Unit,IO.print("cmd-peer=" ++ Setup.local_text(token) ++ ";cursor=" ++ Tick.cursor_show(cursor)),_ => final_storage(storage))
def final_scheduled(app:ScheduledApplication()) -> IO(Unit):
  match app:
    case RootApp.Scheduled{App.State{storage,Product.Owner{_,right},Scope.CompiledBinding{_,guard},handler,_},_,_,_,_}:IO.bind(Unit,Unit,IO.print("cmd-guard=" ++ Run.root_guard_text(guard) ++ ";handler=" ++ U32.show(handler)),_ => final_peer(storage,Run.combined_restore_right(~False{},right)))
def observed_bound(+context:CapturedContext(),result:ScheduledApplication() & String) -> Application() & String:
  match result:
    case (app,text):(Context.Bound{context,app},text)
def observe(bound:Application()) -> Application() & String:
  match bound:
    case Context.Bound{context,app}:observed_bound(context,observe_scheduled(app))
def final_application(bound:Application()) -> IO(Unit):
  match bound:
    case Context.Bound{_,app}:final_scheduled(app)
def finish(result:Application() & Context.RunReport<App.Report<String,Maybe<&2,U32>>>) -> IO(Unit):
  match result:
    case (app,Context.RunReported{report}):IO.bind(Unit,Unit,IO.print("cmd-final=" ++ Run.root_report(report)),_ => final_application(app))
    case (app,Context.ContextRefused{}):IO.bind(Unit,Unit,IO.print("cmd-context-refused"),_ => final_application(app))
def flush_observed(report:App.Report<String,Maybe<&2,U32>>,result:Application() & String) -> IO(Unit):
  match result:
    case (app,text):IO.bind(Unit,Unit,IO.print("cmd-flush=" ++ Run.root_report(report) ++ ";" ++ text),_ => IO.bind(Application() & Context.RunReport<App.Report<String,Maybe<&2,U32>>>,Unit,run(app),finish))
def flushed(result:Application() & Context.RunReport<App.Report<String,Maybe<&2,U32>>>) -> IO(Unit):
  match result:
    case (app,Context.RunReported{report}):flush_observed(report,observe(app))
    case (app,Context.ContextRefused{}):IO.bind(Unit,Unit,IO.print("cmd-context-refused"),_ => final_application(app))
def first_observed(report:App.Report<String,Maybe<&2,U32>>,result:Application() & String) -> IO(Unit):
  match result:
    case (app,text):IO.bind(Unit,Unit,IO.print("cmd-retained=" ++ Run.root_report(report) ++ ";" ++ text),_ => IO.bind(Application() & Context.RunReport<App.Report<String,Maybe<&2,U32>>>,Unit,run(configure(True{},app)),flushed))
def first(result:Application() & Context.RunReport<App.Report<String,Maybe<&2,U32>>>) -> IO(Unit):
  match result:
    case (app,Context.RunReported{report}):first_observed(report,observe(app))
    case (app,Context.ContextRefused{}):IO.bind(Unit,Unit,IO.print("cmd-context-refused"),_ => final_application(app))
def foreign_observed(+context:CapturedContext(),result:Application() & String) -> IO(Unit):
  match result:
    case (Context.Bound{_,app},text):IO.bind(Unit,Unit,IO.print("cmd-foreign=context-refused;" ++ text),_ => IO.bind(Application() & Context.RunReport<App.Report<String,Maybe<&2,U32>>>,Unit,run(Context.Bound{context,app}),first))
def foreign_refused(+context:CapturedContext(),result:Application() & Context.RunReport<App.Report<String,Maybe<&2,U32>>>) -> IO(Unit):
  match result:
    case (app,Context.ContextRefused{}):foreign_observed(context,observe(app))
    case (app,Context.RunReported{report}):IO.bind(Unit,Unit,IO.print("cmd-foreign-unexpected=" ++ Run.root_report(report)),_ => final_application(app))
def guarded(+context:CapturedContext(),+foreign:CapturedContext(),left:Binding(),right:PeerBinding(),result:GuardCompilation() & Sys.Defined<Run.CombinedWorld(),Run.RootGuard(),U32>) -> IO(Unit):
  match result:
    case (compilation,Sys.Defined{world,guard}):IO.bind(Application() & Context.RunReport<App.Report<String,Maybe<&2,U32>>>,Unit,run(Context.Bound{foreign,configure_scheduled(False{},Root.build(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,~Nodes(),~Guard(),~U32,~String,~guard_dispatch(),~Run.root_available,world,Tree.generalized_pair_facts(AuthorNode(),Run.CombinedRightNode(False{}),Author.facts(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,~L.InLeft{L.AtLeaf{}},~Ops,~User,~String,~Maybe<&2,U32>,~declaration,~body,left),Tree.generalized_leaf_facts(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,~String,~Maybe<&2,U32>,~Run.CombinedRightOps,~Run.CombinedLocal,~Run.combined_right_kernel(False{}),~Run.combined_right_body,right)),Conditions.compile_retained_leaf(~String,~S.SchemaA,~Run.WC(),~L.resources(~S.SchemaA,Run.combined_resources()),~Unit,~Run.RootGuardOps,~U32,~Run.root_guard_kernel,~Run.root_guard_body,~guard_construction(),Scope.CompiledBinding{compilation,guard}),0,[],[App.Binding{1,3},App.Binding{2,3}]))}),result => foreign_refused(context,result))
    case (_,Sys.DefinitionRefused{_,_}):IO.print("cmd-guard-registration-refused")
def peer_defined(+context:CapturedContext(),+foreign:CapturedContext(),left:Binding(),result:PeerCompilation() & Sys.Defined<Run.CombinedWorld(),Peer(),Run.CombinedLocal>) -> IO(Unit):
  match result:
    case (compilation,Sys.Defined{world,owner}):guarded(context,foreign,left,Scope.CompiledBinding{compilation,owner},System.define_with_compilation(~S.SchemaA,~Run.WC(),~Run.WC(),~L.resources(~S.SchemaA,Run.combined_resources()),~Unit,~Run.RootGuardOps,~U32,~String,~Bool,~Run.root_guard_kernel,~Run.root_guard_body,~L.resources(~S.SchemaA,Run.combined_resources()),guard_construction(),world,"cmd-root-guard",0))
    case (_,Sys.DefinitionRefused{_,_}):IO.print("cmd-peer-registration-refused")
def author_defined(+context:CapturedContext(),+foreign:CapturedContext(),result:Compilation() & Sys.Defined<Run.CombinedWorld(),Owner(),Cmd.Captures(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~L.InLeft{L.AtLeaf{}},~User)>) -> IO(Unit):
  match result:
    case (compilation,Sys.Defined{world,owner}):peer_defined(context,foreign,Scope.CompiledBinding{compilation,owner},System.define_with_compilation(~S.SchemaA,~Run.WC(),~Run.CombinedColumns(),~Run.CombinedResources(),~Unit,~Run.CombinedRightOps,~Run.CombinedLocal,~String,~Maybe<&2,U32>,~Run.combined_right_kernel(False{}),~Run.combined_right_body,~L.resources(~S.SchemaA,Run.combined_resources()),Run.combined_right_compiled(~False{}),world,"cmd-root-peer",Run.CombinedLocal{Run.CombinedArray{ALeaf{200}}}))
    case (_,Sys.DefinitionRefused{_,_}):IO.print("cmd-author-registration-refused")
def foreign_created(+context:CapturedContext(),world:Run.CombinedWorld(),result:Context.Initialization<S.SchemaA,S.layout_b(),Run.combined_resources(),Unit>) -> IO(Unit):
  match result:
    case Context.ContextCreated{_,_,foreign}:author_defined(context,foreign,Author.define_with_compilation(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,~L.InLeft{L.AtLeaf{}},~Ops,~User,~String,~Maybe<&2,U32>,~declaration,~body,~{==},compilation(),Setup.live(20n,Setup.initialize(world)),"cmd-root-author",User{Some{Product.Owner{Some{S.Shield{"spawn-affine",ALeaf{901}}},Product.Owner{None{},None{}}}},0}))
    case _:IO.print("cmd-foreign-schema-refused")
def created(result:Context.Initialization<S.SchemaA,S.layout_b(),Run.combined_resources(),Unit>) -> IO(Unit):
  match result:
    case Context.ContextCreated{factory,world,context}:foreign_created(context,world,Context.from_schema(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,Schema.create(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,factory,Setup.resources())))
    case _:IO.print("cmd-schema-creation-refused")
def main() -> IO(Unit):
  created(Context.from_schema(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,Schema.create(~S.SchemaA,~S.layout_b(),~Run.combined_resources(),~Unit,W.factory(),Setup.resources())))
