import Base
import ./ordinary-machine-initialization.bend as Init
import ./ordinary-machine-declaration.bend as OD
import ./ordinary-machine-handler-bundle.bend as Operation
import ./ordinary-machine-schedule.bend as Ordinary
import ./machine-handler-bundle.bend as B
import ./machine-handler-phases.bend as Phase
import ./machine-handlers.bend as H
import ./machine-stream.bend as St
import ./machine.bend as M
import ./world.bend as W
import ./system.bend as Sys
import ./schedule.bend as Sch
import ./event-runtime.bend as Ev

def take_world(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & M.Slot<S,K,V>:
  W.observe_resource(~S,~C,~R,~E,~M.Slot<S,K,V>,~Init.take_slot(~S,~K,~V,~R,~take,~put),world)
def put_resource(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~same:V -> V -> Bool,resource:R,value:M.Slot<S,K,V>) -> R & Unit:
  (Init.put_slot(~S,~K,~V,~R,~take,~put,~same,resource,value),Unit{})
def returned_world(~S:Data,~C:Type,~R:Type,~E:Data,pair:W.World<S,C,R,E> & Unit) -> W.World<S,C,R,E>:
  match pair:
    case (world,_):world
def put_world(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~same:V -> V -> Bool,world:W.World<S,C,R,E>,value:M.Slot<S,K,V>) -> W.World<S,C,R,E>:
  returned_world(~S,~C,~R,~E,Init.with_resource(~S,~C,~R,~E,~Unit,(resource => put_resource(~S,~K,~V,~R,~take,~put,~C,~E,~same,resource,value)),world))
def stream_taken(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,pair:R & Init.State<S,K,V>) -> R & St.Stream<V>:
  match pair:
    case (resource,Init.State{slot,+stream,revision}):(put(resource,Init.State{slot,stream,revision}),stream)
def stream_put_taken(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,stream:St.Stream<V>,pair:R & Init.State<S,K,V>) -> R & Unit:
  match pair:
    case (resource,Init.State{slot,_,revision}):(put(resource,Init.State{slot,stream,revision}),Unit{})
def stream_put(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,world:W.World<S,C,R,E>,stream:St.Stream<V>) -> W.World<S,C,R,E>:
  returned_world(~S,~C,~R,~E,Init.with_resource(~S,~C,~R,~E,~Unit,(resource => stream_put_taken(~S,~K,~V,~R,~take,~put,~C,~E,stream,take(resource))),world))
def published(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,tick:Nat,event:M.Transition<V>,pair:W.World<S,C,R,E> & St.Stream<V>) -> W.World<S,C,R,E>:
  match pair:
    case (world,stream):stream_put(~S,~K,~V,~R,~take,~put,~C,~E,world,St.publish(~V,stream,tick,event))
def publish_clocked(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,event:M.Transition<V>,pair:W.World<S,C,R,E> & U32) -> W.World<S,C,R,E>:
  match pair:
    case (world,tick):published(~S,~K,~V,~R,~take,~put,~C,~E,U32.to_nat(tick),event,W.observe_resource(~S,~C,~R,~E,~St.Stream<V>,~(resource => stream_taken(~S,~K,~V,~R,~take,~put,~C,~E,take(resource))),world))
def publish(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,world:W.World<S,C,R,E>,event:M.Transition<V>) -> W.World<S,C,R,E>:
  publish_clocked(~S,~K,~V,~R,~take,~put,~C,~E,event,W.advance_clock(~S,~C,~R,~E,world))
def last(~V:Data,items:List<&2,M.Transition<V>>,prior:Maybe<&2,M.Transition<V>>) -> Maybe<&2,M.Transition<V>>:
  match items:
    case []:prior
    case value <> tail:last(~V,tail,Some{value})
type Opening<S:Data,K:Data,V:Data,C:Type,R:Type,E:Data> is Type:
  Opened{world:W.World<S,C,R,E>,reader:St.Reader<S,K>,latest:Maybe<&2,M.Transition<V>>,readThrough:Nat}
  OpenRejected{world:W.World<S,C,R,E>,reader:St.Reader<S,K>}
def opened_finished(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,world:W.World<S,C,R,E>,latest:Maybe<&2,M.Transition<V>>,tick:Nat,pair:St.Reader<S,K> & St.Stream<V>) -> Opening<S,K,V,C,R,E>:
  match pair:
    case (reader,stream):Opened{stream_put(~S,~K,~V,~R,~take,~put,~C,~E,world,stream),reader,latest,tick}
def opened(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,world:W.World<S,C,R,E>,+tick:Nat,result:St.OpenResult<S,K,V>) -> Opening<S,K,V,C,R,E>:
  match result:
    case St.ReaderRefused{reader,stream}:OpenRejected{stream_put(~S,~K,~V,~R,~take,~put,~C,~E,world,stream),reader}
    case St.Opened{reader,stream,Ev.Reading{values,_}}:opened_finished(~S,~K,~V,~R,~take,~put,~C,~E,world,last(~V,values,None{}),tick,St.finish(~S,~K,~V,reader,stream,tick,True{}))
def open_stream(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,reader:St.Reader<S,K>,namespace:U32,+tick:Nat,pair:W.World<S,C,R,E> & St.Stream<V>) -> Opening<S,K,V,C,R,E>:
  match pair:
    case (world,stream):opened(~S,~K,~V,~R,~take,~put,~C,~E,world,tick,St.open(~S,~K,~V,reader,stream,namespace,tick))
def open_clocked(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,reader:St.Reader<S,K>,namespace:U32,pair:W.World<S,C,R,E> & U32) -> Opening<S,K,V,C,R,E>:
  match pair:
    case (world,tick):open_stream(~S,~K,~V,~R,~take,~put,~C,~E,reader,namespace,U32.to_nat(tick),W.observe_resource(~S,~C,~R,~E,~St.Stream<V>,~(resource => stream_taken(~S,~K,~V,~R,~take,~put,~C,~E,take(resource))),world))
def open_namespaced(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,reader:St.Reader<S,K>,pair:W.World<S,C,R,E> & U32) -> Opening<S,K,V,C,R,E>:
  match pair:
    case (world,namespace):open_clocked(~S,~K,~V,~R,~take,~put,~C,~E,reader,namespace,W.clock(~S,~C,~R,~E,world))
def open(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,reader:St.Reader<S,K>,world:W.World<S,C,R,E>) -> Opening<S,K,V,C,R,E>:
  open_namespaced(~S,~K,~V,~R,~take,~put,~C,~E,reader,W.namespace(~S,~C,~R,~E,world))
def completed_stream(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,world:W.World<S,C,R,E>,pair:St.Reader<S,K> & St.Stream<V>) -> W.World<S,C,R,E> & St.Reader<S,K>:
  match pair:
    case (reader,stream):(stream_put(~S,~K,~V,~R,~take,~put,~C,~E,world,stream),reader)
def complete_taken(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,reader:St.Reader<S,K>,tick:Nat,success:Bool,pair:W.World<S,C,R,E> & St.Stream<V>) -> W.World<S,C,R,E> & St.Reader<S,K>:
  match pair:
    case (world,stream):completed_stream(~S,~K,~V,~R,~take,~put,~C,~E,world,St.finish(~S,~K,~V,reader,stream,tick,success))
def complete_clocked(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,reader:St.Reader<S,K>,success:Bool,pair:W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & St.Reader<S,K>:
  match pair:
    case (world,tick):complete_taken(~S,~K,~V,~R,~take,~put,~C,~E,reader,U32.to_nat(tick),success,W.observe_resource(~S,~C,~R,~E,~St.Stream<V>,~(resource => stream_taken(~S,~K,~V,~R,~take,~put,~C,~E,take(resource))),world))
def complete(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,reader:St.Reader<S,K>,success:Bool,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & St.Reader<S,K>:
  complete_clocked(~S,~K,~V,~R,~take,~put,~C,~E,reader,success,W.clock(~S,~C,~R,~E,world))
type Owners<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Owners{ordinary:Operation.Owners<S,K,V,Q,C,R,E,runner>,reader:St.Reader<S,K>,readThrough:Nat}
type MarkerRun<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  MarkerRun{reader:St.Reader<S,K>,result:Operation.MarkerResult<S,K,V,Q,C,R,E,runner>}
def initial_partition(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,namespace:U32,to:V,partition:B.Partition<S,K,V,Q,C,R,E,runner>) -> Operation.Owners<S,K,V,Q,C,R,E,runner>:
  match partition:
    case B.Partition{positions,kept,handlers}:Operation.Selected{positions,kept,Phase.Owners{handlers,Phase.InitialReady{to}},H.Enter{}}
def initial_selected(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,ordinary:Operation.Owners<S,K,V,Q,C,R,E,runner>,opened:Opening<S,K,V,C,R,E>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match ordinary opened:
    case Operation.Pending{entries} Opened{world,reader,Some{M.Initial{+to}},through}:(Owners{initial_partition(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,0,to,B.partition_initial(~S,~K,~V,~Q,~C,~R,~E,~runner,~same,entries,to)),reader,through},Sys.Succeeded{world,Unit{}})
    case Operation.Selected{positions,kept,Phase.Owners{handlers,Phase.Idle{}},phase} Opened{world,reader,Some{M.Initial{to}},through}:(Owners{Operation.Selected{positions,kept,Phase.Owners{handlers,Phase.InitialReady{to}},phase},reader,through},Sys.Succeeded{world,Unit{}})
    case ordinary Opened{world,reader,_,through}:(Owners{ordinary,reader,through},Sys.Succeeded{world,Unit{}})
    case ordinary OpenRejected{world,reader}:(Owners{ordinary,reader,0n},Sys.Failed{world,"InitialReaderRejected"})
def apply_observed(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,reader:St.Reader<S,K>,result:Operation.Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match result:
    case (ordinary,Sys.Failed{world,error}):(Owners{ordinary,reader,0n},Sys.Failed{world,error})
    case (Operation.Unavailable{entries},Sys.Succeeded{world,_}):(Owners{Operation.Unavailable{entries},reader,0n},Sys.Succeeded{world,Unit{}})
    case (Operation.Selected{positions,kept,Phase.Owners{handlers,Phase.Ready{from,to,skip}},phase},Sys.Succeeded{world,_}):(Owners{Operation.Selected{positions,kept,Phase.Owners{handlers,Phase.Ready{from,to,skip}},phase},reader,0n},Sys.Succeeded{world,Unit{}})
    case (ordinary,Sys.Succeeded{world,_}):initial_selected(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,ordinary,open(~S,~K,~V,~R,~take,~put,~C,~E,reader,world))
def apply(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,owners:Owners<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match owners:
    case Owners{ordinary,reader,_}:apply_observed(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,reader,Operation.apply(~S,~K,~V,~Q,~C,~R,~E,~runner,~take_world(~S,~K,~V,~R,~take,~put,~C,~E),~put_world(~S,~K,~V,~R,~take,~put,~C,~E,~same),~publish(~S,~K,~V,~R,~take,~put,~C,~E),~same,~requirement_same,~has,~frame,ordinary,world))
def phase_returned(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,reader:St.Reader<S,K>,through:Nat,result:Operation.Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match result:
    case (ordinary,outcome):(Owners{ordinary,reader,through},outcome)
def exit(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,owners:Owners<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match owners:
    case Owners{ordinary,reader,through}:phase_returned(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,reader,through,Operation.exit(~S,~K,~V,~Q,~C,~R,~E,~runner,~take_world(~S,~K,~V,~R,~take,~put,~C,~E),~put_world(~S,~K,~V,~R,~take,~put,~C,~E,~same),~publish(~S,~K,~V,~R,~take,~put,~C,~E),~same,~requirement_same,~has,~frame,ordinary,world))
def checkpoint_opened(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,ordinary:Operation.Owners<S,K,V,Q,C,R,E,runner>,opened:Opening<S,K,V,C,R,E>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match opened:
    case Opened{world,reader,_,through}:(Owners{ordinary,reader,through},Sys.Succeeded{world,Unit{}})
    case OpenRejected{world,reader}:(Owners{ordinary,reader,0n},Sys.Failed{world,"InitialReaderRejected"})
def transition_returned(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,reader:St.Reader<S,K>,through:Nat,result:Operation.Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match result:
    case (Operation.Selected{positions,kept,Phase.Owners{handlers,Phase.Ready{from,to,skip}},phase},Sys.Succeeded{world,_}):checkpoint_opened(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,Operation.Selected{positions,kept,Phase.Owners{handlers,Phase.Ready{from,to,skip}},phase},open(~S,~K,~V,~R,~take,~put,~C,~E,reader,world))
    case (ordinary,outcome):(Owners{ordinary,reader,through},outcome)
def transition(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,owners:Owners<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match owners:
    case Owners{ordinary,reader,through}:transition_returned(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,reader,through,Operation.transition(~S,~K,~V,~Q,~C,~R,~E,~runner,~take_world(~S,~K,~V,~R,~take,~put,~C,~E),~put_world(~S,~K,~V,~R,~take,~put,~C,~E,~same),~publish(~S,~K,~V,~R,~take,~put,~C,~E),~same,~requirement_same,~has,~frame,ordinary,world))
def enter(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,owners:Owners<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>) -> Owners<S,K,V,Q,C,R,E,runner> & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match owners:
    case Owners{ordinary,reader,through}:phase_returned(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,reader,through,Operation.enter(~S,~K,~V,~Q,~C,~R,~E,~runner,~take_world(~S,~K,~V,~R,~take,~put,~C,~E),~put_world(~S,~K,~V,~R,~take,~put,~C,~E,~same),~publish(~S,~K,~V,~R,~take,~put,~C,~E),~same,~requirement_same,~has,~frame,ordinary,world))
def finished_world(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,namespace:U32,ordinary:Operation.Owners<S,K,V,Q,C,R,E,runner>,steps:List<&2,Sch.Step>,observations:List<&2,Sch.Observation>,error:Maybe<&2,String>,pair:W.World<S,C,R,E> & St.Reader<S,K>) -> MarkerRun<S,K,V,Q,C,R,E,runner>:
  match pair:
    case (world,reader):MarkerRun{reader,Operation.MarkerResult{Operation.finished(~S,~K,~V,~Q,~C,~R,~E,~runner,~take_world(~S,~K,~V,~R,~take,~put,~C,~E),~put_world(~S,~K,~V,~R,~take,~put,~C,~E,~same),~publish(~S,~K,~V,~R,~take,~put,~C,~E),~same,~requirement_same,~has,~frame,namespace,ordinary,world,error),steps,observations}}
def succeeded(error:Maybe<&2,String>) -> Bool:
  match error:
    case None{}:True{}
    case Some{_}:False{}
def finished(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,namespace:U32,owners:Owners<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>,steps:List<&2,Sch.Step>,observations:List<&2,Sch.Observation>,+error:Maybe<&2,String>) -> MarkerRun<S,K,V,Q,C,R,E,runner>:
  match owners:
    case Owners{ordinary,reader,through}:finished_world(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,namespace,ordinary,steps,observations,error,(world,reader))
def returned(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,result:Sch.RunResult<S,C,R,E,Owners<S,K,V,Q,C,R,E,runner>,String>) -> MarkerRun<S,K,V,Q,C,R,E,runner>:
  match result:
    case Sch.Finished{Sch.Schedule{namespace,_,steps,owners},world,observations}:finished(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,namespace,owners,world,steps,observations,None{})
    case Sch.Failed{Sch.Schedule{namespace,_,steps,owners},world,error,observations}:finished(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,namespace,owners,world,steps,observations,Some{error})
    case Sch.Rejected{Sch.Schedule{namespace,_,steps,owners},world}:finished(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,namespace,owners,world,steps,[],Some{"schedule-rejected"})
def installed(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,world:W.World<S,C,R,E>,build:Sch.Build<S,C,R,E,Owners<S,K,V,Q,C,R,E,runner>>) -> MarkerRun<S,K,V,Q,C,R,E,runner>:
  match build:
    case Sch.Built{schedule}:returned(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,Ordinary.run(~S,~C,~R,~E,~Owners<S,K,V,Q,C,R,E,runner>,~String,~apply(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame),~exit(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame),~transition(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame),~enter(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame),schedule,world))
    case Sch.Invalid{owners}:finished(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,0,owners,world,[],[],Some{"invalid"})
def checked(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,declaration:Ordinary.Declaration<S>,namespace:U32,reader:St.Reader<S,K>,entries:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>>,pair:W.World<S,C,R,E> & List<&2,Q>) -> MarkerRun<S,K,V,Q,C,R,E,runner>:
  match pair:
    case (world,[]):installed(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,world,Ordinary.install(~S,~C,~R,~E,~Owners<S,K,V,Q,C,R,E,runner>,~String,declaration,namespace,Owners{Operation.Pending{entries},reader,0n}))
    case (world,missing):MarkerRun{reader,Operation.MarkerResult{B.Returned{B.Bundle{namespace,entries},world,B.MissingRequirements{missing}},[],[]}}
def gathered(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,declaration:Ordinary.Declaration<S>,namespace:U32,reader:St.Reader<S,K>,world:W.World<S,C,R,E>,pair:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,Q>) -> MarkerRun<S,K,V,Q,C,R,E,runner>:
  match pair:
    case (entries,needs):checked(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,declaration,namespace,reader,entries,B.missing(~S,~C,~R,~E,~Q,~has,B.collect(~Q,~requirement_same,needs,[]),world))
def allowed(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,declaration:Ordinary.Declaration<S>,yes:Bool,namespace:U32,reader:St.Reader<S,K>,entries:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>>,world:W.World<S,C,R,E>) -> MarkerRun<S,K,V,Q,C,R,E,runner>:
  match yes:
    case False{}:MarkerRun{reader,Operation.MarkerResult{B.Returned{B.Bundle{namespace,entries},world,B.ForeignBundle{}},[],[]}}
    case True{}:gathered(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,declaration,namespace,reader,world,B.requirements(~S,~K,~V,~Q,~C,~R,~E,~runner,entries))
def namespaced(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,declaration:Ordinary.Declaration<S>,+namespace:U32,reader:St.Reader<S,K>,entries:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>>,pair:W.World<S,C,R,E> & U32) -> MarkerRun<S,K,V,Q,C,R,E,runner>:
  match reader pair:
    case St.Reader{+owner,id}, (world,+actual):allowed(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,declaration,Bool.and(U32.is_eq(namespace,actual),U32.is_eq(owner,actual)),namespace,St.Reader{owner,id},entries,world)
def run(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,declaration:Ordinary.Declaration<S>,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>,reader:St.Reader<S,K>,world:W.World<S,C,R,E>) -> MarkerRun<S,K,V,Q,C,R,E,runner>:
  match bundle:
    case B.Bundle{namespace,entries}:namespaced(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,declaration,namespace,reader,entries,W.namespace(~S,~C,~R,~E,world))
# Normal application construction allocates its marker reader through World.register.
type Application<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Application{world:W.World<S,C,R,E>,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>,reader:St.Reader<S,K>,declaration:Ordinary.Declaration<S>}
type Definition<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Bound{app:Application<S,K,V,Q,C,R,E,runner>}
  BindRejected{world:W.World<S,C,R,E>,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>,declaration:Ordinary.Declaration<S>}
def bound(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,namespace:U32,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>,declaration:Ordinary.Declaration<S>,pair:W.World<S,C,R,E> & W.Registration) -> Definition<S,K,V,Q,C,R,E,runner>:
  match pair:
    case (world,W.Registered{id}):Bound{Application{world,bundle,St.Reader{namespace,id},declaration}}
    case (world,W.RegistrationRejected{_}):BindRejected{world,bundle,declaration}
def bind_allowed(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,~initial:OD.Declaration<S,K,V,R,Init.take_slot(~S,~K,~V,~R,~take,~put)>,allowed:Bool,namespace:U32,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>,declaration:Ordinary.Declaration<S>,world:W.World<S,C,R,E>) -> Definition<S,K,V,Q,C,R,E,runner>:
  match allowed:
    case False{}:BindRejected{world,bundle,declaration}
    case True{}:bound(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,namespace,bundle,declaration,W.register(~S,~C,~R,~E,world,"machine." ++ OD.name(~S,~K,~V,~R,~Init.take_slot(~S,~K,~V,~R,~take,~put),initial) ++ ".initial-marker",["machine." ++ OD.name(~S,~K,~V,~R,~Init.take_slot(~S,~K,~V,~R,~take,~put),initial) ++ ".transition.read"]))
def bind_namespaced(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,~initial:OD.Declaration<S,K,V,R,Init.take_slot(~S,~K,~V,~R,~take,~put)>,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>,declaration:Ordinary.Declaration<S>,pair:W.World<S,C,R,E> & U32) -> Definition<S,K,V,Q,C,R,E,runner>:
  match bundle pair:
    case B.Bundle{+owner,entries}, (world,+namespace):bind_allowed(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,~initial,U32.is_eq(owner,namespace),namespace,B.Bundle{owner,entries},declaration,world)
def bind(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,~initial:OD.Declaration<S,K,V,R,Init.take_slot(~S,~K,~V,~R,~take,~put)>,declaration:Ordinary.Declaration<S>,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>,world:W.World<S,C,R,E>) -> Definition<S,K,V,Q,C,R,E,runner>:
  bind_namespaced(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,~initial,bundle,declaration,W.namespace(~S,~C,~R,~E,world))
type AppRun<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Applied{app:Application<S,K,V,Q,C,R,E,runner>,status:B.Status<Q>,steps:List<&2,Sch.Step>,observations:List<&2,Sch.Observation>}
  RecoveryRequired{declaration:Ordinary.Declaration<S>,result:MarkerRun<S,K,V,Q,C,R,E,runner>}
def app_returned(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,declaration:Ordinary.Declaration<S>,result:MarkerRun<S,K,V,Q,C,R,E,runner>) -> AppRun<S,K,V,Q,C,R,E,runner>:
  match result:
    case MarkerRun{reader,Operation.MarkerResult{B.Returned{bundle,world,status},steps,observations}}:Applied{Application{world,bundle,reader,declaration},status,steps,observations}
    case result:RecoveryRequired{declaration,result}
def run_app(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,app:Application<S,K,V,Q,C,R,E,runner>) -> AppRun<S,K,V,Q,C,R,E,runner>:
  match app:
    case Application{world,bundle,reader,+declaration}:app_returned(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,declaration,run(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,declaration,bundle,reader,world))

# Application methods retain marker and handler ownership across ordinary setup.
def init_app(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,~initial:OD.Declaration<S,K,V,R,Init.take_slot(~S,~K,~V,~R,~take,~put)>,~make:W.World<S,C,R,E> -> W.World<S,C,R,E> & V,app:Application<S,K,V,Q,C,R,E,runner>) -> Application<S,K,V,Q,C,R,E,runner>:
  match app:
    case Application{world,bundle,reader,declaration}:Application{Init.init_state(~S,~K,~V,~R,~take,~put,~C,~E,~initial,~make,world),bundle,reader,declaration}
def insert_app(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~C:Type,~E:Data,~Q:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,~initial:OD.Declaration<S,K,V,R,Init.take_slot(~S,~K,~V,~R,~take,~put)>,app:Application<S,K,V,Q,C,R,E,runner>,value:V) -> Application<S,K,V,Q,C,R,E,runner>:
  match app:
    case Application{world,bundle,reader,declaration}:Application{Init.insert_state(~S,~K,~V,~R,~take,~put,~C,~E,~initial,world,value),bundle,reader,declaration}
