import Base
import ./entity-key.bend as K
import ./world.bend as W
import ./relation-types.bend as T
import ./execution-relation-operation.bend as O

# Existing Failure represents relate/reorder. Unrelate remains explicit rather
# than reporting a different operation to fit that older record.
type Message<-S:Data,-descriptor:T.Descriptor<S>> is Data:
  RelationFailed{operation:O.Operation<S>,failure:T.Failure<S>}
  UnrelateFailed{operation:O.Operation<S>,source:K.Key,error:T.Error}
def error_target(error:T.Error,parent:K.Key) -> K.Key:
  match error:
    case T.MissingChildEntity{_,child,_}:child
    case T.DuplicateChild{_,child,_}:child
    case T.ChildNotRelatedToParent{_,child,_}:child
    case _:parent
def failed(~S:Data,~descriptor:T.Descriptor<S>,operation:O.Operation<S>,+error:T.Error) -> Message<S,descriptor>:
  match operation:
    case O.Relate{+source,+target}:RelationFailed{O.Relate{source,target},T.Failure{descriptor,T.Relate{},W.handle_key(~S,source),W.handle_key(~S,target),error}}
    case O.Unrelate{+source}:UnrelateFailed{O.Unrelate{source},W.handle_key(~S,source),error}
    case O.Reorder{+parent,children}:RelationFailed{O.Reorder{parent,children},T.Failure{descriptor,T.ReorderChildren{},W.handle_key(~S,parent),error_target(error,W.handle_key(~S,parent)),error}}
def refused(~S:Data,~descriptor:T.Descriptor<S>,operation:O.Operation<S>,reason:O.Reason) -> Maybe<&2,Message<S,descriptor>>:
  match reason:
    case O.RelationError{error}:Some{failed(~S,~descriptor,operation,error)}
    case O.HierarchyRequired{}:None{}
