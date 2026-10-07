import Base
import types.bend as G
import graph-core.bend as C
import world-adapter.bend as A
import ../../src/ecs/world.bend as W

# Explicit experiment continuation. Exhaustion retains every affine owner/frame.
type CleanupResult<S: Data,C: Type,R: Type,E: Data> is Type:
  Complete{world: W.World<S,A.Store<S,C>,R,A.Notice<S,E>>}
  Incomplete{world: W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,frames: List<&2,G.CleanupFrame<S>>}
def snapshot(~S: Data,~C: Type,store: A.Store<S,C>,descriptor: G.Descriptor<S>,id: U32) -> A.Store<S,C> & List<&2,U32>:
  A.store_inverse(~S,~C,store,descriptor,id)
def clear_join(~S:Data,~C:Type,~E:Data,cleared:C & List<&2,A.Notice<S,E>>,graph:G.Graph<S>) -> A.Store<S,C> & List<&2,A.Notice<S,E>>:
  (components,notices) = cleared
  (A.Store{components,graph},notices)
def clear_store(~S: Data,~C: Type,~E: Data,~clear: C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,store: A.Store<S,C>,handle: W.Handle<S>) -> A.Store<S,C> & List<&2,A.Notice<S,E>>:
  match store:
    case A.Store{components,graph}: clear_join(~S,~C,~E,clear(components,handle),graph)
def publish_final(~S:Data,~C:Type,~R:Type,~E:Data,~record:W.Handle<S> -> A.Notice<S,E>,deactivated:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & W.Status,notices:List<&2,A.Notice<S,E>>,handle:W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  (world,_) = deactivated
  W.event_publish(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,List.append(&2,A.Notice<S,E>,notices,[record(handle)]))
def finalized(~S: Data,~C: Type,~R: Type,~E: Data,~record: W.Handle<S> -> A.Notice<S,E>,cleared: W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,A.Notice<S,E>>,+handle: W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  (world,notices) = cleared
  publish_final(~S,~C,~R,~E,~record,W.deactivate(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,handle),notices,handle)
def finish(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record: W.Handle<S> -> A.Notice<S,E>,world: W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,+handle: W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  finalized(~S,~C,~R,~E,~record,W.with_store(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~List<&2,A.Notice<S,E>>,store => clear_store(~S,~C,~E,~clear,store,handle),world),handle)
def entered(~S: Data,~C: Type,~R: Type,~E: Data,checked: W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Bool,id: U32,descriptors: List<&2,G.Descriptor<S>>,frames: List<&2,G.CleanupFrame<S>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.CleanupFrame<S>>:
  match checked:
    case (world,False{}): (world,frames)
    case (world,True{}): (world,G.CleanupDescriptors{id,descriptors} <> frames)
def children_start(~S: Data,~C: Type,~R: Type,~E: Data,observed: W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,U32>,id: U32,descriptor: G.Descriptor<S>,remaining: List<&2,G.Descriptor<S>>,frames: List<&2,G.CleanupFrame<S>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.CleanupFrame<S>>:
  (world,children) = observed
  (world,G.CleanupChildren{id,descriptor,remaining,children} <> frames)
def child_step(~S: Data,~C: Type,~R: Type,~E: Data,kind: G.RelationKind,world: W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,namespace: U32,id: U32,+descriptor: G.Descriptor<S>,remaining: List<&2,G.Descriptor<S>>,child: U32,children: List<&2,U32>,frames: List<&2,G.CleanupFrame<S>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.CleanupFrame<S>>:
  match kind:
    case G.Hierarchy{}: (world,G.CleanupEnter{child} <> G.CleanupChildren{id,descriptor,remaining,children} <> frames)
    case G.Ordinary{}: (A.apply_unrelate(~S,~C,~R,~E,world,descriptor,W.Handle{namespace,child}),G.CleanupChildren{id,descriptor,remaining,children} <> frames)
def kind(~S: Data,d: G.Descriptor<S>) -> G.RelationKind:
  match d:
    case G.Descriptor{_,_,_,kind}: kind
def step(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record: W.Handle<S> -> A.Notice<S,E>,frame: G.CleanupFrame<S>,world: W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,+namespace: U32,+descriptors: List<&2,G.Descriptor<S>>,frames: List<&2,G.CleanupFrame<S>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.CleanupFrame<S>>:
  match frame:
    case G.CleanupEnter{+id}: entered(~S,~C,~R,~E,W.valid(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,W.Handle{namespace,id}),id,descriptors,frames)
    case G.CleanupDescriptors{id,[]}: (world,G.CleanupFinish{id} <> frames)
    case G.CleanupDescriptors{+id,+d <> remaining}: children_start(~S,~C,~R,~E,W.with_store(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~List<&2,U32>,store => snapshot(~S,~C,store,d,id),world),id,d,remaining,frames)
    case G.CleanupChildren{+id,d,remaining,[]}: (A.apply_unrelate(~S,~C,~R,~E,world,d,W.Handle{namespace,id}),G.CleanupDescriptors{id,remaining} <> frames)
    case G.CleanupChildren{id,+d,remaining,child <> children}: child_step(~S,~C,~R,~E,kind(~S,d),world,namespace,id,d,remaining,child,children,frames)
    case G.CleanupFinish{id}: (finish(~S,~C,~R,~E,~clear,~record,world,W.Handle{namespace,id}),frames)
def resumed(~S:Data,~C:Type,~R:Type,~E:Data,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.CleanupFrame<S>>,next:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> -> List<&2,G.CleanupFrame<S>> -> CleanupResult<S,C,R,E>) -> CleanupResult<S,C,R,E>:
  (world,frames) = observed
  next(world,frames)
def drive(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record: W.Handle<S> -> A.Notice<S,E>,fuel: Nat,frames: List<&2,G.CleanupFrame<S>>,world: W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,+namespace: U32,+descriptors: List<&2,G.Descriptor<S>>) -> CleanupResult<S,C,R,E>:
  match fuel frames:
    case _ Nil{}: Complete{world}
    case 0n frames: Incomplete{world,frames}
    case 1n+rest Con{frame,frames}: resumed(~S,~C,~R,~E,step(~S,~C,~R,~E,~clear,~record,frame,world,namespace,descriptors,frames),world => frames => drive(~S,~C,~R,~E,~clear,~record,rest,frames,world,namespace,descriptors))
