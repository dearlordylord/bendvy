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
# Setup carrier for read/optional/pair declarations and their detached
# inspection recipe. It owns no runtime world or payload; use finish to obtain
# the ordinary observable declaration accepted by registration.
type Builder<-S:Data,-Store:Type,-R:Type,-E:Data,-H:Type,-G:Type,-V:Data> is Type:
  Builder{ordinary:Unit -> O.Declaration<S,H,G,I.Frame<S,Store,R,E>,V>,session:Unit -> P.DeclaredSelection<Session.Owner<S,Store>,S,V>}
# Consume the setup builder to obtain its ordinary observable declaration.
# No query executes; use finish to retain the prepared read enumeration path.
def ordinary(~S:Data,~Store:Type,~R:Type,~E:Data,~H:Type,~G:Type,~V:Data,builder:Builder<S,Store,R,E,H,G,V>) -> O.Declaration<S,H,G,I.Frame<S,Store,R,E>,V>:
  match builder:
    case Builder{ordinary,_}:ordinary(Unit{})
def session(~S:Data,~Store:Type,~R:Type,~E:Data,~H:Type,~G:Type,~V:Data,builder:Builder<S,Store,R,E,H,G,V>) -> P.DeclaredSelection<Session.Owner<S,Store>,S,V>:
  match builder:
    case Builder{_,session}:session(Unit{})
# Build a required component read and matching detached inspection recipe
# from one trusted binding. view preserves Payload and exposes Data V only.
# Operational reads return Found/ComponentAbsent/MissingEntity; declaration
# creation neither acquires a world nor advances system visibility.
def read(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Builder<S,Store,R,E,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>,C.Access<V>>:
  Builder{_=>O.read(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,~R,~E,~binding),_=>Session.slot(~S,~Store,~Rest,~Payload,~V,~take,~put,~view,~Q.Required{})}

# Build an optional read: a missing component does not exclude a live row.
# Access results retain ComponentAbsent; stale/foreign handles remain
# MissingEntity. The projection preserves affine Payload while exposing V.
def optional(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Builder<S,Store,R,E,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>,C.Access<V>>:
  Builder{_=>O.optional(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,~R,~E,~binding),_=>Session.slot(~S,~Store,~Rest,~Payload,~V,~take,~put,~view,~Q.Optional{})}

# Combine setup builders with conjunctive row selection and nested grants
# (L & R); detached results use Product<LV,RV>. Both builders must share schema,
# storage and owner. Nest pairs for larger shapes; no fixed arity limit is
# introduced. No row traversal occurs during construction.
def pair(~S:Data,~Store:Type,~Resource:Type,~E:Data,~H:Type,~L:Type,~R:Type,~LV:Data,~RV:Data,~left:Builder<S,Store,Resource,E,H,L,LV>,~right:Builder<S,Store,Resource,E,H,R,RV>) -> Builder<S,Store,Resource,E,H,L & R,P.Product<LV,RV>>:
  Builder{_=>O.pair(~S,~H,~L,~R,~I.Frame<S,Store,Resource,E>,~LV,~RV,~ordinary(~S,~Store,~Resource,~E,~H,~L,~LV,left),~ordinary(~S,~Store,~Resource,~E,~H,~R,~RV,right)),_=>P.pair(~Session.Owner<S,Store>,~S,~LV,~RV,~session(~S,~Store,~Resource,~E,~H,~L,~LV,left),~session(~S,~Store,~Resource,~E,~H,~R,~RV,right))}
# Unsupported declarations remain ordinary O.Declaration values. Composing one
# with finish(builder) through O.pair retains the complete opaque evaluator.
# Produce an ordinary observable declaration with prepared read enumeration.
# Supports this builder's read/optional/pair forms; mix other supported forms
# afterward using ordinary-query-observable.pair. Preserves typed operational
# grants and detached inspection; this call does not execute either.
# Example: test-fixtures/connected-performance/sparse-motion64/consumer/s-perf/
# canonical-api-v1/sparse-runtime-v1/motion-logical.bend, declaration().
def finish(~S:Data,~Store:Type,~R:Type,~E:Data,~H:Type,~G:Type,~V:Data,~builder:Builder<S,Store,R,E,H,G,V>) -> O.Declaration<S,H,G,I.Frame<S,Store,R,E>,V>:
  O.PreparedDeclaration{_=>O.operational(~S,~H,~G,~I.Frame<S,Store,R,E>,~V,ordinary(~S,~Store,~R,~E,~H,~G,~V,builder)),_=>O.inspection(~S,~H,~G,~I.Frame<S,Store,R,E>,~V,ordinary(~S,~Store,~R,~E,~H,~G,~V,builder)),owner=>Session.enumerate(~S,~Store,~R,~E,~V,~session(~S,~Store,~R,~E,~H,~G,~V,builder),owner)}
# Trusted advanced adapter replacing the builder's operational declaration
# while retaining its inspection and read-enumeration recipes. Caller must
# preserve their intended relationship; no semantic equivalence is checked.
# Does not grant inspection the replacement's write operations.
def replace_operational(~S:Data,~Store:Type,~R:Type,~E:Data,~H:Type,~Old:Type,~New:Type,~V:Data,~operation:N.Declaration<S,H,New>,~builder:Builder<S,Store,R,E,H,Old,V>) -> Builder<S,Store,R,E,H,New,V>:
  Builder{_=>O.Declaration{_=>operation,_=>O.inspection(~S,~H,~Old,~I.Frame<S,Store,R,E>,~V,ordinary(~S,~Store,~R,~E,~H,~Old,~V,builder))},_=>session(~S,~Store,~R,~E,~H,~Old,~V,builder)}
