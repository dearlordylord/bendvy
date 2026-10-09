import Base
import ../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../../src/ecs/transaction.bend as Cmd
import ../../../../../../../src/ecs/commands.bend as Commands
import ../application.bend as Schemas
import ../domains.bend as D
import ../readings.bend as Read
import runtime-v14.bend as K
import mixed-components-v13.bend as M
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/system.bend as Sy
import ../../../../../../../src/ecs/component.bend as C
import ../../../../../../../src/ecs/lifecycle.bend as L
import ../../../../../../../src/ecs/relation-types.bend as G
import ../../../../../../../src/ecs/relation-commands.bend as RC
import ../../../../../../../src/ecs/event-runtime.bend as Ev
import ../../../../../../../src/ecs/removals.bend as Rm
import ../../../../../../../src/ecs/reader-domains.bend as ED

type ClockMark is Data:
  ClockMark{stage: String,relationTick: Nat,worldClock: U32,stamp: L.Stamp,component: C.Access<List<&2,U32>>,cursor: Maybe<&2,U32>,added: Maybe<&2,Bool>,changed: Maybe<&2,Bool>}

type Args is Type:
  Args{private: Array<U32>,cursor: U32}
def Runtime(~S: Data) -> Type: K.Runtime<S,M.Store(~S),Array<U32>,M.Notice(~S)>
def Output(~S: Data) -> Type: Array<U32> & (List<&2,Read.KeyReading<S,M.Notice(~S)>> & ClockMark)
# Complete public component + stamp projections consume and return World.
def marked_clock(~S: Data,clocked: M.World(~S) & U32,stage: String,tick: Nat,stamp: L.Stamp,component: C.Access<List<&2,U32>>) -> M.World(~S) & ClockMark:
  (world,clock) = clocked
  (world,ClockMark{stage,tick,clock,stamp,component,None{},None{},None{}})
def marked_stamp(~S: Data,stamped: M.World(~S) & L.Stamp,stage: String,tick: Nat,component: C.Access<List<&2,U32>>) -> M.World(~S) & ClockMark:
  (world,stamp) = stamped
  marked_clock(~S,W.clock(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),world),stage,tick,stamp,component)
def marked_get(~S: Data,observed: M.World(~S) & C.Access<List<&2,U32>>,+handle: W.Handle<S>,stage: String,tick: Nat) -> M.World(~S) & ClockMark:
  (world,component) = observed
  marked_stamp(~S,M.lifecycle(~S,world,handle),stage,tick,component)
def marked_named(~S: Data,named: M.World(~S) & U32,stage: String,tick: Nat) -> M.World(~S) & ClockMark:
  (world,+namespace) = named
  marked_get(~S,M.get(~S,world,W.Handle{namespace,1}),W.Handle{namespace,1},stage,tick)
def captured(~S: Data,marked: M.World(~S) & ClockMark,+cursor: U32,private: Array<U32>,readings: List<&2,Read.KeyReading<S,M.Notice(~S)>>) -> Sy.Outcome<M.World(~S),U32,Output(~S)>:
  match marked:
    case (world,ClockMark{stage,tick,+clock,+stamp,component,_,_,_}): Sy.Succeeded{world,(private,(readings,ClockMark{stage,U32.to_nat(clock),clock,stamp,component,Some{cursor},Some{L.added(stamp,cursor)},Some{L.changed(stamp,cursor)}}))}
def body(~S: Data,world: M.World(~S),input: K.Input<S,M.Notice(~S),Args>) -> Sy.Outcome<M.World(~S),U32,Output(~S)>:
  match input:
    case K.Input{readings,Args{private,cursor}}: captured(~S,marked_named(~S,W.namespace(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),world),"registered",0n),cursor,private,readings)
