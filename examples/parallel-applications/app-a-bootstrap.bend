import Base
import ./app-a-schema.bend as D
import ./app-a-payloads.bend as P
import ./app-a-commands.bend as Author
import ./app-a-events.bend as Events
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-root-application.bend as App
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as State
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/execution-parallel-registration.bend as Registration

def Columns() -> Type:Author.Columns()
def Resources() -> Type:L.resources(~P.AuditWorkshop,Author.resources())
def CR() -> Type:L.columns(~P.AuditWorkshop,L.origin(D.components(),L.InRight{L.AtLeaf{}}))
def RR() -> Type:L.resources(~P.AuditWorkshop,D.tail_resources(~Author.Receipts()))
def World() -> Type:W.World<P.AuditWorkshop,Columns(),Resources(),Unit>
def Peer() -> Type:Events.Owners()
def left(~F:Tree.Family(),~leaf:Tree.Leaf(~P.AuditWorkshop,~Columns(),~Author.C(),~Author.R(),~Unit,~Author.resources(),~String,~String,~F),~command:Tree.CommandLeaf(~P.AuditWorkshop,~Columns(),~Author.C(),~Author.R(),~Unit,~Author.resources(),~String,~String,~F),~join:Tree.Join(~F),owner:Author.Owner()) -> F(Author.Owner()):
  command(D.components(),Author.route(),{==},{==},Author.Ops,Author.User,Author.declaration,Author.body,owner)
def right(~F:Tree.Family(),~leaf:Tree.Leaf(~P.AuditWorkshop,~Columns(),~CR(),~RR(),~Unit,~Author.resources(),~String,~String,~F),~command:Tree.CommandLeaf(~P.AuditWorkshop,~Columns(),~CR(),~RR(),~Unit,~Author.resources(),~String,~String,~F),~join:Tree.Join(~F),owner:Peer()) -> F(Peer()):
  Events.tree(~F,~leaf,~command,~join,owner)
def handle(handler:Unit,_:String) -> Unit & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def Owners() -> Type:Product.Owner<Author.Owner(),Peer()>
def ApplicationState() -> Type:State.State<World(),Owners(),Unit,Unit>
def Application() -> Type:App.Scheduled<ApplicationState()>
def Bound() -> Type:Context.Bound<P.AuditWorkshop,Resources(),Author.resources(),{==},Application()>
def build(context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,world:World(),author:Author.Owner(),peer:Peer()) -> Bound():
  Context.Bound{context,App.configure(~ApplicationState(),Settings.Settings{False{},False{},[],[]},App.build(~P.AuditWorkshop,~Author.C(),~CR(),~Author.R(),~RR(),~Unit,~Author.resources(),~{==},~String,~String,~Author.Owner(),~Peer(),~left,~right,~Unit,~Unit,~Conditions.empty_dispatch(~World(),~String),~Conditions.empty(~World(),~String),~handle,~available,world,Product.Owner{author,peer},Unit{},Unit{},[],[]))}
def invoke(bound:Bound()) -> IO(Bound() & Context.RunReport<State.Report<String,String>>):
  App.run_bound_serial(~P.AuditWorkshop,~Author.C(),~CR(),~Author.R(),~RR(),~Unit,~Author.resources(),~{==},~String,~String,~Author.Owner(),~Peer(),~left,~right,~Unit,~Unit,~Conditions.empty_dispatch(~World(),~String),~Conditions.empty(~World(),~String),~handle,bound)
def flushed(context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,rules:Registration.Rules,systems:List<&2,U32>,settings:Settings.Settings,result:ApplicationState() & List<&2,U32>) -> Bound():
  match result:
    case (state,remaining):Context.Bound{context,App.Scheduled{state,plan,bindings,rules,App.Deferred{systems,settings,remaining}}}
def flush(bound:Bound()) -> Bound():
  match bound:
    case Context.Bound{context,App.Scheduled{state,plan,bindings,rules,App.Deferred{systems,settings,unapplied}}}:flushed(context,plan,bindings,rules,systems,settings,App.apply_state(~P.AuditWorkshop,~Author.C(),~CR(),~Author.R(),~RR(),~Unit,~Author.resources(),~{==},~String,~String,~Author.Owner(),~Peer(),~left,~right,~Unit,~Unit,~Conditions.empty_dispatch(~World(),~String),~Conditions.empty(~World(),~String),~handle,unapplied,state))
type Definition is Type:
  Ready{application:Bound()}
  AuthorRefused{context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,world:World(),local:Cmd.Captures(~P.AuditWorkshop,~D.components(),~Author.resources(),~Author.route(),~Author.User),reader:Events.Reader()}
  PeerRefused{context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,author:Author.Owner(),result:Events.Definition}
def peer_defined(context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,author:Author.Owner(),result:Events.Definition) -> Definition:
  match result:
    case Events.Ready{world,peer}:Ready{build(context,world,author,peer)}
    case result:PeerRefused{context,author,result}
def author_defined(context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,reader:Events.Reader(),result:Sys.Defined<World(),Author.Owner(),Cmd.Captures(~P.AuditWorkshop,~D.components(),~Author.resources(),~Author.route(),~Author.User)>) -> Definition:
  match result:
    case Sys.Defined{world,author}:peer_defined(context,author,Events.define(world,reader))
    case Sys.DefinitionRefused{world,local}:AuthorRefused{context,world,local,reader}
def define(context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,world:World(),reader:Events.Reader()) -> Definition:
  author_defined(context,reader,Cmd.define(~P.AuditWorkshop,~Author.C(),~Author.R(),~Unit,~D.components(),~Author.resources(),~Author.route(),~{==},~Author.Ops,~Author.User,~String,~String,~Author.declaration,~Author.body,~Resources(),world,"AppA explicit commands",Author.Seed{}))

def world_returned(~Out:Type,context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,owners:Owners(),guards:Unit,handler:Unit,stateBindings:List<&2,State.Binding>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,rules:Registration.Rules,deferred:App.Deferred,result:World() & Out) -> Bound() & Out:
  match result:
    case (world,out):(Context.Bound{context,App.Scheduled{State.State{world,owners,guards,handler,stateBindings},plan,bindings,rules,deferred}},out)
def with_world(~Out:Type,operation:World() -> World() & Out,bound:Bound()) -> Bound() & Out:
  match bound:
    case Context.Bound{context,App.Scheduled{State.State{world,owners,guards,handler,stateBindings},plan,bindings,rules,deferred}}:world_returned(~Out,context,owners,guards,handler,stateBindings,plan,bindings,rules,deferred,operation(world))

def events_returned(~Out:Type,context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,world:World(),author:Author.Owner(),guards:Unit,handler:Unit,stateBindings:List<&2,State.Binding>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,rules:Registration.Rules,deferred:App.Deferred,result:Peer() & Out) -> Bound() & Out:
  match result:
    case (events,out):(Context.Bound{context,App.Scheduled{State.State{world,Product.Owner{author,events},guards,handler,stateBindings},plan,bindings,rules,deferred}},out)
def with_events(~Out:Type,operation:Peer() -> Peer() & Out,bound:Bound()) -> Bound() & Out:
  match bound:
    case Context.Bound{context,App.Scheduled{State.State{world,Product.Owner{author,events},guards,handler,stateBindings},plan,bindings,rules,deferred}}:events_returned(~Out,context,world,author,guards,handler,stateBindings,plan,bindings,rules,deferred,operation(events))
