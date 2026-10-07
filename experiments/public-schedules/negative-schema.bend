import Base
import ../../src/ecs/schedule.bend as Sch
import ../../src/ecs/world.bend as W
import main.bend as D

type Other is Data:
  Other{}
def wrong(schedule: Sch.Schedule<D.Schema,Unit,U32,U32,D.Owners>,world: W.World<Other,Unit,U32,U32>) -> Sch.RunResult<D.Schema,Unit,U32,U32,D.Owners,String>:
  Sch.run(~D.Schema,~Unit,~U32,~U32,~D.Owners,~String,~D.dispatch,~D.condition,schedule,world)
