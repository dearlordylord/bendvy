import Base
import ../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../src/ecs/ordinary-machine-declaration.bend as OD
import ../../../../src/ecs/machine.bend as M
import ../../../../src/ecs/machine-stream.bend as Stream
import ../../../../src/ecs/machine-stream-queue.bend as Queue
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/column.bend as Col

type Mode is Data:
  Mode{}
type Resources<S:Data> is Data:
  Resources{counter:U32,state:Init.State<S,Mode,U32>}
def empty(~S:Data) -> Resources<S>:
  Resources{10,Init.empty(~S,~Mode,~U32)}
def take(~S:Data,value:Resources<S>) -> Resources<S> & Init.State<S,Mode,U32>:
  match value:
    case Resources{counter,+state}:(Resources{counter,state},state)
def put(~S:Data,value:Resources<S>,state:Init.State<S,Mode,U32>) -> Resources<S>:
  match value:
    case Resources{counter,_}:Resources{counter,state}
def counter_read(~S:Data,value:Resources<S>) -> Resources<S> & U32:
  match value:
    case Resources{+counter,state}:(Resources{counter,state},counter)
def counter_write(~S:Data,value:Resources<S>,counter:U32) -> Resources<S>:
  match value:
    case Resources{_,state}:Resources{counter,state}
def declaration(~S:Data) -> OD.Declaration<S,Mode,U32,Resources<S>,Init.take_slot(~S,~Mode,~U32,~Resources<S>,~take(~S),~put(~S))>:
  Init.declared(~S,~Mode,~U32,~Resources<S>,~take(~S),~put(~S),"Mode",[0,1,2])
def insert(~S:Data,world:W.World<S,Col.Column<S,U32>,Resources<S>,Unit>,value:U32) -> W.World<S,Col.Column<S,U32>,Resources<S>,Unit>:
  Init.insert_state(~S,~Mode,~U32,~Resources<S>,~take(~S),~put(~S),~Col.Column<S,U32>,~Unit,~declaration(~S),world,value)

def pending(value:M.Pending<U32>) -> String:
  match value:
    case M.NoPending{}:"none"
    case M.Queued{value,skip}:"queued:" ++ U32.show(value) ++ ":" ++ Bool.show(skip)
def previous(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:U32.show(value)
def slot(~S:Data,value:M.Slot<S,Mode,U32>) -> String:
  match value:
    case M.Missing{}:"missing"
    case M.Present{current,next,last,changed}:U32.show(current) ++ ":" ++ pending(next) ++ ":" ++ previous(last) ++ ":" ++ Bool.show(changed)
def transition(value:M.Transition<U32>) -> String:
  match value:
    case M.Transition{from,to}:U32.show(from) ++ ">" ++ U32.show(to)
    case M.Initial{to}:"initial:" ++ U32.show(to)
def batch(value:Queue.Batch<M.Transition<U32>>) -> String:
  match value:
    case Queue.Batch{tick,count,values}:Nat.show(tick) ++ ":" ++ Nat.show(count) ++ ":" ++ List.show(~&2,~M.Transition<U32>,~transition,values)
def queue(value:Queue.Queue<M.Transition<U32>>) -> String:
  match value:
    case Queue.Queue{front,back,size,dropped,count}:List.show(~&2,~Queue.Batch<M.Transition<U32>>,~batch,front) ++ ":" ++ List.show(~&2,~Queue.Batch<M.Transition<U32>>,~batch,back) ++ ":" ++ Nat.show(size) ++ ":" ++ Nat.show(dropped) ++ ":" ++ Nat.show(count)
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registered)
def stream(value:Stream.Stream<U32>) -> String:
  match value:
    case Stream.Stream{items,positions,start}:queue(items) ++ ":" ++ List.show(~&2,~Ev.Position,~position,positions) ++ ":" ++ Nat.show(start)
def state_text(~S:Data,value:Init.State<S,Mode,U32>) -> String:
  match value:
    case Init.State{current,events,revision}:slot(~S,current) ++ ":" ++ stream(events) ++ ":revision=" ++ Nat.show(revision)
def show(~S:Data,value:Resources<S>) -> Resources<S> & String:
  match value:
    case Resources{+counter,+state}:(Resources{counter,state},"Resources{" ++ U32.show(counter) ++ "," ++ state_text(~S,state) ++ "}")
