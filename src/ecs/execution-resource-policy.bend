import Base
import ./relation-types.bend as T

# Authority and persistence are independent properties of a canonical leaf.
type Policy is Type:
  Ordinary{}
  ProtectedRelation{S:Data,descriptor:T.Descriptor<S>}
  ProtectedLifetimeScope{S:Data}
def generic_write(policy:Policy) -> Bool:
  match policy:
    case Ordinary{}:True{}
    case ProtectedRelation{_,_}:False{}
    case ProtectedLifetimeScope{_}:False{}
