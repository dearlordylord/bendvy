import Base
import ./registration.bend as Bind
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy

type First is Data:First{}
type Second is Data:Second{}
def World(~S:Data) -> Type:W.World<S,Unit,Array<U32>,Unit>
def empty(u:Unit) -> Unit:Unit{}
def project(owner:Array<U32>) -> Array<U32> & U32:Array.get(U32,owner,0)
def observed(~S:Data,value:World(~S) & U32) -> Sy.Outcome<World(~S),Unit,U32>:
  match value:
    case (world,value):Sy.Succeeded{world,value}
def get(~S:Data,world:World(~S)) -> World(~S) & U32:
  W.observe_resource(~S,~Unit,~Array<U32>,~Unit,~U32,~project,world)
def body(~H:Type,~cap:Cap.ValueRead<H,U32>,args:Unit,owner:H) -> H & U32:
  Cap.value_read(~H,~U32,~cap,owner)
def runner(~S:Data,world:World(~S),args:Unit) -> Sy.Outcome<World(~S),Unit,U32>:
  observed(~S,Cap.invoke(~(H => Cap.ValueRead<H,U32>),~Unit,~U32,~body,~World(~S),~Cap.ValueRead{get(~S)},args,world))
def initialize(~S:Data,world:World(~S)) -> Sy.RegistrationResult<S,Unit,Array<U32>,Unit,Unit,Unit,U32,runner(~S)>:
  Sy.register(~S,~Unit,~Array<U32>,~Unit,~Unit,~Unit,~U32,~runner(~S),world,"read-array",["array"])
def entry(~S:Data) -> SF.Entry<S>:SF.Entry{SF.Resource{},"array","array"}
# Both successful and rejected branches return the complete World owner.
type Report<S:Data> is Type:BindingDone{world:World(~S),registry:Sy.Registry<S,Unit,Array<U32>,Unit,Unit,Unit,U32,runner(~S)>,first:U32,second:U32} Declined{world:World(~S),error:SF.Error} RegistrationFailed{world:World(~S)} Refused{world:World(~S),registry:Sy.Registry<S,Unit,Array<U32>,Unit,Unit,Unit,U32,runner(~S)>} BodyFailed{world:World(~S),registry:Sy.Registry<S,Unit,Array<U32>,Unit,Unit,Unit,U32,runner(~S)>} CreateFailed{factory:W.Factory,resource:Array<U32>}
def second(~S:Data,first:U32,value:Sy.RunResult<S,Unit,Array<U32>,Unit,Unit,Unit,U32,runner(~S)>) -> Report<S>:
  match value:
    case Sy.Completed{registry,Sy.Succeeded{world,value}}:BindingDone{world,registry,first,value}
    case Sy.Completed{registry,Sy.Failed{world,_}}:BodyFailed{world,registry}
    case Sy.RegistrationRejected{registry,world,_}:Refused{world,registry}
def first(~S:Data,value:Sy.RunResult<S,Unit,Array<U32>,Unit,Unit,Unit,U32,runner(~S)>) -> Report<S>:
  match value:
    case Sy.Completed{registry,Sy.Succeeded{world,value}}:second(~S,value,Sy.run(~S,~Unit,~Array<U32>,~Unit,~Unit,~Unit,~U32,~runner(~S),registry,world,Unit{}))
    case Sy.Completed{registry,Sy.Failed{world,_}}:BodyFailed{world,registry}
    case Sy.RegistrationRejected{registry,world,_}:Refused{world,registry}
def registered(~S:Data,value:Sy.RegistrationResult<S,Unit,Array<U32>,Unit,Unit,Unit,U32,runner(~S)>) -> Report<S>:
  match value:
    case Sy.Registered{world,registry}:first(~S,Sy.run(~S,~Unit,~Array<U32>,~Unit,~Unit,~Unit,~U32,~runner(~S),registry,world,Unit{}))
    case Sy.RegistrationFailed{world}:RegistrationFailed{world}
def bound(~S:Data,value:SF.Bound<S,World(~S),Sy.RegistrationResult<S,Unit,Array<U32>,Unit,Unit,Unit,U32,runner(~S)>>) -> Report<S>:
  match value:
    case SF.Built{registration}:registered(~S,registration)
    case SF.BindRejected{error,SF.Fragment{_,world}}:Declined{world,error}
def created(~S:Data,entries:List<&2,SF.Entry<S>>,value:W.Creation<S,Unit,Array<U32>,Unit>) -> Report<S>:
  match value:
    case W.Created{_,world}:bound(~S,Bind.bind(~S,~Unit,~Array<U32>,~Unit,~Unit,~Unit,~U32,~runner(~S),~initialize(~S),SF.Fragment{entries,world},[entry(~S)]))
    case W.CreateRejected{factory,resource}:CreateFailed{factory,resource}
def run(~S:Data,entries:List<&2,SF.Entry<S>>) -> Report<S>:
  created(~S,entries,W.create(~S,~Unit,~Array<U32>,~Unit,~empty,W.factory(),ANode{ALeaf{7},ALeaf{9}}))
def main() -> Report<First> & (Report<Second> & (Report<First> & Report<First>)):
  (run(~First,[entry(~First)]),(run(~Second,[entry(~Second)]),(run(~First,[]),run(~First,[entry(~First),entry(~First)]))))
