import Base
import ./relation-types.bend as G
import ./relation-graph.bend as Graph

# Raw graph helpers are trusted setup, not gameplay authority. Valid hierarchy
# edges have one parent per source and no cycle; traversal uses E+1 small fuel.
# Unsupported forged cyclic graph traversal remains an incomplete diagnostic.
type Order is Data:
  Depth{}
  Breadth{}
type Walk is Data:
  Complete{ids:List<&2,U32>}
  Incomplete{ids:List<&2,U32>,pending:List<&2,U32>}
def budget(~S:Data,graph:G.Graph<S>) -> Nat:
  match graph:
    case G.Graph{edges,_}: 1n+List.length(&2,G.Edge<S>,edges)
def finished(acc:List<&2,U32>,pending:List<&2,U32>) -> Walk:
  match pending:
    case []: Complete{List.reverse(&2,U32,acc)}
    case pending: Incomplete{List.reverse(&2,U32,acc),pending}
def enqueue(order:Order,children:List<&2,U32>,rest:List<&2,U32>) -> List<&2,U32>:
  match order:
    case Depth{}: List.append(&2,U32,children,rest)
    case Breadth{}: List.append(&2,U32,rest,children)
def next_desc(~S:Data,graph:G.Graph<S>,descriptor:G.Descriptor<S>,order:Order,state:List<&2,U32> & List<&2,U32>) -> List<&2,U32> & List<&2,U32>:
  match state:
    case ([],acc): ([],acc)
    case (+id <> rest,acc): (enqueue(order,Graph.inverse(~S,graph,descriptor,id),rest),id <> acc)
def descendants_loop(~S:Data,n:Nat,state:List<&2,U32> & List<&2,U32>,+graph:G.Graph<S>,+descriptor:G.Descriptor<S>,+order:Order) -> Walk:
  match n state:
    case 0n Tuple{pending,acc}: finished(acc,pending)
    case 1n+rest Tuple{[],acc}: Complete{List.reverse(&2,U32,acc)}
    case 1n+rest state: descendants_loop(~S,rest,next_desc(~S,graph,descriptor,order,state),graph,descriptor,order)
def descendants(~S:Data,+graph:G.Graph<S>,+descriptor:G.Descriptor<S>,target:U32,order:Order) -> Walk:
  descendants_loop(~S,budget(~S,graph),(Graph.inverse(~S,graph,descriptor,target),[]),graph,descriptor,order)
def next_ancestor(~S:Data,graph:G.Graph<S>,descriptor:G.Descriptor<S>,state:Maybe<&2,U32> & List<&2,U32>) -> Maybe<&2,U32> & List<&2,U32>:
  match state:
    case (None{},acc): (None{},acc)
    case (Some{+id},acc): (Graph.target(~S,graph,descriptor,id),id <> acc)
def ancestor_finished(state:Maybe<&2,U32> & List<&2,U32>) -> Walk:
  match state:
    case (None{},acc): Complete{List.reverse(&2,U32,acc)}
    case (Some{id},acc): Incomplete{List.reverse(&2,U32,acc),[id]}
def ancestors_loop(~S:Data,n:Nat,state:Maybe<&2,U32> & List<&2,U32>,+graph:G.Graph<S>,+descriptor:G.Descriptor<S>) -> Walk:
  match n state:
    case 0n state: ancestor_finished(state)
    case 1n+rest Tuple{None{},acc}: Complete{List.reverse(&2,U32,acc)}
    case 1n+rest state: ancestors_loop(~S,rest,next_ancestor(~S,graph,descriptor,state),graph,descriptor)
def ancestors(~S:Data,+graph:G.Graph<S>,+descriptor:G.Descriptor<S>,target:U32) -> Walk:
  ancestors_loop(~S,budget(~S,graph),(Graph.target(~S,graph,descriptor,target),[]),graph,descriptor)
def root_ids(ids:List<&2,U32>,current:U32) -> U32:
  match ids:
    case []: current
    case id <> rest: root_ids(rest,id)
def root(walk:Walk,target:U32) -> Maybe<&2,U32>:
  match walk:
    case Complete{ids}: Some{root_ids(ids,target)}
    case _: None{}
