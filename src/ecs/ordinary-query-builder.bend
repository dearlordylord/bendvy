import Base
import ./ordinary-query-observable.bend as O
import ./ordinary-query-declaration.bend as N
import ./ordinary-component-binding.bend as B
import ./inspector-query-projection.bend as P
import ./inspector-query.bend as IQ
import ./inspector.bend as I
import ./compose.bend as Q
import ./component.bend as C
import ./column.bend as Col
import ./capabilities.bend as Cap
import ./internal/query-read-session.bend as Session

# Supported ordinary setup for read/optional/pair queries. Each binding defines
# both ordinary authority and the compact read recipe; finish returns the existing
# ordinary Declaration. Other forms and mixed composition use O.pair after finish.
# The concrete Store remains indexed until composition finishes; gameplay keeps
# the existing opaque owner and query interfaces.
type Builder<-S:Data,-Store:Type,-R:Type,-E:Data,-H:Type,-G:Type,-V:Data> is Type:
  Builder{ordinary:Unit -> O.Declaration<S,H,G,I.Frame<S,Store,R,E>,V>,session:Unit -> P.DeclaredSelection<Session.Owner<S,Store>,S,V>}
def ordinary(~S:Data,~Store:Type,~R:Type,~E:Data,~H:Type,~G:Type,~V:Data,builder:Builder<S,Store,R,E,H,G,V>) -> O.Declaration<S,H,G,I.Frame<S,Store,R,E>,V>:
  match builder:
    case Builder{ordinary,_}:ordinary(Unit{})
def session(~S:Data,~Store:Type,~R:Type,~E:Data,~H:Type,~G:Type,~V:Data,builder:Builder<S,Store,R,E,H,G,V>) -> P.DeclaredSelection<Session.Owner<S,Store>,S,V>:
  match builder:
    case Builder{_,session}:session(Unit{})
def read(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Builder<S,Store,R,E,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>,C.Access<V>>:
  Builder{_=>O.read(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,~R,~E,~binding),_=>Session.slot(~S,~Store,~Rest,~Payload,~V,~take,~put,~view,~Q.Required{})}

def optional(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Builder<S,Store,R,E,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>,C.Access<V>>:
  Builder{_=>O.optional(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,~R,~E,~binding),_=>Session.slot(~S,~Store,~Rest,~Payload,~V,~take,~put,~view,~Q.Optional{})}

def pair(~S:Data,~Store:Type,~Resource:Type,~E:Data,~H:Type,~L:Type,~R:Type,~LV:Data,~RV:Data,~left:Builder<S,Store,Resource,E,H,L,LV>,~right:Builder<S,Store,Resource,E,H,R,RV>) -> Builder<S,Store,Resource,E,H,L & R,P.Product<LV,RV>>:
  Builder{_=>O.pair(~S,~H,~L,~R,~I.Frame<S,Store,Resource,E>,~LV,~RV,~ordinary(~S,~Store,~Resource,~E,~H,~L,~LV,left),~ordinary(~S,~Store,~Resource,~E,~H,~R,~RV,right)),_=>P.pair(~Session.Owner<S,Store>,~S,~LV,~RV,~session(~S,~Store,~Resource,~E,~H,~L,~LV,left),~session(~S,~Store,~Resource,~E,~H,~R,~RV,right))}
# Unsupported declarations remain ordinary O.Declaration values. Composing one
# with finish(builder) through O.pair retains the complete opaque evaluator.
def finish(~S:Data,~Store:Type,~R:Type,~E:Data,~H:Type,~G:Type,~V:Data,~builder:Builder<S,Store,R,E,H,G,V>) -> O.Declaration<S,H,G,I.Frame<S,Store,R,E>,V>:
  O.PreparedDeclaration{_=>O.operational(~S,~H,~G,~I.Frame<S,Store,R,E>,~V,ordinary(~S,~Store,~R,~E,~H,~G,~V,builder)),_=>O.inspection(~S,~H,~G,~I.Frame<S,Store,R,E>,~V,ordinary(~S,~Store,~R,~E,~H,~G,~V,builder)),owner=>Session.enumerate(~S,~Store,~R,~E,~V,~session(~S,~Store,~R,~E,~H,~G,~V,builder),owner)}
def replace_operational(~S:Data,~Store:Type,~R:Type,~E:Data,~H:Type,~Old:Type,~New:Type,~V:Data,~operation:N.Declaration<S,H,New>,~builder:Builder<S,Store,R,E,H,Old,V>) -> Builder<S,Store,R,E,H,New,V>:
  Builder{_=>O.Declaration{_=>operation,_=>O.inspection(~S,~H,~Old,~I.Frame<S,Store,R,E>,~V,ordinary(~S,~Store,~R,~E,~H,~Old,~V,builder))},_=>session(~S,~Store,~R,~E,~H,~Old,~V,builder)}
