import Base
import types.bend as T
import systems.bend as SysBody
import application.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as Stream
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/owner-observer.bend as Dump

def show_first(value:T.First) -> String:
  match value:
    case T.Cold{}:"Cold"
    case T.Warm{}:"Warm"
    case T.Settled{}:"Settled"
def show_second(value:T.Second) -> String:
  match value:
    case T.Idle{}:"Idle"
    case T.Active{value}:"Active:" ++ U32.show(value)
def event(value:T.Pulse) -> String:
  match value:
    case T.Callback{machine,phase}:U32.show(machine) ++ ":" ++ U32.show(phase)
def pending(~V:Data,~render:V -> String,value:M.Pending<V>) -> String:
  match value:
    case M.NoPending{}:"None"
    case M.Queued{value,skip}:render(value) ++ ":" ++ Bool.show(skip)
def optional(~V:Data,~render:V -> String,value:Maybe<&2,V>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:render(value)
def slot(~S:Data,~K:Data,~V:Data,~render:V -> String,value:M.Slot<S,K,V>) -> String:
  match value:
    case M.Missing{}:"Missing"
    case M.Present{current,next,previous,changed}:render(current) ++ ":pending=" ++ pending(~V,~render,next) ++ ":previous=" ++ optional(~V,~render,previous) ++ ":changed=" ++ Bool.show(changed)
def transition(~V:Data,~render:V -> String,value:M.Transition<V>) -> String:
  match value:
    case M.Transition{from,to}:render(from) ++ ">" ++ render(to)
def batch(~V:Data,~render:V -> String,value:Ev.Batch<M.Transition<V>>) -> String:
  match value:
    case Ev.Batch{tick,values}:Nat.show(tick) ++ ":" ++ List.show(&2,M.Transition<V>,transition(~V,~render),values)
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registeredAt}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registeredAt)
def stream(~V:Data,~render:V -> String,value:Stream.Stream<V>) -> String:
  match value:
    case Stream.Stream{batches,positions,dropped,start}:"batches=" ++ List.show(&2,Ev.Batch<M.Transition<V>>,batch(~V,~render),batches) ++ ":positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ":dropped=" ++ Nat.show(dropped) ++ ":frameStart=" ++ Nat.show(start)
def reader(~S:Data,~K:Data,value:Maybe<&1,Stream.Reader<S,K>>) -> Maybe<&1,Stream.Reader<S,K>> & String:
  match value:
    case None{}:(None{},"None")
    case Some{Stream.Reader{+ns,+id}}:(Some{Stream.Reader{ns,id}},U32.show(ns) ++ ":" ++ U32.show(id))
def local_returned(+namespace:U32,+id:U32,tail:List<&1,T.LocalOwner> & List<&2,String>,pair:Array<U32> & String) -> List<&1,T.LocalOwner> & List<&2,String>:
  match tail pair:
    case (tail,text),(owner,shown):(T.LocalOwner{namespace,id,Local.Cell{owner}} <> tail,(U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ shown) <> text)
def show_locals(items:List<&1,T.LocalOwner>) -> List<&1,T.LocalOwner> & List<&2,String>:
  match items:
    case []:([],[])
    case T.LocalOwner{namespace,id,Local.Cell{owner}} <> rest:local_returned(namespace,id,show_locals(rest),Dump.u32_array(owner))
def resources_returned(~S:Data,+first:M.Slot<S,T.FirstKey,T.First>, +second:M.Slot<S,T.SecondKey,T.Second>, +firstStream:Stream.Stream<T.First>, +secondStream:Stream.Stream<T.Second>, +firstTick:Nat, +secondTick:Nat, +trace:List<&2,String>, +firstDelivered:List<&2,M.Transition<T.First>>, +secondDelivered:List<&2,M.Transition<T.Second>>, +applied:U32,owned:Array<U32> & String,sibling:Array<U32> & String,firstReader:Maybe<&1,Stream.Reader<S,T.FirstKey>> & String,secondReader:Maybe<&1,Stream.Reader<S,T.SecondKey>> & String,locals:List<&1,T.LocalOwner> & List<&2,String>) -> T.Resources<S> & String:
  match owned sibling firstReader secondReader locals:
    case (owned,a),(sibling,b),(firstReader,c),(secondReader,d),(locals,e):(T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},"owned=" ++ a ++ "|sibling=" ++ b ++ "|first={" ++ slot(~S,~T.FirstKey,~T.First,~show_first,first) ++ "}|second={" ++ slot(~S,~T.SecondKey,~T.Second,~show_second,second) ++ "}|firstStream={" ++ stream(~T.First,~show_first,firstStream) ++ "}|secondStream={" ++ stream(~T.Second,~show_second,secondStream) ++ "}|firstReader=" ++ c ++ "|secondReader=" ++ d ++ "|locals=" ++ List.show(&2,String,x=>x,e) ++ "|firstTick=" ++ Nat.show(firstTick) ++ "|secondTick=" ++ Nat.show(secondTick) ++ "|trace=" ++ List.show(&2,String,x=>x,trace) ++ "|firstDelivered=" ++ List.show(&2,M.Transition<T.First>,transition(~T.First,~show_first),firstDelivered) ++ "|secondDelivered=" ++ List.show(&2,M.Transition<T.Second>,transition(~T.Second,~show_second),secondDelivered) ++ "|applied=" ++ U32.show(applied))
