import Base
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/types.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as Stream
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Events
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/world.bend as AppWorld
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as Life
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

# Application-owned array projection preserves the actual affine owner.
def projected(pair:Array<U32> & U32,+amount:U32) -> Array<U32> & U32:
  (owner,+old)=pair
  (Array.set(U32,owner,0,U32.add(old,amount)),old)
def increment(owner:Array<U32>,amount:U32) -> Array<U32> & U32:
  projected(Array.get(U32,owner,0),amount)
def local_incremented(pair:Local.Cell<Array<U32>> & U32) -> Local.Cell<Array<U32>>:
  (cell,_)=pair
  cell
def local_increment(cell:Local.Cell<Array<U32>>) -> Local.Cell<Array<U32>>:
  match cell:
    case Local.Cell{owner}: local_incremented(Local.projected(~Array<U32>,~U32,increment(owner,1)))
def local_join(head:T.LocalOwner,tail:List<&1,T.LocalOwner>) -> List<&1,T.LocalOwner>:
  head <> tail
def local_selected(yes:Bool,+namespace:U32,+id:U32,cell:Local.Cell<Array<U32>>,rest:List<&1,T.LocalOwner>) -> List<&1,T.LocalOwner>:
  match yes:
    case True{}: T.LocalOwner{namespace,id,local_increment(cell)} <> rest
    case False{}: T.LocalOwner{namespace,id,cell} <> rest
def locals_increment(items:List<&1,T.LocalOwner>,+namespace:U32,+id:U32) -> List<&1,T.LocalOwner>:
  match items:
    case []: []
    case T.LocalOwner{+owner,+key,cell} <> rest:
      local_selected(Bool.and(U32.is_eq(owner,namespace),U32.is_eq(key,id)),owner,key,cell,locals_increment(rest,namespace,id))
# This operation must be invoked exclusively inside a validated registered runner,
# before Tx.begin. Gameplay inverses never replace these retained Local owners.
def touch_local(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,+id:U32) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals_increment(locals,ns,id),tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}
def outcome(~S:Data,returned:Tx.Returned<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match returned:
    case Tx.Returned{world,Tx.Success{}}: Sys.Succeeded{world,Unit{}}
    case Tx.Returned{world,Tx.Failure{error}}: Sys.Failed{world,error}

# Replacement keeps the affine owner; only its U32 element is updated.
def restore_resource(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,value:U32) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,T.Resources{Array.set(U32,owned,0,value),slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}
def resource_changed(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,pair:Array<U32> & U32) -> Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>:
  match world pair:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{_,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}, (owned,old):
      Tx.add_undo(~W.World<S,T.Store<S>,T.Resources<S>,Unit>,~Unit,Tx.begin(~W.World<S,T.Store<S>,T.Resources<S>,Unit>,~Unit,W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}),w => restore_resource(~S,w,old))
def change_resource(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,amount:U32) -> Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}:
      resource_changed(~S,W.World{ns,next,high,live,capacity,depth,store,T.Resources{ALeaf{0},slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock},increment(owned,amount))
def structural(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,U32.add(applied,1)},events,pending,registrations,nextSystem,clock}
def enqueue_all(~S:Data,commands:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)>,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  match commands:
    case []: world
    case command <> rest: enqueue_all(~S,rest,W.enqueue(~S,~T.Store<S>,~T.Resources<S>,~Unit,world,command))
