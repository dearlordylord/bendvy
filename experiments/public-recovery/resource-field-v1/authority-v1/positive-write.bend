import Base
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recoverable-array-resource.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-resource-field.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Read
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product

type First is Data:First{}
type Other is Data:Other{}
def positive(~H:Type,~caps:F.Ops(~First)(H),owner:H,incoming:Array<Array<U32>>) -> H:
  O.replace(~First,~Array<U32>,~F.identity(~First),~H,~caps,owner,incoming)
