import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/provider.bend as Provider
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/library/public-relation-readers/keyed-candidate/application.bend as A
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/core/relation-failure-reader.bend as Decl
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/internal/relation-failures/readings.bend as Read
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/library/public-relation-readers/keyed-candidate/driven.bend as Old
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/core/relation-failure-runtime.bend as Previous
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/core/relation-failure-runtime.bend as K
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/relation-commands.bend as RC
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/system.bend as Sy

def World(~S: Data) -> Type: W.World<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>
def Runtime(~S: Data) -> Type: K.Runtime<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>
def Output(~S: Data) -> Type: Array<U32> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>
def body_unwrapped(~S: Data,world: World(~S),input: K.Input<S,RC.Notice<S,U32>,Array<U32>>) -> Sy.Outcome<World(~S),U32,Output(~S)>:
  match input:
    case K.Input{readings,private}: Sy.Succeeded{world,(private,readings)}
def body_provided(~S:Data,pair:World(~S) & K.Input<S,RC.Notice<S,U32>,Array<U32>>) -> Sy.Outcome<World(~S),U32,Output(~S)>:
  (world,input) = pair
  body_unwrapped(~S,world,input)

def body(~S:Data,world:World(~S),input:K.Input<S,RC.Notice<S,U32>,Array<U32>>) -> Sy.Outcome<World(~S),U32,Output(~S)>:
  body_provided(~S,Provider.read(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~Array<U32>,world,input))

def Reader(~S: Data) -> Type: K.Reader<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,Array<U32>,U32,Output(~S),body(~S)>
type Slot<S: Data> is Type:
  Slot{reader: Reader(~S),private: Array<U32>}
type WideApp<S: Data> is Type:
  WideApp{runtime: Runtime(~S),alpha: Slot<S>,beta: Slot<S>,both: Slot<S>,deliveries: List<&2,List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>}

def register(~S: Data,runtime: Runtime(~S),declarations: List<&2,Decl.Declaration<S>>,name: String) -> K.Registered<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,Array<U32>,U32,Output(~S),body(~S)>:
  Decl.register(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~Array<U32>,~U32,~Output(~S),~body(~S),runtime,declarations,name)
def third(~S: Data,registered: K.Registered<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,Array<U32>,U32,Output(~S),body(~S)>,alpha: Slot<S>,beta: Slot<S>) -> Maybe<WideApp<S>>:
  match registered:
    case K.Registered{runtime,reader}: Some{WideApp{runtime,alpha,beta,Slot{reader,ANode{ALeaf{701},ALeaf{702}}},[]}}
    case K.RegistrationFailed{_}: None{}
def second(~S: Data,registered: K.Registered<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,Array<U32>,U32,Output(~S),body(~S)>,alpha: Slot<S>) -> Maybe<WideApp<S>>:
  match registered:
    case K.Registered{runtime,reader}: third(~S,register(~S,runtime,[Decl.relation(~S,A.descriptor(~S,1)),Decl.relation(~S,A.descriptor(~S,2))],"both"),alpha,Slot{reader,ANode{ALeaf{601},ALeaf{602}}})
    case K.RegistrationFailed{_}: None{}
def first(~S: Data,registered: K.Registered<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,Array<U32>,U32,Output(~S),body(~S)>) -> Maybe<WideApp<S>>:
  match registered:
    case K.Registered{runtime,reader}: second(~S,register(~S,runtime,[Decl.relation(~S,A.descriptor(~S,2))],"beta"),Slot{reader,ANode{ALeaf{501},ALeaf{502}}})
    case K.RegistrationFailed{_}: None{}
def from_old(~S: Data,old: Previous.Runtime<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>>) -> Maybe<WideApp<S>>:
  match old:
    case Previous.Runtime{world,_,_,_,_,_,_}: first(~S,register(~S,K.start(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,world),[Decl.relation(~S,A.descriptor(~S,1))],"alpha"))
def seeded(~S: Data,start: A.Start<S>) -> Maybe<WideApp<S>>:
  match start:
    case A.Started{runtime}: from_old(~S,runtime)
    case A.StartRejected{_,_}: None{}
