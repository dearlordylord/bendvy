import Base
import ./fixture.bend as Fixture
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema

def first_identity(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"FirstResource")
def second_identity(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"SecondResource")
def Index(~S:Data) -> Data:B.Branch<B.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>,B.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>>
def declarations(~S:Data) -> B.Built<S,Fixture.Resources(),Index(~S)>:
  B.joined(~S,~Array<U32>,~Array<U32>,~Schema.Resource<S,Array<U32>>,~Schema.Resource<S,Array<U32>>,B.leaf(~S,~Array<U32>,first_identity(~S)),B.leaf(~S,~Array<U32>,second_identity(~S)))
def root(~S:Data) -> B.Cursor<S,Fixture.Resources(),Fixture.Resources(),Unit,Index(~S),B.whole(~Fixture.Resources())>:
  B.root(~S,~Fixture.Resources(),~Index(~S),declarations(~S))
def first_lens() -> Product.Lens<Fixture.Resources(),Array<U32>,Unit & Array<U32>>:
  B.left_lens(~Fixture.Resources(),~Array<U32>,~Array<U32>,~Unit,~B.whole(~Fixture.Resources()))
def second_lens() -> Product.Lens<Fixture.Resources(),Array<U32>,Unit & Array<U32>>:
  B.right_lens(~Fixture.Resources(),~Array<U32>,~Array<U32>,~Unit,~B.whole(~Fixture.Resources()))
def first(~S:Data) -> B.Cursor<S,Fixture.Resources(),Array<U32>,Unit & Array<U32>,Schema.Resource<S,Array<U32>>,first_lens()>:
  B.left(~S,~Fixture.Resources(),~Array<U32>,~Array<U32>,~Unit,~Schema.Resource<S,Array<U32>>,~Schema.Resource<S,Array<U32>>,~B.whole(~Fixture.Resources()),root(~S))
def second(~S:Data) -> B.Cursor<S,Fixture.Resources(),Array<U32>,Unit & Array<U32>,Schema.Resource<S,Array<U32>>,second_lens()>:
  B.right(~S,~Fixture.Resources(),~Array<U32>,~Array<U32>,~Unit,~Schema.Resource<S,Array<U32>>,~Schema.Resource<S,Array<U32>>,~B.whole(~Fixture.Resources()),root(~S))
def first_binding(~S:Data) -> B.Binding<S,Fixture.Resources(),Array<U32>,Unit & Array<U32>,first_lens(),first_identity(~S)>:
  B.bind(~S,~Fixture.Resources(),~Array<U32>,~Unit & Array<U32>,~first_lens(),~first(~S))
def second_binding(~S:Data) -> B.Binding<S,Fixture.Resources(),Array<U32>,Unit & Array<U32>,second_lens(),second_identity(~S)>:
  B.bind(~S,~Fixture.Resources(),~Array<U32>,~Unit & Array<U32>,~second_lens(),~second(~S))
def view(values:Array<U32>) -> Array<U32> & U32:Array.get(U32,values,0)