def show_resources(~S:Data,value:T.Resources<S>) -> T.Resources<S> & String:
  match value:
    case T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied}:resources_returned(~S,first,second,firstStream,secondStream,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied,Dump.u32_array(owned),Dump.u32_array(sibling),reader(~S,~T.FirstKey,firstReader),reader(~S,~T.SecondKey,secondReader),show_locals(locals))
def store_returned(~S:Data,first:Col.Column<S,Array<U32>> & String,sibling:Col.Column<S,Array<U32>> & String) -> T.Store<S> & String:
  match first sibling:
    case (first,a),(sibling,b):(T.Store{first,sibling},"first=" ++ a ++ "|sibling=" ++ b)
def show_store(~S:Data,value:T.Store<S>) -> T.Store<S> & String:
  match value:
    case T.Store{first,sibling}:store_returned(~S,Dump.column(~S,~Array<U32>,~Dump.u32_array,first),Dump.column(~S,~Array<U32>,~Dump.u32_array,sibling))
def world_returned(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,T.Pulse>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,live:Array<Bool> & String,store:T.Store<S> & String,resources:T.Resources<S> & String,pending:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>)> & Nat) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & String:
  match live store resources pending:
    case (live,a),(store,b),(resources,c),(pending,+count):(W.World{ns,next,high,live,capacity,depth,store,resources,events,pending,registrations,nextSystem,clock},"ns=" ++ U32.show(ns) ++ "|next=" ++ U32.show(next) ++ "|high=" ++ U32.show(high) ++ "|live=" ++ a ++ "|capacity=" ++ U32.show(capacity) ++ "|depth=" ++ Nat.show(depth) ++ "|store={" ++ b ++ "}|resources={" ++ c ++ "}|events=" ++ List.show(&2,T.Pulse,event,events) ++ "|pending=" ++ Nat.show(count) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,registrations) ++ "|nextSystem=" ++ U32.show(nextSystem) ++ "|clock=" ++ U32.show(clock))
def world(~S:Data,value:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,pending,registrations,nextSystem,clock}:world_returned(~S,ns,next,high,capacity,depth,events,registrations,nextSystem,clock,Dump.bool_array(live),show_store(~S,store),show_resources(~S,resources),Dump.callbacks(~W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,~W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,pending))
def selector(~S:Data,~K:Data,~V:Data,~render:V -> String,value:B.Selector<S,K,V>) -> String:
  match value:
    case B.ExitFrom{value}:"exit:" ++ render(value)
    case B.TransitionPair{from,to}:"transition:" ++ render(from) ++ ">" ++ render(to)
    case B.EnterTo{value}:"enter:" ++ render(value)
def entries_returned(~S:Data,~K:Data,~V:Data,~run:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> -> H.Invocation<V> -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>,~render:V -> String,+selected:B.Selector<S,K,V>,+needs:List<&2,U32>,+ordinal:U32,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32,tail:List<&1,B.Scheduled<S,K,V,U32,T.Store<S>,T.Resources<S>,T.Pulse,run>> & List<&2,String>) -> List<&1,B.Scheduled<S,K,V,U32,T.Store<S>,T.Resources<S>,T.Pulse,run>> & List<&2,String>:
  (rest,text)=tail
  (B.Scheduled{selected,needs,H.Entry{ordinal,Sys.Registry{ns,id,name,access,cursor}}} <> rest,(selector(~S,~K,~V,~render,selected) ++ ":needs=" ++ List.show(&2,U32,U32.show,needs) ++ ":entry=" ++ U32.show(ordinal) ++ ":registry=" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":cursor=" ++ U32.show(cursor)) <> text)
