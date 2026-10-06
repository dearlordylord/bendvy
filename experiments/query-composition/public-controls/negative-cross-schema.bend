import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/column.bend as Col

def bad(~S1: Data,~S2: Data,~Store: Type,~R: Type,~E: Data,~Rest: Type,~C: Type,~V: Data,~Token: Data,~take: Store -> Rest & Col.Column<S2,C>,~put: Rest -> Col.Column<S2,C> -> Store,~project: C -> C & V,~family: Cmp.Family<S2,Store,Rest,C,V,Token,take,put,project>) -> Cap.Read<Q.Frame<S1,Store,R,E>,V>:
  Q.read_family(~S1,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,~family)
def main() -> U32:
  0
