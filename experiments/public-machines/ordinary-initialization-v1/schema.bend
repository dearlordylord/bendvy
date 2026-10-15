import Base
import ../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../src/ecs/ordinary-machine-declaration.bend as OD
import ../../../src/ecs/machine.bend as M
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/machine-stream.bend as St
import ../../../src/ecs/system.bend as Sys

type SchemaA is Data: SchemaA{}
type SchemaB is Data: SchemaB{}

type MachineKey<S:Data> is Data: MachineKey{}
type MachineState is Data: A{} B{} C{} D{}

type StreamSnapshot<S:Data> is Data:
  StreamSnapshot{batches:List<&2,Ev.Batch<M.Transition<MachineState>>>,positions:List<&2,Ev.Position>,dropped:Nat,frameStart:Nat}
type Snapshot<S:Data> is Data:
  Snapshot{slot:M.Slot<S,MachineKey<S>,MachineState>,stream:StreamSnapshot<S>,revision:Nat,defaultEffects:Nat,callbackLog:List<&2,String>,failEnter:Bool}

# The initialization state is stored in the actual ECS resource, alongside the
# fixture's observable default-effect count and callback log.
type Resources<S:Data> is Data:
  Resources{machine:Init.State<S,MachineKey<S>,MachineState>,defaultEffects:Nat,callbackLog:List<&2,String>,failEnter:Bool}

# A registered user transition reader receives the real prepared stream view as
# its system arguments. Its failure result is kept outside the callback output
# so the consumer can still report the attempted values on the failure branch.
type TransitionReadArgs is Data:
  TransitionReadArgs{values:List<&2,M.Transition<MachineState>>,lagged:Bool,fail:Bool}
type TransitionReadOutput is Data:
  TransitionReadOutput{values:List<&2,M.Transition<MachineState>>,lagged:Bool}

def resources(~S:Data) -> Resources<S>:
  Resources{Init.empty(~S,~MachineKey<S>,~MachineState),0n,[],False{}}

def take_machine(~S:Data,resource:Resources<S>) -> Resources<S> & Init.State<S,MachineKey<S>,MachineState>:
  match resource:
    case Resources{+machine,defaultEffects,callbackLog,failEnter}:(Resources{machine,defaultEffects,callbackLog,failEnter},machine)

def world_unit(~S:Data,pair:W.World<S,Array<U32>,Resources<S>,String> & Unit) -> W.World<S,Array<U32>,Resources<S>,String>:
  match pair:
    case (world,_):world

def put_machine(~S:Data,resource:Resources<S>,machine:Init.State<S,MachineKey<S>,MachineState>) -> Resources<S>:
  match resource:
    case Resources{_,defaultEffects,callbackLog,failEnter}:Resources{machine,defaultEffects,callbackLog,failEnter}

def take_slot(~S:Data,resource:Resources<S>) -> Resources<S> & M.Slot<S,MachineKey<S>,MachineState>:
  Init.take_slot(~S,~MachineKey<S>,~MachineState,~Resources<S>,~take_machine(~S),~put_machine(~S),resource)

def put_slot(~S:Data,~same:MachineState -> MachineState -> Bool,resource:Resources<S>,slot:M.Slot<S,MachineKey<S>,MachineState>) -> Resources<S>:
  Init.put_slot(~S,~MachineKey<S>,~MachineState,~Resources<S>,~take_machine(~S),~put_machine(~S),~same,resource,slot)

def declaration(~S:Data) -> OD.Declaration<S,MachineKey<S>,MachineState,Resources<S>,Init.take_slot(~S,~MachineKey<S>,~MachineState,~Resources<S>,~take_machine(~S),~put_machine(~S))>:
  Init.declared(~S,~MachineKey<S>,~MachineState,~Resources<S>,~take_machine(~S),~put_machine(~S),"machine.state",[A{},B{},C{},D{}])

def same_state(a:MachineState,b:MachineState) -> Bool:
  match a b:
    case A{} A{}:True{}
    case B{} B{}:True{}
    case C{} C{}:True{}
    case D{} D{}:True{}
    case _ _:False{}

def default_effect(~S:Data,resource:Resources<S>) -> Resources<S> & Nat:
  match resource:
    case Resources{machine,+defaultEffects,callbackLog,failEnter}:
      (Resources{machine,Nat.add(defaultEffects,1n),callbackLog,failEnter},Nat.add(defaultEffects,1n))

def effect_count(~S:Data,resource:Resources<S>) -> Resources<S> & Nat:
  match resource:
    case Resources{machine,+defaultEffects,callbackLog,failEnter}:(Resources{machine,defaultEffects,callbackLog,failEnter},defaultEffects)

