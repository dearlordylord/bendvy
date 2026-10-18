import Base
import ./trace-relation.bend as TraceRel
import ./deferred-command.bend as Deferred
import ./trace-facts.bend as TraceFacts
import entity-key.bend as Key
import relation-types.bend as G
import relation-reorder-core.bend as C
import relation-commands.bend as A
import world.bend as W
import transaction.bend as X
import capabilities.bend as Cap

type Args<S:Data> is Data:
  Args{parent:W.Handle<S>,children:List<&2,W.Handle<S>>}
type Writable<H:Type,S:Data> is Type:
  Writable{reorder:Cap.Request<H,Args<S>,A.QueueStatus>}
def descriptor(~S:Data,value:G.HierarchyDescriptor<S>) -> G.Descriptor<S>:
  match value:
    case G.HierarchyDescriptor{key,name,inverse}: G.Descriptor{key,name,inverse,G.Hierarchy{}}
def store_reorder(~S:Data,~C:Type,store:A.Store<S,C>,d:G.Descriptor<S>,parent:Key.Key,children:List<&2,G.ChildStatus>,parentLive:Bool) -> A.Store<S,C> & Maybe<&2,G.Error>:
  match store:
    case A.Store{components,graph}: A.relate_result(~S,~C,C.reorder(~S,graph,d,parent,children,parentLive),components)
def error_target(error:G.Error,parent:Key.Key) -> Key.Key:
  match error:
    case G.MissingChildEntity{_,child,_}: child
    case G.DuplicateChild{_,child,_}: child
    case G.ChildNotRelatedToParent{_,child,_}: child
    case _: parent
def publish(~S:Data,~C:Type,~R:Type,~E:Data,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,G.Error>,d:G.Descriptor<S>,+parent:Key.Key) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  match observed:
    case (world,None{}): world
    case (world,Some{+error}): W.event_publish(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,[A.RelationFailed{G.Failure{d,G.ReorderChildren{},parent,error_target(error,parent),error}}])
def children_prepend(~S:Data,~C:Type,~R:Type,~E:Data,result:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.ChildStatus>,id:Key.Key,live:Bool) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.ChildStatus>:
  (world,rest) = result
  (world,G.ChildStatus{id,live} <> rest)
