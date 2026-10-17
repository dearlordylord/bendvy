import Base
import ./trace-relation.bend as TraceRel
import ./deferred-command.bend as Deferred
import ./trace-facts.bend as TraceFacts
import entity-key.bend as Key
import relation-types.bend as G
import relation-graph.bend as C
import world.bend as W
import transaction.bend as X

# Experiment-only transport: never duplicates or inspects arbitrary component owners.
# This initial seam implements relate/unrelate, not linked cleanup or keyed retention.
type Store<S: Data,Components: Type> is Type:
  Store{components: Components,graph: G.Graph<S>}
type Notice<S: Data,Original: Data> is Data:
  Original{event: Original}
  RelationFailed{failure: G.Failure<S>}
  ComponentRemoved{id:Key.Key}
  CleanupPaused{frames: List<&2,G.CleanupFrame<S>>}
type QueueStatus is Data:
  Queued{}
  MissingEntity{}
def empty(~S: Data,~C: Type,components: C) -> Store<S,C>:
  Store{components,G.Graph{[],[]}}
def graph_read(~S: Data,~C: Type,store: Store<S,C>) -> Store<S,C> & G.Graph<S>:
  match store:
    case Store{components,+graph}: (Store{components,graph},graph)
def graph_replace(~S: Data,~C: Type,store: Store<S,C>,replacement: G.Graph<S>) -> Store<S,C>:
  match store:
    case Store{components,_}: Store{components,replacement}
def relate_result(~S: Data,~C: Type,result: G.CoreResult<S>,components: C) -> Store<S,C> & Maybe<&2,G.Error>:
  match result:
    case G.CoreResult{graph,error}: (Store{components,graph},error)
def store_relate(~S: Data,~C: Type,store: Store<S,C>,descriptor: G.Descriptor<S>,source:Key.Key,target:Key.Key,sourceLive: Bool,targetLive: Bool) -> Store<S,C> & Maybe<&2,G.Error>:
  match store:
    case Store{components,graph}: relate_result(~S,~C,C.relate(~S,graph,descriptor,source,target,sourceLive,targetLive),components)
def publish_relate(~S: Data,~C: Type,~R: Type,~E: Data,observed: W.World<S,Store<S,C>,R,Notice<S,E>> & Maybe<&2,G.Error>,descriptor: G.Descriptor<S>,source:Key.Key,target:Key.Key) -> W.World<S,Store<S,C>,R,Notice<S,E>>:
  match observed:
    case (world,None{}): world
    case (world,Some{error}): W.event_publish(~S,~Store<S,C>,~R,~Notice<S,E>,world,[RelationFailed{G.Failure{descriptor,G.Relate{},source,target,error}}])
def apply_live_result(~S: Data,~C: Type,~R: Type,~E: Data,checked: W.World<S,Store<S,C>,R,Notice<S,E>> & Bool,+descriptor: G.Descriptor<S>,+source:Key.Key,+target:Key.Key,sourceLive: Bool) -> W.World<S,Store<S,C>,R,Notice<S,E>> & Maybe<&2,G.Error>:
  (world,targetLive) = checked
  W.with_store(~S,~Store<S,C>,~R,~Notice<S,E>,~Maybe<&2,G.Error>,store => store_relate(~S,~C,store,descriptor,source,target,sourceLive,targetLive),world)
def apply_source_result(~S: Data,~C: Type,~R: Type,~E: Data,checked: W.World<S,Store<S,C>,R,Notice<S,E>> & Bool,descriptor: G.Descriptor<S>,source:Key.Key,target:Key.Key,targetHandle: W.Handle<S>) -> W.World<S,Store<S,C>,R,Notice<S,E>> & Maybe<&2,G.Error>:
  (world,sourceLive) = checked
  apply_live_result(~S,~C,~R,~E,W.valid(~S,~Store<S,C>,~R,~Notice<S,E>,world,targetHandle),descriptor,source,target,sourceLive)
