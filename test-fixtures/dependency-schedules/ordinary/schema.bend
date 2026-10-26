import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/ordinary-schema.bend as Schema
import ../../../src/ecs/execution-access.bend as Access
import ../../../src/ecs/execution-declaration.bend as D
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-composer-layout.bend as Layout

type Alpha is Data:Alpha{}
type Beta is Data:Beta{}
type Counter is Type:Counter{token:Array<U32>,value:U32}
type Sentinel is Type:Sentinel{token:Array<U32>,text:String}
type Local is Type:Local{token:Array<U32>,runs:U32}
type Handler is Type:Handler{token:Array<U32>,errors:List<&2,String>}
def view(owner:Counter) -> Counter & U32:
  match owner:
    case Counter{token,+value}:(Counter{token,value},value)
def increment(owner:Counter) -> Counter & U32:
  match owner:
    case Counter{token,value}:view(Counter{token,U32.add(value,1)})
def sentinel_view(owner:Sentinel) -> Sentinel & String:
  match owner:
    case Sentinel{token,+text}:(Sentinel{token,text},text)
def resource_layout() -> Layout.Layout:Layout.LayoutPair{Layout.LayoutLeaf{Counter,U32,view,"counter"},Layout.LayoutLeaf{Sentinel,String,sentinel_view,"sentinel"}}
def first_route() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def Resources(~S:Data) -> Type:Layout.resources(~S,resource_layout())
def World(~S:Data) -> Type:W.World<S,Unit,Resources(~S),Unit>
def Write() -> Type -> Type:Access.ResourceWrites(~Counter,~U32)
def Read() -> Type -> Type:Access.ResourceReads(~U32)
def write_selection(~S:Data,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~Unit,~Resources(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~Unit,~Resources(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~Unit,~Resources(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~Unit,~Resources(~S),~H,~B),~query:Build.Query(~S,~Unit,~Resources(~S),~H,~B),book:B) -> B & Write()(H):
  resource_write(resource_layout(),first_route(),{==},{==},book)
def write(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Unit,~Resources(~S),~H,~B),book:B) -> B & Write()(H):
  builder(Write(),write_selection(~S,~H,~B),book)
def read_selection(~S:Data,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~Unit,~Resources(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~Unit,~Resources(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~Unit,~Resources(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~Unit,~Resources(~S),~H,~B),~query:Build.Query(~S,~Unit,~Resources(~S),~H,~B),book:B) -> B & Read()(H):
  resource_read(resource_layout(),first_route(),{==},{==},book)
def read(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Unit,~Resources(~S),~H,~B),book:B) -> B & Read()(H):
  builder(Read(),read_selection(~S,~H,~B),book)
def resources(~S:Data) -> Resources(~S):Product.Owner{Layout.ResourceSlot{Layout.initialize(resource_layout(),first_route(),Counter{ALeaf{301},0})},Layout.ResourceSlot{Layout.initialize(resource_layout(),Layout.InRight{Layout.AtLeaf{}},Sentinel{ALeaf{401},"retained"})}}
def empty(_:Unit) -> Unit:Unit{}
def available(key:String) -> Bool:String.eq(key,"resource/counter")
