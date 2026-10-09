import Base
import provider.bend as P
import readers.bend as R
import ../../src/ecs/capabilities.bend as Cap

def gameplay(~H: Type,~level: Cap.ValueRead<H,R.View<P.SchemaA,P.LevelToken,P.Level>>,ctx: H) -> H & R.View<P.SchemaA,P.FlowToken,P.Flow>:
  Cap.value_read(~H,~R.View<P.SchemaA,P.FlowToken,P.Flow>,~level,ctx)
