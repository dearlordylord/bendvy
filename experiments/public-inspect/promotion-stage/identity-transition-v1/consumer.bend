import Base
import ./state.bend as State
import ./dump.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-world.bend as MW
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as OD
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-machine.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/inspector-transition-projection.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/inspector-stream-frame.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

def declaration(~S:Data) -> OD.Declaration<S,State.FlowToken,U32,State.Resources<S>,State.flow(~S)>:
  OD.declared(~S,~State.FlowToken,~U32,~State.Resources<S>,~State.flow(~S),"Flow",[7,9])
def put_resource(~S:Data,resources:State.Resources<S>,slot:M.Slot<S,State.FlowToken,U32>) -> State.Resources<S>:
  match resources:
    case State.Resources{owned,_,level,ran,flowStream,levelStream}:State.Resources{owned,slot,level,ran,flowStream,levelStream}
def take(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & M.Slot<S,State.FlowToken,U32>:
  MW.take(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),world)
def put(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,slot:M.Slot<S,State.FlowToken,U32>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>:
  MW.put(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~put_resource(~S),world,slot)
def log(~S:Data,resources:State.Resources<S>) -> State.Resources<S> & St.Stream<U32>:
  match resources:
    case State.Resources{owned,flow,level,ran,+stream,levelStream}:(State.Resources{owned,flow,level,ran,stream,levelStream},stream)
def publish(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,event:M.Transition<U32>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,State.Resources{owned,flow,level,ran,stream,levelStream},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,State.Resources{owned,flow,level,ran,St.publish(~U32,stream,1n,event),levelStream},events,pending,registrations,nextSystem,clock}
def runner(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,_:H.Invocation<U32>) -> Sys.Outcome<W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,String,Unit>:
  Sys.Succeeded{world,Unit{}}
def applied(~S:Data,result:H.HandlerResult<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,U32,runner(~S)>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String:
  match result:
    case H.Completed{_,world}:(world,"Completed")
    case H.Stopped{_,world,_,error}:(world,"Stopped:" ++ error)
def captured(~S:Data,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & M.Slot<S,State.FlowToken,U32>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String:
  (world,slot)=result
  applied(~S,H.run(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~U32,~runner(~S),~State.FlowToken,~take(~S),~put(~S),~publish(~S),~U32.is_eq,H.Owners{[],[],[]},world,M.snapshot(~S,~State.FlowToken,~U32,slot)))
def marker(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String:
  captured(~S,take(~S,world))
def queued(~S:Data,result:Tx.Returned<W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,String>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String:
  match result:
    case Tx.Returned{world,Tx.Success{}}:(world,"Success")
    case Tx.Returned{world,Tx.Failure{error}}:(world,"Failure:" ++ error)
def queue(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,skip:Bool) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String:
  queued(~S,App.queue(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~put_resource(~S),~U32.is_eq,~declaration(~S),~String,world,M.Set{7,skip},Tx.Success{}))
def inspected(~S:Data,result:F.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,U32> & T.TransitionLog<S,State.FlowToken,U32>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String:
  match result:
    case (F.Frame{Ev.Runtime{world,namespace,batches,positions,nextReader,tick,start,boundary,capacity,dropped},cursor},T.TransitionLog{stream}):(world,"inspect(cursor=" ++ U32.show(cursor) ++ ",namespace=" ++ U32.show(namespace) ++ ",batches=" ++ Nat.show(List.length(&2,Ev.Batch<A.Notice<S,U32>>,batches)) ++ ",positions=" ++ List.show(&2,Ev.Position,Dump.position,positions) ++ ",nextReader=" ++ U32.show(nextReader) ++ ",tick=" ++ Nat.show(tick) ++ ",start=" ++ Nat.show(start) ++ ",boundary=" ++ Nat.show(boundary) ++ ",capacity=" ++ Nat.show(capacity) ++ ",dropped=" ++ Nat.show(dropped) ++ "," ++ Dump.stream(stream) ++ ")")
def inspect(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String:
  inspected(~S,Cap.value_read(~F.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,U32>,~T.TransitionLog<S,State.FlowToken,U32>,~T.inspect(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~U32,~log(~S),~T.Declaration{"Flow"}),F.Frame{Ev.start(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,65536n),19}))
def clocked(~S:Data,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & U32) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>:
  (world,_)=result
  world
def pending(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>:
  clocked(~S,W.advance_clock(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world))
def store(~S:Data,_:Unit) -> A.Store<S,State.Components<S>>:
  A.empty(~S,~State.Components<S>,State.Components{ANode{ALeaf{31},ALeaf{32}}})
def resources(~S:Data) -> State.Resources<S>:
  State.Resources{ANode{ALeaf{11},ALeaf{12}},M.Present{7,M.NoPending{},None{},False{}},M.Present{11,M.Queued{12,True{}},Some{10},False{}},0,St.activate(~U32,St.empty(~U32),1,0n),St.empty(~U32)}
def operational_finished(~S:Data,owned:Array<U32>,flow:M.Slot<S,State.FlowToken,U32>,level:M.Slot<S,State.LevelToken,U32>,ran:U32,levelStream:St.Stream<U32>,text:String,result:St.Reader<S,State.FlowToken> & St.Stream<U32>) -> State.Resources<S> & String:
  (_,stream)=result
  (State.Resources{owned,flow,level,ran,stream,levelStream},text)
def operational_opened(~S:Data,owned:Array<U32>,flow:M.Slot<S,State.FlowToken,U32>,level:M.Slot<S,State.LevelToken,U32>,ran:U32,levelStream:St.Stream<U32>,result:St.OpenResult<S,State.FlowToken,U32>) -> State.Resources<S> & String:
  match result:
    case St.Opened{reader,stream,Ev.Reading{values,lagged}}:operational_finished(~S,owned,flow,level,ran,levelStream,List.show(&2,M.Transition<U32>,Dump.transition,values) ++ ":lagged=" ++ Bool.show(lagged),St.finish(~S,~State.FlowToken,~U32,reader,stream,1n,True{}))
    case St.ReaderRefused{_,stream}:(State.Resources{owned,flow,level,ran,stream,levelStream},"ReaderRefused")
def operational_resource(~S:Data,+namespace:U32,resources:State.Resources<S>) -> State.Resources<S> & String:
  match resources:
    case State.Resources{owned,flow,level,ran,stream,levelStream}:operational_opened(~S,owned,flow,level,ran,levelStream,St.open(~S,~State.FlowToken,~U32,St.Reader{namespace,1},stream,namespace,1n))
def operational(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,resources,events,pending,registrations,nextSystem,clock}:W.observe_resource_finish(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~String,operational_resource(~S,ns,resources),ns,next,high,live,capacity,depth,store,events,pending,registrations,nextSystem,clock)
def final_world(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (_,text)=result
  List.append(&2,String,previous,["after-operational:" ++ text])
def operational_returned(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  final_world(~S,List.append(&2,String,previous,["operational:" ++ text]),Dump.world(~S,world))
def returned16(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  operational_returned(~S,List.append(&2,String,previous,["true-after-second:" ++ text]),operational(~S,world))
def step16(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned16(~S,previous,Dump.world(~S,world))
def returned15(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step16(~S,world,List.append(&2,String,previous,["true-second:" ++ text]))
def step15(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned15(~S,previous,inspect(~S,world))
def returned14(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step15(~S,world,List.append(&2,String,previous,["true-after-first:" ++ text]))
def step14(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned14(~S,previous,Dump.world(~S,world))
def returned13(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step14(~S,world,List.append(&2,String,previous,["true-first:" ++ text]))
def step13(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned13(~S,previous,inspect(~S,world))
def returned12(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step13(~S,world,List.append(&2,String,previous,["true-before-inspect:" ++ text]))
def step12(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned12(~S,previous,Dump.world(~S,world))
def returned11(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step12(~S,world,List.append(&2,String,previous,["true-marker:" ++ text]))
def step11(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned11(~S,previous,marker(~S,world))
def returned10(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step11(~S,world,List.append(&2,String,previous,["true-queued-world:" ++ text]))
def step10(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned10(~S,previous,Dump.world(~S,world))
def returned9(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step10(~S,world,List.append(&2,String,previous,["true-queued:" ++ text]))
def step9(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned9(~S,previous,queue(~S,world,True{}))
def returned8(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step9(~S,world,List.append(&2,String,previous,["false-after-second:" ++ text]))
def step8(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned8(~S,previous,Dump.world(~S,world))
def returned7(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step8(~S,world,List.append(&2,String,previous,["false-second:" ++ text]))
def step7(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned7(~S,previous,inspect(~S,world))
def returned6(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step7(~S,world,List.append(&2,String,previous,["false-after-first:" ++ text]))
def step6(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned6(~S,previous,Dump.world(~S,world))
def returned5(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step6(~S,world,List.append(&2,String,previous,["false-first:" ++ text]))
def step5(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned5(~S,previous,inspect(~S,world))
def returned4(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step5(~S,world,List.append(&2,String,previous,["false-before-inspect:" ++ text]))
def step4(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned4(~S,previous,Dump.world(~S,world))
def returned3(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step4(~S,world,List.append(&2,String,previous,["false-marker:" ++ text]))
def step3(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned3(~S,previous,marker(~S,world))
def returned2(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step3(~S,world,List.append(&2,String,previous,["false-queued-world:" ++ text]))
def step2(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned2(~S,previous,Dump.world(~S,world))
def returned1(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step2(~S,world,List.append(&2,String,previous,["false-queued:" ++ text]))
def step1(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned1(~S,previous,queue(~S,world,False{}))
def returned0(~S:Data,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step1(~S,world,List.append(&2,String,previous,["before:" ++ text]))
def step0(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,previous:List<&2,String>) -> List<&2,String>:
  returned0(~S,previous,Dump.world(~S,world))
def created(~S:Data,result:W.Creation<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> List<&2,String>:
  match result:
    case W.Created{_,world}:step0(~S,W.enqueue(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,pending(~S)),[])
    case W.CreateRejected{_,_}:["CreateRejected"]
def run(~S:Data) -> List<&2,String>:
  created(~S,W.create(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~store(~S),W.factory(),resources(~S)))
