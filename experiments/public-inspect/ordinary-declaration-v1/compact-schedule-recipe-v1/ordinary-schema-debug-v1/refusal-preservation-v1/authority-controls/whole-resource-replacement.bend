import Base
import ../frontend.bend as Front
import ../../setup.bend as Setup
import ../../modules/ordinary-app-resource-field-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
type AuthoritySchema is Data:
  AuthoritySchema{}
def rejected(~H:Type,~caps:Front.resource_ops(~AuthoritySchema)(H),owner:H,replacement:Setup.resources(~Array<U32>)) -> H:
  Field.set(~AuthoritySchema,~Array<U32>,~Setup.resource_identity(~AuthoritySchema,~Array<U32>,~Array<U32>,Front.declarations(~AuthoritySchema)),~H,~U32,~caps,owner,replacement)
