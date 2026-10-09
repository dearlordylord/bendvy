import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/premature-publication/provider.bend as Provider
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/internal/relation-failures/domains.bend as D
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/internal/relation-failures/readings.bend as Read
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/premature-publication/core/relation-failure-runtime.bend as K
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/relation-commands.bend as RC
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/transaction.bend as X
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/system.bend as Sy

type ReadersAlpha is Data: ReadersAlpha{}
type ReadersBeta is Data: ReadersBeta{}
type ReaderArgs is Type:
  ReaderArgs{private: Array<U32>,fail: Bool}
type ReturnedPrivate<S: Data> is Type:
  ReturnedPrivate{private: Array<U32>,readings: List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>}
type Resources<S: Data> is Type:
  Resources{baseline: Array<U32>,returned: List<ReturnedPrivate<S>>}
type CellOwners is Type:
  CellOwners{left: Array<U32>,right: Array<U32>}

def empty(~S: Data,_: Unit) -> RC.Store<S,CellOwners>:
  RC.empty(~S,~CellOwners,CellOwners{ANode{ALeaf{11},ALeaf{12}},ANode{ALeaf{21},ALeaf{22}}})

def classify(~S: Data,notice: RC.Notice<S,U32>) -> Maybe<D.DescriptorKey<S>>:
  match notice:
    case RC.RelationFailed{G.Failure{G.Descriptor{key,_,_,_},_,_,_,_}}: Some{D.DeclaredKey{key}}
    case _: None{}

def descriptor(~S: Data,key: U32) -> G.Descriptor<S>:
  match key:
    case 1: G.Descriptor{1,"Parent","Children",G.Hierarchy{}}
    case _: G.Descriptor{2,"ParentB","ChildrenB",G.Hierarchy{}}

def activated(~S: Data,result: W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>> & W.Status) -> W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>:
  (world,_) = result
  world

def reserved(~S: Data,result: W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>> & W.Reservation<S>) -> W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>:
  match result:
    case (world,W.Reserved{handle}): activated(~S,W.activate(~S,~RC.Store<S,CellOwners>,~Resources<S>,~RC.Notice<S,U32>,world,handle))
    case (world,_): world

type Start<S: Data> is Type:
  Started{runtime: K.Runtime<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>}
  StartRejected{factory: W.Factory,resource: Resources<S>}

def seeded(~S: Data,created: W.Creation<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>) -> Start<S>:
  match created:
    case W.Created{_,world}: Started{K.start(~S,~RC.Store<S,CellOwners>,~Resources<S>,~RC.Notice<S,U32>,reserved(~S,W.reserve_id(~S,~RC.Store<S,CellOwners>,~Resources<S>,~RC.Notice<S,U32>,world)))}
    case W.CreateRejected{factory,resource}: StartRejected{factory,resource}

def queue_finish(~S: Data,result: X.Returned<W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,U32>,status: RC.QueueStatus) -> W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>> & RC.QueueStatus:
  match result:
    case X.Returned{world,_}: (world,status)

def queued(~S: Data,result: X.Tx<W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,RC.Notice<S,U32>> & RC.QueueStatus) -> W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>> & RC.QueueStatus:
  (tx,status) = result
  queue_finish(~S,Cmd.tx_finish(~S,~RC.Store<S,CellOwners>,~Resources<S>,~RC.Notice<S,U32>,~U32,tx,X.Success{}),status)

def queue(~S: Data,+descriptor: G.Descriptor<S>,+source: W.Handle<S>,+target: W.Handle<S>,world: W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>) -> W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>> & RC.QueueStatus:
  queued(~S,RC.queue_relate(~S,~CellOwners,~Resources<S>,~U32,X.begin(~W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,~RC.Notice<S,U32>,world),descriptor,source,target))

# Reader's private affine argument is returned as the actual output on success.
# Failure uses an actual transaction finish; no stream cursor mutation is fabricated.
def read_input(~S: Data,input: K.Input<S,RC.Notice<S,U32>,ReaderArgs>) -> K.Input<S,RC.Notice<S,U32>,ReaderArgs> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>:
  match input:
    case K.Input{+readings,args}: (K.Input{readings,args},readings)

def reader_success_returned(~S: Data,world: W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,result: K.Input<S,RC.Notice<S,U32>,ReaderArgs> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>) -> Sy.Outcome<W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>:
  match result:
    case (K.Input{_,ReaderArgs{args,_}},readings): Sy.Succeeded{world,(args,readings)}

def reader_success(~S: Data,world: W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,input: K.Input<S,RC.Notice<S,U32>,ReaderArgs>) -> Sy.Outcome<W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>:
  reader_success_returned(~S,world,read_input(~S,input))

def returned_args(~S: Data,world: W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,args: Array<U32>,readings: List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>) -> W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,Resources{baseline,returned},events,pending,registrations,nextSystemId,clock}: W.World{namespace,nextId,highWater,live,capacity,depth,store,Resources{baseline,ReturnedPrivate{args,readings} <> returned},events,pending,registrations,nextSystemId,clock}

def reader_failed_finish(~S: Data,returned: X.Returned<W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,U32>,args: Array<U32>,readings: List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>) -> Sy.Outcome<W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>:
  match returned:
    case X.Returned{world,_}: Sy.Failed{returned_args(~S,world,args,readings),77}

def reader_failure(~S: Data,world: W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,input: K.Input<S,RC.Notice<S,U32>,ReaderArgs>) -> Sy.Outcome<W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>:
  match input:
    case K.Input{readings,ReaderArgs{args,_}}: reader_failed_finish(~S,Cmd.tx_finish(~S,~RC.Store<S,CellOwners>,~Resources<S>,~RC.Notice<S,U32>,~U32,X.emit(~W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,~RC.Notice<S,U32>,X.begin(~W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,~RC.Notice<S,U32>,world),RC.Original{999}),X.Failure{77}),args,readings)

def reader_dispatch(~S: Data,fail: Bool,world: W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,readings: List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,private: Array<U32>) -> Sy.Outcome<W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>:
  match fail:
    case False{}: reader_success(~S,world,K.Input{readings,ReaderArgs{private,False{}}})
    case True{}: reader_failure(~S,world,K.Input{readings,ReaderArgs{private,True{}}})

def reader_unwrapped(~S: Data,world: W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,input: K.Input<S,RC.Notice<S,U32>,ReaderArgs>) -> Sy.Outcome<W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>:
  match input:
    case K.Input{readings,ReaderArgs{private,fail}}: reader_dispatch(~S,fail,world,readings,private)

def reader_provided(~S:Data,pair:W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>> & K.Input<S,RC.Notice<S,U32>,ReaderArgs>) -> Sy.Outcome<W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>:
  (world,input) = pair
  reader_unwrapped(~S,world,input)

def reader(~S:Data,world:W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,input:K.Input<S,RC.Notice<S,U32>,ReaderArgs>) -> Sy.Outcome<W.World<S,RC.Store<S,CellOwners>,Resources<S>,RC.Notice<S,U32>>,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>:
  reader_provided(~S,Provider.read(~S,~RC.Store<S,CellOwners>,~Resources<S>,~RC.Notice<S,U32>,~ReaderArgs,world,input))
