import Base
import ./ordinary-query-declaration.bend as N
import ./ordinary-component-binding.bend as B
import ./ordinary-declaration.bend as Identity
import ./ordinary-query-selections.bend as F
import ./inspector-query-projection.bend as P
import ./inspector-query-families.bend as Families
import ./inspector-query-world.bend as IW
import ./inspector-query.bend as IQ
import ./inspector.bend as I
import ./compose.bend as Q
import ./column.bend as Col
import ./component.bend as C
import ./capabilities.bend as Cap

# One ordinary declaration delays both lowerings from the same component binding.
# Operational transaction authority never enters the detached read-only query.
type Declaration<-S:Data,-H:Type,-G:Type,-IH:Type,-V:Data> is Type:
  Declaration{operational:Unit -> N.Declaration<S,H,G>,inspection:Unit -> P.DeclaredSelection<IH,S,V>}
def operational(~S:Data,~H:Type,~G:Type,~IH:Type,~V:Data,declaration:Declaration<S,H,G,IH,V>) -> N.Declaration<S,H,G>:
  match declaration:
    case Declaration{operational,_}:operational(Unit{})
def inspection(~S:Data,~H:Type,~G:Type,~IH:Type,~V:Data,declaration:Declaration<S,H,G,IH,V>) -> P.DeclaredSelection<IH,S,V>:
  match declaration:
    case Declaration{_,inspection}:inspection(Unit{})
def clauses(~S:Data,~H:Type,~G:Type,~IH:Type,~V:Data,declaration:Declaration<S,H,G,IH,V>) -> List<&2,N.Clause<S>>:
  N.clauses(~S,~H,~G,operational(~S,~H,~G,~IH,~V,declaration))

def read(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>,I.Frame<S,Store,R,E>,C.Access<V>>:
  Declaration{_=>(N.read(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(F.inspect_slot(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding,~Families.Required{}))}

def write(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Write<Q.Frame<S,Store,R,E>,Payload,V>,I.Frame<S,Store,R,E>,C.Access<V>>:
  Declaration{_=>(N.write(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(F.inspect_slot(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding,~Families.Required{}))}

def optional(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>,I.Frame<S,Store,R,E>,C.Access<V>>:
  Declaration{_=>(N.optional(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(F.inspect_slot(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding,~Families.Optional{}))}

def with_component(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit,I.Frame<S,Store,R,E>,Unit>:
  Declaration{_=>(N.with_component(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(P.constrain(~I.Frame<S,Store,R,E>,~S,~Unit,~P.empty(~I.Frame<S,Store,R,E>,~S),~F.inspect_with(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding)))}

def without_component(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit,I.Frame<S,Store,R,E>,Unit>:
  Declaration{_=>(N.without_component(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(P.constrain(~I.Frame<S,Store,R,E>,~S,~Unit,~P.empty(~I.Frame<S,Store,R,E>,~S),~F.inspect_without(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding)))}

def added(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit,I.Frame<S,Store,R,E>,Unit>:
  Declaration{_=>(N.added(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(P.constrain(~I.Frame<S,Store,R,E>,~S,~Unit,~P.empty(~I.Frame<S,Store,R,E>,~S),~F.inspect_filter(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding,~Q.Added{})))}

def changed(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit,I.Frame<S,Store,R,E>,Unit>:
  Declaration{_=>(N.changed(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(P.constrain(~I.Frame<S,Store,R,E>,~S,~Unit,~P.empty(~I.Frame<S,Store,R,E>,~S),~F.inspect_filter(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding,~Q.Changed{})))}

def pair(~S:Data,~H:Type,~L:Type,~R:Type,~IH:Type,~LV:Data,~RV:Data,~left:Declaration<S,H,L,IH,LV>,~right:Declaration<S,H,R,IH,RV>) -> Declaration<S,H,L & R,IH,P.Product<LV,RV>>:
  Declaration{_=>(N.pair(~S,~H,~L,~R,~operational(~S,~H,~L,~IH,~LV,left),~operational(~S,~H,~R,~IH,~RV,right))),_=>(P.pair(~IH,~S,~LV,~RV,~inspection(~S,~H,~L,~IH,~LV,left),~inspection(~S,~H,~R,~IH,~RV,right)))}
def inspect_query(~S:Data,~Store:Type,~R:Type,~E:Data,~H:Type,~G:Type,~V:Data,~declaration:Declaration<S,H,G,I.Frame<S,Store,R,E>,V>) -> IQ.ComposedReadQuery<I.Frame<S,Store,R,E>,S,V>:
  IQ.grant_composed(~I.Frame<S,Store,R,E>,~S,~V,~inspection(~S,~H,~G,~I.Frame<S,Store,R,E>,~V,declaration),~IW.inspect_world(~S,~Store,~R,~E))

def write_displayed(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~display:V -> String,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Write<Q.Frame<S,Store,R,E>,Payload,V>,I.Frame<S,Store,R,E>,C.Access<V>>:
  Declaration{_=>(N.write_displayed(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~display,~take,~put)),_=>(F.inspect_slot(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding,~Families.Required{}))}
