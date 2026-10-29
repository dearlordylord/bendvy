import Base
import ./actor.bend as Actor
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
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-resource-query-composite.bend as Composite
import ../../src/ecs/execution-resource-query-group.bend as Group
import ../../src/ecs/execution-owner-continuation.bend as Continuation

import ./generalized-readers.bend as Readers
def World(~S:Data) -> Type:W.World<S,L.columns(~S,Actor.components()),L.resources(~S,Actor.resources(~S)),Unit>
def Authors(~S:Data) -> Type:Product.Owner<Actors.GraphNode(~S),Actors.LinkNode(~S)>
def EditorReaders(~S:Data) -> Type:Product.Owner<Actors.EditorNode(~S),Readers.FailureNode(~S)>
def FirstFour(~S:Data) -> Type:Product.Owner<Authors(~S),EditorReaders(~S)>
def Tail(~S:Data) -> Type:Product.Owner<Readers.LifecycleNode(~S),Actors.UpdaterNode(~S)>
def RemovalTail(~S:Data) -> Type:Product.Owner<Actors.RemovalNode(~S),Tail(~S)>
def Nodes(~S:Data) -> Type:Product.Owner<FirstFour(~S),RemovalTail(~S)>
def Scheduled(~S:Data) -> Type:Root.Scheduled<App.State<General.Storage<S,Actor.components(),Actor.resources(~S),Unit>,Nodes(~S),Unit,Unit>>
def Bound(~S:Data) -> Type:Provision.Bound<S,L.resources(~S,Actor.resources(~S)),Actor.resources(~S),{==},Setup.Seed(~Actor.Session),Setup.blueprint(~S,~Actor.Session,~U32,~Actor.project),Scheduled(~S)>
def graph_leaf(~S:Data,node:Actors.GraphNode(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,Actors.GraphNode(~S),String,String>:
  Author.compile(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.GraphOps(~S),~Actors.GraphUser<S>,~String,~String,~Actors.graph_declaration(~S),~Actors.graph_body(~S),~Actors.graph_compilation(~S),node)
def pending_graph(~S:Data,ids:List<&2,U32>,world:World(~S),node:Actors.GraphNode(~S)) -> World(~S) & (Actors.GraphNode(~S) & Bool):
  Author.pending(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.GraphOps(~S),~Actors.GraphUser<S>,~String,~String,~Actors.graph_declaration(~S),~Actors.graph_body(~S),ids,world,node)
def publish_graph(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),node:Actors.GraphNode(~S)) -> World(~S) & Actors.GraphNode(~S):
  Author.publication(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.GraphOps(~S),~Actors.GraphUser<S>,~String,~String,~Actors.graph_declaration(~S),~Actors.graph_body(~S),~{==},~Actors.graph_compilation(~S),~Setup.Seed(~Actor.Session),~blueprint,ids,tick,world,node)
def collect_graph(~S:Data,ids:List<&2,U32>,node:Actors.GraphNode(~S)) -> Actors.GraphNode(~S) & List<&2,U32>:
  Author.collect(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.GraphOps(~S),~Actors.GraphUser<S>,~String,~String,~Actors.graph_declaration(~S),~Actors.graph_body(~S),ids,node)
def facts_graph(~S:Data,binding:Actors.GraphBinding(~S)) -> Tree.GeneralizedFacts<Actors.GraphNode(~S)>:
  Author.facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.GraphOps(~S),~Actors.GraphUser<S>,~String,~String,~Actors.graph_declaration(~S),~Actors.graph_body(~S),binding)
