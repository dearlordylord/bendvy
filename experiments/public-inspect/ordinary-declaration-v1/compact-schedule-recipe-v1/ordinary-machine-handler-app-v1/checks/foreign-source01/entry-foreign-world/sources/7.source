import Base
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/types.bend as T
import application.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as Stream
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/machine-conditions.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import systems.bend as Systems

def state(value:T.State) -> String:
  match value:
    case T.Boot{}: "\"Boot\""
    case T.Play{}: "\"Play\""
    case T.Pause{}: "\"Pause\""
def bool(value:Bool) -> String:
  match value:
    case False{}: "false"
    case True{}: "true"
def previous(value:Maybe<&2,T.State>) -> String:
  match value:
    case None{}: "null"
    case Some{value}: state(value)
def pending(value:M.Pending<T.State>) -> String:
  match value:
    case M.NoPending{}: "null"
    case M.Queued{value,_}: state(value)
def slot(~S:Data,value:M.Slot<S,T.MachineKey,T.State>) -> String:
  match value:
    case M.Missing{}: "\"current\":null,\"pending\":null,\"previous\":null,\"changed\":false"
    case M.Present{current,next,prior,changed}: "\"current\":" ++ state(current) ++ ",\"pending\":" ++ pending(next) ++ ",\"previous\":" ++ previous(prior) ++ ",\"changed\":" ++ bool(changed)
def quote(text:String) -> String:
  "\"" ++ text ++ "\""
def transition(event:M.Transition<T.State>) -> String:
  match event:
    case M.Transition{from,to}: "[" ++ state(from) ++ "," ++ state(to) ++ "]"
def array_second(first:U32,pair:Array<U32> & U32) -> Array<U32> & String:
  (owner,last)=pair
  (owner,"[" ++ U32.show(first) ++ "," ++ U32.show(last) ++ "]")
def array_first(pair:Array<U32> & U32) -> Array<U32> & String:
  (owner,first)=pair
  array_second(first,Array.get(U32,owner,1))
def array(owner:Array<U32>) -> Array<U32> & String:
  array_first(Array.get(U32,owner,0))
def locals_join(head:T.LocalOwner,value:U32,tail:List<&1,T.LocalOwner> & List<&2,U32>) -> List<&1,T.LocalOwner> & List<&2,U32>:
  (rest,values)=tail
  (head <> rest,value <> values)
def local_observed(ns:U32,id:U32,pair:Local.Cell<Array<U32>> & U32,tail:List<&1,T.LocalOwner> & List<&2,U32>) -> List<&1,T.LocalOwner> & List<&2,U32>:
  (cell,value)=pair
  locals_join(T.LocalOwner{ns,id,cell},value,tail)
def locals(items:List<&1,T.LocalOwner>) -> List<&1,T.LocalOwner> & List<&2,U32>:
  match items:
    case []: ([],[])
    case T.LocalOwner{ns,id,cell} <> rest: local_observed(ns,id,Systems.local_count(cell),locals(rest))
def batch_values(items:List<&2,Ev.Batch<M.Transition<T.State>>>) -> List<&2,M.Transition<T.State>>:
  match items:
    case []: []
    case Ev.Batch{_,values} <> rest: List.append(&2,M.Transition<T.State>,values,batch_values(rest))
def batch_ticks(items:List<&2,Ev.Batch<M.Transition<T.State>>>) -> List<&2,Nat>:
  match items:
    case []: []
    case Ev.Batch{tick,_} <> rest: tick <> batch_ticks(rest)
def position(items:List<&2,Ev.Position>) -> String:
  match items:
    case []: "null"
    case Ev.Position{_,cursor,at} <> _: "{\"cursor\":" ++ Nat.show(cursor) ++ ",\"registeredAt\":" ++ Nat.show(at) ++ "}"
