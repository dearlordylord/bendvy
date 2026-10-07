import Base
import machine.bend as M
import provider.bend as P
import ../../src/ecs/capabilities.bend as Cap

def gameplay(~H: Type,~flow: Cap.ValueRead<H,M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>>,ctx: H) -> H:
  Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<P.SchemaA,P.FlowToken,P.Flow>,~flow,ctx,M.Set{P.Play{},False{}})
