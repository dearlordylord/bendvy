import Base
import application.bend as A
import pair.bend as P
import driven.bend as Drive
import observe.bend as Obs
import wider/runtime-v14.bend as K
import readings.bend as Read
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/src/ecs/relation-commands.bend as RC

type ForeignResult<S: Data> is Data:
  ForeignResult{status: RC.QueueStatus,before: U32,after: U32,source: Maybe<&2,Obs.Final<S>>,receiver: Maybe<&2,Obs.Final<S>>}

def result(~S: Data,source: P.OwnedReaders<S>,receiver: Drive.Driven<S>,status: RC.QueueStatus,before: U32,after: U32) -> Maybe<&2,ForeignResult<S>>:
  Some{ForeignResult{status,before,after,Obs.observed(~S,Some{Drive.Driven{source,[]}}),Obs.observed(~S,Some{Drive.barrier(~S,receiver)})}}

type ForeignQueue is Data:
  ForeignQueue{status: RC.QueueStatus,before: U32,after: U32}

def counted_after(~S: Data,counted: W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & U32,status: RC.QueueStatus,before: U32) -> W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & ForeignQueue:
  (world,after) = counted
  (world,ForeignQueue{status,before,after})

def foreign_queued(~S: Data,result: W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & RC.QueueStatus,before: U32) -> W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & ForeignQueue:
  (world,status) = result
  counted_after(~S,W.pending_count(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,world),status,before)

def counted_before(~S: Data,counted: W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & U32,+handle: W.Handle<S>) -> W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & ForeignQueue:
  (world,before) = counted
  foreign_queued(~S,A.queue(~S,A.descriptor(~S,1),handle,handle,world),before)

def queue_foreign(~S: Data,world: W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>,handle: W.Handle<S>) -> W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & ForeignQueue:
  counted_before(~S,W.pending_count(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,world),handle)

def queued(~S: Data,queued: K.Runtime<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> & ForeignQueue,source: P.OwnedReaders<S>,fast: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,slow: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,fp: Array<U32>,sp: Array<U32>) -> Maybe<&2,ForeignResult<S>>:
  match queued:
    case (runtime,ForeignQueue{status,before,after}): result(~S,source,Drive.Driven{P.OwnedReaders{runtime,fast,slow,fp,sp},[]},status,before,after)

def foreign(~S: Data,source: P.OwnedReaders<S>,receiver: Drive.Driven<S>,+handle: W.Handle<S>) -> Maybe<&2,ForeignResult<S>>:
  match receiver:
    case Drive.Driven{P.OwnedReaders{runtime,fast,slow,fp,sp},_}: queued(~S,K.with_world(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~ForeignQueue,~A.classify(~S),world => queue_foreign(~S,world,handle),runtime),source,fast,slow,fp,sp)


def pairs(~S: Data,source: P.PairStart<S>,receiver: P.PairStart<S>) -> Maybe<&2,ForeignResult<S>>:
  match source receiver:
    case P.PairReady{P.OwnedReaders{K.Runtime{W.World{+namespace,nextId,highWater,live,capacity,depth,store,resources,events,pending,registrations,nextSystemId,clock},domains,positions,tick,frameStart,boundary,retentionCapacity},fast,slow,fp,sp}} P.PairReady{receiver}: foreign(~S,P.OwnedReaders{K.Runtime{W.World{namespace,nextId,highWater,live,capacity,depth,store,resources,events,pending,registrations,nextSystemId,clock},domains,positions,tick,frameStart,boundary,retentionCapacity},fast,slow,fp,sp},Drive.queue(~S,Drive.Driven{receiver,[]},1,1),W.Handle{namespace,1})
    case _ _: None{}

def second(~S: Data,created: W.Creation<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>,source: W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>) -> Maybe<&2,ForeignResult<S>>:
  match created:
    case W.Created{_,receiver}: pairs(~S,P.register(~S,K.start(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,A.reserved(~S,W.reserve_id(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,source)))),P.register(~S,K.start(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,A.reserved(~S,W.reserve_id(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,receiver)))))
    case _: None{}

def first(~S: Data,created: W.Creation<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>) -> Maybe<&2,ForeignResult<S>>:
  match created:
    case W.Created{factory,source}: second(~S,W.create(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~A.empty(~S),factory,A.Resources{ANode{ALeaf{301},ALeaf{302}},[]}),source)
    case _: None{}

def application(~S: Data) -> Maybe<&2,ForeignResult<S>>:
  first(~S,W.create(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~A.empty(~S),W.factory(),A.Resources{ANode{ALeaf{301},ALeaf{302}},[]}))

def main() -> Maybe<&2,ForeignResult<A.ReadersAlpha>> & Maybe<&2,ForeignResult<A.ReadersBeta>>:
  (application(~A.ReadersAlpha),application(~A.ReadersBeta))