def apply_relate_result(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,Store<S,C>,R,Notice<S,E>>,descriptor: G.Descriptor<S>,+source: W.Handle<S>,+target: W.Handle<S>) -> W.World<S,Store<S,C>,R,Notice<S,E>> & Maybe<&2,G.Error>:
  match source target:
    case W.Handle{+sn,+sid} W.Handle{+tn,+tid}: apply_source_result(~S,~C,~R,~E,W.valid(~S,~Store<S,C>,~R,~Notice<S,E>,world,W.Handle{sn,sid}),descriptor,sid,tid,W.Handle{tn,tid})
def apply_relate(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,Store<S,C>,R,Notice<S,E>>,+descriptor:G.Descriptor<S>,+source:W.Handle<S>,+target:W.Handle<S>) -> W.World<S,Store<S,C>,R,Notice<S,E>>:
  publish_relate(~S,~C,~R,~E,apply_relate_result(~S,~C,~R,~E,world,descriptor,source,target),descriptor,W.handle_key(~S,source),W.handle_key(~S,target))
def applied_relate_traced(~S:Data,~C:Type,~R:Type,~E:Data,trace:TraceFacts.State,+descriptor:G.Descriptor<S>,+source:W.Handle<S>,+target:W.Handle<S>,result:W.World<S,Store<S,C>,R,Notice<S,E>> & Maybe<&2,G.Error>) -> W.World<S,Store<S,C>,R,Notice<S,E>> & TraceFacts.State:
  match result:
    case (world,+error):(publish_relate(~S,~C,~R,~E,(world,error),descriptor,W.handle_key(~S,source),W.handle_key(~S,target)),TraceRel.relate_applied(~S,trace,descriptor,source,target,error))
def relate_command(~S:Data,~C:Type,~R:Type,~E:Data,enabled:Bool,+descriptor:G.Descriptor<S>,+source:W.Handle<S>,+target:W.Handle<S>) -> Deferred.Command<W.World<S,Store<S,C>,R,Notice<S,E>>>:
  match enabled:
    case False{}:Deferred.Raw{world=>apply_relate(~S,~C,~R,~E,world,descriptor,source,target)}
    case True{}:Deferred.Observed{trace=>world=>applied_relate_traced(~S,~C,~R,~E,trace,descriptor,source,target,apply_relate_result(~S,~C,~R,~E,world,descriptor,source,target))}
def relate_staged(~S:Data,~C:Type,~R:Type,~E:Data,+descriptor:G.Descriptor<S>,+source:W.Handle<S>,+target:W.Handle<S>,tx:X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>) -> X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>:
  match tx:
    case X.Tx{world,undo,commands,events,+trace}:X.Tx{world,undo,relate_command(~S,~C,~R,~E,TraceFacts.enabled(trace),descriptor,source,target) <> commands,events,TraceRel.relate(~S,trace,descriptor,TraceFacts.StageOperation{},source,target,TraceFacts.Attempted{})}
def relate_refused(~S:Data,~C:Type,~R:Type,~E:Data,descriptor:G.Descriptor<S>,source:W.Handle<S>,target:W.Handle<S>,tx:X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>) -> X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>:
  match tx:
    case X.Tx{world,undo,commands,events,trace}:X.Tx{world,undo,commands,events,TraceRel.relate(~S,trace,descriptor,TraceFacts.StageOperation{},source,target,TraceFacts.Refused{"MissingEntity"})}
def queue_checked(~S: Data,~C: Type,~R: Type,~E: Data,same: Bool,tx: X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>,descriptor: G.Descriptor<S>,source: W.Handle<S>,target: W.Handle<S>) -> X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>> & QueueStatus:
  match same:
    case False{}: (relate_refused(~S,~C,~R,~E,descriptor,source,target,tx),MissingEntity{})
    case True{}: (relate_staged(~S,~C,~R,~E,descriptor,source,target,tx),Queued{})
