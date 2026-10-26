import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/ordinary-schema.bend as Schema
import ../../../src/ecs/execution-access.bend as Access
import ../../../src/ecs/execution-projection.bend as Projection
import ../../../src/ecs/execution-declaration.bend as D
import ../../../src/ecs/execution-builder.bend as Build

type Alpha is Data:Alpha{}
type Beta is Data:Beta{}
type Counter is Type:Counter{token:Array<U32>,value:U32}
type Sentinel is Type:Sentinel{token:Array<U32>,text:String}
type Local is Type:Local{token:Array<U32>,runs:U32}
type Handler is Type:Handler{token:Array<U32>,errors:List<&2,String>}
def Resources() -> Type:Product.Owner<Counter,Sentinel>
def World(~S:Data) -> Type:W.World<S,Unit,Resources(),Unit>
def CounterLens() -> Product.Lens<Resources(),Counter,Sentinel>:
  Product.lens(~Counter,~Sentinel,~Product.Left{})
def view(owner:Counter) -> Counter & U32:
  match owner:
    case Counter{token,+value}:(Counter{token,value},value)
def increment(owner:Counter) -> Counter & U32:
  match owner:
    case Counter{token,value}:view(Counter{token,U32.add(value,1)})
def Write() -> Type -> Type:Access.ResourceWrites(~Counter,~U32)
def Read() -> Type -> Type:Access.ResourceReads(~U32)
def write_selection(~S:Data,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~Unit,~Resources(),~H,~B),~component_write:Build.ComponentWrite(~S,~Unit,~Resources(),~H,~B),~resource_read:Build.ResourceRead(~S,~Unit,~Resources(),~H,~B),~resource_write:Build.ResourceWrite(~S,~Unit,~Resources(),~H,~B),book:B) -> B & Write()(H):
  resource_write(Counter,Sentinel,U32,CounterLens(),view,Projection.trusted_affine(~Counter,~U32,~view),Schema.resource(~S,~Counter,"counter"),book)
def write(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Unit,~Resources(),~H,~B),book:B) -> B & Write()(H):
  builder(Write(),write_selection(~S,~H,~B),book)
def read_selection(~S:Data,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~Unit,~Resources(),~H,~B),~component_write:Build.ComponentWrite(~S,~Unit,~Resources(),~H,~B),~resource_read:Build.ResourceRead(~S,~Unit,~Resources(),~H,~B),~resource_write:Build.ResourceWrite(~S,~Unit,~Resources(),~H,~B),book:B) -> B & Read()(H):
  resource_read(Counter,Sentinel,U32,CounterLens(),view,Projection.trusted_affine(~Counter,~U32,~view),Schema.resource(~S,~Counter,"counter"),book)
def read(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Unit,~Resources(),~H,~B),book:B) -> B & Read()(H):
  builder(Read(),read_selection(~S,~H,~B),book)
def resources() -> Resources():Product.Owner{Counter{ALeaf{301},0},Sentinel{ALeaf{401},"retained"}}
def empty(_:Unit) -> Unit:Unit{}
def available(key:String) -> Bool:String.eq(key,"resource/counter")
