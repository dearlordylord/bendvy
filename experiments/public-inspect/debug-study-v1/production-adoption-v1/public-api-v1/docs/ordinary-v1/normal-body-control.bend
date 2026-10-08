import Base
import ./normal-values.bend as Game
import ./normal-application.bend as Application
import ./normal-snapshot.bend as Snapshot
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
# Evidence control executes the actual ordinary runner, not a duplicate grant.
type Cursor is Data:
  Fresh{}
  Active{cursor:U32,registeredAt:U32}
type Observation is Data:
  Observation{before:Snapshot.Snapshot,after:Snapshot.Snapshot,cursor:Cursor,result:Result<&2,&2,Unit,Bool>}
type Observed is Type:
  Observed{world:Application.World(),instance:I.Instance<Game.GameSchema>,observation:Observation}
  Failed{world:Application.World(),error:Unit}
def cursor(instance:I.Instance<Game.GameSchema>) -> I.Instance<Game.GameSchema> & Cursor:
  match instance:
    case I.Fresh{}:(I.Fresh{},Fresh{})
    case I.Active{+value,+registeredAt}:(I.Active{value,registeredAt},Active{value,registeredAt})
def finished(before:Snapshot.Snapshot,result:Result<&2,&2,Unit,Bool>,observed:I.Instance<Game.GameSchema> & Cursor,worldObserved:Application.World() & Snapshot.Snapshot) -> Observed:
  match observed worldObserved:
    case (instance,mark),(world,after):Observed{world,instance,Observation{before,after,mark,result}}
def ran(before:Snapshot.Snapshot,result:Sys.Outcome<Application.World(),Unit,I.Instance<Game.GameSchema> & Result<&2,&2,Unit,Bool>>) -> Observed:
  match result:
    case Sys.Failed{world,error}:Failed{world,error}
    case Sys.Succeeded{world,(instance,value)}:finished(before,value,cursor(instance),Snapshot.world(world))
def before(result:Application.World() & Snapshot.Snapshot) -> Observed:
  match result:
    case (world,snapshot):ran(snapshot,Application.runner(world,(I.Fresh{},Unit{})))
def run(world:Application.World()) -> Observed:
  before(Snapshot.world(world))
