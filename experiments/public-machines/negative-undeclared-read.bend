import Base
import machine.bend as M
import provider.bend as P
import ../../src/ecs/capabilities.bend as Cap

# Only Level is declared. It cannot serve as the missing Flow read capability.
def gameplay(~H: Type,~level: Cap.ValueRead<H,M.CurrentView<P.SchemaA,P.LevelToken,P.Level>>,ctx: H) -> H & M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>:
  Cap.value_read(~H,~M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>,~level,ctx)
