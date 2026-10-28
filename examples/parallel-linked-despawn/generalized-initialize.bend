import Base
import ./actor.bend as Actor
import ./setup.bend as Setup
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

import ./generalized-readers.bend as Readers
import ../../src/ecs/execution-parallel-system.bend as Register
import ../../src/ecs/execution-lifecycle-administration.bend as Life
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/execution-relation-failure-registration.bend as Registration
import ../../src/ecs/execution-relation-failure-local.bend as FailureLocal
import ../../src/ecs/execution-relation-world-publication.bend as Publication
import ../../src/ecs/entity-allocator.bend as Allocator
def Captured(~S:Data) -> Data:Context.Context<S,L.resources(~S,Actor.resources(~S)),Actor.resources(~S),{==}>
def SchemaResult(~S:Data) -> Type:SchemaSetup.ProvisionedInitialization<S,Actor.components(),Actor.resources(~S),Unit,Setup.Seed(~Actor.Session),Setup.blueprint(~S,~Actor.Session,~U32,~Actor.project)>
type Inputs<-S:Data> is Data:
  Inputs{child:W.Handle<S>,parent:W.Handle<S>,replacement:W.Handle<S>,scoped:W.Handle<S>}
type Initialization<-S:Data> is Type:
  InitializationReady{factory:W.Factory,bound:Application.Bound(~S)}
  InitializationRefused{-Held:Type,held:Held,stage:String}
def graph_user(~S:Data,inputs:Inputs<S>,session:Actor.Session) -> Actors.GraphUser<S>:
  match inputs:
    case Inputs{child,parent,replacement,scoped}:Actors.GraphUser{Actor.User{child,parent,replacement,session},scoped,False{},0}
def link_user(~S:Data,inputs:Inputs<S>,session:Actor.Session) -> Actors.LinkUser<S>:
  match inputs:
    case Inputs{_,parent,replacement,_}:Actors.LinkUser{parent,replacement,session,False{},0}
def removal_user(~S:Data,inputs:Inputs<S>) -> Actors.RemovalUser<S>:
  match inputs:
    case Inputs{_,_,replacement,_}:Actors.RemovalUser{replacement,False{},0}
def updater_user(~S:Data,inputs:Inputs<S>) -> Actors.UpdaterUser<S>:
  match inputs:
    case Inputs{_,parent,_,_}:Actors.UpdaterUser{parent,Some{Actor.Session{222}},Some{Actor.Session{333}},0}
def updater_defined(~S:Data,factory:W.Factory,context:Captured(~S),+inputs:Inputs<S>,graph:Actors.GraphBinding(~S),link:Actors.LinkBinding(~S),editor:Actors.EditorBinding(~S),failure:Readers.FailureBinding(~S),removal:Actors.RemovalBinding(~S),lifecycle:Readers.LifecycleBinding(~S),result:Actors.UpdaterCompilation(~S) & Sys.Defined<Application.World(~S),Actors.UpdaterOwner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actors.UpdaterUser<S>)>) -> Initialization<S>:
  match result:
    case (compilation,Sys.Defined{world,owner}):InitializationReady{factory,Application.build(~S,context,world,graph,link,editor,failure,removal,lifecycle,Scope.CompiledBinding{compilation,owner})}
    case (compilation,result):InitializationRefused{W.Factory & Captured(~S) & Inputs<S> & Actors.GraphBinding(~S) & Actors.LinkBinding(~S) & Actors.EditorBinding(~S) & Readers.FailureBinding(~S) & Actors.RemovalBinding(~S) & Readers.LifecycleBinding(~S) & Actors.UpdaterCompilation(~S) & Sys.Defined<Application.World(~S),Actors.UpdaterOwner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actors.UpdaterUser<S>)>,(factory,context,inputs,graph,link,editor,failure,removal,lifecycle,compilation,result),"define-updater"}
