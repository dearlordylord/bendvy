import Base
import ./extended-declarations.bend as Schema
import ./extended-programs.bend as P
import ./extended-target.bend as Target
import ./extended-admission.bend as Admission
import ./extended-restore.bend as Restore
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-command-retention.bend as Retention
import ../../src/ecs/execution-parallel-system.bend as Define
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-parallel-registration.bend as Part
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/execution-restore-publication.bend as Publication
import ./restore.bend as Ordinary
import ../../src/ecs/execution-restore-receiver.bend as Receiver

type Handler<-S:Data> is Type:Handler{capture:Array<U32>,handled:U32,reader:Maybe<&1,Target.Reader(~S)>}
def handle(~S:Data,handler:Handler<S>,_:String) -> Handler<S> & Exec.Handling:
  match handler:
    case Handler{capture,handled,reader}:(Handler{capture,U32.add(handled,1),reader},Exec.Continue{})
def dispatch(~S:Data) -> Conditions.Dispatch(~Schema.World(~S),~P.Guard(~S),~String):Conditions.retained_leaf_dispatch(~S,~P.Columns(~S),~Schema.Resources(~S),~Unit,~P.GuardOps(~S),~P.Local,~String,~P.guard_declaration(~S),~P.guard_body(~S),~P.guard_construction(~S))
def guard_selection(~S:Data,~F:Conditions.Family(~String),~leaf:Conditions.RetainedLeaf(~String,~F),~pair:Conditions.Join(~String,~F),~empty:Conditions.Vacant(~String,~F),guard:P.Guard(~S)) -> F(Schema.World(~S),P.Guard(~S),dispatch(~S)):leaf(S,P.Columns(~S),Schema.Resources(~S),Unit,P.GuardOps(~S),P.Local,P.guard_declaration(~S),P.guard_body(~S),P.guard_construction(~S),guard)
def left(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~P.Columns(~S),~P.LeftColumn(~S),~P.LeftResource(~S),~Unit,~Schema.resource_layout(~S),~String,~String,~F),~command:Tree.CommandLeaf(~S,~P.Columns(~S),~P.LeftColumn(~S),~P.LeftResource(~S),~Unit,~Schema.resource_layout(~S),~String,~String,~F),~join:Tree.Join(~F),owner:P.Left(~S)) -> F(P.Left(~S)):leaf(P.LeftOps(~S),P.Local,P.left_declaration(~S),P.left_body(~S),owner)
def right(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~P.Columns(~S),~P.RightColumn(~S),~P.RightResource(~S),~Unit,~Schema.resource_layout(~S),~String,~String,~F),~command:Tree.CommandLeaf(~S,~P.Columns(~S),~P.RightColumn(~S),~P.RightResource(~S),~Unit,~Schema.resource_layout(~S),~String,~String,~F),~join:Tree.Join(~F),owner:P.Right(~S)) -> F(P.Right(~S)):leaf(P.RightOps(~S),P.Local,P.right_declaration(~S),P.right_body(~S),owner)
def Application(~S:Data) -> Type:Schedule.Scheduled<App.State<Schema.World(~S),Product.Owner<P.Left(~S),P.Right(~S)>,P.Guard(~S),Handler<S>>>
def build(~S:Data,world:Schema.World(~S),l:P.Left(~S),r:P.Right(~S),guard:P.Guard(~S),reader:Maybe<&1,Target.Reader(~S)>) -> Application(~S):Schedule.build_retained(~S,~P.LeftColumn(~S),~P.RightColumn(~S),~P.LeftResource(~S),~P.RightResource(~S),~Unit,~Schema.resource_layout(~S),~{==},~String,~String,~P.Left(~S),~P.Right(~S),~left(~S),~right(~S),~P.Guard(~S),~Handler<S>,~dispatch(~S),~guard_selection(~S),~handle(~S),~(key => True{}),world,Product.Owner{l,r},guard,Handler{ALeaf{803},0,reader},[],[App.Binding{2,3}])
type Defined<-S:Data> is Type:
  Defined{app:Application(~S)}
  LeftRefused{world:Schema.World(~S),local:P.Local,reader:Maybe<&1,Target.Reader(~S)>}
  RightRefused{world:Schema.World(~S),left:P.Left(~S),local:P.Local,reader:Maybe<&1,Target.Reader(~S)>}
  GuardRefused{world:Schema.World(~S),left:P.Left(~S),right:P.Right(~S),compilation:P.GuardCompilation(~S),local:P.Local,reader:Maybe<&1,Target.Reader(~S)>}
