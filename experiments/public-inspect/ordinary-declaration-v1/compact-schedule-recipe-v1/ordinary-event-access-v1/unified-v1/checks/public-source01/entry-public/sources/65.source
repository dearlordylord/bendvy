import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
def bool_right(left:Array<Bool> & String,right:Array<Bool> & String) -> Array<Bool> & String:
  match left right:
    case (left,l), (right,r):(ANode{left,right},"node(" ++ l ++ "," ++ r ++ ")")
def array_bool(value:Array<Bool>) -> Array<Bool> & String:
  match value:
    case ALeaf{+value}:(ALeaf{value},"leaf:" ++ Bool.show(value))
    case ANode{left,right}:bool_right(array_bool(left),array_bool(right))
def pending_counted(~S:Data,first:W.World<S,Unit,Unit,U32> -> W.World<S,Unit,Unit,U32>,rest:List<(W.World<S,Unit,Unit,U32> -> W.World<S,Unit,Unit,U32>)> & U32) -> List<(W.World<S,Unit,Unit,U32> -> W.World<S,Unit,Unit,U32>)> & U32:
  match rest:
    case (rest,count):(first <> rest,U32.add(count,1))
def pending_count(~S:Data,commands:List<(W.World<S,Unit,Unit,U32> -> W.World<S,Unit,Unit,U32>)>) -> List<(W.World<S,Unit,Unit,U32> -> W.World<S,Unit,Unit,U32>)> & U32:
  match commands:
    case []:([],0)
    case first <> rest:pending_counted(~S,first,pending_count(~S,rest))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access)
def physical_done(~S:Data,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,store:Unit,resource:Unit,+events:List<&2,U32>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,live:Array<Bool> & String,pending:List<(W.World<S,Unit,Unit,U32> -> W.World<S,Unit,Unit,U32>)> & U32) -> W.World<S,Unit,Unit,U32> & String:
  match live pending:
    case (live,liveText), (pending,count):(W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},"world{" ++ U32.show(namespace) ++ "|" ++ U32.show(nextId) ++ "|" ++ U32.show(highWater) ++ "|" ++ liveText ++ "|" ++ U32.show(capacity) ++ "|" ++ Nat.show(depth) ++ "|Unit|Unit|" ++ List.show(&2,U32,U32.show,events) ++ "|pending=" ++ U32.show(count) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ "|nextSystem=" ++ U32.show(nextSystemId) ++ "|clock=" ++ U32.show(clock) ++ "}")
def world(~S:Data,world:W.World<S,Unit,Unit,U32>) -> W.World<S,Unit,Unit,U32> & String:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,+events,pending,+registrations,nextSystemId,clock}:physical_done(~S,namespace,nextId,highWater,capacity,depth,store,resource,events,registrations,nextSystemId,clock,array_bool(live),pending_count(~S,pending))
def batch(value:Ev.Batch<U32>) -> String:
  match value:
    case Ev.Batch{tick,values}:Nat.show(tick) ++ ":" ++ List.show(&2,U32,U32.show,values)
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registered)
def runtime_done(~S:Data,~C:Type,~R:Type,+namespace:U32,+batches:List<&2,Ev.Batch<U32>>,+positions:List<&2,Ev.Position>,+nextReader:U32,+tick:Nat,+frameStart:Nat,+boundary:Nat,+capacity:Nat,+dropped:Nat,result:W.World<S,C,R,U32> & String) -> Ev.Runtime<S,C,R,U32> & String:
  match result:
    case (world,text):(Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},text ++ "|runtime{" ++ U32.show(namespace) ++ "|batches=" ++ List.show(&2,Ev.Batch<U32>,batch,batches) ++ "|positions=" ++ List.show(&2,Ev.Position,position,positions) ++ "|nextReader=" ++ U32.show(nextReader) ++ "|tick=" ++ Nat.show(tick) ++ "|frame=" ++ Nat.show(frameStart) ++ "|boundary=" ++ Nat.show(boundary) ++ "|capacity=" ++ Nat.show(capacity) ++ "|dropped=" ++ Nat.show(dropped) ++ "}")
def runtime(~S:Data,~C:Type,~R:Type,~physical:W.World<S,C,R,U32> -> W.World<S,C,R,U32> & String,value:Ev.Runtime<S,C,R,U32>) -> Ev.Runtime<S,C,R,U32> & String:
  match value:
    case Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}:runtime_done(~S,~C,~R,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,physical(world))
def reader(~S:Data,value:Ev.Reader<S>) -> Ev.Reader<S> & String:
  match value:
    case Ev.Reader{+namespace,+id,+registryId}:(Ev.Reader{namespace,id,registryId},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":registry=" ++ U32.show(registryId))
