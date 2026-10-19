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
type Declaration<-S:Data,-Store:Type,-R:Type,-E:Data,-Ops:Type -> Type> is Type:
  Declaration{legacy:Unit -> N.Declaration<S,Q.Frame<S,Store,R,E>,Ops(Q.Frame<S,Store,R,E>)>,caps:Unit -> Ops(F.Frame<S,Store,R,E>),select:F.Frame<S,Store,R,E> -> F.Frame<S,Store,R,E> & Bool}
def ordinary(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,declaration:Declaration<S,Store,R,E,Ops>) -> N.Declaration<S,Q.Frame<S,Store,R,E>,Ops(Q.Frame<S,Store,R,E>)>:
  match declaration:
    case Declaration{legacy,_,_}:legacy(Unit{})
def caps(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,declaration:Declaration<S,Store,R,E,Ops>) -> Ops(F.Frame<S,Store,R,E>):
  match declaration:
    case Declaration{_,caps,_}:caps(Unit{})
def selector(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,declaration:Declaration<S,Store,R,E,Ops>) -> F.Frame<S,Store,R,E> -> F.Frame<S,Store,R,E> & Bool:
  match declaration:
    case Declaration{_,_,select}:select

def write_caps(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Cap.Write<F.Frame<S,Store,R,E>,P,V>:
  Cap.Write{F.read(~S,~Store,~R,~E,~Rest,~P,~V,~take,~put,~view),F.bridge_set(~S,~Store,~R,~E,~P,~Q.set(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~B.family(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)))}
def write(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Declaration<S,Store,R,E,H => Cap.Write<H,P,V>>:
  Declaration{_=>N.write(~S,~P,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding),~view,~take,~put),_=>write_caps(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~binding),F.family_match(~S,~Store,~R,~E,~Rest,~P,~V,~take,~put,~view,~Q.Required{})}
def resource_caps(~S:Data,~Store:Type,~R:Type,~Logs:Type,~E:Data,~V:Data,~view:R -> R & V) -> Cap.ValueWrite<F.Frame<S,Store,Product.Owner<R,Logs>,E>,R,V>:
  Cap.ValueWrite{F.bridge_get(~S,~Store,~Product.Owner<R,Logs>,~E,~V,~Resource.read(~S,~Store,~R,~Logs,~E,~V,~view)),F.bridge_set(~S,~Store,~Product.Owner<R,Logs>,~E,~R,~Resource.set(~S,~Store,~R,~Logs,~E))}
def resource_write(~S:Data,~Store:Type,~R:Type,~Logs:Type,~E:Data,~V:Data,~identity:Schema.Resource<S,R>,~view:R -> R & V) -> Declaration<S,Store,Product.Owner<R,Logs>,E,H => Cap.ValueWrite<H,R,V>>:
  Declaration{_=>Resource.write(~S,~Store,~R,~Logs,~E,~V,~identity,~view),_=>resource_caps(~S,~Store,~R,~Logs,~E,~V,~view),F.all(~S,~Store,~Product.Owner<R,Logs>,~E)}
def pair_caps(~S:Data,~Store:Type,~R:Type,~E:Data,~L:Type -> Type,~Right:Type -> Type,~left:Declaration<S,Store,R,E,L>,~right:Declaration<S,Store,R,E,Right>) -> L(F.Frame<S,Store,R,E>) & Right(F.Frame<S,Store,R,E>):
  (caps(~S,~Store,~R,~E,~L,left),caps(~S,~Store,~R,~E,~Right,right))
def pair(~S:Data,~Store:Type,~R:Type,~E:Data,~L:Type -> Type,~Right:Type -> Type,~left:Declaration<S,Store,R,E,L>,~right:Declaration<S,Store,R,E,Right>) -> Declaration<S,Store,R,E,H => L(H) & Right(H)>:
  Declaration{_=>N.pair(~S,~Q.Frame<S,Store,R,E>,~L(Q.Frame<S,Store,R,E>),~Right(Q.Frame<S,Store,R,E>),~ordinary(~S,~Store,~R,~E,~L,left),~ordinary(~S,~Store,~R,~E,~Right,right)),_=>pair_caps(~S,~Store,~R,~E,~L,~Right,~left,~right),F.both(~S,~Store,~R,~E,~selector(~S,~Store,~R,~E,~L,left),~selector(~S,~Store,~R,~E,~Right,right))}
