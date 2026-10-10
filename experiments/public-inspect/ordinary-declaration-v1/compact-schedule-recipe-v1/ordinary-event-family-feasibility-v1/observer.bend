import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-schema-debug-v1/refusal-preservation-v1/public-successor/consumer/owner-observer.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import stream.bend as Leaf
import family.bend as Publication
import routing.bend as Route
import tree-runtime.bend as Tree
import tree-setup.bend as Setup
import tree-consumer.bend as Consumer
import consumer.bend as Source

def text(value:String) -> String:value
def first_text(value:Source.First) -> String:
  match value:
    case Source.First{value}:"A:" ++ U32.show(value)
def second_text(value:Source.Second) -> String:
  match value:
    case Source.Second{value}:"B:" ++ Bool.show(value)
def unused(value:Setup.Unused) -> String:
  match value:
    case Setup.Unused{code}:"Unused:" ++ U32.show(code)
def pair(value:Setup.PairEvents()) -> String:
  match value:
    case Publication.Publication{a,b}:"pair(" ++ List.show(&2,Source.First,first_text,a) ++ "," ++ List.show(&2,Source.Second,second_text,b) ++ ")"
def event(value:Setup.Events()) -> String:
  match value:
    case Publication.Publication{a,b}:"record(" ++ List.show(&2,Setup.PairEvents(),pair,a) ++ "," ++ List.show(&2,Setup.Unused,unused,b) ++ ")"
def batch(~E:Data,~show:E -> String,value:Ev.Batch<E>) -> String:
  match value:
    case Ev.Batch{tick,values}:Nat.show(tick) ++ ":" ++ List.show(&2,E,show,values)
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registered)
def domain_key(~E:Data,value:Event.Domain<Source.Schema,E>) -> String:
  match value:
    case Event.Domain{key}:key
def stream(~E:Data,~show:E -> String,value:Leaf.Stream<Source.Schema,E>) -> String:
  match value:
    case Leaf.Stream{domain,batches,positions,nextReader,frameStart,boundary,capacity,dropped}:"domain=" ++ domain_key(~E,domain) ++ "|batches=" ++ List.show(&2,Ev.Batch<E>,batch(~E,~show),batches) ++ "|positions=" ++ List.show(&2,Ev.Position,position,positions) ++ "|nextReader=" ++ U32.show(nextReader) ++ "|frame=" ++ Nat.show(frameStart) ++ "|boundary=" ++ Nat.show(boundary) ++ "|capacity=" ++ Nat.show(capacity) ++ "|dropped=" ++ Nat.show(dropped)
def world_returned(+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,+events:List<&2,Setup.Events()>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,live:Array<Bool> & String,store:Array<U32> & String,resource:Array<U32> & String,pending:List<(Setup.World() -> Setup.World())> & Nat) -> Setup.World() & String:
  (live,liveText)=live
  (store,storeText)=store
  (resource,resourceText)=resource
  (pending,+count)=pending
  (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},"ns=" ++ U32.show(namespace) ++ "|next=" ++ U32.show(nextId) ++ "|high=" ++ U32.show(highWater) ++ "|live=" ++ liveText ++ "|capacity=" ++ U32.show(capacity) ++ "|depth=" ++ Nat.show(depth) ++ "|store=" ++ storeText ++ "|resource=" ++ resourceText ++ "|events=" ++ List.show(&2,Setup.Events(),event,events) ++ "|pending=" ++ Nat.show(count) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,O.registration,registrations) ++ "|nextSystem=" ++ U32.show(nextSystemId) ++ "|clock=" ++ U32.show(clock))
def observe_world(value:Setup.World()) -> Setup.World() & String:
  match value:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:world_returned(namespace,nextId,highWater,capacity,depth,events,registrations,nextSystemId,clock,O.bool_array(live),O.u32_array(store),O.u32_array(resource),O.callbacks(~Setup.World(),~Setup.World(),pending))