def enqueue(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,commands:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  enqueue_all(~S,commands,world)
def discard_unit_events(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,_:List<&2,Unit>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  world

def set_value(owner:Array<U32>,value:U32) -> Array<U32> & Unit:
  (Array.set(U32,owner,0,value),Unit{})
def restore_component_result(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,pair:Col.Column<S,Array<U32>> & Maybe<&2,Unit>,stamp:Life.Stamp,+oldClock:U32) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  match world pair:
    case W.World{ns,next,high,live,capacity,depth,_,resources,events,pending,registrations,nextSystem,_}, (column,_):
      W.World{ns,next,high,live,capacity,depth,T.Store{Col.restore_stamp(~S,~Array<U32>,column,1,stamp)},resources,events,pending,registrations,nextSystem,oldClock}
def restored_swap(~S:Data,result:Col.SwapOutcome<S,Array<U32>>) -> Col.Column<S,Array<U32>>:
  match result:
    case Col.Accepted{column,_}: column
    case Col.Rejected{column,_}: column
def restore_taken(~S:Data,result:Col.SwapOutcome<S,Array<U32>>,value:U32) -> Col.Column<S,Array<U32>> & Maybe<&2,Unit>:
  match result:
    case Col.Accepted{column,Some{owner}}: (restored_swap(~S,Col.swap(~S,~Array<U32>,column,1,Some{Array.set(U32,owner,0,value)})),Some{Unit{}})
    case Col.Accepted{column,None{}}: (column,None{})
    case Col.Rejected{column,_}: (column,None{})
def restore_component(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,value:U32,stamp:Life.Stamp,oldClock:U32) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,T.Store{column},resources,events,pending,registrations,nextSystem,clock}:
      restore_component_result(~S,W.World{ns,next,high,live,capacity,depth,T.Store{Col.Column{ALeaf{None{}},[]}},resources,events,pending,registrations,nextSystem,clock},restore_taken(~S,Col.swap(~S,~Array<U32>,column,1,None{}),value),stamp,oldClock)
def component_written(~S:Data,tx:Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>,pair:Col.Column<S,Array<U32>> & Maybe<&2,U32>,stamp:Life.Stamp,oldClock:U32) -> Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>:
  match tx pair:
    case Tx.Tx{W.World{ns,next,high,live,capacity,depth,_,resources,events,pending,registrations,nextSystem,+clock},undo,commands,emitted}, (column,Some{old}):
      Tx.add_undo(~W.World<S,T.Store<S>,T.Resources<S>,Unit>,~Unit,Tx.Tx{W.World{ns,next,high,live,capacity,depth,T.Store{Col.mark(~S,~Array<U32>,column,1,True{},True{},U32.add(clock,1))},resources,events,pending,registrations,nextSystem,U32.add(clock,1)},undo,commands,emitted},world => restore_component(~S,world,old,stamp,oldClock))
    case Tx.Tx{W.World{ns,next,high,live,capacity,depth,_,resources,events,pending,registrations,nextSystem,clock},undo,commands,emitted}, (column,None{}):
      Tx.Tx{W.World{ns,next,high,live,capacity,depth,T.Store{column},resources,events,pending,registrations,nextSystem,clock},undo,commands,emitted}
def changed_owner(~S:Data,column:Col.Column<S,Array<U32>>,pair:Array<U32> & U32) -> Col.Column<S,Array<U32>> & Maybe<&2,U32>:
  (owner,old)=pair
  (restored_swap(~S,Col.swap(~S,~Array<U32>,column,1,Some{owner})),Some{old})
def changed_taken(~S:Data,result:Col.SwapOutcome<S,Array<U32>>,amount:U32) -> Col.Column<S,Array<U32>> & Maybe<&2,U32>:
  match result:
    case Col.Accepted{column,Some{owner}}: changed_owner(~S,column,increment(owner,amount))
    case Col.Accepted{column,None{}}: (column,None{})
    case Col.Rejected{column,_}: (column,None{})
def component_stamp(~S:Data,tx:Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>,pair:Col.Column<S,Array<U32>> & Life.Stamp,amount:U32,clock:U32) -> Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>:
  (column,stamp)=pair
  component_written(~S,tx,changed_taken(~S,Col.swap(~S,~Array<U32>,column,1,None{}),amount),stamp,clock)
def change_component(~S:Data,tx:Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>,amount:U32) -> Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>:
  match tx:
    case Tx.Tx{W.World{ns,next,high,live,capacity,depth,T.Store{column},resources,events,pending,registrations,nextSystem,+clock},undo,commands,emitted}:
      component_stamp(~S,Tx.Tx{W.World{ns,next,high,live,capacity,depth,T.Store{Col.Column{ALeaf{None{}},[]}},resources,events,pending,registrations,nextSystem,clock},undo,commands,emitted},Col.lifecycle(~S,~Array<U32>,column,1),amount,clock)
def prefix(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,name:String) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prior,delivered,applied},events,pending,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,List.append(&2,String,prior,[name]),delivered,applied},events,pending,registrations,nextSystem,clock}
def local_count_value(pair:Array<U32> & U32) -> Array<U32> & U32:
  pair
def local_count(cell:Local.Cell<Array<U32>>) -> Local.Cell<Array<U32>> & U32:
  Local.read_cell(~Array<U32>,~U32,~(owner => Array.get(U32,owner,0)),cell)
def attempt_join(head:T.LocalOwner,tail:List<&1,T.LocalOwner> & U32) -> List<&1,T.LocalOwner> & U32:
  (rest,value)=tail
  (head <> rest,value)
def attempt_observed(namespace:U32,id:U32,observed:Local.Cell<Array<U32>> & U32,tail:List<&1,T.LocalOwner> & U32) -> List<&1,T.LocalOwner> & U32:
  (cell,value)=observed
  (rest,_)=tail
  (T.LocalOwner{namespace,id,cell} <> rest,value)
