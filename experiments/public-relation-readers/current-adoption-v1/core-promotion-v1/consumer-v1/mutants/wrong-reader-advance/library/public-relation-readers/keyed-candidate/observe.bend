import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/library/public-relation-readers/keyed-candidate/application.bend as A
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/library/public-relation-readers/keyed-candidate/pair.bend as P
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/library/public-relation-readers/keyed-candidate/driven.bend as Drive
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/core/relation-failure-runtime.bend as K
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/internal/relation-failures/domains.bend as D
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/relation-commands.bend as RC
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/event-runtime.bend as Ev

type Final<S: Data> is Data:
  Final{deliveries: List<&2,Drive.Delivery<S>>,domains: List<&2,D.Domain<S,RC.Notice<S,U32>>>,positions: List<&2,Ev.Position>,tick: Nat,frameStart: Nat,boundary: Nat,retentionCapacity: Nat,namespace: U32,nextId: U32,highWater: U32,live: List<&2,Bool>,capacity: U32,depth: Nat,left: List<&2,U32>,right: List<&2,U32>,graph: G.Graph<S>,baseline: List<&2,U32>,returned: List<&2,List<&2,U32>>,events: List<&2,RC.Notice<S,U32>>,pendingCount: Nat,registrations: List<&2,W.RegistrationMeta>,nextSystemId: U32,clock: U32,fastPrivate: List<&2,U32>,slowPrivate: List<&2,U32>}

def bool_cells(array: Array<Bool>) -> List<&2,Bool>:
  match array:
    case ALeaf{value}: [value]
    case ANode{left,right}: List.append(&2,Bool,bool_cells(left),bool_cells(right))

def mailbox(~S: Data,items: List<A.ReturnedPrivate<S>>) -> List<&2,List<&2,U32>>:
  match items:
    case []: []
    case A.ReturnedPrivate{owner,_} <> rest: Drive.cells(owner) <> mailbox(~S,rest)

def pending_count(~S: Data,pending: List<(W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>> -> W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>)>,acc: Nat) -> Nat:
  match pending:
    case []: acc
    case _ <> rest: pending_count(~S,rest,1n+acc)

def observed(~S: Data,state: Maybe<Drive.Driven<S>>) -> Maybe<&2,Final<S>>:
  match state:
    case None{}: None{}
    case Some{Drive.Driven{P.OwnedReaders{K.Runtime{W.World{namespace,nextId,highWater,live,capacity,depth,RC.Store{A.CellOwners{left,right},graph},A.Resources{baseline,returned},events,pending,registrations,nextSystemId,clock},domains,positions,tick,frameStart,boundary,retentionCapacity},_,_,fastPrivate,slowPrivate},deliveries}}: Some{Final{List.reverse(&2,Drive.Delivery<S>,deliveries),domains,positions,tick,frameStart,boundary,retentionCapacity,namespace,nextId,highWater,bool_cells(live),capacity,depth,Drive.cells(left),Drive.cells(right),graph,Drive.cells(baseline),mailbox(~S,returned),events,pending_count(~S,pending,0n),registrations,nextSystemId,clock,Drive.cells(fastPrivate),Drive.cells(slowPrivate)}}

def main() -> Maybe<&2,Final<A.ReadersAlpha>> & Maybe<&2,Final<A.ReadersBeta>>:
  (observed(~A.ReadersAlpha,Drive.application(~A.ReadersAlpha)),observed(~A.ReadersBeta,Drive.application(~A.ReadersBeta)))
