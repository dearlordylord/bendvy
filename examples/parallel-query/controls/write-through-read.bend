import Base
import ../declarations.bend as Declaration
import ../payloads.bend as Payload
import ../../../src/ecs/chunk-column.bend as Column
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/execution-query.bend as Query
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-projection.bend as Projection
import ../../../src/ecs/ordinary-declaration.bend as Identity
type Schema is Data:
  Schema{}
def wrong_body(index:U32,read:Payload.Input,write:Payload.Output) -> Payload.Output & Maybe<&2,String>:
  (write,None{})
def selection(~H:Type,~B:Type,~component_read:Build.ComponentRead(~Schema,~Declaration.Store(~Schema),~Payload.Resource,~H,~B),~component_write:Build.ComponentWrite(~Schema,~Declaration.Store(~Schema),~Payload.Resource,~H,~B),~resource_read:Build.ResourceRead(~Schema,~Declaration.Store(~Schema),~Payload.Resource,~H,~B),~resource_write:Build.ResourceWrite(~Schema,~Declaration.Store(~Schema),~Payload.Resource,~H,~B),~query:Build.Query(~Schema,~Declaration.Store(~Schema),~Payload.Resource,~H,~B),book:B) -> B & Query.Each<Schema,H,String>:
  query(Payload.Input,Payload.Output,Unit,U32,String,Declaration.columns(~Schema),Payload.read,wrong_body,Projection.trusted_affine(~Payload.Input,~U32,~Payload.read),Query.Parallel{},Identity.component(~Schema,~Payload.Input,"input"),Identity.component(~Schema,~Payload.Output,"output"),book)
def declaration(~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Declaration.Store(~Schema),~Payload.Resource,~H,~B),book:B) -> B & Query.Each<Schema,H,String>:
  builder(Query.Ops(~Schema,~String),selection(~H,~B),book)