def attempt_selected(yes:Bool,namespace:U32,id:U32,cell:Local.Cell<Array<U32>>,tail:List<&1,T.LocalOwner> & U32) -> List<&1,T.LocalOwner> & U32:
  match yes:
    case False{}: attempt_join(T.LocalOwner{namespace,id,cell},tail)
    case True{}: attempt_observed(namespace,id,local_count(cell),tail)
def attempts(items:List<&1,T.LocalOwner>,+namespace:U32,+id:U32) -> List<&1,T.LocalOwner> & U32:
  match items:
    case []: ([],0)
    case T.LocalOwner{+owner,+key,cell} <> rest: attempt_selected(Bool.and(U32.is_eq(owner,namespace),U32.is_eq(key,id)),owner,key,cell,attempts(rest,namespace,id))

def attempt_world_join(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,pair:List<&1,T.LocalOwner> & U32) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & U32:
  match world pair:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,_,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}, (locals,count):
      (W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock},count)
def attempt_world(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,+id:U32) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & U32:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}:
      attempt_world_join(~S,W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,[],tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock},attempts(locals,ns,id))
def committed_prefix(~S:Data,name:String,result:Tx.Returned<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match result:
    case Tx.Returned{world,Tx.Failure{error}}: Sys.Failed{world,error}
    case Tx.Returned{world,Tx.Success{}}: Sys.Succeeded{prefix(~S,world,name),Unit{}}
def finished(~S:Data,tx:Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>,name:String,fail:Bool) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match fail:
    case True{}: committed_prefix(~S,name,Tx.finish(~W.World<S,T.Store<S>,T.Resources<S>,Unit>,~Unit,~String,~(w => c => enqueue(~S,w,c)),~(w => e => discard_unit_events(~S,w,e)),tx,Tx.Failure{"once"}))
    case False{}: committed_prefix(~S,name,Tx.finish(~W.World<S,T.Store<S>,T.Resources<S>,Unit>,~Unit,~String,~(w => c => enqueue(~S,w,c)),~(w => e => discard_unit_events(~S,w,e)),tx,Tx.Success{}))
def resource_tx_join(~S:Data,changed:Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>,oldUndo:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)>,oldCommands:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)>,oldEvents:List<&2,Unit>) -> Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>:
  match changed:
    case Tx.Tx{world,undo,_,_}: Tx.Tx{world,List.append(&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>),undo,oldUndo),oldCommands,oldEvents}
def resource_tx_write(~S:Data,frame:Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>,amount:U32) -> Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>:
  match frame:
    case Tx.Tx{world,undo,commands,events}: resource_tx_join(~S,change_resource(~S,world,amount),undo,commands,events)
def resource_read_world(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,pair:Array<U32> & U32) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & U32:
  match world pair:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{_,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}, (owned,value):
      (W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock},value)
def resource_read(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & U32:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}:
      resource_read_world(~S,W.World{ns,next,high,live,capacity,depth,store,T.Resources{ALeaf{0},slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock},Array.get(U32,owned,0))
def resource_tx_read_join(~S:Data,pair:W.World<S,T.Store<S>,T.Resources<S>,Unit> & U32,undo:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)>,commands:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)>,events:List<&2,Unit>) -> Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit> & U32:
  (world,value)=pair
  (Tx.Tx{world,undo,commands,events},value)
def resource_tx_read(~S:Data,frame:Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>) -> Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit> & U32:
  match frame:
    case Tx.Tx{world,undo,commands,events}: resource_tx_read_join(~S,resource_read(~S,world),undo,commands,events)
type Work<-F:Type> is Type:
  Work{resource:Cap.ValueWrite<F,U32,U32>,component:Cap.Action<F>,deferred:Cap.Action<F>}
def act(-F:Type,owner:F,cap:Cap.Action<F>) -> F:
  match cap:
    case Cap.Action{apply}: apply(owner)
def gameplay_write(-F:Type,cap:Cap.ValueWrite<F,U32,U32>,owner:F,amount:U32) -> F:
  match cap:
    case Cap.ValueWrite{_,write}: write(owner,amount)
def gameplay_body(-F:Type,caps:Work<F>,owner:F,amount:U32) -> F:
  match caps:
    case Work{resource,component,deferred}: act(F,act(F,gameplay_write(F,resource,owner,amount),component),deferred)
