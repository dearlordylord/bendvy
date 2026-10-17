import Base
import ./fixture.bend as F
import ./setup.bend as Setup
import ./scenario.bend as Scenario
import ./observe.bend as O
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as WIO

def refused_resource(~S:Data,observed:F.Resources(~S) & String) -> String:
  match observed:
    case (resource,text):"creation-refused:" ++ text
def foreign_observed(~S:Data,observed:F.World(~S) & String,resource:String) -> String:
  match observed:
    case (world,text):text ++ ";" ++ resource
def foreign_refused(~S:Data,world:F.World(~S),resource:F.Resources(~S)) -> String:foreign_observed(~S,O.world(~S,world),refused_resource(~S,O.resources(~S,resource)))
def foreign_reserved(~S:Data,world:F.World(~S),observed:F.World(~S) & W.Reservation<S>) -> String:
  match observed:
    case (foreign,W.Reserved{handle}):Scenario.start(~S,world,foreign,handle)
    case (foreign,W.ReservationRejected{_}):foreign_observed(~S,O.world(~S,world),foreign_observed(~S,O.world(~S,foreign),"foreign-reservation-refused"))
def foreign_created(~S:Data,world:F.World(~S),created:WIO.Creation<S,F.Store(~S),F.Resources(~S),F.Events(~S)>) -> IO(String):
  match created:
    case WIO.Created{foreign}:IO.pure(String,foreign_reserved(~S,world,Setup.spawn(~S,foreign,99,False{})))
    case WIO.Refused{resource}:IO.pure(String,foreign_refused(~S,world,resource))
def primary_created(~S:Data,created:WIO.Creation<S,F.Store(~S),F.Resources(~S),F.Events(~S)>) -> IO(String):
  match created:
    case WIO.Created{world}:IO.bind(WIO.Creation<S,F.Store(~S),F.Resources(~S),F.Events(~S)>,String,WIO.create(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Setup.empty(~S),Setup.resources(~S)),foreign => foreign_created(~S,world,foreign))
    case WIO.Refused{resource}:IO.pure(String,refused_resource(~S,O.resources(~S,resource)))
def run(~S:Data) -> IO(String):IO.bind(WIO.Creation<S,F.Store(~S),F.Resources(~S),F.Events(~S)>,String,WIO.create(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Setup.empty(~S),Setup.resources(~S)),primary => primary_created(~S,primary))