def Reader(~S: Data) -> Type: K.Reader<S,M.Store(~S),Array<U32>,M.Notice(~S),Args,U32,Output(~S),body(~S)>
type State<S: Data> is Type:
  State{runtime: Runtime(~S),reader: Reader(~S),private: Array<U32>,deliveries: List<&2,List<&2,Read.KeyReading<S,M.Notice(~S)>>>,marks: List<&2,ClockMark>}
def descriptor(~S: Data) -> G.Descriptor<S>:
  G.Descriptor{1,"Parent","Children",G.Hierarchy{}}
def classify(~S: Data,notice: M.Notice(~S)) -> Maybe<D.DescriptorKey<S>>:
  match notice:
    case RC.RelationFailed{G.Failure{G.Descriptor{key,_,_,_},_,_,_,_}}: Some{D.DeclaredKey{key}}
    case _: None{}
def registered(~S: Data,result: K.Registered<S,M.Store(~S),Array<U32>,M.Notice(~S),Args,U32,Output(~S),body(~S)>) -> Maybe<State<S>>:
  match result:
    case K.Registered{runtime,reader}: Some{State{runtime,reader,ANode{ALeaf{501},ALeaf{502}},[],[]}}
    case _: None{}
def completed(~S: Data,result: K.RunResult<S,M.Store(~S),Array<U32>,M.Notice(~S),Args,U32,Output(~S),body(~S)>,deliveries: List<&2,List<&2,Read.KeyReading<S,M.Notice(~S)>>>,marks: List<&2,ClockMark>) -> Maybe<State<S>>:
  match result:
    case K.Ran{runtime,reader,K.Succeeded{(private,(readings,capture))}}: Some{State{runtime,reader,private,readings <> deliveries,capture <> marks}}
    case _: None{}
def run_cursor(~S: Data,runtime: Runtime(~S),identified: Sy.Registry<S,M.Store(~S),Array<U32>,M.Notice(~S),K.Input<S,M.Notice(~S),Args>,U32,Output(~S),body(~S)> & U32,keys: List<&2,D.DescriptorKey<S>>,private: Array<U32>,deliveries: List<&2,List<&2,Read.KeyReading<S,M.Notice(~S)>>>,marks: List<&2,ClockMark>) -> Maybe<State<S>>:
  (registry,cursor) = identified
  completed(~S,K.run(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~Args,~U32,~Output(~S),~body(~S),~classify(~S),runtime,K.Reader{registry,keys},Args{private,cursor}),deliveries,marks)
def run(~S: Data,state: Maybe<State<S>>) -> Maybe<State<S>>:
  match state:
    case None{}: None{}
    case Some{State{runtime,K.Reader{registry,keys},private,deliveries,marks}}: run_cursor(~S,runtime,Sy.cursor(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~K.Input<S,M.Notice(~S),Args>,~U32,~Output(~S),~body(~S),registry),keys,private,deliveries,marks)

def mark_restore(~S: Data,marked: M.World(~S) & ClockMark,domains: List<&2,D.Domain<S,M.Notice(~S)>>,positions: List<&2,Ev.Position>,tick: Nat,start: Nat,boundary: Nat,capacity: Nat,reader: Reader(~S),private: Array<U32>,deliveries: List<&2,List<&2,Read.KeyReading<S,M.Notice(~S)>>>,marks: List<&2,ClockMark>) -> Maybe<State<S>>:
  (world,mark) = marked
  Some{State{K.Runtime{world,domains,positions,tick,start,boundary,capacity},reader,private,deliveries,mark <> marks}}
def mark(~S: Data,state: Maybe<State<S>>,stage: String) -> Maybe<State<S>>:
  match state:
    case None{}: None{}
    case Some{State{K.Runtime{world,domains,positions,+tick,start,boundary,capacity},reader,private,deliveries,marks}}: mark_restore(~S,marked_named(~S,W.namespace(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),world),stage,tick),domains,positions,tick,start,boundary,capacity,reader,private,deliveries,marks)

