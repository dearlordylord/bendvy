import Base
import queue.bend as Q
import domains.bend as D
import ../../../../../../src/ecs/event-runtime.bend as Ev

type KeyReading<S: Data,E: Data> is Data:
  KeyReading{key: D.DescriptorKey<S>,values: List<&2,E>,lagged: Bool}

def queue_reading(~S: Data,~E: Data,key: D.DescriptorKey<S>,queue: Q.Queue<E>,position: Ev.Position) -> KeyReading<S,E>:
  match queue position:
    case Q.Queue{+front,+back,+size,+dropped} Ev.Position{_,+cursor,+registered}: KeyReading{key,Q.read(~E,Q.Queue{front,back,size,dropped},cursor),Nat.is_lt(Nat.max(cursor,registered),dropped)}

def select(~S: Data,~E: Data,same: Bool,key: D.DescriptorKey<S>,queue: Q.Queue<E>,position: Ev.Position,ih: Unit -> KeyReading<S,E>) -> KeyReading<S,E>:
  match same:
    case True{}: queue_reading(~S,~E,key,queue,position)
    case False{}: ih(Unit{})

def one(~S: Data,~E: Data,domains: List<&2,D.Domain<S,E>>,+wanted: D.DescriptorKey<S>,+position: Ev.Position) -> KeyReading<S,E>:
  match domains:
    case []: KeyReading{wanted,[],False{}}
    case D.Domain{+key,queue,_} <> rest: select(~S,~E,D.key_equal(~S,key,wanted),key,queue,position,_ => one(~S,~E,rest,wanted,position))

def all(~S: Data,~E: Data,keys: List<&2,D.DescriptorKey<S>>,+domains: List<&2,D.Domain<S,E>>,+position: Ev.Position) -> List<&2,KeyReading<S,E>>:
  match keys:
    case []: []
    case key <> rest: one(~S,~E,domains,key,position) <> all(~S,~E,rest,domains,position)

def activate(~S: Data,~E: Data,keys: List<&2,D.DescriptorKey<S>>,domains: List<&2,D.Domain<S,E>>,+id: U32) -> List<&2,D.Domain<S,E>>:
  match keys:
    case []: domains
    case key <> rest: activate(~S,~E,rest,D.activate_one(~S,~E,domains,key,id),id)
