import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field-declaration.bend as App
import runtime-owners.bend as Owners
import schema-families.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/resource-field.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def physical(~S:Data) -> Schema.Resource<S,Owners.Physical<S>>:
  Schema.resource(~S,~Owners.Physical<S>,"ApplicationOwners")
def identity(~S:Data) -> Schema.Resource<S,Owners.CheckInputs<S>>:
  Schema.resource(~S,~Owners.CheckInputs<S>,"CheckInputs")
def Index(~S:Data) -> Data:
  Tree.Branch<Tree.Built<S,Owners.Physical<S>,Schema.Resource<S,Owners.Physical<S>>>,Tree.Built<S,Owners.CheckInputs<S>,Schema.Resource<S,Owners.CheckInputs<S>>>>
def tree(~S:Data) -> Tree.Built<S,Owners.Resource(~S),Index(~S)>:
  Tree.joined(~S,~Owners.Physical<S>,~Owners.CheckInputs<S>,~Schema.Resource<S,Owners.Physical<S>>,~Schema.Resource<S,Owners.CheckInputs<S>>,Tree.leaf(~S,~Owners.Physical<S>,physical(~S)),Tree.leaf(~S,~Owners.CheckInputs<S>,identity(~S)))
def lens(~S:Data) -> Product.Lens<Owners.Resource(~S),Owners.CheckInputs<S>,Unit & Owners.Physical<S>>:
  Tree.right_lens(~Owners.Resource(~S),~Owners.Physical<S>,~Owners.CheckInputs<S>,~Unit,~Tree.whole(~Owners.Resource(~S)))
def binding(~S:Data) -> Tree.Binding<S,Owners.Resource(~S),Owners.CheckInputs<S>,Unit & Owners.Physical<S>,lens(~S),identity(~S)>:
  Tree.bind(~S,~Owners.Resource(~S),~Owners.CheckInputs<S>,~(Unit & Owners.Physical<S>),~lens(~S),~Tree.right(~S,~Owners.Resource(~S),~Owners.Physical<S>,~Owners.CheckInputs<S>,~Unit,~Schema.Resource<S,Owners.Physical<S>>,~Schema.Resource<S,Owners.CheckInputs<S>>,~Tree.whole(~Owners.Resource(~S)),Tree.root(~S,~Owners.Resource(~S),~Index(~S),tree(~S))))
def view(~S:Data,value:Owners.CheckInputs<S>) -> Owners.CheckInputs<S> & Owners.CheckInputs<S>:
  match value:
    case Owners.CheckInputs{+kind,+targets,+expected}:(Owners.CheckInputs{kind,targets,expected},Owners.CheckInputs{kind,targets,expected})
def project(~S:Data,resource:Owners.Resource(~S)) -> Owners.Resource(~S) & Owners.CheckInputs<S>:
  Field.project(~Owners.Resource(~S),~Owners.CheckInputs<S>,~(Unit & Owners.Physical<S>),~Owners.CheckInputs<S>,~lens(~S),~view(~S),resource)
def render(~S:Data,value:Owners.CheckInputs<S>) -> String:
  match value:
    case Owners.CheckInputs{kind,_,expected}:U32.show(kind) ++ ":" ++ expected
def ops(~S:Data,H:Type) -> Type:
  App.read_ops(~S,~Owners.CheckInputs<S>,~identity(~S),~Owners.CheckInputs<S>,H)
def declaration(~S:Data) -> App.Declaration<S,D.Store<S>,Owners.Resource(~S),U32,App.read_ops(~S,~Owners.CheckInputs<S>,~identity(~S),~Owners.CheckInputs<S>),Owners.CheckInputs<S>>:
  App.read(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Owners.CheckInputs<S>,~(Unit & Owners.Physical<S>),~Owners.CheckInputs<S>,~lens(~S),~identity(~S),~binding(~S),~view(~S),~render(~S))
def read(~S:Data,world:W.World<S,D.Store<S>,Owners.Resource(~S),U32>) -> W.World<S,D.Store<S>,Owners.Resource(~S),U32> & Owners.CheckInputs<S>:
  App.observer(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~App.read_ops(~S,~Owners.CheckInputs<S>,~identity(~S),~Owners.CheckInputs<S>),~Owners.CheckInputs<S>,declaration(~S))(world)
def replaced(~S:Data,result:W.World<S,D.Store<S>,Owners.Resource(~S),U32> & Owners.CheckInputs<S>) -> W.World<S,D.Store<S>,Owners.Resource(~S),U32>:
  (world,_)=result
  world
def set(~S:Data,value:Owners.CheckInputs<S>,world:W.World<S,D.Store<S>,Owners.Resource(~S),U32>) -> W.World<S,D.Store<S>,Owners.Resource(~S),U32>:
  replaced(~S,Field.replace_world(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Owners.CheckInputs<S>,~(Unit & Owners.Physical<S>),~lens(~S),value,world))
