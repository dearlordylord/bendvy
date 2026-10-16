import Base
import ../wiring.bend as Bind
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/captured-schedule.bend as Run
import ../../../../src/ecs/captured-schedule-composition.bend as Comp
import ../../../../src/ecs/compose.bend as Q
import ../fixture.bend as F
import ../resource.bend as R
type First is Data:
  First{}
type Other is Data:
  Other{}
def rejected(owner:Bind.Schedule(~First),world:W.World<Other,Col.Column<Other,U32>,U32,Unit>) -> Run.Run<W.World<First,Col.Column<First,U32>,U32,Unit>,Bind.Schedule(~First),First,Comp.Choice<Q.Error<F.Error>,R.Error>>:
  Bind.run(~First,owner,world)
