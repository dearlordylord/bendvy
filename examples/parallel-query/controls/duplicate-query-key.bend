import Base
import ./layout-case.bend as Case
import ../payloads.bend as Payload
import ../../../src/ecs/execution-query.bend as Query
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-composer-layout.bend as Layout

def layout() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutLeaf{Payload.Output,U32,Payload.output_view,"public"},Layout.LayoutLeaf{Payload.Output,U32,Payload.output_view,"public"}}
def Store() -> Type: Layout.columns(~Case.Schema,layout())
def selection(~H:Type,~B:Type,~component_read:Build.ComponentRead(~Case.Schema,~Store(),~Unit,~H,~B),~component_write:Build.ComponentWrite(~Case.Schema,~Store(),~Unit,~H,~B),~resource_read:Build.ResourceRead(~Case.Schema,~Store(),~Unit,~H,~B),~resource_write:Build.ResourceWrite(~Case.Schema,~Store(),~Unit,~H,~B),~query:Build.Query(~Case.Schema,~Store(),~Store(),~Unit,~H,~B),~lifecycle:Build.Lifecycle(~Case.Schema,~Store(),~Store(),~Unit,~H,~B),book:B) -> B & Query.Each<Case.Schema,H,String>:
  Build.basic_query(~Case.Schema,~Store(),~Store(),~Unit,~layout(),~Layout.AtLeaf{},~{==},~{==},~{==},~String,~Case.body,~Query.Parallel{},~H,~B,~query,book)
