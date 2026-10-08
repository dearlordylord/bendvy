import Base
import ./normal-values.bend as Game
import ./normal-application.bend as Application
import ./normal-snapshot.bend as Snapshot
import ./canonical-schema.bend as Schema
import ./canonical-app.bend as App
import ./canonical-retained.bend as Retained
import ./canonical-provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I

type AppSnapshot is Data:
  AppSnapshot{debug:App.Debug,namespace:U32,name:String,steps:List<&2,Sch.Step>,systemNamespace:U32,id:U32,systemName:String,access:List<&2,String>,cursor:U32,first:Schema.Path,second:Schema.Path,entries:List<&2,Schema.Entry<Game.GameSchema>>,ownerNeeds:List<&2,SP.Requirement<Game.GameSchema>>,needs:List<&2,SP.Requirement<Game.GameSchema>>}
type Observation is Data:
  Observation{beforeWorld:Snapshot.Snapshot,afterWorld:Snapshot.Snapshot,beforeApp:AppSnapshot,afterApp:AppSnapshot,available:List<&2,SP.Requirement<Game.GameSchema>>,description:Maybe<&2,App.Description<Game.GameSchema>>}
type Observed is Type:
  Observed{world:Application.World(),app:Application.Application(),observation:Observation}
def app(app:Application.Application()) -> Application.Application() & AppSnapshot:
  match app:
    case App.Application{+debug,SP.Provisioned{Sch.Schedule{+namespace,+name,+steps,Retained.Registered{Sys.Registry{+systemNamespace,+id,+systemName,+access,+cursor},Schema.Params{+first,+second},+entries,+ownerNeeds}},+needs}}:(App.Application{debug,SP.Provisioned{Sch.Schedule{namespace,name,steps,Retained.Registered{Sys.Registry{systemNamespace,id,systemName,access,cursor},Schema.Params{first,second},entries,ownerNeeds}},needs}},AppSnapshot{debug,namespace,name,steps,systemNamespace,id,systemName,access,cursor,first,second,entries,ownerNeeds,needs})
def finish(app:Application.Application(),beforeWorld:Snapshot.Snapshot,beforeApp:AppSnapshot,afterApp:AppSnapshot,available:List<&2,SP.Requirement<Game.GameSchema>>,description:Maybe<&2,App.Description<Game.GameSchema>>,result:Application.World() & Snapshot.Snapshot) -> Observed:
  match result:
    case (world,afterWorld):Observed{world,app,Observation{beforeWorld,afterWorld,beforeApp,afterApp,available,description}}
def after_app(world:Application.World(),beforeWorld:Snapshot.Snapshot,beforeApp:AppSnapshot,available:List<&2,SP.Requirement<Game.GameSchema>>,description:Maybe<&2,App.Description<Game.GameSchema>>,result:Application.Application() & AppSnapshot) -> Observed:
  match result:
    case (app,afterApp):finish(app,beforeWorld,beforeApp,afterApp,available,description,Snapshot.world(world))
def described(world:Application.World(),beforeWorld:Snapshot.Snapshot,beforeApp:AppSnapshot,available:List<&2,SP.Requirement<Game.GameSchema>>,result:Application.Application() & Maybe<&2,App.Description<Game.GameSchema>>) -> Observed:
  match result:
    case (owner,description):after_app(world,beforeWorld,beforeApp,available,description,app(owner))

def available(owner:Application.Application(),beforeWorld:Snapshot.Snapshot,beforeApp:AppSnapshot,result:Application.World() & List<&2,SP.Requirement<Game.GameSchema>>) -> Observed:
  match result:
    case (world,resources):described(world,beforeWorld,beforeApp,resources,App.describe(~Game.GameSchema,~Unit,~Array<U32>,~Game.Clock,~U32,~Game.layout(),~(I.Instance<Game.GameSchema> & Unit),~Unit,~(I.Instance<Game.GameSchema> & Result<&2,&2,Unit,Bool>),~Application.runner,owner))

def before_app(world:Application.World(),beforeWorld:Snapshot.Snapshot,result:Application.Application() & AppSnapshot) -> Observed:
  match result:
    case (owner,beforeApp):available(owner,beforeWorld,beforeApp,Provision.provision(~Game.GameSchema,~Unit,~Array<U32>,~Game.Clock,~U32,~Game.layout(),world))

def before_world(owner:Application.Application(),result:Application.World() & Snapshot.Snapshot) -> Observed:
  match result:
    case (world,beforeWorld):before_app(world,beforeWorld,app(owner))

def observe(world:Application.World(),owner:Application.Application()) -> Observed:
  before_world(owner,Snapshot.world(world))
