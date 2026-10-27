import Base
import entity-key.bend as Key
import entity-allocator.bend as Alloc
import relation-types.bend as G
import relation-graph.bend as C
import relation-commands.bend as A
import world.bend as W
import ./relation-cleanup-control.bend as Control
import ./relation-cleanup-engine.bend as Engine

# Explicit experiment continuation. Exhaustion retains every affine owner/frame.
type CleanupResult<S: Data,C: Type,R: Type,E: Data> is Type:
  Complete{world: W.World<S,A.Store<S,C>,R,A.Notice<S,E>>}
  Incomplete{world: W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,frames: List<&2,G.CleanupFrame<S>>}
def snapshot(~S: Data,~C: Type,store: A.Store<S,C>,descriptor: G.Descriptor<S>,id:Key.Key) -> A.Store<S,C> & List<&2,Key.Key>:
  A.store_inverse(~S,~C,store,descriptor,id)
def clear_join(~S:Data,~C:Type,~E:Data,cleared:C & List<&2,A.Notice<S,E>>,graph:G.Graph<S>) -> A.Store<S,C> & List<&2,A.Notice<S,E>>:
  (components,notices) = cleared
  (A.Store{components,graph},notices)
def clear_store(~S: Data,~C: Type,~E: Data,~clear: C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,store: A.Store<S,C>,handle: W.Handle<S>) -> A.Store<S,C> & List<&2,A.Notice<S,E>>:
  match store:
    case A.Store{components,graph}: clear_join(~S,~C,~E,clear(components,handle),graph)
