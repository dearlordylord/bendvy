import Base
import ./ordinary-binding.bend as B
import ../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../src/ecs/ordinary-query-declaration.bend as D
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/inspector-query.bend as Q
import ../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../src/ecs/column.bend as Col

type Declaration<-S:Data,-H:Type,-V:Data> is Type:
  Declaration{query:Q.ReadQuery<H,S,V>,clauses:List<&2,D.Clause<S>>}
def query(~S:Data,~H:Type,~V:Data,declaration:Declaration<S,H,V>) -> Q.ReadQuery<H,S,V>:
  match declaration:
    case Declaration{query,_}:query
def observe(~S:Data,~H:Type,~V:Data,declaration:Declaration<S,H,V>) -> Declaration<S,H,V> & List<&2,D.Clause<S>>:
  match declaration:
    case Declaration{query,+clauses}:(Declaration{query,clauses},clauses)
def read(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Declaration<S,I.Frame<S,Store,R,E>,V>:
  Declaration{Q.grant(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~B.family(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding),~Projection.Required{}),[]}
def optional(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Declaration<S,I.Frame<S,Store,R,E>,V>:
  Declaration{Q.grant(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~B.family(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding),~Projection.Optional{}),[D.Clause{Identity.key(~S,~P,B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)),D.Optional{}}]}
def added(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Declaration<S,I.Frame<S,Store,R,E>,V>:
  Declaration{Q.grant(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~B.family(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding),~Projection.Added{}),[D.Clause{Identity.key(~S,~P,B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)),D.Added{}}]}
def changed(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Declaration<S,I.Frame<S,Store,R,E>,V>:
  Declaration{Q.grant(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~B.family(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding),~Projection.Changed{}),[D.Clause{Identity.key(~S,~P,B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)),D.Changed{}}]}