def gameplay(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,+amount:U32,name:String,fail:Bool) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  finished(~S,gameplay_body(Tx.Tx<W.World<S,T.Store<S>,T.Resources<S>,Unit>,Unit>,Work{Cap.ValueWrite{resource_tx_read(~S),resource_tx_write(~S)},Cap.Action{frame => change_component(~S,frame,amount)},Cap.Action{frame => Tx.stage(~W.World<S,T.Store<S>,T.Resources<S>,Unit>,~Unit,frame,w => structural(~S,w))}},Tx.begin(~W.World<S,T.Store<S>,T.Resources<S>,Unit>,~Unit,world),amount),name,fail)
def queue_join(~S:Data,pair:W.World<S,T.Store<S>,T.Resources<S>,Unit> & M.Slot<S,T.MachineKey,T.State>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  (world,slot)=pair
  AppWorld.put(~S,world,M.queue(~S,~T.MachineKey,~T.State,slot,T.Pause{},False{}))
def entered(~S:Data,to:T.State,result:Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match to result:
    case T.Play{}, Sys.Succeeded{world,output}: Sys.Succeeded{queue_join(~S,AppWorld.take(~S,world)),output}
    case _, result: result
# Fixture-selected failure position is retained in owned physical Array cell1.
def phase_body(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,count:U32,selected:U32,phase:H.Phase,to:T.State) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match phase:
    case H.Exit{}:gameplay(~S,world,1,"exit",Bool.and(U32.is_eq(selected,1),U32.is_eq(count,1)))
    case H.Transition{}:gameplay(~S,world,10,"transition",Bool.and(U32.is_eq(selected,2),U32.is_eq(count,1)))
    case H.Enter{}:entered(~S,to,gameplay(~S,world,100,"enter",Bool.and(U32.is_eq(selected,3),U32.is_eq(count,1))))
def selected_failure(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,count:U32,phase:H.Phase,to:T.State,pair:Array<U32> & U32) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match world pair:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{_,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock},(owned,selected):phase_body(~S,W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock},count,selected,phase,to)
def invoked(~S:Data,observed:W.World<S,T.Store<S>,T.Resources<S>,Unit> & U32,invocation:H.Invocation<T.State>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match observed invocation:
    case (W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock},count),H.Invocation{phase,_,_,to}:selected_failure(~S,W.World{ns,next,high,live,capacity,depth,store,T.Resources{ALeaf{0},slot,stream,reader,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock},count,phase,to,Array.get(U32,owned,1))
def runner(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,invocation:H.Invocation<T.State>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match invocation:
    case H.Invocation{phase,+ordinal,from,to}: invoked(~S,attempt_world(~S,touch_local(~S,world,ordinal),ordinal),H.Invocation{phase,ordinal,from,to})

def read_finished(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,pair:Stream.Reader<S,T.MachineKey> & Stream.Stream<T.State>,values:List<&2,M.Transition<T.State>>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match world pair:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,_,_,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}, (reader,stream):
      Sys.Succeeded{W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,Some{reader},locals,tick,prefix,List.append(&2,M.Transition<T.State>,delivered,values),applied},events,pending,registrations,nextSystem,clock},Unit{}}
def read_refused(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,reader:Stream.Reader<S,T.MachineKey>,stream:Stream.Stream<T.State>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,_,_,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}:
      Sys.Failed{W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,Some{reader},locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock},"ForeignReader"}
def read_opened(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,tick:Nat,result:Stream.OpenResult<S,T.MachineKey,T.State>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match result:
    case Stream.ReaderRefused{reader,stream}: read_refused(~S,world,reader,stream)
    case Stream.Opened{reader,stream,Events.Reading{values,_}}:
      read_finished(~S,world,Stream.finish(~S,~T.MachineKey,~T.State,reader,stream,tick,True{}),values)
def read_missing(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,stream:Stream.Stream<T.State>) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,_,_,locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}:
      Sys.Failed{W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,None{},locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock},"MissingReader"}
def reader_selected(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,reader:Maybe<&1,Stream.Reader<S,T.MachineKey>>,stream:Stream.Stream<T.State>,ns:U32,+tick:Nat) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match reader:
    case None{}: read_missing(~S,world,stream)
    case Some{reader}: read_opened(~S,world,tick,Stream.open(~S,~T.MachineKey,~T.State,reader,stream,ns,tick))
def reader_runner(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,_:Unit) -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,+tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock}:
      reader_selected(~S,W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,Stream.empty(~T.State),None{},locals,tick,prefix,delivered,applied},events,pending,registrations,nextSystem,clock},reader,stream,ns,tick)