def lifecycle_defined(~S:Data,factory:W.Factory,context:Captured(~S),+inputs:Inputs<S>,graph:Actors.GraphBinding(~S),link:Actors.LinkBinding(~S),editor:Actors.EditorBinding(~S),failure:Readers.FailureBinding(~S),removal:Actors.RemovalBinding(~S),result:Readers.LifecycleCompilation(~S) & Sys.Defined<Application.World(~S),Readers.LifecycleOwner(~S),Readers.LifecycleUser<S>>) -> Initialization<S>:
  match result:
    case (compilation,Sys.Defined{world,owner}):updater_defined(~S,factory,context,inputs,graph,link,editor,failure,removal,Scope.CompiledBinding{compilation,owner},Author.define_with_compilation(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.UpdaterOps(~S),~Actors.UpdaterUser<S>,~String,~String,~Actors.updater_declaration(~S),~Actors.updater_body(~S),~{==},Actors.updater_compilation(~S),world,"scene-updater",updater_user(~S,inputs)))
    case (compilation,result):InitializationRefused{W.Factory & Captured(~S) & Inputs<S> & Actors.GraphBinding(~S) & Actors.LinkBinding(~S) & Actors.EditorBinding(~S) & Readers.FailureBinding(~S) & Actors.RemovalBinding(~S) & Readers.LifecycleCompilation(~S) & Sys.Defined<Application.World(~S),Readers.LifecycleOwner(~S),Readers.LifecycleUser<S>>,(factory,context,inputs,graph,link,editor,failure,removal,compilation,result),"define-lifecycle"}
def despawned_register(~S:Data,factory:W.Factory,context:Captured(~S),+inputs:Inputs<S>,graph:Actors.GraphBinding(~S),link:Actors.LinkBinding(~S),editor:Actors.EditorBinding(~S),failure:Readers.FailureBinding(~S),removal:Actors.RemovalBinding(~S),removed:Readers.RemovalReader(~S),result:Application.World(~S) & Notice.Registration<S,L.EmptyLayout{},Notice.Despawned{}>) -> Initialization<S>:
  match result:
    case (world,Notice.Registered{reader}):lifecycle_defined(~S,factory,context,inputs,graph,link,editor,failure,removal,Register.define_with_compilation(~S,~Readers.Columns(~S),~Actors.C(~S),~Actors.R(~S),~Unit,~Readers.LifecycleOps(~S),~Readers.LifecycleUser<S>,~String,~String,~Readers.lifecycle_kernel(~S),~Readers.lifecycle_body(~S),~L.resources(~S,Actor.resources(~S)),Readers.lifecycle_compilation(~S),world,"scene-lifecycle",Readers.LifecycleUser{Actor.Session{606},removed,reader,0,[],[],0n,0n,False{},False{}}))
    case result:InitializationRefused{W.Factory & Captured(~S) & Inputs<S> & Actors.GraphBinding(~S) & Actors.LinkBinding(~S) & Actors.EditorBinding(~S) & Readers.FailureBinding(~S) & Actors.RemovalBinding(~S) & Readers.RemovalReader(~S) & Application.World(~S) & Notice.Registration<S,L.EmptyLayout{},Notice.Despawned{}>,(factory,context,inputs,graph,link,editor,failure,removal,removed,result),"despawn-reader-registration"}
def removed_register(~S:Data,factory:W.Factory,context:Captured(~S),+inputs:Inputs<S>,graph:Actors.GraphBinding(~S),link:Actors.LinkBinding(~S),editor:Actors.EditorBinding(~S),failure:Readers.FailureBinding(~S),removal:Actors.RemovalBinding(~S),result:Application.World(~S) & Notice.Registration<S,L.origin(Actor.components(),Actor.route()),Notice.Removed{"scene-node"}>) -> Initialization<S>:
  match result:
    case (world,Notice.Registered{reader}):despawned_register(~S,factory,context,inputs,graph,link,editor,failure,removal,reader,Life.register_despawn(~S,~Readers.Columns(~S),~L.resources(~S,Actor.resources(~S)),~Unit,world,Notice.Retained{}))
    case result:InitializationRefused{W.Factory & Captured(~S) & Inputs<S> & Actors.GraphBinding(~S) & Actors.LinkBinding(~S) & Actors.EditorBinding(~S) & Readers.FailureBinding(~S) & Actors.RemovalBinding(~S) & Application.World(~S) & Notice.Registration<S,L.origin(Actor.components(),Actor.route()),Notice.Removed{"scene-node"}>,(factory,context,inputs,graph,link,editor,failure,removal,result),"removed-reader-registration"}