def link_leaf(~S:Data,node:Actors.LinkNode(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,Actors.LinkNode(~S),String,String>:
  Author.compile(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.LinkOps(~S),~Actors.LinkUser<S>,~String,~String,~Actors.link_declaration(~S),~Actors.link_body(~S),~Actors.link_compilation(~S),node)
def pending_link(~S:Data,ids:List<&2,U32>,world:World(~S),node:Actors.LinkNode(~S)) -> World(~S) & (Actors.LinkNode(~S) & Bool):
  Author.pending(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.LinkOps(~S),~Actors.LinkUser<S>,~String,~String,~Actors.link_declaration(~S),~Actors.link_body(~S),ids,world,node)
def publish_link(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),node:Actors.LinkNode(~S)) -> World(~S) & Actors.LinkNode(~S):
  Author.publication(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.LinkOps(~S),~Actors.LinkUser<S>,~String,~String,~Actors.link_declaration(~S),~Actors.link_body(~S),~{==},~Actors.link_compilation(~S),~Setup.Seed(~Actor.Session),~blueprint,ids,tick,world,node)
def collect_link(~S:Data,ids:List<&2,U32>,node:Actors.LinkNode(~S)) -> Actors.LinkNode(~S) & List<&2,U32>:
  Author.collect(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.LinkOps(~S),~Actors.LinkUser<S>,~String,~String,~Actors.link_declaration(~S),~Actors.link_body(~S),ids,node)
def facts_link(~S:Data,binding:Actors.LinkBinding(~S)) -> Tree.GeneralizedFacts<Actors.LinkNode(~S)>:
  Author.facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.LinkOps(~S),~Actors.LinkUser<S>,~String,~String,~Actors.link_declaration(~S),~Actors.link_body(~S),binding)
def editor_leaf(~S:Data,node:Actors.EditorNode(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,Actors.EditorNode(~S),String,String>:
  Author.compile(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.LinkOps(~S),~Actors.LinkUser<S>,~String,~String,~Actors.link_declaration(~S),~Actors.editor_body(~S),~Actors.editor_compilation(~S),node)
def pending_editor(~S:Data,ids:List<&2,U32>,world:World(~S),node:Actors.EditorNode(~S)) -> World(~S) & (Actors.EditorNode(~S) & Bool):
  Author.pending(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.LinkOps(~S),~Actors.LinkUser<S>,~String,~String,~Actors.link_declaration(~S),~Actors.editor_body(~S),ids,world,node)
def publish_editor(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),node:Actors.EditorNode(~S)) -> World(~S) & Actors.EditorNode(~S):
  Author.publication(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.LinkOps(~S),~Actors.LinkUser<S>,~String,~String,~Actors.link_declaration(~S),~Actors.editor_body(~S),~{==},~Actors.editor_compilation(~S),~Setup.Seed(~Actor.Session),~blueprint,ids,tick,world,node)
def collect_editor(~S:Data,ids:List<&2,U32>,node:Actors.EditorNode(~S)) -> Actors.EditorNode(~S) & List<&2,U32>:
  Author.collect(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.LinkOps(~S),~Actors.LinkUser<S>,~String,~String,~Actors.link_declaration(~S),~Actors.editor_body(~S),ids,node)
def facts_editor(~S:Data,binding:Actors.EditorBinding(~S)) -> Tree.GeneralizedFacts<Actors.EditorNode(~S)>:
  Author.facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.LinkOps(~S),~Actors.LinkUser<S>,~String,~String,~Actors.link_declaration(~S),~Actors.editor_body(~S),binding)
def failure_leaf(~S:Data,node:Readers.FailureNode(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,Readers.FailureNode(~S),String,String>:
  Leaf.from_retained(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Readers.FailureOps(~S),~Readers.FailureState(~S),~Readers.failure_kernel(~S),~Readers.failure_body(~S),~D.trusted_construction_caps(~S,~L.columns(~S,Actor.components()),~Actors.C(~S),~Actors.R(~S),~Readers.FailureOps(~S),Readers.failure_compilation(~S)),node)
def pending_failure(~S:Data,ids:List<&2,U32>,world:World(~S),node:Readers.FailureNode(~S)) -> World(~S) & (Readers.FailureNode(~S) & Bool):
  (world,(node,False{}))
def publish_failure(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),node:Readers.FailureNode(~S)) -> World(~S) & Readers.FailureNode(~S):
  (world,node)
def collect_failure(~S:Data,ids:List<&2,U32>,node:Readers.FailureNode(~S)) -> Readers.FailureNode(~S) & List<&2,U32>:
  (node,[])
def facts_failure(~S:Data,binding:Readers.FailureBinding(~S)) -> Tree.GeneralizedFacts<Readers.FailureNode(~S)>:
  Tree.generalized_leaf_facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Readers.FailureOps(~S),~Readers.FailureState(~S),~Readers.failure_kernel(~S),~Readers.failure_body(~S),binding)
