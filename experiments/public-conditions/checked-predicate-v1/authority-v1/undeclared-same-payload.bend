import Base
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-condition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-composition.bend as Old
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def rejected(~S:Data,~H:Type,~caps:F.CheckOps(~S)(H),owner:H) -> H & Maybe<&2,U32>:D.read(~S,~Array<U32>,~F.identity(~S),~H,~U32,~caps,owner)