def replaced(~S: Data,result: C.Replacement<M.World(~S),M.Payload>) -> M.World(~S) & Bool:
  match result:
    case C.Replaced{world,None{}}: (world,True{})
    case C.Replaced{world,Some{_}}: (world,False{})
    case C.ReplaceRejected{world,_,_}: (world,False{})
def insert_named(~S: Data,named: M.World(~S) & U32) -> M.World(~S) & Bool:
  (world,namespace) = named
  replaced(~S,M.replace(~S,world,W.Handle{namespace,1},Some{M.Payload{ANode{ANode{ALeaf{11},ALeaf{12}},ANode{ALeaf{13},ALeaf{14}}}}}))
def insert(~S: Data,world: M.World(~S)) -> M.World(~S) & Bool:
  insert_named(~S,W.namespace(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),world))
def inserted(~S: Data,result: Runtime(~S) & Bool,reader: Reader(~S),private: Array<U32>,deliveries: List<&2,List<&2,Read.KeyReading<S,M.Notice(~S)>>>,marks: List<&2,ClockMark>) -> Maybe<State<S>>:
  match result:
    case (runtime,True{}): Some{State{runtime,reader,private,deliveries,marks}}
    case (runtime,False{}): None{}
def insertion(~S: Data,state: Maybe<State<S>>) -> Maybe<State<S>>:
  match state:
    case None{}: None{}
    case Some{State{runtime,reader,private,deliveries,marks}}: inserted(~S,K.with_world(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~Bool,~classify(~S),insert(~S),runtime),reader,private,deliveries,marks)

def queue_finished(~S: Data,result: Cmd.Returned<M.World(~S),U32>,status: RC.QueueStatus) -> M.World(~S) & RC.QueueStatus:
  match result:
    case Cmd.Returned{world,_}: (world,status)
def queue_done(~S: Data,result: Tx.Tx<M.World(~S),M.Notice(~S)> & RC.QueueStatus) -> M.World(~S) & RC.QueueStatus:
  (tx,status) = result
  queue_finished(~S,Commands.tx_finish(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~U32,tx,Tx.Success{}),status)
def queued_commands(~S: Data,result: M.World(~S) & RC.QueueStatus,+namespace: U32) -> M.World(~S) & RC.QueueStatus:
  (world,status) = result
  (M.enqueue_clear(~S,W.enqueue(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),world,w => W.event_publish(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),w,[RC.Original{M.Ordinary{31}},RC.Original{M.Ordinary{32}}])),W.Handle{namespace,1}),status)
def queue_named(~S: Data,named: M.World(~S) & U32) -> M.World(~S) & RC.QueueStatus:
  (world,+namespace) = named
  queued_commands(~S,queue_done(~S,RC.queue_relate(~S,~M.Cells<S>,~Array<U32>,~M.Message<S>,Tx.begin(~M.World(~S),~M.Notice(~S),world),descriptor(~S),W.Handle{namespace,1},W.Handle{namespace,999})),namespace)
def queue(~S: Data,world: M.World(~S)) -> M.World(~S) & RC.QueueStatus:
  queue_named(~S,W.namespace(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),world))
def publication_done(~S: Data,result: Runtime(~S) & RC.QueueStatus,reader: Reader(~S),private: Array<U32>,deliveries: List<&2,List<&2,Read.KeyReading<S,M.Notice(~S)>>>,marks: List<&2,ClockMark>) -> Maybe<State<S>>:
  match result:
    case (runtime,RC.Queued{}): Some{State{K.barrier(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~classify(~S),runtime),reader,private,deliveries,marks}}
    case (_, _): None{}
def publication(~S: Data,state: Maybe<State<S>>) -> Maybe<State<S>>:
  match state:
    case None{}: None{}
    case Some{State{runtime,reader,private,deliveries,marks}}: publication_done(~S,K.with_world(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~RC.QueueStatus,~classify(~S),queue(~S),runtime),reader,private,deliveries,marks)

