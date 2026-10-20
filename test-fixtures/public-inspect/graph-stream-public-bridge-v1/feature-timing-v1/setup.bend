import Base
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/relation-commands.bend as A
import ../../../../src/ecs/relation-types.bend as G
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/machine.bend as M
import ../../../../src/ecs/machine-stream.bend as St
import ../../../../src/ecs/ordinary-machine-operations.bend as MO
import ../../../../src/ecs/ordinary-machine-declaration.bend as MD
import ../../../../src/ecs/system.bend as Sys
import state.bend as State
import ./declarations.bend as D
import ./reader.bend as MachineCalls

def World(~S:Data) -> Type:
  W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>
def Transaction(~S:Data) -> Type:
  Tx.Tx<World(~S),A.Notice<S,U32>>

type SetupFailure<S:Data> is Type:
  CreationRefused{factory:W.Factory,resources:State.Resources<S>}
  ReservationRefused{factory:W.Factory,world:World(~S),handles:List<&2,W.Handle<S>>,error:W.WorldError}
  ActivationRefused{factory:W.Factory,world:World(~S),handles:List<&2,W.Handle<S>>,stage:U32,error:W.WorldError}
  RelationQueueRefused{factory:W.Factory,transaction:Transaction(~S),handles:List<&2,W.Handle<S>>,edge:U32}
  CommitRefused{factory:W.Factory,world:World(~S),handles:List<&2,W.Handle<S>>,error:W.WorldError}
  MachineCommitRefused{factory:W.Factory,world:World(~S),handles:List<&2,W.Handle<S>>,error:W.WorldError}
  ReaderRegistrationRefused{factory:W.Factory,world:World(~S),handles:List<&2,W.Handle<S>>}
  ReaderReservationRefused{factory:W.Factory,registry:MachineCalls.ReaderRegistry(~S),world:World(~S),handles:List<&2,W.Handle<S>>,error:W.WorldError}
  ReaderRelationQueueRefused{factory:W.Factory,registry:MachineCalls.ReaderRegistry(~S),transaction:Transaction(~S),handles:List<&2,W.Handle<S>>,edge:U32}
  ReaderCommitRefused{factory:W.Factory,registry:MachineCalls.ReaderRegistry(~S),world:World(~S),handles:List<&2,W.Handle<S>>,error:W.WorldError}
  ReaderMachineCommitRefused{factory:W.Factory,registry:MachineCalls.ReaderRegistry(~S),world:World(~S),handles:List<&2,W.Handle<S>>,error:W.WorldError}

type Setup<S:Data> is Type:
  BendvyReady{world:World(~S),registry:MachineCalls.ReaderRegistry(~S),+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>}
  BuildRefused{failure:SetupFailure<S>}

def initial_components(~S:Data) -> State.Components<S>:
  State.Components{Array.new(List<&2,U32>,4n,[]),Array.new(List<&2,U32>,4n,[])}

def initial_resources(~S:Data) -> State.Resources<S>:
  State.Resources{ANode{ALeaf{11},ALeaf{12}},ANode{ALeaf{21},ALeaf{22}},M.Present{4,M.NoPending{},None{},False{}},M.Present{10,M.NoPending{},None{},False{}},0,St.empty(~U32),St.empty(~U32)}

def with_resources(~S:Data,change:State.Resources<S> -> State.Resources<S>,world:World(~S)) -> World(~S):
  match world:
    case W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:W.World{namespace,nextId,highWater,live,capacity,depth,store,change(resource),events,pending,registrations,nextSystemId,clock}

def cell_payload(+id:U32) -> List<&2,U32>:
  [(id * 10 + 1 : U32),(id * 10 + 2 : U32)]
def sibling_payload(+id:U32) -> List<&2,U32>:
  [(id * 10 + 3 : U32),(id * 10 + 4 : U32)]
def write_component(~S:Data,values:Array<List<&2,U32>>,handle:W.Handle<S>,payload:List<&2,U32>) -> Array<List<&2,U32>>:
  match handle:
    case W.Handle{_,id}:Array.set(List<&2,U32>,values,U32.sub(id,1),payload)
