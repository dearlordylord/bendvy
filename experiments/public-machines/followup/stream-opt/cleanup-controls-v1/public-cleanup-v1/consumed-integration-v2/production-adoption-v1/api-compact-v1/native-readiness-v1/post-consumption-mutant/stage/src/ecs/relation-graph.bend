import Base
import relation-types.bend as T

# Experimental maintained inverse implementation. Does not call graph-spec.
def key(~S: Data,descriptor: T.Descriptor<S>) -> U32:
  match descriptor:
    case T.Descriptor{key,_,_,_}: key
def name(~S: Data,descriptor: T.Descriptor<S>) -> String:
  match descriptor:
    case T.Descriptor{_,name,_,_}: name
def contains(xs: List<&2,U32>,+id: U32) -> Bool:
  match xs:
    case []: False{}
    case x <> rest: Bool.or(U32.is_eq(x,id),contains(rest,id))
def removed_id(remove: Bool,id: U32,rest: List<&2,U32>) -> List<&2,U32>:
  match remove:
    case True{}: rest
    case False{}: id <> rest
def remove_id(xs: List<&2,U32>,+id: U32) -> List<&2,U32>:
  match xs:
    case []: []
    case +x <> rest: removed_id(U32.is_eq(x,id),x,remove_id(rest,id))
def chosen_target(found: Bool,target: U32,next: Unit -> Maybe<&2,U32>) -> Maybe<&2,U32>:
  match found:
    case True{}: Some{target}
    case False{}: next(Unit{})
def target_edges(~S: Data,edges: List<&2,T.Edge<S>>,+descriptor: T.Descriptor<S>,+source: U32) -> Maybe<&2,U32>:
  match edges:
    case []: None{}
    case T.Edge{other,id,target} <> rest: chosen_target(Bool.and(U32.is_eq(key(~S,other),key(~S,descriptor)),U32.is_eq(id,source)),target,_ => target_edges(~S,rest,descriptor,source))
def target(~S: Data,graph: T.Graph<S>,descriptor: T.Descriptor<S>,source: U32) -> Maybe<&2,U32>:
  match graph:
    case T.Graph{edges,_}: target_edges(~S,edges,descriptor,source)
def chosen_inverse(found: Bool,sources: List<&2,U32>,next: Unit -> List<&2,U32>) -> List<&2,U32>:
  match found:
    case True{}: sources
    case False{}: next(Unit{})
def inverse_entries(~S: Data,entries: List<&2,T.Inverse<S>>,+descriptor: T.Descriptor<S>,+target: U32) -> List<&2,U32>:
  match entries:
    case []: []
    case T.Inverse{other,id,sources} <> rest: chosen_inverse(Bool.and(U32.is_eq(key(~S,other),key(~S,descriptor)),U32.is_eq(id,target)),sources,_ => inverse_entries(~S,rest,descriptor,target))
def inverse(~S: Data,graph: T.Graph<S>,descriptor: T.Descriptor<S>,target: U32) -> List<&2,U32>:
  match graph:
    case T.Graph{_,entries}: inverse_entries(~S,entries,descriptor,target)