def activated(~S: Data,result: M.World(~S) & W.Status) -> Maybe<State<S>>:
  (world,_) = result
  registered(~S,K.register(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~Args,~U32,~Output(~S),~body(~S),K.start(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),world),[D.DeclaredKey{1}],"relation",[]))
def reserved(~S: Data,result: M.World(~S) & W.Reservation<S>) -> Maybe<State<S>>:
  match result:
    case (world,W.Reserved{handle}): activated(~S,W.activate(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),world,handle))
    case (_, _): None{}
def seeded(~S: Data,created: W.Creation<S,M.Store(~S),Array<U32>,M.Notice(~S)>) -> Maybe<State<S>>:
  match created:
    case W.Created{_,world}: reserved(~S,W.reserve_id(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),world))
    case _: None{}
def initial(~S: Data) -> Maybe<State<S>>:
  seeded(~S,W.create(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~M.empty(~S),W.factory(),ANode{ALeaf{301},ALeaf{302}}))
def inserted_application(~S: Data) -> Maybe<State<S>>:
  mark(~S,insertion(~S,mark(~S,run(~S,initial(~S)),"activated")),"inserted")
def application(~S: Data) -> Maybe<State<S>>:
  mark(~S,run(~S,publication(~S,run(~S,run(~S,inserted_application(~S))))),"published")

type ColumnSnapshot is Data:
  ColumnSnapshot{values: List<&2,Maybe<&2,List<&2,U32>>>,stamps: List<&2,L.Entry>}
type RegistrySnapshot is Data:
  RegistrySnapshot{namespace: U32,id: U32,name: String,access: List<&2,String>,cursor: U32}
type RemovalSnapshot is Data:
  RemovalSnapshot{namespace: U32,id: U32,name: String,cursor: Nat}
type Held<S: Data> is Type:
  Held{domains: List<&2,D.Domain<S,M.Notice(~S)>>,positions: List<&2,Ev.Position>,tick: Nat,start: Nat,boundary: Nat,capacity: Nat,reader: Reader(~S),private: Array<U32>,deliveries: List<&2,List<&2,Read.KeyReading<S,M.Notice(~S)>>>,marks: List<&2,ClockMark>,beforePartition: List<&2,M.Notice(~S)>}
type Final<S: Data> is Data:
  Final{marks: List<&2,ClockMark>,deliveries: List<&2,List<&2,Read.KeyReading<S,M.Notice(~S)>>>,relationDomains: List<&2,D.Domain<S,M.Notice(~S)>>,relationPositions: List<&2,Ev.Position>,relationTick: Nat,relationStart: Nat,relationBoundary: Nat,relationCapacity: Nat,relationRegistry: RegistrySnapshot,relationKeys: List<&2,D.DescriptorKey<S>>,private: List<&2,U32>,beforePartition: List<&2,M.Notice(~S)>,removed: List<&2,Rm.Record<S,M.FamilyTag>>,removalReader: RemovalSnapshot,eventReading: Ev.Reading<M.Notice(~S)>,eventBatches: List<&2,Ev.Batch<M.Notice(~S)>>,eventPositions: List<&2,Ev.Position>,eventTick: Nat,eventStart: Nat,eventBoundary: Nat,eventCapacity: Nat,eventDropped: Nat,eventRegistry: RegistrySnapshot,namespace: U32,nextId: U32,highWater: U32,live: List<&2,Bool>,capacity: U32,depth: Nat,column: Maybe<&2,ColumnSnapshot>,retired: List<&2,List<&2,U32>>,graph: G.Graph<S>,resources: List<&2,U32>,worldEvents: List<&2,M.Notice(~S)>,pendingCount: Nat,registrations: List<&2,W.RegistrationMeta>,nextSystemId: U32,clock: U32}
def cells(array: Array<U32>) -> List<&2,U32>:
  match array:
    case ALeaf{value}: [value]
    case ANode{left,right}: List.append(&2,U32,cells(left),cells(right))