def guard_defined(~S:Data,l:P.Left(~S),r:P.Right(~S),reader:Maybe<&1,Target.Reader(~S)>,result:P.GuardCompilation(~S) & Sys.Defined<Schema.World(~S),P.GuardOwner(~S),P.Local>) -> Defined<S>:
  match result:
    case (compilation,Sys.Defined{world,guard}):Defined{build(~S,world,l,r,Scope.CompiledBinding{compilation,guard},reader)}
    case (compilation,Sys.DefinitionRefused{world,local}):GuardRefused{world,l,r,compilation,local,reader}
def right_defined(~S:Data,l:P.Left(~S),reader:Maybe<&1,Target.Reader(~S)>,result:Sys.Defined<Schema.World(~S),P.Right(~S),P.Local>) -> Defined<S>:
  match result:
    case Sys.Defined{world,r}:guard_defined(~S,l,r,reader,Define.define_with_compilation(~S,~P.Columns(~S),~P.Columns(~S),~Schema.Resources(~S),~Unit,~P.GuardOps(~S),~P.Local,~String,~Bool,~P.guard_declaration(~S),~P.guard_body(~S),~Schema.Resources(~S),P.guard_construction(~S),world,"restored-waiting",P.Local{ALeaf{903},0}))
    case Sys.DefinitionRefused{world,local}:RightRefused{world,l,local,reader}
def left_defined(~S:Data,reader:Maybe<&1,Target.Reader(~S)>,result:Sys.Defined<Schema.World(~S),P.Left(~S),P.Local>) -> Defined<S>:
  match result:
    case Sys.Defined{world,l}:right_defined(~S,l,reader,Define.define_framework(~S,~P.Columns(~S),~P.RightColumn(~S),~P.RightResource(~S),~Unit,~P.RightOps(~S),~P.Local,~String,~String,~P.right_declaration(~S),~P.right_body(~S),~Schema.Resources(~S),world,"restored-transition",P.Local{ALeaf{703},0}))
    case Sys.DefinitionRefused{world,local}:LeftRefused{world,local,reader}
def setup(~S:Data,world:Schema.World(~S),reader:Maybe<&1,Target.Reader(~S)>) -> Defined<S>:left_defined(~S,reader,Define.define_framework(~S,~P.Columns(~S),~P.LeftColumn(~S),~P.LeftResource(~S),~Unit,~P.LeftOps(~S),~P.Local,~String,~String,~P.left_declaration(~S),~P.left_body(~S),~Schema.Resources(~S),world,"retained-graph-read",P.Local{ALeaf{603},0}))
def pending(~S:Data,app:Application(~S)) -> Application(~S) & Bool:
  match app:
    case Schedule.Scheduled{App.State{world,owners,guard,handler,stateBindings},plan,appBindings,rules,Schedule.Deferred{+systems,settings,unapplied}}:Schedule.pending_collected(~S,~P.LeftColumn(~S),~P.RightColumn(~S),~P.LeftResource(~S),~P.RightResource(~S),~Unit,~Schema.resource_layout(~S),~{==},~String,~String,~P.Left(~S),~P.Right(~S),~left(~S),~right(~S),~P.Guard(~S),~Handler<S>,~dispatch(~S),~handle(~S),world,guard,handler,stateBindings,plan,appBindings,rules,Schedule.Deferred{systems,settings,unapplied},Retention.collect_pair(~P.Left(~S),~P.Right(~S),Retention.collect(~S,~P.Columns(~S),~P.LeftColumn(~S),~P.LeftResource(~S),~Unit,~Schema.resource_layout(~S),~String,~String,~P.Left(~S),~left(~S)),Retention.collect(~S,~P.Columns(~S),~P.RightColumn(~S),~P.RightResource(~S),~Unit,~Schema.resource_layout(~S),~String,~String,~P.Right(~S),~right(~S)),systems,owners))
