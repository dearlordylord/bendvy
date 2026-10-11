import Base
import ../normal/operations.bend as Ops
import ../normal/state.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
def refuse(~H:Type,~caps:Ops.ComponentOps(H),owner:H) -> F.World() & Cmp.Access<U32>:Cap.read(~H,~U32,~caps,owner)
def main() -> Unit:Unit{}