def bool_cells(array: Array<Bool>) -> List<&2,Bool>:
  match array:
    case ALeaf{value}: [value]
    case ANode{left,right}: List.append(&2,Bool,bool_cells(left),bool_cells(right))
def payload(owner: M.Payload) -> List<&2,U32>:
  match owner:
    case M.Payload{values}: cells(values)
def optional(owner: Maybe<&1,M.Payload>) -> Maybe<&2,List<&2,U32>>:
  match owner:
    case None{}: None{}
    case Some{owner}: Some{payload(owner)}
def column_values(values: Array<Maybe<&1,M.Payload>>) -> List<&2,Maybe<&2,List<&2,U32>>>:
  match values:
    case ALeaf{owner}: [optional(owner)]
    case ANode{left,right}: List.append(&2,Maybe<&2,List<&2,U32>>,column_values(left),column_values(right))
def column(~S: Data,owner: Col.Column<S,M.Payload>) -> Maybe<&2,ColumnSnapshot>:
  match owner:
    case Col.Column{values,stamps}: Some{ColumnSnapshot{column_values(values),stamps}}
    case _: None{}
def retired(owners: List<M.Payload>) -> List<&2,List<&2,U32>>:
  match owners:
    case []: []
    case owner <> rest: payload(owner) <> retired(rest)
def pending(~S: Data,commands: List<(M.World(~S) -> M.World(~S))>) -> Nat:
  match commands:
    case []: 0n
    case _ <> rest: 1n+pending(~S,rest)

def consume_removals(~S: Data,records: List<&2,Rm.Record<S,M.FamilyTag>>) -> Result<&2,&1,U32,List<&2,Rm.Record<S,M.FamilyTag>>>:
  Done{records}
def event_body(~S: Data,world: M.World(~S),input: Ev.Input<M.Notice(~S),Unit>) -> Sy.Outcome<M.World(~S),U32,Ev.Reading<M.Notice(~S)>>:
  match input:
    case Ev.Input{values,lagged,_}: Sy.Succeeded{world,Ev.Reading{values,lagged}}

def final(~S: Data,result: Ev.RunResult<S,M.Store(~S),Array<U32>,M.Notice(~S),Unit,U32,Ev.Reading<M.Notice(~S)>,event_body(~S)>,held: Held<S>,removed: List<&2,Rm.Record<S,M.FamilyTag>>,removal: RemovalSnapshot) -> Maybe<&2,Final<S>>:
  match result held:
    case Ev.Ran{Ev.Runtime{W.World{namespace,nextId,highWater,live,capacity,depth,RC.Store{M.Cells{owners,mailbox},graph},resource,worldEvents,commands,registrations,nextSystemId,clock},_,eventBatches,eventPositions,_,eventTick,eventStart,eventBoundary,eventCapacity,eventDropped},_,Sy.Registry{en,ei,ename,eaccess,ecursor},Ev.Succeeded{eventReading}} Held{domains,positions,tick,start,boundary,cap,K.Reader{Sy.Registry{rn,ri,rname,raccess,rcursor},keys},private,deliveries,marks,beforePartition}: Some{Final{List.reverse(&2,ClockMark,marks),List.reverse(&2,List<&2,Read.KeyReading<S,M.Notice(~S)>>,deliveries),domains,positions,tick,start,boundary,cap,RegistrySnapshot{rn,ri,rname,raccess,rcursor},keys,cells(private),beforePartition,removed,removal,eventReading,eventBatches,eventPositions,eventTick,eventStart,eventBoundary,eventCapacity,eventDropped,RegistrySnapshot{en,ei,ename,eaccess,ecursor},namespace,nextId,highWater,bool_cells(live),capacity,depth,column(~S,owners),retired(mailbox),graph,cells(resource),worldEvents,pending(~S,commands),registrations,nextSystemId,clock}}
    case _ _: None{}