def removal_defined(~S:Data,factory:W.Factory,context:Captured(~S),+inputs:Inputs<S>,graph:Actors.GraphBinding(~S),link:Actors.LinkBinding(~S),editor:Actors.EditorBinding(~S),failure:Readers.FailureBinding(~S),result:Actors.RemovalCompilation(~S) & Sys.Defined<Application.World(~S),Actors.RemovalOwner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actors.RemovalUser<S>)>) -> Initialization<S>:
  match result:
    case (compilation,Sys.Defined{world,owner}):removed_register(~S,factory,context,inputs,graph,link,editor,failure,Scope.CompiledBinding{compilation,owner},Life.register_removed(~S,~Readers.Columns(~S),~L.resources(~S,Actor.resources(~S)),~Unit,~Actor.components(),~Actor.route(),~{==},~{==},world,Notice.Retained{}))
    case (compilation,result):InitializationRefused{W.Factory & Captured(~S) & Inputs<S> & Actors.GraphBinding(~S) & Actors.LinkBinding(~S) & Actors.EditorBinding(~S) & Readers.FailureBinding(~S) & Actors.RemovalCompilation(~S) & Sys.Defined<Application.World(~S),Actors.RemovalOwner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actors.RemovalUser<S>)>,(factory,context,inputs,graph,link,editor,failure,compilation,result),"define-removal"}
def failure_defined(~S:Data,factory:W.Factory,context:Captured(~S),+inputs:Inputs<S>,graph:Actors.GraphBinding(~S),link:Actors.LinkBinding(~S),editor:Actors.EditorBinding(~S),result:Readers.FailureCompilation(~S) & Sys.Defined<Application.World(~S),Readers.FailureOwner(~S),Readers.FailureState(~S)>) -> Initialization<S>:
  match result:
    case (compilation,Sys.Defined{world,owner}):removal_defined(~S,factory,context,inputs,graph,link,editor,Scope.CompiledBinding{compilation,owner},Author.define_with_compilation(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.RemovalOps(~S),~Actors.RemovalUser<S>,~String,~String,~Actors.removal_declaration(~S),~Actors.removal_body(~S),~{==},Actors.removal_compilation(~S),world,"scene-removal",removal_user(~S,inputs)))
    case (compilation,result):InitializationRefused{W.Factory & Captured(~S) & Inputs<S> & Actors.GraphBinding(~S) & Actors.LinkBinding(~S) & Actors.EditorBinding(~S) & Readers.FailureCompilation(~S) & Sys.Defined<Application.World(~S),Readers.FailureOwner(~S),Readers.FailureState(~S)>,(factory,context,inputs,graph,link,editor,compilation,result),"define-failure"}
