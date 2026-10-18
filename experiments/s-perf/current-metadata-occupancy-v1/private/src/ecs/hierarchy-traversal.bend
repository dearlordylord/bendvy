import Base
import entity-key.bend as K
import ./relation-types.bend as G
import ./relation-graph.bend as Graph

# Raw graph helpers are trusted setup, not gameplay authority. Valid hierarchy
# edges have one parent per source and no cycle; traversal uses E+1 small fuel.
# Unsupported forged cyclic graph traversal remains an incomplete diagnostic.
type Order is Data:
  Depth{}
  Breadth{}
type Walk is Data:
  Complete{ids:List<&2,K.Key>}
  Incomplete{ids:List<&2,K.Key>,pending:List<&2,K.Key>}
def budget(~S:Data,graph:G.Graph<S>) -> Nat:
  match graph:
    case G.Graph{edges,_}: 1n+List.length(&2,G.Edge<S>,edges)
def finished(acc:List<&2,K.Key>,pending:List<&2,K.Key>) -> Walk:
  match pending:
    case []: Complete{List.reverse(&2,K.Key,acc)}
    case pending: Incomplete{List.reverse(&2,K.Key,acc),pending}
def enqueue(order:Order,children:List<&2,K.Key>,rest:List<&2,K.Key>) -> List<&2,K.Key>:
  match order:
    case Depth{}: List.append(&2,K.Key,children,rest)
    case Breadth{}: List.append(&2,K.Key,rest,children)
def next_desc(~S:Data,graph:G.Graph<S>,descriptor:G.Descriptor<S>,order:Order,state:List<&2,K.Key> & List<&2,K.Key>) -> List<&2,K.Key> & List<&2,K.Key>:
  match state:
    case ([],acc): ([],acc)
    case (+id <> rest,acc): (enqueue(order,Graph.inverse(~S,graph,descriptor,id),rest),id <> acc)
def descendants_loop(~S:Data,n:Nat,state:List<&2,K.Key> & List<&2,K.Key>,+graph:G.Graph<S>,+descriptor:G.Descriptor<S>,+order:Order) -> Walk:
  match n state:
    case 0n Tuple{pending,acc}: finished(acc,pending)
    case 1n+rest Tuple{[],acc}: Complete{List.reverse(&2,K.Key,acc)}
    case 1n+rest state: descendants_loop(~S,rest,next_desc(~S,graph,descriptor,order,state),graph,descriptor,order)
def descendants(~S:Data,+graph:G.Graph<S>,+descriptor:G.Descriptor<S>,target:K.Key,order:Order) -> Walk:
  descendants_loop(~S,budget(~S,graph),(Graph.inverse(~S,graph,descriptor,target),[]),graph,descriptor,order)
def next_ancestor(~S:Data,graph:G.Graph<S>,descriptor:G.Descriptor<S>,state:Maybe<&2,K.Key> & List<&2,K.Key>) -> Maybe<&2,K.Key> & List<&2,K.Key>:
  match state:
    case (None{},acc): (None{},acc)
    case (Some{+id},acc): (Graph.target(~S,graph,descriptor,id),id <> acc)
def ancestor_finished(state:Maybe<&2,K.Key> & List<&2,K.Key>) -> Walk:
  match state:
    case (None{},acc): Complete{List.reverse(&2,K.Key,acc)}
    case (Some{id},acc): Incomplete{List.reverse(&2,K.Key,acc),[id]}
def ancestors_loop(~S:Data,n:Nat,state:Maybe<&2,K.Key> & List<&2,K.Key>,+graph:G.Graph<S>,+descriptor:G.Descriptor<S>) -> Walk:
  match n state:
    case 0n state: ancestor_finished(state)
    case 1n+rest Tuple{None{},acc}: Complete{List.reverse(&2,K.Key,acc)}
    case 1n+rest state: ancestors_loop(~S,rest,next_ancestor(~S,graph,descriptor,state),graph,descriptor)
def ancestors(~S:Data,+graph:G.Graph<S>,+descriptor:G.Descriptor<S>,target:K.Key) -> Walk:
  ancestors_loop(~S,budget(~S,graph),(Graph.target(~S,graph,descriptor,target),[]),graph,descriptor)
def root_ids(ids:List<&2,K.Key>,current:K.Key) -> K.Key:
  match ids:
    case []: current
    case id <> rest: root_ids(rest,id)
def root(walk:Walk,target:K.Key) -> Maybe<&2,K.Key>:
  match walk:
    case Complete{ids}: Some{root_ids(ids,target)}
    case _: None{}