def state_returned(+first:Leaf.Stream<Source.Schema,Source.First>,+second:Leaf.Stream<Source.Schema,Source.Second>,+unusedLeaf:Leaf.Stream<Source.Schema,Setup.Unused>,+journal:List<&2,Ev.Batch<Setup.Events()>>,+frameStart:Nat,observed:Array<U32> & String) -> Setup.State() & String:
  match observed:
    case (owners,text):(Tree.State{Product.Owner{Product.Owner{first,second},unusedLeaf},owners,journal,frameStart},"first{" ++ stream(~Source.First,~first_text,first) ++ "}|second{" ++ stream(~Source.Second,~second_text,second) ++ "}|unused{" ++ stream(~Setup.Unused,~unused,unusedLeaf) ++ "}|sibling=" ++ text ++ "|journal=" ++ List.show(&2,Ev.Batch<Setup.Events()>,batch(~Setup.Events(),~event),journal) ++ "|frameStart=" ++ Nat.show(frameStart))
def observe_state(value:Setup.State()) -> Setup.State() & String:
  match value:
    case Tree.State{Product.Owner{Product.Owner{first,second},unusedLeaf},owners,journal,frameStart}:state_returned(first,second,unusedLeaf,journal,frameStart,O.u32_array(owners))
def runtime_returned(+tick:Nat,observedWorld:Setup.World() & String,observedState:Setup.State() & String) -> Setup.Runtime() & String:
  (world,worldText)=observedWorld
  (state,stateText)=observedState
  (Route.Runtime{world,state,tick},"tick=" ++ Nat.show(tick) ++ "|" ++ worldText ++ "|" ++ stateText)
def observe_runtime(value:Setup.Runtime()) -> Setup.Runtime() & String:
  match value:
    case Route.Runtime{world,state,tick}:runtime_returned(tick,observe_world(world),observe_state(state))
def first_reader(value:Consumer.FirstReader()) -> Consumer.FirstReader() & String:
  match value:
    case Route.Reader{+namespace,+id,+registryId}:(Route.Reader{namespace,id,registryId},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ U32.show(registryId))
def first_registry(value:Consumer.FirstRegistry()) -> Consumer.FirstRegistry() & String:
  match value:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}:(Sys.Registry{namespace,id,name,access,cursor},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access) ++ ":" ++ U32.show(cursor))
def second_reader(value:Consumer.SecondReader()) -> Consumer.SecondReader() & String:
  match value:
    case Route.Reader{+namespace,+id,+registryId}:(Route.Reader{namespace,id,registryId},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ U32.show(registryId))
def second_registry(value:Consumer.SecondRegistry()) -> Consumer.SecondRegistry() & String:
  match value:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}:(Sys.Registry{namespace,id,name,access,cursor},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access) ++ ":" ++ U32.show(cursor))
def publisher_registry(value:Consumer.PublisherRegistry()) -> Consumer.PublisherRegistry() & String:
  match value:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}:(Sys.Registry{namespace,id,name,access,cursor},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access) ++ ":" ++ U32.show(cursor))
def fixture_returned(factory:W.Factory,publisher:Consumer.PublisherRegistry() & String,runtime:Setup.Runtime() & String,first:Consumer.FirstReader() & String,firstRegistry:Consumer.FirstRegistry() & String,slow:Consumer.FirstReader() & String,slowRegistry:Consumer.FirstRegistry() & String,second:Consumer.SecondReader() & String,secondRegistry:Consumer.SecondRegistry() & String) -> Consumer.Fixture & String:
  (publisher,publisherText)=publisher
  (runtime,runtimeText)=runtime
  (first,firstText)=first
  (firstRegistry,firstRegistryText)=firstRegistry
  (slow,slowText)=slow
  (slowRegistry,slowRegistryText)=slowRegistry
  (second,secondText)=second
  (secondRegistry,secondRegistryText)=secondRegistry
  (Consumer.Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry},runtimeText ++ "|publisher=" ++ publisherText ++ "|firstReader=" ++ firstText ++ ":" ++ firstRegistryText ++ "|slowReader=" ++ slowText ++ ":" ++ slowRegistryText ++ "|secondReader=" ++ secondText ++ ":" ++ secondRegistryText)
def fixture(value:Consumer.Fixture) -> Consumer.Fixture & String:
  match value:
    case Consumer.Fixture{factory,publisher,runtime,first,firstRegistry,slow,slowRegistry,second,secondRegistry}:fixture_returned(factory,publisher_registry(publisher),observe_runtime(runtime),first_reader(first),first_registry(firstRegistry),first_reader(slow),first_registry(slowRegistry),second_reader(second),second_registry(secondRegistry))
    case value:(value,"SetupUnavailable")
