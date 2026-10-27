import Base
import ./actor.bend as Actor
import ./setup.bend as Setup
import ./remover.bend as Remover
import ./initialize.bend as Entities
import ./generalized-actors.bend as Actors
import ./generalized-application.bend as Application
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-relation-schema-setup.bend as SchemaSetup
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W

def Captured(~S:Data) -> Data:Context.Context<S,L.resources(~S,Actor.resources(~S)),Actor.resources(~S),{==}>
def GraphDefined(~S:Data) -> Type:Sys.Defined<Application.World(~S),Actors.GraphOwner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.User<S>)>
def RemovalDefined(~S:Data) -> Type:Sys.Defined<Application.World(~S),Actors.RemovalOwner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~W.Handle<S>)>
def SchemaResult(~S:Data) -> Type:SchemaSetup.ProvisionedInitialization<S,Actor.components(),Actor.resources(~S),Unit,Setup.Seed(~Actor.Session),Setup.blueprint(~S,~Actor.Session,~U32,~Actor.project)>
type Initialization<-S:Data> is Type:
  Ready{factory:W.Factory,bound:Application.Bound(~S)}
  SchemaRefused{result:SchemaResult(~S),local:Actor.Session}
  NodeRefused{factory:W.Factory,context:Captured(~S),world:Application.World(~S),created:List<&2,W.Handle<S>>,local:Actor.Session,error:W.WorldError}
  GraphRefused{factory:W.Factory,context:Captured(~S),compilation:Actors.GraphCompilation(~S),result:GraphDefined(~S)}
  RemovalRefused{factory:W.Factory,context:Captured(~S),graph:Actors.GraphBinding(~S),compilation:Actors.RemovalCompilation(~S),result:RemovalDefined(~S)}
def removal_defined(~S:Data,factory:W.Factory,context:Captured(~S),graph:Actors.GraphBinding(~S),result:Actors.RemovalCompilation(~S) & RemovalDefined(~S)) -> Initialization<S>:
  match result:
    case (compilation,Sys.Defined{world,owner}):Ready{factory,Application.build(~S,context,world,graph,Scope.CompiledBinding{compilation,owner})}
    case (compilation,result):RemovalRefused{factory,context,graph,compilation,result}
def graph_defined(~S:Data,factory:W.Factory,context:Captured(~S),handle:W.Handle<S>,result:Actors.GraphCompilation(~S) & GraphDefined(~S)) -> Initialization<S>:
  match result:
    case (compilation,Sys.Defined{world,owner}):removal_defined(~S,factory,context,Scope.CompiledBinding{compilation,owner},Author.define_with_compilation(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Remover.Ops(~S),~W.Handle<S>,~String,~String,~Actors.removal_declaration(~S),~Remover.body(~S),~{==},Actors.removal_compilation(~S),world,"generalized-despawn-only",handle))
    case (compilation,result):GraphRefused{factory,context,compilation,result}
def replacement_ready(~S:Data,factory:W.Factory,context:Captured(~S),child:W.Handle<S>,parent:W.Handle<S>,local:Actor.Session,result:Entities.Node<S>) -> Initialization<S>:
  match result:
    case Entities.NodeReady{world,+replacement}:graph_defined(~S,factory,context,replacement,Author.define_with_compilation(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actors.graph_declaration(~S),~Actor.body(~S),~{==},Actors.graph_compilation(~S),world,"generalized-graph-author",Actor.User{child,parent,replacement,local}))
    case Entities.NodeRefused{world,error}:NodeRefused{factory,context,world,[child,parent],local,error}
def parent_ready(~S:Data,factory:W.Factory,context:Captured(~S),child:W.Handle<S>,local:Actor.Session,result:Entities.Node<S>) -> Initialization<S>:
  match result:
    case Entities.NodeReady{world,parent}:replacement_ready(~S,factory,context,child,parent,local,Entities.node(~S,world))
    case Entities.NodeRefused{world,error}:NodeRefused{factory,context,world,[child],local,error}
def child_ready(~S:Data,factory:W.Factory,context:Captured(~S),local:Actor.Session,result:Entities.Node<S>) -> Initialization<S>:
  match result:
    case Entities.NodeReady{world,child}:parent_ready(~S,factory,context,child,local,Entities.node(~S,world))
    case Entities.NodeRefused{world,error}:NodeRefused{factory,context,world,[],local,error}
def schema_created(~S:Data,local:Actor.Session,result:SchemaResult(~S)) -> Initialization<S>:
  match result:
    case SchemaSetup.ProvisionedInitialization{Context.ContextCreated{factory,world,context}}:child_ready(~S,factory,context,local,Entities.node(~S,world))
    case result:SchemaRefused{result,local}
def create(~S:Data,factory:W.Factory,resourceState:Actor.Session,local:Actor.Session) -> Initialization<S>:
  schema_created(~S,local,SchemaSetup.create_provisioned(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Setup.Seed(~Actor.Session),~Setup.blueprint(~S,~Actor.Session,~U32,~Actor.project),factory,Product.Owner{Product.Owner{Unit{},Unit{}},Product.Owner{Unit{},resourceState}}))
