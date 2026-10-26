import Base
import ../declarations.bend as Declaration
import ../payloads.bend as Payload
import ../../../src/ecs/execution-query.bend as Query
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-composer-layout.bend as Layout
type Schema is Data:
  Schema{}
def wrong_body(index:U32,read:Payload.Input,write:Payload.Output) -> Payload.Output & Maybe<&2,String>:
  (write,None{})
def selection(~H:Type,~B:Type,~component_read:Build.ComponentRead(~Schema,~Declaration.Store(~Schema),~Declaration.Resources(~Schema),~H,~B),~component_write:Build.ComponentWrite(~Schema,~Declaration.Store(~Schema),~Declaration.Resources(~Schema),~H,~B),~resource_read:Build.ResourceRead(~Schema,~Declaration.Store(~Schema),~Declaration.Resources(~Schema),~H,~B),~resource_write:Build.ResourceWrite(~Schema,~Declaration.Store(~Schema),~Declaration.Resources(~Schema),~H,~B),~query:Build.Query(~Schema,~Declaration.Store(~Schema),~Declaration.Resources(~Schema),~H,~B),book:B) -> B & Query.Each<Schema,H,String>:
  Build.basic_query(~Schema,~Declaration.Store(~Schema),~Declaration.Resources(~Schema),~Declaration.layout(),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~{==},~String,~wrong_body,~Query.Parallel{},~H,~B,~query,book)
def declaration(~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Declaration.Store(~Schema),~Declaration.Resources(~Schema),~H,~B),book:B) -> B & Query.Each<Schema,H,String>:
  builder(Query.Ops(~Schema,~String),selection(~H,~B),book)
