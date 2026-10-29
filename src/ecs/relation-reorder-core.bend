import Base
import entity-key.bend as K
import relation-types.bend as T
import relation-graph.bend as C

# Maintained inverse reorder: preserve authoritative targets; replace selected inverse order.
def child_ids(children: List<&2,T.ChildStatus>) -> List<&2,K.Key>:
  match children:
    case []: []
    case T.ChildStatus{id,_} <> rest: id <> child_ids(rest)
def parent_match(value: Maybe<&2,K.Key>,parent: K.Key) -> Bool:
  match value:
    case None{}: False{}
    case Some{id}: K.equal(id,parent)
def same_count(a: List<&2,K.Key>,b: List<&2,K.Key>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{_,ar} Con{_,br}: same_count(ar,br)
    case _ _: False{}
def subset(a: List<&2,K.Key>,+b: List<&2,K.Key>) -> Bool:
  match a:
    case []: True{}
    case x <> rest: Bool.and(C.contains(b,x),subset(rest,b))
def child_error(live: Bool,duplicate: Bool,related: Bool,parent: K.Key,child: K.Key,+name: String) -> Maybe<&2,T.Error>:
  match live duplicate related:
    case False{} _ _: Some{T.MissingChildEntity{parent,child,name}}
    case True{} True{} _: Some{T.DuplicateChild{parent,child,name}}
    case True{} False{} False{}: Some{T.ChildNotRelatedToParent{parent,child,name}}
    case True{} False{} True{}: None{}
def first_error(current: Maybe<&2,T.Error>,next: Unit -> Maybe<&2,T.Error>) -> Maybe<&2,T.Error>:
  match current:
    case Some{e}: Some{e}
    case None{}: next(Unit{})
def children_checked_erased(-S: Data,children: List<&2,T.ChildStatus>,+graph: T.Graph<S>,+d: T.Descriptor<S>,+parent: K.Key,+seen: List<&2,K.Key>) -> Maybe<&2,T.Error>:
  match children:
    case []: None{}
    case T.ChildStatus{+id,live} <> rest: first_error(child_error(live,C.contains(seen,id),parent_match(C.target_erased(S,graph,d,id),parent),parent,id,C.name_erased(S,d)),_ => children_checked_erased(S,rest,graph,d,parent,id <> seen))
def mismatch(same: Bool,error: Maybe<&2,T.Error>,parent: K.Key,name: String) -> Maybe<&2,T.Error>:
  match same error:
    case _ Some{e}: Some{e}
    case True{} None{}: None{}
    case False{} None{}: Some{T.ChildSetMismatch{parent,name}}
def validate_erased(-S: Data,parentLive: Bool,+graph: T.Graph<S>,+d: T.Descriptor<S>,+parent: K.Key,+children: List<&2,T.ChildStatus>) -> Maybe<&2,T.Error>:
  match parentLive:
    case False{}: Some{T.MissingEntity{parent}}
    case True{}: mismatch(Bool.and(same_count(C.inverse_erased(S,graph,d,parent),child_ids(children)),subset(C.inverse_erased(S,graph,d,parent),child_ids(children))),children_checked_erased(S,children,graph,d,parent,[]),parent,C.name_erased(S,d))
# Maintained inverse reorder changes only the selected inverse entry.
def replaced_erased(-S: Data,found: Bool,entry: T.Inverse<S>,sources: List<&2,K.Key>,rest: List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  match found entry:
    case True{} T.Inverse{d,parent,_}: T.Inverse{d,parent,sources} <> rest
    case False{} entry: entry <> rest
def replace_inverse_erased(-S: Data,entries: List<&2,T.Inverse<S>>,+d: T.Descriptor<S>,+parent: K.Key,+sources: List<&2,K.Key>) -> List<&2,T.Inverse<S>>:
  match entries:
    case []: []
    case T.Inverse{+other,+id,old} <> rest: replaced_erased(S,Bool.and(U32.is_eq(C.key_erased(S,d),C.key_erased(S,other)),K.equal(parent,id)),T.Inverse{other,id,old},sources,replace_inverse_erased(S,rest,d,parent,sources))
def checked_erased(-S: Data,error: Maybe<&2,T.Error>,graph: T.Graph<S>,d: T.Descriptor<S>,parent: K.Key,children: List<&2,T.ChildStatus>) -> T.CoreResult<S>:
  match error graph:
    case Some{e} graph: T.CoreResult{graph,Some{e}}
    case None{} T.Graph{edges,inverses}: T.CoreResult{T.Graph{edges,replace_inverse_erased(S,inverses,d,parent,child_ids(children))},None{}}
def reorder_erased(-S: Data,+graph: T.Graph<S>,+d: T.Descriptor<S>,+parent: K.Key,+children: List<&2,T.ChildStatus>,parentLive: Bool) -> T.CoreResult<S>:
  checked_erased(S,validate_erased(S,parentLive,graph,d,parent,children),graph,d,parent,children)
# Public schema-specialized entry points delegate to the same erased algorithms.
def children_checked(~S: Data,children: List<&2,T.ChildStatus>,+graph: T.Graph<S>,+d: T.Descriptor<S>,+parent: K.Key,+seen: List<&2,K.Key>) -> Maybe<&2,T.Error>:
  children_checked_erased(S,children,graph,d,parent,seen)
def validate(~S: Data,parentLive: Bool,+graph: T.Graph<S>,+d: T.Descriptor<S>,+parent: K.Key,+children: List<&2,T.ChildStatus>) -> Maybe<&2,T.Error>:
  validate_erased(S,parentLive,graph,d,parent,children)
def replaced(~S: Data,found: Bool,entry: T.Inverse<S>,sources: List<&2,K.Key>,rest: List<&2,T.Inverse<S>>) -> List<&2,T.Inverse<S>>:
  replaced_erased(S,found,entry,sources,rest)
def replace_inverse(~S: Data,entries: List<&2,T.Inverse<S>>,+d: T.Descriptor<S>,+parent: K.Key,+sources: List<&2,K.Key>) -> List<&2,T.Inverse<S>>:
  replace_inverse_erased(S,entries,d,parent,sources)
def checked(~S: Data,error: Maybe<&2,T.Error>,graph: T.Graph<S>,d: T.Descriptor<S>,parent: K.Key,children: List<&2,T.ChildStatus>) -> T.CoreResult<S>:
  checked_erased(S,error,graph,d,parent,children)
def reorder(~S: Data,+graph: T.Graph<S>,+d: T.Descriptor<S>,+parent: K.Key,+children: List<&2,T.ChildStatus>,parentLive: Bool) -> T.CoreResult<S>:
  reorder_erased(S,graph,d,parent,children,parentLive)
