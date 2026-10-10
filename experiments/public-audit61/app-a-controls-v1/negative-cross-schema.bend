import Base
import ./bundle.bend as B
import ./resources.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
type Other is Data:
  Other{}
def foreign_counter() -> Schema.Resource<Other,Array<U32>>:
  Schema.resource(~Other,~Array<U32>,"Counter")
# Same payload/name, distinct schema: actual Counter grant cannot cross it.
def rejected(~H:Type,~cap:R.Ops(H),unit:Unit,owner:H) -> H & (T.Outcome<Unit> & Unit):
  (Field.set(~Other,~Array<U32>,~foreign_counter(),~H,~List<&2,U32>,~cap,owner,ANode{ALeaf{21},ALeaf{22}}),(T.Success{},Unit{}))
def main() -> Unit:
  Unit{}
