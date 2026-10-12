import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-despawn.bend as Clear

# Closed trusted setup declaration; the same clear index supplies execution.
type Declaration<-S:Data,-Store:Type,-E:Data,-clear:Store -> W.Handle<S> -> Store & List<&2,E>> is Data:
  Declaration{keys:List<&2,String>}
def keys(~S:Data,~Store:Type,~E:Data,~clear:Store -> W.Handle<S> -> Store & List<&2,E>,declaration:Declaration<S,Store,E,clear>) -> List<&2,String>:
  match declaration:
    case Declaration{keys}:keys
def leaf(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~E:Data,~inject:Identity.Declaration<S,P> -> W.Handle<S> -> E,~binding:Binding.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Declaration<S,Store,E,Clear.leaf(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,~E,~inject,~binding)>:
  Declaration{[Identity.key(~S,~P,Binding.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding))]}
def product_clear(~S:Data,~Store:Type,~E:Data,~left:Store -> W.Handle<S> -> Store & List<&2,E>,~right:Store -> W.Handle<S> -> Store & List<&2,E>,store:Store,handle:W.Handle<S>) -> Store & List<&2,E>:
  Clear.product(~S,~Store,~E,~left,~right,store,handle)
def product(~S:Data,~Store:Type,~E:Data,~left:Store -> W.Handle<S> -> Store & List<&2,E>,~right:Store -> W.Handle<S> -> Store & List<&2,E>,~leftDeclaration:Declaration<S,Store,E,left>,~rightDeclaration:Declaration<S,Store,E,right>) -> Declaration<S,Store,E,product_clear(~S,~Store,~E,~left,~right)>:
  Declaration{List.append(&2,String,keys(~S,~Store,~E,~left,leftDeclaration),keys(~S,~Store,~E,~right,rightDeclaration))}