def removal_leaf(~S:Data,node:Actors.RemovalNode(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,Actors.RemovalNode(~S),String,String>:
  Author.compile(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.RemovalOps(~S),~Actors.RemovalUser<S>,~String,~String,~Actors.removal_declaration(~S),~Actors.removal_body(~S),~Actors.removal_compilation(~S),node)
def pending_removal(~S:Data,ids:List<&2,U32>,world:World(~S),node:Actors.RemovalNode(~S)) -> World(~S) & (Actors.RemovalNode(~S) & Bool):
  Author.pending(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.RemovalOps(~S),~Actors.RemovalUser<S>,~String,~String,~Actors.removal_declaration(~S),~Actors.removal_body(~S),ids,world,node)
def publish_removal(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),node:Actors.RemovalNode(~S)) -> World(~S) & Actors.RemovalNode(~S):
  Author.publication(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.RemovalOps(~S),~Actors.RemovalUser<S>,~String,~String,~Actors.removal_declaration(~S),~Actors.removal_body(~S),~{==},~Actors.removal_compilation(~S),~Setup.Seed(~Actor.Session),~blueprint,ids,tick,world,node)
def collect_removal(~S:Data,ids:List<&2,U32>,node:Actors.RemovalNode(~S)) -> Actors.RemovalNode(~S) & List<&2,U32>:
  Author.collect(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.RemovalOps(~S),~Actors.RemovalUser<S>,~String,~String,~Actors.removal_declaration(~S),~Actors.removal_body(~S),ids,node)
def facts_removal(~S:Data,binding:Actors.RemovalBinding(~S)) -> Tree.GeneralizedFacts<Actors.RemovalNode(~S)>:
  Author.facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.RemovalOps(~S),~Actors.RemovalUser<S>,~String,~String,~Actors.removal_declaration(~S),~Actors.removal_body(~S),binding)
def lifecycle_leaf(~S:Data,node:Readers.LifecycleNode(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,Readers.LifecycleNode(~S),String,String>:
  Leaf.from_retained(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Readers.LifecycleOps(~S),~Readers.LifecycleUser<S>,~Readers.lifecycle_kernel(~S),~Readers.lifecycle_body(~S),~D.trusted_construction_caps(~S,~L.columns(~S,Actor.components()),~Actors.C(~S),~Actors.R(~S),~Readers.LifecycleOps(~S),Readers.lifecycle_compilation(~S)),node)
def pending_lifecycle(~S:Data,ids:List<&2,U32>,world:World(~S),node:Readers.LifecycleNode(~S)) -> World(~S) & (Readers.LifecycleNode(~S) & Bool):
  (world,(node,False{}))
def publish_lifecycle(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),node:Readers.LifecycleNode(~S)) -> World(~S) & Readers.LifecycleNode(~S):
  (world,node)
def collect_lifecycle(~S:Data,ids:List<&2,U32>,node:Readers.LifecycleNode(~S)) -> Readers.LifecycleNode(~S) & List<&2,U32>:
  (node,[])
def facts_lifecycle(~S:Data,binding:Readers.LifecycleBinding(~S)) -> Tree.GeneralizedFacts<Readers.LifecycleNode(~S)>:
  Tree.generalized_leaf_facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Readers.LifecycleOps(~S),~Readers.LifecycleUser<S>,~Readers.lifecycle_kernel(~S),~Readers.lifecycle_body(~S),binding)
