import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/capacity-v1/main.bend as Full
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/library/public-relation-readers/keyed-candidate/application.bend as Schema
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/library/public-relation-readers/keyed-candidate/observe.bend as Retry
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/library/public-relation-readers/keyed-candidate/foreign.bend as Foreign
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/library/public-relation-readers/keyed-candidate/wider/lifecycle-v14.bend as Lifecycle
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/library/public-relation-readers/keyed-candidate/wider/mixed-clock-v16.bend as Mixed
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/library/public-relation-readers/keyed-candidate/wider/observe-v14.bend as Capacity
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/internal/relation-failures/readings.bend as Read
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/internal/relation-failures/domains.bend as D
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/internal/relation-failures/queue.bend as Q
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/relation-commands.bend as RC
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/world.bend as W

# Sequence is an explicit output transport. Empty remains exact; every
# non-empty power-of-two list uses a balanced Array; other lists remain full
# linked Lists rather than being padded, rounded, or truncated.
type Sequence<T: Data> is Type:
  SeqEmpty{}
  SeqArray{items: Array<T>}
  SeqList{items: List<&2,T>}

type QueueTransport<E: Data> is Type:
  Queue{front: Sequence<Q.Batch<E>>,back: List<&2,Q.Batch<E>>,size: Nat,dropped: Nat}

type DomainTransport<S: Data,E: Data> is Type:
  Domain{key: D.DescriptorKey<S>,queue: QueueTransport<E>,readers: List<&2,U32>}

type ReadingTransport<S: Data,E: Data> is Type:
  KeyReading{key: D.DescriptorKey<S>,values: Sequence<E>,lagged: Bool}

type CapacityTransport<S: Data> is Type:
  Final{deliveries: List<&1,List<&1,ReadingTransport<S,RC.Notice<S,U32>>>>,domains: List<&1,DomainTransport<S,RC.Notice<S,U32>>>,positions: List<&2,Ev.Position>,tick: Nat,frameStart: Nat,boundary: Nat,retentionCapacity: Nat,namespace: U32,nextId: U32,highWater: U32,live: List<&2,Bool>,capacity: U32,depth: Nat,left: List<&2,U32>,right: List<&2,U32>,graph: G.Graph<S>,baseline: List<&2,U32>,returned: List<&2,List<&2,U32>>,events: List<&2,RC.Notice<S,U32>>,pendingCount: Nat,registrations: List<&2,W.RegistrationMeta>,nextSystemId: U32,clock: U32,alphaPrivate: List<&2,U32>,betaPrivate: List<&2,U32>,bothPrivate: List<&2,U32>}

# The two existing observation families together can exceed the stock C
# continuation width. The singleton Array is an explicit box; the inverse
# removes exactly that box and the one grouping constructor.
type LifecycleMixed<S: Data> is Data:
  LifecycleMixed{lifecycle: Lifecycle.Cases<S>,mixed: Maybe<&2,Mixed.Final<S>>}

type Report<S: Data> is Type:
  Report{retry: Maybe<&2,Retry.Final<S>>,foreign: Maybe<&2,Foreign.ForeignResult<S>>,observed: Array<LifecycleMixed<S>>,capacity: Maybe<&1,CapacityTransport<S>>}

type Output is Type:
  Output{alpha: Report<Schema.ReadersAlpha>,beta: Report<Schema.ReadersBeta>}

type Candidate is Type:
  Candidate{result: Maybe<&1,Output>}

def item_count(~T: Data,items: List<&2,T>,acc: Nat) -> Nat:
  match items:
    case []: acc
    case _ <> rest: item_count(~T,rest,1n+acc)

def power_depth_dispatch(remaining: Nat,+size: Nat,+power: Nat,depth: Nat,equal: Bool,less: Bool) -> Maybe<Nat>:
  match remaining equal less:
    case 0n _ _: None{}
    case 1n+rest True{} _: Some{depth}
    case 1n+rest False{} True{}: power_depth_dispatch(rest,size,Nat.double(power),1n+depth,Nat.is_eq(size,Nat.double(power)),Nat.is_lt(Nat.double(power),size))
    case 1n+_ False{} False{}: None{}

def power_depth(+size: Nat,+power: Nat,depth: Nat) -> Maybe<Nat>:
  power_depth_dispatch(size,size,power,depth,Nat.is_eq(size,power),Nat.is_lt(power,size))

def fill_array(~T: Data,remaining: Nat,+index: U32,items: List<&2,T>,array: Array<T>) -> Maybe<Array<T>>:
  match remaining items:
    case 0n Nil{}: Some{array}
    case 1n+rest item <> tail:
      fill_array(~T,rest,U32.add(index,1),tail,Array.set(T,array,index,item))
    case _ _: None{}

def filled_sequence(~T: Data,items: List<&2,T>,filled: Maybe<Array<T>>) -> Sequence<T>:
  match filled:
    case Some{array}: SeqArray{array}
    case None{}: SeqList{items}

def depth_sequence(~T: Data,items: List<&2,T>,count: Nat,rest: List<&2,T>,first: T,depth_result: Maybe<Nat>) -> Sequence<T>:
  match depth_result:
    case Some{depth}: filled_sequence(~T,items,fill_array(~T,Nat.sub(count,1n),1,rest,Array.new(T,depth,first)))
    case None{}: SeqList{items}

