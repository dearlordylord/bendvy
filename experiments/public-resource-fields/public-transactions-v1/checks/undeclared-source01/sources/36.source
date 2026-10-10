import Base
import ../../../../src/ecs/resource-field-binding.bend as B
import ../../../../src/ecs/ordinary-resource-field-system.bend as P
import operations.bend as O
import owner-observer.bend as Dump
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as T
type Other is Data:
  Other{}
type Sentinel is Type:
  Sentinel{values:Array<U32>,flags:Array<Bool>}
def Tail() -> Type:
  Product.Owner<O.Counter,Sentinel>
def Resources() -> Type:
  Product.Owner<O.Counter,Tail()>
def first() -> Schema.Resource<Other,O.Counter>:
  Schema.resource(~Other,~O.Counter,"Primary")
def second() -> Schema.Resource<Other,O.Counter>:
  Schema.resource(~Other,~O.Counter,"Secondary")
def Leaf() -> Data:
  B.Built<Other,O.Counter,Schema.Resource<Other,O.Counter>>
def sentinel() -> Schema.Resource<Other,Sentinel>:
  Schema.resource(~Other,~Sentinel,"Untouched")
def TailIndex() -> Data:
  B.Branch<Leaf(),B.Built<Other,Sentinel,Schema.Resource<Other,Sentinel>>>
def Index() -> Data:
  B.Branch<Leaf(),B.Built<Other,Tail(),TailIndex()>>
def tail_layout() -> B.Built<Other,Tail(),TailIndex()>:
  B.joined(~Other,~O.Counter,~Sentinel,~Schema.Resource<Other,O.Counter>,~Schema.Resource<Other,Sentinel>,B.leaf(~Other,~O.Counter,second()),B.leaf(~Other,~Sentinel,sentinel()))
def layout() -> B.Built<Other,Resources(),Index()>:
  B.joined(~Other,~O.Counter,~Tail(),~Schema.Resource<Other,O.Counter>,~TailIndex(),B.leaf(~Other,~O.Counter,first()),tail_layout())
def first_lens() -> Product.Lens<Resources(),O.Counter,Unit & Tail()>:
  B.left_lens(~Resources(),~O.Counter,~Tail(),~Unit,~B.whole(~Resources()))
def tail_lens() -> Product.Lens<Resources(),Tail(),Unit & O.Counter>:
  B.right_lens(~Resources(),~O.Counter,~Tail(),~Unit,~B.whole(~Resources()))
def second_lens() -> Product.Lens<Resources(),O.Counter,(Unit & O.Counter) & Sentinel>:
  B.left_lens(~Resources(),~O.Counter,~Sentinel,~Unit & O.Counter,~tail_lens())
def first_cursor() -> B.Cursor<Other,Resources(),O.Counter,Unit & Tail(),Schema.Resource<Other,O.Counter>,first_lens()>:
  B.left(~Other,~Resources(),~O.Counter,~Tail(),~Unit,~Schema.Resource<Other,O.Counter>,~TailIndex(),~B.whole(~Resources()),B.root(~Other,~Resources(),~Index(),layout()))
def tail_cursor() -> B.Cursor<Other,Resources(),Tail(),Unit & O.Counter,TailIndex(),tail_lens()>:
  B.right(~Other,~Resources(),~O.Counter,~Tail(),~Unit,~Schema.Resource<Other,O.Counter>,~TailIndex(),~B.whole(~Resources()),B.root(~Other,~Resources(),~Index(),layout()))
def second_cursor() -> B.Cursor<Other,Resources(),O.Counter,(Unit & O.Counter) & Sentinel,Schema.Resource<Other,O.Counter>,second_lens()>:
  B.left(~Other,~Resources(),~O.Counter,~Sentinel,~Unit & O.Counter,~Schema.Resource<Other,O.Counter>,~Schema.Resource<Other,Sentinel>,~tail_lens(),tail_cursor())
def first_binding() -> B.Binding<Other,Resources(),O.Counter,Unit & Tail(),first_lens(),first()>:
  B.bind(~Other,~Resources(),~O.Counter,~Unit & Tail(),~first_lens(),~first_cursor())
def second_binding() -> B.Binding<Other,Resources(),O.Counter,(Unit & O.Counter) & Sentinel,second_lens(),second()>:
  B.bind(~Other,~Resources(),~O.Counter,~(Unit & O.Counter) & Sentinel,~second_lens(),~second_cursor())
def Ops(H:Type) -> Type:
  O.Ops(~Other,~first(),~second(),H)
