import Base
import ./dependency-plan.bend as Plan
import ./spec.bend as Spec
def ready_blocked() -> {Plan.ready(~U32,[Plan.Node{0,[]},Plan.Node{1,[]}],[Plan.Edge{0,1}]) == Spec.ready(~U32,[Plan.Node{0,[]},Plan.Node{1,[]}],[Plan.Edge{0,1}]) : List<&2,Plan.Node<U32>>}:{==}
