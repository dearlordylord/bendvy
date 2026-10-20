import Base
import ./compose.bend as Q
import ./ordinary-query-declaration.bend as N
import ./internal/compact-operational-frame.bend as F
import ./ordinary-component-binding.bend as B
import ./column.bend as Col
import ./component.bend as C
import ./capabilities.bend as Cap
import ./ordinary-schema.bend as Schema
import ./ordinary-owned-event-family-resource.bend as Resource
import ./owner-product.bend as Product

# The owner functor is retained before ordinary grant erasure. Raw declarations
# continue through the existing registration path.
# A closed query declaration for the recognized App entry, tied to schema S and
# its component/resource owners. Ops gives the same declared capabilities for
# both ordinary and compact execution; callbacks must return their opaque owner.
# Use write, resource_write and pair below. This additive surface does not supply
# all ordinary query combinators or an adapter for arbitrary custom selectors.
# Complete setup: the Sparse consumer's motion.bend:recognized and
# motion-driver.bend:define under test-fixtures/connected-performance/
# sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/.
type Declaration<-S:Data,-Store:Type,-R:Type,-E:Data,-Ops:Type -> Type> is Type:
  Declaration{legacy:Unit -> N.Declaration<S,Q.Frame<S,Store,R,E>,Ops(Q.Frame<S,Store,R,E>)>,caps:Unit -> Ops(F.Frame<S,Store,R,E>),select:F.Frame<S,Store,R,E> -> F.Frame<S,Store,R,E> & Bool}
# Convert the recognized declaration into its ordinary operational declaration.
# Consumes the carrier; call a closed declaration template again when both forms
# are needed. Selection, access clauses and grants come from this same carrier.
def ordinary(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,declaration:Declaration<S,Store,R,E,Ops>) -> N.Declaration<S,Q.Frame<S,Store,R,E>,Ops(Q.Frame<S,Store,R,E>)>:
  match declaration:
    case Declaration{legacy,_,_}:legacy(Unit{})
# Advanced runner projection: consume the declaration and obtain operations for
# the compact opaque frame. Application callbacks receive these through their
# Ops parameter; they should not construct or unwrap a compact frame themselves.
def caps(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,declaration:Declaration<S,Store,R,E,Ops>) -> Ops(F.Frame<S,Store,R,E>):
  match declaration:
    case Declaration{_,caps,_}:caps(Unit{})
# Advanced runner projection: consume the declaration and obtain its row filter.
# The filter returns the updated frame even when the row does not match. This
# operation does not enumerate entities or grant access beyond the declaration.
def selector(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,declaration:Declaration<S,Store,R,E,Ops>) -> F.Frame<S,Store,R,E> -> F.Frame<S,Store,R,E> & Bool:
  match declaration:
    case Declaration{_,_,select}:select

# Internal capability assembly for write; the binding fixes the component path.
# The getter threads its payload back with a Data view; the setter uses the
# ordinary transactional write path. Prefer write in setup.
def write_caps(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Cap.Write<F.Frame<S,Store,R,E>,P,V>:
  Cap.Write{F.read(~S,~Store,~R,~E,~Rest,~P,~V,~take,~put,~view),F.bridge_set(~S,~Store,~R,~E,~P,~Q.set(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~B.family(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)))}
# Declare required read/write access to one schema-bound component family.
# Only matching rows invoke the body. P may be an affine Type; view threads P
# back together with a Data observation V. take/put describe the same store
# path as binding. The returned declaration supplies Cap.Write;
# access failures still flow through the query's normal error/rollback result.
def write(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Declaration<S,Store,R,E,H => Cap.Write<H,P,V>>:
  Declaration{_=>N.write(~S,~P,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding),~view,~take,~put),_=>write_caps(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~binding),F.family_match(~S,~Store,~R,~E,~Rest,~P,~V,~take,~put,~view,~Q.Required{})}
# Internal capability assembly for resource_write. Keeps the resource and Logs
# owners together and uses the ordinary resource transaction bridge; this is not
# a direct application resource handle or permission to bypass rollback.
def resource_caps(~S:Data,~Store:Type,~R:Type,~Logs:Type,~E:Data,~V:Data,~view:R -> R & V) -> Cap.ValueWrite<F.Frame<S,Store,Product.Owner<R,Logs>,E>,R,V>:
  Cap.ValueWrite{F.bridge_get(~S,~Store,~Product.Owner<R,Logs>,~E,~V,~Resource.read(~S,~Store,~R,~Logs,~E,~V,~view)),F.bridge_set(~S,~Store,~Product.Owner<R,Logs>,~E,~R,~Resource.set(~S,~Store,~R,~Logs,~E))}
# Declare read/write access to a schema resource whose owner is paired with Logs.
# The owner-preserving view returns a Data value; resource selection alone does
# not exclude an entity row. The supplied identity determines declared access.
# Writes retain the ordinary resource undo/rollback behavior. Pair this with a
# component declaration when the body also needs a current entity component.
def resource_write(~S:Data,~Store:Type,~R:Type,~Logs:Type,~E:Data,~V:Data,~identity:Schema.Resource<S,R>,~view:R -> R & V) -> Declaration<S,Store,Product.Owner<R,Logs>,E,H => Cap.ValueWrite<H,R,V>>:
  Declaration{_=>Resource.write(~S,~Store,~R,~Logs,~E,~V,~identity,~view),_=>resource_caps(~S,~Store,~R,~Logs,~E,~V,~view),F.all(~S,~Store,~Product.Owner<R,Logs>,~E)}
# Internal grant assembly for pair: produce left and right operation bundles
# for the same compact owner. Prefer pair rather than assembling these manually.
def pair_caps(~S:Data,~Store:Type,~R:Type,~E:Data,~L:Type -> Type,~Right:Type -> Type,~left:Declaration<S,Store,R,E,L>,~right:Declaration<S,Store,R,E,Right>) -> L(F.Frame<S,Store,R,E>) & Right(F.Frame<S,Store,R,E>):
  (caps(~S,~Store,~R,~E,~L,left),caps(~S,~Store,~R,~E,~Right,right))
# Combine two declarations for the same schema/store/resource owners.
# The body receives (leftCaps, rightCaps) in that order. Selection runs left first;
# if it returns False, right is not called, and the returned owner is preserved.
# The ordinary form keeps the same clause order, including duplicate clauses;
# this does not promise that two grants refer to disjoint component columns.
def pair(~S:Data,~Store:Type,~R:Type,~E:Data,~L:Type -> Type,~Right:Type -> Type,~left:Declaration<S,Store,R,E,L>,~right:Declaration<S,Store,R,E,Right>) -> Declaration<S,Store,R,E,H => L(H) & Right(H)>:
  Declaration{_=>N.pair(~S,~Q.Frame<S,Store,R,E>,~L(Q.Frame<S,Store,R,E>),~Right(Q.Frame<S,Store,R,E>),~ordinary(~S,~Store,~R,~E,~L,left),~ordinary(~S,~Store,~R,~E,~Right,right)),_=>pair_caps(~S,~Store,~R,~E,~L,~Right,~left,~right),F.both(~S,~Store,~R,~E,~selector(~S,~Store,~R,~E,~L,left),~selector(~S,~Store,~R,~E,~Right,right))}
