import Base
import ../normal/operations.bend as Ops
import ../normal/state.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
def refuse(~H:Type,~caps:Unit,owner:H) -> H & (Tx.Outcome<Unit> & Unit):Ops.component_completed(~H,Cap.read(~H,~U32,~caps,owner))
def main() -> Unit:Unit{}