def run_slot(~S: Data,runtime: Runtime(~S),slot: Slot<S>) -> K.RunResult<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,Array<U32>,U32,Output(~S),body(~S)>:
  match slot:
    case Slot{reader,private}: K.run(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~Array<U32>,~U32,~Output(~S),~body(~S),~A.classify(~S),runtime,reader,private)
def completed(~S: Data,result: K.RunResult<S,RC.Store<S,A.CellOwners>,A.Resources<S>,RC.Notice<S,U32>,Array<U32>,U32,Output(~S),body(~S)>) -> Maybe<(Runtime(~S) & Slot<S> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>)>:
  match result:
    case K.Ran{runtime,reader,K.Succeeded{(private,readings)}}: Some{(runtime,Slot{reader,private},readings)}
    case K.Ran{_,_,_}: None{}
def restore(~S: Data,done: Maybe<(Runtime(~S) & Slot<S> & List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>)>,first: Slot<S>,second: Slot<S>,deliveries: List<&2,List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>) -> Maybe<WideApp<S>>:
  match done:
    case Some{(runtime,last,readings)}: Some{WideApp{runtime,first,second,last,readings <> deliveries}}
    case None{}: None{}
# Rotate owners: three executions return the original alpha/beta/both ordering.
def next(~S: Data,app: WideApp<S>) -> Maybe<WideApp<S>>:
  match app:
    case WideApp{runtime,alpha,beta,both,deliveries}: restore(~S,completed(~S,run_slot(~S,runtime,alpha)),beta,both,deliveries)
def step(~S: Data,app: Maybe<WideApp<S>>) -> Maybe<WideApp<S>>:
  match app:
    case None{}: None{}
    case Some{app}: next(~S,app)
def queue_result(~S: Data,result: World(~S) & RC.QueueStatus,ih: World(~S) -> World(~S)) -> World(~S):
  (world,_) = result
  ih(world)
def queue_loop(~S: Data,count: Nat,world: World(~S),+namespace: U32,+target: U32) -> World(~S):
  match count:
    case 0n: world
    case 1n+rest: queue_result(~S,A.queue(~S,A.descriptor(~S,2),W.Handle{namespace,1},W.Handle{namespace,target},world),world => queue_loop(~S,rest,world,namespace,(target + 1 : U32)))
def queue_alpha(~S: Data,result: World(~S) & RC.QueueStatus,namespace: U32,count: Nat) -> World(~S):
  (world,_) = result
  queue_loop(~S,count,world,namespace,1000)
def publish_named(~S: Data,named: World(~S) & U32,count: Nat) -> World(~S) & Unit:
  (world,+namespace) = named
  (queue_alpha(~S,A.queue(~S,A.descriptor(~S,1),W.Handle{namespace,1},W.Handle{namespace,1},world),namespace,count),Unit{})
def publish(~S: Data,count: Nat,world: World(~S)) -> World(~S) & Unit:
  publish_named(~S,W.namespace(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,world),count)
def published(~S: Data,result: Runtime(~S) & Unit,alpha: Slot<S>,beta: Slot<S>,both: Slot<S>,deliveries: List<&2,List<&2,Read.KeyReading<S,RC.Notice<S,U32>>>>) -> WideApp<S>:
  (runtime,_) = result
  WideApp{K.frame(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,K.barrier(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~A.classify(~S),runtime)),alpha,beta,both,deliveries}
def publication(~S: Data,app: Maybe<WideApp<S>>,count: Nat) -> Maybe<WideApp<S>>:
  match app:
    case None{}: None{}
    case Some{WideApp{runtime,alpha,beta,both,deliveries}}: Some{published(~S,K.with_world(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~Unit,~A.classify(~S),publish(~S,count),runtime),alpha,beta,both,deliveries)}
def triple(~S: Data,app: Maybe<WideApp<S>>) -> Maybe<WideApp<S>>:
  step(~S,step(~S,step(~S,app)))
def application(~S: Data,count: Nat) -> Maybe<WideApp<S>>:
  triple(~S,publication(~S,triple(~S,seeded(~S,A.seeded(~S,W.create(~S,~RC.Store<S,A.CellOwners>,~A.Resources<S>,~RC.Notice<S,U32>,~A.empty(~S),W.factory(),A.Resources{ANode{ALeaf{301},ALeaf{302}},[]})))),count))
