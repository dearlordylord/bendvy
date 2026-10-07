import Base
import feature.bend as F
import ../../src/ecs/schema-fragments.bend as SF
# Independent accumulator specifications visit right before left to construct
# the same authored sequence without the implementation's append recursion.
def names_into(~S:Data,tree:F.Tree<S>,suffix:List<&2,String>) -> List<&2,String>:
  match tree:
    case F.Empty{}: suffix
    case F.Feature{name,_,_}: name <> suffix
    case F.Sequence{left,right}: names_into(~S,left,names_into(~S,right,suffix))
def visibility_into(~S:Data,tree:F.Tree<S>,suffix:List<&2,SF.Entry<S>>) -> List<&2,SF.Entry<S>>:
  match tree:
    case F.Empty{}: suffix
    case F.Feature{_,own,deps}: List.append(&2,SF.Entry<S>,own,visibility_into(~S,deps,suffix))
    case F.Sequence{left,right}: visibility_into(~S,left,visibility_into(~S,right,suffix))
