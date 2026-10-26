import Base
import ./payloads.bend as P
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-projection.bend as Projection
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout

def layout() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutPair{Layout.LayoutLeaf{P.Input,"input"},Layout.LayoutLeaf{P.Output,"output"}},Layout.EmptyLayout{}}
def resource_layout() -> Layout.Layout: Layout.LayoutLeaf{P.Resource,"resource"}
def Store(~S:Data) -> Type: Layout.columns(~S,layout())
def Resources(~S:Data) -> Type: Layout.resources(~S,resource_layout())
def selection(~S:Data,~mode:Q.Mode,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~Store(~S),~Resources(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~Store(~S),~Resources(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~Store(~S),~Resources(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~Store(~S),~Resources(~S),~H,~B),~query:Build.Query(~S,~Store(~S),~Resources(~S),~H,~B),book:B) -> B & Q.Each<S,H,String>:
  query(layout(),Layout.InLeft{Layout.AtLeaf{}},{==},{==},{==},U32,String,P.read,P.update,Projection.trusted_affine(~P.Input,~U32,~P.read),mode,book)
def declaration(~S:Data,~mode:Q.Mode,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Resources(~S),~H,~B),book:B) -> B & Q.Each<S,H,String>:
  builder(Q.Ops(~S,~String),selection(~S,~mode,~H,~B),book)
def inserted(~S:Data,~T:Type,result:Col.SwapOutcome<S,T>) -> Col.Column<S,T>:
  match result:
    case Col.Accepted{column,_}: column
    case Col.Rejected{column,_}: column
def inputs(~S:Data) -> Col.Column<S,P.Input>:
  inserted(~S,~P.Input,Col.swap(~S,~P.Input,inserted(~S,~P.Input,Col.swap(~S,~P.Input,inserted(~S,~P.Input,Col.swap(~S,~P.Input,inserted(~S,~P.Input,Col.swap(~S,~P.Input,Col.ensure(~S,~P.Input,Col.empty(~S,~P.Input),32),1,Some{P.Input{ALeaf{501},3}})),17,Some{P.Input{ALeaf{502},5}})),16,Some{P.Input{ALeaf{503},7}})),31,Some{P.Input{ALeaf{504},99}}))
def outputs(~S:Data) -> Col.Column<S,P.Output>:
  inserted(~S,~P.Output,Col.swap(~S,~P.Output,inserted(~S,~P.Output,Col.swap(~S,~P.Output,inserted(~S,~P.Output,Col.swap(~S,~P.Output,inserted(~S,~P.Output,Col.swap(~S,~P.Output,Col.ensure(~S,~P.Output,Col.empty(~S,~P.Output),32),1,Some{P.Output{ALeaf{101},10}})),17,Some{P.Output{ALeaf{202},20}})),18,Some{P.Output{ALeaf{304},40}})),31,Some{P.Output{ALeaf{303},30}}))
def empty(~S:Data,_:Unit) -> Store(~S):
  Product.Owner{Product.Owner{Layout.ColumnSlot{inputs(~S)},Layout.ColumnSlot{outputs(~S)}},Unit{}}
def resource(~S:Data) -> Resources(~S): Layout.ResourceSlot{P.Resource{ALeaf{800}}}
