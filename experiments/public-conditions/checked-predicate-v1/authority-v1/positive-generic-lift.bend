import Base
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-condition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-composition.bend as Old
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def accepted(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Old.Evaluation<World,Owner>,condition:Old.Condition<World,Owner,evaluate>) -> Cond.Condition<World,Owner,Cond.lift_run(~World,~Owner,~evaluate)>:Cond.lift(~World,~Owner,~evaluate,condition)
