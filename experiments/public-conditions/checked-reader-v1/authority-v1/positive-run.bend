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
def accepted(~S:Data,value:F.Application(~S)) -> Single.RunResult<F.Application(~S),S,Error.Error<Unit>>:F.run(~S,value)
