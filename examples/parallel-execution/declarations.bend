import Base
import ./payloads.bend as P
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-projection.bend as Projection
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/execution-composer-layout.bend as Layout

def component_layout() -> Layout.Layout:Layout.LayoutPair{Layout.LayoutLeaf{P.Position,String,P.position,"position"},Layout.LayoutLeaf{P.Label,String,P.label,"label"}}
def resource_layout() -> Layout.Layout:Layout.LayoutPair{Layout.LayoutLeaf{P.Counter,String,P.counter,"counter"},Layout.LayoutLeaf{P.Secret,String,P.secret,"secret"}}
def first_route() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def Store(~S:Data) -> Type:Layout.columns(~S,component_layout())
def Resources(~S:Data) -> Type:Layout.resources(~S,resource_layout())
def Ops(~S:Data) -> Type -> Type:
  D.Combined(~A.ComponentWrites(~S,~P.Position,~String),~A.ResourceWrites(~P.Counter,~String))
def combined(~S:Data,~H:Type,~B:Type,positions:A.ComponentWrite<S,H,P.Position,String>,result:B & A.ResourceWrite<H,P.Counter,String>) -> B & Ops(~S)(H):
  match result:
    case (book,counter):(book,Cap.Bundle{positions,counter})
def position_granted(~S:Data,~H:Type,~B:Type,~resource_write:Build.ResourceWrite(~S,~Store(~S),~Resources(~S),~H,~B),result:B & A.ComponentWrite<S,H,P.Position,String>) -> B & Ops(~S)(H):
  match result:
    case (book,positions):combined(~S,~H,~B,positions,resource_write(resource_layout(),first_route(),{==},{==},book))
def selection(~S:Data,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~Store(~S),~Resources(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~Store(~S),~Resources(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~Store(~S),~Resources(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~Store(~S),~Resources(~S),~H,~B),~query:Build.Query(~S,~Store(~S),~Resources(~S),~H,~B),book:B) -> B & Ops(~S)(H):
  position_granted(~S,~H,~B,~resource_write,component_write(component_layout(),first_route(),{==},{==},book))
def declaration(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Resources(~S),~H,~B),book:B) -> B & Ops(~S)(H):
  builder(Ops(~S),selection(~S,~H,~B),book)
def inserted(~S:Data,~T:Type,result:Col.SwapOutcome<S,T>) -> Col.Column<S,T>:
  match result:
    case Col.Accepted{column,_}:column
    case Col.Rejected{column,_}:column
def empty(~S:Data,_:Unit) -> Store(~S):
  Product.Owner{Layout.ColumnSlot{inserted(~S,~Layout.Viewed<P.Position,String>,Col.swap(~S,~Layout.Viewed<P.Position,String>,inserted(~S,~Layout.Viewed<P.Position,String>,Col.swap(~S,~Layout.Viewed<P.Position,String>,Col.ensure(~S,~Layout.Viewed<P.Position,String>,Col.empty(~S,~Layout.Viewed<P.Position,String>),31),1,Some{Layout.initialize(component_layout(),first_route(),P.Position{ALeaf{101},10})})),16,Some{Layout.initialize(component_layout(),first_route(),P.Position{ALeaf{116},20})}))},Layout.ColumnSlot{inserted(~S,~Layout.Viewed<P.Label,String>,Col.swap(~S,~Layout.Viewed<P.Label,String>,Col.ensure(~S,~Layout.Viewed<P.Label,String>,Col.empty(~S,~Layout.Viewed<P.Label,String>),31),2,Some{Layout.initialize(component_layout(),Layout.InRight{Layout.AtLeaf{}},P.Label{ALeaf{202},"sentinel"})}))}}
def resources(~S:Data) -> Resources(~S):Product.Owner{Layout.ResourceSlot{Layout.initialize(resource_layout(),first_route(),P.Counter{ALeaf{301},0})},Layout.ResourceSlot{Layout.initialize(resource_layout(),Layout.InRight{Layout.AtLeaf{}},P.Secret{ALeaf{401}})}}
