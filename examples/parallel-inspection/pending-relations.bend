import Base
import ../parallel-relations/actor.bend as Actor
import ../parallel-relations/setup.bend as Setup
import ../parallel-relations/initialize.bend as Initialize
import ../parallel-relations/scheduled.bend as Scheduled
import ../parallel-relations/scene.bend as Scene
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/execution-inspector.bend as Modern
import ../../src/ecs/execution-inspector-application.bend as Inspect
import ../../src/ecs/execution-inspector-commands.bend as Commands
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-parallel-registration.bend as Registration
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/relation-types.bend as Relation
import ../../src/ecs/dependency-application.bend as State
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/check.bend as Check

def actor_returned(namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>,user:Actor.User<Scene.Schema>,permission:Permission.Permission,result:Buffer.Buffer<Scene.Schema,Unit,Removed.Removed(Actor.components())> & Commands.Snapshot<Scene.Schema>) -> Actor.Owner(~Scene.Schema) & Commands.Snapshot<Scene.Schema>:
  match result:
    case (buffer,view):(Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,buffer,permission}}},view)
def actor_snapshot(value:Actor.Owner(~Scene.Schema)) -> Actor.Owner(~Scene.Schema) & Commands.Snapshot<Scene.Schema>:
  match value:
    case Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,buffer,permission}}}:actor_returned(namespace,id,name,access,cursor,user,permission,Commands.snapshot(Scene.Schema,Unit,Removed.Removed(Actor.components()),buffer))
def app_returned(world:Scheduled.World(~Scene.Schema),peer:Scheduled.Peer(~Scene.Schema),guards:Unit,handler:Unit,stateBindings:List<&2,State.Binding>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,rules:Registration.Rules,deferred:Root.Deferred,result:Actor.Owner(~Scene.Schema) & Commands.Snapshot<Scene.Schema>) -> Scheduled.Application(~Scene.Schema) & Commands.Snapshot<Scene.Schema>:
  match result:
    case (actor,view):(Root.Scheduled{State.State{world,Product.Owner{actor,peer},guards,handler,stateBindings},plan,bindings,rules,deferred},view)
def app_snapshot(value:Scheduled.Application(~Scene.Schema)) -> Scheduled.Application(~Scene.Schema) & Commands.Snapshot<Scene.Schema>:
  match value:
    case Root.Scheduled{State.State{world,Product.Owner{actor,peer},guards,handler,stateBindings},plan,bindings,rules,deferred}:app_returned(world,peer,guards,handler,stateBindings,plan,bindings,rules,deferred,actor_snapshot(actor))
def bound_returned(context:Context.Context<Scene.Schema,Scheduled.Resources(~Scene.Schema),Actor.resources(~Scene.Schema),{==}>,result:Scheduled.Application(~Scene.Schema) & Commands.Snapshot<Scene.Schema>) -> Scheduled.Bound(~Scene.Schema) & Commands.Snapshot<Scene.Schema>:
  match result:
    case (app,view):(Context.Bound{context,app},view)
def snapshot(value:Scheduled.Bound(~Scene.Schema)) -> Scheduled.Bound(~Scene.Schema) & Commands.Snapshot<Scene.Schema>:
  match value:
    case Context.Bound{context,app}:bound_returned(context,app_snapshot(app))
def pending(value:Commands.Pending<Scene.Schema>) -> String:
  match value:
    case Commands.Relation{_,operation}:Scene.operation(operation)
    case _:"component-command"
def receipt(value:Commands.Receipt<Scene.Schema>) -> String:
  match value:
    case Commands.RelationPublished{_,Store.Applied{operation}}:"applied:" ++ Scene.operation(operation)
    case Commands.RelationPublished{_,Store.Refused{operation,_}}:"refused:" ++ Scene.operation(operation)
    case _:"other-receipt"
def snapshot_text(value:Commands.Snapshot<Scene.Schema>) -> String:
  match value:
    case Commands.Snapshot{pendingValues,receipts}:"pending=" ++ List.show(&2,Commands.Pending<Scene.Schema>,pending,pendingValues) ++ ";receipts=" ++ List.show(&2,Commands.Receipt<Scene.Schema>,receipt,receipts)
