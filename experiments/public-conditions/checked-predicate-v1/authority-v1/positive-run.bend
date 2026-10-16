import Base
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-condition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-composition.bend as Old
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/checked-condition-schedule.bend as Error
def accepted(~S:Data,app:F.Application(~S)) -> Single.RunResult<F.Application(~S),S,Error.Error<String>>:F.run(~S,app)
