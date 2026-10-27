import Base
import ./world.bend as W
import ./execution-composer-layout.bend as Layout
import ./execution-relation-operation.bend as O

# The closed command declaration binds route and enqueue to the existing Buffer.
# These adapters do not allocate a queue or accept a World callback.
type Commands<-Q:Type,-S:Data> is Type:
  Commands{relate:Q -> W.Handle<S> -> W.Handle<S> -> Q,unrelate:Q -> W.Handle<S> -> Q}
type HierarchyCommands<-Q:Type,-S:Data> is Type:
  HierarchyCommands{relations:Commands<Q,S>,reorder:Q -> W.Handle<S> -> List<&2,W.Handle<S>> -> Q}
def commands(~S:Data,~Q:Type,~route:Layout.Route,~enqueue:Q -> Layout.Route -> O.Operation<S> -> Q) -> Commands<Q,S>:
  Commands{queue => source => target => enqueue(queue,route,O.Relate{source,target}),queue => source => enqueue(queue,route,O.Unrelate{source})}
def hierarchy(~S:Data,~Q:Type,~route:Layout.Route,~enqueue:Q -> Layout.Route -> O.Operation<S> -> Q) -> HierarchyCommands<Q,S>:
  HierarchyCommands{commands(~S,~Q,~route,~enqueue),queue => parent => children => enqueue(queue,route,O.Reorder{parent,children})}
def relate_field(~S:Data,~Q:Type,cap:Commands<Q,S>) -> Q -> W.Handle<S> -> W.Handle<S> -> Q:
  match cap:
    case Commands{relate,_}:relate
def unrelate_field(~S:Data,~Q:Type,cap:Commands<Q,S>) -> Q -> W.Handle<S> -> Q:
  match cap:
    case Commands{_,unrelate}:unrelate
def relations_field(~S:Data,~Q:Type,cap:HierarchyCommands<Q,S>) -> Commands<Q,S>:
  match cap:
    case HierarchyCommands{relations,_}:relations
def reorder_field(~S:Data,~Q:Type,cap:HierarchyCommands<Q,S>) -> Q -> W.Handle<S> -> List<&2,W.Handle<S>> -> Q:
  match cap:
    case HierarchyCommands{_,reorder}:reorder
