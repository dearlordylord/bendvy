import Base
import ./payloads.bend as P
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-projection.bend as Projection
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/ordinary-declaration.bend as Identity

def Columns(~S:Data) -> Type: Product.Owner<Col.Column<S,P.Input>,Col.Column<S,P.Output>>
def Store(~S:Data) -> Type: Product.Owner<Columns(~S),Unit>
def columns(~S:Data) -> Product.Lens<Store(~S),Columns(~S),Unit>:
  Product.lens(~Columns(~S),~Unit,~Product.Left{})
def selection(~S:Data,~mode:Q.Mode,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~Store(~S),~P.Resource,~H,~B),~component_write:Build.ComponentWrite(~S,~Store(~S),~P.Resource,~H,~B),~resource_read:Build.ResourceRead(~S,~Store(~S),~P.Resource,~H,~B),~resource_write:Build.ResourceWrite(~S,~Store(~S),~P.Resource,~H,~B),~query:Build.Query(~S,~Store(~S),~P.Resource,~H,~B),book:B) -> B & Q.Each<S,H,String>:
  query(P.Input,P.Output,Unit,U32,String,columns(~S),P.read,P.update,Projection.trusted_affine(~P.Input,~U32,~P.read),mode,Identity.component(~S,~P.Input,"input"),Identity.component(~S,~P.Output,"output"),book)
def declaration(~S:Data,~mode:Q.Mode,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~P.Resource,~H,~B),book:B) -> B & Q.Each<S,H,String>:
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
  Product.Owner{Product.Owner{inputs(~S),outputs(~S)},Unit{}}
def resource() -> P.Resource: P.Resource{ALeaf{800}}
