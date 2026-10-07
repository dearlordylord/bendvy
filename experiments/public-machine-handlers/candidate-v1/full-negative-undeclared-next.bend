import Base
import full-provider.bend as P
import ../../public-machines/machine.bend as M
import ../../../src/ecs/capabilities.bend as Cap

type ReadOnly<F:Type> is Type:
  ReadOnly{flow:Cap.ValueRead<F,M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>>}
def next(-F:Type,caps:ReadOnly<F>,owner:F) -> F:
  match caps:
    case ReadOnly{flow,next}: owner