def seed_store(~S:Data,store:A.Store<S,State.Components<S>>,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>) -> A.Store<S,State.Components<S>>:
  match store:
    case A.Store{components,graph}:
      match components:
        case State.Components{cells,sibling}:
          cells1=write_component(~S,cells,first,cell_payload(1))
          cells2=write_component(~S,cells1,middle,cell_payload(2))
          cells3=write_component(~S,cells2,last,cell_payload(3))
          siblings1=write_component(~S,sibling,first,sibling_payload(1))
          siblings2=write_component(~S,siblings1,middle,sibling_payload(2))
          siblings3=write_component(~S,siblings2,last,sibling_payload(3))
          A.Store{State.Components{cells3,siblings3},graph}
def seed_store_effect(~S:Data,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,store:A.Store<S,State.Components<S>>) -> A.Store<S,State.Components<S>> & Unit:
  (seed_store(~S,store,first,middle,last),Unit{})
def seeded_world(~S:Data,observed:World(~S) & Unit) -> World(~S):
  match observed:
    case (world,_):world
def seed_world(~S:Data,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,world:World(~S)) -> World(~S):
  seeded_world(~S,W.with_store(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,store => seed_store_effect(~S,first,middle,last,store),world))

def empty_store(~S:Data,_:Unit) -> A.Store<S,State.Components<S>>:
  A.empty(~S,~State.Components<S>,initial_components(~S))

def enqueue_all(~S:Data,commands:List<&1,(World(~S) -> World(~S))>,world:World(~S)) -> World(~S):
  match commands:
    case []:world
    case command <> rest:enqueue_all(~S,rest,W.enqueue(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,command))

def publish_all(~S:Data,world:World(~S),notices:List<&2,A.Notice<S,U32>>) -> World(~S):
  W.event_publish(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,notices)

def enqueue_tx(~S:Data,world:World(~S),commands:List<&1,(World(~S) -> World(~S))>) -> World(~S):
  enqueue_all(~S,commands,world)
def publish_tx(~S:Data,world:World(~S),events:List<&2,A.Notice<S,U32>>) -> World(~S):
  publish_all(~S,world,events)
def finish_tx(~S:Data,transaction:Transaction(~S)) -> Tx.Returned<World(~S),W.WorldError>:
  Tx.finish(~World(~S),~A.Notice<S,U32>,~W.WorldError,~enqueue_tx(~S),~publish_tx(~S),transaction,Tx.Success{})
def advanced_world(~S:Data,observed:World(~S) & U32) -> World(~S):
  match observed:
    case (world,_):world
def advance_world(~S:Data,world:World(~S)) -> World(~S):
  advanced_world(~S,W.advance_clock(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world))

def flow_decl(~S:Data) -> MD.Declaration<S,State.FlowToken,U32,State.Resources<S>,State.flow(~S)>:
  MD.declared(~S,~State.FlowToken,~U32,~State.Resources<S>,~State.flow(~S),"Flow",[4,7,8,9])
def level_decl(~S:Data) -> MD.Declaration<S,State.LevelToken,U32,State.Resources<S>,State.level(~S)>:
  MD.declared(~S,~State.LevelToken,~U32,~State.Resources<S>,~State.level(~S),"Level",[10,11,12])
def initial_state_requests(~S:Data,world:World(~S)) -> Transaction(~S):
  flow=MO.set(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~State.put_flow(~S),~U32.is_eq,~flow_decl(~S),Tx.begin(~World(~S),~A.Notice<S,U32>,world),M.Set{7,False{}})
  MO.set(~S,~State.LevelToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.level(~S),~State.put_level(~S),~U32.is_eq,~level_decl(~S),flow,M.Set{11,False{}})
def pending_state_requests(~S:Data,world:World(~S)) -> Transaction(~S):
  flow=MO.set(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~State.put_flow(~S),~U32.is_eq,~flow_decl(~S),Tx.begin(~World(~S),~A.Notice<S,U32>,world),M.Set{9,False{}})
  MO.set(~S,~State.LevelToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.level(~S),~State.put_level(~S),~U32.is_eq,~level_decl(~S),flow,M.Set{12,True{}})

def publish_transition(tick:Nat,event:Maybe<&2,M.Transition<U32>>,stream:St.Stream<U32>) -> St.Stream<U32>:
  match event:
    case None{}:stream
    case Some{event}:St.publish(~U32,stream,tick,event)
def flow_applied(~S:Data,+tick:Nat,owned:Array<U32>,siblingOwned:Array<U32>,level:M.Slot<S,State.LevelToken,U32>,ran:U32,flowStream:St.Stream<U32>,levelStream:St.Stream<U32>,applied:M.Applied<S,State.FlowToken,U32>) -> State.Resources<S>:
  match applied:
    case M.Applied{slot,event}:State.Resources{owned,siblingOwned,slot,level,ran,publish_transition(tick,event,flowStream),levelStream}
