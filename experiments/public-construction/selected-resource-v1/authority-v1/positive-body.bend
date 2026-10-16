import Base
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
def accepted(~S:Data,~H:Type,~caps:F.Ops(~S)(H),owner:H,args:F.Args<S>) -> H & (T.Outcome<Unit> & F.Output<S>):F.body(~S,~H,~caps,args,owner)