def queue_namespaced(~S: Data,~C: Type,~R: Type,~E: Data,checked: W.World<S,Store<S,C>,R,Notice<S,E>> & U32,undo: List<(W.World<S,Store<S,C>,R,Notice<S,E>> -> W.World<S,Store<S,C>,R,Notice<S,E>>)>,commands:List<Deferred.Command<W.World<S,Store<S,C>,R,Notice<S,E>>>>,events: List<&2,Notice<S,E>>,trace:TraceFacts.State,descriptor: G.Descriptor<S>,source: W.Handle<S>,target: W.Handle<S>) -> X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>> & QueueStatus:
  match checked source target:
    case (world,+namespace) W.Handle{+sn,+sid} W.Handle{+tn,+tid}: queue_checked(~S,~C,~R,~E,Bool.and(U32.is_eq(namespace,sn),U32.is_eq(namespace,tn)),X.Tx{world,undo,commands,events,trace},descriptor,W.Handle{sn,sid},W.Handle{tn,tid})
def queue_relate(~S: Data,~C: Type,~R: Type,~E: Data,tx: X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>,descriptor: G.Descriptor<S>,source: W.Handle<S>,target: W.Handle<S>) -> X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>> & QueueStatus:
  match tx:
    case X.Tx{world,undo,commands,events,trace}: queue_namespaced(~S,~C,~R,~E,W.namespace(~S,~Store<S,C>,~R,~Notice<S,E>,world),undo,commands,events,trace,descriptor,source,target)
def store_unrelate(~S: Data,~C: Type,store: Store<S,C>,descriptor: G.Descriptor<S>,source:Key.Key) -> Store<S,C> & Unit:
  match store:
    case Store{components,graph}: (Store{components,C.unrelate(~S,graph,descriptor,source)},Unit{})
def discard_unit(~S: Data,~C: Type,~R: Type,~E: Data,result: W.World<S,Store<S,C>,R,Notice<S,E>> & Unit) -> W.World<S,Store<S,C>,R,Notice<S,E>>:
  (world,_) = result
  world
def apply_unrelate(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,Store<S,C>,R,Notice<S,E>>,descriptor: G.Descriptor<S>,source: W.Handle<S>) -> W.World<S,Store<S,C>,R,Notice<S,E>>:
  match source:
    case W.Handle{_,id}: discard_unit(~S,~C,~R,~E,W.with_store(~S,~Store<S,C>,~R,~Notice<S,E>,~Unit,store => store_unrelate(~S,~C,store,descriptor,id),world))
def unrelate_command(~S:Data,~C:Type,~R:Type,~E:Data,enabled:Bool,+descriptor:G.Descriptor<S>,+source:W.Handle<S>) -> Deferred.Command<W.World<S,Store<S,C>,R,Notice<S,E>>>:
  match enabled:
    case False{}:Deferred.Raw{world=>apply_unrelate(~S,~C,~R,~E,world,descriptor,source)}
    case True{}:Deferred.Observed{trace=>world=>(apply_unrelate(~S,~C,~R,~E,world,descriptor,source),TraceRel.unrelate(~S,trace,descriptor,TraceFacts.ApplyOperation{},source,TraceFacts.Applied{}))}
def unrelate_staged(~S:Data,~C:Type,~R:Type,~E:Data,+descriptor:G.Descriptor<S>,+source:W.Handle<S>,tx:X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>) -> X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>:
  match tx:
    case X.Tx{world,undo,commands,events,+trace}:X.Tx{world,undo,unrelate_command(~S,~C,~R,~E,TraceFacts.enabled(trace),descriptor,source) <> commands,events,TraceRel.unrelate(~S,trace,descriptor,TraceFacts.StageOperation{},source,TraceFacts.Attempted{})}
