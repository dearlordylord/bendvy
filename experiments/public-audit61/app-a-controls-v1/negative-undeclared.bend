import Base
import ./bundle.bend as B
import ./resources.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
# Gameplay receives only Counter's nominal write grant. Sibling is undeclared.
def rejected(~H:Type,~cap:R.Ops(H),unit:Unit,owner:H) -> H & (T.Outcome<Unit> & Unit):
  (Field.set(~B.AuditWorkshop,~Array<U32>,~R.Sibling(),~H,~List<&2,U32>,~cap,owner,ANode{ALeaf{21},ALeaf{22}}),(T.Success{},Unit{}))
def main() -> Unit:
  Unit{}
