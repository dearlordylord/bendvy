import Base
import ../../../../../src/ecs/resource-field-binding.bend as B
import provider.bend as P
import operations.bend as O
import ../../normal/owner-observer.bend as Dump
import ../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../src/ecs/owner-product.bend as Product
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/transaction.bend as T
type A is Data:
  A{}
def Resources() -> Type:
  Product.Owner<O.Counter,O.Counter>
def first() -> Schema.Resource<A,O.Counter>:
  Schema.resource(~A,~O.Counter,"First")
def second() -> Schema.Resource<A,O.Counter>:
  Schema.resource(~A,~O.Counter,"Second")
def Leaf() -> Data:
  B.Built<A,O.Counter,Schema.Resource<A,O.Counter>>
def Index() -> Data:
  B.Branch<Leaf(),Leaf()>
def layout() -> B.Built<A,Resources(),Index()>:
  B.joined(~A,~O.Counter,~O.Counter,~Schema.Resource<A,O.Counter>,~Schema.Resource<A,O.Counter>,B.leaf(~A,~O.Counter,first()),B.leaf(~A,~O.Counter,second()))
def first_lens() -> Product.Lens<Resources(),O.Counter,Unit & O.Counter>:
  B.left_lens(~Resources(),~O.Counter,~O.Counter,~Unit,~B.whole(~Resources()))
def second_lens() -> Product.Lens<Resources(),O.Counter,Unit & O.Counter>:
  B.right_lens(~Resources(),~O.Counter,~O.Counter,~Unit,~B.whole(~Resources()))
def first_cursor() -> B.Cursor<A,Resources(),O.Counter,Unit & O.Counter,Schema.Resource<A,O.Counter>,first_lens()>:
  B.left(~A,~Resources(),~O.Counter,~O.Counter,~Unit,~Schema.Resource<A,O.Counter>,~Schema.Resource<A,O.Counter>,~B.whole(~Resources()),B.root(~A,~Resources(),~Index(),layout()))
def second_cursor() -> B.Cursor<A,Resources(),O.Counter,Unit & O.Counter,Schema.Resource<A,O.Counter>,second_lens()>:
  B.right(~A,~Resources(),~O.Counter,~O.Counter,~Unit,~Schema.Resource<A,O.Counter>,~Schema.Resource<A,O.Counter>,~B.whole(~Resources()),B.root(~A,~Resources(),~Index(),layout()))
def first_binding() -> B.Binding<A,Resources(),O.Counter,Unit & O.Counter,first_lens(),first()>:
  B.bind(~A,~Resources(),~O.Counter,~Unit & O.Counter,~first_lens(),~first_cursor())
def second_binding() -> B.Binding<A,Resources(),O.Counter,Unit & O.Counter,second_lens(),second()>:
  B.bind(~A,~Resources(),~O.Counter,~Unit & O.Counter,~second_lens(),~second_cursor())
def Ops(H:Type) -> Type:
  O.Ops(~A,~first(),~second(),H)
def declaration() -> P.Declaration<A,T.Tx<W.World<A,Col.Column<A,Unit>,Resources(),U32>,U32>,Ops(T.Tx<W.World<A,Col.Column<A,Unit>,Resources(),U32>,U32>)>:
  P.pair(~A,~T.Tx<W.World<A,Col.Column<A,Unit>,Resources(),U32>,U32>,~P.Write<A,O.Counter,first(),T.Tx<W.World<A,Col.Column<A,Unit>,Resources(),U32>,U32>,U32>,~P.Write<A,O.Counter,second(),T.Tx<W.World<A,Col.Column<A,Unit>,Resources(),U32>,U32>,U32>,P.write(~A,~Col.Column<A,Unit>,~Resources(),~U32,~O.Counter,~Unit & O.Counter,~U32,~first_lens(),~first(),~first_binding(),~O.view),P.write(~A,~Col.Column<A,Unit>,~Resources(),~U32,~O.Counter,~Unit & O.Counter,~U32,~second_lens(),~second(),~second_binding(),~O.view))
def body(~H:Type,~caps:Ops(H),fail:Bool,owner:H) -> H & (T.Outcome<O.Error> & O.Output):
  O.body(~A,~first(),~second(),~H,~caps,fail,owner)
def initial() -> Resources():
  Product.Owner{O.counter(10,11,12,13),O.counter(100,101,102,103)}
def counter_viewed(result:Array<U32> & String) -> O.Counter & String:
  match result:
    case (values,text):(O.Counter{values},text)
def counter_view(value:O.Counter) -> O.Counter & String:
  match value:
    case O.Counter{values}:counter_viewed(Dump.u32_array(values))
def resource_view_join(a:O.Counter & String,b:O.Counter & String) -> Resources() & String:
  (left,lt)=a
  (right,rt)=b
  (Product.Owner{left,right},"First=" ++ lt ++ ";Second=" ++ rt)
def resource_view(value:Resources()) -> Resources() & String:
  match value:
    case Product.Owner{left,right}:resource_view_join(counter_view(left),counter_view(right))
def ReadOps(H:Type) -> Type:
  O.ReadOps(~A,~first(),~second(),H)
def read_declaration() -> P.Declaration<A,T.Tx<W.World<A,Col.Column<A,Unit>,Resources(),U32>,U32>,ReadOps(T.Tx<W.World<A,Col.Column<A,Unit>,Resources(),U32>,U32>)>:
  P.pair(~A,~T.Tx<W.World<A,Col.Column<A,Unit>,Resources(),U32>,U32>,~P.Read<A,O.Counter,first(),T.Tx<W.World<A,Col.Column<A,Unit>,Resources(),U32>,U32>,U32>,~P.Read<A,O.Counter,second(),T.Tx<W.World<A,Col.Column<A,Unit>,Resources(),U32>,U32>,U32>,P.read(~A,~Col.Column<A,Unit>,~Resources(),~U32,~O.Counter,~Unit & O.Counter,~U32,~first_lens(),~first(),~first_binding(),~O.view),P.read(~A,~Col.Column<A,Unit>,~Resources(),~U32,~O.Counter,~Unit & O.Counter,~U32,~second_lens(),~second(),~second_binding(),~O.view))
def read_body(~H:Type,~caps:ReadOps(H),fail:Bool,owner:H) -> H & (T.Outcome<O.Error> & O.Output):
  O.read_body(~A,~first(),~second(),~H,~caps,fail,owner)