def event_registered(~S: Data,result: Ev.Registered<S,M.Store(~S),Array<U32>,M.Notice(~S),Unit,U32,Ev.Reading<M.Notice(~S)>,event_body(~S)>,held: Held<S>,removed: List<&2,Rm.Record<S,M.FamilyTag>>,removal: RemovalSnapshot) -> Maybe<&2,Final<S>>:
  match result:
    case Ev.Registered{runtime,reader,registry}: final(~S,Ev.run(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~Unit,~U32,~Ev.Reading<M.Notice(~S)>,~event_body(~S),runtime,reader,registry,Unit{}),held,removed,removal)
    case _: None{}
def removed(~S: Data,result: Rm.Run<S,M.Store(~S),Array<U32>,M.Notice(~S),M.FamilyTag,M.select_removal(~S),U32,List<&2,Rm.Record<S,M.FamilyTag>>>,events: ED.Events<S,M.Notice(~S)>,held: Held<S>) -> Maybe<&2,Final<S>>:
  match result:
    case Rm.Completed{Rm.Reader{namespace,id,name,cursor},Sy.Succeeded{world,records}}: event_registered(~S,Ev.register(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~Unit,~U32,~Ev.Reading<M.Notice(~S)>,~event_body(~S),ED.attach(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),events,world),"ordinary",[]),held,records,RemovalSnapshot{namespace,id,name,cursor})
    case _: None{}
def removal_registered(~S: Data,result: Rm.Registered<S,M.Store(~S),Array<U32>,M.Notice(~S),M.FamilyTag,M.select_removal(~S)>,events: ED.Events<S,M.Notice(~S)>,held: Held<S>) -> Maybe<&2,Final<S>>:
  match result:
    case Rm.Registered{world,reader}: removed(~S,Rm.run(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~M.FamilyTag,~M.select_removal(~S),~U32,~List<&2,Rm.Record<S,M.FamilyTag>>,~consume_removals(~S),reader,world),events,held)
    case _: None{}
def separated(~S: Data,result: ED.Detached<S,M.Store(~S),Array<U32>,M.Notice(~S)>,held: Held<S>) -> Maybe<&2,Final<S>>:
  match result:
    case ED.Detached{world,events}: removal_registered(~S,Rm.register(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~M.FamilyTag,~M.select_removal(~S),world,"removals"),events,held)
def identity_world(~S: Data,world: M.World(~S)) -> M.World(~S) & Unit:
  (world,Unit{})
def synced(~S: Data,result: Ev.Runtime<S,M.Store(~S),Array<U32>,M.Notice(~S)> & Unit,held: Held<S>) -> Maybe<&2,Final<S>>:
  (runtime,_) = result
  separated(~S,ED.recover(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~M.is_event(~S),runtime,[]),held)
def snapshot(~S: Data,state: Maybe<State<S>>) -> Maybe<&2,Final<S>>:
  match state:
    case None{}: None{}
    case Some{State{K.Runtime{W.World{+namespace,nextId,highWater,live,capacity,depth,store,resource,+events,commands,registrations,nextSystemId,clock},domains,positions,tick,start,boundary,cap},reader,private,deliveries,marks}}: synced(~S,Ev.with_world(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),~Unit,identity_world(~S),Ev.start(~S,~M.Store(~S),~Array<U32>,~M.Notice(~S),W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,commands,registrations,nextSystemId,clock},65536n)),Held{domains,positions,tick,start,boundary,cap,reader,private,deliveries,marks,events})
def main() -> Maybe<&2,Final<Schemas.ReadersAlpha>> & Maybe<&2,Final<Schemas.ReadersBeta>>:
  (snapshot(~Schemas.ReadersAlpha,application(~Schemas.ReadersAlpha)),snapshot(~Schemas.ReadersBeta,application(~Schemas.ReadersBeta)))
