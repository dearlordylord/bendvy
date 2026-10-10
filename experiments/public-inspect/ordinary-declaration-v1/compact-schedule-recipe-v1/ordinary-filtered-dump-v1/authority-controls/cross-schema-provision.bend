import Base
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-provision.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-dump.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-builtin.bend as Builtin
type Schema is Data:Schema{}
type Other is Data:Other{}
def foreign(value:Identity.Declaration<Schema,Array<U32>>) -> Provision.Provision<Other,Col.Column<Other,Array<U32>>,Unit,Ordinary.component_empty(~Other,~Array<U32>),Ordinary.component_count(~Other,~Array<U32>),Provision.component_read(~Other,~Array<U32>,~Builtin.array),Provision.component_resources>:
  Provision.array_component(~Other,value)
def main() -> Unit:Unit{}
