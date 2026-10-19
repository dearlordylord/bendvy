import Base
import ../world.bend as W
import ../entity-key.bend as K
import ../entity-allocator.bend as A
import ../component.bend as C
import ../column.bend as Col
import ../inspector.bend as I
import ../inspector-query.bend as IQ
import ../inspector-query-world.bend as IW
import ../inspector-query-projection.bend as P
import ../compose.bend as Q
import ../deferred-command.bend as Deferred

# A scan owns one Store; unrelated World owners remain outside its row loop.
type Owner<-S:Data,-Store:Type> is Type:
  Owner{namespace:U32,allocator:A.Allocator,store:Store,cursor:U32}

def read_join(~S:Data,~Store:Type,~V:Data,namespace:U32,allocator:A.Allocator,cursor:U32,observed:Store & C.Access<V>) -> Owner<S,Store> & C.Access<V>:
  (store,value)=observed
  (Owner{namespace,allocator,store,cursor},value)
def read_valid(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,namespace:U32,store:Store,cursor:U32,key:K.Key,observed:A.Allocator & Bool) -> Owner<S,Store> & C.Access<V>:
  match key observed:
    case _, (allocator,False{}):(Owner{namespace,allocator,store,cursor},C.MissingEntity{})
    case K.EntityKey{id,_}, (allocator,True{}):read_join(~S,~Store,~V,namespace,allocator,cursor,C.get_store(~S,~Store,~Unit,~Nat,~Rest,~Payload,~V,~Unit,~take,~put,~view,id,take(store)))
def read_namespace(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,allowed:Bool,namespace:U32,allocator:A.Allocator,store:Store,cursor:U32,+key:K.Key) -> Owner<S,Store> & C.Access<V>:
  match allowed:
    case False{}:(Owner{namespace,allocator,store,cursor},C.MissingEntity{})
    case True{}:read_valid(~S,~Store,~Rest,~Payload,~V,~take,~put,~view,namespace,store,cursor,key,A.checked(allocator,key,1))
def read(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,owner:Owner<S,Store>,target:W.Handle<S>) -> Owner<S,Store> & C.Access<V>:
  match owner target:
    case Owner{+namespace,allocator,store,cursor} W.Handle{ns,key}:read_namespace(~S,~Store,~Rest,~Payload,~V,~take,~put,~view,U32.is_eq(namespace,ns),namespace,allocator,store,cursor,key)
def matched(~S:Data,~Store:Type,mode:Q.Selection,observed:Owner<S,Store> & C.Access<Bool>) -> Owner<S,Store> & Bool:
  (owner,value)=observed
  (owner,Q.selected_value(~Bool,mode,value))
def matches(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~mode:Q.Selection,owner:Owner<S,Store>,target:W.Handle<S>) -> Owner<S,Store> & Bool:
  matched(~S,~Store,mode,read(~S,~Store,~Rest,~Payload,~Bool,~take,~put,~Col.present(~Payload),owner,target))
def slot(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~mode:Q.Selection) -> P.DeclaredSelection<Owner<S,Store>,S,C.Access<V>>:
  P.DeclaredSelection{owner=>target=>matches(~S,~Store,~Rest,~Payload,~take,~put,~mode,owner,target),owner=>target=>read(~S,~Store,~Rest,~Payload,~V,~take,~put,~view,owner,target)}

def restore(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,resource:R,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,Store,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,observed:Owner<S,Store> & List<&2,IQ.ProjectedRow<S,V>>) -> I.Frame<S,Store,R,E> & List<&2,IQ.ProjectedRow<S,V>>:
  match observed:
    case (Owner{namespace,allocator,store,cursor},rows):(I.Frame{W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},cursor},rows)
def enter_world(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~selection:P.DeclaredSelection<Owner<S,Store>,S,V>,world:W.World<S,Store,R,E>,cursor:U32,targets:List<&2,W.Handle<S>>) -> I.Frame<S,Store,R,E> & List<&2,IQ.ProjectedRow<S,V>>:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}:restore(~S,~Store,~R,~E,~V,resource,events,pending,registrations,nextSystemId,clock,IQ.composed_scanned(~Owner<S,Store>,~S,~V,~selection,(Owner{namespace,allocator,store,cursor},targets)))
def enter(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~selection:P.DeclaredSelection<Owner<S,Store>,S,V>,observed:I.Frame<S,Store,R,E> & List<&2,W.Handle<S>>) -> I.Frame<S,Store,R,E> & List<&2,IQ.ProjectedRow<S,V>>:
  match observed:
    case (I.Frame{world,cursor},targets):enter_world(~S,~Store,~R,~E,~V,~selection,world,cursor,targets)
def enumerate(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~selection:P.DeclaredSelection<Owner<S,Store>,S,V>,frame:I.Frame<S,Store,R,E>) -> I.Frame<S,Store,R,E> & List<&2,IQ.ProjectedRow<S,V>>:
  enter(~S,~Store,~R,~E,~V,~selection,IQ.composed_handles_field(~I.Frame<S,Store,R,E>,~S,IW.inspect_world(~S,~Store,~R,~E))(frame))
