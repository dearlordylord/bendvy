import Base
import types.bend as T

# Independent slow specification: one chronological authoritative edge list.
# Inverses are reconstructed, never maintained as a second source of truth.
def key(~S: Data,descriptor: T.Descriptor<S>) -> U32:
  match descriptor:
    case T.Descriptor{key,_,_,_}: key
def name(~S: Data,descriptor: T.Descriptor<S>) -> String:
  match descriptor:
    case T.Descriptor{_,name,_,_}: name
def contains(xs: List<&2,U32>,+needle: U32) -> Bool:
  match xs:
    case []: False{}
    case x <> rest: Bool.or(U32.is_eq(x,needle),contains(rest,needle))
def source_chosen(same: Bool,target: U32,rest: Unit -> Maybe<&2,U32>) -> Maybe<&2,U32>:
  match same:
    case True{}: Some{target}
    case False{}: rest(Unit{})
def target_edges(~S: Data,edges: List<&2,T.Edge<S>>,+descriptor: T.Descriptor<S>,+source: U32) -> Maybe<&2,U32>:
  match edges:
    case []: None{}
    case T.Edge{other,id,target} <> rest: source_chosen(Bool.and(U32.is_eq(key(~S,descriptor),key(~S,other)),U32.is_eq(source,id)),target,_ => target_edges(~S,rest,descriptor,source))
def target(~S: Data,graph: T.SpecGraph<S>,descriptor: T.Descriptor<S>,source: U32) -> Maybe<&2,U32>:
  match graph:
    case T.SpecGraph{edges}: target_edges(~S,edges,descriptor,source)
def inverse_selected(selected: Bool,source: U32,rest: List<&2,U32>) -> List<&2,U32>:
  match selected:
    case True{}: source <> rest
    case False{}: rest
def inverse_edges(~S: Data,edges: List<&2,T.Edge<S>>,+descriptor: T.Descriptor<S>,+target: U32) -> List<&2,U32>:
  match edges:
    case []: []
    case T.Edge{other,source,id} <> rest: inverse_selected(Bool.and(U32.is_eq(key(~S,descriptor),key(~S,other)),U32.is_eq(target,id)),source,inverse_edges(~S,rest,descriptor,target))
def inverse(~S: Data,graph: T.SpecGraph<S>,descriptor: T.Descriptor<S>,target: U32) -> List<&2,U32>:
  match graph:
    case T.SpecGraph{edges}: inverse_edges(~S,edges,descriptor,target)
def removed_selected(~S: Data,remove: Bool,edge: T.Edge<S>,rest: List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  match remove:
    case True{}: rest
    case False{}: edge <> rest
def remove_source(~S: Data,edges: List<&2,T.Edge<S>>,+descriptor: T.Descriptor<S>,+source: U32) -> List<&2,T.Edge<S>>:
  match edges:
    case []: []
    case T.Edge{+other,+id,+target} <> rest: removed_selected(~S,Bool.and(U32.is_eq(key(~S,descriptor),key(~S,other)),U32.is_eq(source,id)),T.Edge{other,id,target},remove_source(~S,rest,descriptor,source))
def unrelate(~S: Data,graph: T.SpecGraph<S>,descriptor: T.Descriptor<S>,source: U32) -> T.SpecGraph<S>:
  match graph:
    case T.SpecGraph{edges}: T.SpecGraph{remove_source(~S,edges,descriptor,source)}
def next_cycle(~S: Data,current: Maybe<&2,U32>,next: U32 -> Bool) -> Bool:
  match current:
    case None{}: False{}
    case Some{id}: next(id)
def cycle_at(~S: Data,fuel: Nat,+graph: T.SpecGraph<S>,+descriptor: T.Descriptor<S>,+source: U32,+current: U32) -> Bool:
  match fuel:
    case 0n: U32.is_eq(source,current)
    case 1n+rest: Bool.or(U32.is_eq(source,current),next_cycle(~S,target(~S,graph,descriptor,current),id => cycle_at(~S,rest,graph,descriptor,source,id)))
def cycle(~S: Data,+graph: T.SpecGraph<S>,+descriptor: T.Descriptor<S>,+source: U32,target: U32) -> Bool:
  match graph descriptor:
    case T.SpecGraph{+edges} T.Descriptor{+k,+n,+inv,T.Ordinary{}}: False{}
    case T.SpecGraph{+edges} T.Descriptor{+k,+n,+inv,T.Hierarchy{}}: cycle_at(~S,List.length(&2,T.Edge<S>,edges),T.SpecGraph{edges},T.Descriptor{k,n,inv,T.Hierarchy{}},source,target)
def validation(sourceLive: Bool,targetLive: Bool,self: Bool,cyclic: Bool,source: U32,target: U32,+name: String) -> Maybe<&2,T.Error>:
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
def success(~S: Data,same: Bool,edges: List<&2,T.Edge<S>>,+descriptor: T.Descriptor<S>,+source: U32,target: U32) -> T.SpecGraph<S>:
  match same:
    case True{}: T.SpecGraph{edges}
    case False{}: T.SpecGraph{List.append(&2,T.Edge<S>,remove_source(~S,edges,descriptor,source),[T.Edge{descriptor,source,target}])}
def apply_checked(~S: Data,error: Maybe<&2,T.Error>,+graph: T.SpecGraph<S>,+descriptor: T.Descriptor<S>,+source: U32,+target: U32) -> T.SpecResult<S>:
  match error graph:
    case Some{error} graph: T.SpecResult{graph,Some{error}}
    case None{} T.SpecGraph{+edges}: T.SpecResult{success(~S,already(target_edges(~S,edges,descriptor,source),target),edges,descriptor,source,target),None{}}
def relate(~S: Data,+graph: T.SpecGraph<S>,+descriptor: T.Descriptor<S>,+source: U32,+target: U32,sourceLive: Bool,targetLive: Bool) -> T.SpecResult<S>:
  apply_checked(~S,validation(sourceLive,targetLive,U32.is_eq(source,target),cycle(~S,graph,descriptor,source,target),source,target,name(~S,descriptor)),graph,descriptor,source,target)
