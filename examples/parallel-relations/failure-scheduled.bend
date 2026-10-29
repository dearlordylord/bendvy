import Base
import ./actor.bend as Actor
import ./setup.bend as Scene
import ./scheduled.bend as Existing
import ./failure-reader.bend as Reader
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-relation-failure-retention.bend as Retention
import ../../src/ecs/execution-lifecycle-maintenance.bend as Lifecycle
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/world.bend as W

def Left(~S:Data) -> Type:Product.Owner<Actor.Owner(~S),Reader.Owner(~S)>
def Owners(~S:Data) -> Type:Product.Owner<Left(~S),Existing.Peer(~S)>
def State(~S:Data) -> Type:App.State<Existing.World(~S),Owners(~S),Unit,Unit>
def Application(~S:Data) -> Type:Root.Scheduled<State(~S)>
def Bound(~S:Data) -> Type:Context.Bound<S,Existing.Resources(~S),Actor.resources(~S),{==},Application(~S)>
def reader_leaf(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Existing.Columns(~S),~Actor.C(~S),~Actor.R(~S),~Unit,~Actor.resources(~S),~String,~String,~F),~command:Tree.CommandLeaf(~S,~Existing.Columns(~S),~Actor.C(~S),~Actor.R(~S),~Unit,~Actor.resources(~S),~String,~String,~F),~join:Tree.Join(~F),owner:Reader.Owner(~S)) -> F(Reader.Owner(~S)):
  leaf(Reader.Ops(~S),Reader.State(~S),Build.framework_program(~S,~Existing.Columns(~S),~Actor.C(~S),~Actor.R(~S),~Reader.Ops(~S),~Reader.declaration(~S)),Reader.body(~S),owner)
def left(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Existing.Columns(~S),~Actor.C(~S),~Actor.R(~S),~Unit,~Actor.resources(~S),~String,~String,~F),~command:Tree.CommandLeaf(~S,~Existing.Columns(~S),~Actor.C(~S),~Actor.R(~S),~Unit,~Actor.resources(~S),~String,~String,~F),~join:Tree.Join(~F),owners:Left(~S)) -> F(Left(~S)):
  Tree.pair(~S,~Existing.Columns(~S),~Actor.C(~S),~Actor.R(~S),~Unit,~Actor.resources(~S),~String,~String,~Actor.Owner(~S),~Reader.Owner(~S),~Existing.left(~S),~reader_leaf(~S),~F,~leaf,~command,~join,owners)
def catalogue(~S:Data) -> Retention.Catalogue<S,Actor.resources(~S)>:
  Retention.add(~S,~Actor.resources(~S),~Actor.route(),~{==},~Scene.hierarchy(~S),~{==},~{==},~{==},Retention.none(~S,~Actor.resources(~S)))
def completed(~S:Data,program:Retention.Program(~S,~Actor.resources(~S)),result:Exec.ExecutionResult<State(~S),String,String,String>) -> Exec.ExecutionResult<State(~S),String,String,String>:
  Retention.completed(~S,~Existing.Columns(~S),~Existing.Resources(~S),~Unit,~Actor.resources(~S),~{==},~Owners(~S),~Unit,~Unit,~String,~String,program,Lifecycle.completed(~S,~Existing.Columns(~S),~Existing.Resources(~S),~Unit,~Owners(~S),~Unit,~Unit,~String,~String,result))
def run_application(~S:Data,program:Retention.Program(~S,~Actor.resources(~S)),application:Application(~S)) -> IO(Application(~S) & App.Report<String,String>):
  match application:
    case Root.Scheduled{state,+plan,+bindings,+rules,Root.Deferred{+systems,+settings,unapplied}}:Root.run_scheduled_built_owned(~State(~S),~String,~String,~Root.condition_state(~Existing.World(~S),~Owners(~S),~Unit,~Unit,~String,~Conditions.empty_dispatch(~Existing.World(~S),~String)),~Root.group_serial_state(~S,~Actor.C(~S),~Unit,~Actor.R(~S),~Existing.RightResources(~S),~Unit,~Actor.resources(~S),~{==},~String,~String,~Left(~S),~Existing.Peer(~S),~left(~S),~Existing.right(~S),~Unit,~Unit,~Conditions.empty_dispatch(~Existing.World(~S),~String),~Conditions.empty(~Existing.World(~S),~String),~Existing.handle),~Root.handle_state(~Existing.World(~S),~Owners(~S),~Unit,~Unit,~String,~Existing.handle),~Root.apply_state(~S,~Actor.C(~S),~Unit,~Actor.R(~S),~Existing.RightResources(~S),~Unit,~Actor.resources(~S),~{==},~String,~String,~Left(~S),~Existing.Peer(~S),~left(~S),~Existing.right(~S),~Unit,~Unit,~Conditions.empty_dispatch(~Existing.World(~S),~String),~Conditions.empty(~Existing.World(~S),~String),~Existing.handle),result => completed(~S,program,result),rules,systems,settings,plan,bindings,state,unapplied,Settings.compile(settings,systems,plan))