def failure_registered(~S:Data,factory:W.Factory,context:Captured(~S),+inputs:Inputs<S>,graph:Actors.GraphBinding(~S),link:Actors.LinkBinding(~S),editor:Actors.EditorBinding(~S),frame:Publication.Frame<S,Readers.Columns(~S),L.resources(~S,Actor.resources(~S)),Unit>,allocator:Allocator.Allocator,result:Registration.Registration<S,Actor.resources(~S),Actor.parent_route(),Setup.hierarchy(~S)>) -> Initialization<S>:
  match frame result:
    case Publication.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle} Registration.Registered{resources,reader}:failure_defined(~S,factory,context,inputs,graph,link,editor,Register.define_with_compilation(~S,~Readers.Columns(~S),~Actors.C(~S),~Actors.R(~S),~Unit,~Readers.FailureOps(~S),~Readers.FailureState(~S),~String,~String,~Readers.failure_kernel(~S),~Readers.failure_body(~S),~L.resources(~S,Actor.resources(~S)),Readers.failure_compilation(~S),W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle},"scene-failure",FailureLocal.Local{reader,Readers.FailureUser{Actor.Session{604},0n,0n,0n,[],[]}}))
    case frame result:InitializationRefused{W.Factory & Captured(~S) & Inputs<S> & Actors.GraphBinding(~S) & Actors.LinkBinding(~S) & Actors.EditorBinding(~S) & Publication.Frame<S,Readers.Columns(~S),L.resources(~S,Actor.resources(~S)),Unit> & Allocator.Allocator & Registration.Registration<S,Actor.resources(~S),Actor.parent_route(),Setup.hierarchy(~S)>,(factory,context,inputs,graph,link,editor,frame,allocator,result),"failure-reader-registration"}
def failure_register(~S:Data,factory:W.Factory,context:Captured(~S),+inputs:Inputs<S>,graph:Actors.GraphBinding(~S),link:Actors.LinkBinding(~S),editor:Actors.EditorBinding(~S),world:Application.World(~S)) -> Initialization<S>:
  match world:
    case W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle}:failure_registered(~S,factory,context,inputs,graph,link,editor,Publication.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle},allocator,Registration.register(~S,~Actor.resources(~S),~Actor.parent_route(),~{==},~Setup.hierarchy(~S),~{==},~{==},~{==},resources))
def editor_defined(~S:Data,factory:W.Factory,context:Captured(~S),+inputs:Inputs<S>,graph:Actors.GraphBinding(~S),link:Actors.LinkBinding(~S),result:Actors.EditorCompilation(~S) & Sys.Defined<Application.World(~S),Actors.EditorOwner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actors.LinkUser<S>)>) -> Initialization<S>:
  match result:
    case (compilation,Sys.Defined{world,owner}):failure_register(~S,factory,context,inputs,graph,link,Scope.CompiledBinding{compilation,owner},world)
    case (compilation,result):InitializationRefused{W.Factory & Captured(~S) & Inputs<S> & Actors.GraphBinding(~S) & Actors.LinkBinding(~S) & Actors.EditorCompilation(~S) & Sys.Defined<Application.World(~S),Actors.EditorOwner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actors.LinkUser<S>)>,(factory,context,inputs,graph,link,compilation,result),"define-editor"}
def link_defined(~S:Data,factory:W.Factory,context:Captured(~S),+inputs:Inputs<S>,graph:Actors.GraphBinding(~S),result:Actors.LinkCompilation(~S) & Sys.Defined<Application.World(~S),Actors.LinkOwner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actors.LinkUser<S>)>) -> Initialization<S>:
  match result:
    case (compilation,Sys.Defined{world,owner}):editor_defined(~S,factory,context,inputs,graph,Scope.CompiledBinding{compilation,owner},Author.define_with_compilation(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.LinkOps(~S),~Actors.LinkUser<S>,~String,~String,~Actors.link_declaration(~S),~Actors.editor_body(~S),~{==},Actors.editor_compilation(~S),world,"scene-editor",link_user(~S,inputs,Actor.Session{603})))
    case (compilation,result):InitializationRefused{W.Factory & Captured(~S) & Inputs<S> & Actors.GraphBinding(~S) & Actors.LinkCompilation(~S) & Sys.Defined<Application.World(~S),Actors.LinkOwner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actors.LinkUser<S>)>,(factory,context,inputs,graph,compilation,result),"define-link"}
