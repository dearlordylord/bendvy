import Base
import full-provider.bend as P
import ../../public-machines/machine.bend as M
import ../../../src/ecs/capabilities.bend as Cap

def write(~F:Type,~read:Cap.ValueRead<F,M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>>,owner:F) -> F:
  Cap.value_set(~F,~M.QueueInput<P.Flow>,~M.NextView<P.SchemaA,P.FlowToken,P.Flow>,~read,owner,M.Set{P.Play{},False{}})
