import Base
import ./normal-values.bend as Game
import ./normal-application.bend as Application
import ./normal-consumer.bend as Consumer
import ./normal-snapshot.bend as Snapshot
import ./normal-body-control.bend as Body
import ./normal-registered-control.bend as Registered
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
# Evidence-only whole-owner observation around real registered dispatch.
type Observation is Data:
  Observation{beforeWorld:Snapshot.Snapshot,afterWorld:Snapshot.Snapshot,beforeApp:Consumer.AppSnapshot,afterApp:Consumer.AppSnapshot,cursor:Body.Cursor,result:Result<&2,&2,Unit,Bool>}
type Observed is Type:
  Succeeded{world:Application.World(),app:Application.Application(),instance:I.Instance<Game.GameSchema>,observation:Observation}
  Rejected{world:Application.World(),app:Application.Application(),args:I.Instance<Game.GameSchema> & Unit}
  Failed{world:Application.World(),app:Application.Application(),error:Unit}
def finished(beforeWorld:Snapshot.Snapshot,beforeApp:Consumer.AppSnapshot,afterApp:Consumer.AppSnapshot,value:Result<&2,&2,Unit,Bool>,mark:Body.Cursor,instance:I.Instance<Game.GameSchema>,app:Application.Application(),observed:Application.World() & Snapshot.Snapshot) -> Observed:
  match observed:
    case (world,afterWorld):Succeeded{world,app,instance,Observation{beforeWorld,afterWorld,beforeApp,afterApp,mark,value}}
def marked(beforeWorld:Snapshot.Snapshot,beforeApp:Consumer.AppSnapshot,afterApp:Consumer.AppSnapshot,value:Result<&2,&2,Unit,Bool>,world:Application.World(),app:Application.Application(),observed:I.Instance<Game.GameSchema> & Body.Cursor) -> Observed:
  match observed:
    case (instance,mark):finished(beforeWorld,beforeApp,afterApp,value,mark,instance,app,Snapshot.world(world))
def after_app(beforeWorld:Snapshot.Snapshot,beforeApp:Consumer.AppSnapshot,value:Result<&2,&2,Unit,Bool>,instance:I.Instance<Game.GameSchema>,world:Application.World(),observed:Application.Application() & Consumer.AppSnapshot) -> Observed:
  match observed:
    case (app,afterApp):marked(beforeWorld,beforeApp,afterApp,value,world,app,Body.cursor(instance))
def ran(beforeWorld:Snapshot.Snapshot,beforeApp:Consumer.AppSnapshot,result:Registered.Outcome) -> Observed:
  match result:
    case Registered.Rejected{world,app,args}:Rejected{world,app,args}
    case Registered.Failed{world,app,error}:Failed{world,app,error}
    case Registered.Succeeded{world,app,instance,value}:after_app(beforeWorld,beforeApp,value,instance,world,Consumer.app(app))
def before_app(world:Application.World(),beforeWorld:Snapshot.Snapshot,observed:Application.Application() & Consumer.AppSnapshot) -> Observed:
  match observed:
    case (app,beforeApp):ran(beforeWorld,beforeApp,Registered.run(world,app))
def before_world(app:Application.Application(),observed:Application.World() & Snapshot.Snapshot) -> Observed:
  match observed:
    case (world,beforeWorld):before_app(world,beforeWorld,Consumer.app(app))
def run(world:Application.World(),app:Application.Application()) -> Observed:
  before_world(app,Snapshot.world(world))
