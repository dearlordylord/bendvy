import Base
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/owner-observer.bend as Dump
import types.bend as T
import lenses.bend as Lens
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as Stream
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev

def incremented(pair:Array<U32> & U32,amount:U32) -> Array<U32> & U32:
  (owner,+old)=pair
  (Array.set(U32,owner,0,U32.add(old,amount)),old)
def increment(owner:Array<U32>,amount:U32) -> Array<U32> & U32:incremented(Array.get(U32,owner,0),amount)
def local_returned(pair:Array<U32> & U32) -> Local.Cell<Array<U32>>:
  (owner,_)=pair
  Local.Cell{owner}
def local_touch(cell:Local.Cell<Array<U32>>) -> Local.Cell<Array<U32>>:
  match cell:
    case Local.Cell{owner}:local_returned(increment(owner,1))
def local_choice(yes:Bool,namespace:U32,id:U32,cell:Local.Cell<Array<U32>>,rest:List<&1,T.LocalOwner>) -> List<&1,T.LocalOwner>:
  match yes:
    case True{}:T.LocalOwner{namespace,id,local_touch(cell)} <> rest
    case False{}:T.LocalOwner{namespace,id,cell} <> rest
def locals_touch(values:List<&1,T.LocalOwner>,+selected:U32) -> List<&1,T.LocalOwner>:
  match values:
    case []:[]
    case T.LocalOwner{namespace,+id,cell} <> rest:local_choice(U32.is_eq(id,selected),namespace,id,cell,locals_touch(rest,selected))
def inspected_local(pair:Array<U32> & U32) -> Local.Cell<Array<U32>> & Bool:
  (owner,value)=pair
  (Local.Cell{owner},U32.is_eq(value,1))
def inspect_local(cell:Local.Cell<Array<U32>>) -> Local.Cell<Array<U32>> & Bool:
  match cell:
    case Local.Cell{owner}:inspected_local(Array.get(U32,owner,0))
def chosen_local(+namespace:U32,+id:U32,selected:U32,pair:Local.Cell<Array<U32>> & Bool,tail:List<&1,T.LocalOwner> & Bool) -> List<&1,T.LocalOwner> & Bool:
  match pair tail:
    case (cell,first),(rest,prior):(T.LocalOwner{namespace,id,cell} <> rest,Bool.or(Bool.and(U32.is_eq(id,selected),first),prior))
def locals_first(values:List<&1,T.LocalOwner>,+selected:U32) -> List<&1,T.LocalOwner> & Bool:
  match values:
    case []:([],False{})
    case T.LocalOwner{namespace,id,cell} <> rest:chosen_local(namespace,id,selected,inspect_local(cell),locals_first(rest,selected))
def phase_code(value:H.Phase) -> U32:
  match value:
    case H.Exit{}:1
    case H.Transition{}:2
    case H.Enter{}:3
def touch(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,id:U32) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals_touch(locals,id),firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}
def structural(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,U32.add(applied,1)},events,pending,registrations,nextSystem,clock}
def enqueue_all(~S:Data,commands:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>)>,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match commands:
    case []:world
    case head <> rest:enqueue_all(~S,rest,W.enqueue(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,world,head))
def enqueue(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,commands:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>)>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:enqueue_all(~S,commands,world)
def publish_events(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,values:List<&2,T.Pulse>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},List.append(&2,T.Pulse,events,values),pending,registrations,nextSystem,clock}
def restore(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,old:U32,oldTrace:List<&2,String>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,T.Resources{Array.set(U32,owned,0,old),sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,oldTrace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}
def changed(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,label:String,pair:Array<U32> & U32) -> Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,T.Pulse>:
  match world pair:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{_,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,+trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock},(owned,old):Tx.add_undo(~W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,~T.Pulse,Tx.begin(~W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,~T.Pulse,W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,List.append(&2,String,trace,[label]),firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}),world => restore(~S,world,old,trace))
