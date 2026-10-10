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
def rejected(~H:Type,~caps:Front.resource_ops(~AuthoritySchema)(H),owner:H) -> H:
  Field.set(~AuthoritySchema,~Array<U32>,~Schema.resource(~AuthoritySchema,~Array<U32>,"UndeclaredCounter"),~H,~U32,~caps,owner,Array.new(U32,0n,77))
