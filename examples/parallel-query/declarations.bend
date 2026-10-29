import Base
import ../../src/ecs/execution-resource-policy.bend as Policy
import ./payloads.bend as P
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout

def layout() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutPair{Layout.LayoutLeaf{P.Input,U32,P.read,"input",Policy.Ordinary{}},Layout.LayoutLeaf{P.Output,U32,P.output_view,"output",Policy.Ordinary{}}},Layout.EmptyLayout{}}
def resource_layout() -> Layout.Layout: Layout.LayoutLeaf{P.Resource,Unit,P.resource_view,"resource",Policy.Ordinary{}}
def Store(~S:Data) -> Type: Layout.columns(~S,layout())
def Resources(~S:Data) -> Type: Layout.resources(~S,resource_layout())
def Ops(~S:Data,Permit:Data,H:Type) -> Type:Q.Each<S,H,String>
def selection(~S:Data,~mode:Q.Mode,~Permit:Data,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~Store(~S),~Resources(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~Store(~S),~Resources(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~Store(~S),~Resources(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~Store(~S),~Resources(~S),~H,~B),~query:Build.Query(~S,~Store(~S),~Store(~S),~Resources(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~Store(~S),~Store(~S),~Resources(~S),~H,~B),book:B) -> B & Q.Each<S,H,String>:
  Build.basic_query(~S,~Store(~S),~Store(~S),~Resources(~S),~layout(),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~{==},~String,~P.update,~mode,~H,~B,~query,book)
def declaration(~S:Data,~mode:Q.Mode,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Store(~S),~Resources(~S),~Permit,~H,~B),book:B) -> B & Q.Each<S,H,String>:
  builder(Ops(~S),selection(~S,~mode,~Permit,~H,~B),book)
def inserted(~S:Data,~T:Type,result:Col.SwapOutcome<S,T>) -> Col.Column<S,T>:
  match result:
    case Col.Accepted{column,_}: column
    case Col.Rejected{column,_}: column
def inputs(~S:Data) -> Col.Column<S,Layout.Viewed<P.Input,U32>>:
  inserted(~S,~Layout.Viewed<P.Input,U32>,Col.swap(~S,~Layout.Viewed<P.Input,U32>,inserted(~S,~Layout.Viewed<P.Input,U32>,Col.swap(~S,~Layout.Viewed<P.Input,U32>,inserted(~S,~Layout.Viewed<P.Input,U32>,Col.swap(~S,~Layout.Viewed<P.Input,U32>,inserted(~S,~Layout.Viewed<P.Input,U32>,Col.swap(~S,~Layout.Viewed<P.Input,U32>,Col.ensure(~S,~Layout.Viewed<P.Input,U32>,Col.empty(~S,~Layout.Viewed<P.Input,U32>),32),0,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}},P.Input{ALeaf{501},3})})),16,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}},P.Input{ALeaf{502},5})})),15,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}},P.Input{ALeaf{503},7})})),30,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}},P.Input{ALeaf{504},99})}))
def outputs(~S:Data) -> Col.Column<S,Layout.Viewed<P.Output,U32>>:
  inserted(~S,~Layout.Viewed<P.Output,U32>,Col.swap(~S,~Layout.Viewed<P.Output,U32>,inserted(~S,~Layout.Viewed<P.Output,U32>,Col.swap(~S,~Layout.Viewed<P.Output,U32>,inserted(~S,~Layout.Viewed<P.Output,U32>,Col.swap(~S,~Layout.Viewed<P.Output,U32>,inserted(~S,~Layout.Viewed<P.Output,U32>,Col.swap(~S,~Layout.Viewed<P.Output,U32>,Col.ensure(~S,~Layout.Viewed<P.Output,U32>,Col.empty(~S,~Layout.Viewed<P.Output,U32>),32),0,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}},P.Output{ALeaf{101},10})})),16,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}},P.Output{ALeaf{202},20})})),17,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}},P.Output{ALeaf{304},40})})),30,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}},P.Output{ALeaf{303},30})}))
def empty(~S:Data,_:Unit) -> Store(~S):
  Product.Owner{Product.Owner{Layout.ColumnSlot{inputs(~S)},Layout.ColumnSlot{outputs(~S)}},Unit{}}
def resource(~S:Data) -> Resources(~S): Layout.ResourceSlot{Layout.initialize(resource_layout(),Layout.AtLeaf{},P.Resource{ALeaf{800}}),Layout.unknown_stamp()}
