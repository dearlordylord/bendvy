import Base
import ./ordinary-declaration.bend as Identity
import ./component.bend as C
import ./column.bend as Col

# Static trusted schema lenses; this Data binding owns no payload or closure.
type Binding<-S:Data,-Store:Type,-Rest:Type,-P:Type,-V:Data,-Token:Data,-take:Store -> Rest & Col.Column<S,P>,-put:Rest -> Col.Column<S,P> -> Store,-view:P -> P & V> is Data:
  Binding{identity:Identity.Declaration<S,P>,family:C.Family<S,Store,Rest,P,V,Token,take,put,view>}
# Trusted schema setup: connect a component identity to its column take/put
# lenses and owner-preserving Data projection. The resulting Data binding owns
# no payload. Callers must supply mutually consistent lenses; this constructor
# does not prove their laws or establish runtime world identity.
# Example: examples/scheduled-health/registration.bend component bindings.
def bind(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,+identity:Identity.Declaration<S,P>) -> Binding<S,Store,Rest,P,V,Token,take,put,view>:
  Binding{identity,C.Family{Identity.key(~S,~P,identity)}}
# Return the schema-scoped component identity from a trusted binding.
# This detached declaration does not identify an entity or grant world access.
def identity(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,binding:Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Identity.Declaration<S,P>:
  match binding:
    case Binding{identity,_}:identity
# Return the typed component family used by lower-level component operations.
# Retains the binding's schema, storage and projection indices; does not access
# a world. Raw family construction is trusted provisioning, not gameplay access.
def family(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,binding:Binding<S,Store,Rest,P,V,Token,take,put,view>) -> C.Family<S,Store,Rest,P,V,Token,take,put,view>:
  match binding:
    case Binding{_,family}:family
