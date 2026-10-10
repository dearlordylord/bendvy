import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/resource-field.bend as Lens
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
# Same canonical field binding drives the grant and detached owning observation.
type Declaration<-S:Data,-C:Type,-R:Type,-E:Data,-Ops:Type -> Type,-V:Data> is Type:
  Declaration{ordinary:Field.Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & V,render:V -> String}
def read_ops(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~V:Data,H:Type) -> Type:
  Field.Read<S,P,identity,H,V>
def write_ops(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~V:Data,H:Type) -> Type:
  Field.Write<S,P,identity,H,V>
def read(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~identity:Schema.Resource<S,P>,~binding:Binding.Binding<S,R,P,Rest,lens,identity>,~view:P -> P & V,~render:V -> String) -> Declaration<S,C,R,E,read_ops(~S,~P,~identity,~V),V>:
  Declaration{Field.read(~S,~C,~R,~E,~P,~Rest,~V,~lens,~identity,~binding,~view),W.observe_resource(~S,~C,~R,~E,~V,~Lens.project(~R,~P,~Rest,~V,~lens,~view)),render}
def write(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~identity:Schema.Resource<S,P>,~binding:Binding.Binding<S,R,P,Rest,lens,identity>,~view:P -> P & V,~render:V -> String) -> Declaration<S,C,R,E,write_ops(~S,~P,~identity,~V),V>:
  Declaration{Field.write(~S,~C,~R,~E,~P,~Rest,~V,~lens,~identity,~binding,~view),W.observe_resource(~S,~C,~R,~E,~V,~Lens.project(~R,~P,~Rest,~V,~lens,~view)),render}
def ordinary(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> Field.Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>:
  match declaration:
    case Declaration{ordinary,_,_}:ordinary
def observer(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> W.World<S,C,R,E> -> W.World<S,C,R,E> & V:
  match declaration:
    case Declaration{_,observe,_}:observe
def renderer(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> V -> String:
  match declaration:
    case Declaration{_,_,render}:render

def names(~S:Data,clauses:List<&2,Query.Clause<S>>) -> String:
  match clauses:
    case []:""
    case Query.Clause{key,_} <> []:key
    case Query.Clause{key,_} <> rest:key ++ "," ++ names(~S,rest)
def name(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> String:
  names(~S,Field.clauses(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),ordinary(~S,~C,~R,~E,~Ops,~V,declaration)))
def presenter(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> V -> String:
  renderer(~S,~C,~R,~E,~Ops,~V,declaration)
