import Base
import ./application.bend as App
import ./systems.bend as Systems
import ./observe.bend as Prior
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/types.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as Stream
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/owner-observer.bend as Dump

def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registeredAt}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registeredAt)
def batch(value:Ev.Batch<M.Transition<T.State>>) -> String:
  match value:
    case Ev.Batch{tick,values}:Nat.show(tick) ++ ":" ++ List.show(&2,M.Transition<T.State>,Prior.transition,values)
def reader(~S:Data,value:Maybe<&1,Stream.Reader<S,T.MachineKey>>) -> Maybe<&1,Stream.Reader<S,T.MachineKey>> & String:
  match value:
    case None{}:(None{},"None")
    case Some{Stream.Reader{+namespace,+id}}:(Some{Stream.Reader{namespace,id}},U32.show(namespace) ++ ":" ++ U32.show(id))
def local_join(head:T.LocalOwner,text:String,tail:List<&1,T.LocalOwner> & List<&2,String>) -> List<&1,T.LocalOwner> & List<&2,String>:
  (rest,texts)=tail
  (head <> rest,text <> texts)
def local_value(+namespace:U32,+id:U32,result:Array<U32> & String,tail:List<&1,T.LocalOwner> & List<&2,String>) -> List<&1,T.LocalOwner> & List<&2,String>:
  match result:
    case (owner,text):local_join(T.LocalOwner{namespace,id,Local.Cell{owner}},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ text,tail)
def locals(values:List<&1,T.LocalOwner>) -> List<&1,T.LocalOwner> & List<&2,String>:
  match values:
    case []:([],[])
    case T.LocalOwner{namespace,id,Local.Cell{owner}} <> rest:local_value(namespace,id,Dump.u32_array(owner),locals(rest))
def pending_skip(~S:Data,slot:M.Slot<S,T.MachineKey,T.State>) -> String:
  match slot:
    case M.Missing{}:"Missing"
    case M.Present{_,M.NoPending{},_,_}:"None"
    case M.Present{_,M.Queued{_,skip},_,_}:Bool.show(skip)
def resources_join(~S:Data,+slot:M.Slot<S,T.MachineKey,T.State>,+batches:List<&2,Ev.Batch<M.Transition<T.State>>>,+positions:List<&2,Ev.Position>,+dropped:Nat,+frameStart:Nat,+tick:Nat,+prefix:List<&2,String>,+delivered:List<&2,M.Transition<T.State>>,+applied:U32,owned:Array<U32> & String,reader:Maybe<&1,Stream.Reader<S,T.MachineKey>> & String,locals:List<&1,T.LocalOwner> & List<&2,String>) -> T.Resources<S> & String:
  match owned reader locals:
    case (owned,text),(reader,readerText),(locals,localTexts):(T.Resources{owned,slot,Stream.Stream{batches,positions,dropped,frameStart},reader,locals,tick,prefix,delivered,applied},"owned=" ++ text ++ "|slot={" ++ Prior.slot(~S,slot) ++ "}|pendingSkip=" ++ pending_skip(~S,slot) ++ "|stream={batches=" ++ List.show(&2,Ev.Batch<M.Transition<T.State>>,batch,batches) ++ "|positions=" ++ List.show(&2,Ev.Position,position,positions) ++ "|dropped=" ++ Nat.show(dropped) ++ "|frameStart=" ++ Nat.show(frameStart) ++ "}|reader=" ++ readerText ++ "|locals=" ++ List.show(&2,String,x=>x,localTexts) ++ "|tick=" ++ Nat.show(tick) ++ "|prefix=" ++ List.show(&2,String,Prior.quote,prefix) ++ "|delivered=" ++ List.show(&2,M.Transition<T.State>,Prior.transition,delivered) ++ "|structuralApplied=" ++ U32.show(applied))