def apply_flow(~S:Data,tick:Nat,resources:State.Resources<S>) -> State.Resources<S>:
  match resources:
    case State.Resources{owned,siblingOwned,+flow,level,ran,+flowStream,levelStream}:flow_applied(~S,tick,owned,siblingOwned,level,ran,flowStream,levelStream,M.apply_snapshot(~S,~State.FlowToken,~U32,~U32.is_eq,flow,M.snapshot(~S,~State.FlowToken,~U32,flow)))
def level_applied(~S:Data,+tick:Nat,owned:Array<U32>,siblingOwned:Array<U32>,flow:M.Slot<S,State.FlowToken,U32>,ran:U32,flowStream:St.Stream<U32>,levelStream:St.Stream<U32>,applied:M.Applied<S,State.LevelToken,U32>) -> State.Resources<S>:
  match applied:
    case M.Applied{slot,event}:State.Resources{owned,siblingOwned,flow,slot,ran,flowStream,publish_transition(tick,event,levelStream)}
def apply_level(~S:Data,tick:Nat,resources:State.Resources<S>) -> State.Resources<S>:
  match resources:
    case State.Resources{owned,siblingOwned,flow,+level,ran,flowStream,+levelStream}:level_applied(~S,tick,owned,siblingOwned,flow,ran,flowStream,levelStream,M.apply_snapshot(~S,~State.LevelToken,~U32,~U32.is_eq,level,M.snapshot(~S,~State.LevelToken,~U32,level)))
def apply_transitions_clocked(~S:Data,clocked:World(~S) & U32) -> World(~S):
  (world,+tick)=clocked
  with_resources(~S,resources => apply_level(~S,U32.to_nat(tick),apply_flow(~S,U32.to_nat(tick),resources)),world)
def apply_transitions(~S:Data,world:World(~S)) -> World(~S):
  apply_transitions_clocked(~S,W.clock(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,advance_world(~S,world)))

def populate_store(~S:Data,store:A.Store<S,State.Components<S>>,+handle:W.Handle<S>,cellsPayload:List<&2,U32>,siblingPayload:List<&2,U32>) -> A.Store<S,State.Components<S>>:
  match store:
    case A.Store{components,graph}:
      match components:
        case State.Components{cells,sibling}:A.Store{State.Components{write_component(~S,cells,handle,cellsPayload),write_component(~S,sibling,handle,siblingPayload)},graph}
def populated_world(~S:Data,observed:World(~S) & Unit) -> World(~S):
  match observed:
    case (world,_):world
def spawn_activated(~S:Data,+handle:W.Handle<S>,observed:World(~S) & W.Status) -> World(~S):
  match observed:
    case (world,W.Accepted{}):
      populated_world(~S,W.with_store(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,store => (populate_store(~S,store,handle,[99,100],[101,102]),Unit{}),world))
    # This command closes over an ID reserved by this same World before enqueue.
    # A refusal cannot occur after that reservation; retain the world defensively.
    case (world,W.Rejected{_}):world
def apply_spawn(~S:Data,+handle:W.Handle<S>,world:World(~S)) -> World(~S):
  spawn_activated(~S,handle,W.activate(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,handle))

def pending_reserved(~S:Data,factory:W.Factory,registry:MachineCalls.ReaderRegistry(~S),+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,observed:World(~S) & W.Reservation<S>) -> Setup<S>:
  match observed:
    case (world,W.Reserved{handle}):BendvyReady{advance_world(~S,W.enqueue(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,queued => apply_spawn(~S,handle,queued))),registry,first,middle,last}
    case (world,W.ReservationRejected{error}):BuildRefused{ReaderReservationRefused{factory,registry,world,[first,middle,last],error}}
def pending_complete(~S:Data,factory:W.Factory,registry:MachineCalls.ReaderRegistry(~S),+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,returned:Tx.Returned<World(~S),W.WorldError>) -> Setup<S>:
  match returned:
    case Tx.Returned{world,Tx.Success{}}:pending_reserved(~S,factory,registry,first,middle,last,W.reserve_id(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world))
    case Tx.Returned{world,Tx.Failure{error}}:BuildRefused{ReaderMachineCommitRefused{factory,registry,world,[first,middle,last],error}}