def unrelate_refused(~S:Data,~C:Type,~R:Type,~E:Data,descriptor:G.Descriptor<S>,source:W.Handle<S>,tx:X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>) -> X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>:
  match tx:
    case X.Tx{world,undo,commands,events,trace}:X.Tx{world,undo,commands,events,TraceRel.unrelate(~S,trace,descriptor,TraceFacts.StageOperation{},source,TraceFacts.Refused{"MissingEntity"})}
def queue_clear_checked(~S: Data,~C: Type,~R: Type,~E: Data,same: Bool,tx: X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>,descriptor: G.Descriptor<S>,source: W.Handle<S>) -> X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>> & QueueStatus:
  match same:
    case False{}: (unrelate_refused(~S,~C,~R,~E,descriptor,source,tx),MissingEntity{})
    case True{}: (unrelate_staged(~S,~C,~R,~E,descriptor,source,tx),Queued{})
def queue_clear_namespaced(~S: Data,~C: Type,~R: Type,~E: Data,checked: W.World<S,Store<S,C>,R,Notice<S,E>> & U32,undo: List<(W.World<S,Store<S,C>,R,Notice<S,E>> -> W.World<S,Store<S,C>,R,Notice<S,E>>)>,commands:List<Deferred.Command<W.World<S,Store<S,C>,R,Notice<S,E>>>>,events: List<&2,Notice<S,E>>,trace:TraceFacts.State,descriptor: G.Descriptor<S>,source: W.Handle<S>) -> X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>> & QueueStatus:
  match checked source:
    case (world,namespace) W.Handle{+sn,+sid}: queue_clear_checked(~S,~C,~R,~E,U32.is_eq(namespace,sn),X.Tx{world,undo,commands,events,trace},descriptor,W.Handle{sn,sid})
def queue_unrelate(~S: Data,~C: Type,~R: Type,~E: Data,tx: X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>,descriptor: G.Descriptor<S>,source: W.Handle<S>) -> X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>> & QueueStatus:
  match tx:
    case X.Tx{world,undo,commands,events,trace}: queue_clear_namespaced(~S,~C,~R,~E,W.namespace(~S,~Store<S,C>,~R,~Notice<S,E>,world),undo,commands,events,trace,descriptor,source)
def store_inverse(~S: Data,~C: Type,store: Store<S,C>,descriptor: G.Descriptor<S>,target:Key.Key) -> Store<S,C> & List<&2,Key.Key>:
  match store:
    case Store{components,+graph}: (Store{components,graph},C.inverse(~S,graph,descriptor,target))
def inverse_present(~S: Data,~C: Type,~R: Type,~E: Data,result: W.World<S,Store<S,C>,R,Notice<S,E>> & List<&2,Key.Key>) -> W.World<S,Store<S,C>,R,Notice<S,E>> & Maybe<&2,List<&2,Key.Key>>:
  (world,sources) = result
  (world,Some{sources})
def inverse_checked(~S: Data,~C: Type,~R: Type,~E: Data,checked: W.World<S,Store<S,C>,R,Notice<S,E>> & Bool,descriptor: G.Descriptor<S>,target: W.Handle<S>) -> W.World<S,Store<S,C>,R,Notice<S,E>> & Maybe<&2,List<&2,Key.Key>>:
  match checked target:
    case (world,False{}) _: (world,None{})
    case (world,True{}) W.Handle{_,id}: inverse_present(~S,~C,~R,~E,W.with_store(~S,~Store<S,C>,~R,~Notice<S,E>,~List<&2,Key.Key>,store => store_inverse(~S,~C,store,descriptor,id),world))
def inverse(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,Store<S,C>,R,Notice<S,E>>,descriptor: G.Descriptor<S>,+target: W.Handle<S>) -> W.World<S,Store<S,C>,R,Notice<S,E>> & Maybe<&2,List<&2,Key.Key>>:
  inverse_checked(~S,~C,~R,~E,W.valid(~S,~Store<S,C>,~R,~Notice<S,E>,world,target),descriptor,target)