def resources(~S:Data,value:T.Resources<S>) -> T.Resources<S> & String:
  match value:
    case T.Resources{owned,slot,Stream.Stream{batches,positions,dropped,frameStart},readerOwner,tickLocals,tick,prefix,delivered,applied}:resources_join(~S,slot,batches,positions,dropped,frameStart,tick,prefix,delivered,applied,Dump.u32_array(owned),reader(~S,readerOwner),locals(tickLocals))
def world_join(~S:Data,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,+events:List<&2,Unit>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,live:Array<Bool> & String,column:Col.Column<S,Array<U32>> & String,resource:T.Resources<S> & String,pending:List<(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)> & Nat) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & String:
  match live column resource pending:
    case (live,sl),(column,sc),(resource,sr),(pending,+count):(W.World{namespace,nextId,highWater,live,capacity,depth,T.Store{column},resource,events,pending,registrations,nextSystemId,clock},"namespace=" ++ U32.show(namespace) ++ "|nextId=" ++ U32.show(nextId) ++ "|highWater=" ++ U32.show(highWater) ++ "|live=" ++ sl ++ "|capacity=" ++ U32.show(capacity) ++ "|depth=" ++ Nat.show(depth) ++ "|store=" ++ sc ++ "|resource={" ++ sr ++ "}|events=" ++ List.show(&2,Unit,u=>"Unit",events) ++ "|pendingCount=" ++ Nat.show(count) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,registrations) ++ "|nextSystemId=" ++ U32.show(nextSystemId) ++ "|clock=" ++ U32.show(clock))
def world(~S:Data,value:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & String:
  match value:
    case W.World{namespace,nextId,highWater,live,capacity,depth,T.Store{column},resource,events,pending,registrations,nextSystemId,clock}:world_join(~S,namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock,Dump.bool_array(live),Dump.column(~S,~Array<U32>,~Dump.u32_array,column),resources(~S,resource),Dump.callbacks(~W.World<S,T.Store<S>,T.Resources<S>,Unit>,~W.World<S,T.Store<S>,T.Resources<S>,Unit>,pending))
def registry(~S:Data,value:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>) -> Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>> & String:
  match value:
    case None{}:(None{},"None")
    case Some{Sys.Registry{+namespace,+id,+name,+access,+cursor}}:(Some{Sys.Registry{namespace,id,name,access,cursor}},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":cursor=" ++ U32.show(cursor))
def entries_join(~S:Data,head:H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>,text:String,tail:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>> & List<&2,String>) -> List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>> & List<&2,String>:
  (rest,texts)=tail
  (head <> rest,text <> texts)
def entries(~S:Data,values:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>>) -> List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>> & List<&2,String>:
  match values:
    case []:([],[])
    case H.Entry{+ordinal,Sys.Registry{+namespace,+id,+name,+access,+cursor}} <> rest:entries_join(~S,H.Entry{ordinal,Sys.Registry{namespace,id,name,access,cursor}},U32.show(ordinal) ++ ":" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":cursor=" ++ U32.show(cursor),entries(~S,rest))
def observed(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit> & String,exit:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>> & List<&2,String>,transition:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>> & List<&2,String>,enter:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>> & List<&2,String>,readerRegistry:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>> & String) -> App.Application<S> & String:
  match world exit transition enter readerRegistry:
    case (world,text),(exit,se),(transition,st),(enter,si),(readerRegistry,sr):(App.Application{world,H.Owners{exit,transition,enter},readerRegistry},"world{" ++ text ++ "}|exit=" ++ List.show(&2,String,x=>x,se) ++ "|transition=" ++ List.show(&2,String,x=>x,st) ++ "|enter=" ++ List.show(&2,String,x=>x,si) ++ "|readerRegistry=" ++ sr)
def observe(~S:Data,value:App.Application<S>) -> App.Application<S> & String:
  match value:
    case App.Application{actualWorld,H.Owners{exit,transition,enter},readerRegistry}:observed(~S,world(~S,actualWorld),entries(~S,exit),entries(~S,transition),entries(~S,enter),registry(~S,readerRegistry))
