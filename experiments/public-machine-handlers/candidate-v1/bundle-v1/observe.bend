import Base
import types.bend as T
import application.bend as App
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/machine.bend as M
import ../../../../src/ecs/machine-stream.bend as Stream
import ../../../../src/ecs/machine-handlers.bend as H
import ../../../../src/ecs/machine-conditions.bend as Cond
import ../../../../src/ecs/event-runtime.bend as Ev
import systems.bend as Systems
import bundle.bend as B

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
    case M.Queued{value,skip}: "{\"value\":" ++ state(value) ++ ",\"skipIfSame\":" ++ bool(skip) ++ "}"
def slot(~S:Data,value:M.Slot<S,T.MachineKey,T.State>) -> String:
  match value:
    case M.Missing{}: "\"current\":null,\"pending\":null,\"previous\":null,\"changed\":false"
    case M.Present{current,next,prior,changed}: "\"current\":" ++ state(current) ++ ",\"pending\":" ++ pending(next) ++ ",\"previous\":" ++ previous(prior) ++ ",\"changed\":" ++ bool(changed)
def quote(text:String) -> String:
  "\"" ++ text ++ "\""
def transition(event:M.Transition<T.State>) -> String:
  match event:
    case M.Transition{from,to}: "{\"from\":" ++ state(from) ++ ",\"to\":" ++ state(to) ++ "}"
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
    case None{}: (None{},"\"readerNamespace\":null,\"readerId\":null,\"readerPosition\":null")
    case Some{Stream.Reader{+ns,+id}}: (Some{Stream.Reader{ns,id}},"\"readerNamespace\":" ++ U32.show(ns) ++ ",\"readerId\":" ++ U32.show(id) ++ ",\"readerPosition\":" ++ position(positions))

def requirement(~S:Data,value:T.Requirement<S>) -> String:
  match value:
    case T.MachineRequirement{}: "\"machine\""
    case T.OwnedRequirement{}: "\"owned\""
    case T.ExtraRequirement{}: "\"extra\""
def selector(~S:Data,value:B.Selector<S,T.MachineKey,T.State>) -> String:
  match value:
    case B.ExitFrom{old}: "\"phase\":\"exit\",\"from\":" ++ state(old) ++ ",\"to\":null"
    case B.TransitionPair{old,new}: "\"phase\":\"transition\",\"from\":" ++ state(old) ++ ",\"to\":" ++ state(new)
    case B.EnterTo{new}: "\"phase\":\"enter\",\"from\":null,\"to\":" ++ state(new)
type EntriesObserved<S:Data> is Type:
  EntriesObserved{entries:List<&1,B.Scheduled<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>,texts:List<&2,String>,ids:List<&2,U32>,names:List<&2,String>,namespaces:List<&2,U32>,cursors:List<&2,U32>,requirements:List<&2,T.Requirement<S>>}
def entry_join(~S:Data,head:B.Scheduled<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,text:String,id:U32,name:String,ns:U32,cursor:U32,needs:List<&2,T.Requirement<S>>,tail:EntriesObserved<S>) -> EntriesObserved<S>:
  match tail:
    case EntriesObserved{entries,texts,ids,names,namespaces,cursors,requirements}: EntriesObserved{head <> entries,text <> texts,id <> ids,name <> names,ns <> namespaces,cursor <> cursors,List.append(&2,T.Requirement<S>,needs,requirements)}
def entries(~S:Data,items:List<&1,B.Scheduled<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>) -> EntriesObserved<S>:
  match items:
    case []: EntriesObserved{[],[],[],[],[],[],[]}
    case B.Scheduled{+selected,+needs,H.Entry{+ordinal,Sys.Registry{+ns,+id,+name,+access,+cursor}}} <> rest:
      entry_join(~S,B.Scheduled{selected,needs,H.Entry{ordinal,Sys.Registry{ns,id,name,access,cursor}}},"{\"id\":" ++ U32.show(id) ++ ",\"name\":" ++ quote(name) ++ "," ++ selector(~S,selected) ++ ",\"delta\":" ++ U32.show(Systems.amount(ordinal)) ++ ",\"requirements\":" ++ List.show(&2,T.Requirement<S>,requirement(~S),needs) ++ "}",id,name,ns,cursor,needs,entries(~S,rest))
def extra_viewed(pair:Array<U32> & String) -> Maybe<&1,Array<U32>> & String & Bool:
  (owner,text)=pair
  (Some{owner},text,True{})