def set_fail_enter(~S:Data,resource:Resources<S>,enabled:Bool) -> Resources<S>:
  match resource:
    case Resources{machine,defaultEffects,callbackLog,_}:Resources{machine,defaultEffects,callbackLog,enabled}

def fail_enter_on(~S:Data,resource:Resources<S>) -> Resources<S>:
  set_fail_enter(~S,resource,True{})

def fail_enter_off(~S:Data,resource:Resources<S>) -> Resources<S>:
  set_fail_enter(~S,resource,False{})

def failure_resource(~S:Data,resource:Resources<S>,enabled:Bool) -> Resources<S> & Unit:
  (set_fail_enter(~S,resource,enabled),Unit{})

def failure_world(~S:Data,world:W.World<S,Array<U32>,Resources<S>,String>,enabled:Bool) -> W.World<S,Array<U32>,Resources<S>,String>:
  world_unit(~S,Init.with_resource(~S,~Array<U32>,~Resources<S>,~String,~Unit,(resource => failure_resource(~S,resource,enabled)),world))

def queue_taken(~S:Data,value:MachineState,pair:Resources<S> & Init.State<S,MachineKey<S>,MachineState>) -> Resources<S>:
  match pair:
    case (resource,Init.State{slot,stream,revision}):put_machine(~S,resource,Init.State{M.queue(~S,~MachineKey<S>,~MachineState,slot,value,False{}),stream,revision})

def queue_resource(~S:Data,resource:Resources<S>,value:MachineState) -> Resources<S> & Unit:
  (queue_taken(~S,value,take_machine(~S,resource)),Unit{})

def queue_world(~S:Data,world:W.World<S,Array<U32>,Resources<S>,String>,value:MachineState) -> W.World<S,Array<U32>,Resources<S>,String>:
  world_unit(~S,Init.with_resource(~S,~Array<U32>,~Resources<S>,~String,~Unit,(resource => queue_resource(~S,resource,value)),world))

def log(~S:Data,resource:Resources<S>,entry:String) -> Resources<S>:
  match resource:
    case Resources{machine,defaultEffects,+callbackLog,failEnter}:Resources{machine,defaultEffects,List.append(&2,String,callbackLog,[entry]),failEnter}

def failure_mode(~S:Data,resource:Resources<S>) -> Resources<S> & Bool:
  match resource:
    case Resources{machine,defaultEffects,callbackLog,+failEnter}:(Resources{machine,defaultEffects,callbackLog,failEnter},failEnter)

def stream_snapshot(~S:Data,value:List<&2,Ev.Batch<M.Transition<MachineState>>> & (List<&2,Ev.Position> & (Nat & Nat))) -> StreamSnapshot<S>:
  match value:
    case (batches,(positions,(dropped,frameStart))):StreamSnapshot{batches,positions,dropped,frameStart}
def snapshot_resource(~S:Data,resource:Resources<S>) -> Resources<S> & Snapshot<S>:
  match resource:
    case Resources{+machine,+defaultEffects,+callbackLog,+failEnter}:
      match machine:
        case Init.State{+slot,+stream,+revision}:
          (Resources{Init.State{slot,stream,revision},defaultEffects,callbackLog,failEnter},Snapshot{slot,stream_snapshot(~S,St.snapshot(~MachineState,stream)),revision,defaultEffects,callbackLog,failEnter})

def default_finished(~S:Data,observed:W.World<S,Array<U32>,Resources<S>,String> & Nat) -> W.World<S,Array<U32>,Resources<S>,String> & MachineState:
  match observed:
    case (world,_):(world,A{})

def make_default(~S:Data,world:W.World<S,Array<U32>,Resources<S>,String>) -> W.World<S,Array<U32>,Resources<S>,String> & MachineState:
  default_finished(~S,W.observe_resource(~S,~Array<U32>,~Resources<S>,~String,~Nat,~default_effect(~S),world))

def initialize(~S:Data,world:W.World<S,Array<U32>,Resources<S>,String>) -> W.World<S,Array<U32>,Resources<S>,String>:
  Init.init_state(~S,~MachineKey<S>,~MachineState,~Resources<S>,~take_machine(~S),~put_machine(~S),~Array<U32>,~String,~declaration(~S),~make_default(~S),world)

def insert(~S:Data,world:W.World<S,Array<U32>,Resources<S>,String>,value:MachineState) -> W.World<S,Array<U32>,Resources<S>,String>:
  Init.insert_state(~S,~MachineKey<S>,~MachineState,~Resources<S>,~take_machine(~S),~put_machine(~S),~Array<U32>,~String,~declaration(~S),world,value)

def remove_resource(~S:Data,resource:Resources<S>) -> Resources<S> & Unit:
  (put_slot(~S,~same_state,resource,M.Missing{}),Unit{})