def nonempty_sequence(~T: Data,+items: List<&2,T>,+count: Nat) -> Sequence<T>:
  match items:
    case []: SeqEmpty{}
    case first <> rest: depth_sequence(~T,items,count,rest,first,power_depth(count,1n,0n))

def sequence(~T: Data,+items: List<&2,T>) -> Sequence<T>:
  match items:
    case []: SeqEmpty{}
    case _ <> _: nonempty_sequence(~T,items,item_count(~T,items,0n))

def reading(~S: Data,~E: Data,item: Read.KeyReading<S,E>) -> ReadingTransport<S,E>:
  match item:
    case Read.KeyReading{key,values,lagged}:
      KeyReading{key,sequence(~E,values),lagged}

def readings(~S: Data,~E: Data,items: List<&2,Read.KeyReading<S,E>>) -> List<&1,ReadingTransport<S,E>>:
  match items:
    case []: []
    case item <> rest: reading(~S,~E,item) <> readings(~S,~E,rest)

def delivery_rows(~S: Data,~E: Data,items: List<&2,List<&2,Read.KeyReading<S,E>>>) -> List<&1,List<&1,ReadingTransport<S,E>>>:
  match items:
    case []: []
    case row <> rest: readings(~S,~E,row) <> delivery_rows(~S,~E,rest)

def queue_transport(~E: Data,item: Q.Queue<E>) -> QueueTransport<E>:
  match item:
    case Q.Queue{front,back,size,dropped}:
      Queue{sequence(~Q.Batch<E>,front),back,size,dropped}

def domain_transport(~S: Data,~E: Data,item: D.Domain<S,E>) -> DomainTransport<S,E>:
  match item:
    case D.Domain{key,queue,readers}:
      Domain{key,queue_transport(~E,queue),readers}

def domains_transport(~S: Data,~E: Data,items: List<&2,D.Domain<S,E>>) -> List<&1,DomainTransport<S,E>>:
  match items:
    case []: []
    case item <> rest: domain_transport(~S,~E,item) <> domains_transport(~S,~E,rest)

def capacity_transport(~S: Data,item: Capacity.Final<S>) -> CapacityTransport<S>:
  match item:
    case Capacity.Final{deliveries,domains,positions,tick,frameStart,boundary,retentionCapacity,namespace,nextId,highWater,live,capacity,depth,left,right,graph,baseline,returned,events,pendingCount,registrations,nextSystemId,clock,alphaPrivate,betaPrivate,bothPrivate}:
      Final{delivery_rows(~S,~RC.Notice<S,U32>,deliveries),domains_transport(~S,~RC.Notice<S,U32>,domains),positions,tick,frameStart,boundary,retentionCapacity,namespace,nextId,highWater,live,capacity,depth,left,right,graph,baseline,returned,events,pendingCount,registrations,nextSystemId,clock,alphaPrivate,betaPrivate,bothPrivate}

def maybe_capacity(~S: Data,item: Maybe<&2,Capacity.Final<S>>) -> Maybe<&1,CapacityTransport<S>>:
  match item:
    case None{}: None{}
    case Some{capacity}: Some{capacity_transport(~S,capacity)}

def report_retry(~S: Data,item: Full.Report<S>) -> Maybe<&2,Retry.Final<S>>:
  match item:
    case Full.Report{retry,_,_,_,_}: retry

def report_foreign(~S: Data,item: Full.Report<S>) -> Maybe<&2,Foreign.ForeignResult<S>>:
  match item:
    case Full.Report{_,foreign,_,_,_}: foreign

def report_observed(~S: Data,item: Full.Report<S>) -> Array<LifecycleMixed<S>>:
  match item:
    case Full.Report{_,_,lifecycle,mixed,_}:
      Array.new(LifecycleMixed<S>,0n,LifecycleMixed{lifecycle,mixed})

def report_capacity(~S: Data,item: Full.Report<S>) -> Maybe<&1,CapacityTransport<S>>:
  match item:
    case Full.Report{_,_,_,_,capacity}: maybe_capacity(~S,capacity)

def report_transport(~S: Data,+item: Full.Report<S>) -> Report<S>:
  Report{report_retry(~S,item),report_foreign(~S,item),report_observed(~S,item),report_capacity(~S,item)}

def output_transport(item: Full.Output) -> Output:
  match item:
    case Full.Output{alpha,beta}:
      Output{report_transport(~Schema.ReadersAlpha,alpha),report_transport(~Schema.ReadersBeta,beta)}

def maybe_output(item: Maybe<&2,Full.Output>) -> Maybe<&1,Output>:
  match item:
    case None{}: None{}
    case Some{output}: Some{output_transport(output)}

def candidate(item: Full.Candidate) -> Candidate:
  match item:
    case Full.Candidate{result}: Candidate{maybe_output(result)}

def candidates(items: List<&2,Full.Candidate>) -> List<&1,Candidate>:
  match items:
    case []: []
    case item <> rest: candidate(item) <> candidates(rest)

def main() -> List<&1,Candidate>:
  candidates(Full.main())
