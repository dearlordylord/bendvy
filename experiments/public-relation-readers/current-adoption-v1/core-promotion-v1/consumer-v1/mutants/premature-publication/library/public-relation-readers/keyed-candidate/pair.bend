import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/premature-publication/library/public-relation-readers/keyed-candidate/application.bend as A
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/premature-publication/core/relation-failure-runtime.bend as K
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/premature-publication/core/relation-failure-reader.bend as Decl
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/internal/relation-failures/readings.bend as Read
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/relation-commands.bend as RC
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/world.bend as W

type OwnedReaders<S: Data> is Type:
  OwnedReaders{runtime: K.Runtime<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>,fast: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,slow: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,fastPrivate: Array<U32>,slowPrivate: Array<U32>}
type PairStart<S: Data> is Type:
  PairReady{pair: OwnedReaders<S>}
  PairRejected{runtime: K.Runtime<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>}

def slow_registered(~S: Data,result: K.Registered<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>,fast: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>) -> PairStart<S>:
  match result:
    case K.RegistrationFailed{runtime}: PairRejected{runtime}
    case K.Registered{runtime,slow}: PairReady{OwnedReaders{runtime,fast,slow,ANode{ALeaf{101},ALeaf{102}},ANode{ALeaf{201},ALeaf{202}}}}

def fast_registered(~S: Data,result: K.Registered<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,A.ReaderArgs,U32,Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,A.reader(~S)>) -> PairStart<S>:
  match result:
    case K.RegistrationFailed{runtime}: PairRejected{runtime}
    case K.Registered{runtime,fast}: slow_registered(~S,Decl.register(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~A.ReaderArgs,~U32,~(Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>),~A.reader(~S),runtime,[Decl.relation(~S,A.descriptor(~S,1))],"slow"),fast)

def register(~S: Data,runtime: K.Runtime<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>) -> PairStart<S>:
  fast_registered(~S,Decl.register(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~A.ReaderArgs,~U32,~(Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>),~A.reader(~S),runtime,[Decl.relation(~S,A.descriptor(~S,1))],"fast"))
