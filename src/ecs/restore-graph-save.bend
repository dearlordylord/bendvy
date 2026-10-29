import Base
import ./restore-graph-data.bend as R
import ./entity-key.bend as Key
import ./relation-types.bend as G
import ./relation-graph.bend as Graph
import ./relation-failure-reader.bend as Ordinary

def included(found:Bool,target:Key.Key,sources:List<&2,Key.Key>,rest:List<&2,R.Group>) -> List<&2,R.Group>:
  match found:
    case True{}:R.Group{target,sources} <> rest
    case False{}:rest
def groups(~S:Data,entries:List<&2,G.Inverse<S>>,+descriptor:G.Descriptor<S>) -> List<&2,R.Group>:
  match entries:
    case []:[]
    case G.Inverse{other,target,sources} <> rest:included(U32.is_eq(Graph.key(~S,descriptor),Graph.key(~S,other)),target,sources,groups(~S,rest,descriptor))
def relations(~S:Data,declarations:List<&2,Ordinary.Declaration<S>>,+graph:G.Graph<S>) -> List<&2,R.Relation>:
  match declarations graph:
    case [] _:[]
    case Ordinary.Declaration{+descriptor} <> rest G.Graph{+edges,+inverses}:R.Relation{Graph.name(~S,descriptor),groups(~S,inverses,descriptor)} <> relations(~S,rest,G.Graph{edges,inverses})