def reader(~S:Data,owner:Maybe<&1,Stream.Reader<S,T.MachineKey>>,positions:List<&2,Ev.Position>) -> Maybe<&1,Stream.Reader<S,T.MachineKey>> & String:
  match owner:
    case None{}: (None{},"null")
    case Some{Stream.Reader{+ns,+id}}: (Some{Stream.Reader{ns,id}},"{\"namespace\":" ++ U32.show(ns) ++ ",\"id\":" ++ U32.show(id) ++ ",\"position\":" ++ position(positions) ++ "}")
def entries_join(~S:Data,head:H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>,id:U32,cursor:U32,tail:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>> & List<&2,U32> & List<&2,U32>) -> List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>> & List<&2,U32> & List<&2,U32>:
  (rest,ids,cursors)=tail
  (head <> rest,id <> ids,cursor <> cursors)
def entries(~S:Data,items:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>>) -> List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>> & List<&2,U32> & List<&2,U32>:
  match items:
    case []: ([],[],[])
    case H.Entry{ordinal,Sys.Registry{+ns,+id,+name,+access,+cursor}} <> rest:
      entries_join(~S,H.Entry{ordinal,Sys.Registry{ns,id,name,access,cursor}},id,cursor,entries(~S,rest))

def commands_join(~S:Data,head:W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>,tail:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)> & Nat) -> List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)> & Nat:
  (rest,count)=tail
  (head <> rest,1n+count)
def commands(~S:Data,items:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)>) -> List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)> & Nat:
  match items:
    case []: ([],0n)
    case head <> rest: commands_join(~S,head,commands(~S,rest))
def resource_arrays(~S:Data,rest:T.Resources<S>,owner:Array<U32> & String,localValues:List<&2,U32>,readerText:String) -> T.Resources<S> & String:
  match rest owner:
    case T.Resources{_,+slotValue,Stream.Stream{+batches,positions,dropped,start},readerOwner,locals,+tick,+prefix,+delivered,+applied}, (owned,text):
      (T.Resources{owned,slotValue,Stream.Stream{batches,positions,dropped,start},readerOwner,locals,tick,prefix,delivered,applied},"\"resource\":" ++ text ++ ",\"locals\":" ++ List.show(&2,U32,U32.show,localValues) ++ "," ++ slot(~S,slotValue) ++ ",\"streamReader\":" ++ readerText ++ ",\"publications\":" ++ List.show(&2,M.Transition<T.State>,transition,batch_values(batches)) ++ ",\"publicationTicks\":" ++ List.show(&2,Nat,Nat.show,batch_ticks(batches)) ++ ",\"deliveries\":" ++ List.show(&2,M.Transition<T.State>,transition,delivered) ++ ",\"tick\":" ++ Nat.show(tick) ++ ",\"structuralApplied\":" ++ U32.show(applied) ++ ",\"prefix\":" ++ List.show(&2,String,quote,prefix))
def resource_reader(~S:Data,rest:T.Resources<S>,pair:Maybe<&1,Stream.Reader<S,T.MachineKey>> & String,owned:Array<U32>,localValues:List<&2,U32>) -> T.Resources<S> & String:
  match rest pair:
    case T.Resources{_,slotValue,stream,_,locals,tick,prefix,delivered,applied}, (readerOwner,text):
      resource_arrays(~S,T.Resources{ALeaf{0},slotValue,stream,readerOwner,locals,tick,prefix,delivered,applied},array(owned),localValues,text)
def resource_locals(~S:Data,owned:Array<U32>,slotValue:M.Slot<S,T.MachineKey,T.State>,stream:Stream.Stream<T.State>,readerOwner:Maybe<&1,Stream.Reader<S,T.MachineKey>>,tick:Nat,prefix:List<&2,String>,delivered:List<&2,M.Transition<T.State>>,applied:U32,pair:List<&1,T.LocalOwner> & List<&2,U32>) -> T.Resources<S> & String:
  match stream pair:
    case Stream.Stream{+batches,+positions,+dropped,+start}, (locals,values):
      resource_reader(~S,T.Resources{ALeaf{0},slotValue,Stream.Stream{batches,positions,dropped,start},None{},locals,tick,prefix,delivered,applied},reader(~S,readerOwner,positions),owned,values)
