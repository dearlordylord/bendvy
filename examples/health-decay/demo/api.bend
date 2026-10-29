import Base
import ../schema.bend as S
import ../root.bend as Root
import ../registration.bend as Registration
import ../observe.bend as Observe
import ../../../src/ecs/execution-composer-schema.bend as Setup
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/dependency-application.bend as App

type State is Type:State{app:Root.Application(),inspector:I.Instance<S.Schema>,tick:U32}
type Packet is Type:
  Packet{state:State,frame:String}
  Failed{error:String}
def rendered(+tick:U32,result:Root.Application() & (I.Instance<S.Schema> & Result<&2,&2,Unit,Observe.Snapshot>)) -> Packet:
  match result:
    case (app,(inspector,Done{Observe.Snapshot{_,_,entities}})):Packet{State{app,inspector,tick},"{\"tick\":" ++ U32.show(tick) ++ ",\"entities\":[" ++ entities ++ "]}"}
    case _:Failed{"Observation refused"}
def executed(tick:U32,inspector:I.Instance<S.Schema>,result:Root.Application() & App.Report<String,Unit>) -> Packet:
  match result:
    case (app,App.Finished{_}):rendered(tick,Observe.snapshot(Root.configure(True{},app),inspector))
    case _:Failed{"System refused"}
def registered(result:Maybe<Root.Application()>) -> IO(Packet):
  match result:
    case Some{app}:IO.bind(Root.Application() & App.Report<String,Unit>,Packet,Root.run(Root.prepare(app)),result => IO.pure(Packet,executed(0,I.Fresh{},result)))
    case None{}:IO.pure(Packet,Failed{"Registration refused"})
def created(result:Setup.Initialized<S.Schema,S.components(),S.resources(),Unit>) -> IO(Packet):
  match result:
    case Setup.SchemaCreated{_,world}:registered(Registration.attach(world))
    case _:IO.pure(Packet,Failed{"World creation refused"})
def start(_:Unit) -> IO(Packet):created(S.create(W.factory()))
def step(state:State) -> IO(Packet):
  match state:
    case State{app,inspector,tick}:IO.bind(Root.Application() & App.Report<String,Unit>,Packet,Root.run(app),result => IO.pure(Packet,executed(U32.add(tick,1),inspector,result)))
