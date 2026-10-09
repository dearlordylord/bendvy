import Base
import application.bend as A
import pair.bend as P
import wider/runtime-v14.bend as K
import domains.bend as D
import readings.bend as Read
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/relation-commands.bend as RC
import ../../../../../../src/ecs/event-runtime.bend as Ev

type Delivery<S: Data> is Data:
  Delivery{who: String,result: U32,readings: List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,privateCells: List<&2,U32>,domains: List<&2,D.Domain<S,RC.Notice<S,U32>>>,positions: List<&2,Ev.Position>}
type Driven<S: Data> is Type:
  Driven{pair: P.OwnedReaders<S>,deliveries: List<&2,Delivery<S>>}

def cells(array: Array<U32>) -> List<&2,U32>:
  match array:
    case ALeaf{value}: [value]
    case ANode{left,right}: List.append(&2,U32,cells(left),cells(right))

def private_observed(cloned: Array<U32> & Array<U32>) -> Array<U32> & List<&2,U32>:
  (owner,copy) = cloned
  (owner,cells(copy))

def delivered_side(~S: Data,isFast: Bool,pair: P.OwnedReaders<S>,deliveries: List<&2,Delivery<S>>) -> Driven<S>:
  match isFast pair:
    case True{} pair: Driven{pair,deliveries}
    case False{} P.OwnedReaders{runtime,fast,slow,owner,other}: Driven{P.OwnedReaders{runtime,fast,slow,other,owner},deliveries}

def delivered(~S: Data,who: String,result: U32,readings: List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,observed: Array<U32> & List<&2,U32>,runtime: K.Runtime<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>,fast: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,slow: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,other: Array<U32>,previous: List<&2,Delivery<S>>,isFast: Bool) -> Driven<S>:
  match observed runtime:
    case (owner,observedCells) K.Runtime{world,+domains,+positions,tick,frameStart,boundary,capacity}:
      delivered_side(~S,isFast,P.OwnedReaders{K.Runtime{world,domains,positions,tick,frameStart,boundary,capacity},fast,slow,owner,other},Delivery{who,result,readings,observedCells,domains,positions} <> previous)


# A failed reader placed its original private owner in the resource mailbox.
# Recovery removes that very owner; no replacement owner is constructed.
def recover_world(~S: Data,world: W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>) -> W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & Maybe<A.ReturnedPrivate<S>>:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,A.Resources{baseline,owner <> rest},events,pending,registrations,nextSystemId,clock}: (W.World{namespace,nextId,highWater,live,capacity,depth,store,A.Resources{baseline,rest},events,pending,registrations,nextSystemId,clock},Some{owner})
    case world: (world,None{})

def recovered(~S: Data,result: W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & Maybe<A.ReturnedPrivate<S>>,domains: List<&2,D.Domain<S,RC.Notice<S,U32>>>,positions: List<&2,Ev.Position>,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat) -> K.Runtime<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & Maybe<A.ReturnedPrivate<S>>:
  (world,owner) = result
  (K.Runtime{world,domains,positions,tick,frameStart,boundary,capacity},owner)

def recover(~S: Data,runtime: K.Runtime<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>) -> K.Runtime<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & Maybe<A.ReturnedPrivate<S>>:
  match runtime:
    case K.Runtime{world,domains,positions,tick,frameStart,boundary,capacity}: recovered(~S,recover_world(~S,world),domains,positions,tick,frameStart,boundary,capacity)

def recovered_failure(~S: Data,recovered: K.Runtime<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & Maybe<A.ReturnedPrivate<S>>,fast: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,slow: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,other: Array<U32>,previous: List<&2,Delivery<S>>,who: String,error: U32,isFast: Bool) -> Maybe<Driven<S>>:
  match recovered:
    case (runtime,Some{A.ReturnedPrivate{owner,readings}}): Some{delivered(~S,who,error,readings,private_observed(Array.clone(U32,owner)),runtime,fast,slow,other,previous,isFast)}
    case _: None{}

def fast_completed(~S: Data,result: K.RunResult<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,slow: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,otherPrivate: Array<U32>,previous: List<&2,Delivery<S>>) -> Maybe<Driven<S>>:
  match result:
    case K.Ran{runtime,fast,K.Succeeded{(owner,readings)}}: Some{delivered(~S,"fast",0,readings,private_observed(Array.clone(U32,owner)),runtime,fast,slow,otherPrivate,previous,True{})}
    case K.Ran{runtime,fast,K.Failed{error}}: recovered_failure(~S,recover(~S,runtime),fast,slow,otherPrivate,previous,"fast",error,True{})
    case _: None{}

