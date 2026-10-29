import Base
import entity-key.bend as K
import relation-types.bend as T

# Experimental maintained inverse implementation. Does not call graph-spec.
def key_erased(-S: Data,descriptor: T.Descriptor<S>) -> U32:
  match descriptor:
    case T.Descriptor{key,_,_,_}: key
def name_erased(-S: Data,descriptor: T.Descriptor<S>) -> String:
  match descriptor:
    case T.Descriptor{_,name,_,_}: name
def contains(xs: List<&2,K.Key>,+id: K.Key) -> Bool:
  match xs:
    case []: False{}
    case x <> rest: Bool.or(K.equal(x,id),contains(rest,id))
def removed_id(remove: Bool,id: K.Key,rest: List<&2,K.Key>) -> List<&2,K.Key>:
  match remove:
    case True{}: rest
    case False{}: id <> rest
def remove_id(xs: List<&2,K.Key>,+id: K.Key) -> List<&2,K.Key>:
  match xs:
    case []: []
    case +x <> rest: removed_id(K.equal(x,id),x,remove_id(rest,id))
def chosen_target(found: Bool,target: K.Key,next: Unit -> Maybe<&2,K.Key>) -> Maybe<&2,K.Key>:
  match found:
    case True{}: Some{target}
    case False{}: next(Unit{})
def target_edges_erased(-S: Data,edges: List<&2,T.Edge<S>>,+descriptor: T.Descriptor<S>,+source: K.Key) -> Maybe<&2,K.Key>:
  match edges:
    case []: None{}
    case T.Edge{other,id,target} <> rest: chosen_target(Bool.and(U32.is_eq(key_erased(S,other),key_erased(S,descriptor)),K.equal(id,source)),target,_ => target_edges_erased(S,rest,descriptor,source))
def target_erased(-S: Data,graph: T.Graph<S>,descriptor: T.Descriptor<S>,source: K.Key) -> Maybe<&2,K.Key>:
  match graph:
    case T.Graph{edges,_}: target_edges_erased(S,edges,descriptor,source)
def chosen_inverse(found: Bool,sources: List<&2,K.Key>,next: Unit -> List<&2,K.Key>) -> List<&2,K.Key>:
  match found:
    case True{}: sources
    case False{}: next(Unit{})
def inverse_entries_erased(-S: Data,entries: List<&2,T.Inverse<S>>,+descriptor: T.Descriptor<S>,+target: K.Key) -> List<&2,K.Key>:
  match entries:
    case []: []
    case T.Inverse{other,id,sources} <> rest: chosen_inverse(Bool.and(U32.is_eq(key_erased(S,other),key_erased(S,descriptor)),K.equal(id,target)),sources,_ => inverse_entries_erased(S,rest,descriptor,target))
def inverse_erased(-S: Data,graph: T.Graph<S>,descriptor: T.Descriptor<S>,target: K.Key) -> List<&2,K.Key>:
  match graph:
    case T.Graph{_,entries}: inverse_entries_erased(S,entries,descriptor,target)