def Ops(H:Type) -> Type:Cap.ValueRead<H,Store.View<Scene.Schema,Setup.hierarchy(~Scene.Schema)>>
def plan() -> I.Plan<Scene.Schema,Scheduled.Columns(~Scene.Schema),Scheduled.Resources(~Scene.Schema),Unit,Ops>:
  I.Plan{Modern.resource_grant(~I.Frame<Scene.Schema,Scheduled.Columns(~Scene.Schema),Scheduled.Resources(~Scene.Schema),Unit>,~Store.View<Scene.Schema,Setup.hierarchy(~Scene.Schema)>,Modern.resource(~Scene.Schema,~Scheduled.Columns(~Scene.Schema),~Scheduled.Resources(~Scene.Schema),~Unit,~Actor.resources(~Scene.Schema),~L.InLeft{L.AtLeaf{}},~{==},~{==}))}
def graph_read(~H:Type,result:H & Store.View<Scene.Schema,Setup.hierarchy(~Scene.Schema)>) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,Store.View{namespace,Relation.Graph{edges,inverses}}):(owner,Done{U32.show(namespace) ++ "/" ++ List.show(&2,Relation.Edge<Scene.Schema>,Scene.edge,edges) ++ "/" ++ List.show(&2,Relation.Inverse<Scene.Schema>,Scene.inverse,inverses)})
def body(~H:Type,~cap:Ops(H),_:Unit,owner:H) -> H & Result<&2,&2,String,String>:
  graph_read(~H,Cap.value_read(~H,~Store.View<Scene.Schema,Setup.hierarchy(~Scene.Schema)>,~cap,owner))
def inspected(context:Context.Context<Scene.Schema,Scheduled.Resources(~Scene.Schema),Actor.resources(~Scene.Schema),{==}>,result:Scheduled.Application(~Scene.Schema) & (I.Instance<Scene.Schema> & Result<&2,&2,String,String>)) -> Scheduled.Bound(~Scene.Schema) & String:
  match result:
    case (app,(_,Done{graph})):(Context.Bound{context,app},graph)
    case (app,(_,Fail{error})):(Context.Bound{context,app},error)
def inspect(value:Scheduled.Bound(~Scene.Schema)) -> Scheduled.Bound(~Scene.Schema) & String:
  match value:
    case Context.Bound{context,app}:inspected(context,Inspect.passive(~Scene.Schema,~Scheduled.Columns(~Scene.Schema),~Scheduled.Resources(~Scene.Schema),~Unit,~Product.Owner<Actor.Owner(~Scene.Schema),Scheduled.Peer(~Scene.Schema)>,~Unit,~Unit,~Ops,~Unit,~String,~String,~plan(),~body,app,I.Fresh{},Unit{}))
def configure(final:Bool,value:Scheduled.Bound(~Scene.Schema)) -> Scheduled.Bound(~Scene.Schema):
  match value:
    case Context.Bound{context,app}:Context.Bound{context,Root.configure(~State.State<Scheduled.World(~Scene.Schema),Product.Owner<Actor.Owner(~Scene.Schema),Scheduled.Peer(~Scene.Schema)>,Unit,Unit>,Settings.Settings{False{},final,[],[]},app)}
def checked_graph(~H:Type,result:H & Store.View<Scene.Schema,Setup.hierarchy(~Scene.Schema)>) -> H & Bool:
  match result:
    case (owner,Store.View{_,Relation.Graph{[],_}}):(owner,False{})
    case (owner,_):(owner,True{})
def check_body(~H:Type,~cap:Ops(H),_:Unit,owner:H) -> H & Bool:
  checked_graph(~H,Cap.value_read(~H,~Store.View<Scene.Schema,Setup.hierarchy(~Scene.Schema)>,~cap,owner))
