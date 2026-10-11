import Base
import types.bend as T
import lenses.bend as Lens
import systems.bend as SysBody
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as Stream
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
import operation.bend as Operation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-schedule.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
type Application<S:Data> is Type:
  Application{world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,first:B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>,second:B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>,firstReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.first_reader_runner(~S)>>,secondReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.second_reader_runner(~S)>>,statuses:List<&2,String>}
  RecoveringFirst{result:Operation.MarkerResult<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>,second:B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>,firstReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.first_reader_runner(~S)>>,secondReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.second_reader_runner(~S)>>,statuses:List<&2,String>}
  RecoveringSecond{first:B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>,result:Operation.MarkerResult<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>,firstReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.first_reader_runner(~S)>>,secondReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.second_reader_runner(~S)>>,statuses:List<&2,String>}
def install_local(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,+id:U32) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,List.append(&1,T.LocalOwner,locals,[T.LocalOwner{ns,id,Local.Cell{ANode{ALeaf{0},ALeaf{id}}}}]),firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}
def first_registered(~S:Data,selector:B.Selector<S,T.FirstKey,T.First>,needs:List<&2,U32>,result:Sys.RegistrationResult<S,T.Store<S>,T.Resources<S>,T.Pulse,H.Invocation<T.First>,String,Unit,SysBody.first_runner(~S)>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & List<&1,B.Scheduled<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>>:
  match result:
    case Sys.Registered{world,Sys.Registry{+namespace,+id,+name,+access,+cursor}}:(install_local(~S,world,id),[B.Scheduled{selector,needs,H.Entry{id,Sys.Registry{namespace,id,name,access,cursor}}}])
    case Sys.RegistrationFailed{world}:(world,[])
def register_first(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,selector:B.Selector<S,T.FirstKey,T.First>,name:String) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & List<&1,B.Scheduled<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>>:first_registered(~S,selector,[1,2,1],Sys.register(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,~H.Invocation<T.First>,~String,~Unit,~SysBody.first_runner(~S),world,name,["owned:write","Local:write","deferred:write"]))
def first_enter(~S:Data,+namespace:U32,prior:List<&1,B.Scheduled<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>>,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & List<&1,B.Scheduled<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>:
  (world,entry)=pair
  (world,B.Bundle{namespace,List.append(&1,B.Scheduled<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>,prior,entry)})
def first_transition(~S:Data,+namespace:U32,exit:List<&1,B.Scheduled<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>>,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & List<&1,B.Scheduled<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>:
  (world,transition)=pair
  first_enter(~S,namespace,List.append(&1,B.Scheduled<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>,exit,transition),register_first(~S,world,B.EnterTo{T.Warm{}},"first-enter"))
def first_exit(~S:Data,+namespace:U32,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & List<&1,B.Scheduled<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>:
  (world,exit)=pair
  first_transition(~S,namespace,exit,register_first(~S,world,B.TransitionPair{T.Cold{},T.Warm{}},"first-transition"))
def build_first(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,namespace:U32) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>:first_exit(~S,namespace,register_first(~S,world,B.ExitFrom{T.Cold{}},"first-exit"))
def second_registered(~S:Data,selector:B.Selector<S,T.SecondKey,T.Second>,needs:List<&2,U32>,result:Sys.RegistrationResult<S,T.Store<S>,T.Resources<S>,T.Pulse,H.Invocation<T.Second>,String,Unit,SysBody.second_runner(~S)>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & List<&1,B.Scheduled<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>>:
  match result:
    case Sys.Registered{world,Sys.Registry{+namespace,+id,+name,+access,+cursor}}:(install_local(~S,world,id),[B.Scheduled{selector,needs,H.Entry{id,Sys.Registry{namespace,id,name,access,cursor}}}])
    case Sys.RegistrationFailed{world}:(world,[])
def register_second(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,selector:B.Selector<S,T.SecondKey,T.Second>,name:String) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & List<&1,B.Scheduled<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>>:second_registered(~S,selector,[1,2,1],Sys.register(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,~H.Invocation<T.Second>,~String,~Unit,~SysBody.second_runner(~S),world,name,["owned:write","Local:write","deferred:write"]))
def second_enter(~S:Data,+namespace:U32,prior:List<&1,B.Scheduled<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>>,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & List<&1,B.Scheduled<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>:
  (world,entry)=pair
  (world,B.Bundle{namespace,List.append(&1,B.Scheduled<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>,prior,entry)})
def second_transition(~S:Data,+namespace:U32,exit:List<&1,B.Scheduled<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>>,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & List<&1,B.Scheduled<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>:
  (world,transition)=pair
  second_enter(~S,namespace,List.append(&1,B.Scheduled<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>,exit,transition),register_second(~S,world,B.EnterTo{T.Active{7}},"second-enter"))
def second_exit(~S:Data,+namespace:U32,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & List<&1,B.Scheduled<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>:
  (world,exit)=pair
  second_transition(~S,namespace,exit,register_second(~S,world,B.TransitionPair{T.Idle{},T.Active{7}},"second-transition"))
def build_second(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,namespace:U32) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>:second_exit(~S,namespace,register_second(~S,world,B.ExitFrom{T.Idle{}},"second-exit"))
def readers_installed(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,+namespace:U32) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,Some{Stream.Reader{namespace,1}},Some{Stream.Reader{namespace,1}},locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}
def reader_second(~S:Data,first:B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>,second:B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>,firstReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.first_reader_runner(~S)>>,result:Sys.RegistrationResult<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.second_reader_runner(~S)>) -> Application<S>:
  match result:
    case Sys.Registered{world,registry}:Application{world,first,second,firstReader,Some{registry},[]}
    case Sys.RegistrationFailed{world}:Application{world,first,second,firstReader,None{},[]}
def reader_first(~S:Data,first:B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>,second:B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>,result:Sys.RegistrationResult<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.first_reader_runner(~S)>) -> Application<S>:
  match result:
    case Sys.Registered{world,registry}:reader_second(~S,first,second,Some{registry},Sys.register(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,~Unit,~String,~Unit,~SysBody.second_reader_runner(~S),world,"second-reader",["second-stream:read"]))
    case Sys.RegistrationFailed{world}:reader_second(~S,first,second,None{},Sys.register(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,~Unit,~String,~Unit,~SysBody.second_reader_runner(~S),world,"second-reader",["second-stream:read"]))
def second_built(~S:Data,namespace:U32,first:B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>) -> Application<S>:
  (world,second)=pair
  reader_first(~S,first,second,Sys.register(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,~Unit,~String,~Unit,~SysBody.first_reader_runner(~S),readers_installed(~S,world,namespace),"first-reader",["first-stream:read"]))
def first_built(~S:Data,+namespace:U32,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>) -> Application<S>:
  (world,first)=pair
  second_built(~S,namespace,first,build_second(~S,world,namespace))
def named(~S:Data,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & U32) -> Application<S>:
  (world,+namespace)=pair
  first_built(~S,namespace,build_first(~S,world,namespace))
def initial_resources(~S:Data) -> T.Resources<S>:T.Resources{ANode{ALeaf{11},ALeaf{12}},ANode{ALeaf{21},ALeaf{22}},M.Present{T.Cold{},M.NoPending{},None{},False{}},M.Present{T.Idle{},M.NoPending{},None{},False{}},Stream.empty(~T.First),Stream.empty(~T.Second),None{},None{},[],0n,0n,[],[],[],0}
def store(~S:Data,_:Unit) -> T.Store<S>:T.Store{Col.Column{ALeaf{Some{ANode{ALeaf{31},ALeaf{32}}}},[]},Col.Column{ALeaf{Some{ANode{ALeaf{41},ALeaf{42}}}},[]}}
type Construction<S:Data> is Type:
  Constructed{factory:W.Factory,app:Application<S>}
  Refused{factory:W.Factory}
def activated(~S:Data,factory:W.Factory,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & W.Status) -> Construction<S>:
  match pair:
    case (world,W.Accepted{}):Constructed{factory,named(~S,W.namespace(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,W.enqueue(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,world,SysBody.structural(~S))))}
    case (_,W.Rejected{_}):Refused{factory}
def reserved(~S:Data,factory:W.Factory,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & W.Reservation<S>) -> Construction<S>:
  match pair:
    case (world,W.Reserved{handle}):activated(~S,factory,W.activate(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,world,handle))
    case (_,W.ReservationRejected{_}):Refused{factory}
def created(~S:Data,result:W.Creation<S,T.Store<S>,T.Resources<S>,T.Pulse>) -> Construction<S>:
  match result:
    case W.Created{factory,world}:reserved(~S,factory,W.reserve_id(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,world))
    case W.CreateRejected{factory,_}:Refused{factory}
def create(~S:Data,factory:W.Factory) -> Construction<S>:created(~S,W.create(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,~store(~S),factory,initial_resources(~S)))
def first_availability(~S:Data,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & M.Slot<S,T.FirstKey,T.First>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & Bool:
  match pair:
    case (world,M.Missing{}):(Lens.put_first(~S,world,M.Missing{}),False{})
    case (world,slot):(Lens.put_first(~S,world,slot),True{})
def has_first(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,id:U32) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & Bool:
  match id:
    case 1:first_availability(~S,Lens.take_first(~S,world))
    case 2:(world,True{})
    case _:(world,False{})
def second_availability(~S:Data,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & M.Slot<S,T.SecondKey,T.Second>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & Bool:
  match pair:
    case (world,M.Missing{}):(Lens.put_second(~S,world,M.Missing{}),False{})
    case (world,slot):(Lens.put_second(~S,world,slot),True{})
def has_second(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,id:U32) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & Bool:
  match id:
    case 1:second_availability(~S,Lens.take_second(~S,world))
    case 2:(world,True{})
    case _:(world,False{})
def phase_text(value:H.Phase) -> String:
  match value:
    case H.Exit{}:"exit"
    case H.Transition{}:"transition"
    case H.Enter{}:"enter"
def status(value:B.Status<U32>) -> String:
  match value:
    case B.Completed{}:"Completed"
    case B.ForeignBundle{}:"ForeignBundle"
    case B.MachineUnavailable{}:"MachineUnavailable"
    case B.MissingRequirements{missing}:"Missing:" ++ List.show(&2,U32,U32.show,missing)
    case B.HandlerFailed{phase,error}:"Failed:" ++ phase_text(phase) ++ ":" ++ error
def first_returned(~S:Data,second:B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>,firstReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.first_reader_runner(~S)>>,secondReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.second_reader_runner(~S)>>,prior:List<&2,String>,result:Operation.MarkerResult<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>) -> Application<S>:
  match result:
    case Operation.MarkerResult{B.Returned{first,world,outcome},_,_}:Application{world,first,second,firstReader,secondReader,List.append(&2,String,prior,["first:" ++ status(outcome)])}
    case result:RecoveringFirst{result,second,firstReader,secondReader,prior}
def rewind(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,_,firstDelivered,secondDelivered,applied},_,_,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,T.Resources{Array.set(U32,owned,0,11),sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,[],firstDelivered,secondDelivered,applied},[],[],registrations,nextSystem,clock}
def marker_first(~S:Data,app:Application<S>) -> Application<S>:
  match app:
    case Application{world,first,second,firstReader,secondReader,prior}:first_returned(~S,second,firstReader,secondReader,prior,Operation.run(~S,~T.FirstKey,~T.First,~U32,~T.Store<S>,~T.Resources<S>,~T.Pulse,~SysBody.first_runner(~S),~Lens.take_first(~S),~Lens.put_first(~S),~Lens.publish_first(~S),~T.same_first,~U32.is_eq,~has_first(~S),~Lens.frame_first(~S),~rewind(~S),Ordinary.declare(~S,"first-marker"),first,world))
    case app:app
def second_returned(~S:Data,first:B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>,firstReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.first_reader_runner(~S)>>,secondReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.second_reader_runner(~S)>>,prior:List<&2,String>,result:Operation.MarkerResult<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>) -> Application<S>:
  match result:
    case Operation.MarkerResult{B.Returned{second,world,outcome},_,_}:Application{world,first,second,firstReader,secondReader,List.append(&2,String,prior,["second:" ++ status(outcome)])}
    case result:RecoveringSecond{first,result,firstReader,secondReader,prior}
def marker_second(~S:Data,app:Application<S>) -> Application<S>:
  match app:
    case Application{world,first,second,firstReader,secondReader,prior}:second_returned(~S,first,firstReader,secondReader,prior,Operation.run(~S,~T.SecondKey,~T.Second,~U32,~T.Store<S>,~T.Resources<S>,~T.Pulse,~SysBody.second_runner(~S),~Lens.take_second(~S),~Lens.put_second(~S),~Lens.publish_second(~S),~T.same_second,~U32.is_eq,~has_second(~S),~Lens.frame_second(~S),~rewind(~S),Ordinary.declare(~S,"second-marker"),second,world))
    case app:app
def queue(~S:Data,app:Application<S>) -> Application<S>:
  match app:
    case Application{world,first,second,firstReader,secondReader,prior}:Application{Lens.queue_second(~S,Lens.queue_first(~S,world,T.Warm{}),T.Active{7}),first,second,firstReader,secondReader,prior}
    case app:app
def first_reader_returned(~S:Data,first:B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>,second:B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>,other:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.second_reader_runner(~S)>>,prior:List<&2,String>,result:Sys.RunResult<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.first_reader_runner(~S)>) -> Application<S>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,_}}:Application{world,first,second,Some{registry},other,List.append(&2,String,prior,["first-reader:Completed"])}
    case Sys.Completed{registry,Sys.Failed{world,error}}:Application{world,first,second,Some{registry},other,List.append(&2,String,prior,[error])}
    case Sys.RegistrationRejected{registry,world,_}:Application{world,first,second,Some{registry},other,prior}
def read_first(~S:Data,app:Application<S>) -> Application<S>:
  match app:
    case Application{world,first,second,Some{registry},secondReader,prior}:first_reader_returned(~S,first,second,secondReader,prior,Sys.run_tracked(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,~Unit,~String,~Unit,~SysBody.first_reader_runner(~S),registry,world,Unit{}))
    case app:app
def second_reader_returned(~S:Data,first:B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>,second:B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>,other:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.first_reader_runner(~S)>>,prior:List<&2,String>,result:Sys.RunResult<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.second_reader_runner(~S)>) -> Application<S>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,_}}:Application{world,first,second,other,Some{registry},List.append(&2,String,prior,["second-reader:Completed"])}
    case Sys.Completed{registry,Sys.Failed{world,error}}:Application{world,first,second,other,Some{registry},List.append(&2,String,prior,[error])}
    case Sys.RegistrationRejected{registry,world,_}:Application{world,first,second,other,Some{registry},prior}
def read_second(~S:Data,app:Application<S>) -> Application<S>:
  match app:
    case Application{world,first,second,firstReader,Some{registry},prior}:second_reader_returned(~S,first,second,firstReader,prior,Sys.run_tracked(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,~Unit,~String,~Unit,~SysBody.second_reader_runner(~S),registry,world,Unit{}))
    case app:app
