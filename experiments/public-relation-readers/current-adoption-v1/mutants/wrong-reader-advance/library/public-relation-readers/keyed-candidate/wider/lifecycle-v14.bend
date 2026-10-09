import Base
import ../application.bend as A
import application-v14.bend as Wide
import disposal-v14.bend as Dispose
import ../../../../../../../../../src/ecs/system.bend as Sy
import observe-v14.bend as Observe
import ../../../../../../../../../src/ecs/schedule.bend as Sch
import ../driven.bend as Drive
import runtime-v14.bend as K
import ../domains.bend as D
import ../readings.bend as Read
import ../../../../../../../../../src/ecs/world.bend as W
import ../../../../../../../../../src/ecs/relation-commands.bend as RC
import ../../../../../../../../../src/ecs/relation-types.bend as G
import ../../../../../../../../../src/ecs/event-runtime.bend as Ev


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

def snapshot(~S: Data,runtime: Wide.Runtime(~S),alphaPrivate: List<&2,U32>,betaPrivate: List<&2,U32>,bothPrivate: List<&2,U32>,deliveries: List<&2,List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>) -> Maybe<&2,Observe.Final<S>>:
  match runtime:
    case K.Runtime{W.World{namespace,nextId,highWater,live,capacity,depth,RC.Store{A.CellOwners{left,right},graph},A.Resources{baseline,returned},events,pending,registrations,nextSystemId,clock},domains,positions,tick,frameStart,boundary,retentionCapacity}: Some{Observe.Final{List.reverse(&2,List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>,deliveries),domains,positions,tick,frameStart,boundary,retentionCapacity,namespace,nextId,highWater,bool_cells(live),capacity,depth,Drive.cells(left),Drive.cells(right),graph,Drive.cells(baseline),mailbox(~S,returned),events,pending_count(~S,pending,0n),registrations,nextSystemId,clock,alphaPrivate,betaPrivate,bothPrivate}}

def seed(~S: Data) -> Maybe<Wide.WideApp<S>>:
  Wide.seeded(~S,A.seeded(~S,W.create(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~A.empty(~S),W.factory(),A.Resources{ANode{ALeaf{301},ALeaf{302}},[]})))

def skip_restore(~S: Data,result: Wide.Runtime(~S) & Wide.Reader(~S),private: Array<U32>,beta: Wide.Slot<S>,both: Wide.Slot<S>,deliveries: List<&2,List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>) -> Maybe<Wide.WideApp<S>>:
  (runtime,reader) = result
  Some{Wide.WideApp{runtime,Wide.Slot{reader,private},beta,both,deliveries}}

def skipped(~S: Data,app: Maybe<Wide.WideApp<S>>) -> Maybe<Wide.WideApp<S>>:
  match app:
    case None{}: None{}
    case Some{Wide.WideApp{runtime,Wide.Slot{reader,private},beta,both,deliveries}}: skip_restore(~S,K.skip(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~Array<U32>,~U32,~Wide.Output(~S),~Wide.body(~S),runtime,reader),private,beta,both,deliveries)

def disposal_result(~S: Data,result: Dispose.Disposal<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,Array<U32>,U32,Wide.Output(~S),Wide.body(~S)>,alphaPrivate: List<&2,U32>,beta: Wide.Slot<S>,both: Wide.Slot<S>,deliveries: List<&2,List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>) -> Maybe<&2,Observe.Final<S>>:
  match result beta both:
    case Dispose.ReaderDisposed{runtime} Wide.Slot{_,betaPrivate} Wide.Slot{_,bothPrivate}: snapshot(~S,runtime,alphaPrivate,Drive.cells(betaPrivate),Drive.cells(bothPrivate),deliveries)
    case Dispose.ReaderDisposalRejected{_,_} _ _: None{}

def disposed(~S: Data,app: Maybe<Wide.WideApp<S>>) -> Maybe<&2,Observe.Final<S>>:
  match app:
    case None{}: None{}
    case Some{Wide.WideApp{runtime,Wide.Slot{reader,private},beta,both,deliveries}}: disposal_result(~S,Dispose.dispose(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~Array<U32>,~U32,~Wide.Output(~S),~Wide.body(~S),runtime,reader),Drive.cells(private),beta,both,deliveries)

