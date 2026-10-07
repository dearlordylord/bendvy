import Base
import ../../src/ecs/schedule.bend as Sch
import main.bend as D

def duplicate(schedule: Sch.Schedule<D.Schema,Unit,U32,U32,D.Owners>) -> Sch.Schedule<D.Schema,Unit,U32,U32,D.Owners> & Sch.Schedule<D.Schema,Unit,U32,U32,D.Owners>:
  (schedule,schedule)