def change(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,+machine:U32,+code:U32) -> Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,T.Pulse>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:changed(~S,W.World{ns,next,high,live,capacity,depth,store,T.Resources{ALeaf{0},sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock},U32.show(machine) ++ ":" ++ U32.show(code),increment(owned,U32.add(U32.mul(machine,10),code)))
def finished(~S:Data,returned:Tx.Returned<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  match returned:
    case Tx.Returned{world,Tx.Success{}}:Sys.Succeeded{world,Unit{}}
    case Tx.Returned{world,Tx.Failure{error}}:Sys.Failed{world,error}
type Work<F:Type> is Type:Work{effect:Cap.Action<F>}
def gameplay(-F:Type,work:Work<F>,owner:F) -> F:
  match work:
    case Work{Cap.Action{invoke}}:invoke(owner)
def take_cells(~S:Data,store:T.Store<S>) -> Col.Column<S,Array<U32>> & Col.Column<S,Array<U32>>:
  match store:
    case T.Store{cells,sibling}:(sibling,cells)
def put_cells(~S:Data,sibling:Col.Column<S,Array<U32>>,cells:Col.Column<S,Array<U32>>) -> T.Store<S>:T.Store{cells,sibling}
def cells_view(owner:Array<U32>) -> Array<U32> & Unit:(owner,Unit{})
def cells_named(~S:Data,+value:U32,undo:List<(W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>)>,commands:List<(W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>)>,events:List<&2,T.Pulse>,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & U32) -> Component.SetResult<Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,T.Pulse>,Array<U32>>:
  (world,namespace)=pair
  Component.tx_set(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,~Col.Column<S,Array<U32>>,~Array<U32>,~Unit,~Unit,~take_cells(~S),~put_cells(~S),~cells_view,Component.Family{"Cells"},Tx.Tx{world,undo,commands,events},W.Handle{namespace,1},ANode{ALeaf{value},ALeaf{32}})
def cells_write(~S:Data,frame:Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,T.Pulse>,value:U32) -> Component.SetResult<Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,T.Pulse>,Array<U32>>:
  match frame:
    case Tx.Tx{world,undo,commands,events}:cells_named(~S,value,undo,commands,events,W.namespace(~S,~T.Store<S>,~T.Resources<S>,~T.Pulse,world))
def tentative_returned(~S:Data,+ns:U32,+next:U32,+high:U32,live:Array<Bool>,+capacity:U32,+depth:Nat,sibling:Col.Column<S,Array<U32>>,resource:T.Resources<S>,+events:List<&2,T.Pulse>,pending:List<(W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>)>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,undo:List<(W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>)>,commands:List<(W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>)>,+emitted:List<&2,T.Pulse>,pair:Col.Column<S,Array<U32>> & String) -> Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,T.Pulse> & String:
  (cells,text)=pair
  (Tx.Tx{W.World{ns,next,high,live,capacity,depth,T.Store{cells,sibling},resource,events,pending,registrations,nextSystem,clock},undo,commands,emitted},"tentativeCells=" ++ text ++ "|clock=" ++ U32.show(clock))
def tentative(~S:Data,frame:Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,T.Pulse>) -> Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,T.Pulse> & String:
  match frame:
    case Tx.Tx{W.World{ns,next,high,live,capacity,depth,T.Store{cells,sibling},resource,events,pending,registrations,nextSystem,clock},undo,commands,emitted}:tentative_returned(~S,ns,next,high,live,capacity,depth,sibling,resource,events,pending,registrations,nextSystem,clock,undo,commands,emitted,Dump.column(~S,~Array<U32>,~Dump.u32_array,cells))
def observed_outcome(outcome:Tx.Outcome<String>,text:String) -> Tx.Outcome<String>:
  match outcome:
    case Tx.Success{}:Tx.Success{}
    case Tx.Failure{error}:Tx.Failure{error ++ "|" ++ text}
def cells_finished(~S:Data,+machine:U32,+code:U32,outcome:Tx.Outcome<String>,pair:Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,T.Pulse> & String) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  (frame,text)=pair
  finished(~S,Tx.finish(~W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,~T.Pulse,~String,~enqueue(~S),~publish_events(~S),gameplay(Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,T.Pulse>,Work{Cap.Action{frame => Tx.stage(~W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,~T.Pulse,Tx.emit(~W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,~T.Pulse,frame,T.Callback{machine,code}),structural(~S))}},frame),observed_outcome(outcome,text)))
def rejected_cells(~S:Data,frame:Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,T.Pulse>,pair:Array<U32> & String) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  (incoming,text)=pair
  finished(~S,Tx.finish(~W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,~T.Pulse,~String,~enqueue(~S),~publish_events(~S),frame,Tx.Failure{"ComponentWriteRejected|incoming=" ++ text}))
def cells_selected(~S:Data,+machine:U32,+code:U32,outcome:Tx.Outcome<String>,result:Component.SetResult<Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,T.Pulse>,Array<U32>>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  match result:
    case Component.Written{frame}:cells_finished(~S,machine,code,outcome,tentative(~S,frame))
    case Component.WriteRejected{frame,incoming,_}:rejected_cells(~S,frame,Dump.u32_array(incoming))
    case Component.WriteFailure{frame,_}:finished(~S,Tx.finish(~W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,~T.Pulse,~String,~enqueue(~S),~publish_events(~S),frame,Tx.Failure{"ComponentWriteFailure"}))
def callback_outcome(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,+machine:U32,+code:U32,outcome:Tx.Outcome<String>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  cells_selected(~S,machine,code,outcome,cells_write(~S,change(~S,world,machine,code),U32.add(U32.mul(machine,10),code)))

def callback(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,machine:U32,code:U32) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:callback_outcome(~S,world,machine,code,Tx.Success{})
def first_completed(~S:Data,phase:H.Phase,result:Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  match phase result:
    case H.Enter{},Sys.Succeeded{world,out}:Sys.Succeeded{Lens.queue_first(~S,world,T.Settled{}),out}
    case _,result:result
def first_local_restored(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,pair:List<&1,T.LocalOwner> & Bool) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & Bool:
  match world pair:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,_,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}, (locals,yes):(W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock},yes)
def first_local(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,id:U32) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & Bool:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:first_local_restored(~S,W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,[],firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock},locals_first(locals,id))
def first_outcome(phase:H.Phase,first:Bool) -> Tx.Outcome<String>:
  match phase first:
    case H.Transition{} True{}:Tx.Failure{"transition-first-attempt"}
    case _ _:Tx.Success{}
def first_selected(~S:Data,+phase:H.Phase,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & Bool) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  (world,first)=pair
  first_completed(~S,phase,callback_outcome(~S,world,1,phase_code(phase),first_outcome(phase,first)))
def first_runner(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,invocation:H.Invocation<T.First>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  match invocation:
    case H.Invocation{phase,+id,_,_}:first_selected(~S,phase,first_local(~S,touch(~S,world,id),id))
def second_runner(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,invocation:H.Invocation<T.Second>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  match invocation:
    case H.Invocation{phase,id,_,_}:callback(~S,touch(~S,world,id),2,phase_code(phase))
def first_read_finished(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,pair:Stream.Reader<S,T.FirstKey> & Stream.Stream<T.First>,values:List<&2,M.Transition<T.First>>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  match world pair:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,_,secondStream,_,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock},(reader,stream):Sys.Succeeded{W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,stream,secondStream,Some{reader},secondReader,locals,firstTick,secondTick,trace,List.append(&2,M.Transition<T.First>,firstDelivered,values),secondDelivered,applied},events,pending,registrations,nextSystem,clock},Unit{}}
def first_read_opened(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,tick:Nat,result:Stream.OpenResult<S,T.FirstKey,T.First>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  match result:
    case Stream.Opened{reader,stream,Ev.Reading{values,_}}:first_read_finished(~S,world,Stream.finish(~S,~T.FirstKey,~T.First,reader,stream,tick,True{}),values)
    case Stream.ReaderRefused{reader,stream}:first_read_finished(~S,world,(reader,stream),[])
def first_read_selected(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,reader:Maybe<&1,Stream.Reader<S,T.FirstKey>>,stream:Stream.Stream<T.First>,namespace:U32,+tick:Nat) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  match reader:
    case Some{reader}:first_read_opened(~S,world,tick,Stream.open(~S,~T.FirstKey,~T.First,reader,stream,namespace,tick))
    case None{}:Sys.Failed{world,"MissingReader"}
def first_reader_runner(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,_:Unit) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,+firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:first_read_selected(~S,W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,Stream.empty(~T.First),secondStream,None{},secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock},firstReader,firstStream,ns,firstTick)
def second_read_finished(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,pair:Stream.Reader<S,T.SecondKey> & Stream.Stream<T.Second>,values:List<&2,M.Transition<T.Second>>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  match world pair:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,_,firstReader,_,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock},(reader,stream):Sys.Succeeded{W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,stream,firstReader,Some{reader},locals,firstTick,secondTick,trace,firstDelivered,List.append(&2,M.Transition<T.Second>,secondDelivered,values),applied},events,pending,registrations,nextSystem,clock},Unit{}}
def second_read_opened(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,tick:Nat,result:Stream.OpenResult<S,T.SecondKey,T.Second>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  match result:
    case Stream.Opened{reader,stream,Ev.Reading{values,_}}:second_read_finished(~S,world,Stream.finish(~S,~T.SecondKey,~T.Second,reader,stream,tick,True{}),values)
    case Stream.ReaderRefused{reader,stream}:second_read_finished(~S,world,(reader,stream),[])
def second_read_selected(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,reader:Maybe<&1,Stream.Reader<S,T.SecondKey>>,stream:Stream.Stream<T.Second>,namespace:U32,+tick:Nat) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  match reader:
    case Some{reader}:second_read_opened(~S,world,tick,Stream.open(~S,~T.SecondKey,~T.Second,reader,stream,namespace,tick))
    case None{}:Sys.Failed{world,"MissingReader"}
def second_reader_runner(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,_:Unit) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,+secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock}:second_read_selected(~S,W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,sibling,first,second,firstStream,Stream.empty(~T.Second),firstReader,None{},locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},events,pending,registrations,nextSystem,clock},secondReader,secondStream,ns,secondTick)
