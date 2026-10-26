import Base
import ./payloads.bend as P
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-projection.bend as Projection
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/ordinary-declaration.bend as Identity
import ../../src/ecs/ordinary-schema.bend as Schema
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/capabilities.bend as Cap
def inserted(~S:Data,~T:Type,result:Col.SwapOutcome<S,T>) -> Col.Column<S,T>:
  match result:
    case Col.Accepted{column,_}:column
    case Col.Rejected{column,_}:column
def LeftStore(~S:Data) -> Type:Product.Owner<Col.Column<S,P.Position>,Unit>
def LeftResource() -> Type:Product.Owner<P.Counter,Unit>
def LeftOps(~S:Data) -> Type -> Type:D.Combined(~A.ComponentWrites(~S,~P.Position,~String),~A.ResourceWrites(~P.Counter,~String))
def left_column(~S:Data) -> Product.Lens<LeftStore(~S),Col.Column<S,P.Position>,Unit>:Product.lens(~Col.Column<S,P.Position>,~Unit,~Product.Left{})
def left_resource() -> Product.Lens<LeftResource(),P.Counter,Unit>:Product.lens(~P.Counter,~Unit,~Product.Left{})
def left_combined(~S:Data,~H:Type,~B:Type,component:A.ComponentWrite<S,H,P.Position,String>,result:B & A.ResourceWrite<H,P.Counter,String>) -> B & LeftOps(~S)(H):
  match result:
    case (book,resource):(book,Cap.Bundle{component,resource})
def left_component_granted(~S:Data,~H:Type,~B:Type,~resource_write:Build.ResourceWrite(~S,~LeftStore(~S),~LeftResource(),~H,~B),result:B & A.ComponentWrite<S,H,P.Position,String>) -> B & LeftOps(~S)(H):
  match result:
    case (book,component):left_combined(~S,~H,~B,component,resource_write(P.Counter,Unit,String,left_resource(),P.counter,Projection.trusted_affine(~P.Counter,~String,~P.counter),Schema.resource(~S,~P.Counter,"counter"),book))
def left_selection(~S:Data,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~LeftStore(~S),~LeftResource(),~H,~B),~component_write:Build.ComponentWrite(~S,~LeftStore(~S),~LeftResource(),~H,~B),~resource_read:Build.ResourceRead(~S,~LeftStore(~S),~LeftResource(),~H,~B),~resource_write:Build.ResourceWrite(~S,~LeftStore(~S),~LeftResource(),~H,~B),~query:Build.Query(~S,~LeftStore(~S),~LeftResource(),~H,~B),book:B) -> B & LeftOps(~S)(H):
  left_component_granted(~S,~H,~B,~resource_write,component_write(P.Position,Unit,String,left_column(~S),P.position,Projection.trusted_affine(~P.Position,~String,~P.position),Identity.component(~S,~P.Position,"position"),book))
def left(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~LeftStore(~S),~LeftResource(),~H,~B),book:B) -> B & LeftOps(~S)(H):
  builder(LeftOps(~S),left_selection(~S,~H,~B),book)
def left_store(~S:Data) -> LeftStore(~S):
  Product.Owner{inserted(~S,~P.Position,Col.swap(~S,~P.Position,inserted(~S,~P.Position,Col.swap(~S,~P.Position,Col.ensure(~S,~P.Position,Col.empty(~S,~P.Position),31),1,Some{P.Position{ALeaf{101},10}})),17,Some{P.Position{ALeaf{118},70}})),Unit{}}
def left_resources() -> LeftResource():Product.Owner{P.Counter{ALeaf{301},0},Unit{}}
def RightStore(~S:Data) -> Type:Product.Owner<Col.Column<S,P.Health>,Unit>
def RightResource() -> Type:Product.Owner<P.Score,Unit>
def RightOps(~S:Data) -> Type -> Type:D.Combined(~A.ComponentWrites(~S,~P.Health,~String),~A.ResourceWrites(~P.Score,~String))
def right_column(~S:Data) -> Product.Lens<RightStore(~S),Col.Column<S,P.Health>,Unit>:Product.lens(~Col.Column<S,P.Health>,~Unit,~Product.Left{})
def right_resource() -> Product.Lens<RightResource(),P.Score,Unit>:Product.lens(~P.Score,~Unit,~Product.Left{})
def right_combined(~S:Data,~H:Type,~B:Type,component:A.ComponentWrite<S,H,P.Health,String>,result:B & A.ResourceWrite<H,P.Score,String>) -> B & RightOps(~S)(H):
  match result:
    case (book,resource):(book,Cap.Bundle{component,resource})
def right_component_granted(~S:Data,~H:Type,~B:Type,~resource_write:Build.ResourceWrite(~S,~RightStore(~S),~RightResource(),~H,~B),result:B & A.ComponentWrite<S,H,P.Health,String>) -> B & RightOps(~S)(H):
  match result:
    case (book,component):right_combined(~S,~H,~B,component,resource_write(P.Score,Unit,String,right_resource(),P.score,Projection.trusted_affine(~P.Score,~String,~P.score),Schema.resource(~S,~P.Score,"score"),book))
def right_selection(~S:Data,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~RightStore(~S),~RightResource(),~H,~B),~component_write:Build.ComponentWrite(~S,~RightStore(~S),~RightResource(),~H,~B),~resource_read:Build.ResourceRead(~S,~RightStore(~S),~RightResource(),~H,~B),~resource_write:Build.ResourceWrite(~S,~RightStore(~S),~RightResource(),~H,~B),~query:Build.Query(~S,~RightStore(~S),~RightResource(),~H,~B),book:B) -> B & RightOps(~S)(H):
  right_component_granted(~S,~H,~B,~resource_write,component_write(P.Health,Unit,String,right_column(~S),P.health,Projection.trusted_affine(~P.Health,~String,~P.health),Identity.component(~S,~P.Health,"health"),book))
def right(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~RightStore(~S),~RightResource(),~H,~B),book:B) -> B & RightOps(~S)(H):
  builder(RightOps(~S),right_selection(~S,~H,~B),book)
def right_store(~S:Data) -> RightStore(~S):
  Product.Owner{inserted(~S,~P.Health,Col.swap(~S,~P.Health,inserted(~S,~P.Health,Col.swap(~S,~P.Health,Col.ensure(~S,~P.Health,Col.empty(~S,~P.Health),31),1,Some{P.Health{ALeaf{201},10}})),9,Some{P.Health{ALeaf{210},80}})),Unit{}}
def right_resources() -> RightResource():Product.Owner{P.Score{ALeaf{401},0},Unit{}}
def Store(~S:Data) -> Type:Product.Owner<LeftStore(~S),RightStore(~S)>
def Resources() -> Type:Product.Owner<LeftResource(),RightResource()>
def empty(~S:Data,_:Unit) -> Store(~S):Product.Owner{left_store(~S),right_store(~S)}
def resources() -> Resources():Product.Owner{left_resources(),right_resources()}
