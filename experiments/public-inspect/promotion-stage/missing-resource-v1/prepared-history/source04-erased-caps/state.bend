import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/optional-resource-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
type Workshop is Data: Workshop{}
type Garden is Data: Garden{}
def payload(~S:Data) -> Schema.Resource<S,Array<U32>>:
  Schema.resource(~S,~Array<U32>,"Payload")
def counter(~S:Data) -> Schema.Resource<S,Array<U32>>:
  Schema.resource(~S,~Array<U32>,"CallbackCounter")
def sibling(~S:Data) -> Schema.Resource<S,Array<U32>>:
  Schema.resource(~S,~Array<U32>,"Sibling")
def owners(~S:Data) -> Schema.Resource<S,Array<U32>>:
  Schema.resource(~S,~Array<U32>,"Owners")
def Slot(~S:Data) -> Type:
  O.Slot<S,Array<U32>,payload(~S)>
def Tail() -> Type:
  Product.Owner<Array<U32>,Product.Owner<Array<U32>,Array<U32>>>
def Resource(~S:Data) -> Type:
  Product.Owner<Slot(~S),Tail()>
def IndexTail(~S:Data) -> Data:
  Tree.Branch<Tree.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>,Tree.Built<S,Product.Owner<Array<U32>,Array<U32>>,Tree.Branch<Tree.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>,Tree.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>>>>
def Index(~S:Data) -> Data:
  Tree.Branch<Tree.Built<S,Slot(~S),B.Index<S,Array<U32>,payload(~S)>>,Tree.Built<S,Tail(),IndexTail(~S)>>
def tree(~S:Data) -> Tree.Built<S,Resource(~S),Index(~S)>:
  Tree.joined(~S,~Slot(~S),~Tail(),~B.Index<S,Array<U32>,payload(~S)>,~IndexTail(~S),B.leaf(~S,~Array<U32>,payload(~S)),Tree.joined(~S,~Array<U32>,~Product.Owner<Array<U32>,Array<U32>>,~Schema.Resource<S,Array<U32>>,~Tree.Branch<Tree.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>,Tree.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>>,Tree.leaf(~S,~Array<U32>,counter(~S)),Tree.joined(~S,~Array<U32>,~Array<U32>,~Schema.Resource<S,Array<U32>>,~Schema.Resource<S,Array<U32>>,Tree.leaf(~S,~Array<U32>,sibling(~S)),Tree.leaf(~S,~Array<U32>,owners(~S)))))
def slot_lens(~S:Data) -> Product.Lens<Resource(~S),Slot(~S),Unit & Tail()>:
  Tree.left_lens(~Resource(~S),~Slot(~S),~Tail(),~Unit,~Tree.whole(~Resource(~S)))
def slot_binding(~S:Data) -> B.Binding<S,Resource(~S),Array<U32>,Unit & Tail(),payload(~S),slot_lens(~S)>:
  B.bind(~S,~Resource(~S),~Array<U32>,~(Unit & Tail()),~payload(~S),~slot_lens(~S),~Tree.left(~S,~Resource(~S),~Slot(~S),~Tail(),~Unit,~B.Index<S,Array<U32>,payload(~S)>,~IndexTail(~S),~Tree.whole(~Resource(~S)),Tree.root(~S,~Resource(~S),~Index(~S),tree(~S))))
def counter_lens(~S:Data) -> Product.Lens<Resource(~S),Array<U32>,(Unit & Slot(~S)) & Product.Owner<Array<U32>,Array<U32>>>:
  Tree.left_lens(~Resource(~S),~Array<U32>,~Product.Owner<Array<U32>,Array<U32>>,~(Unit & Slot(~S)),~Tree.right_lens(~Resource(~S),~Slot(~S),~Tail(),~Unit,~Tree.whole(~Resource(~S))))
def counter_binding(~S:Data) -> Tree.Binding<S,Resource(~S),Array<U32>,(Unit & Slot(~S)) & Product.Owner<Array<U32>,Array<U32>>,counter_lens(~S),counter(~S)>:
  Tree.bind(~S,~Resource(~S),~Array<U32>,~((Unit & Slot(~S)) & Product.Owner<Array<U32>,Array<U32>>),~counter_lens(~S),~Tree.left(~S,~Resource(~S),~Array<U32>,~Product.Owner<Array<U32>,Array<U32>>,~(Unit & Slot(~S)),~Schema.Resource<S,Array<U32>>,~Tree.Branch<Tree.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>,Tree.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>>,~Tree.right_lens(~Resource(~S),~Slot(~S),~Tail(),~Unit,~Tree.whole(~Resource(~S))),Tree.right(~S,~Resource(~S),~Slot(~S),~Tail(),~Unit,~B.Index<S,Array<U32>,payload(~S)>,~IndexTail(~S),~Tree.whole(~Resource(~S)),Tree.root(~S,~Resource(~S),~Index(~S),tree(~S)))))
def pair(+first:U32,+second:U32) -> Array<U32>:
  ANode{ALeaf{first},ALeaf{second}}