def entries(~S:Data,~K:Data,~V:Data,~run:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> -> H.Invocation<V> -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>,~render:V -> String,items:List<&1,B.Scheduled<S,K,V,U32,T.Store<S>,T.Resources<S>,T.Pulse,run>>) -> List<&1,B.Scheduled<S,K,V,U32,T.Store<S>,T.Resources<S>,T.Pulse,run>> & List<&2,String>:
  match items:
    case []:([],[])
    case B.Scheduled{selected,needs,H.Entry{ordinal,Sys.Registry{ns,id,name,access,cursor}}} <> rest:entries_returned(~S,~K,~V,~run,~render,selected,needs,ordinal,ns,id,name,access,cursor,entries(~S,~K,~V,~run,~render,rest))
def bundle_returned(~S:Data,~K:Data,~V:Data,~run:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> -> H.Invocation<V> -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>,~render:V -> String,+ns:U32,pair:List<&1,B.Scheduled<S,K,V,U32,T.Store<S>,T.Resources<S>,T.Pulse,run>> & List<&2,String>) -> B.Bundle<S,K,V,U32,T.Store<S>,T.Resources<S>,T.Pulse,run> & String:
  (entries,text)=pair
  (B.Bundle{ns,entries},U32.show(ns) ++ ":" ++ List.show(&2,String,x=>x,text))
def bundle(~S:Data,~K:Data,~V:Data,~run:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> -> H.Invocation<V> -> Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,String,Unit>,~render:V -> String,value:B.Bundle<S,K,V,U32,T.Store<S>,T.Resources<S>,T.Pulse,run>) -> B.Bundle<S,K,V,U32,T.Store<S>,T.Resources<S>,T.Pulse,run> & String:
  match value:
    case B.Bundle{ns,items}:bundle_returned(~S,~K,~V,~run,~render,ns,entries(~S,~K,~V,~run,~render,items))
def first_registry(~S:Data,value:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.first_reader_runner(~S)>>) -> Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.first_reader_runner(~S)>> & String:
  match value:
    case None{}:(None{},"None")
    case Some{Sys.Registry{+ns,+id,+name,+access,+cursor}}:(Some{Sys.Registry{ns,id,name,access,cursor}},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":cursor=" ++ U32.show(cursor))
def second_registry(~S:Data,value:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.second_reader_runner(~S)>>) -> Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.second_reader_runner(~S)>> & String:
  match value:
    case None{}:(None{},"None")
    case Some{Sys.Registry{+ns,+id,+name,+access,+cursor}}:(Some{Sys.Registry{ns,id,name,access,cursor}},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":cursor=" ++ U32.show(cursor))
def observed(~S:Data,+statuses:List<&2,String>,world:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & String,first:B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)> & String,second:B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)> & String,firstReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.first_reader_runner(~S)>> & String,secondReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.second_reader_runner(~S)>> & String) -> App.Application<S> & String:
  match world first second firstReader secondReader:
    case (world,a),(first,b),(second,c),(firstReader,d),(secondReader,e):(App.Application{world,first,second,firstReader,secondReader,statuses},"world={" ++ a ++ "}|firstBundle=" ++ b ++ "|secondBundle=" ++ c ++ "|firstReaderRegistry=" ++ d ++ "|secondReaderRegistry=" ++ e ++ "|statuses=" ++ List.show(&2,String,x=>x,statuses))
def observe(~S:Data,app:App.Application<S>) -> App.Application<S> & String:
  match app:
    case App.Application{actualWorld,first,second,firstReader,secondReader,statuses}:observed(~S,statuses,world(~S,actualWorld),bundle(~S,~T.FirstKey,~T.First,~SysBody.first_runner(~S),~show_first,first),bundle(~S,~T.SecondKey,~T.Second,~SysBody.second_runner(~S),~show_second,second),first_registry(~S,firstReader),second_registry(~S,secondReader))
    case app:(app,"Recovering")
def labeled(~S:Data,label:String,pair:App.Application<S> & String) -> App.Application<S> & String:
  (app,text)=pair
  (app,label ++ ":" ++ text)
def snapshot(~S:Data,app:App.Application<S>,label:String) -> App.Application<S> & String:labeled(~S,label,observe(~S,app))

def count_local(+namespace:U32,+id:U32,pair:Array<U32> & U32,tail:List<&1,T.LocalOwner> & List<&2,U32>) -> List<&1,T.LocalOwner> & List<&2,U32>:
  match pair tail:
    case (owner,count),(rest,counts):(T.LocalOwner{namespace,id,Local.Cell{owner}} <> rest,count <> counts)
