import Base
import relation-types.bend as G
import relation-reorder-core.bend as C
import relation-commands.bend as A
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as X
import ../../../src/ecs/capabilities.bend as Cap

type Args<S:Data> is Data:
  Args{parent:W.Handle<S>,children:List<&2,W.Handle<S>>}
type Writable<H:Type,S:Data> is Type:
  Writable{reorder:Cap.Request<H,Args<S>,A.QueueStatus>}
def descriptor(~S:Data,value:G.HierarchyDescriptor<S>) -> G.Descriptor<S>:
  match value:
    case G.HierarchyDescriptor{key,name,inverse}: G.Descriptor{key,name,inverse,G.Hierarchy{}}
def store_reorder(~S:Data,~C:Type,store:A.Store<S,C>,d:G.Descriptor<S>,parent:U32,children:List<&2,G.ChildStatus>,parentLive:Bool) -> A.Store<S,C> & Maybe<&2,G.Error>:
  match store:
    case A.Store{components,graph}: A.relate_result(~S,~C,C.reorder(~S,graph,d,parent,children,parentLive),components)
def error_target(error:G.Error,parent:U32) -> U32:
  match error:
    case G.MissingChildEntity{_,child,_}: child
    case G.DuplicateChild{_,child,_}: child
    case G.ChildNotRelatedToParent{_,child,_}: child
    case _: parent
def publish(~S:Data,~C:Type,~R:Type,~E:Data,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,G.Error>,d:G.Descriptor<S>,+parent:U32) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  match observed:
    case (world,None{}): world
    case (world,Some{+error}): W.event_publish(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,[A.RelationFailed{G.Failure{d,G.ReorderChildren{},parent,error_target(error,parent),error}}])
def children_prepend(~S:Data,~C:Type,~R:Type,~E:Data,result:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.ChildStatus>,id:U32,live:Bool) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.ChildStatus>:
  (world,rest) = result
  (world,G.ChildStatus{id,live} <> rest)
def child_next(~S:Data,~C:Type,~R:Type,~E:Data,checked:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Bool,id:U32,next:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.ChildStatus>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.ChildStatus>:
  (world,live) = checked
  children_prepend(~S,~C,~R,~E,next(world),id,live)
def child_statuses(~S:Data,~C:Type,~R:Type,~E:Data,children:List<&2,W.Handle<S>>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.ChildStatus>:
  match children:
    case []: (world,[])
    case W.Handle{+ns,+id} <> rest: child_next(~S,~C,~R,~E,W.valid(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,W.Handle{ns,id}),id,world => child_statuses(~S,~C,~R,~E,rest,world))
def apply_children(~S:Data,~C:Type,~R:Type,~E:Data,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.ChildStatus>,+d:G.Descriptor<S>,+parent:U32,parentLive:Bool) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  (world,children) = observed
  publish(~S,~C,~R,~E,W.with_store(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Maybe<&2,G.Error>,store => store_reorder(~S,~C,store,d,parent,children,parentLive),world),d,parent)
def apply_parent(~S:Data,~C:Type,~R:Type,~E:Data,checked:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Bool,d:G.Descriptor<S>,parent:U32,children:List<&2,W.Handle<S>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  (world,live) = checked
  apply_children(~S,~C,~R,~E,child_statuses(~S,~C,~R,~E,children,world),d,parent,live)
def apply(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,args:Args<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  match args:
    case Args{W.Handle{+ns,+parent},children}: apply_parent(~S,~C,~R,~E,W.valid(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,W.Handle{ns,parent}),descriptor(~S,d),parent,children)
def namespaces(~S:Data,children:List<&2,W.Handle<S>>,+namespace:U32) -> Bool:
  match children:
    case []: True{}
    case W.Handle{ns,_} <> rest: Bool.and(U32.is_eq(namespace,ns),namespaces(~S,rest,namespace))
def same_world(~S:Data,+args:Args<S>,+namespace:U32) -> Bool:
  match args:
    case Args{W.Handle{ns,_},children}: Bool.and(U32.is_eq(ns,namespace),namespaces(~S,children,namespace))
def queued(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,same:Bool,tx:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,args:Args<S>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  match same:
    case False{}: (tx,A.MissingEntity{})
    case True{}: (X.stage(~W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,~A.Notice<S,E>,tx,world => apply(~S,~C,~R,~E,~d,world,args)),A.Queued{})
def namespace_join(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & U32,undo:List<(W.World<S,A.Store<S,C>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>)>,commands:List<(W.World<S,A.Store<S,C>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>)>,events:List<&2,A.Notice<S,E>>,+args:Args<S>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  (world,namespace) = observed
  queued(~S,~C,~R,~E,~d,same_world(~S,args,namespace),X.Tx{world,undo,commands,events},args)
def queue(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,tx:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,args:Args<S>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  match tx:
    case X.Tx{world,undo,commands,events}: namespace_join(~S,~C,~R,~E,~d,W.namespace(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world),undo,commands,events,args)
def body(~S:Data,-H:Type,caps:Writable<H,S>,args:Args<S>,owner:H) -> H & A.QueueStatus:
  match caps:
    case Writable{Cap.Request{reorder}}: reorder(owner,args)
def invoke(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,~Out:Type,~client:@-H:Type -> Writable<H,S> -> Args<S> -> H -> H & Out,args:Args<S>,tx:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & Out:
  client(X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,Writable{Cap.Request{queue(~S,~C,~R,~E,~d)}},args,tx)
