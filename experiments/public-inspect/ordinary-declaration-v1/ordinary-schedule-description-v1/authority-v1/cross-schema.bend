import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Schedule
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule-description.bend as Description
type Other is Data:Other{}
def foreign(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~otherObserve:W.World<Other,C,R,E> -> W.World<Other,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~otherFold:H -> H & List<&2,Fields.Fields<Other>>,app:Schedule.Application<Other,C,R,E,H,Rows,otherObserve,otherFold>) -> Schedule.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Description.Description<S,Rows>>:
  Description.snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app)
def main() -> Unit:Unit{}