type Run<-S:Data> is Type:
  Returned{bound:Bound(~S),report:Context.RunReport<App.Report<String,String>>}
  CatalogueRefused{bound:Bound(~S),catalogue:Retention.Catalogue<S,Actor.resources(~S)>}
def bound_result(~S:Data,context:Context.Context<S,Existing.Resources(~S),Actor.resources(~S),{==}>,result:Application(~S) & App.Report<String,String>) -> Run<S>:
  match result:
    case (application,report):Returned{Context.Bound{context,application},Context.RunReported{report}}
def admitted(~S:Data,context:Context.Context<S,Existing.Resources(~S),Actor.resources(~S),{==}>,application:Application(~S),admission:Retention.Admission<S,Actor.resources(~S)>) -> IO(Run<S>):
  match admission:
    case Retention.Refused{catalogue}:IO.pure(Run<S>,CatalogueRefused{Context.Bound{context,application},catalogue})
    case Retention.Accepted{program}:Root.mapped(Application(~S) & App.Report<String,String>,Run<S>,run_application(~S,program,application),result => bound_result(~S,context,result))
def checked(~S:Data,allowed:Bool,bound:Bound(~S)) -> IO(Run<S>):
  match allowed bound:
    case False{} bound:IO.pure(Run<S>,Returned{bound,Context.ContextRefused{}})
    case True{} Context.Bound{context,application}:admitted(~S,context,application,Retention.prepare(~S,~Actor.resources(~S),catalogue(~S)))
def context_returned(~S:Data,context:Context.Context<S,Existing.Resources(~S),Actor.resources(~S),{==}>,restore:Existing.World(~S) -> Application(~S),result:Existing.World(~S) & Bool) -> Bound(~S) & Bool:
  match result:
    case (world,allowed):(Context.Bound{context,restore(world)},allowed)
def context_checked(~S:Data,bound:Bound(~S)) -> Bound(~S) & Bool:
  match bound:
    case Context.Bound{+context,Root.Scheduled{App.State{world,owners,guards,handler,stateBindings},plan,bindings,rules,deferred}}:context_returned(~S,context,world => Root.Scheduled{App.State{world,owners,guards,handler,stateBindings},plan,bindings,rules,deferred},Context.matches(~S,~Existing.Columns(~S),~Existing.Resources(~S),~Unit,~Actor.resources(~S),~{==},context,world))
def run_checked(~S:Data,result:Bound(~S) & Bool) -> IO(Run<S>):
  match result:
    case (bound,allowed):checked(~S,allowed,bound)
def run(~S:Data,bound:Bound(~S)) -> IO(Run<S>):run_checked(~S,context_checked(~S,bound))
def build(~S:Data,context:Context.Context<S,Existing.Resources(~S),Actor.resources(~S),{==}>,world:Existing.World(~S),actor:Actor.Owner(~S),reader:Reader.Owner(~S),peer:Existing.Peer(~S)) -> Bound(~S):
  Context.Bound{context,Root.build(~S,~Actor.C(~S),~Unit,~Actor.R(~S),~Existing.RightResources(~S),~Unit,~Actor.resources(~S),~{==},~String,~String,~Left(~S),~Existing.Peer(~S),~left(~S),~Existing.right(~S),~Unit,~Unit,~Conditions.empty_dispatch(~Existing.World(~S),~String),~Conditions.empty(~Existing.World(~S),~String),~Existing.handle,~Existing.available,world,Product.Owner{Product.Owner{actor,reader},peer},Unit{},Unit{},[],[])}
