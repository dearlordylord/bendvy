import Base
import ../../../../../src/ecs/restore-graph-data.bend as R
import ../../../../../src/ecs/entity-key.bend as Key
import ../../../../../src/ecs/snapshot-data.bend as Basic
import ../../../../../src/ecs/relation-types.bend as G
import ../../../../../src/ecs/relation-graph.bend as Graph
import ../../../../../src/ecs/relation-failure-reader.bend as Ordinary

def contains(+key:Key.Key,entities:List<&2,Basic.Entity>) -> Bool:
  match entities:
    case []:False{}
    case Basic.Entity{other,_} <> rest:Bool.or(Key.equal(key,other),contains(key,rest))
def descriptor_found(~S:Data,found:Bool,descriptor:G.Descriptor<S>,next:Unit -> Maybe<&2,G.Descriptor<S>>) -> Maybe<&2,G.Descriptor<S>>:
  match found:
    case True{}:Some{descriptor}
    case False{}:next(Unit{})
def descriptor(~S:Data,+name:String,declarations:List<&2,Ordinary.Declaration<S>>) -> Maybe<&2,G.Descriptor<S>>:
  match declarations:
    case []:None{}
    case Ordinary.Declaration{+value} <> rest:descriptor_found(~S,String.eq(name,Graph.name(~S,value)),value,_ => descriptor(~S,name,rest))
def absent(~S:Data,value:Maybe<&2,Key.Key>) -> Bool:
  match value:
    case None{}:True{}
    case Some{_}:False{}
def added(~S:Data,graph:G.Graph<S>,descriptor:G.Descriptor<S>,source:Key.Key,target:Key.Key) -> G.Graph<S>:
  match graph:
    case G.Graph{edges,inverses}:Graph.updated(~S,False{},edges,inverses,descriptor,source,target)
def source_checked(~S:Data,valid:Bool,graph:G.Graph<S>,descriptor:G.Descriptor<S>,source:Key.Key,target:Key.Key,next:G.Graph<S> -> R.GraphResult<S>) -> R.GraphResult<S>:
  match valid:
    case False{}:R.Rejected{R.InvalidRelation{Graph.name(~S,descriptor),source,target}}
    case True{}:next(added(~S,graph,descriptor,source,target))
def sources(~S:Data,values:List<&2,Key.Key>,+target:Key.Key,+descriptor:G.Descriptor<S>,+entities:List<&2,Basic.Entity>,+graph:G.Graph<S>,next:G.Graph<S> -> R.GraphResult<S>) -> R.GraphResult<S>:
  match values:
    case []:next(graph)
    case +source <> rest:source_checked(~S,Bool.and(contains(source,entities),Bool.and(contains(target,entities),Bool.and(Bool.not(Key.equal(source,target)),absent(~S,Graph.target(~S,graph,descriptor,source))))),graph,descriptor,source,target,graph => sources(~S,rest,target,descriptor,entities,graph,next))
def groups(~S:Data,values:List<&2,R.Group>,+descriptor:G.Descriptor<S>,+entities:List<&2,Basic.Entity>,graph:G.Graph<S>,next:G.Graph<S> -> R.GraphResult<S>) -> R.GraphResult<S>:
  match values:
    case []:next(graph)
    case R.Group{target,members} <> rest:sources(~S,members,target,descriptor,entities,graph,graph => groups(~S,rest,descriptor,entities,graph,next))
def cycle_checked(~S:Data,cyclic:Bool,descriptor:G.Descriptor<S>,source:Key.Key,target:Key.Key,next:Unit -> R.GraphResult<S>) -> R.GraphResult<S>:
  match cyclic:
    case True{}:R.Rejected{R.InvalidRelation{Graph.name(~S,descriptor),source,target}}
    case False{}:next(Unit{})
def cycles(~S:Data,edges:List<&2,G.Edge<S>>,+graph:G.Graph<S>,next:Unit -> R.GraphResult<S>) -> R.GraphResult<S>:
  match edges:
    case []:next(Unit{})
    case G.Edge{+descriptor,+source,+target} <> rest:cycle_checked(~S,False{},descriptor,source,target,_ => cycles(~S,rest,graph,next))
def acyclic(~S:Data,+graph:G.Graph<S>,next:G.Graph<S> -> R.GraphResult<S>) -> R.GraphResult<S>:
  match graph:
    case G.Graph{+edges,+inverses}:cycles(~S,edges,G.Graph{edges,inverses},_ => next(G.Graph{edges,inverses}))
def declared(~S:Data,name:String,values:List<&2,R.Group>,entities:List<&2,Basic.Entity>,graph:G.Graph<S>,next:G.Graph<S> -> R.GraphResult<S>,found:Maybe<&2,G.Descriptor<S>>) -> R.GraphResult<S>:
  match found:
    case None{}:R.Rejected{R.UnknownRelation{name}}
    case Some{descriptor}:groups(~S,values,descriptor,entities,graph,graph => acyclic(~S,graph,next))
def relations(~S:Data,values:List<&2,R.Relation>,+entities:List<&2,Basic.Entity>,+declarations:List<&2,Ordinary.Declaration<S>>,graph:G.Graph<S>) -> R.GraphResult<S>:
  match values:
    case []:R.Accepted{graph}
    case R.Relation{+name,groups} <> rest:declared(~S,name,groups,entities,graph,graph => relations(~S,rest,entities,declarations,graph),descriptor(~S,name,declarations))
def validate(~S:Data,values:List<&2,R.Relation>,entities:List<&2,Basic.Entity>,declarations:List<&2,Ordinary.Declaration<S>>) -> R.GraphResult<S>:
  relations(~S,values,entities,declarations,G.Graph{[],[]})