def updater_leaf(~S:Data,node:Actors.UpdaterNode(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,Actors.UpdaterNode(~S),String,String>:
  Author.compile(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.UpdaterOps(~S),~Actors.UpdaterUser<S>,~String,~String,~Actors.updater_declaration(~S),~Actors.updater_body(~S),~Actors.updater_compilation(~S),node)
def pending_updater(~S:Data,ids:List<&2,U32>,world:World(~S),node:Actors.UpdaterNode(~S)) -> World(~S) & (Actors.UpdaterNode(~S) & Bool):
  Author.pending(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.UpdaterOps(~S),~Actors.UpdaterUser<S>,~String,~String,~Actors.updater_declaration(~S),~Actors.updater_body(~S),ids,world,node)
def publish_updater(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),node:Actors.UpdaterNode(~S)) -> World(~S) & Actors.UpdaterNode(~S):
  Author.publication(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.UpdaterOps(~S),~Actors.UpdaterUser<S>,~String,~String,~Actors.updater_declaration(~S),~Actors.updater_body(~S),~{==},~Actors.updater_compilation(~S),~Setup.Seed(~Actor.Session),~blueprint,ids,tick,world,node)
def collect_updater(~S:Data,ids:List<&2,U32>,node:Actors.UpdaterNode(~S)) -> Actors.UpdaterNode(~S) & List<&2,U32>:
  Author.collect(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.UpdaterOps(~S),~Actors.UpdaterUser<S>,~String,~String,~Actors.updater_declaration(~S),~Actors.updater_body(~S),ids,node)
def facts_updater(~S:Data,binding:Actors.UpdaterBinding(~S)) -> Tree.GeneralizedFacts<Actors.UpdaterNode(~S)>:
  Author.facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.UpdaterOps(~S),~Actors.UpdaterUser<S>,~String,~String,~Actors.updater_declaration(~S),~Actors.updater_body(~S),binding)
def collected(-Left:Type,-Right:Type,left:Left & List<&2,U32>,right:Right & List<&2,U32>) -> Product.Owner<Left,Right> & List<&2,U32>:
  match left right:
    case (left,leftIds), (right,rightIds):(Product.Owner{left,right},List.append(&2,U32,leftIds,rightIds))
def collected_results(-Left:Type,-Right:Type,pair:(Left & List<&2,U32>) & (Right & List<&2,U32>)) -> Product.Owner<Left,Right> & List<&2,U32>:
  match pair:
    case (left,right):collected(Left,Right,left,right)
def collected_left(-Left:Type,-Right:Type,pair:((Right -> Right & List<&2,U32>) & Right) & (Left & List<&2,U32>)) -> Product.Owner<Left,Right> & List<&2,U32>:
  match pair:
    case ((collect,right),left):
      continuation:Continuation.PairedHeader<(Right & List<&2,U32>),(Product.Owner<Left,Right> & List<&2,U32>)> = Continuation.PairedHeader{Left & List<&2,U32>,left,collected_results(Left,Right)}
      Continuation.paired_returned(Right & List<&2,U32>,Product.Owner<Left,Right> & List<&2,U32>,continuation,collect(right))
def collect_pair(-Left:Type,-Right:Type,collectLeft:Left -> Left & List<&2,U32>,collectRight:Right -> Right & List<&2,U32>,nodes:Product.Owner<Left,Right>) -> Product.Owner<Left,Right> & List<&2,U32>:
  match nodes:
    case Product.Owner{left,right}:
      continuation:Continuation.PairedHeader<(Left & List<&2,U32>),(Product.Owner<Left,Right> & List<&2,U32>)> = Continuation.PairedHeader{(Right -> Right & List<&2,U32>) & Right,(collectRight,right),collected_left(Left,Right)}
      Continuation.paired_returned(Left & List<&2,U32>,Product.Owner<Left,Right> & List<&2,U32>,continuation,collectLeft(left))