def declaration() -> P.Declaration<Other,T.Tx<W.World<Other,Col.Column<Other,Unit>,Resources(),U32>,U32>,Ops(T.Tx<W.World<Other,Col.Column<Other,Unit>,Resources(),U32>,U32>)>:
  P.pair(~Other,~T.Tx<W.World<Other,Col.Column<Other,Unit>,Resources(),U32>,U32>,~P.Write<Other,O.Counter,first(),T.Tx<W.World<Other,Col.Column<Other,Unit>,Resources(),U32>,U32>,U32>,~P.Write<Other,O.Counter,second(),T.Tx<W.World<Other,Col.Column<Other,Unit>,Resources(),U32>,U32>,U32>,P.write(~Other,~Col.Column<Other,Unit>,~Resources(),~U32,~O.Counter,~Unit & Tail(),~U32,~first_lens(),~first(),~first_binding(),~O.view),P.write(~Other,~Col.Column<Other,Unit>,~Resources(),~U32,~O.Counter,~(Unit & O.Counter) & Sentinel,~U32,~second_lens(),~second(),~second_binding(),~O.view))
def body(~H:Type,~caps:Ops(H),fail:Bool,owner:H) -> H & (T.Outcome<O.Error> & O.Output):
  O.body(~Other,~first(),~second(),~H,~caps,fail,owner)
def initial() -> Resources():
  Product.Owner{O.counter(30,31,32,33),Product.Owner{O.counter(300,301,302,303),Sentinel{ANode{ALeaf{700},ALeaf{701}},ANode{ALeaf{True{}},ALeaf{False{}}}}}}
def counter_viewed(result:Array<U32> & String) -> O.Counter & String:
  match result:
    case (values,text):(O.Counter{values},text)
def counter_view(value:O.Counter) -> O.Counter & String:
  match value:
    case O.Counter{values}:counter_viewed(Dump.u32_array(values))
def sentinel_join(a:Array<U32> & String,b:Array<Bool> & String) -> Sentinel & String:
  (values,vs)=a
  (flags,fs)=b
  (Sentinel{values,flags},"values=" ++ vs ++ ";flags=" ++ fs)
def sentinel_view(value:Sentinel) -> Sentinel & String:
  match value:
    case Sentinel{values,flags}:sentinel_join(Dump.u32_array(values),Dump.bool_array(flags))
def tail_view_join(a:O.Counter & String,b:Sentinel & String) -> Tail() & String:
  (left,lt)=a
  (right,rt)=b
  (Product.Owner{left,right},"Secondary=" ++ lt ++ ";Untouched{" ++ rt ++ "}")
def tail_view(value:Tail()) -> Tail() & String:
  match value:
    case Product.Owner{left,right}:tail_view_join(counter_view(left),sentinel_view(right))
def resource_view_join(a:O.Counter & String,b:Tail() & String) -> Resources() & String:
  (left,lt)=a
  (right,rt)=b
  (Product.Owner{left,right},"Primary=" ++ lt ++ ";" ++ rt)
def resource_view(value:Resources()) -> Resources() & String:
  match value:
    case Product.Owner{left,right}:resource_view_join(counter_view(left),tail_view(right))
def ReadOps(H:Type) -> Type:
  O.ReadOps(~Other,~first(),~second(),H)
def read_declaration() -> P.Declaration<Other,T.Tx<W.World<Other,Col.Column<Other,Unit>,Resources(),U32>,U32>,ReadOps(T.Tx<W.World<Other,Col.Column<Other,Unit>,Resources(),U32>,U32>)>:
  P.pair(~Other,~T.Tx<W.World<Other,Col.Column<Other,Unit>,Resources(),U32>,U32>,~P.Read<Other,O.Counter,first(),T.Tx<W.World<Other,Col.Column<Other,Unit>,Resources(),U32>,U32>,U32>,~P.Read<Other,O.Counter,second(),T.Tx<W.World<Other,Col.Column<Other,Unit>,Resources(),U32>,U32>,U32>,P.read(~Other,~Col.Column<Other,Unit>,~Resources(),~U32,~O.Counter,~Unit & Tail(),~U32,~first_lens(),~first(),~first_binding(),~O.view),P.read(~Other,~Col.Column<Other,Unit>,~Resources(),~U32,~O.Counter,~(Unit & O.Counter) & Sentinel,~U32,~second_lens(),~second(),~second_binding(),~O.view))
def read_body(~H:Type,~caps:ReadOps(H),fail:Bool,owner:H) -> H & (T.Outcome<O.Error> & O.Output):
  O.read_body(~Other,~first(),~second(),~H,~caps,fail,owner)
