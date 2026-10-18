import Base
import queue.bend as Q
import ../../event-runtime.bend as Ev

# Schema-owned descriptor IDs; a key's readers never hold another key's log.
type DescriptorKey<S: Data> is Data:
  DeclaredKey{id: U32}
type Domain<S: Data,E: Data> is Data:
  Domain{key: DescriptorKey<S>,queue: Q.Queue<E>,readers: List<&2,U32>}

def key_equal(~S: Data,left: DescriptorKey<S>,right: DescriptorKey<S>) -> Bool:
  match left right:
    case DeclaredKey{a} DeclaredKey{b}: U32.is_eq(a,b)

def member(ids: List<&2,U32>,+wanted: U32) -> Bool:
  match ids:
    case []: False{}
    case id <> rest: Bool.or(U32.is_eq(id,wanted),member(rest,wanted))

def add_checked(found: Bool,ids: List<&2,U32>,id: U32) -> List<&2,U32>:
  match found:
    case True{}: ids
    case False{}: id <> ids

def add(+ids: List<&2,U32>,+id: U32) -> List<&2,U32>:
  add_checked(member(ids,id),ids,id)

def select_boundary(registered: Bool,+cursor: Nat,boundary: Nat) -> Nat:
  match registered:
    case False{}: boundary
    case True{}: Nat.min(cursor,boundary)

def boundary(positions: List<&2,Ev.Position>,+ids: List<&2,U32>,acc: Nat) -> Nat:
  match positions:
    case []: acc
    case Ev.Position{id,cursor,_} <> rest: boundary(rest,ids,select_boundary(member(ids,id),cursor,acc))

def trim_domain(~S: Data,~E: Data,domain: Domain<S,E>,+positions: List<&2,Ev.Position>,fallback: Nat,capacity: Nat) -> Domain<S,E>:
  match domain:
    case Domain{key,queue,+ids}: Domain{key,Q.trim(~E,queue,boundary(positions,ids,fallback),capacity),ids}

def trim(~S: Data,~E: Data,domains: List<&2,Domain<S,E>>,+positions: List<&2,Ev.Position>,+fallback: Nat,+capacity: Nat) -> List<&2,Domain<S,E>>:
  match domains:
    case []: []
    case domain <> rest: trim_domain(~S,~E,domain,positions,fallback,capacity) <> trim(~S,~E,rest,positions,fallback,capacity)

def activate_domain(~S: Data,~E: Data,same: Bool,domain: Domain<S,E>,id: U32) -> Domain<S,E>:
  match same domain:
    case False{} domain: domain
    case True{} Domain{key,queue,ids}: Domain{key,queue,add(ids,id)}

def activate_walk(~S: Data,~E: Data,same: Bool,domain: Domain<S,E>,+rest: List<&2,Domain<S,E>>,id: U32,ih: Unit -> List<&2,Domain<S,E>>) -> List<&2,Domain<S,E>>:
  match same:
    case True{}: activate_domain(~S,~E,True{},domain,id) <> rest
    case False{}: domain <> ih(Unit{})

def activate_one(~S: Data,~E: Data,domains: List<&2,Domain<S,E>>,+wanted: DescriptorKey<S>,+id: U32) -> List<&2,Domain<S,E>>:
  match domains:
    case []: Domain{wanted,Q.empty(~E),[id]} <> []
    case Domain{+key,+queue,+ids} <> +rest: activate_walk(~S,~E,key_equal(~S,key,wanted),Domain{key,queue,ids},rest,id,_ => activate_one(~S,~E,rest,wanted,id))
