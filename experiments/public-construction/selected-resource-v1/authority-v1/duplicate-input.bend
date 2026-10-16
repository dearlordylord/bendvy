import Base
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
def rejected(value:F.Input<F.Workshop>) -> F.Input<F.Workshop> & F.Input<F.Workshop>:(value,value)
