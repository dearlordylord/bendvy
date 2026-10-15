import Base
import ../fixture.bend as F
import ../../../../src/ecs/ordinary-app-schedules.bend as N
import ../../../../src/ecs/schedule-provision.bend as SP
def wrong(app:F.application(~F.Workshop)) -> F.application(~F.Garden) & Maybe<&2,SP.Plan<F.Garden>>:
  N.get(~F.Garden,~F.Store,~F.Resources,~Unit,~F.Owners(~F.Garden),~F.Rows(),~F.observe(~F.Garden),~F.fold(~F.Garden),app,"First")