def run_serial(~S:Data,app:Application(~S)) -> IO(Application(~S) & App.Report<String,String>):Schedule.run_serial_retained(~S,~P.LeftColumn(~S),~P.RightColumn(~S),~P.LeftResource(~S),~P.RightResource(~S),~Unit,~Schema.resource_layout(~S),~{==},~String,~String,~P.Left(~S),~P.Right(~S),~left(~S),~right(~S),~P.Guard(~S),~Handler<S>,~dispatch(~S),~handle(~S),app)
def run_native(~S:Data,app:Application(~S)) -> IO(Application(~S) & App.Report<String,String>):Schedule.run_native_retained(~S,~P.LeftColumn(~S),~P.RightColumn(~S),~P.LeftResource(~S),~P.RightResource(~S),~Unit,~Schema.resource_layout(~S),~{==},~String,~String,~P.Left(~S),~P.Right(~S),~left(~S),~right(~S),~P.Guard(~S),~Handler<S>,~dispatch(~S),~handle(~S),app)
type Held<-S:Data> is Type:Held{owners:Product.Owner<P.Left(~S),P.Right(~S)>,guard:P.Guard(~S),handler:Handler<S>,stateBindings:List<&2,App.Binding>,plan:Plan.Build<String>,appBindings:List<&2,App.Binding>,rules:Part.Rules,deferred:Schedule.Deferred}
def rejoin(~S:Data,held:Held<S>,world:Schema.World(~S)) -> Application(~S):
  match held:
    case Held{owners,guard,handler,stateBindings,plan,appBindings,rules,deferred}:Schedule.Scheduled{App.State{world,owners,guard,handler,stateBindings},plan,appBindings,rules,deferred}
type Restoration<-S:Data> is Type:
  Pending{schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,app:Application(~S)}
  InputRefused{app:Application(~S),schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,reason:Admission.Reason}
  NamespaceRefused{app:Application(~S),state:Restore.State<S>}
  ReceiverRefused{app:Application(~S),state:Restore.State<S>,reason:Receiver.Reason}
  StagingRefused{app:Application(~S),state:Restore.State<S>,error:R.Error<Unit>}
  RowsRefused{app:Application(~S),state:Restore.State<S>,rows:List<Publication.Row<Schema.components(~S)>>}
  Restored{app:Application(~S),state:Restore.State<S>,removed:List<Ordinary.Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publication.Receipt<S,Schema.components(~S)>>,previous:Restore.Previous<S>}
  Refused{held:Held<S>,result:Restore.Outcome<S>}
def completed(~S:Data,held:Held<S>,result:Restore.Outcome<S>) -> Restoration<S>:
  match result:
    case Restore.InputRefused{world,schema,input,reason}:InputRefused{rejoin(~S,held,world),schema,input,reason}
    case Restore.NamespaceRefused{state,world}:NamespaceRefused{rejoin(~S,held,world),state}
    case Restore.ReceiverRefused{state,Receiver.Refused{world,reason}}:ReceiverRefused{rejoin(~S,held,world),state,reason}
    case Restore.StagingRefused{state,world,error}:StagingRefused{rejoin(~S,held,world),state,error}
    case Restore.RowsRefused{state,world,rows}:RowsRefused{rejoin(~S,held,world),state,rows}
    case Restore.Restored{state,world,removed,mapping,publications,previous}:Restored{rejoin(~S,held,world),state,removed,mapping,publications,previous}
    case result:Refused{held,result}
def checked(~S:Data,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,result:Application(~S) & Bool) -> Restoration<S>:
  match result:
    case (app,True{}):Pending{schema,input,app}
    case (Schedule.Scheduled{App.State{world,owners,guard,handler,stateBindings},plan,appBindings,rules,deferred},False{}):completed(~S,Held{owners,guard,handler,stateBindings,plan,appBindings,rules,deferred},Restore.restore(~S,schema,input,world))
def restore(~S:Data,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,app:Application(~S)) -> Restoration<S>:checked(~S,schema,input,pending(~S,app))