type Owners<S: Data> is Type:
  Owners{domains: List<&2,D.Domain<S,RC.Notice<S,U32>>>,positions: List<&2,Ev.Position>,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat,alpha: Wide.Slot<S>,beta: Wide.Slot<S>,both: Wide.Slot<S>,deliveries: List<&2,List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>}
type Scheduled<S: Data> is Data:
  Scheduled{final: Maybe<&2,Observe.Final<S>>,observations: List<&2,Sch.Observation>}

def false_condition(~S: Data,world: Wide.World(~S),_: U32) -> Wide.World(~S) & Bool:
  (world,False{})
# This fixture has only a false condition. Any attempted dispatch is an error,
# preserved by the real scheduler as Failed rather than silently accepted.
def unexpected_dispatch(~S: Data,owners: Owners<S>,world: Wide.World(~S),_: U32) -> Owners<S> & Sy.Outcome<Wide.World(~S),U32,Unit>:
  (owners,Sy.Failed{world,999})

def skip_rejoined(~S: Data,joined: Wide.Runtime(~S) & Wide.Reader(~S),private: Array<U32>,beta: Wide.Slot<S>,both: Wide.Slot<S>,deliveries: List<&2,List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>) -> Owners<S> & Wide.World(~S):
  match joined:
    case (K.Runtime{world,domains,positions,tick,frameStart,boundary,capacity},reader): (Owners{domains,positions,tick,frameStart,boundary,capacity,Wide.Slot{reader,private},beta,both,deliveries},world)

def registered_skip(~S: Data,owners: Owners<S>,world: Wide.World(~S),_: U32) -> Owners<S> & Wide.World(~S):
  match owners:
    case Owners{domains,positions,tick,frameStart,boundary,capacity,Wide.Slot{reader,private},beta,both,deliveries}: skip_rejoined(~S,K.skip(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~Array<U32>,~U32,~Wide.Output(~S),~Wide.body(~S),K.Runtime{world,domains,positions,tick,frameStart,boundary,capacity},reader),private,beta,both,deliveries)

def schedule_finished(~S: Data,result: Sch.RunResult<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,Owners<S>,U32>) -> Scheduled<S>:
  match result:
    case Sch.Finished{Sch.Schedule{_,_,_,Owners{domains,positions,tick,frameStart,boundary,capacity,alpha,beta,both,deliveries}},world,observations}: Scheduled{Observe.observed(~S,Some{Wide.WideApp{K.Runtime{world,domains,positions,tick,frameStart,boundary,capacity},alpha,beta,both,deliveries}}),observations}
    case Sch.Failed{_,_,_,observations}: Scheduled{None{},observations}
    case Sch.Rejected{_,_}: Scheduled{None{},[]}

def schedule_built(~S: Data,built: Sch.Build<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,Owners<S>>,world: Wide.World(~S)) -> Scheduled<S>:
  match built:
    case Sch.Invalid{_}: Scheduled{None{},[]}
    case Sch.Built{schedule}: schedule_finished(~S,Sch.run_with_skip(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~Owners<S>,~U32,~registered_skip(~S),~unexpected_dispatch(~S),~false_condition(~S),schedule,world))

def schedule_named(~S: Data,named: Wide.World(~S) & U32,owners: Owners<S>) -> Scheduled<S>:
  (world,namespace) = named
  schedule_built(~S,Sch.build(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~Owners<S>,namespace,"false-alpha",[Sch.System{1,0}],[1],owners),world)

def scheduled(~S: Data,app: Maybe<Wide.WideApp<S>>) -> Scheduled<S>:
  match app:
    case None{}: Scheduled{None{},[]}
    case Some{Wide.WideApp{K.Runtime{world,domains,positions,tick,frameStart,boundary,capacity},alpha,beta,both,deliveries}}: schedule_named(~S,W.namespace(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,world),Owners{domains,positions,tick,frameStart,boundary,capacity,alpha,beta,both,deliveries})

type Cases<S: Data> is Data:
  Cases{neverActivatedSkip: Scheduled<S>,activatedSkip: Scheduled<S>,successfulDisposal: Maybe<&2,Observe.Final<S>>}

def cases(~S: Data) -> Cases<S>:
  Cases{scheduled(~S,seed(~S)),scheduled(~S,Wide.application(~S,3n)),disposed(~S,Wide.application(~S,3n))}

def main() -> Cases<A.ReadersAlpha> & Cases<A.ReadersBeta>:
  (cases(~A.ReadersAlpha),cases(~A.ReadersBeta))
