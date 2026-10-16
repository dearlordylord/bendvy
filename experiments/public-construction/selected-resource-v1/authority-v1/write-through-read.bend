import Base
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
def rejected(~S:Data,~H:Type,~caps:Field.Read<S,F.Payload<S>,F.target_identity(~S),H,U32>,owner:H,value:F.Payload<S>) -> H:Field.set(~S,~F.Payload<S>,~F.target_identity(~S),~H,~U32,~caps,owner,value)
