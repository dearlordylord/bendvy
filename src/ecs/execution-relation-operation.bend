import Base
import ./world.bend as W
import ./relation-types.bend as T

# Descriptor selection belongs to the declaration, not to a queued request.
type Operation<S:Data> is Data:
  Relate{source:W.Handle<S>,target:W.Handle<S>}
  Unrelate{source:W.Handle<S>}
  Reorder{parent:W.Handle<S>,children:List<&2,W.Handle<S>>}
type Reason is Data:
  RelationError{error:T.Error}
  HierarchyRequired{}
type Outcome<S:Data> is Data:
  Applied{graph:T.Graph<S>,operation:Operation<S>}
  Refused{graph:T.Graph<S>,operation:Operation<S>,reason:Reason}
