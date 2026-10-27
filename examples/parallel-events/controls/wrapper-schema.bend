import Base
import ./positive.bend as P
import ../scenario.bend as D
import ../../../src/ecs/execution-event-view.bend as View
import ../../../src/ecs/execution-event-ops.bend as Ops
import ../../../src/ecs/execution-access.bend as Access
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-composer-layout.bend as Layout

def granted(~H:Type,~B:Type,result:B & Access.ResourceRead<H,View.View<P.SchemaA,Array<U32>,"events",U32>>) -> B & Ops.Reader<P.SchemaB,H,Array<U32>,"events",U32>:
  match result:
    case (book,cap):(book,Ops.reader(~P.SchemaB,~H,~Array<U32>,~"events",~U32,cap))
def selection(~H:Type,~B:Type,~rr:Build.ResourceRead(~P.SchemaA,~Unit,~D.Resources(~P.SchemaA,~Array<U32>,~P.project),~H,~B),book:B) -> B & Ops.Reader<P.SchemaB,H,Array<U32>,"events",U32>:
  granted(~H,~B,Build.basic_resource_read(~P.SchemaA,~Unit,~D.Resources(~P.SchemaA,~Array<U32>,~P.project),~H,~B,~D.layout(~P.SchemaA,~Array<U32>,~P.project),~Layout.AtLeaf{},~{==},~{==},~rr,book))
