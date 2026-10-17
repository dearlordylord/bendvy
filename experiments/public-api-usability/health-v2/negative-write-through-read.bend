import Base
import schema.bend as S
import core.bend as Core
import ../../../examples/scheduled-health/components.bend as D
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/ordinary-query-observable.bend as O
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/column.bend as Col

def query() -> O.Declaration<S.Schema,Core.Frame(),Cap.Read<Core.Frame(),D.Health>,I.Frame<S.Schema,S.Store,S.Resources,Unit>,C.Access<D.Health>>:
  O.read(~S.Schema,~S.Store,~Col.Column<S.Schema,D.HealthDecay>,~D.Health,~D.Health,~S.HealthToken,~S.take_health,~S.put_health,~S.project_health,~S.Resources,~Unit,~Core.health_binding())
def denied(~H:Type,~caps:Cap.Read<H,D.Health>,owner:H,value:D.Health) -> H:
  Cap.set(~H,~D.Health,~D.Health,~caps,owner,value)
