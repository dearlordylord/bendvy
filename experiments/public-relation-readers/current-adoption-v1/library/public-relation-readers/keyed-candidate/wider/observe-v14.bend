import Base
import ../application.bend as A
import application-v14.bend as Wide
import ../driven.bend as Drive
import runtime-v14.bend as K
import ../domains.bend as D
import ../readings.bend as Read
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/relation-commands.bend as RC
import ../../../../../../../src/ecs/relation-types.bend as G
import ../../../../../../../src/ecs/event-runtime.bend as Ev

type Final<S: Data> is Data:
  Final{deliveries: List<&2,List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>,domains: List<&2,D.Domain<S,RC.Notice<S,U32>>>,positions: List<&2,Ev.Position>,tick: Nat,frameStart: Nat,boundary: Nat,retentionCapacity: Nat,namespace: U32,nextId: U32,highWater: U32,live: List<&2,Bool>,capacity: U32,depth: Nat,left: List<&2,U32>,right: List<&2,U32>,graph: G.Graph<S>,baseline: List<&2,U32>,returned: List<&2,List<&2,U32>>,events: List<&2,RC.Notice<S,U32>>,pendingCount: Nat,registrations: List<&2,W.RegistrationMeta>,nextSystemId: U32,clock: U32,alphaPrivate: List<&2,U32>,betaPrivate: List<&2,U32>,bothPrivate: List<&2,U32>}

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

def observed(~S: Data,state: Maybe<Wide.WideApp<S>>) -> Maybe<&2,Final<S>>:
  match state:
    case None{}: None{}
    case Some{Wide.WideApp{K.Runtime{W.World{namespace,nextId,highWater,live,capacity,depth,RC.Store{A.CellOwners{left,right},graph},A.Resources{baseline,returned},events,pending,registrations,nextSystemId,clock},domains,positions,tick,frameStart,boundary,retentionCapacity},Wide.Slot{_,alphaPrivate},Wide.Slot{_,betaPrivate},Wide.Slot{_,bothPrivate},deliveries}}: Some{Final{List.reverse(&2,List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,deliveries),domains,positions,tick,frameStart,boundary,retentionCapacity,namespace,nextId,highWater,bool_cells(live),capacity,depth,Drive.cells(left),Drive.cells(right),graph,Drive.cells(baseline),mailbox(~S,returned),events,pending_count(~S,pending,0n),registrations,nextSystemId,clock,Drive.cells(alphaPrivate),Drive.cells(betaPrivate),Drive.cells(bothPrivate)}}

def main() -> Maybe<&2,Final<A.ReadersAlpha>> & Maybe<&2,Final<A.ReadersBeta>>:
  (observed(~A.ReadersAlpha,Wide.application(~A.ReadersAlpha,65537n)),observed(~A.ReadersBeta,Wide.application(~A.ReadersBeta,65537n)))
