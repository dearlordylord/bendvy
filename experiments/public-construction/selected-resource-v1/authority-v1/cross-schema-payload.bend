import Base
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
def rejected(~H:Type,~caps:F.Ops(~F.Workshop)(H),owner:H,value:F.Payload<F.Garden>) -> H:Field.set(~F.Workshop,~F.Payload<F.Workshop>,~F.target_identity(~F.Workshop),~H,~U32,~caps,owner,value)
