import Base
import ../normal/operations.bend as Ops
import ../normal/state.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
def refuse(~H:Type,~caps:Ops.ComponentOps(H),owner:H) -> H & (H -> Array<U32> -> H):(owner,Cap.write_field(~H,~Array<U32>,~U32,caps))
def main() -> Unit:Unit{}
