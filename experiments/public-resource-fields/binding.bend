import Base
import ../../src/ecs/ordinary-schema.bend as Schema
import ../../src/ecs/schema-fragments.bend as Fragment
import ../../src/ecs/owner-product.bend as Product
# Ordinary declaration tree. Physical ownership and index shape are both typed.
type Branch<-L:Data,-R:Data> is Data:
  Branch{left:L,right:R}
type Built<-S:Data,-R:Type,-Index:Data> is Data:
  Built{entries:List<&2,Fragment.Entry<S>>,index:Index}
def leaf(~S:Data,~P:Type,+identity:Schema.Resource<S,P>) -> Built<S,P,Schema.Resource<S,P>>:
  Built{Schema.entries(~S,~Unit,~P,Schema.resource_schema(~S,~P,identity)),identity}
def joined(~S:Data,~L:Type,~R:Type,~LI:Data,~RI:Data,left:Built<S,L,LI>,right:Built<S,R,RI>) -> Built<S,Product.Owner<L,R>,Branch<Built<S,L,LI>,Built<S,R,RI>>>:
  match left right:
    case Built{+le,+li} Built{+re,+ri}:Built{List.append(&2,Fragment.Entry<S>,le,re),Branch{Built{le,li},Built{re,ri}}}
def entries(~S:Data,~R:Type,~I:Data,value:Built<S,R,I>) -> List<&2,Fragment.Entry<S>>:
  match value:
    case Built{entries,_}:entries
def validate(~S:Data,~R:Type,~I:Data,value:Built<S,R,I>) -> Fragment.Validation:
  Fragment.validate(~S,entries(~S,~R,~I,value))
def whole_take(~P:Type,value:P) -> Unit & P:
  (Unit{},value)
def whole_put(~P:Type,rest:Unit,value:P) -> P:
  value
def whole(~P:Type) -> Product.Lens<P,P,Unit>:
  Product.Lens{whole_take(~P),whole_put(~P)}
# Erased canonical lens; no closure/payload is retained in the runtime cursor.
type Cursor<-S:Data,-W:Type,-P:Type,-Rest:Type,-I:Data,-lens:Product.Lens<W,P,Rest>> is Data:
  Cursor{index:I}
def root(~S:Data,~R:Type,~I:Data,value:Built<S,R,I>) -> Cursor<S,R,R,Unit,I,whole(~R)>:
  match value:
    case Built{_,index}:Cursor{index}
def left_lens(~W:Type,~L:Type,~R:Type,~Rest:Type,~outer:Product.Lens<W,Product.Owner<L,R>,Rest>) -> Product.Lens<W,L,Rest & R>:
  Product.compose(~W,~Product.Owner<L,R>,~Rest,~L,~R,~outer,~Product.lens(~L,~R,~Product.Left{}))
def right_lens(~W:Type,~L:Type,~R:Type,~Rest:Type,~outer:Product.Lens<W,Product.Owner<L,R>,Rest>) -> Product.Lens<W,R,Rest & L>:
  Product.compose(~W,~Product.Owner<L,R>,~Rest,~R,~L,~outer,~Product.lens(~L,~R,~Product.Right{}))
def left(~S:Data,~W:Type,~L:Type,~R:Type,~Rest:Type,~LI:Data,~RI:Data,~outer:Product.Lens<W,Product.Owner<L,R>,Rest>,value:Cursor<S,W,Product.Owner<L,R>,Rest,Branch<Built<S,L,LI>,Built<S,R,RI>>,outer>) -> Cursor<S,W,L,Rest & R,LI,left_lens(~W,~L,~R,~Rest,~outer)>:
  match value:
    case Cursor{Branch{Built{_,index},_}}:Cursor{index}
def right(~S:Data,~W:Type,~L:Type,~R:Type,~Rest:Type,~LI:Data,~RI:Data,~outer:Product.Lens<W,Product.Owner<L,R>,Rest>,value:Cursor<S,W,Product.Owner<L,R>,Rest,Branch<Built<S,L,LI>,Built<S,R,RI>>,outer>) -> Cursor<S,W,R,Rest & L,RI,right_lens(~W,~L,~R,~Rest,~outer)>:
  match value:
    case Cursor{Branch{_,Built{_,index}}}:Cursor{index}
def identity(~S:Data,~W:Type,~P:Type,~Rest:Type,~lens:Product.Lens<W,P,Rest>,value:Cursor<S,W,P,Rest,Schema.Resource<S,P>,lens>) -> Schema.Resource<S,P>:
  match value:
    case Cursor{identity}:identity
# Identity and canonical physical path are compile-time indices of the binding.
# Raw constructors remain trusted; application systems receive opaque grants.
type Binding<-S:Data,-W:Type,-P:Type,-Rest:Type,-lens:Product.Lens<W,P,Rest>,-identity:Schema.Resource<S,P>> is Data:
  Binding{}
def bind(~S:Data,~W:Type,~P:Type,~Rest:Type,~lens:Product.Lens<W,P,Rest>,~cursor:Cursor<S,W,P,Rest,Schema.Resource<S,P>,lens>) -> Binding<S,W,P,Rest,lens,identity(~S,~W,~P,~Rest,~lens,cursor)>:
  Binding{}
