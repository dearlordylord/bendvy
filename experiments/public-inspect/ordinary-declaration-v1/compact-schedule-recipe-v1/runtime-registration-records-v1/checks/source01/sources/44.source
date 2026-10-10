import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as P

# Private presentation belongs to the normal component binding, not a dump call.
type Binding<-S:Data,-Store:Type,-Rest:Type,-Payload:Type,-V:Data,-Token:Data,-take:Store -> Rest & Col.Column<S,Payload>,-put:Rest -> Col.Column<S,Payload> -> Store,-view:Payload -> Payload & V> is Type:
  Binding{ordinary:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>,display:V -> String}
def bind(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,ordinary:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>,display:V -> String) -> Binding<S,Store,Rest,Payload,V,Token,take,put,view>:
  Binding{ordinary,display}
def ordinary_binding(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,binding:Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>:
  match binding:
    case Binding{ordinary,_}:ordinary
def binding_display(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,binding:Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> V -> String:
  match binding:
    case Binding{_,display}:display
type Declaration<-S:Data,-H:Type,-Ops:Type,-IH:Type,-V:Data> is Type:
  Declaration{ordinary:O.Declaration<S,H,Ops,IH,V>,display:V -> String}
def ordinary(~S:Data,~H:Type,~Ops:Type,~IH:Type,~V:Data,declaration:Declaration<S,H,Ops,IH,V>) -> O.Declaration<S,H,Ops,IH,V>:
  match declaration:
    case Declaration{ordinary,_}:ordinary
def display(~S:Data,~H:Type,~Ops:Type,~IH:Type,~V:Data,declaration:Declaration<S,H,Ops,IH,V>) -> V -> String:
  match declaration:
    case Declaration{_,display}:display
def access(~V:Data,~display:V -> String,value:C.Access<V>) -> String:
  match value:
    case C.Found{value}:"Found:" ++ display(value)
    case C.ComponentAbsent{}:"ComponentAbsent"
    case C.MissingEntity{}:"MissingEntity"
def unit(value:Unit) -> String:
  "Unit"
def product(~L:Data,~R:Data,~left:L -> String,~right:R -> String,value:P.Product<L,R>) -> String:
  match value:
    case P.Product{leftValue,rightValue}:"Product(" ++ left(leftValue) ++ "," ++ right(rightValue) ++ ")"
def read(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>,I.Frame<S,Store,R,E>,C.Access<V>>:
  Declaration{O.read(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,~R,~E,~ordinary_binding(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding)),access(~V,~binding_display(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding))}
def optional(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>,I.Frame<S,Store,R,E>,C.Access<V>>:
  Declaration{O.optional(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,~R,~E,~ordinary_binding(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding)),access(~V,~binding_display(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding))}
def without_component(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit,I.Frame<S,Store,R,E>,Unit>:
  Declaration{O.without_component(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,~R,~E,~ordinary_binding(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding)),unit}
def added(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit,I.Frame<S,Store,R,E>,Unit>:
  Declaration{O.added(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,~R,~E,~ordinary_binding(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding)),unit}
def pair(~S:Data,~H:Type,~L:Type,~R:Type,~IH:Type,~LV:Data,~RV:Data,~left:Declaration<S,H,L,IH,LV>,~right:Declaration<S,H,R,IH,RV>) -> Declaration<S,H,L & R,IH,P.Product<LV,RV>>:
  Declaration{O.pair(~S,~H,~L,~R,~IH,~LV,~RV,~ordinary(~S,~H,~L,~IH,~LV,left),~ordinary(~S,~H,~R,~IH,~RV,right)),product(~LV,~RV,~display(~S,~H,~L,~IH,~LV,left),~display(~S,~H,~R,~IH,~RV,right))}