def extra_view(owner:Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>> & String & Bool:
  match owner:
    case None{}: (None{},"null",False{})
    case Some{owner}: extra_viewed(array(owner))

def publication(event:M.Transition<T.State>,tick:Nat) -> String:
  match event:
    case M.Transition{from,to}: "{\"from\":" ++ state(from) ++ ",\"to\":" ++ state(to) ++ ",\"tick\":" ++ Nat.show(tick) ++ "}"
def publications_values(values:List<&2,M.Transition<T.State>>,+tick:Nat) -> List<&2,String>:
  match values:
    case []: []
    case value <> tail: publication(value,tick) <> publications_values(tail,tick)
def publications(items:List<&2,Ev.Batch<M.Transition<T.State>>>) -> List<&2,String>:
  match items:
    case []: []
    case Ev.Batch{tick,values} <> rest: List.append(&2,String,publications_values(values,tick),publications(rest))
def commands_join(~S:Data,head:W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>,tail:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)> & Nat) -> List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)> & Nat:
  (rest,count)=tail
  (head <> rest,1n+count)
def commands(~S:Data,items:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)>) -> List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)> & Nat:
  match items:
    case []: ([],0n)
    case head <> rest: commands_join(~S,head,commands(~S,rest))
def last(items:List<&2,String>,prior:String) -> String:
  match items:
    case []: prior
    case head <> rest: last(rest,head)
def status(~S:Data,value:Maybe<&2,B.Status<T.Requirement<S>>>,attemptLog:List<&2,String>) -> String:
  match value:
    case None{}: "\"outcome\":\"idle\",\"missing\":[]"
    case Some{B.Completed{}}: "\"outcome\":\"ok\",\"missing\":[]"
    case Some{B.HandlerFailed{_,_}}: "\"outcome\":" ++ quote("failed:" ++ last(attemptLog,"unknown")) ++ ",\"missing\":[]"
    case Some{B.MissingRequirements{missing}}: "\"outcome\":\"requirements\",\"missing\":" ++ List.show(&2,T.Requirement<S>,requirement(~S),missing)
    case Some{B.ForeignBundle{}}: "\"outcome\":\"foreign\",\"missing\":[]"
    case Some{B.MachineUnavailable{}}: "\"outcome\":\"machineUnavailable\",\"missing\":[]"
def resources_join(~S:Data,rest:T.Resources<S>,owned:Array<U32> & String,extra:Maybe<&1,Array<U32>> & String & Bool,localValues:List<&1,T.LocalOwner> & List<&2,U32>,readerValue:Maybe<&1,Stream.Reader<S,T.MachineKey>> & String,runStatus:Maybe<&2,B.Status<T.Requirement<S>>>) -> T.Resources<S> & String:
  match rest owned extra localValues readerValue:
    case T.Resources{_,+slotValue,Stream.Stream{+batches,positions,dropped,start},_,_,+tick,+prefix,+delivered,+applied,_,failureId,+attemptLog}, (owned,ownedText), (extra,extraText,available), (locals,values), (reader,readerText):
      (T.Resources{owned,slotValue,Stream.Stream{batches,positions,dropped,start},reader,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog},"\"resource\":" ++ ownedText ++ ",\"extraPresent\":" ++ bool(available) ++ ",\"extraPayload\":" ++ extraText ++ ",\"locals\":" ++ List.show(&2,U32,U32.show,values) ++ "," ++ slot(~S,slotValue) ++ "," ++ readerText ++ ",\"publications\":" ++ List.show(&2,String,s => s,publications(batches)) ++ ",\"deliveries\":" ++ List.show(&2,M.Transition<T.State>,transition,delivered) ++ ",\"tick\":" ++ Nat.show(tick) ++ ",\"prefix\":" ++ List.show(&2,String,quote,prefix) ++ ",\"attempts\":" ++ List.show(&2,String,quote,attemptLog) ++ ",\"structuralApplied\":" ++ U32.show(applied) ++ "," ++ status(~S,runStatus,attemptLog))
def resources_from_stream(~S:Data,rest:T.Resources<S>,stream:Stream.Stream<T.State>,owned:Array<U32>,extra:Maybe<&1,Array<U32>>,localOwners:List<&1,T.LocalOwner>,readerOwner:Maybe<&1,Stream.Reader<S,T.MachineKey>>,runStatus:Maybe<&2,B.Status<T.Requirement<S>>>) -> T.Resources<S> & String:
  match stream:
    case Stream.Stream{_,positions,_,_}: resources_join(~S,rest,array(owned),extra_view(extra),locals(localOwners),reader(~S,readerOwner,positions),runStatus)