def array_returned(result:Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  match result:
    case (array,value):(array,[value])
def array_second(first:U32,result:Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  match result:
    case (array,second):(array,[first,second])
def array_first(result:Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  match result:
    case (array,first):array_second(first,Array.get(U32,array,1))
def view(array:Array<U32>) -> Array<U32> & List<&2,U32>:
  array_first(Array.get(U32,array,0))
def count(array:Array<U32>) -> Array<U32> & U32:
  Array.get(U32,array,0)
def render(value:Maybe<&2,List<&2,U32>>) -> String:
  match value:
    case None{}:"Unavailable"
    case Some{value}:List.show(&2,U32,U32.show,value)
def LeftOps(~S:Data,H:Type) -> Type:
  D.Ops(~S,~Array<U32>,~payload(~S),~List<&2,U32>,H)
def RightOps(~S:Data,H:Type) -> Type:
  Field.Write<S,Array<U32>,counter(~S),H,U32>
def Ops(~S:Data) -> Type -> Type:
  D.PairOps(~D.Ops(~S,~Array<U32>,~payload(~S),~List<&2,U32>),~RightOps(~S))
def optional_declaration(~S:Data) -> D.Declaration<S,Array<U32>,Resource(~S),U32,Ops(~S),Maybe<&2,List<&2,U32>>>:
  D.with(~S,~Array<U32>,~Resource(~S),~U32,~D.Ops(~S,~Array<U32>,~payload(~S),~List<&2,U32>),~RightOps(~S),~Maybe<&2,List<&2,U32>>,D.optional(~S,~Array<U32>,~Resource(~S),~U32,~Array<U32>,~(Unit & Tail()),~List<&2,U32>,~payload(~S),~slot_lens(~S),~slot_binding(~S),~view,render),Field.write(~S,~Array<U32>,~Resource(~S),~U32,~Array<U32>,~((Unit & Slot(~S)) & Product.Owner<Array<U32>,Array<U32>>),~U32,~counter_lens(~S),~counter(~S),~counter_binding(~S),~count))
def required_declaration(~S:Data) -> D.Declaration<S,Array<U32>,Resource(~S),U32,Ops(~S),Maybe<&2,List<&2,U32>>>:
  D.with(~S,~Array<U32>,~Resource(~S),~U32,~D.Ops(~S,~Array<U32>,~payload(~S),~List<&2,U32>),~RightOps(~S),~Maybe<&2,List<&2,U32>>,D.required(~S,~Array<U32>,~Resource(~S),~U32,~Array<U32>,~(Unit & Tail()),~List<&2,U32>,~payload(~S),~slot_lens(~S),~slot_binding(~S),~view,render),Field.write(~S,~Array<U32>,~Resource(~S),~U32,~Array<U32>,~((Unit & Slot(~S)) & Product.Owner<Array<U32>,Array<U32>>),~U32,~counter_lens(~S),~counter(~S),~counter_binding(~S),~count))
def counted(~S:Data,~H:Type,~write:RightOps(~S,H),value:Maybe<&2,List<&2,U32>>,result:H & U32) -> H & (T.Outcome<K.Error> & Maybe<&2,List<&2,U32>>):
  match result:
    case (owner,n):(Field.set(~S,~Array<U32>,~counter(~S),~H,~U32,~write,owner,ALeaf{(n + 1 : U32)}),(T.Success{},value))
def read(~S:Data,~H:Type,~write:RightOps(~S,H),result:H & Maybe<&2,List<&2,U32>>) -> H & (T.Outcome<K.Error> & Maybe<&2,List<&2,U32>>):
  match result:
    case (owner,value):counted(~S,~H,~write,value,Field.get(~S,~Array<U32>,~counter(~S),~H,~U32,~write,owner))
def body(~S:Data,~H:Type,~caps:Ops(~S)(H),args:Unit,owner:H) -> H & (T.Outcome<K.Error> & Maybe<&2,List<&2,U32>>):
  match caps:
    case Cap.Bundle{left,right}:read(~S,~H,~right,Field.read_value(~S,~Array<U32>,~payload(~S),~H,~Maybe<&2,List<&2,U32>>,~left,owner))
def resource(~S:Data,present:Bool) -> Resource(~S):
  match present:
    case False{}:Product.Owner{O.Missing{},Product.Owner{ALeaf{0},Product.Owner{pair(27,28),pair(901,902)}}}
    case True{}:Product.Owner{O.Present{pair(17,18)},Product.Owner{ALeaf{0},Product.Owner{pair(27,28),pair(901,902)}}}
def store(unit:Unit) -> Array<U32>:
  pair(31,32)
def pending(~S:Data,world:W.World<S,Array<U32>,Resource(~S),U32>) -> W.World<S,Array<U32>,Resource(~S),U32>:
  match world:
    case W.World{namespace,next,high,live,capacity,depth,store,resource,events,pending,registrations,nextSystem,clock}:W.World{namespace,next,high,live,capacity,depth,store,resource,events,pending,registrations,nextSystem,(clock + 100 : U32)}
