import Base
import ../../../../../src/ecs/entity-key.bend as Key
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/restore-data.bend as Basic
import ../../../../../src/ecs/relation-types.bend as G
import ../../../../../src/ecs/relation-graph.bend as Graph

type Mapped<S:Data> is Data:
  Mapped{graph:G.Graph<S>}
  MissingBinding{saved:Key.Key}
def target(~S:Data,descriptor:G.Descriptor<S>,source:W.Handle<S>,saved:Key.Key,result:Maybe<&2,W.Handle<S>>,graph:G.Graph<S>,next:G.Graph<S> -> Mapped<S>) -> Mapped<S>:
  match source result graph:
    case _ None{} _:MissingBinding{saved}
    case W.Handle{_,source} Some{W.Handle{_,target}} G.Graph{edges,inverses}:next(Graph.updated(~S,False{},edges,inverses,descriptor,source,target))
def source(~S:Data,descriptor:G.Descriptor<S>,saved:Key.Key,+other:Key.Key,+bindings:List<&2,Basic.Binding<S>>,result:Maybe<&2,W.Handle<S>>,graph:G.Graph<S>,next:G.Graph<S> -> Mapped<S>) -> Mapped<S>:
  match result:
    case None{}:MissingBinding{saved}
    case Some{handle}:target(~S,descriptor,handle,other,Basic.lookup(~S,other,bindings),graph,next)
def edges(~S:Data,values:List<&2,G.Edge<S>>,+bindings:List<&2,Basic.Binding<S>>,graph:G.Graph<S>) -> Mapped<S>:
  match values:
    case []:Mapped{graph}
    case G.Edge{descriptor,+saved,other} <> rest:source(~S,descriptor,saved,other,bindings,Basic.lookup(~S,saved,bindings),graph,graph => edges(~S,rest,bindings,graph))
def remap(~S:Data,graph:G.Graph<S>,bindings:List<&2,Basic.Binding<S>>) -> Mapped<S>:
  match graph:
    case G.Graph{values,_}:edges(~S,List.reverse(&2,G.Edge<S>,values),bindings,G.Graph{[],[]})
