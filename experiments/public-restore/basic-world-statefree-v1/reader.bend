import Base
import model.bend as F
import events.bend as Event
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/owned-event-family-reader-runtime.bend as Core
import ../../../src/ecs/event-family-routing.bend as Route
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/event-runtime.bend as Ev
def at(payload:Array<U32>,request:Unit) -> Array<U32> & U32:Array.get(U32,payload,0)
def read_returned(~H:Type,args:Array<U32>,observed:H & U32) -> H & (T.Outcome<Unit> & Array<U32>):
  match observed:
    case (owner,value):(owner,(T.Success{},Array.set(U32,args,0,value)))
def read_body(~H:Type,~read:Cap.Request<H,Unit,U32>,owner:H,args:Array<U32>) -> H & (T.Outcome<Unit> & Array<U32>):read_returned(~H,args,Cap.request(~H,~Unit,~U32,~read,owner,Unit{}))
def runner(~S:Data) -> (F.World(~S) -> Ev.Input<Nat,Array<U32>> -> Sys.Outcome<F.World(~S),Unit,Core.Reply<Unit,Array<U32>>>):Core.runner(~S,~F.FullStore(~S),~F.FullResources(~S),~Array<U32>,~(F.UserResources(~S) & Event.Rest(~S)),~F.Events(~S),~Event.resource_path(~S),~Unit,~U32,~Array<U32>,~Unit,~at,~read_body)
def ReaderOwner(~S:Data) -> Type:Route.Reader<S,Nat,Event.State(~S),Event.state_take(~S),Event.state_put(~S)>
def Registry(~S:Data) -> Type:Sys.Registry<S,F.FullStore(~S),F.FullResources(~S),F.Events(~S),Ev.Input<Nat,Array<U32>>,Unit,Core.Reply<Unit,Array<U32>>,runner(~S)>
def Registration(~S:Data) -> Type:Route.Registration<S,F.FullStore(~S),F.FullResources(~S),F.Events(~S),Nat,Event.State(~S),Array<U32>,Unit,Core.Reply<Unit,Array<U32>>,Event.state_take(~S),Event.state_put(~S),runner(~S)>
def ReadResult(~S:Data) -> Type:Route.RunResult<S,F.FullStore(~S),F.FullResources(~S),F.Events(~S),Nat,Event.State(~S),Array<U32>,Unit,Core.Reply<Unit,Array<U32>>,Event.state_take(~S),Event.state_put(~S),runner(~S)>
