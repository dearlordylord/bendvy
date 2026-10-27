import Base
import ../../src/ecs/execution-resource-policy.bend as Policy
import ./actor.bend as Actor
import ./setup.bend as Scene
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-reservation-task.bend as Effect
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec

def Columns(~S:Data) -> Type:Layout.columns(~S,Actor.components())
def Resources(~S:Data) -> Type:Layout.resources(~S,Actor.resources(~S))
def RightResources(~S:Data) -> Type:Layout.resources(~S,Scene.right_resources(~S,~Actor.Session,~U32,~Actor.project))
def World(~S:Data) -> Type:W.World<S,Columns(~S),Resources(~S),Unit>
def Ops(Permit:Data,H:Type) -> Type:Unit
def peer_declaration(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Unit,~RightResources(~S),~Permit,~H,~B),book:B) -> B & Unit:(book,Unit{})
def peer_body(~S:Data,~Permit:Data,~H:Type,~caps:Unit,scope:H,local:Unit) -> Effect.Task<S,Permit,H & (Unit & Sys.Completion<String,String>)>:
  Effect.TDone{(scope,(local,Sys.Success{"peer finished"}))}
def Peer(~S:Data) -> Type:Sys.Owner<S,Columns(~S),Unit,RightResources(~S),Unit,Ops,Unit,String,String,Build.framework_program(~S,~Columns(~S),~Unit,~RightResources(~S),~Ops,~peer_declaration(~S)),peer_body(~S)>
def left(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Columns(~S),~Actor.C(~S),~Actor.R(~S),~Unit,~Actor.resources(~S),~String,~String,~F),~command:Tree.CommandLeaf(~S,~Columns(~S),~Actor.C(~S),~Actor.R(~S),~Unit,~Actor.resources(~S),~String,~String,~F),~join:Tree.Join(~F),owner:Actor.Owner(~S)) -> F(Actor.Owner(~S)):
  command(Actor.components(),Actor.route(),{==},{==},Actor.Ops(~S),Actor.User<S>,Actor.declaration(~S),Actor.body(~S),owner)
def right(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Columns(~S),~Unit,~RightResources(~S),~Unit,~Actor.resources(~S),~String,~String,~F),~command:Tree.CommandLeaf(~S,~Columns(~S),~Unit,~RightResources(~S),~Unit,~Actor.resources(~S),~String,~String,~F),~join:Tree.Join(~F),owner:Peer(~S)) -> F(Peer(~S)):
  leaf(Ops,Unit,Build.framework_program(~S,~Columns(~S),~Unit,~RightResources(~S),~Ops,~peer_declaration(~S)),peer_body(~S),owner)
def handle(handler:Unit,_:String) -> Unit & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def Application(~S:Data) -> Type:Schedule.Scheduled<App.State<World(~S),Product.Owner<Actor.Owner(~S),Peer(~S)>,Unit,Unit>>
def Bound(~S:Data) -> Type:Context.Bound<S,Resources(~S),Actor.resources(~S),{==},Application(~S)>
def build(~S:Data,context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,world:World(~S),actor:Actor.Owner(~S),peer:Peer(~S)) -> Bound(~S):
  Context.Bound{context,Schedule.build(~S,~Actor.C(~S),~Unit,~Actor.R(~S),~RightResources(~S),~Unit,~Actor.resources(~S),~{==},~String,~String,~Actor.Owner(~S),~Peer(~S),~left(~S),~right(~S),~Unit,~Unit,~Conditions.empty_dispatch(~World(~S),~String),~Conditions.empty(~World(~S),~String),~handle,~available,world,Product.Owner{actor,peer},Unit{},Unit{},[],[])}
def run_once(~S:Data,bound:Bound(~S)) -> IO(Bound(~S) & Context.RunReport<App.Report<String,String>>):
  Schedule.run_bound_serial(~S,~Actor.C(~S),~Unit,~Actor.R(~S),~RightResources(~S),~Unit,~Actor.resources(~S),~{==},~String,~String,~Actor.Owner(~S),~Peer(~S),~left(~S),~right(~S),~Unit,~Unit,~Conditions.empty_dispatch(~World(~S),~String),~Conditions.empty(~World(~S),~String),~handle,bound)
type Definition<-S:Data> is Type:
  SceneReady{application:Bound(~S)}
  ActorRefused{context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,world:World(~S),local:Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.User<S>)}
  PeerRefused{context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,world:World(~S),actor:Actor.Owner(~S),local:Unit}
def peer_defined(~S:Data,context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,actor:Actor.Owner(~S),result:Sys.Defined<World(~S),Peer(~S),Unit>) -> Definition<S>:
  match result:
    case Sys.Defined{world,peer}:SceneReady{build(~S,context,world,actor,peer)}
    case Sys.DefinitionRefused{world,local}:PeerRefused{context,world,actor,local}
def actor_defined(~S:Data,context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,result:Sys.Defined<World(~S),Actor.Owner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.User<S>)>) -> Definition<S>:
  match result:
    case Sys.Defined{world,actor}:peer_defined(~S,context,actor,Task.define_framework(~S,~Columns(~S),~Unit,~RightResources(~S),~Unit,~Ops,~Unit,~String,~String,~Build.framework_program(~S,~Columns(~S),~Unit,~RightResources(~S),~Ops,~peer_declaration(~S)),~peer_body(~S),~Resources(~S),world,"scene-peer",Unit{}))
    case Sys.DefinitionRefused{world,local}:ActorRefused{context,world,local}
def define(~S:Data,context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,world:World(~S),user:Actor.User<S>) -> Definition<S>:
  actor_defined(~S,context,Cmd.define(~S,~Actor.C(~S),~Actor.R(~S),~Unit,~Actor.components(),~Actor.resources(~S),~Actor.route(),~{==},~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actor.declaration(~S),~Actor.body(~S),~Resources(~S),world,"scene-hierarchy",user))
