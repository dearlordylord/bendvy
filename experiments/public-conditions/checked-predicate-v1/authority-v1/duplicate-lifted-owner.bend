import Base
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-condition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-composition.bend as Old
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def rejected(~World:Type,~evaluate:Array<U32> -> World -> Old.Evaluation<World,Array<U32>>,condition:Cond.Condition<World,Array<U32>,Cond.lift_run(~World,~Array<U32>,~evaluate)>) -> Cond.Condition<World,Array<U32>,Cond.lift_run(~World,~Array<U32>,~evaluate)> & Cond.Condition<World,Array<U32>,Cond.lift_run(~World,~Array<U32>,~evaluate)>:(condition,condition)
