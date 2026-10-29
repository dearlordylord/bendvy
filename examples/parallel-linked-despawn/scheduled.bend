import Base
import ../../src/ecs/execution-resource-policy.bend as Policy
import ./actor.bend as Actor
import ./remover.bend as Remover
import ../../src/ecs/execution-schema-provisioning.bend as Provision
import ../../src/ecs/execution-provisioned-root-application.bend as ProvisionedRoot
import ../../src/ecs/dependency-plan.bend as Plan
import ./setup.bend as Scene
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system.bend as Sys
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
def Peer(~S:Data) -> Type:Remover.Owner(~S)
def left(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Columns(~S),~Actor.C(~S),~Actor.R(~S),~Unit,~Actor.resources(~S),~String,~String,~F),~command:Tree.CommandLeaf(~S,~Columns(~S),~Actor.C(~S),~Actor.R(~S),~Unit,~Actor.resources(~S),~String,~String,~F),~join:Tree.Join(~F),owner:Actor.Owner(~S)) -> F(Actor.Owner(~S)):
  command(Actor.components(),Actor.route(),{==},{==},Actor.Ops(~S),Actor.User<S>,Actor.declaration(~S),Actor.body(~S),owner)
def right(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~Columns(~S),~Unit,~RightResources(~S),~Unit,~Actor.resources(~S),~String,~String,~F),~command:Tree.CommandLeaf(~S,~Columns(~S),~Unit,~RightResources(~S),~Unit,~Actor.resources(~S),~String,~String,~F),~join:Tree.Join(~F),owner:Peer(~S)) -> F(Peer(~S)):
  command(Actor.components(),Actor.route(),{==},{==},Remover.Ops(~S),W.Handle<S>,Remover.declaration(~S),Remover.body(~S),owner)
def handle(handler:Unit,_:String) -> Unit & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def Application(~S:Data) -> Type:Schedule.Scheduled<App.State<World(~S),Product.Owner<Actor.Owner(~S),Peer(~S)>,Unit,Unit>>
def Bound(~S:Data) -> Type:Provision.Bound<S,Resources(~S),Actor.resources(~S),{==},Scene.Seed(~Actor.Session),Scene.blueprint(~S,~Actor.Session,~U32,~Actor.project),Application(~S)>
def build(~S:Data,context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,world:World(~S),actor:Actor.Owner(~S),peer:Peer(~S)) -> Bound(~S):
  Provision.Bound{Context.Bound{context,Schedule.build(~S,~Actor.C(~S),~Unit,~Actor.R(~S),~RightResources(~S),~Unit,~Actor.resources(~S),~{==},~String,~String,~Actor.Owner(~S),~Peer(~S),~left(~S),~right(~S),~Unit,~Unit,~Conditions.empty_dispatch(~World(~S),~String),~Conditions.empty(~World(~S),~String),~handle,~available,world,Product.Owner{actor,peer},Unit{},Unit{},[Plan.Edge{1,2}],[])}}
def run_once(~S:Data,bound:Bound(~S)) -> IO(Bound(~S) & Context.RunReport<App.Report<String,String>>):
  ProvisionedRoot.run_bound_serial(~S,~Actor.C(~S),~Unit,~Actor.R(~S),~RightResources(~S),~Unit,~Actor.resources(~S),~{==},~Scene.Seed(~Actor.Session),~Scene.blueprint(~S,~Actor.Session,~U32,~Actor.project),~String,~String,~Actor.Owner(~S),~Peer(~S),~left(~S),~right(~S),~Unit,~Unit,~Conditions.empty_dispatch(~World(~S),~String),~Conditions.empty(~World(~S),~String),~handle,bound)
type Definition<-S:Data> is Type:
  SceneReady{application:Bound(~S)}
  ActorRefused{context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,world:World(~S),local:Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.User<S>)}
  PeerRefused{context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,world:World(~S),actor:Actor.Owner(~S),local:Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~W.Handle<S>)}
def peer_defined(~S:Data,context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,actor:Actor.Owner(~S),result:Sys.Defined<World(~S),Peer(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~W.Handle<S>)>) -> Definition<S>:
  match result:
    case Sys.Defined{world,peer}:SceneReady{build(~S,context,world,actor,peer)}
    case Sys.DefinitionRefused{world,local}:PeerRefused{context,world,actor,local}
def actor_defined(~S:Data,context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,handle:W.Handle<S>,result:Sys.Defined<World(~S),Actor.Owner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.User<S>)>) -> Definition<S>:
  match result:
    case Sys.Defined{world,actor}:peer_defined(~S,context,actor,Cmd.define(~S,~Unit,~RightResources(~S),~Unit,~Actor.components(),~Actor.resources(~S),~Actor.route(),~{==},~Remover.Ops(~S),~W.Handle<S>,~String,~String,~Remover.declaration(~S),~Remover.body(~S),~Resources(~S),world,"despawn-only",handle))
    case Sys.DefinitionRefused{world,local}:ActorRefused{context,world,local}
def define(~S:Data,context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,world:World(~S),user:Actor.User<S>) -> Definition<S>:
  match user:
    case Actor.User{child,parent,+replacement,session}:actor_defined(~S,context,replacement,Cmd.define(~S,~Actor.C(~S),~Actor.R(~S),~Unit,~Actor.components(),~Actor.resources(~S),~Actor.route(),~{==},~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actor.declaration(~S),~Actor.body(~S),~Resources(~S),world,"scene-hierarchy",Actor.User{child,parent,replacement,session}))
