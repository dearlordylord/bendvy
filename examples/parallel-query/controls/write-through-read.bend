import Base
import ../declarations.bend as Declaration
import ../payloads.bend as Payload
import ../../../src/ecs/chunk-column.bend as Column
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/execution-query.bend as Query
import ../../../src/ecs/execution-declaration.bend as D
import ../../../src/ecs/execution-projection.bend as Projection
import ../../../src/ecs/ordinary-declaration.bend as Identity
type Schema is Data:
  Schema{}
def wrong_body(index:U32,read:Payload.Input,write:Payload.Output) -> Payload.Output & Maybe<&2,String>:
  (write,None{})
def declaration() -> D.Declaration<Schema,Declaration.Store(~Schema),Payload.Resource,Query.Ops(~Schema,~String)>:
  Query.declaration(~Schema,~Declaration.Store(~Schema),~Payload.Resource,~Payload.Input,~Payload.Output,~Unit,~U32,~String,~Declaration.columns(~Schema),~Payload.read,~wrong_body,Projection.trusted_affine(~Payload.Input,~U32,~Payload.read),Query.Parallel{},Identity.component(~Schema,~Payload.Input,"input"),Identity.component(~Schema,~Payload.Output,"output"))
