import Base
import ../../../src/ecs/relation-types.bend as T
import graph-spec.bend as S

# Independent slow reorder: rebuild target edges in requested order.
def child_ids(children: List<&2,T.ChildStatus>) -> List<&2,U32>:
  match children:
    case []: []
    case T.ChildStatus{id,_} <> rest: id <> child_ids(rest)
def parent_match(value: Maybe<&2,U32>,parent: U32) -> Bool:
  match value:
    case None{}: False{}
    case Some{id}: U32.is_eq(id,parent)
def same_count(a: List<&2,U32>,b: List<&2,U32>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{_,ar} Con{_,br}: same_count(ar,br)
    case _ _: False{}
def subset(a: List<&2,U32>,+b: List<&2,U32>) -> Bool:
  match a:
    case []: True{}
    case x <> rest: Bool.and(S.contains(b,x),subset(rest,b))
def child_error(live: Bool,duplicate: Bool,related: Bool,parent: U32,child: U32,+name: String) -> Maybe<&2,T.Error>:
  match live duplicate related:
    case False{} _ _: Some{T.MissingChildEntity{parent,child,name}}
    case True{} True{} _: Some{T.DuplicateChild{parent,child,name}}
    case True{} False{} False{}: Some{T.ChildNotRelatedToParent{parent,child,name}}
    case True{} False{} True{}: None{}
def first_error(current: Maybe<&2,T.Error>,next: Unit -> Maybe<&2,T.Error>) -> Maybe<&2,T.Error>:
  match current:
    case Some{e}: Some{e}
    case None{}: next(Unit{})
def children_checked(~S: Data,children: List<&2,T.ChildStatus>,+graph: T.SpecGraph<S>,+d: T.Descriptor<S>,+parent: U32,+seen: List<&2,U32>) -> Maybe<&2,T.Error>:
  match children:
    case []: None{}
    case T.ChildStatus{+id,live} <> rest: first_error(child_error(live,S.contains(seen,id),parent_match(S.target(~S,graph,d,id),parent),parent,id,S.name(~S,d)),_ => children_checked(~S,rest,graph,d,parent,id <> seen))
def mismatch(same: Bool,error: Maybe<&2,T.Error>,parent: U32,name: String) -> Maybe<&2,T.Error>:
  match same error:
    case _ Some{e}: Some{e}
    case True{} None{}: None{}
    case False{} None{}: Some{T.ChildSetMismatch{parent,name}}
def validate(~S: Data,parentLive: Bool,+graph: T.SpecGraph<S>,+d: T.Descriptor<S>,+parent: U32,+children: List<&2,T.ChildStatus>) -> Maybe<&2,T.Error>:
  match parentLive:
    case False{}: Some{T.MissingEntity{parent}}
    case True{}: mismatch(Bool.and(same_count(S.inverse(~S,graph,d,parent),child_ids(children)),subset(S.inverse(~S,graph,d,parent),child_ids(children))),children_checked(~S,children,graph,d,parent,[]),parent,S.name(~S,d))
def keep_edge(~S: Data,remove: Bool,edge: T.Edge<S>,rest: List<&2,T.Edge<S>>) -> List<&2,T.Edge<S>>:
  match remove:
    case True{}: rest
    case False{}: edge <> rest
def remove_target(~S: Data,edges: List<&2,T.Edge<S>>,+d: T.Descriptor<S>,+parent: U32) -> List<&2,T.Edge<S>>:
  match edges:
    case []: []
    case T.Edge{+other,+source,+target} <> rest: keep_edge(~S,Bool.and(U32.is_eq(S.key(~S,d),S.key(~S,other)),U32.is_eq(parent,target)),T.Edge{other,source,target},remove_target(~S,rest,d,parent))
def new_edges(~S: Data,children: List<&2,T.ChildStatus>,+d: T.Descriptor<S>,+parent: U32) -> List<&2,T.Edge<S>>:
  match children:
    case []: []
    case T.ChildStatus{id,_} <> rest: T.Edge{d,id,parent} <> new_edges(~S,rest,d,parent)
def checked(~S: Data,error: Maybe<&2,T.Error>,graph: T.SpecGraph<S>,+d: T.Descriptor<S>,+parent: U32,children: List<&2,T.ChildStatus>) -> T.SpecResult<S>:
  match error graph:
    case Some{e} graph: T.SpecResult{graph,Some{e}}
    case None{} T.SpecGraph{edges}: T.SpecResult{T.SpecGraph{List.append(&2,T.Edge<S>,remove_target(~S,edges,d,parent),new_edges(~S,children,d,parent))},None{}}
def reorder(~S: Data,+graph: T.SpecGraph<S>,+d: T.Descriptor<S>,+parent: U32,+children: List<&2,T.ChildStatus>,parentLive: Bool) -> T.SpecResult<S>:
  checked(~S,validate(~S,parentLive,graph,d,parent,children),graph,d,parent,children)
