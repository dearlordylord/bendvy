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

def World(~S:Data) -> Type:W.World<S,L.columns(~S,Actor.components()),L.resources(~S,Actor.resources(~S)),Unit>
def Nodes(~S:Data) -> Type:Product.Owner<Actors.GraphNode(~S),Actors.RemovalNode(~S)>
def Scheduled(~S:Data) -> Type:Root.Scheduled<App.State<General.Storage<S,Actor.components(),Actor.resources(~S),Unit>,Nodes(~S),Unit,Unit>>
def Bound(~S:Data) -> Type:Provision.Bound<S,L.resources(~S,Actor.resources(~S)),Actor.resources(~S),{==},Setup.Seed(~Actor.Session),Setup.blueprint(~S,~Actor.Session,~U32,~Actor.project),Scheduled(~S)>
def dispatch(~S:Data,nodes:Nodes(~S),world:World(~S),ids:List<&2,U32>) -> IO(Execution.RunResult<S,Actor.components(),Actor.resources(~S),Unit,Nodes(~S),String,String>):
  match nodes:
    case Product.Owner{left,right}:Tree.run_generalized(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,Actors.GraphNode(~S),Actors.RemovalNode(~S),ids,world,Tree.GeneralizedPair{Author.compile(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actors.graph_declaration(~S),~Actor.body(~S),~Actors.graph_compilation(~S),left),Author.compile(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Remover.Ops(~S),~W.Handle<S>,~String,~String,~Actors.removal_declaration(~S),~Remover.body(~S),~Actors.removal_compilation(~S),right)})
def pending(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & Bool):
  Tree.pending_pair(World(~S),Actors.GraphNode(~S),Actors.RemovalNode(~S),Author.pending(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actors.graph_declaration(~S),~Actor.body(~S)),Author.pending(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Remover.Ops(~S),~W.Handle<S>,~String,~String,~Actors.removal_declaration(~S),~Remover.body(~S)),ids,world,nodes)
def publish(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:Nodes(~S)) -> World(~S) & Nodes(~S):
  Tree.publish_pair(World(~S),Actors.GraphNode(~S),Actors.RemovalNode(~S),Author.publication(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actors.graph_declaration(~S),~Actor.body(~S),~{==},~Actors.graph_compilation(~S),~Setup.Seed(~Actor.Session),~blueprint),Author.publication(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Remover.Ops(~S),~W.Handle<S>,~String,~String,~Actors.removal_declaration(~S),~Remover.body(~S),~{==},~Actors.removal_compilation(~S),~Setup.Seed(~Actor.Session),~blueprint),ids,tick,world,nodes)
def collected(~S:Data,left:Actors.GraphNode(~S) & List<&2,U32>,right:Actors.RemovalNode(~S) & List<&2,U32>) -> Nodes(~S) & List<&2,U32>:
  match left right:
    case (left,leftIds), (right,rightIds):(Product.Owner{left,right},List.append(&2,U32,leftIds,rightIds))
def collect(~S:Data,ids:List<&2,U32>,nodes:Nodes(~S)) -> Nodes(~S) & List<&2,U32>:
  match ids nodes:
    case +ids Product.Owner{left,right}:collected(~S,Author.collect(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actors.graph_declaration(~S),~Actor.body(~S),ids,left),Author.collect(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Remover.Ops(~S),~W.Handle<S>,~String,~String,~Actors.removal_declaration(~S),~Remover.body(~S),ids,right))
def apply(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & List<&2,U32>):
  Publication.apply(~S,~L.columns(~S,Actor.components()),~L.resources(~S,Actor.resources(~S)),~Unit,~Nodes(~S),~pending(~S),~publish(~S,~blueprint),~collect(~S),ids,world,nodes)
def handle(handler:Unit,_:String) -> Unit & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def build(~S:Data,context:Context.Context<S,L.resources(~S,Actor.resources(~S)),Actor.resources(~S),{==}>,world:World(~S),left:Actors.GraphBinding(~S),right:Actors.RemovalBinding(~S)) -> Bound(~S):
  Provision.Bound{Context.Bound{context,General.build(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Nodes(~S),~Unit,~Unit,~String,~Conditions.empty_dispatch(~World(~S),~String),~available,world,Tree.generalized_pair_facts(Actors.GraphNode(~S),Actors.RemovalNode(~S),Author.facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actors.graph_declaration(~S),~Actor.body(~S),left),Author.facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Remover.Ops(~S),~W.Handle<S>,~String,~String,~Actors.removal_declaration(~S),~Remover.body(~S),right)),Conditions.Registry{Unit{},[],None{}},Unit{},[Plan.Edge{1,2}],[])}}
def run(~S:Data,bound:Bound(~S)) -> IO(Bound(~S) & Context.RunReport<App.Report<String,String>>):
  ProvisionedRoot.run_bound(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Setup.Seed(~Actor.Session),~Setup.blueprint(~S,~Actor.Session,~U32,~Actor.project),~Nodes(~S),~Unit,~Unit,~String,~String,~dispatch(~S),~Conditions.empty_dispatch(~World(~S),~String),~handle,~apply(~S),bound)
