import Base
import machine.bend as M
import provider.bend as P
import ../../src/ecs/capabilities.bend as Cap

# The committed view grants get/is, not next-state getPending.
def gameplay(~H: Type,~flow: Cap.ValueRead<H,M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>>,ctx: H) -> H & M.NextView<P.SchemaA,P.FlowToken,P.Flow>:
  Cap.value_get(~H,~M.QueueInput<P.Flow>,~M.NextView<P.SchemaA,P.FlowToken,P.Flow>,~flow,ctx)
