import Base
import ./payloads.bend as P
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/ordinary-declaration.bend as Identity
import ../../src/ecs/ordinary-schema.bend as Schema

def Store(~S:Data) -> Type:Product.Owner<Col.Column<S,P.Position>,Col.Column<S,P.Label>>
def Resources() -> Type:Product.Owner<P.Counter,P.Secret>
def Ops(~S:Data) -> Type -> Type:
  D.Combined(~A.ComponentWrites(~S,~P.Position,~String),~A.ResourceWrites(~P.Counter,~String))
def positions(~S:Data) -> Product.Lens<Store(~S),Col.Column<S,P.Position>,Col.Column<S,P.Label>>:
  Product.lens(~Col.Column<S,P.Position>,~Col.Column<S,P.Label>,~Product.Left{})
def counter() -> Product.Lens<Resources(),P.Counter,P.Secret>:
  Product.lens(~P.Counter,~P.Secret,~Product.Left{})
def declaration(~S:Data) -> D.Declaration<S,Store(~S),Resources(),Ops(~S)>:
  D.paired(~S,~Store(~S),~Resources(),~A.ComponentWrites(~S,~P.Position,~String),~A.ResourceWrites(~P.Counter,~String),A.component_write(~S,~Store(~S),~Resources(),~P.Position,~Col.Column<S,P.Label>,~String,~positions(~S),~P.position,Identity.component(~S,~P.Position,"position")),A.resource_write(~S,~Store(~S),~Resources(),~P.Counter,~P.Secret,~String,~counter(),~P.counter,Schema.resource(~S,~P.Counter,"counter")))
def inserted(~S:Data,~T:Type,result:Col.SwapOutcome<S,T>) -> Col.Column<S,T>:
  match result:
    case Col.Accepted{column,_}:column
    case Col.Rejected{column,_}:column
def empty(~S:Data,_:Unit) -> Store(~S):
  Product.Owner{inserted(~S,~P.Position,Col.swap(~S,~P.Position,inserted(~S,~P.Position,Col.swap(~S,~P.Position,Col.ensure(~S,~P.Position,Col.empty(~S,~P.Position),31),1,Some{P.Position{ALeaf{101},10}})),16,Some{P.Position{ALeaf{116},20}})),inserted(~S,~P.Label,Col.swap(~S,~P.Label,Col.ensure(~S,~P.Label,Col.empty(~S,~P.Label),31),2,Some{P.Label{ALeaf{202},"sentinel"}}))}
def resources() -> Resources():Product.Owner{P.Counter{ALeaf{301},0},P.Secret{ALeaf{401}}}
