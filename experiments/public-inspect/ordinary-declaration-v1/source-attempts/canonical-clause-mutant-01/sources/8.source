import Base
import ../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/column.bend as Col

# Static trusted schema lenses; this Data binding owns no payload or closure.
type Binding<-S:Data,-Store:Type,-Rest:Type,-P:Type,-V:Data,-Token:Data,-take:Store -> Rest & Col.Column<S,P>,-put:Rest -> Col.Column<S,P> -> Store,-view:P -> P & V> is Data:
  Binding{identity:Identity.Declaration<S,P>,family:C.Family<S,Store,Rest,P,V,Token,take,put,view>}
def bind(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,+identity:Identity.Declaration<S,P>) -> Binding<S,Store,Rest,P,V,Token,take,put,view>:
  Binding{identity,C.Family{Identity.key(~S,~P,identity)}}
def identity(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,binding:Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Identity.Declaration<S,P>:
  match binding:
    case Binding{identity,_}:identity
def family(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,binding:Binding<S,Store,Rest,P,V,Token,take,put,view>) -> C.Family<S,Store,Rest,P,V,Token,take,put,view>:
  match binding:
    case Binding{_,family}:family
