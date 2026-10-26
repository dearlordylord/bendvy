import Base
import ../../src/ecs/execution-composer-layout.bend as Layout
import ./payloads.bend as P
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/capabilities.bend as Cap
def inserted(~S:Data,~T:Type,result:Col.SwapOutcome<S,T>) -> Col.Column<S,T>:
  match result:
    case Col.Accepted{column,_}:column
    case Col.Rejected{column,_}:column
def left_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Position,String,P.position,"position"}
def left_resource_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Counter,String,P.counter,"counter"}
def LeftStore(~S:Data) -> Type:Layout.columns(~S,left_layout())
def LeftResource(~S:Data) -> Type:Layout.resources(~S,left_resource_layout())
def LeftOps(~S:Data) -> Type -> Type:D.Combined(~A.ComponentWrites(~S,~P.Position,~String),~A.ResourceWrites(~P.Counter,~String))
def left_combined(~S:Data,~H:Type,~B:Type,component:A.ComponentWrite<S,H,P.Position,String>,result:B & A.ResourceWrite<H,P.Counter,String>) -> B & LeftOps(~S)(H):
  match result:
    case (book,resource):(book,Cap.Bundle{component,resource})
def left_component_granted(~S:Data,~H:Type,~B:Type,~resource_write:Build.ResourceWrite(~S,~LeftStore(~S),~LeftResource(~S),~H,~B),result:B & A.ComponentWrite<S,H,P.Position,String>) -> B & LeftOps(~S)(H):
  match result:
    case (book,component):left_combined(~S,~H,~B,component,resource_write(left_resource_layout(),Layout.AtLeaf{},{==},{==},book))
def left_selection(~S:Data,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~LeftStore(~S),~LeftResource(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~LeftStore(~S),~LeftResource(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~LeftStore(~S),~LeftResource(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~LeftStore(~S),~LeftResource(~S),~H,~B),~query:Build.Query(~S,~LeftStore(~S),~LeftResource(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~LeftStore(~S),~LeftResource(~S),~H,~B),book:B) -> B & LeftOps(~S)(H):
  left_component_granted(~S,~H,~B,~resource_write,component_write(left_layout(),Layout.AtLeaf{},{==},{==},book))
def left(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~LeftStore(~S),~LeftResource(~S),~H,~B),book:B) -> B & LeftOps(~S)(H):
  builder(LeftOps(~S),left_selection(~S,~H,~B),book)
def left_store(~S:Data) -> LeftStore(~S):
  Layout.ColumnSlot{inserted(~S,~Layout.Viewed<P.Position,String>,Col.swap(~S,~Layout.Viewed<P.Position,String>,inserted(~S,~Layout.Viewed<P.Position,String>,Col.swap(~S,~Layout.Viewed<P.Position,String>,Col.ensure(~S,~Layout.Viewed<P.Position,String>,Col.empty(~S,~Layout.Viewed<P.Position,String>),31),1,Some{Layout.initialize(left_layout(),Layout.AtLeaf{},P.Position{ALeaf{101},10})})),17,Some{Layout.initialize(left_layout(),Layout.AtLeaf{},P.Position{ALeaf{118},70})}))}
def left_resources(~S:Data) -> LeftResource(~S):Layout.ResourceSlot{Layout.initialize(left_resource_layout(),Layout.AtLeaf{},P.Counter{ALeaf{301},0})}
def right_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Health,String,P.health,"health"}
def right_resource_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Score,String,P.score,"score"}
def RightStore(~S:Data) -> Type:Layout.columns(~S,right_layout())
def RightResource(~S:Data) -> Type:Layout.resources(~S,right_resource_layout())
def RightOps(~S:Data) -> Type -> Type:D.Combined(~A.ComponentWrites(~S,~P.Health,~String),~A.ResourceWrites(~P.Score,~String))
def right_combined(~S:Data,~H:Type,~B:Type,component:A.ComponentWrite<S,H,P.Health,String>,result:B & A.ResourceWrite<H,P.Score,String>) -> B & RightOps(~S)(H):
  match result:
    case (book,resource):(book,Cap.Bundle{component,resource})
def right_component_granted(~S:Data,~H:Type,~B:Type,~resource_write:Build.ResourceWrite(~S,~RightStore(~S),~RightResource(~S),~H,~B),result:B & A.ComponentWrite<S,H,P.Health,String>) -> B & RightOps(~S)(H):
  match result:
    case (book,component):right_combined(~S,~H,~B,component,resource_write(right_resource_layout(),Layout.AtLeaf{},{==},{==},book))
def right_selection(~S:Data,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~RightStore(~S),~RightResource(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~RightStore(~S),~RightResource(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~RightStore(~S),~RightResource(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~RightStore(~S),~RightResource(~S),~H,~B),~query:Build.Query(~S,~RightStore(~S),~RightResource(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~RightStore(~S),~RightResource(~S),~H,~B),book:B) -> B & RightOps(~S)(H):
  right_component_granted(~S,~H,~B,~resource_write,component_write(right_layout(),Layout.AtLeaf{},{==},{==},book))
def right(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~RightStore(~S),~RightResource(~S),~H,~B),book:B) -> B & RightOps(~S)(H):
  builder(RightOps(~S),right_selection(~S,~H,~B),book)
def right_store(~S:Data) -> RightStore(~S):
  Layout.ColumnSlot{inserted(~S,~Layout.Viewed<P.Health,String>,Col.swap(~S,~Layout.Viewed<P.Health,String>,inserted(~S,~Layout.Viewed<P.Health,String>,Col.swap(~S,~Layout.Viewed<P.Health,String>,Col.ensure(~S,~Layout.Viewed<P.Health,String>,Col.empty(~S,~Layout.Viewed<P.Health,String>),31),1,Some{Layout.initialize(right_layout(),Layout.AtLeaf{},P.Health{ALeaf{201},10})})),9,Some{Layout.initialize(right_layout(),Layout.AtLeaf{},P.Health{ALeaf{210},80})}))}
def right_resources(~S:Data) -> RightResource(~S):Layout.ResourceSlot{Layout.initialize(right_resource_layout(),Layout.AtLeaf{},P.Score{ALeaf{401},0})}
def Store(~S:Data) -> Type:Product.Owner<LeftStore(~S),RightStore(~S)>
def Resources(~S:Data) -> Type:Product.Owner<LeftResource(~S),RightResource(~S)>
def empty(~S:Data,_:Unit) -> Store(~S):Product.Owner{left_store(~S),right_store(~S)}
def resources(~S:Data) -> Resources(~S):Product.Owner{left_resources(~S),right_resources(~S)}
