import Base
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-condition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-composition.bend as Old
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def bad(~S:Data,~H:Type,~caps:F.CheckOps(~S)(H),_:Unit,owner:H) -> H & U32:(owner,1)
def rejected(~S:Data) -> Cond.Condition<F.World(~S),Unit,Cond.check_run(~S,~Unit,~F.Resources(~S),~Unit,~F.CheckOps(~S),~Unit,~bad(~S),~F.required(~S))>:Cond.check(~S,~Unit,~F.Resources(~S),~Unit,~F.CheckOps(~S),~Unit,~bad(~S),~F.required(~S),"bad",Unit{})
