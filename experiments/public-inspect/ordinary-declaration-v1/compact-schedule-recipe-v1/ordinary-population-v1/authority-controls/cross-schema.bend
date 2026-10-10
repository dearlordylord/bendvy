import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-provision.bend as Provision
type Schema is Data:Schema{}
type Other is Data:Other{}
def foreign(value:Identity.Declaration<Schema,Array<U32>>) -> Provision.Provision<Other,Col.Column<Other,Array<U32>>,Unit,Provision.component_empty(~Other,~Array<U32>),Provision.component_count(~Other,~Array<U32>)>:
  Provision.component(~Other,~Array<U32>,value)
def main() -> Unit:Unit{}