def child_next(~S:Data,~C:Type,~R:Type,~E:Data,checked:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Bool,id:Key.Key,next:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.ChildStatus>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.ChildStatus>:
  (world,live) = checked
  children_prepend(~S,~C,~R,~E,next(world),id,live)
def child_statuses(~S:Data,~C:Type,~R:Type,~E:Data,children:List<&2,W.Handle<S>>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.ChildStatus>:
  match children:
    case []: (world,[])
    case W.Handle{+ns,+id} <> rest: child_next(~S,~C,~R,~E,W.valid(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,W.Handle{ns,id}),id,world => child_statuses(~S,~C,~R,~E,rest,world))
def apply_children_result(~S:Data,~C:Type,~R:Type,~E:Data,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,G.ChildStatus>,+d:G.Descriptor<S>,+parent:Key.Key,parentLive:Bool) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,G.Error>:
  (world,children) = observed
  W.with_store(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Maybe<&2,G.Error>,store => store_reorder(~S,~C,store,d,parent,children,parentLive),world)
def apply_parent_result(~S:Data,~C:Type,~R:Type,~E:Data,checked:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Bool,d:G.Descriptor<S>,parent:Key.Key,children:List<&2,W.Handle<S>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,G.Error>:
  (world,live) = checked
  apply_children_result(~S,~C,~R,~E,child_statuses(~S,~C,~R,~E,children,world),d,parent,live)
def apply_result(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,args:Args<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,G.Error>:
  match args:
    case Args{W.Handle{+ns,+parent},children}: apply_parent_result(~S,~C,~R,~E,W.valid(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,W.Handle{ns,parent}),descriptor(~S,d),parent,children)
def apply_published(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,args:Args<S>,result:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,G.Error>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  match args:
    case Args{parent,_}:publish(~S,~C,~R,~E,result,descriptor(~S,d),W.handle_key(~S,parent))
def apply_traced(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,trace:TraceFacts.State,args:Args<S>,result:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,G.Error>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & TraceFacts.State:
  match args result:
    case Args{+parent,+children}, (world,+error):(publish(~S,~C,~R,~E,(world,error),descriptor(~S,d),W.handle_key(~S,parent)),TraceRel.reorder_applied(~S,trace,descriptor(~S,d),parent,children,error))
def apply(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,+args:Args<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>:
  apply_published(~S,~C,~R,~E,~d,args,apply_result(~S,~C,~R,~E,~d,world,args))
def namespaces(~S:Data,children:List<&2,W.Handle<S>>,+namespace:U32) -> Bool:
  match children:
    case []: True{}
    case W.Handle{ns,_} <> rest: Bool.and(U32.is_eq(namespace,ns),namespaces(~S,rest,namespace))
def same_world(~S:Data,+args:Args<S>,+namespace:U32) -> Bool:
  match args:
    case Args{W.Handle{ns,_},children}: Bool.and(U32.is_eq(ns,namespace),namespaces(~S,children,namespace))
def reorder_command(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,enabled:Bool,+args:Args<S>) -> Deferred.Command<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>>:
  match enabled:
    case False{}:Deferred.Raw{world=>apply(~S,~C,~R,~E,~d,world,args)}
    case True{}:Deferred.Observed{trace=>world=>apply_traced(~S,~C,~R,~E,~d,trace,args,apply_result(~S,~C,~R,~E,~d,world,args))}
def reordered_stage(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,+args:Args<S>,result:TraceFacts.FactResult,tx:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>:
  match args tx:
    case Args{parent,children} X.Tx{world,undo,commands,events,trace}:X.Tx{world,undo,commands,events,TraceRel.reorder(~S,trace,descriptor(~S,d),TraceFacts.StageOperation{},parent,children,result)}
def reorder_staged(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,+args:Args<S>,tx:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>:
  match tx:
    case X.Tx{world,undo,commands,events,+trace}:reordered_stage(~S,~C,~R,~E,~d,args,TraceFacts.Attempted{},X.Tx{world,undo,reorder_command(~S,~C,~R,~E,~d,TraceFacts.enabled(trace),args) <> commands,events,trace})
def queued(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,same:Bool,tx:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,args:Args<S>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  match same:
    case False{}: (reordered_stage(~S,~C,~R,~E,~d,args,TraceFacts.Refused{"MissingEntity"},tx),A.MissingEntity{})
    case True{}: (reorder_staged(~S,~C,~R,~E,~d,args,tx),A.Queued{})
def namespace_join(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & U32,undo:List<(W.World<S,A.Store<S,C>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>)>,commands:List<Deferred.Command<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>>>,events:List<&2,A.Notice<S,E>>,trace:TraceFacts.State,+args:Args<S>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  (world,namespace) = observed
  queued(~S,~C,~R,~E,~d,same_world(~S,args,namespace),X.Tx{world,undo,commands,events,trace},args)
def queue(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,tx:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,args:Args<S>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  match tx:
    case X.Tx{world,undo,commands,events,trace}: namespace_join(~S,~C,~R,~E,~d,W.namespace(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world),undo,commands,events,trace,args)
def body(~S:Data,-H:Type,caps:Writable<H,S>,args:Args<S>,owner:H) -> H & A.QueueStatus:
  match caps:
    case Writable{Cap.Request{reorder}}: reorder(owner,args)
def invoke(~S:Data,~C:Type,~R:Type,~E:Data,~d:G.HierarchyDescriptor<S>,~Out:Type,~client:@-H:Type -> Writable<H,S> -> Args<S> -> H -> H & Out,args:Args<S>,tx:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & Out:
  client(X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,Writable{Cap.Request{queue(~S,~C,~R,~E,~d)}},args,tx)