def edge_removed(~S: Data,remove: Bool,edge: T.Edge<S>,rest: List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  match remove:
    case True{}: rest
    case False{}: edge <> rest
def remove_edge_fields(~S: Data,edge: T.Edge<S>,+descriptor: T.Descriptor<S>,source: U32,next: Unit -> List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  match edge:
    case T.Edge{+other,+id,+target}: edge_removed(~S,Bool.and(U32.is_eq(key(~S,other),key(~S,descriptor)),U32.is_eq(id,source)),T.Edge{other,id,target},next(Unit{}))
def remove_edge_keep(~S:Data,edge:T.Edge<S>,+descriptor:T.Descriptor<S>,source:U32,acc:List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  match edge:
    case T.Edge{+other,+id,+target}: edge_removed(~S,Bool.and(U32.is_eq(key(~S,other),key(~S,descriptor)),U32.is_eq(id,source)),T.Edge{other,id,target},acc)
def remove_edge_acc(~S:Data,edges:List<&2,T.Edge<S>>,+descriptor:T.Descriptor<S>,+source:U32,acc:List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  match edges:
    case []: List.reverse(&2,T.Edge<S>,acc)
    case +edge <> rest: remove_edge_acc(~S,rest,descriptor,source,remove_edge_keep(~S,edge,descriptor,source,acc))
def remove_edge(~S: Data,edges: List<&2,T.Edge<S>>,descriptor: T.Descriptor<S>,source: U32) -> List<&2,T.Edge<S>>:
  remove_edge_acc(~S,edges,descriptor,source,[])
def nonempty_inverse(~S: Data,descriptor: T.Descriptor<S>,target: U32,sources: List<&2,U32>,rest: List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  match sources:
    case []: rest
    case head <> tail: T.Inverse{descriptor,target,head <> tail} <> rest
def inverse_remove_one(~S: Data,matched: Bool,descriptor: T.Descriptor<S>,target: U32,sources: List<&2,U32>,source: U32,rest: List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  match matched:
    case True{}: nonempty_inverse(~S,descriptor,target,remove_id(sources,source),rest)
    case False{}: T.Inverse{descriptor,target,sources} <> rest
def inverse_remove_acc(~S:Data,entries:List<&2,T.Inverse<S>>,+descriptor:T.Descriptor<S>,+target:U32,+source:U32,acc:List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  match entries:
    case []: List.reverse(&2,T.Inverse<S>,acc)
    case T.Inverse{+other,+id,sources} <> rest: inverse_remove_acc(~S,rest,descriptor,target,source,inverse_remove_one(~S,Bool.and(U32.is_eq(key(~S,other),key(~S,descriptor)),U32.is_eq(id,target)),other,id,sources,source,acc))
def inverse_remove(~S: Data,entries: List<&2,T.Inverse<S>>,descriptor: T.Descriptor<S>,target: U32,source: U32) -> List<&2,T.Inverse<S>>:
  inverse_remove_acc(~S,entries,descriptor,target,source,[])
def remove_previous(~S: Data,previous: Maybe<&2,U32>,entries: List<&2,T.Inverse<S>>,descriptor: T.Descriptor<S>,source: U32) -> List<&2,T.Inverse<S>>:
  match previous:
    case None{}: entries
    case Some{target}: inverse_remove(~S,entries,descriptor,target,source)
def appended_source(present: Bool,sources: List<&2,U32>,source: U32) -> List<&2,U32>:
  match present:
    case True{}: sources
    case False{}: List.append(&2,U32,sources,[source])
def inverse_add_found(~S: Data,found: Bool,other: T.Descriptor<S>,id: U32,+sources: List<&2,U32>,+descriptor: T.Descriptor<S>,target: U32,+source: U32,rest: List<&2,T.Inverse<S>>,next: Unit -> List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  match found:
    case True{}: T.Inverse{other,id,appended_source(contains(sources,source),sources,source)} <> rest
    case False{}: T.Inverse{other,id,sources} <> next(Unit{})
def inverse_add(~S: Data,entries: List<&2,T.Inverse<S>>,+descriptor: T.Descriptor<S>,+target: U32,+source: U32) -> List<&2,T.Inverse<S>>:
  match entries:
    case []: [T.Inverse{descriptor,target,[source]}]
    case T.Inverse{+other,+id,+sources} <> +rest: inverse_add_found(~S,Bool.and(U32.is_eq(key(~S,other),key(~S,descriptor)),U32.is_eq(id,target)),other,id,sources,descriptor,target,source,rest,_ => inverse_add(~S,rest,descriptor,target,source))
def unrelate(~S: Data,graph: T.Graph<S>,+descriptor: T.Descriptor<S>,+source: U32) -> T.Graph<S>:
  match graph:
    case T.Graph{+edges,inverses}: T.Graph{remove_edge(~S,edges,descriptor,source),remove_previous(~S,target_edges(~S,edges,descriptor,source),inverses,descriptor,source)}
def next_cycle(~S: Data,current: Maybe<&2,U32>,next: U32 -> Bool) -> Bool:
  match current:
    case None{}: False{}
    case Some{id}: next(id)
def cycle_loop(~S: Data,fuel: Nat,+graph: T.Graph<S>,+descriptor: T.Descriptor<S>,+source: U32,+current: U32) -> Bool:
  match fuel:
    case 0n: U32.is_eq(source,current)
    case 1n+rest: Bool.or(U32.is_eq(source,current),next_cycle(~S,target(~S,graph,descriptor,current),id => cycle_loop(~S,rest,graph,descriptor,source,id)))
def cycle(~S: Data,+graph: T.Graph<S>,descriptor: T.Descriptor<S>,source: U32,target: U32) -> Bool:
  match graph descriptor:
    case T.Graph{edges,inverses} T.Descriptor{k,n,inv,T.Ordinary{}}: False{}
    case T.Graph{+edges,+inverses} T.Descriptor{+k,+n,+inv,T.Hierarchy{}}: cycle_loop(~S,List.length(&2,T.Edge<S>,edges),T.Graph{edges,inverses},T.Descriptor{k,n,inv,T.Hierarchy{}},source,target)
def validation(sourceLive: Bool,targetLive: Bool,self: Bool,cyclic: Bool,source: U32,target: U32,name: String) -> Maybe<&2,T.Error>:
  match sourceLive targetLive self cyclic:
    case False{} _ _ _: Some{T.MissingEntity{source}}
    case True{} False{} _ _: Some{T.MissingTargetEntity{source,target,name}}
    case True{} True{} True{} _: Some{T.SelfRelationNotAllowed{source,name}}
    case True{} True{} False{} True{}: Some{T.HierarchyCycle{source,target,name}}
    case True{} True{} False{} False{}: None{}
def already(previous: Maybe<&2,U32>,target: U32) -> Bool:
  match previous:
    case None{}: False{}
    case Some{id}: U32.is_eq(id,target)
def updated(~S: Data,same: Bool,+edges: List<&2,T.Edge<S>>,inverses: List<&2,T.Inverse<S>>,+descriptor: T.Descriptor<S>,+source: U32,+target: U32) -> T.Graph<S>:
  match same:
    case True{}: T.Graph{edges,inverses}
    case False{}: T.Graph{List.append(&2,T.Edge<S>,remove_edge(~S,edges,descriptor,source),[T.Edge{descriptor,source,target}]),inverse_add(~S,remove_previous(~S,target_edges(~S,edges,descriptor,source),inverses,descriptor,source),descriptor,target,source)}
def checked(~S: Data,error: Maybe<&2,T.Error>,graph: T.Graph<S>,+descriptor: T.Descriptor<S>,+source: U32,+target: U32) -> T.CoreResult<S>:
  match error graph:
    case Some{error} graph: T.CoreResult{graph,Some{error}}
    case None{} T.Graph{+edges,inverses}: T.CoreResult{updated(~S,already(target_edges(~S,edges,descriptor,source),target),edges,inverses,descriptor,source,target),None{}}
def relate(~S: Data,+graph: T.Graph<S>,+descriptor: T.Descriptor<S>,+source: U32,+target: U32,sourceLive: Bool,targetLive: Bool) -> T.CoreResult<S>:
  checked(~S,validation(sourceLive,targetLive,U32.is_eq(source,target),cycle(~S,graph,descriptor,source,target),source,target,name(~S,descriptor)),graph,descriptor,source,target)
def project(~S: Data,graph: T.Graph<S>) -> T.SpecGraph<S>:
  match graph:
    case T.Graph{edges,_}: T.SpecGraph{edges}