def fast(~S: Data,state: Driven<S>,fail: Bool) -> Maybe<Driven<S>>:
  match state:
    case Driven{P.OwnedReaders{runtime,fast,slow,fastPrivate,slowPrivate},previous}: fast_completed(~S,K.run(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~A.ReaderArgs,~U32,~(Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>),~A.reader(~S),~A.classify(~S),runtime,fast,A.ReaderArgs{fastPrivate,fail}),slow,slowPrivate,previous)

def slow_completed(~S: Data,result: K.RunResult<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,fast: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,otherPrivate: Array<U32>,previous: List<&2,Delivery<S>>) -> Maybe<Driven<S>>:
  match result:
    case K.Ran{runtime,slow,K.Succeeded{(owner,readings)}}: Some{delivered(~S,"slow",0,readings,private_observed(Array.clone(U32,owner)),runtime,fast,slow,otherPrivate,previous,False{})}
    case K.Ran{runtime,slow,K.Failed{error}}: recovered_failure(~S,recover(~S,runtime),fast,slow,otherPrivate,previous,"slow",error,False{})
    case _: None{}

def slow(~S: Data,state: Driven<S>,fail: Bool) -> Maybe<Driven<S>>:
  match state:
    case Driven{P.OwnedReaders{runtime,fast,slow,fastPrivate,slowPrivate},previous}: slow_completed(~S,K.run(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~A.ReaderArgs,~U32,~(Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>),~A.reader(~S),~A.classify(~S),runtime,slow,A.ReaderArgs{slowPrivate,fail}),fast,fastPrivate,previous)

def queue_named(~S: Data,named: W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & U32,key: U32,target: U32) -> W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & RC.QueueStatus:
  (world,+namespace) = named
  A.queue(~S,A.descriptor(~S,key),W.Handle{namespace,1},W.Handle{namespace,target},world)

def queue_completed(~S: Data,result: K.Runtime<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & RC.QueueStatus,fast: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,slow: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,fastPrivate: Array<U32>,slowPrivate: Array<U32>,previous: List<&2,Delivery<S>>) -> Driven<S>:
  (runtime,_) = result
  Driven{P.OwnedReaders{runtime,fast,slow,fastPrivate,slowPrivate},previous}

def queue(~S: Data,state: Driven<S>,key: U32,target: U32) -> Driven<S>:
  match state:
    case Driven{P.OwnedReaders{runtime,fast,slow,fastPrivate,slowPrivate},previous}:
      queue_completed(~S,K.with_world(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~RC.QueueStatus,~A.classify(~S),world => queue_named(~S,W.namespace(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,world),key,target),runtime),fast,slow,fastPrivate,slowPrivate,previous)

def barrier(~S: Data,state: Driven<S>) -> Driven<S>:
  match state:
    case Driven{P.OwnedReaders{runtime,fast,slow,fastPrivate,slowPrivate},previous}: Driven{P.OwnedReaders{K.barrier(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~A.classify(~S),runtime),fast,slow,fastPrivate,slowPrivate},previous}

def frame(~S: Data,state: Driven<S>) -> Driven<S>:
  match state:
    case Driven{P.OwnedReaders{runtime,fast,slow,fastPrivate,slowPrivate},previous}: Driven{P.OwnedReaders{K.frame(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,runtime),fast,slow,fastPrivate,slowPrivate},previous}

def execute_step(~S: Data,step: U32,state: Driven<S>) -> Maybe<Driven<S>>:
  match step:
    case 0: fast(~S,state,False{})
    case 1: slow(~S,state,False{})
    case 2: Some{queue(~S,state,1,1)}
    case 3: Some{queue(~S,state,1,99)}
    case 4: Some{queue(~S,state,2,1)}
    case 5: fast(~S,state,False{})
    case 6: slow(~S,state,False{})
    case 7: Some{barrier(~S,state)}
    case 8: fast(~S,state,False{})
    case 9: slow(~S,state,True{})
    case 10: slow(~S,state,False{})
    case 11: fast(~S,state,False{})
    case _: Some{frame(~S,state)}

def steps(~S: Data,remaining: List<&2,U32>,state: Maybe<Driven<S>>) -> Maybe<Driven<S>>:
  match remaining state:
    case [] state: state
    case step <> rest Some{state}: steps(~S,rest,execute_step(~S,step,state))
    case _ None{}: None{}

def registered(~S: Data,result: P.PairStart<S>) -> Maybe<Driven<S>>:
  match result:
    case P.PairReady{pair}: steps(~S,[0,1,2,3,4,5,6,7,8,9,10,11,12,12],Some{Driven{pair,[]}})
    case _: None{}

def started(~S: Data,result: A.Start<S>) -> Maybe<Driven<S>>:
  match result:
    case A.Started{runtime}: registered(~S,P.register(~S,runtime))
    case _: None{}

def application(~S: Data) -> Maybe<Driven<S>>:
  started(~S,A.seeded(~S,W.create(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~A.empty(~S),W.factory(),A.Resources{ANode{ALeaf{301},ALeaf{302}},[]})))
