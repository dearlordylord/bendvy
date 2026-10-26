import Base
import ./payloads.bend as P
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout

def layout() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutPair{Layout.LayoutLeaf{P.Input,U32,P.read,"input"},Layout.LayoutLeaf{P.Output,U32,P.output_view,"output"}},Layout.EmptyLayout{}}
def resource_layout() -> Layout.Layout: Layout.LayoutLeaf{P.Resource,Unit,P.resource_view,"resource"}
def Store(~S:Data) -> Type: Layout.columns(~S,layout())
def Resources(~S:Data) -> Type: Layout.resources(~S,resource_layout())
def selection(~S:Data,~mode:Q.Mode,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~Store(~S),~Resources(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~Store(~S),~Resources(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~Store(~S),~Resources(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~Store(~S),~Resources(~S),~H,~B),~query:Build.Query(~S,~Store(~S),~Resources(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~Store(~S),~Store(~S),~Resources(~S),~H,~B),book:B) -> B & Q.Each<S,H,String>:
  Build.basic_query(~S,~Store(~S),~Resources(~S),~layout(),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~{==},~String,~P.update,~mode,~H,~B,~query,book)
def declaration(~S:Data,~mode:Q.Mode,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Store(~S),~Resources(~S),~H,~B),book:B) -> B & Q.Each<S,H,String>:
  builder(Q.Ops(~S,~String),selection(~S,~mode,~H,~B),book)
def inserted(~S:Data,~T:Type,result:Col.SwapOutcome<S,T>) -> Col.Column<S,T>:
  match result:
    case Col.Accepted{column,_}: column
    case Col.Rejected{column,_}: column
def inputs(~S:Data) -> Col.Column<S,Layout.Viewed<P.Input,U32>>:
  inserted(~S,~Layout.Viewed<P.Input,U32>,Col.swap(~S,~Layout.Viewed<P.Input,U32>,inserted(~S,~Layout.Viewed<P.Input,U32>,Col.swap(~S,~Layout.Viewed<P.Input,U32>,inserted(~S,~Layout.Viewed<P.Input,U32>,Col.swap(~S,~Layout.Viewed<P.Input,U32>,inserted(~S,~Layout.Viewed<P.Input,U32>,Col.swap(~S,~Layout.Viewed<P.Input,U32>,Col.ensure(~S,~Layout.Viewed<P.Input,U32>,Col.empty(~S,~Layout.Viewed<P.Input,U32>),32),1,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}},P.Input{ALeaf{501},3})})),17,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}},P.Input{ALeaf{502},5})})),16,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}},P.Input{ALeaf{503},7})})),31,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}},P.Input{ALeaf{504},99})}))
def outputs(~S:Data) -> Col.Column<S,Layout.Viewed<P.Output,U32>>:
  inserted(~S,~Layout.Viewed<P.Output,U32>,Col.swap(~S,~Layout.Viewed<P.Output,U32>,inserted(~S,~Layout.Viewed<P.Output,U32>,Col.swap(~S,~Layout.Viewed<P.Output,U32>,inserted(~S,~Layout.Viewed<P.Output,U32>,Col.swap(~S,~Layout.Viewed<P.Output,U32>,inserted(~S,~Layout.Viewed<P.Output,U32>,Col.swap(~S,~Layout.Viewed<P.Output,U32>,Col.ensure(~S,~Layout.Viewed<P.Output,U32>,Col.empty(~S,~Layout.Viewed<P.Output,U32>),32),1,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}},P.Output{ALeaf{101},10})})),17,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}},P.Output{ALeaf{202},20})})),18,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}},P.Output{ALeaf{304},40})})),31,Some{Layout.initialize(layout(),Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}},P.Output{ALeaf{303},30})}))
def empty(~S:Data,_:Unit) -> Store(~S):
  Product.Owner{Product.Owner{Layout.ColumnSlot{inputs(~S)},Layout.ColumnSlot{outputs(~S)}},Unit{}}
def resource(~S:Data) -> Resources(~S): Layout.ResourceSlot{Layout.initialize(resource_layout(),Layout.AtLeaf{},P.Resource{ALeaf{800}})}
