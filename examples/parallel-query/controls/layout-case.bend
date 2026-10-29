import Base
import ../../../src/ecs/execution-resource-policy.bend as Policy
import ../payloads.bend as Payload
import ../../../src/ecs/execution-query.bend as Query
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-declaration.bend as D
import ../../../src/ecs/execution-composer-layout.bend as Layout

type Schema is Data:
  Schema{}
def actual() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutLeaf{Payload.Output,U32,Payload.output_view,"public",Policy.Ordinary{}},Layout.LayoutLeaf{Payload.Output,U32,Payload.output_view,"secret",Policy.Ordinary{}}}
def wrong_keys() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutLeaf{Payload.Output,U32,Payload.output_view,"secret",Policy.Ordinary{}},Layout.LayoutLeaf{Payload.Output,U32,Payload.output_view,"public",Policy.Ordinary{}}}
def Store() -> Type: Layout.columns(~Schema,actual())
def Ops(Permit:Data,H:Type) -> Type:Query.Each<Schema,H,String>
def body(index:U32,read:U32,write:Payload.Output) -> Payload.Output & Maybe<&2,String>:
  (write,None{})
def selection(~layout:Layout.Layout,~route:Layout.Route,~same:{Store() == Layout.columns(~Schema,layout) : Type},~shape:{Layout.columns(~Schema,Layout.subtree(layout,route)) == Layout.query_pair(~Schema,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~rowbody:U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,String>,~H:Type,~B:Type,~component_read:Build.ComponentRead(~Schema,~Store(),~Unit,~H,~B),~component_write:Build.ComponentWrite(~Schema,~Store(),~Unit,~H,~B),~resource_read:Build.ResourceRead(~Schema,~Store(),~Unit,~H,~B),~resource_write:Build.ResourceWrite(~Schema,~Store(),~Unit,~H,~B),~query:Build.Query(~Schema,~Store(),~Store(),~Unit,~H,~B),~lifecycle:Build.Lifecycle(~Schema,~Store(),~Store(),~Unit,~H,~B),book:B) -> B & Query.Each<Schema,H,String>:
  Build.basic_query(~Schema,~Store(),~Store(),~Unit,~layout,~route,~same,~shape,~valid,~String,~rowbody,~Query.Parallel{},~H,~B,~query,book)
def declaration(~layout:Layout.Layout,~route:Layout.Route,~same:{Store() == Layout.columns(~Schema,layout) : Type},~shape:{Layout.columns(~Schema,Layout.subtree(layout,route)) == Layout.query_pair(~Schema,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~rowbody:U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,String>,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Store(),~Unit,~Permit,~H,~B),book:B) -> B & Query.Each<Schema,H,String>:
  builder(Ops,selection(~layout,~route,~same,~shape,~valid,~rowbody,~H,~B),book)
def compiled(~layout:Layout.Layout,~route:Layout.Route,~same:{Store() == Layout.columns(~Schema,layout) : Type},~shape:{Layout.columns(~Schema,Layout.subtree(layout,route)) == Layout.query_pair(~Schema,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~rowbody:U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,String>) -> D.Compilation<Schema,Store(),Store(),Unit,Ops>:
  Build.compile(~Schema,~Store(),~Store(),~Unit,~Ops,~declaration(~layout,~route,~same,~shape,~valid,~rowbody))
