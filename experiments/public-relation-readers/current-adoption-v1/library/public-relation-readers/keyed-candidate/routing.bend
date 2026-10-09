import Base
import queue.bend as Q
import domains.bend as D
import ../../../../../../src/ecs/world.bend as W

type PendingBatch<S: Data,E: Data> is Data:
  PendingBatch{key: D.DescriptorKey<S>,reversed: List<&2,E>}
type Partition<S: Data,E: Data> is Data:
  Partition{ordinary: List<&2,E>,batches: List<&2,PendingBatch<S,E>>}

def group_found(~S: Data,~E: Data,same: Bool,+key: D.DescriptorKey<S>,items: List<&2,E>,+rest: List<&2,PendingBatch<S,E>>,+item: E,ih: Unit -> List<&2,PendingBatch<S,E>>) -> List<&2,PendingBatch<S,E>>:
  match same:
    case True{}: PendingBatch{key,item <> items} <> rest
    case False{}: PendingBatch{key,items} <> ih(Unit{})

def group(~S: Data,~E: Data,batches: List<&2,PendingBatch<S,E>>,+wanted: D.DescriptorKey<S>,+item: E) -> List<&2,PendingBatch<S,E>>:
  match batches:
    case []: [PendingBatch{wanted,[item]}]
    case PendingBatch{+key,+items} <> +rest: group_found(~S,~E,D.key_equal(~S,key,wanted),key,items,rest,item,_ => group(~S,~E,rest,wanted,item))

def partition_selected(~S: Data,~E: Data,key: Maybe<D.DescriptorKey<S>>,item: E,ordinary: List<&2,E>,batches: List<&2,PendingBatch<S,E>>) -> Partition<S,E>:
  match key:
    case None{}: Partition{item <> ordinary,batches}
    case Some{wanted}: Partition{ordinary,group(~S,~E,batches,wanted,item)}

def partition_loop(~S: Data,~E: Data,~classify: E -> Maybe<D.DescriptorKey<S>>,items: List<&2,E>,acc: Partition<S,E>) -> Partition<S,E>:
  match items acc:
    case Nil{} acc: acc
    case +item <> rest Partition{ordinary,batches}: partition_loop(~S,~E,~classify,rest,partition_selected(~S,~E,classify(item),item,ordinary,batches))

def publish_found(~S: Data,~E: Data,same: Bool,+key: D.DescriptorKey<S>,queue: Q.Queue<E>,ids: List<&2,U32>,+rest: List<&2,D.Domain<S,E>>,tick: Nat,items: List<&2,E>,ih: Unit -> List<&2,D.Domain<S,E>>) -> List<&2,D.Domain<S,E>>:
  match same:
    case True{}: D.Domain{key,Q.publish(~E,queue,tick,items),ids} <> rest
    case False{}: D.Domain{key,queue,ids} <> ih(Unit{})

def publish_one(~S: Data,~E: Data,domains: List<&2,D.Domain<S,E>>,+wanted: D.DescriptorKey<S>,+tick: Nat,+items: List<&2,E>) -> List<&2,D.Domain<S,E>>:
  match domains:
    case []: [D.Domain{wanted,Q.publish(~E,Q.empty(~E),tick,items),[]}]
    case D.Domain{+key,+queue,+ids} <> +rest: publish_found(~S,~E,D.key_equal(~S,key,wanted),key,queue,ids,rest,tick,items,_ => publish_one(~S,~E,rest,wanted,tick,items))

def publish_batches(~S: Data,~E: Data,batches: List<&2,PendingBatch<S,E>>,+tick: Nat,domains: List<&2,D.Domain<S,E>>) -> List<&2,D.Domain<S,E>>:
  match batches:
    case []: domains
    case PendingBatch{key,reversed} <> rest: publish_batches(~S,~E,rest,tick,publish_one(~S,~E,domains,key,tick,List.reverse(&2,E,reversed)))

def collected(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,partition: Partition<S,E>,tick: Nat,domains: List<&2,D.Domain<S,E>>) -> W.World<S,C,R,E> & List<&2,D.Domain<S,E>>:
  match partition:
    case Partition{ordinary,batches}: (W.events_replace(~S,~C,~R,~E,world,List.reverse(&2,E,ordinary)),publish_batches(~S,~E,batches,tick,domains))

def collect_view(~S: Data,~C: Type,~R: Type,~E: Data,~classify: E -> Maybe<D.DescriptorKey<S>>,view: W.World<S,C,R,E> & List<&2,E>,tick: Nat,domains: List<&2,D.Domain<S,E>>) -> W.World<S,C,R,E> & List<&2,D.Domain<S,E>>:
  (world,items) = view
  collected(~S,~C,~R,~E,world,partition_loop(~S,~E,~classify,items,Partition{[],[]}),tick,domains)

def collect(~S: Data,~C: Type,~R: Type,~E: Data,~classify: E -> Maybe<D.DescriptorKey<S>>,world: W.World<S,C,R,E>,tick: Nat,domains: List<&2,D.Domain<S,E>>) -> W.World<S,C,R,E> & List<&2,D.Domain<S,E>>:
  collect_view(~S,~C,~R,~E,~classify,W.events_view(~S,~C,~R,~E,world),tick,domains)
