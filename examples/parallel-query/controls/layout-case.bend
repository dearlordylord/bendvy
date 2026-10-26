import Base
import ../payloads.bend as Payload
import ../../../src/ecs/execution-query.bend as Query
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-declaration.bend as D
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/execution-projection.bend as Projection

type Schema is Data:
  Schema{}
def actual() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutLeaf{Payload.Output,"public"},Layout.LayoutLeaf{Payload.Output,"secret"}}
def wrong_keys() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutLeaf{Payload.Output,"secret"},Layout.LayoutLeaf{Payload.Output,"public"}}
def Store() -> Type: Layout.columns(~Schema,actual())
def body(index:U32,read:String,write:Payload.Output) -> Payload.Output & Maybe<&2,String>:
  (write,None{})
def selection(~layout:Layout.Layout,~route:Layout.Route,~same:{Store() == Layout.columns(~Schema,layout) : Type},~shape:{Layout.columns(~Schema,Layout.subtree(layout,route)) == Layout.query_pair(~Schema,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~project:Layout.query_input(layout,route) -> Layout.query_input(layout,route) & String,~rowbody:U32 -> String -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,String>,~H:Type,~B:Type,~component_read:Build.ComponentRead(~Schema,~Store(),~Unit,~H,~B),~component_write:Build.ComponentWrite(~Schema,~Store(),~Unit,~H,~B),~resource_read:Build.ResourceRead(~Schema,~Store(),~Unit,~H,~B),~resource_write:Build.ResourceWrite(~Schema,~Store(),~Unit,~H,~B),~query:Build.Query(~Schema,~Store(),~Unit,~H,~B),book:B) -> B & Query.Each<Schema,H,String>:
  query(layout,route,same,shape,valid,String,String,project,rowbody,Projection.trusted_affine(~Layout.query_input(layout,route),~String,~project),Query.Parallel{},book)
def declaration(~layout:Layout.Layout,~route:Layout.Route,~same:{Store() == Layout.columns(~Schema,layout) : Type},~shape:{Layout.columns(~Schema,Layout.subtree(layout,route)) == Layout.query_pair(~Schema,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~project:Layout.query_input(layout,route) -> Layout.query_input(layout,route) & String,~rowbody:U32 -> String -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,String>,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Unit,~H,~B),book:B) -> B & Query.Each<Schema,H,String>:
  builder(Query.Ops(~Schema,~String),selection(~layout,~route,~same,~shape,~valid,~project,~rowbody,~H,~B),book)
def compiled(~layout:Layout.Layout,~route:Layout.Route,~same:{Store() == Layout.columns(~Schema,layout) : Type},~shape:{Layout.columns(~Schema,Layout.subtree(layout,route)) == Layout.query_pair(~Schema,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~project:Layout.query_input(layout,route) -> Layout.query_input(layout,route) & String,~rowbody:U32 -> String -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,String>) -> D.Declaration<Schema,Store(),Unit,Query.Ops(~Schema,~String)>:
  Build.compile(~Schema,~Store(),~Unit,~Query.Ops(~Schema,~String),~declaration(~layout,~route,~same,~shape,~valid,~project,~rowbody))