def required(world:Scheduled.World(~Scene.Schema)) -> Scheduled.World(~Scene.Schema) & List<&2,String>:(world,[])
def check_plan() -> Check.Plan<Scene.Schema,Scheduled.Columns(~Scene.Schema),Scheduled.Resources(~Scene.Schema),Unit,Ops>:
  Check.Plan{required,Modern.resource_grant(~Check.Frame<Scene.Schema,Scheduled.Columns(~Scene.Schema),Scheduled.Resources(~Scene.Schema),Unit>,~Store.View<Scene.Schema,Setup.hierarchy(~Scene.Schema)>,Modern.check_resource(~Scene.Schema,~Scheduled.Columns(~Scene.Schema),~Scheduled.Resources(~Scene.Schema),~Unit,~Actor.resources(~Scene.Schema),~L.InLeft{L.AtLeaf{}},~{==},~{==}))}
def check_returned(context:Context.Context<Scene.Schema,Scheduled.Resources(~Scene.Schema),Actor.resources(~Scene.Schema),{==}>,result:Scheduled.Application(~Scene.Schema) & Result<&2,&2,Check.Error,Bool>) -> Scheduled.Bound(~Scene.Schema) & String:
  match result:
    case (app,Done{value}):(Context.Bound{context,app},Bool.show(value))
    case (app,Fail{_}):(Context.Bound{context,app},"check-refused")
def check(value:Scheduled.Bound(~Scene.Schema)) -> Scheduled.Bound(~Scene.Schema) & String:
  match value:
    case Context.Bound{context,app}:check_returned(context,Inspect.check(~Scene.Schema,~Scheduled.Columns(~Scene.Schema),~Scheduled.Resources(~Scene.Schema),~Unit,~Product.Owner<Actor.Owner(~Scene.Schema),Scheduled.Peer(~Scene.Schema)>,~Unit,~Unit,~Ops,~Unit,~check_plan(),~check_body,app,Unit{}))
def observed_finished(trace:String,result:Scheduled.Bound(~Scene.Schema) & String) -> IO(Unit):
  match result:
    case (bound,checked):IO.print(trace ++ "|check=" ++ checked ++ "|" ++ Scene.application(bound))
def inspected_finished(trace:String,result:Scheduled.Bound(~Scene.Schema) & String) -> IO(Unit):
  match result:
    case (bound,graph):observed_finished(trace ++ "|published-passive-graph=" ++ graph,check(bound))
def finished(before:String,graph:String,after:String,result:Scheduled.Bound(~Scene.Schema) & Context.RunReport<State.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,status):inspected_finished("before=" ++ before ++ "|passive-graph=" ++ graph ++ "|after=" ++ after ++ "|" ++ Scene.report(status),inspect(bound))
def resnapshotted(before:String,graph:String,result:Scheduled.Bound(~Scene.Schema) & Commands.Snapshot<Scene.Schema>) -> IO(Unit):
  match result:
    case (bound,view):IO.bind(Scheduled.Bound(~Scene.Schema) & Context.RunReport<State.Report<String,String>>,Unit,Scheduled.run_once(~Scene.Schema,configure(True{},bound)),next=>finished(before,graph,snapshot_text(view),next))
def read_graph(before:String,result:Scheduled.Bound(~Scene.Schema) & String) -> IO(Unit):
  match result:
    case (bound,graph):resnapshotted(before,graph,snapshot(bound))
def snapshotted(result:Scheduled.Bound(~Scene.Schema) & Commands.Snapshot<Scene.Schema>) -> IO(Unit):
  match result:
    case (bound,view):read_graph(snapshot_text(view),inspect(bound))
def ran(result:Scheduled.Bound(~Scene.Schema) & Context.RunReport<State.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,_):snapshotted(snapshot(bound))
def initialized(result:Initialize.Initialization<Scene.Schema>) -> IO(Unit):
  match result:
    case Initialize.SceneInitialized{_,Scheduled.SceneReady{bound}}:IO.bind(Scheduled.Bound(~Scene.Schema) & Context.RunReport<State.Report<String,String>>,Unit,Scheduled.run_once(~Scene.Schema,configure(False{},bound)),ran)
    case _:IO.print("initialization-refused")
def main() -> IO(Unit):initialized(Initialize.create(~Scene.Schema,W.factory(),Actor.Session{401},Actor.Session{601}))