def resources(~S:Data,owner:T.Resources<S>) -> T.Resources<S> & String:
  match owner:
    case T.Resources{owned,slotValue,stream,readerOwner,localOwners,tick,prefix,delivered,applied}:
      resource_locals(~S,owned,slotValue,stream,readerOwner,tick,prefix,delivered,applied,locals(localOwners))
def world_join(~S:Data,+ns:U32,next:U32,high:U32,live:Array<Bool>,capacity:U32,depth:Nat,column:Col.Column<S,Array<U32>> & Maybe<&2,String>,resource:T.Resources<S> & String,events:List<&2,Unit>,pending:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)> & Nat,registrations:List<&2,W.RegistrationMeta>,nextSystem:U32,+clock:U32) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & String:
  match column resource pending:
    case (column,Some{cells}), (owner,text), (pending,count):
      (W.World{ns,next,high,live,capacity,depth,T.Store{column},owner,events,pending,registrations,nextSystem,clock},"\"namespace\":" ++ U32.show(ns) ++ ",\"entity\":1,\"component\":" ++ cells ++ "," ++ text ++ ",\"clock\":" ++ U32.show(clock) ++ ",\"pendingStructural\":" ++ Nat.show(count))
    case (column,None{}), (owner,text), (pending,count):
      (W.World{ns,next,high,live,capacity,depth,T.Store{column},owner,events,pending,registrations,nextSystem,clock},"\"namespace\":" ++ U32.show(ns) ++ ",\"entity\":1,\"component\":null," ++ text ++ ",\"clock\":" ++ U32.show(clock) ++ ",\"pendingStructural\":" ++ Nat.show(count))
def world(~S:Data,owner:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & String:
  match owner:
    case W.World{ns,next,high,live,capacity,depth,T.Store{column},resource,events,pending,registrations,nextSystem,clock}:
      world_join(~S,ns,next,high,live,capacity,depth,Col.view(~S,~Array<U32>,~String,~array,column,1),resources(~S,resource),events,commands(~S,pending),registrations,nextSystem,clock)
def observed(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit> & String,exit:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>> & List<&2,U32> & List<&2,U32>,transition:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>> & List<&2,U32> & List<&2,U32>,enter:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>> & List<&2,U32> & List<&2,U32>,readerRegistry:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>) -> App.Application<S> & String:
  match world exit transition enter readerRegistry:
    case (world,text), (exit,a,ac), (transition,b,bc), (enter,c,cc), Some{Sys.Registry{+ns,+id,+name,+access,+cursor}}:
      (App.Application{world,H.Owners{exit,transition,enter},Some{Sys.Registry{ns,id,name,access,cursor}}},"{" ++ text ++ ",\"registryIds\":" ++ List.show(&2,U32,U32.show,List.append(&2,U32,a,List.append(&2,U32,b,List.append(&2,U32,c,[id])))) ++ ",\"registryCursors\":" ++ List.show(&2,U32,U32.show,List.append(&2,U32,ac,List.append(&2,U32,bc,List.append(&2,U32,cc,[cursor])))) ++ "}")
    case (world,_), (exit,_,_), (transition,_,_), (enter,_,_), None{}: (App.Application{world,H.Owners{exit,transition,enter},None{}},"{\"error\":\"MissingRegistry\"}")
def observe(~S:Data,application:App.Application<S>) -> App.Application<S> & String:
  match application:
    case App.Application{owner,H.Owners{exit,transition,enter},readerRegistry}:
      observed(~S,world(~S,owner),entries(~S,exit),entries(~S,transition),entries(~S,enter),readerRegistry)