def pending_requests(~S:Data,factory:W.Factory,registry:MachineCalls.ReaderRegistry(~S),+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,world:World(~S)) -> Setup<S>:
  pending_complete(~S,factory,registry,first,middle,last,finish_tx(~S,pending_state_requests(~S,world)))

def cycle_committed(~S:Data,factory:W.Factory,registry:MachineCalls.ReaderRegistry(~S),+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,returned:Tx.Returned<World(~S),W.WorldError>) -> Setup<S>:
  match returned:
    case Tx.Returned{world,Tx.Success{}}:pending_requests(~S,factory,registry,first,middle,last,advance_world(~S,W.barrier(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world)))
    case Tx.Returned{world,Tx.Failure{error}}:BuildRefused{ReaderCommitRefused{factory,registry,world,[first,middle,last],error}}
def cycle_queued(~S:Data,factory:W.Factory,registry:MachineCalls.ReaderRegistry(~S),+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,observed:Transaction(~S) & A.QueueStatus) -> Setup<S>:
  match observed:
    case (transaction,A.Queued{}):cycle_committed(~S,factory,registry,first,middle,last,finish_tx(~S,transaction))
    case (transaction,A.MissingEntity{}):BuildRefused{ReaderRelationQueueRefused{factory,registry,transaction,[first,middle,last],5}}
def reject_cycle(~S:Data,factory:W.Factory,registry:MachineCalls.ReaderRegistry(~S),+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,world:World(~S)) -> Setup<S>:
  cycle_queued(~S,factory,registry,first,middle,last,A.queue_relate(~S,~State.Components<S>,~State.Resources<S>,~U32,Tx.begin(~World(~S),~A.Notice<S,U32>,world),D.parent(~S),middle,last))

def reader_registered_world(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,world:World(~S),identified:MachineCalls.ReaderRegistry(~S) & U32) -> Setup<S>:
  match identified:
    case (registry,readerId):reject_cycle(~S,factory,registry,first,middle,last,apply_transitions(~S,world))
def reader_registered_transitions(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,result:MachineCalls.ReaderRegistration<S>) -> Setup<S>:
  match result:
    case MachineCalls.StreamReaderRegistrationFailed{world}:BuildRefused{ReaderRegistrationRefused{factory,world,[first,middle,last]}}
    case MachineCalls.StreamReaderRegistered{world,registry}:reader_registered_world(~S,factory,first,middle,last,world,MachineCalls.identify_reader(~S,registry))

def initial_requests_committed(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,returned:Tx.Returned<World(~S),W.WorldError>) -> Setup<S>:
  match returned:
    case Tx.Returned{world,Tx.Success{}}:
      world3=advance_world(~S,W.barrier(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world))
      reader_registered_transitions(~S,factory,first,middle,last,MachineCalls.register_reader(~S,world3))
    case Tx.Returned{world,Tx.Failure{error}}:BuildRefused{MachineCommitRefused{factory,world,[first,middle,last],error}}
def state_transition_requests(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,world:World(~S)) -> Setup<S>:
  initial_requests_committed(~S,factory,first,middle,last,finish_tx(~S,initial_state_requests(~S,advance_world(~S,world))))

def committed(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,result:Tx.Returned<World(~S),W.WorldError>) -> Setup<S>:
  match result:
    case Tx.Returned{world,Tx.Success{}}:state_transition_requests(~S,factory,first,middle,last,advance_world(~S,W.barrier(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world)))
    case Tx.Returned{world,Tx.Failure{error}}:BuildRefused{CommitRefused{factory,world,[first,middle,last],error}}

def commit_edges(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,transaction:Transaction(~S)) -> Setup<S>:
  committed(~S,factory,first,middle,last,finish_tx(~S,Tx.emit(~World(~S),~A.Notice<S,U32>,Tx.emit(~World(~S),~A.Notice<S,U32>,transaction,A.Original{31}),A.Original{32})))

def accepted_edge_four(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,observed:Transaction(~S) & A.QueueStatus) -> Setup<S>:
  match observed:
    case (transaction,A.Queued{}):commit_edges(~S,factory,first,middle,last,transaction)
    case (transaction,A.MissingEntity{}):BuildRefused{RelationQueueRefused{factory,transaction,[first,middle,last],4}}

