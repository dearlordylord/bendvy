import Base
import runtime-v14.bend as K
import ../domains.bend as D
import ../../../../../../../../../src/ecs/world.bend as W
import ../../../../../../../../../src/ecs/system.bend as Sy
import ../../../../../../../../../src/ecs/event-runtime.bend as Ev

# Supplemental owned Bend contract: pinned TS has no public unregister method.
# Release stream membership only after actual successful Sy.dispose.
type Disposal<S: Data,C: Type,R: Type,E: Data,A: Type,Error: Data,O: Type,-runner: W.World<S,C,R,E> -> K.Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>> is Type:
  ReaderDisposed{runtime: K.Runtime<S,C,R,E>}
  ReaderDisposalRejected{runtime: K.Runtime<S,C,R,E>,reader: K.Reader<S,C,R,E,A,Error,O,runner>}

def keep(found: Bool,id: U32,rest: List<&2,U32>) -> List<&2,U32>:
  match found:
    case True{}: rest
    case False{}: id <> rest

def remove(ids: List<&2,U32>,+wanted: U32) -> List<&2,U32>:
  match ids:
    case []: []
    case +id <> rest: keep(U32.is_eq(id,wanted),id,remove(rest,wanted))

def release(~S: Data,~E: Data,domains: List<&2,D.Domain<S,E>>,+id: U32) -> List<&2,D.Domain<S,E>>:
  match domains:
    case []: []
    case D.Domain{key,queue,ids} <> rest: D.Domain{key,queue,remove(ids,id)} <> release(~S,~E,rest,id)

def completed(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> K.Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,result: Sy.Disposal<S,C,R,E,K.Input<S,E,A>,Error,O,runner>,keys: List<&2,D.DescriptorKey<S>>,domains: List<&2,D.Domain<S,E>>,positions: List<&2,Ev.Position>,+id: U32,+tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat) -> Disposal<S,C,R,E,A,Error,O,runner>:
  match result:
    case Sy.Disposed{world}: ReaderDisposed{K.Runtime{world,release(~S,~E,domains,id),Ev.update(positions,id,tick,True{}),tick,frameStart,boundary,capacity}}
    case Sy.DisposalRejected{world,registry}: ReaderDisposalRejected{K.Runtime{world,domains,positions,tick,frameStart,boundary,capacity},K.Reader{registry,keys}}

def identified(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> K.Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: K.Runtime<S,C,R,E>,identity: Sy.Registry<S,C,R,E,K.Input<S,E,A>,Error,O,runner> & U32,keys: List<&2,D.DescriptorKey<S>>) -> Disposal<S,C,R,E,A,Error,O,runner>:
  match runtime:
    case K.Runtime{world,domains,positions,tick,frameStart,boundary,capacity}:
      (registry,+id) = identity
      completed(~S,~C,~R,~E,~A,~Error,~O,~runner,Sy.dispose(~S,~C,~R,~E,~K.Input<S,E,A>,~Error,~O,~runner,registry,world),keys,domains,positions,id,tick,frameStart,boundary,capacity)

def dispose(~S: Data,~C: Type,~R: Type,~E: Data,~A: Type,~Error: Data,~O: Type,~runner: W.World<S,C,R,E> -> K.Input<S,E,A> -> Sy.Outcome<W.World<S,C,R,E>,Error,O>,runtime: K.Runtime<S,C,R,E>,reader: K.Reader<S,C,R,E,A,Error,O,runner>) -> Disposal<S,C,R,E,A,Error,O,runner>:
  match reader:
    case K.Reader{registry,keys}: identified(~S,~C,~R,~E,~A,~Error,~O,~runner,runtime,Sy.identity(~S,~C,~R,~E,~K.Input<S,E,A>,~Error,~O,~runner,registry),keys)