def graph_defined(~S:Data,factory:W.Factory,context:Captured(~S),+inputs:Inputs<S>,result:Actors.GraphCompilation(~S) & Sys.Defined<Application.World(~S),Actors.GraphOwner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actors.GraphUser<S>)>) -> Initialization<S>:
  match result:
    case (compilation,Sys.Defined{world,owner}):link_defined(~S,factory,context,inputs,Scope.CompiledBinding{compilation,owner},Author.define_with_compilation(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.LinkOps(~S),~Actors.LinkUser<S>,~String,~String,~Actors.link_declaration(~S),~Actors.link_body(~S),~{==},Actors.link_compilation(~S),world,"scene-link",link_user(~S,inputs,Actor.Session{602})))
    case (compilation,result):InitializationRefused{W.Factory & Captured(~S) & Inputs<S> & Actors.GraphCompilation(~S) & Sys.Defined<Application.World(~S),Actors.GraphOwner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actors.GraphUser<S>)>,(factory,context,inputs,compilation,result),"define-graph"}
def scoped_ready(~S:Data,factory:W.Factory,context:Captured(~S),+child:W.Handle<S>,+parent:W.Handle<S>,+replacement:W.Handle<S>,local:Actor.Session,result:Entities.Node<S>) -> Initialization<S>:
  match result:
    case Entities.NodeReady{world,+scoped}:graph_defined(~S,factory,context,Inputs{child,parent,replacement,scoped},Author.define_with_compilation(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actors.GraphOps(~S),~Actors.GraphUser<S>,~String,~String,~Actors.graph_declaration(~S),~Actors.graph_body(~S),~{==},Actors.graph_compilation(~S),world,"scene-graph",graph_user(~S,Inputs{child,parent,replacement,scoped},local)))
    case result:InitializationRefused{W.Factory & Captured(~S) & List<&2,W.Handle<S>> & Actor.Session & Entities.Node<S>,(factory,context,[child,parent,replacement],local,result),"allocate-scoped"}
def replacement_ready(~S:Data,factory:W.Factory,context:Captured(~S),child:W.Handle<S>,parent:W.Handle<S>,local:Actor.Session,result:Entities.Node<S>) -> Initialization<S>:
  match result:
    case Entities.NodeReady{world,replacement}:scoped_ready(~S,factory,context,child,parent,replacement,local,Entities.node(~S,world))
    case result:InitializationRefused{W.Factory & Captured(~S) & List<&2,W.Handle<S>> & Actor.Session & Entities.Node<S>,(factory,context,[child,parent],local,result),"allocate-replacement"}
def parent_ready(~S:Data,factory:W.Factory,context:Captured(~S),child:W.Handle<S>,local:Actor.Session,result:Entities.Node<S>) -> Initialization<S>:
  match result:
    case Entities.NodeReady{world,parent}:replacement_ready(~S,factory,context,child,parent,local,Entities.node(~S,world))
    case result:InitializationRefused{W.Factory & Captured(~S) & List<&2,W.Handle<S>> & Actor.Session & Entities.Node<S>,(factory,context,[child],local,result),"allocate-parent"}
def child_ready(~S:Data,factory:W.Factory,context:Captured(~S),local:Actor.Session,result:Entities.Node<S>) -> Initialization<S>:
  match result:
    case Entities.NodeReady{world,child}:parent_ready(~S,factory,context,child,local,Entities.node(~S,world))
    case result:InitializationRefused{W.Factory & Captured(~S) & List<&2,W.Handle<S>> & Actor.Session & Entities.Node<S>,(factory,context,[],local,result),"allocate-child"}
def schema_created(~S:Data,local:Actor.Session,result:SchemaResult(~S)) -> Initialization<S>:
  match result:
    case SchemaSetup.ProvisionedInitialization{Context.ContextCreated{factory,world,context}}:child_ready(~S,factory,context,local,Entities.node(~S,world))
    case result:InitializationRefused{SchemaResult(~S) & Actor.Session,(result,local),"schema"}
def create(~S:Data,factory:W.Factory,resourceState:Actor.Session,local:Actor.Session) -> Initialization<S>:
  schema_created(~S,local,SchemaSetup.create_provisioned(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Setup.Seed(~Actor.Session),~Setup.blueprint(~S,~Actor.Session,~U32,~Actor.project),factory,Product.Owner{Product.Owner{Unit{},Unit{}},Product.Owner{Unit{},resourceState}}))