def edge_removed_erased(-S: Data,remove: Bool,edge: T.Edge<S>,rest: List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  match remove:
    case True{}: rest
    case False{}: edge <> rest
def remove_edge_fields_erased(-S: Data,edge: T.Edge<S>,+descriptor: T.Descriptor<S>,source: K.Key,next: Unit -> List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  match edge:
    case T.Edge{+other,+id,+target}: edge_removed_erased(S,Bool.and(U32.is_eq(key_erased(S,other),key_erased(S,descriptor)),K.equal(id,source)),T.Edge{other,id,target},next(Unit{}))
def remove_edge_keep_erased(-S:Data,edge:T.Edge<S>,+descriptor:T.Descriptor<S>,source:K.Key,acc:List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  match edge:
    case T.Edge{+other,+id,+target}: edge_removed_erased(S,Bool.and(U32.is_eq(key_erased(S,other),key_erased(S,descriptor)),K.equal(id,source)),T.Edge{other,id,target},acc)
def remove_edge_acc_erased(-S:Data,edges:List<&2,T.Edge<S>>,+descriptor:T.Descriptor<S>,+source:K.Key,acc:List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  match edges:
    case []: List.reverse(&2,T.Edge<S>,acc)
    case +edge <> rest: remove_edge_acc_erased(S,rest,descriptor,source,remove_edge_keep_erased(S,edge,descriptor,source,acc))
def remove_edge_erased(-S: Data,edges: List<&2,T.Edge<S>>,descriptor: T.Descriptor<S>,source: K.Key) -> List<&2,T.Edge<S>>:
  remove_edge_acc_erased(S,edges,descriptor,source,[])
def nonempty_inverse_erased(-S: Data,descriptor: T.Descriptor<S>,target: K.Key,sources: List<&2,K.Key>,rest: List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  match sources:
    case []: rest
    case head <> tail: T.Inverse{descriptor,target,head <> tail} <> rest
def inverse_remove_one_erased(-S: Data,matched: Bool,descriptor: T.Descriptor<S>,target: K.Key,sources: List<&2,K.Key>,source: K.Key,rest: List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  match matched:
    case True{}: nonempty_inverse_erased(S,descriptor,target,remove_id(sources,source),rest)
    case False{}: T.Inverse{descriptor,target,sources} <> rest
def inverse_remove_acc_erased(-S:Data,entries:List<&2,T.Inverse<S>>,+descriptor:T.Descriptor<S>,+target:K.Key,+source:K.Key,acc:List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  match entries:
    case []: List.reverse(&2,T.Inverse<S>,acc)
    case T.Inverse{+other,+id,sources} <> rest: inverse_remove_acc_erased(S,rest,descriptor,target,source,inverse_remove_one_erased(S,Bool.and(U32.is_eq(key_erased(S,other),key_erased(S,descriptor)),K.equal(id,target)),other,id,sources,source,acc))
def inverse_remove_erased(-S: Data,entries: List<&2,T.Inverse<S>>,descriptor: T.Descriptor<S>,target: K.Key,source: K.Key) -> List<&2,T.Inverse<S>>:
  inverse_remove_acc_erased(S,entries,descriptor,target,source,[])
def remove_previous_erased(-S: Data,previous: Maybe<&2,K.Key>,entries: List<&2,T.Inverse<S>>,descriptor: T.Descriptor<S>,source: K.Key) -> List<&2,T.Inverse<S>>:
  match previous:
    case None{}: entries
    case Some{target}: inverse_remove_erased(S,entries,descriptor,target,source)
def appended_source(present: Bool,sources: List<&2,K.Key>,source: K.Key) -> List<&2,K.Key>:
  match present:
    case True{}: sources
    case False{}: List.append(&2,K.Key,sources,[source])
def inverse_add_found_erased(-S: Data,found: Bool,other: T.Descriptor<S>,id: K.Key,+sources: List<&2,K.Key>,+descriptor: T.Descriptor<S>,target: K.Key,+source: K.Key,rest: List<&2,T.Inverse<S>>,next: Unit -> List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  match found:
    case True{}: T.Inverse{other,id,appended_source(contains(sources,source),sources,source)} <> rest
    case False{}: T.Inverse{other,id,sources} <> next(Unit{})
def inverse_add_erased(-S: Data,entries: List<&2,T.Inverse<S>>,+descriptor: T.Descriptor<S>,+target: K.Key,+source: K.Key) -> List<&2,T.Inverse<S>>:
  match entries:
    case []: [T.Inverse{descriptor,target,[source]}]
    case T.Inverse{+other,+id,+sources} <> +rest: inverse_add_found_erased(S,Bool.and(U32.is_eq(key_erased(S,other),key_erased(S,descriptor)),K.equal(id,target)),other,id,sources,descriptor,target,source,rest,_ => inverse_add_erased(S,rest,descriptor,target,source))
def unrelate_erased(-S: Data,graph: T.Graph<S>,+descriptor: T.Descriptor<S>,+source: K.Key) -> T.Graph<S>:
  match graph:
    case T.Graph{+edges,inverses}: T.Graph{remove_edge_erased(S,edges,descriptor,source),remove_previous_erased(S,target_edges_erased(S,edges,descriptor,source),inverses,descriptor,source)}
def next_cycle_erased(-S: Data,current: Maybe<&2,K.Key>,next: K.Key -> Bool) -> Bool:
  match current:
    case None{}: False{}
    case Some{id}: next(id)
def cycle_loop_erased(-S: Data,fuel: Nat,+graph: T.Graph<S>,+descriptor: T.Descriptor<S>,+source: K.Key,+current: K.Key) -> Bool:
  match fuel:
    case 0n: K.equal(source,current)
    case 1n+rest: Bool.or(K.equal(source,current),next_cycle_erased(S,target_erased(S,graph,descriptor,current),id => cycle_loop_erased(S,rest,graph,descriptor,source,id)))
def cycle_erased(-S: Data,+graph: T.Graph<S>,descriptor: T.Descriptor<S>,source: K.Key,target: K.Key) -> Bool:
  match graph descriptor:
    case T.Graph{edges,inverses} T.Descriptor{k,n,inv,T.Ordinary{}}: False{}
    case T.Graph{+edges,+inverses} T.Descriptor{+k,+n,+inv,T.Hierarchy{}}: cycle_loop_erased(S,List.length(&2,T.Edge<S>,edges),T.Graph{edges,inverses},T.Descriptor{k,n,inv,T.Hierarchy{}},source,target)
def validation(sourceLive: Bool,targetLive: Bool,self: Bool,cyclic: Bool,source: K.Key,target: K.Key,name: String) -> Maybe<&2,T.Error>:
  match sourceLive targetLive self cyclic:
    case False{} _ _ _: Some{T.MissingEntity{source}}
    case True{} False{} _ _: Some{T.MissingTargetEntity{source,target,name}}
    case True{} True{} True{} _: Some{T.SelfRelationNotAllowed{source,name}}
    case True{} True{} False{} True{}: Some{T.HierarchyCycle{source,target,name}}
    case True{} True{} False{} False{}: None{}
def already(previous: Maybe<&2,K.Key>,target: K.Key) -> Bool:
  match previous:
    case None{}: False{}
    case Some{id}: K.equal(id,target)
def updated_erased(-S: Data,same: Bool,+edges: List<&2,T.Edge<S>>,inverses: List<&2,T.Inverse<S>>,+descriptor: T.Descriptor<S>,+source: K.Key,+target: K.Key) -> T.Graph<S>:
  match same:
    case True{}: T.Graph{edges,inverses}
    case False{}: T.Graph{List.append(&2,T.Edge<S>,remove_edge_erased(S,edges,descriptor,source),[T.Edge{descriptor,source,target}]),inverse_add_erased(S,remove_previous_erased(S,target_edges_erased(S,edges,descriptor,source),inverses,descriptor,source),descriptor,target,source)}
def checked_erased(-S: Data,error: Maybe<&2,T.Error>,graph: T.Graph<S>,+descriptor: T.Descriptor<S>,+source: K.Key,+target: K.Key) -> T.CoreResult<S>:
  match error graph:
    case Some{error} graph: T.CoreResult{graph,Some{error}}
    case None{} T.Graph{+edges,inverses}: T.CoreResult{updated_erased(S,already(target_edges_erased(S,edges,descriptor,source),target),edges,inverses,descriptor,source,target),None{}}
def relate_erased(-S: Data,+graph: T.Graph<S>,+descriptor: T.Descriptor<S>,+source: K.Key,+target: K.Key,sourceLive: Bool,targetLive: Bool) -> T.CoreResult<S>:
  checked_erased(S,validation(sourceLive,targetLive,K.equal(source,target),cycle_erased(S,graph,descriptor,source,target),source,target,name_erased(S,descriptor)),graph,descriptor,source,target)
def project_erased(-S: Data,graph: T.Graph<S>) -> T.SpecGraph<S>:
  match graph:
    case T.Graph{edges,_}: T.SpecGraph{edges}
# Public schema-specialized entry points delegate to the same erased algorithms.
def key(~S: Data,descriptor: T.Descriptor<S>) -> U32:
  key_erased(S,descriptor)
def name(~S: Data,descriptor: T.Descriptor<S>) -> String:
  name_erased(S,descriptor)
def target_edges(~S: Data,edges: List<&2,T.Edge<S>>,+descriptor: T.Descriptor<S>,+source: K.Key) -> Maybe<&2,K.Key>:
  target_edges_erased(S,edges,descriptor,source)
def target(~S: Data,graph: T.Graph<S>,descriptor: T.Descriptor<S>,source: K.Key) -> Maybe<&2,K.Key>:
  target_erased(S,graph,descriptor,source)
def inverse_entries(~S: Data,entries: List<&2,T.Inverse<S>>,+descriptor: T.Descriptor<S>,+target: K.Key) -> List<&2,K.Key>:
  inverse_entries_erased(S,entries,descriptor,target)
def inverse(~S: Data,graph: T.Graph<S>,descriptor: T.Descriptor<S>,target: K.Key) -> List<&2,K.Key>:
  inverse_erased(S,graph,descriptor,target)
def edge_removed(~S: Data,remove: Bool,edge: T.Edge<S>,rest: List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  edge_removed_erased(S,remove,edge,rest)
def remove_edge_fields(~S: Data,edge: T.Edge<S>,+descriptor: T.Descriptor<S>,source: K.Key,next: Unit -> List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  remove_edge_fields_erased(S,edge,descriptor,source,next)
def remove_edge_keep(~S:Data,edge:T.Edge<S>,+descriptor:T.Descriptor<S>,source:K.Key,acc:List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  remove_edge_keep_erased(S,edge,descriptor,source,acc)
def remove_edge_acc(~S:Data,edges:List<&2,T.Edge<S>>,+descriptor:T.Descriptor<S>,+source:K.Key,acc:List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  remove_edge_acc_erased(S,edges,descriptor,source,acc)
def remove_edge(~S: Data,edges: List<&2,T.Edge<S>>,descriptor: T.Descriptor<S>,source: K.Key) -> List<&2,T.Edge<S>>:
  remove_edge_erased(S,edges,descriptor,source)
def nonempty_inverse(~S: Data,descriptor: T.Descriptor<S>,target: K.Key,sources: List<&2,K.Key>,rest: List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  nonempty_inverse_erased(S,descriptor,target,sources,rest)
def inverse_remove_one(~S: Data,matched: Bool,descriptor: T.Descriptor<S>,target: K.Key,sources: List<&2,K.Key>,source: K.Key,rest: List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  inverse_remove_one_erased(S,matched,descriptor,target,sources,source,rest)
def inverse_remove_acc(~S:Data,entries:List<&2,T.Inverse<S>>,+descriptor:T.Descriptor<S>,+target:K.Key,+source:K.Key,acc:List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  inverse_remove_acc_erased(S,entries,descriptor,target,source,acc)
def inverse_remove(~S: Data,entries: List<&2,T.Inverse<S>>,descriptor: T.Descriptor<S>,target: K.Key,source: K.Key) -> List<&2,T.Inverse<S>>:
  inverse_remove_erased(S,entries,descriptor,target,source)
def remove_previous(~S: Data,previous: Maybe<&2,K.Key>,entries: List<&2,T.Inverse<S>>,descriptor: T.Descriptor<S>,source: K.Key) -> List<&2,T.Inverse<S>>:
  remove_previous_erased(S,previous,entries,descriptor,source)
def inverse_add_found(~S: Data,found: Bool,other: T.Descriptor<S>,id: K.Key,+sources: List<&2,K.Key>,+descriptor: T.Descriptor<S>,target: K.Key,+source: K.Key,rest: List<&2,T.Inverse<S>>,next: Unit -> List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  inverse_add_found_erased(S,found,other,id,sources,descriptor,target,source,rest,next)
def inverse_add(~S: Data,entries: List<&2,T.Inverse<S>>,+descriptor: T.Descriptor<S>,+target: K.Key,+source: K.Key) -> List<&2,T.Inverse<S>>:
  inverse_add_erased(S,entries,descriptor,target,source)
def unrelate(~S: Data,graph: T.Graph<S>,+descriptor: T.Descriptor<S>,+source: K.Key) -> T.Graph<S>:
  unrelate_erased(S,graph,descriptor,source)
def next_cycle(~S: Data,current: Maybe<&2,K.Key>,next: K.Key -> Bool) -> Bool:
  next_cycle_erased(S,current,next)
def cycle_loop(~S: Data,fuel: Nat,+graph: T.Graph<S>,+descriptor: T.Descriptor<S>,+source: K.Key,+current: K.Key) -> Bool:
  cycle_loop_erased(S,fuel,graph,descriptor,source,current)
def cycle(~S: Data,+graph: T.Graph<S>,descriptor: T.Descriptor<S>,source: K.Key,target: K.Key) -> Bool:
  cycle_erased(S,graph,descriptor,source,target)
def updated(~S: Data,same: Bool,+edges: List<&2,T.Edge<S>>,inverses: List<&2,T.Inverse<S>>,+descriptor: T.Descriptor<S>,+source: K.Key,+target: K.Key) -> T.Graph<S>:
  updated_erased(S,same,edges,inverses,descriptor,source,target)
def checked(~S: Data,error: Maybe<&2,T.Error>,graph: T.Graph<S>,+descriptor: T.Descriptor<S>,+source: K.Key,+target: K.Key) -> T.CoreResult<S>:
  checked_erased(S,error,graph,descriptor,source,target)
def relate(~S: Data,+graph: T.Graph<S>,+descriptor: T.Descriptor<S>,+source: K.Key,+target: K.Key,sourceLive: Bool,targetLive: Bool) -> T.CoreResult<S>:
  relate_erased(S,graph,descriptor,source,target,sourceLive,targetLive)
def project(~S: Data,graph: T.Graph<S>) -> T.SpecGraph<S>:
  project_erased(S,graph)
