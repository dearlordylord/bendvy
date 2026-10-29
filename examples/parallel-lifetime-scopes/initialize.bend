import Base
import ./actor.bend as Actor
import ./setup.bend as Scene
import ./scheduled.bend as Scheduled
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-relation-schema-setup.bend as Setup
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/schema-fragments.bend as Fragment

type Node<-S:Data> is Type:
  NodeReady{world:Scheduled.World(~S),handle:W.Handle<S>}
  NodeRefused{world:Scheduled.World(~S),error:W.WorldError}
def activated(~S:Data,handle:W.Handle<S>,result:Scheduled.World(~S) & W.Status) -> Node<S>:
  match result:
    case (world,W.Accepted{}):NodeReady{world,handle}
    case (world,W.Rejected{error}):NodeRefused{world,error}
def reserved(~S:Data,result:Scheduled.World(~S) & W.Reservation<S>) -> Node<S>:
  match result:
    case (world,W.Reserved{+handle}):activated(~S,handle,W.activate(~S,~Scheduled.Columns(~S),~Scheduled.Resources(~S),~Unit,world,handle))
    case (world,W.ReservationRejected{error}):NodeRefused{world,error}
# Setup creates genuinely live, initially component-free scene entities through
# the actual allocator. These handles are never fabricated from literal keys.
def node(~S:Data,world:Scheduled.World(~S)) -> Node<S>:
  reserved(~S,W.reserve_id(~S,~Scheduled.Columns(~S),~Scheduled.Resources(~S),~Unit,world))
type Initialization<-S:Data> is Type:
  SceneInitialized{factory:W.Factory,definition:Scheduled.Definition<S>}
  NodeSetupRefused{factory:W.Factory,context:Context.Context<S,Scheduled.Resources(~S),Actor.resources(~S),{==}>,world:Scheduled.World(~S),created:List<&2,W.Handle<S>>,session:Actor.Session,error:W.WorldError}
  SchemaSetupRefused{factory:W.Factory,owners:Scheduled.Resources(~S),session:Actor.Session,error:Maybe<&2,Fragment.Error>}
def replacement_ready(~S:Data,factory:W.Factory,context:Context.Context<S,Scheduled.Resources(~S),Actor.resources(~S),{==}>,+child:W.Handle<S>,+parent:W.Handle<S>,session:Actor.Session,result:Node<S>) -> Initialization<S>:
  match result:
    case NodeReady{world,replacement}:SceneInitialized{factory,Scheduled.define(~S,context,world,Actor.User{child,parent,replacement,session})}
    case NodeRefused{world,error}:NodeSetupRefused{factory,context,world,[child,parent],session,error}
def parent_ready(~S:Data,factory:W.Factory,context:Context.Context<S,Scheduled.Resources(~S),Actor.resources(~S),{==}>,+child:W.Handle<S>,session:Actor.Session,result:Node<S>) -> Initialization<S>:
  match result:
    case NodeReady{world,parent}:replacement_ready(~S,factory,context,child,parent,session,node(~S,world))
    case NodeRefused{world,error}:NodeSetupRefused{factory,context,world,[child],session,error}
def child_ready(~S:Data,factory:W.Factory,context:Context.Context<S,Scheduled.Resources(~S),Actor.resources(~S),{==}>,session:Actor.Session,result:Node<S>) -> Initialization<S>:
  match result:
    case NodeReady{world,child}:parent_ready(~S,factory,context,child,session,node(~S,world))
    case NodeRefused{world,error}:NodeSetupRefused{factory,context,world,[],session,error}
def schema_created(~S:Data,session:Actor.Session,result:Context.Initialization<S,Actor.components(),Actor.resources(~S),Unit>) -> Initialization<S>:
  match result:
    case Context.ContextCreated{factory,world,context}:child_ready(~S,factory,context,session,node(~S,world))
    case Context.SchemaRefused{factory,owners,error}:SchemaSetupRefused{factory,owners,session,Some{error}}
    case Context.NamespaceRefused{factory,owners}:SchemaSetupRefused{factory,owners,session,None{}}
def create(~S:Data,factory:W.Factory,resourceState:Actor.Session,localState:Actor.Session) -> Initialization<S>:
  schema_created(~S,localState,Setup.create(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.Session,~Scene.owners(~S,~Actor.Session,~U32,~Actor.project),factory,resourceState))
