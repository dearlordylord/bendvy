import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recoverable-array-resource.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-array.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import ./ordinary-recovery-resource-field.bend as Resource

def Siblings() -> Type:Product.Owner<Array<Array<U32>>,Array<U32>>
def Resources() -> Type:Product.Owner<Array<Array<U32>>,Siblings()>
def World(~S:Data) -> Type:W.World<S,Unit,Resources(),Unit>
def State(~S:Data) -> Type:Product.Owner<World(~S),Array<U32>>
def identity(~S:Data) -> Schema.Resource<S,Array<Array<U32>>>:Schema.resource(~S,~Array<Array<U32>>,"Target")
def sibling_identity(~S:Data) -> Schema.Resource<S,Array<Array<U32>>>:Schema.resource(~S,~Array<Array<U32>>,"SamePayloadSibling")
def other_identity(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"OtherAffine")
def LeafIndex(~S:Data) -> Data:Binding.Built<S,Array<Array<U32>>,Schema.Resource<S,Array<Array<U32>>>>
def OtherIndex(~S:Data) -> Data:Binding.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>
def SiblingIndex(~S:Data) -> Data:Binding.Branch<LeafIndex(~S),OtherIndex(~S)>
def Index(~S:Data) -> Data:Binding.Branch<LeafIndex(~S),Binding.Built<S,Siblings(),SiblingIndex(~S)>>
def schema(~S:Data) -> Binding.Built<S,Resources(),Index(~S)>:
  Binding.joined(~S,~Array<Array<U32>>,~Siblings(),~Schema.Resource<S,Array<Array<U32>>>,~SiblingIndex(~S),Binding.leaf(~S,~Array<Array<U32>>,identity(~S)),Binding.joined(~S,~Array<Array<U32>>,~Array<U32>,~Schema.Resource<S,Array<Array<U32>>>,~Schema.Resource<S,Array<U32>>,Binding.leaf(~S,~Array<Array<U32>>,sibling_identity(~S)),Binding.leaf(~S,~Array<U32>,other_identity(~S))))
def lens() -> Product.Lens<Resources(),Array<Array<U32>>,Unit & Siblings()>:
  Binding.left_lens(~Resources(),~Array<Array<U32>>,~Siblings(),~Unit,~Binding.whole(~Resources()))
def cursor(~S:Data) -> Binding.Cursor<S,Resources(),Array<Array<U32>>,Unit & Siblings(),Schema.Resource<S,Array<Array<U32>>>,lens()>:
  Binding.left(~S,~Resources(),~Array<Array<U32>>,~Siblings(),~Unit,~Schema.Resource<S,Array<Array<U32>>>,~SiblingIndex(~S),~Binding.whole(~Resources()),Binding.root(~S,~Resources(),~Index(~S),schema(~S)))
def binding(~S:Data) -> Binding.Binding<S,Resources(),Array<Array<U32>>,Unit & Siblings(),lens(),identity(~S)>:
  Binding.bind(~S,~Resources(),~Array<Array<U32>>,~(Unit & Siblings()),~lens(),~cursor(~S))
def Ops(~S:Data) -> Type -> Type:Resource.Ops(~S,~Array<U32>,~identity(~S))
def Recovery() -> Type:List<A.Record<Array<U32>>>
def declaration(~S:Data) -> D.Declaration<S,State(~S),Recovery(),Ops(~S),Resource.grant(~S,~Unit,~Unit,~Array<U32>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S))>:
  Resource.declaration(~S,~Unit,~Unit,~Array<U32>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S),~binding(~S))
type Args is Type:
  Args{first:Array<Array<U32>>,element:Array<U32>,second:Array<Array<U32>>,rejected:Array<U32>,fail:Bool}
type Error is Data:
  Failed{}
type Output is Type:
  Output{arrays:List<Array<Array<U32>>>,elements:List<Array<U32>>}
def outcome(fail:Bool) -> T.Outcome<Error>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{Failed{}}
def refused(~H:Type,fail:Bool,result:O.Attempt<H,Array<U32>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case O.Refused{owner,rejected}:(owner,(outcome(fail),Output{[],[rejected]}))
    case O.Applied{owner}:(owner,(T.Failure{Failed{}},Output{[],[]}))
def swapped(~S:Data,~H:Type,~caps:Ops(~S)(H),second:Array<Array<U32>>,rejected:Array<U32>,fail:Bool,result:O.Attempt<H,Array<U32>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case O.Applied{owner}:refused(~H,fail,O.swap(~S,~Array<U32>,~identity(~S),~H,~caps,O.replace(~S,~Array<U32>,~identity(~S),~H,~caps,owner,second),99,rejected))
    case O.Refused{owner,element}:(owner,(T.Failure{Failed{}},Output{[second],[element,rejected]}))
def body(~S:Data,~H:Type,~caps:Ops(~S)(H),args:Args,owner:H) -> H & (T.Outcome<Error> & Output):
  match args:
    case Args{first,element,second,rejected,fail}:swapped(~S,~H,~caps,second,rejected,fail,O.swap(~S,~Array<U32>,~identity(~S),~H,~caps,O.replace(~S,~Array<U32>,~identity(~S),~H,~caps,owner,first),1,element))
def Owned(~S:Data) -> Type:System.Owned(~S,~Unit,~Resources(),~Unit,~Array<U32>,~Recovery(),~Ops(~S),~Args,~Error,~Output,~Resource.grant(~S,~Unit,~Unit,~Array<U32>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~declaration(~S),~body(~S))
def define(~S:Data,world:World(~S),capture:Array<U32>) -> System.Defined<World(~S),Owned(~S),Array<U32>>:
  System.define(~S,~Unit,~Resources(),~Unit,~Array<U32>,~Recovery(),~Ops(~S),~Args,~Error,~Output,~Resource.grant(~S,~Unit,~Unit,~Array<U32>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~declaration(~S),~body(~S),world,"selected-recovery",capture)
def run(~S:Data,owner:Owned(~S),world:World(~S),args:Args) -> System.Run<World(~S),Owned(~S),Args,Error,Output,Recovery()>:
  System.run(~S,~Unit,~Resources(),~Unit,~Array<U32>,~Recovery(),~Ops(~S),~Args,~Error,~Output,~Resource.grant(~S,~Unit,~Unit,~Array<U32>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~declaration(~S),~body(~S),owner,world,args)
def pair(+value:U32) -> Array<U32>:
  ANode{ALeaf{value},ALeaf{(value + 1 : U32)}}
def array(+value:U32) -> Array<Array<U32>>:
  ANode{ALeaf{pair(value)},ALeaf{pair((value + 2 : U32))}}
def args(+seed:U32,fail:Bool) -> Args:
  Args{array(seed),pair((seed + 10 : U32)),array((seed + 20 : U32)),pair((seed + 30 : U32)),fail}
def resources(seed:U32) -> Resources():Product.Owner{array(seed),Product.Owner{array(800),pair(900)}}
