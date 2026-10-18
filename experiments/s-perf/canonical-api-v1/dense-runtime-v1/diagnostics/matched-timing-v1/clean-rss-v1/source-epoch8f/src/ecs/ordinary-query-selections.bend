import Base
import ordinary-component-binding.bend as B
import inspector-query-families.bend as F
import inspector-query-projection.bend as Q
import column.bend as Col
import component.bend as C
import inspector.bend as I
import check.bend as K
import compose.bend as P
# Ordinary lowering uses the retained binding, never a second caller family/name.
def inspect_slot(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:F.SlotMode) -> Q.DeclaredSelection<I.Frame<S,Store,R,E>,S,C.Access<V>>:
  F.inspect_slot(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~B.family(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~project,binding),~mode)
def inspect_with(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,project>) -> Q.Predicate<I.Frame<S,Store,R,E>,S>:
  F.inspect_with(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~B.family(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~project,binding))
def inspect_without(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,project>) -> Q.Predicate<I.Frame<S,Store,R,E>,S>:
  F.inspect_without(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~B.family(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~project,binding))
def inspect_filter(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:P.LifecycleSelection) -> Q.Predicate<I.Frame<S,Store,R,E>,S>:
  F.inspect_filter(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~B.family(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~project,binding),~mode)
def check_slot(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:F.SlotMode) -> Q.DeclaredSelection<K.Frame<S,Store,R,E>,S,C.Access<V>>:
  F.check_slot(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~B.family(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~project,binding),~mode)
def check_with(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,project>) -> Q.Predicate<K.Frame<S,Store,R,E>,S>:
  F.check_with(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~B.family(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~project,binding))
def check_without(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,project>) -> Q.Predicate<K.Frame<S,Store,R,E>,S>:
  F.check_without(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~B.family(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~project,binding))
