import Base
import provider.bend as P
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/machine.bend as M
import readers.bend as R
import ../../src/ecs/capabilities.bend as Cap

def gameplay(~H: Type,~read: Cap.ValueRead<H,R.View<P.SchemaA,P.FlowToken,P.Flow>>,ctx: H) -> H:
  Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.NextView<P.SchemaA,P.FlowToken,P.Flow>,~read,ctx,M.Set{P.Play{},False{}})
