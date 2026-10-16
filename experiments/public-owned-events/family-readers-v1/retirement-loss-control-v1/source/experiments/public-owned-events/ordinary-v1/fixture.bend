import Base
import ./payload.bend as P
import ../../../src/ecs/ordinary-owned-event.bend as Pub
import ../../../src/ecs/owned-event-runtime.bend as Read
import ../../../src/ecs/owned-event-storage.bend as Storage
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/world.bend as W

def domain(~S:Data) -> Pub.Domain<S,Array<U32>>:Pub.domain(~S,~Array<U32>,"Cargo")
type PublishError is Data:PublishFailed{}
type PublishArgs is Type:PublishArgs{fail:Bool,payloads:List<Array<U32>>}
def sent(~S:Data,~H:Type,~grant:Pub.Write<S,Array<U32>,domain(~S),H>,payloads:List<Array<U32>>,owner:H) -> H:
  match payloads:
    case []:owner
    case payload <> tail:sent(~S,~H,~grant,tail,Pub.emit(~S,~Array<U32>,~domain(~S),~H,~grant,owner,payload))
def publish_outcome(fail:Bool) -> T.Outcome<PublishError>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{PublishFailed{}}
def write(~S:Data,~H:Type,~grant:Pub.Write<S,Array<U32>,domain(~S),H>,args:PublishArgs,owner:H) -> H & (T.Outcome<PublishError> & Unit):
  match args:
    case PublishArgs{fail,payloads}:(sent(~S,~H,~grant,payloads,owner),(publish_outcome(fail),Unit{}))
def World(~S:Data) -> Type:W.World<S,Unit,Storage.Resources<Unit,Array<U32>>,Nat>
def Runtime(~S:Data) -> Type:Ev.Runtime<S,Unit,Storage.Resources<Unit,Array<U32>>,Nat>
def Publisher(~S:Data) -> Type:Pub.Registry(~S,~Unit,~Unit,~Array<U32>,~domain(~S),~PublishArgs,~PublishError,~Unit,~write(~S))
def Registry(~S:Data) -> Type:Read.Registry(~S,~Unit,~Unit,~Array<U32>,~P.Request,~P.Projection,~P.Args,~P.Error,~domain(~S),~P.at,~P.read)
type Host<S:Data> is Type:
  Host{runtime:Runtime(~S),foreign:World(~S),publisher:Publisher(~S),fast:Ev.Reader<S>,fastRegistry:Registry(~S),slow:Ev.Reader<S>,slowRegistry:Registry(~S),fastArgs:P.Args,slowArgs:P.Args}
type Started<S:Data> is Type:
  Started{host:Host<S>}
  SetupFailed{}
def slow_registered(~S:Data,foreign:World(~S),publisher:Publisher(~S),fast:Ev.Reader<S>,fastRegistry:Registry(~S),result:Ev.Registered<S,Unit,Storage.Resources<Unit,Array<U32>>,Nat,P.Args,Unit,Read.Reply<P.Error,P.Args>,Read.runner(~S,~Unit,~Unit,~Array<U32>,~P.Request,~P.Projection,~P.Args,~P.Error,~domain(~S),~P.at,~P.read)>) -> Started<S>:
  match result:
    case Ev.Registered{runtime,reader,registry}:Started{Host{runtime,foreign,publisher,fast,fastRegistry,reader,registry,P.args(False{},100),P.args(False{},200)}}
    case _:SetupFailed{}
def fast_registered(~S:Data,foreign:World(~S),publisher:Publisher(~S),result:Ev.Registered<S,Unit,Storage.Resources<Unit,Array<U32>>,Nat,P.Args,Unit,Read.Reply<P.Error,P.Args>,Read.runner(~S,~Unit,~Unit,~Array<U32>,~P.Request,~P.Projection,~P.Args,~P.Error,~domain(~S),~P.at,~P.read)>) -> Started<S>:
  match result:
    case Ev.Registered{runtime,reader,registry}:slow_registered(~S,foreign,publisher,reader,registry,Read.define(~S,~Unit,~Unit,~Array<U32>,~P.Request,~P.Projection,~P.Args,~P.Error,~domain(~S),~P.at,~P.read,runtime,"slow"))
    case _:SetupFailed{}
def writer_registered(~S:Data,foreign:World(~S),result:Sys.RegistrationResult<S,Unit,Storage.Resources<Unit,Array<U32>>,Nat,PublishArgs,Unit,Pub.Reply<PublishError,Unit,Array<U32>>,Pub.runner(~S,~Unit,~Unit,~Array<U32>,~domain(~S),~PublishArgs,~PublishError,~Unit,~write(~S))>) -> Started<S>:
  match result:
    case Sys.Registered{world,registry}:fast_registered(~S,foreign,registry,Read.define(~S,~Unit,~Unit,~Array<U32>,~P.Request,~P.Projection,~P.Args,~P.Error,~domain(~S),~P.at,~P.read,Ev.start(~S,~Unit,~Storage.Resources<Unit,Array<U32>>,~Nat,world,2n),"fast"))
    case _:SetupFailed{}
def start(~S:Data,world:World(~S),foreign:World(~S)) -> Started<S>:
  writer_registered(~S,foreign,Pub.define(~S,~Unit,~Unit,~Array<U32>,~domain(~S),~PublishArgs,~PublishError,~Unit,~write(~S),world,"publisher"))
def resources() -> Storage.Resources<Unit,Array<U32>>:Storage.Resources{Unit{},Log.empty(~Array<U32>)}
