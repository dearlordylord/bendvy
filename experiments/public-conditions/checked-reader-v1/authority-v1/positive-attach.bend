import Base
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-conditions/component-query-v1/schema.bend as Model
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-family-schedule.bend as Checked
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as Family
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-bindings.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/checked-condition-schedule.bend as Error
import /workspace/formal-proofs/bendvy/src/ecs/event-stream.bend as Stream
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
def accepted(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,value:Family.Application<S,C,R,E,F,H,Rows,observe,fold>,name:String,plan:SP.Plan<S>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>) -> Checked.Attachment<Family.Application<S,C,R,E,F,H,Rows,observe,fold>,B.Bindings<W.World<S,C,R,E>,B,select>,Checked.Application<S,C,R,E,F,H,Rows,observe,fold,B,select>>:Checked.attach(~S,~C,~R,~E,~F,~H,~Rows,~observe,~fold,~B,~select,value,name,plan,bindings)
