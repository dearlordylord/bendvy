import Base
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import owners.bend as O

def show_edges(~S:Data,edges:List<&2,G.Edge<S>>) -> String:
  match edges:
    case []: ""
    case G.Edge{G.Descriptor{key,_,_,_},source,target} <> rest: U32.show(key) ++ ":" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ";" ++ show_edges(~S,rest)
def graph_edges(~S:Data,graph:G.Graph<S>) -> String:
  match graph:
    case G.Graph{edges,_}: show_edges(~S,edges)
def show_descriptor(~S:Data,d:G.Descriptor<S>) -> String:
  match d:
    case G.Descriptor{key,name,inverse,kind}: U32.show(key) ++ ":" ++ name ++ ":" ++ inverse ++ ":" ++ O.show_kind(kind)
def full_edges(~S:Data,edges:List<&2,G.Edge<S>>) -> String:
  match edges:
    case []: ""
    case G.Edge{d,source,target} <> rest: show_descriptor(~S,d) ++ ":" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ";" ++ full_edges(~S,rest)
def full_inverses(~S:Data,inverses:List<&2,G.Inverse<S>>) -> String:
  match inverses:
    case []: ""
    case G.Inverse{d,target,sources} <> rest: show_descriptor(~S,d) ++ ":" ++ U32.show(target) ++ ":[" ++ O.show_ids(sources) ++ "];" ++ full_inverses(~S,rest)
def full_graph(~S:Data,graph:G.Graph<S>) -> String:
  match graph:
    case G.Graph{edges,inverses}: "graph-edges=" ++ full_edges(~S,edges) ++ "|graph-inverses=" ++ full_inverses(~S,inverses)
def edge_observer(~S:Data,store:A.Store<S,O.Components<S>>) -> A.Store<S,O.Components<S>> & String:
  match store:
    case A.Store{components,+graph}: (A.Store{components,graph},full_graph(~S,graph))
def observed(~S:Data,value:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,edges:String) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  (world,value) = value
  (world,value ++ "|edges=" ++ edges)
def show_bool(value:Bool) -> String:
  match value:
    case True{}: "1,"
    case False{}: "0,"
def live_return(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,head:String) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  (world,tail) = result
  (world,head ++ tail)
def live_next(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & Bool,next:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  (world,value) = result
  live_return(~S,next(world),show_bool(value))
def lives(~S:Data,n:Nat,world:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,+id:U32) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  match n:
    case 0n: (world,"")
    case 1n+rest: live_next(~S,W.valid(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,world,W.Handle{1,id}),world => lives(~S,rest,world,U32.add(id,1)))
def live_done(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String,edges:String) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  (world,values) = result
  observed(~S,O.observe_complete(~S,world),edges ++ "|live=" ++ values)
def edges_done(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  (world,edges) = result
  live_done(~S,lives(~S,16n,world,0),edges)
def observe(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>> & String:
  edges_done(~S,W.with_store(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~String,edge_observer(~S),world))