def resources(~S:Data,owner:T.Resources<S>,runStatus:Maybe<&2,B.Status<T.Requirement<S>>>) -> T.Resources<S> & String:
  match owner:
    case T.Resources{owned,slotValue,+stream,readerOwner,localOwners,tick,prefix,delivered,applied,extra,failureId,attemptLog}: resources_from_stream(~S,T.Resources{ALeaf{0},slotValue,stream,None{},[],tick,prefix,delivered,applied,None{},failureId,attemptLog},stream,owned,extra,localOwners,readerOwner,runStatus)

def world_join(~S:Data,+ns:U32,next:U32,high:U32,live:Array<Bool>,capacity:U32,depth:Nat,column:Col.Column<S,Array<U32>> & Maybe<&2,String>,resource:T.Resources<S> & String,events:List<&2,Unit>,pending:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,Unit> -> W.World<S,T.Store<S>,T.Resources<S>,Unit>)> & Nat,registrations:List<&2,W.RegistrationMeta>,nextSystem:U32,+clock:U32) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & String:
  match column resource pending:
    case (column,Some{cells}), (owner,text), (pending,count):
      (W.World{ns,next,high,live,capacity,depth,T.Store{column},owner,events,pending,registrations,nextSystem,clock},"\"namespace\":" ++ U32.show(ns) ++ ",\"entity\":1,\"component\":" ++ cells ++ "," ++ text ++ ",\"clock\":" ++ U32.show(clock) ++ ",\"pendingStructural\":" ++ Nat.show(count))
    case (column,None{}), (owner,text), (pending,count):
      (W.World{ns,next,high,live,capacity,depth,T.Store{column},owner,events,pending,registrations,nextSystem,clock},"\"namespace\":" ++ U32.show(ns) ++ ",\"entity\":1,\"component\":null," ++ text ++ ",\"clock\":" ++ U32.show(clock) ++ ",\"pendingStructural\":" ++ Nat.show(count))
def world(~S:Data,owner:W.World<S,T.Store<S>,T.Resources<S>,Unit>,status:Maybe<&2,B.Status<T.Requirement<S>>>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & String:
  match owner:
    case W.World{ns,next,high,live,capacity,depth,T.Store{column},resource,events,pending,registrations,nextSystem,clock}:
      world_join(~S,ns,next,high,live,capacity,depth,Col.view(~S,~Array<U32>,~String,~array,column,1),resources(~S,resource,status),events,commands(~S,pending),registrations,nextSystem,clock)
def observed(~S:Data,namespace:U32,world:W.World<S,T.Store<S>,T.Resources<S>,Unit> & String,entryValues:EntriesObserved<S>,readerRegistry:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,status:Maybe<&2,B.Status<T.Requirement<S>>>) -> App.Application<S> & String:
  match world entryValues readerRegistry:
    case (world,text), EntriesObserved{entries,texts,ids,names,namespaces,cursors,requirements}, Some{Sys.Registry{+ns,+id,+name,+access,+cursor}}:
      (App.Application{world,B.Bundle{namespace,entries},Some{Sys.Registry{ns,id,name,access,cursor}},status},"{" ++ text ++ ",\"registryIds\":" ++ List.show(&2,U32,U32.show,ids) ++ ",\"registryNames\":" ++ List.show(&2,String,quote,names) ++ ",\"registryNamespaces\":" ++ List.show(&2,U32,U32.show,namespaces) ++ ",\"registryCursors\":" ++ List.show(&2,U32,U32.show,cursors) ++ ",\"readerCursor\":" ++ U32.show(cursor) ++ ",\"entries\":" ++ List.show(&2,String,s => s,texts) ++ ",\"requirements\":" ++ List.show(&2,T.Requirement<S>,requirement(~S),B.collect(~T.Requirement<S>,~App.requirement_same(~S),requirements,[])) ++ "}")
    case (world,_), EntriesObserved{entries,_,_,_,_,_,_}, None{}: (App.Application{world,B.Bundle{namespace,entries},None{},status},"{\"error\":\"MissingRegistry\"}")
def observe(~S:Data,app:App.Application<S>) -> App.Application<S> & String:
  match app:
    case App.Application{owner,B.Bundle{namespace,items},readerRegistry,+status}: observed(~S,namespace,world(~S,owner,status),entries(~S,items),readerRegistry,status)
    case app: (app,"{\"error\":\"OwnerRemainder\"}")