def publish_final(~S:Data,~C:Type,~R:Type,~E:Data,~record:W.Handle<S> -> A.Notice<S,E>,deactivated:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & W.Status,notices:List<&2,A.Notice<S,E>>,+handle:W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  (world,_) = deactivated
  W.release_cleared(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,W.event_publish(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,List.append(&2,A.Notice<S,E>,notices,[record(handle)])),handle)
def finalized(~S: Data,~C: Type,~R: Type,~E: Data,~record: W.Handle<S> -> A.Notice<S,E>,cleared: W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,A.Notice<S,E>>,+handle: W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  (world,notices) = cleared
  publish_final(~S,~C,~R,~E,~record,W.deactivate(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,handle),notices,handle)
def finish_live(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record: W.Handle<S> -> A.Notice<S,E>,world: W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,+handle: W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  finalized(~S,~C,~R,~E,~record,W.with_store(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~List<&2,A.Notice<S,E>>,store => clear_store(~S,~C,~E,~clear,store,handle),world),handle)
# A paused continuation may outlive its full entity key. Validate before clear.
def finish_checked(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,checked:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Bool,handle:W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  match checked:
    case (world,False{}):world
    case (world,True{}):finish_live(~S,~C,~R,~E,~clear,~record,world,handle)
def finish(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,+handle:W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  finish_checked(~S,~C,~R,~E,~clear,~record,W.valid(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,handle),handle)
def entered(~S: Data,~C: Type,~R: Type,~E: Data,checked: W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Bool,id:Key.Key,descriptors: List<&2,G.Descriptor<S>>,frames: List<&2,G.CleanupFrame<S>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.CleanupFrame<S>>:
  match checked:
    case (world,False{}): (world,frames)
    case (world,True{}): (world,G.CleanupDescriptors{id,descriptors} <> frames)
def children_start(~S: Data,~C: Type,~R: Type,~E: Data,observed: W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,Key.Key>,id:Key.Key,descriptor: G.Descriptor<S>,remaining: List<&2,G.Descriptor<S>>,frames: List<&2,G.CleanupFrame<S>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.CleanupFrame<S>>:
  (world,children) = observed
  (world,G.CleanupChildren{id,descriptor,remaining,children} <> frames)
def interpreted(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,intent:Control.Intent<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,+namespace:U32) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.CleanupFrame<S>>:
  match intent:
    case Control.Check{+id,descriptors,frames}:entered(~S,~C,~R,~E,W.valid(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,W.Handle{namespace,id}),id,descriptors,frames)
    case Control.Observe{+id,+descriptor,remaining,frames}:children_start(~S,~C,~R,~E,W.with_store(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~List<&2,Key.Key>,store => snapshot(~S,~C,store,descriptor,id),world),id,descriptor,remaining,frames)
    case Control.Unrelate{id,descriptor,frames}:(A.apply_unrelate(~S,~C,~R,~E,world,descriptor,W.Handle{namespace,id}),frames)
    case Control.Finish{id,frames}:(finish(~S,~C,~R,~E,~clear,~record,world,W.Handle{namespace,id}),frames)
    case Control.Continue{frames}:(world,frames)
def step(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,frame:G.CleanupFrame<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,+namespace:U32,descriptors:List<&2,G.Descriptor<S>>,frames:List<&2,G.CleanupFrame<S>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.CleanupFrame<S>>:
  interpreted(~S,~C,~R,~E,~clear,~record,Control.next(S,frame,descriptors,frames),world,namespace)
def engine_result(~S:Data,~C:Type,~R:Type,~E:Data,result:Engine.Progress<S,W.World<S,A.Store<S,C>,R,A.Notice<S,E>>>) -> CleanupResult<S,C,R,E>:
  match result:
    case Engine.Complete{world}:Complete{world}
    case Engine.Incomplete{world,frames}:Incomplete{world,frames}
def engine_input(~S:Data,~C:Type,~R:Type,~E:Data,result:CleanupResult<S,C,R,E>) -> Engine.Progress<S,W.World<S,A.Store<S,C>,R,A.Notice<S,E>>>:
  match result:
    case Complete{world}:Engine.Complete{world}
    case Incomplete{world,frames}:Engine.Incomplete{world,frames}
def drive(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,fuel:Nat,frames:List<&2,G.CleanupFrame<S>>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,+namespace:U32,+descriptors:List<&2,G.Descriptor<S>>) -> CleanupResult<S,C,R,E>:
  engine_result(~S,~C,~R,~E,Engine.drive(~S,~W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,~step(~S,~C,~R,~E,~clear,~record),fuel,frames,world,namespace,descriptors))
def owner_blocks(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,remaining:Nat,result:CleanupResult<S,C,R,E>,+nodes:Nat,+edges:List<&2,G.Edge<S>>,+namespace:U32,+descriptors:List<&2,G.Descriptor<S>>) -> CleanupResult<S,C,R,E>:
  engine_result(~S,~C,~R,~E,Engine.owner_blocks(~S,~W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,~step(~S,~C,~R,~E,~clear,~record),remaining,engine_input(~S,~C,~R,~E,result),nodes,edges,namespace,descriptors))
def original_edges(~S:Data,~C:Type,store:A.Store<S,C>) -> A.Store<S,C> & List<&2,G.Edge<S>>:
  match store:
    case A.Store{components,G.Graph{+edges,inverses}}: (A.Store{components,G.Graph{edges,inverses}},edges)
def automatic_start(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,+nodes:Nat,+edges:List<&2,G.Edge<S>>,+namespace:U32,id:Key.Key,+descriptors:List<&2,G.Descriptor<S>>) -> CleanupResult<S,C,R,E>:
  owner_blocks(~S,~C,~R,~E,~clear,~record,nodes,drive(~S,~C,~R,~E,~clear,~record,1n,[G.CleanupEnter{id}],world,namespace,descriptors),nodes,edges,namespace,descriptors)
def automatic_inventory(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.Edge<S>>,namespace:U32,id:Key.Key,descriptors:List<&2,G.Descriptor<S>>) -> CleanupResult<S,C,R,E>:
  match observed:
    case (W.World{+ns,Alloc.Allocator{+next,+highWater,slots,+capacity,+depth,+free,+order},store,resource,+events,pending,+registrations,+nextSystemId,+clock,lifecycle},edges): automatic_start(~S,~C,~R,~E,~clear,~record,W.World{ns,Alloc.Allocator{next,highWater,slots,capacity,depth,free,order},store,resource,events,pending,registrations,nextSystemId,clock,lifecycle},U32.to_nat(highWater),edges,namespace,id,descriptors)
def automatic(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,handle:W.Handle<S>,descriptors:List<&2,G.Descriptor<S>>) -> CleanupResult<S,C,R,E>:
  match handle:
    case W.Handle{namespace,id}: automatic_inventory(~S,~C,~R,~E,~clear,~record,W.with_store(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~List<&2,G.Edge<S>>,store => original_edges(~S,~C,store),world),namespace,id,descriptors)
