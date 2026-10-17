import Base
import entity-key.bend as Key
import ./relation-types.bend as G
import ./relation-graph.bend as Graph
import ./relation-commands.bend as A
import ./relation-reorder.bend as Reorder
import ./relation-providers.bend as Relations
import ./world.bend as W
import ./capabilities.bend as Cap
import ./hierarchy-traversal.bend as T

type Path<S:Data> is Data:
  Complete{handles:List<&2,W.Handle<S>>}
  Incomplete{handles:List<&2,W.Handle<S>>,pending:List<&2,W.Handle<S>>}
type Frame<S:Data> is Data:
  Frame{entity:W.Handle<S>,parent:Maybe<&2,W.Handle<S>>,children:List<&2,W.Handle<S>>,ancestors:Path<S>,root:Maybe<&2,W.Handle<S>>,depth:Path<S>,breadth:Path<S>}
type Read<H:Type,S:Data> is Type:
  Read{lookup:Cap.Request<H,W.Handle<S>,Maybe<&2,Frame<S>>>}
def path(~S:Data,walk:T.Walk,+namespace:U32) -> Path<S>:
  match walk:
    case T.Complete{ids}: Complete{Relations.handle_ids(~S,ids,namespace)}
    case T.Incomplete{ids,pending}: Incomplete{Relations.handle_ids(~S,ids,namespace),Relations.handle_ids(~S,pending,namespace)}
def handle(~S:Data,id:Maybe<&2,Key.Key>,namespace:U32) -> Maybe<&2,W.Handle<S>>:
  match id:
    case None{}: None{}
    case Some{id}: Some{W.Handle{namespace,id}}
def snapshot(~S:Data,+graph:G.Graph<S>,+descriptor:G.Descriptor<S>,target:W.Handle<S>) -> Frame<S>:
  match target:
    case W.Handle{+namespace,+id}: Frame{W.Handle{namespace,id},handle(~S,Graph.target(~S,graph,descriptor,id),namespace),Relations.handle_ids(~S,Graph.inverse(~S,graph,descriptor,id),namespace),path(~S,T.ancestors(~S,graph,descriptor,id),namespace),handle(~S,T.root(T.ancestors(~S,graph,descriptor,id),id),namespace),path(~S,T.descendants(~S,graph,descriptor,id,T.Depth{}),namespace),path(~S,T.descendants(~S,graph,descriptor,id,T.Breadth{}),namespace)}
def store_snapshot(~S:Data,~C:Type,store:A.Store<S,C>,descriptor:G.Descriptor<S>,target:W.Handle<S>) -> A.Store<S,C> & Frame<S>:
  match store:
    case A.Store{components,+graph}: (A.Store{components,graph},snapshot(~S,graph,descriptor,target))
def present(~S:Data,~C:Type,~R:Type,~E:Data,result:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Frame<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,Frame<S>>:
  (world,frame) = result
  (world,Some{frame})
def checked(~S:Data,~C:Type,~R:Type,~E:Data,~descriptor:G.HierarchyDescriptor<S>,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Bool,target:W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,Frame<S>>:
  match observed:
    case (world,False{}): (world,None{})
    case (world,True{}): present(~S,~C,~R,~E,W.with_store(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Frame<S>,store => store_snapshot(~S,~C,store,Reorder.descriptor(~S,descriptor),target),world))
def lookup(~S:Data,~C:Type,~R:Type,~E:Data,~descriptor:G.HierarchyDescriptor<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,target:W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,Frame<S>>:
  match target:
    case W.Handle{+ns,+id}: checked(~S,~C,~R,~E,~descriptor,W.valid(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,W.Handle{ns,id}),W.Handle{ns,id})
def read(-H:Type,-S:Data,caps:Read<H,S>,owner:H,target:W.Handle<S>) -> H & Maybe<&2,Frame<S>>:
  match caps:
    case Read{Cap.Request{get}}: get(owner,target)
def grant(~S:Data,~C:Type,~R:Type,~E:Data,~descriptor:G.HierarchyDescriptor<S>,~Out:Type,~body:@-H:Type -> Read<H,S> -> W.Handle<S> -> H -> H & Out,target:W.Handle<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Out:
  body(W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,Read{Cap.Request{lookup(~S,~C,~R,~E,~descriptor)}},target,world)