def local_counts(items:List<&1,T.LocalOwner>) -> List<&1,T.LocalOwner> & List<&2,U32>:
  match items:
    case []:([],[])
    case T.LocalOwner{namespace,id,Local.Cell{owner}} <> rest:count_local(namespace,id,Array.get(U32,owner,0),local_counts(rest))
def ledger_resources_returned(~S:Data,+first:M.Slot<S,T.FirstKey,T.First>,+second:M.Slot<S,T.SecondKey,T.Second>,+firstStream:Stream.Stream<T.First>,+secondStream:Stream.Stream<T.Second>,firstReader:Maybe<&1,Stream.Reader<S,T.FirstKey>>,secondReader:Maybe<&1,Stream.Reader<S,T.SecondKey>>,+firstTick:Nat,+secondTick:Nat,+trace:List<&2,String>,+firstDelivered:List<&2,M.Transition<T.First>>,+secondDelivered:List<&2,M.Transition<T.Second>>,+applied:U32,owned:Array<U32> & String,sibling:Array<U32> & String,locals:List<&1,T.LocalOwner> & List<&2,U32>) -> T.Resources<S> & String:
  match owned sibling locals:
    case (owned,a),(sibling,b),(locals,counts):(T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied},"owned=" ++ a ++ "|siblingOwner=" ++ b ++ "|locals=" ++ List.show(&2,U32,U32.show,counts) ++ "|committedCallbacks=" ++ List.show(&2,String,x=>x,trace) ++ "|appliedReplacements=" ++ U32.show(applied) ++ "|firstDelivered=" ++ List.show(&2,M.Transition<T.First>,transition(~T.First,~show_first),firstDelivered) ++ "|secondDelivered=" ++ List.show(&2,M.Transition<T.Second>,transition(~T.Second,~show_second),secondDelivered))
def ledger_resources(~S:Data,value:T.Resources<S>) -> T.Resources<S> & String:
  match value:
    case T.Resources{owned,sibling,first,second,firstStream,secondStream,firstReader,secondReader,locals,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied}:ledger_resources_returned(~S,first,second,firstStream,secondStream,firstReader,secondReader,firstTick,secondTick,trace,firstDelivered,secondDelivered,applied,Dump.u32_array(owned),Dump.u32_array(sibling),local_counts(locals))
def ledger_world_returned(~S:Data,+ns:U32,+next:U32,+high:U32,live:Array<Bool>,+capacity:U32,+depth:Nat,+events:List<&2,T.Pulse>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,store:T.Store<S> & String,resources:T.Resources<S> & String,pending:List<&1,(W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>)> & Nat) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & String:
  match store resources pending:
    case (store,a),(resources,b),(pending,count):(W.World{ns,next,high,live,capacity,depth,store,resources,events,pending,registrations,nextSystem,clock},"component={" ++ a ++ "}|" ++ b ++ "|pulse=" ++ List.show(&2,T.Pulse,event,events) ++ "|pendingCommands=" ++ Nat.show(count))
def ledger_world(~S:Data,value:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>) -> W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,pending,registrations,nextSystem,clock}:ledger_world_returned(~S,ns,next,high,live,capacity,depth,events,registrations,nextSystem,clock,show_store(~S,store),ledger_resources(~S,resources),Dump.callbacks(~W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,~W.World<S,T.Store<S>,T.Resources<S>,T.Pulse>,pending))
def ledger_returned(~S:Data,first:B.Bundle<S,T.FirstKey,T.First,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.first_runner(~S)>,second:B.Bundle<S,T.SecondKey,T.Second,U32,T.Store<S>,T.Resources<S>,T.Pulse,SysBody.second_runner(~S)>,firstReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.first_reader_runner(~S)>>,secondReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,T.Pulse,Unit,String,Unit,SysBody.second_reader_runner(~S)>>,statuses:List<&2,String>,pair:W.World<S,T.Store<S>,T.Resources<S>,T.Pulse> & String) -> App.Application<S> & String:
  (world,text)=pair
  (App.Application{world,first,second,firstReader,secondReader,statuses},"ledger:" ++ text)
def ledger(~S:Data,app:App.Application<S>) -> App.Application<S> & String:
  match app:
    case App.Application{world,first,second,firstReader,secondReader,statuses}:ledger_returned(~S,first,second,firstReader,secondReader,statuses,ledger_world(~S,world))
    case app:(app,"ledger:Recovering")
