import Base
import ./canonical-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment

# Reuse adopted kind-local schema policy; no independent duplicate-key rule.
type Bootstrapped<-S:Data,-P:Type,-Q:Type,-layout:Schema.Layout<S,P,Q>> is Type:
  Ready{owner:Schema.Owner<S,P,Q,layout>}
  Rejected{error:Fragment.Error,left:P,right:Q}
def entries(~S:Data,~P:Type,~Q:Type,layout:Schema.Layout<S,P,Q>) -> List<&2,Fragment.Entry<S>>:
  match layout:
    case Schema.Layout{+left,+right}:[Fragment.Entry{Fragment.Resource{},left,left},Fragment.Entry{Fragment.Resource{},right,right}]
def checked(~S:Data,~P:Type,~Q:Type,~layout:Schema.Layout<S,P,Q>,validation:Fragment.Validation,left:P,right:Q) -> Bootstrapped<S,P,Q,layout>:
  match validation:
    case Fragment.Invalid{error}:Rejected{error,left,right}
    case Fragment.Valid{}:Ready{Schema.bootstrap(~S,~P,~Q,~layout,left,right)}
# Keep the validated list named instead of eagerly unfolding recursive validation
# of a computed layout projection in this generic checker context.
def validate_entries(~S:Data,~P:Type,~Q:Type,~layout:Schema.Layout<S,P,Q>,values:List<&2,Fragment.Entry<S>>,left:P,right:Q) -> Bootstrapped<S,P,Q,layout>:
  checked(~S,~P,~Q,~layout,Fragment.validate(~S,values),left,right)
def bootstrap(~S:Data,~P:Type,~Q:Type,~layout:Schema.Layout<S,P,Q>,left:P,right:Q) -> Bootstrapped<S,P,Q,layout>:
  validate_entries(~S,~P,~Q,~layout,entries(~S,~P,~Q,layout),left,right)