def accepted_edge_three(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,observed:Transaction(~S) & A.QueueStatus) -> Setup<S>:
  match observed:
    case (transaction,A.Queued{}):accepted_edge_four(~S,factory,first,middle,last,A.queue_relate(~S,~State.Components<S>,~State.Resources<S>,~U32,transaction,D.parent(~S),last,middle))
    case (transaction,A.MissingEntity{}):BuildRefused{RelationQueueRefused{factory,transaction,[first,middle,last],3}}

def accepted_edge_two(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,observed:Transaction(~S) & A.QueueStatus) -> Setup<S>:
  match observed:
    case (transaction,A.Queued{}):accepted_edge_three(~S,factory,first,middle,last,A.queue_relate(~S,~State.Components<S>,~State.Resources<S>,~U32,transaction,D.parent(~S),first,middle))
    case (transaction,A.MissingEntity{}):BuildRefused{RelationQueueRefused{factory,transaction,[first,middle,last],2}}

def accepted_edge_one(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,observed:Transaction(~S) & A.QueueStatus) -> Setup<S>:
  match observed:
    case (transaction,A.Queued{}):accepted_edge_two(~S,factory,first,middle,last,A.queue_relate(~S,~State.Components<S>,~State.Resources<S>,~U32,transaction,D.link(~S),last,middle))
    case (transaction,A.MissingEntity{}):BuildRefused{RelationQueueRefused{factory,transaction,[first,middle,last],1}}

def queue_edges(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,transaction:Transaction(~S)) -> Setup<S>:
  accepted_edge_one(~S,factory,first,middle,last,A.queue_relate(~S,~State.Components<S>,~State.Resources<S>,~U32,transaction,D.link(~S),first,middle))

def activate_last(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,observed:World(~S) & W.Status) -> Setup<S>:
  match observed:
    case (world,W.Accepted{}):queue_edges(~S,factory,first,middle,last,Tx.begin(~World(~S),~A.Notice<S,U32>,seed_world(~S,first,middle,last,world)))
    case (world,W.Rejected{error}):BuildRefused{ActivationRefused{factory,world,[first,middle,last],3,error}}

def activate_middle(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,observed:World(~S) & W.Status) -> Setup<S>:
  match observed:
    case (world,W.Accepted{}):activate_last(~S,factory,first,middle,last,W.activate(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,last))
    case (world,W.Rejected{error}):BuildRefused{ActivationRefused{factory,world,[first,middle,last],2,error}}

def activate_first(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,+last:W.Handle<S>,observed:World(~S) & W.Status) -> Setup<S>:
  match observed:
    case (world,W.Accepted{}):activate_middle(~S,factory,first,middle,last,W.activate(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,middle))
    case (world,W.Rejected{error}):BuildRefused{ActivationRefused{factory,world,[first,middle,last],1,error}}

def reserved_three(~S:Data,factory:W.Factory,+first:W.Handle<S>,+middle:W.Handle<S>,observed:World(~S) & W.Reservation<S>) -> Setup<S>:
  match observed:
    case (world,W.Reserved{handle}):activate_first(~S,factory,first,middle,handle,W.activate(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,first))
    case (world,W.ReservationRejected{error}):BuildRefused{ReservationRefused{factory,world,[first,middle],error}}

def reserved_two(~S:Data,factory:W.Factory,+first:W.Handle<S>,observed:World(~S) & W.Reservation<S>) -> Setup<S>:
  match observed:
    case (world,W.Reserved{handle}):reserved_three(~S,factory,first,handle,W.reserve_id(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world))
    case (world,W.ReservationRejected{error}):BuildRefused{ReservationRefused{factory,world,[first],error}}

def reserved_one(~S:Data,factory:W.Factory,observed:World(~S) & W.Reservation<S>) -> Setup<S>:
  match observed:
    case (world,W.Reserved{handle}):reserved_two(~S,factory,handle,W.reserve_id(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world))
    case (world,W.ReservationRejected{error}):BuildRefused{ReservationRefused{factory,world,[],error}}

def created(~S:Data,result:W.Creation<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> Setup<S>:
  match result:
    case W.Created{factory,world}:reserved_one(~S,factory,W.reserve_id(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world))
    case W.CreateRejected{factory,resource}:BuildRefused{CreationRefused{factory,resource}}

def build(~S:Data) -> Setup<S>:
  created(~S,W.create(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,empty_store(~S),W.factory(),initial_resources(~S)))