def resource_returned(~S:Data,pair:W.World<S,Array<U32>,Resources<S>,String> & Unit) -> W.World<S,Array<U32>,Resources<S>,String>:
  match pair:
    case (world,_):world

def remove_slot(~S:Data,world:W.World<S,Array<U32>,Resources<S>,String>) -> W.World<S,Array<U32>,Resources<S>,String>:
  resource_returned(~S,W.observe_resource(~S,~Array<U32>,~Resources<S>,~String,~Unit,~remove_resource(~S),world))

def transition_reader_runner(~S:Data,world:W.World<S,Array<U32>,Resources<S>,String>,args:TransitionReadArgs) -> Sys.Outcome<W.World<S,Array<U32>,Resources<S>,String>,String,TransitionReadOutput>:
  match args:
    case TransitionReadArgs{values,lagged,True{}}:Sys.Failed{world,"transition-reader-failed"}
    case TransitionReadArgs{values,lagged,False{}}:Sys.Succeeded{world,TransitionReadOutput{values,lagged}}

def transition_reader_create(~S:Data,namespace:U32,id:U32,world:W.World<S,Array<U32>,Resources<S>,String>) -> W.World<S,Array<U32>,Resources<S>,String> & St.Reader<S,MachineKey<S>>:
  (world,St.Reader{namespace,id})

def transition_reader_validate(~S:Data,reader:St.Reader<S,MachineKey<S>>,namespace:U32,id:U32) -> St.Reader<S,MachineKey<S>> & Bool:
  match reader:
    case St.Reader{+actualNamespace,+actualId}:(reader,Bool.and(U32.is_eq(actualNamespace,namespace),U32.is_eq(actualId,id)))

def transition_stream_from_machine(~S:Data,pair:Resources<S> & Init.State<S,MachineKey<S>,MachineState>) -> Resources<S> & St.Stream<MachineState>:
  match pair:
    case (resource,Init.State{slot,+stream,revision}):(put_machine(~S,resource,Init.State{slot,stream,revision}),stream)

def transition_stream_from_resource(~S:Data,resource:Resources<S>) -> Resources<S> & St.Stream<MachineState>:
  transition_stream_from_machine(~S,take_machine(~S,resource))

def transition_stream_put_machine(~S:Data,pair:Resources<S> & Init.State<S,MachineKey<S>,MachineState>,stream:St.Stream<MachineState>) -> Resources<S> & Unit:
  match pair:
    case (resource,Init.State{slot,_,revision}):(put_machine(~S,resource,Init.State{slot,stream,revision}),Unit{})

def transition_stream_put_resource(~S:Data,resource:Resources<S>,stream:St.Stream<MachineState>) -> Resources<S> & Unit:
  transition_stream_put_machine(~S,take_machine(~S,resource),stream)

def transition_stream_world_returned(~S:Data,pair:W.World<S,Array<U32>,Resources<S>,String> & Unit) -> W.World<S,Array<U32>,Resources<S>,String>:
  match pair:
    case (world,_):world

def transition_stream_world(~S:Data,world:W.World<S,Array<U32>,Resources<S>,String>) -> W.World<S,Array<U32>,Resources<S>,String> & St.Stream<MachineState>:
  W.observe_resource(~S,~Array<U32>,~Resources<S>,~String,~St.Stream<MachineState>,~transition_stream_from_resource(~S),world)

def transition_stream_set_world(~S:Data,world:W.World<S,Array<U32>,Resources<S>,String>,stream:St.Stream<MachineState>) -> W.World<S,Array<U32>,Resources<S>,String>:
  transition_stream_world_returned(~S,Init.with_resource(~S,~Array<U32>,~Resources<S>,~String,~Unit,(resource => transition_stream_put_resource(~S,resource,stream)),world))

def transition_reader_remove_stream_pair(~S:Data,pair:W.World<S,Array<U32>,Resources<S>,String> & St.Stream<MachineState>,id:U32) -> W.World<S,Array<U32>,Resources<S>,String>:
  match pair:
    case (world,stream):transition_stream_set_world(~S,world,St.dispose(~MachineState,stream,id))

def transition_reader_remove_stream(~S:Data,world:W.World<S,Array<U32>,Resources<S>,String>,reader:St.Reader<S,MachineKey<S>>) -> W.World<S,Array<U32>,Resources<S>,String>:
  match reader:
    case St.Reader{namespace,+id}:transition_reader_remove_stream_pair(~S,transition_stream_world(~S,world),id)

def transition_reader_remove(~S:Data,world:W.World<S,Array<U32>,Resources<S>,String>,reader:St.Reader<S,MachineKey<S>>) -> W.World<S,Array<U32>,Resources<S>,String>:
  transition_reader_remove_stream(~S,world,reader)
