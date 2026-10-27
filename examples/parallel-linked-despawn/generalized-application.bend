import Base
import ./actor.bend as Actor
import ./remover.bend as Remover
import ./setup.bend as Setup
import ./generalized-actors.bend as Actors
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-generalized-publication.bend as Publication
import ../../src/ecs/execution-provisioned-generalized-root.bend as ProvisionedRoot
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-schema-provisioning.bend as Provision
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-resource-query-composite.bend as Composite
import ../../src/ecs/execution-resource-query-group.bend as Group

def World(~S:Data) -> Type:W.World<S,L.columns(~S,Actor.components()),L.resources(~S,Actor.resources(~S)),Unit>
def Tail(~S:Data) -> Type:Product.Owner<Actors.RemovalNode(~S),Actors.UpdaterNode(~S)>
def Nodes(~S:Data) -> Type:Product.Owner<Actors.GraphNode(~S),Tail(~S)>
def Scheduled(~S:Data) -> Type:Root.Scheduled<App.State<General.Storage<S,Actor.components(),Actor.resources(~S),Unit>,Nodes(~S),Unit,Unit>>
def Bound(~S:Data) -> Type:Provision.Bound<S,L.resources(~S,Actor.resources(~S)),Actor.resources(~S),{==},Setup.Seed(~Actor.Session),Setup.blueprint(~S,~Actor.Session,~U32,~Actor.project),Scheduled(~S)>
def graph_leaf(~S:Data,node:Actors.GraphNode(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,Actors.GraphNode(~S),String,String>:
  Author.compile(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actors.GraphUser<S>,~String,~String,~Actors.graph_declaration(~S),~Actors.graph_body(~S),~Actors.graph_compilation(~S),node)
def removal_leaf(~S:Data,node:Actors.RemovalNode(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,Actors.RemovalNode(~S),String,String>:
  Author.compile(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Remover.Ops(~S),~Actors.RemovalUser<S>,~String,~String,~Actors.removal_declaration(~S),~Actors.removal_body(~S),~Actors.removal_compilation(~S),node)
def updater_leaf(~S:Data,node:Actors.UpdaterNode(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,Actors.UpdaterNode(~S),String,String>:
  Author.compile(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.UpdaterOps(~S),~Actors.UpdaterUser<S>,~String,~String,~Actors.updater_declaration(~S),~Actors.updater_body(~S),~Actors.updater_compilation(~S),node)
def tail_leaf(~S:Data,nodes:Tail(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,Tail(~S),String,String>:
  Composite.from_nodes(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Actors.RemovalNode(~S),~Actors.UpdaterNode(~S),~removal_leaf(~S),~updater_leaf(~S),nodes)
def dispatch(~S:Data,nodes:Nodes(~S),world:World(~S),ids:List<&2,U32>) -> IO(Execution.RunResult<S,Actor.components(),Actor.resources(~S),Unit,Nodes(~S),String,String>):
  match nodes:
    case Product.Owner{graph,tail}:Group.run_retained(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,Actors.GraphNode(~S),Tail(~S),ids,world,graph_leaf(~S,graph),tail_leaf(~S,tail))
def pending_tail(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Tail(~S)) -> World(~S) & (Tail(~S) & Bool):
  Tree.pending_pair(World(~S),Actors.RemovalNode(~S),Actors.UpdaterNode(~S),Author.pending(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Remover.Ops(~S),~Actors.RemovalUser<S>,~String,~String,~Actors.removal_declaration(~S),~Actors.removal_body(~S)),Author.pending(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.UpdaterOps(~S),~Actors.UpdaterUser<S>,~String,~String,~Actors.updater_declaration(~S),~Actors.updater_body(~S)),ids,world,nodes)
def pending(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & Bool):
  Tree.pending_pair(World(~S),Actors.GraphNode(~S),Tail(~S),Author.pending(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actors.GraphUser<S>,~String,~String,~Actors.graph_declaration(~S),~Actors.graph_body(~S)),pending_tail(~S),ids,world,nodes)
def publish_tail(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:Tail(~S)) -> World(~S) & Tail(~S):
  Tree.publish_pair(World(~S),Actors.RemovalNode(~S),Actors.UpdaterNode(~S),Author.publication(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Remover.Ops(~S),~Actors.RemovalUser<S>,~String,~String,~Actors.removal_declaration(~S),~Actors.removal_body(~S),~{==},~Actors.removal_compilation(~S),~Setup.Seed(~Actor.Session),~blueprint),Author.publication(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.UpdaterOps(~S),~Actors.UpdaterUser<S>,~String,~String,~Actors.updater_declaration(~S),~Actors.updater_body(~S),~{==},~Actors.updater_compilation(~S),~Setup.Seed(~Actor.Session),~blueprint),ids,tick,world,nodes)
def publish(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:Nodes(~S)) -> World(~S) & Nodes(~S):
  Tree.publish_pair(World(~S),Actors.GraphNode(~S),Tail(~S),Author.publication(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actors.GraphUser<S>,~String,~String,~Actors.graph_declaration(~S),~Actors.graph_body(~S),~{==},~Actors.graph_compilation(~S),~Setup.Seed(~Actor.Session),~blueprint),publish_tail(~S,~blueprint),ids,tick,world,nodes)
def collected(-Left:Type,-Right:Type,left:Left & List<&2,U32>,right:Right & List<&2,U32>) -> Product.Owner<Left,Right> & List<&2,U32>:
  match left right:
    case (left,leftIds), (right,rightIds):(Product.Owner{left,right},List.append(&2,U32,leftIds,rightIds))
def collect_tail(~S:Data,ids:List<&2,U32>,nodes:Tail(~S)) -> Tail(~S) & List<&2,U32>:
  match ids nodes:
    case +ids Product.Owner{left,right}:collected(Actors.RemovalNode(~S),Actors.UpdaterNode(~S),Author.collect(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Remover.Ops(~S),~Actors.RemovalUser<S>,~String,~String,~Actors.removal_declaration(~S),~Actors.removal_body(~S),ids,left),Author.collect(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.UpdaterOps(~S),~Actors.UpdaterUser<S>,~String,~String,~Actors.updater_declaration(~S),~Actors.updater_body(~S),ids,right))
def collect(~S:Data,ids:List<&2,U32>,nodes:Nodes(~S)) -> Nodes(~S) & List<&2,U32>:
  match ids nodes:
    case +ids Product.Owner{left,right}:collected(Actors.GraphNode(~S),Tail(~S),Author.collect(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actors.GraphUser<S>,~String,~String,~Actors.graph_declaration(~S),~Actors.graph_body(~S),ids,left),collect_tail(~S,ids,right))
def apply(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & List<&2,U32>):
  Publication.apply(~S,~L.columns(~S,Actor.components()),~L.resources(~S,Actor.resources(~S)),~Unit,~Nodes(~S),~pending(~S),~publish(~S,~blueprint),~collect(~S),ids,world,nodes)
def handle(handler:Unit,_:String) -> Unit & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def build(~S:Data,context:Context.Context<S,L.resources(~S,Actor.resources(~S)),Actor.resources(~S),{==}>,world:World(~S),left:Actors.GraphBinding(~S),right:Actors.RemovalBinding(~S),updater:Actors.UpdaterBinding(~S)) -> Bound(~S):
  Provision.Bound{Context.Bound{context,General.build(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Nodes(~S),~Unit,~Unit,~String,~Conditions.empty_dispatch(~World(~S),~String),~available,world,Tree.generalized_pair_facts(Actors.GraphNode(~S),Tail(~S),Author.facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actors.GraphUser<S>,~String,~String,~Actors.graph_declaration(~S),~Actors.graph_body(~S),left),Tree.generalized_pair_facts(Actors.RemovalNode(~S),Actors.UpdaterNode(~S),Author.facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Remover.Ops(~S),~Actors.RemovalUser<S>,~String,~String,~Actors.removal_declaration(~S),~Actors.removal_body(~S),right),Author.facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.UpdaterOps(~S),~Actors.UpdaterUser<S>,~String,~String,~Actors.updater_declaration(~S),~Actors.updater_body(~S),updater))),Conditions.Registry{Unit{},[],None{}},Unit{},[Plan.Edge{1,2},Plan.Edge{2,3}],[])}}
def configure_scheduled(~S:Data,+final:Bool,app:Scheduled(~S)) -> Scheduled(~S):
  match app:
    case Root.Scheduled{state,plan,bindings,rules,Root.Deferred{systems,Settings.Settings{automatic,_,ignored,explicit},unapplied}}:Root.Scheduled{state,plan,bindings,rules,Root.Deferred{systems,Settings.Settings{automatic,final,ignored,explicit},unapplied}}
def configure(~S:Data,final:Bool,bound:Bound(~S)) -> Bound(~S):
  match bound:
    case Provision.Bound{Context.Bound{context,app}}:Provision.Bound{Context.Bound{context,configure_scheduled(~S,final,app)}}
def run(~S:Data,bound:Bound(~S)) -> IO(Bound(~S) & Context.RunReport<App.Report<String,String>>):
  ProvisionedRoot.run_bound(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Setup.Seed(~Actor.Session),~Setup.blueprint(~S,~Actor.Session,~U32,~Actor.project),~Nodes(~S),~Unit,~Unit,~String,~String,~dispatch(~S),~Conditions.empty_dispatch(~World(~S),~String),~handle,~apply(~S),bound)
