import Base
import relation-types.bend as T
import relation-graph.bend as C

# Maintained inverse reorder: preserve authoritative targets; replace selected inverse order.
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
    case x <> rest: Bool.and(C.contains(b,x),subset(rest,b))
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
def children_checked(~S: Data,children: List<&2,T.ChildStatus>,+graph: T.Graph<S>,+d: T.Descriptor<S>,+parent: U32,+seen: List<&2,U32>) -> Maybe<&2,T.Error>:
  match children:
    case []: None{}
    case T.ChildStatus{+id,live} <> rest: first_error(child_error(live,C.contains(seen,id),parent_match(C.target(~S,graph,d,id),parent),parent,id,C.name(~S,d)),_ => children_checked(~S,rest,graph,d,parent,id <> seen))
def mismatch(same: Bool,error: Maybe<&2,T.Error>,parent: U32,name: String) -> Maybe<&2,T.Error>:
  match same error:
    case _ Some{e}: Some{e}
    case True{} None{}: None{}
    case False{} None{}: Some{T.ChildSetMismatch{parent,name}}
def validate(~S: Data,parentLive: Bool,+graph: T.Graph<S>,+d: T.Descriptor<S>,+parent: U32,+children: List<&2,T.ChildStatus>) -> Maybe<&2,T.Error>:
  match parentLive:
    case False{}: Some{T.MissingEntity{parent}}
    case True{}: mismatch(Bool.and(same_count(C.inverse(~S,graph,d,parent),child_ids(children)),subset(C.inverse(~S,graph,d,parent),child_ids(children))),children_checked(~S,children,graph,d,parent,[]),parent,C.name(~S,d))
# Maintained inverse reorder changes only the selected inverse entry.
def replaced(~S: Data,found: Bool,entry: T.Inverse<S>,sources: List<&2,U32>,rest: List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  match found entry:
    case True{} T.Inverse{d,parent,_}: T.Inverse{d,parent,sources} <> rest
    case False{} entry: entry <> rest
def replace_inverse(~S: Data,entries: List<&2,T.Inverse<S>>,+d: T.Descriptor<S>,+parent: U32,+sources: List<&2,U32>) -> List<&2,T.Inverse<S>>:
  match entries:
    case []: []
    case T.Inverse{+other,+id,old} <> rest: replaced(~S,Bool.and(U32.is_eq(C.key(~S,d),C.key(~S,other)),U32.is_eq(parent,id)),T.Inverse{other,id,old},sources,replace_inverse(~S,rest,d,parent,sources))
def checked(~S: Data,error: Maybe<&2,T.Error>,graph: T.Graph<S>,d: T.Descriptor<S>,parent: U32,children: List<&2,T.ChildStatus>) -> T.CoreResult<S>:
  match error graph:
    case Some{e} graph: T.CoreResult{graph,Some{e}}
    case None{} T.Graph{edges,inverses}: T.CoreResult{T.Graph{edges,replace_inverse(~S,inverses,d,parent,child_ids(children))},None{}}
def reorder(~S: Data,+graph: T.Graph<S>,+d: T.Descriptor<S>,+parent: U32,+children: List<&2,T.ChildStatus>,parentLive: Bool) -> T.CoreResult<S>:
  checked(~S,validate(~S,parentLive,graph,d,parent,children),graph,d,parent,children)