def authors_leaf(~S:Data,nodes:Authors(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,Authors(~S),String,String>:
  Composite.from_nodes(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Actors.GraphNode(~S),~Actors.LinkNode(~S),~graph_leaf(~S),~link_leaf(~S),nodes)
def pending_authors(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Authors(~S)) -> World(~S) & (Authors(~S) & Bool):
  Tree.pending_pair(World(~S),Actors.GraphNode(~S),Actors.LinkNode(~S),pending_graph(~S),pending_link(~S),ids,world,nodes)
def publish_authors(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:Authors(~S)) -> World(~S) & Authors(~S):
  Tree.publish_pair(World(~S),Actors.GraphNode(~S),Actors.LinkNode(~S),publish_graph(~S,~blueprint),publish_link(~S,~blueprint),ids,tick,world,nodes)
def collect_authors(~S:Data,ids:List<&2,U32>,nodes:Authors(~S)) -> Authors(~S) & List<&2,U32>:
  match ids nodes:
    case +ids Product.Owner{left,right}:collected(Actors.GraphNode(~S),Actors.LinkNode(~S),collect_graph(~S,ids,left),collect_link(~S,ids,right))
def editorreaders_leaf(~S:Data,nodes:EditorReaders(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,EditorReaders(~S),String,String>:
  Composite.from_nodes(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Actors.EditorNode(~S),~Readers.FailureNode(~S),~editor_leaf(~S),~failure_leaf(~S),nodes)
def pending_editorreaders(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:EditorReaders(~S)) -> World(~S) & (EditorReaders(~S) & Bool):
  Tree.pending_pair(World(~S),Actors.EditorNode(~S),Readers.FailureNode(~S),pending_editor(~S),pending_failure(~S),ids,world,nodes)
def publish_editorreaders(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:EditorReaders(~S)) -> World(~S) & EditorReaders(~S):
  Tree.publish_pair(World(~S),Actors.EditorNode(~S),Readers.FailureNode(~S),publish_editor(~S,~blueprint),publish_failure(~S,~blueprint),ids,tick,world,nodes)
def collect_editorreaders(~S:Data,ids:List<&2,U32>,nodes:EditorReaders(~S)) -> EditorReaders(~S) & List<&2,U32>:
  match ids nodes:
    case +ids Product.Owner{left,right}:collected(Actors.EditorNode(~S),Readers.FailureNode(~S),collect_editor(~S,ids,left),collect_failure(~S,ids,right))
def firstfour_leaf(~S:Data,nodes:FirstFour(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,FirstFour(~S),String,String>:
  Composite.from_nodes(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Authors(~S),~EditorReaders(~S),~authors_leaf(~S),~editorreaders_leaf(~S),nodes)
def pending_firstfour(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:FirstFour(~S)) -> World(~S) & (FirstFour(~S) & Bool):
  Tree.pending_pair(World(~S),Authors(~S),EditorReaders(~S),pending_authors(~S),pending_editorreaders(~S),ids,world,nodes)
def publish_firstfour(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:FirstFour(~S)) -> World(~S) & FirstFour(~S):
  Tree.publish_pair(World(~S),Authors(~S),EditorReaders(~S),publish_authors(~S,~blueprint),publish_editorreaders(~S,~blueprint),ids,tick,world,nodes)
def collect_firstfour(~S:Data,ids:List<&2,U32>,nodes:FirstFour(~S)) -> FirstFour(~S) & List<&2,U32>:
  match ids nodes:
    case +ids Product.Owner{left,right}:collected(Authors(~S),EditorReaders(~S),collect_authors(~S,ids,left),collect_editorreaders(~S,ids,right))
def tail_leaf(~S:Data,nodes:Tail(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,Tail(~S),String,String>:
  Composite.from_nodes(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Readers.LifecycleNode(~S),~Actors.UpdaterNode(~S),~lifecycle_leaf(~S),~updater_leaf(~S),nodes)
def pending_tail(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Tail(~S)) -> World(~S) & (Tail(~S) & Bool):
  Tree.pending_pair(World(~S),Readers.LifecycleNode(~S),Actors.UpdaterNode(~S),pending_lifecycle(~S),pending_updater(~S),ids,world,nodes)
def publish_tail(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:Tail(~S)) -> World(~S) & Tail(~S):
  Tree.publish_pair(World(~S),Readers.LifecycleNode(~S),Actors.UpdaterNode(~S),publish_lifecycle(~S,~blueprint),publish_updater(~S,~blueprint),ids,tick,world,nodes)
def collect_tail(~S:Data,ids:List<&2,U32>,nodes:Tail(~S)) -> Tail(~S) & List<&2,U32>:
  match ids nodes:
    case +ids Product.Owner{left,right}:collected(Readers.LifecycleNode(~S),Actors.UpdaterNode(~S),collect_lifecycle(~S,ids,left),collect_updater(~S,ids,right))
def removaltail_leaf(~S:Data,nodes:RemovalTail(~S)) -> Leaf.Leaf<S,Actor.components(),Actor.resources(~S),Unit,RemovalTail(~S),String,String>:
  Composite.from_nodes(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Actors.RemovalNode(~S),~Tail(~S),~removal_leaf(~S),~tail_leaf(~S),nodes)
def pending_removaltail(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:RemovalTail(~S)) -> World(~S) & (RemovalTail(~S) & Bool):
  Tree.pending_pair(World(~S),Actors.RemovalNode(~S),Tail(~S),pending_removal(~S),pending_tail(~S),ids,world,nodes)
def publish_removaltail(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:RemovalTail(~S)) -> World(~S) & RemovalTail(~S):
  Tree.publish_pair(World(~S),Actors.RemovalNode(~S),Tail(~S),publish_removal(~S,~blueprint),publish_tail(~S,~blueprint),ids,tick,world,nodes)
def collect_removaltail(~S:Data,ids:List<&2,U32>,nodes:RemovalTail(~S)) -> RemovalTail(~S) & List<&2,U32>:
  match ids nodes:
    case +ids Product.Owner{left,right}:collected(Actors.RemovalNode(~S),Tail(~S),collect_removal(~S,ids,left),collect_tail(~S,ids,right))
def pending_nodes(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & Bool):
  Tree.pending_pair(World(~S),FirstFour(~S),RemovalTail(~S),pending_firstfour(~S),pending_removaltail(~S),ids,world,nodes)
def publish_nodes(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:Nodes(~S)) -> World(~S) & Nodes(~S):
  Tree.publish_pair(World(~S),FirstFour(~S),RemovalTail(~S),publish_firstfour(~S,~blueprint),publish_removaltail(~S,~blueprint),ids,tick,world,nodes)
def collect_nodes(~S:Data,ids:List<&2,U32>,nodes:Nodes(~S)) -> Nodes(~S) & List<&2,U32>:
  match ids:
    case +ids:collect_pair(FirstFour(~S),RemovalTail(~S),collect_firstfour(~S,ids),collect_removaltail(~S,ids),nodes)
def dispatch(~S:Data,nodes:Nodes(~S),world:World(~S),ids:List<&2,U32>) -> IO(Execution.RunResult<S,Actor.components(),Actor.resources(~S),Unit,Nodes(~S),String,String>):
  match nodes:
    case Product.Owner{first,rest}:Group.run_retained(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,FirstFour(~S),RemovalTail(~S),ids,world,firstfour_leaf(~S,first),removaltail_leaf(~S,rest))
def apply(~S:Data,~blueprint:Provision.Blueprint<S,Actor.resources(~S),Setup.Seed(~Actor.Session)>,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & List<&2,U32>):
  Publication.apply(~S,~L.columns(~S,Actor.components()),~L.resources(~S,Actor.resources(~S)),~Unit,~Nodes(~S),~pending_nodes(~S),~publish_nodes(~S,~blueprint),~collect_nodes(~S),ids,world,nodes)
def handle(handler:Unit,_:String) -> Unit & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def Captured(~S:Data) -> Data:Context.Context<S,L.resources(~S,Actor.resources(~S)),Actor.resources(~S),{==}>
def BuildGraphHeld(~S:Data) -> Type:Captured(~S) & World(~S) & Actors.LinkBinding(~S) & Actors.EditorBinding(~S) & Readers.FailureBinding(~S) & Actors.RemovalBinding(~S) & Readers.LifecycleBinding(~S) & Actors.UpdaterBinding(~S)
def BuildLinkHeld(~S:Data) -> Type:Captured(~S) & World(~S) & Actors.EditorBinding(~S) & Readers.FailureBinding(~S) & Actors.RemovalBinding(~S) & Readers.LifecycleBinding(~S) & Actors.UpdaterBinding(~S) & Tree.GeneralizedFacts<Actors.GraphNode(~S)>
def build_link(~S:Data,pair:BuildLinkHeld(~S) & Tree.GeneralizedFacts<Actors.LinkNode(~S)>) -> Bound(~S):
  match pair:
    case ((context,world,editor,failure,removal,lifecycle,updater,graph),link):Provision.Bound{Context.Bound{context,General.build(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Nodes(~S),~Unit,~Unit,~String,~Conditions.empty_dispatch(~World(~S),~String),~available,world,Tree.generalized_pair_facts(FirstFour(~S),RemovalTail(~S),Tree.generalized_pair_facts(Authors(~S),EditorReaders(~S),Tree.generalized_pair_facts(Actors.GraphNode(~S),Actors.LinkNode(~S),graph,link),Tree.generalized_pair_facts(Actors.EditorNode(~S),Readers.FailureNode(~S),facts_editor(~S,editor),facts_failure(~S,failure))),Tree.generalized_pair_facts(Actors.RemovalNode(~S),Tail(~S),facts_removal(~S,removal),Tree.generalized_pair_facts(Readers.LifecycleNode(~S),Actors.UpdaterNode(~S),facts_lifecycle(~S,lifecycle),facts_updater(~S,updater)))),Conditions.Registry{Unit{},[],None{}},Unit{},[Plan.Edge{1,3},Plan.Edge{2,3},Plan.Edge{3,4},Plan.Edge{4,5},Plan.Edge{5,6},Plan.Edge{6,7}],[])}}
def build_graph(~S:Data,pair:BuildGraphHeld(~S) & Tree.GeneralizedFacts<Actors.GraphNode(~S)>) -> Bound(~S):
  match pair:
    case ((context,world,link,editor,failure,removal,lifecycle,updater),graph):
      continuation:Continuation.PairedHeader<Tree.GeneralizedFacts<Actors.LinkNode(~S)>,Bound(~S)> = Continuation.PairedHeader{BuildLinkHeld(~S),(context,world,editor,failure,removal,lifecycle,updater,graph),build_link(~S)}
      Continuation.paired_returned(Tree.GeneralizedFacts<Actors.LinkNode(~S)>,Bound(~S),continuation,facts_link(~S,link))
def build(~S:Data,context:Captured(~S),world:World(~S),graph:Actors.GraphBinding(~S),link:Actors.LinkBinding(~S),editor:Actors.EditorBinding(~S),failure:Readers.FailureBinding(~S),removal:Actors.RemovalBinding(~S),lifecycle:Readers.LifecycleBinding(~S),updater:Actors.UpdaterBinding(~S)) -> Bound(~S):
  continuation:Continuation.PairedHeader<Tree.GeneralizedFacts<Actors.GraphNode(~S)>,Bound(~S)> = Continuation.PairedHeader{BuildGraphHeld(~S),(context,world,link,editor,failure,removal,lifecycle,updater),build_graph(~S)}
  Continuation.paired_returned(Tree.GeneralizedFacts<Actors.GraphNode(~S)>,Bound(~S),continuation,facts_graph(~S,graph))
def configure_scheduled(~S:Data,+final:Bool,app:Scheduled(~S)) -> Scheduled(~S):
  match app:
    case Root.Scheduled{state,plan,bindings,rules,Root.Deferred{systems,Settings.Settings{automatic,_,ignored,explicit},unapplied}}:Root.Scheduled{state,plan,bindings,rules,Root.Deferred{systems,Settings.Settings{automatic,final,ignored,explicit},unapplied}}
def configure(~S:Data,final:Bool,bound:Bound(~S)) -> Bound(~S):
  match bound:
    case Provision.Bound{Context.Bound{context,app}}:Provision.Bound{Context.Bound{context,configure_scheduled(~S,final,app)}}
def run(~S:Data,bound:Bound(~S)) -> IO(Bound(~S) & Context.RunReport<App.Report<String,String>>):
  ProvisionedRoot.run_bound(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Setup.Seed(~Actor.Session),~Setup.blueprint(~S,~Actor.Session,~U32,~Actor.project),~Nodes(~S),~Unit,~Unit,~String,~String,~dispatch(~S),~Conditions.empty_dispatch(~World(~S),~String),~handle,~apply(~S),bound)
