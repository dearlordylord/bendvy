import Base
import ./ordinary-component-binding.bend as B
import ./ordinary-declaration.bend as Identity
import ./ordinary-query-declaration.bend as D
import ./inspector.bend as I
import ./inspector-query.bend as Q
import ./inspector-query-projection.bend as Projection
import ./column.bend as Col
import ./inspector-query-projection.bend as Rows

# Ordinary read-only Inspector query plus clauses from the same binding.
# Retains no World or registered reader; raw construction is trusted setup.
type Declaration<-S:Data,-H:Type,-V:Data> is Type:
  Declaration{query:Q.ReadQuery<H,S,V>,clauses:List<&2,D.Clause<S>>}
# Consume this declaration to obtain its typed read-query capability.
# Does not enumerate rows or advance an observation/system cursor.
def query(~S:Data,~H:Type,~V:Data,declaration:Declaration<S,H,V>) -> Q.ReadQuery<H,S,V>:
  match declaration:
    case Declaration{query,_}:query
# Return declaration and detached clauses without accessing World or
# reading components. Prefer this when retaining the declaration owner.
def observe(~S:Data,~H:Type,~V:Data,declaration:Declaration<S,H,V>) -> Declaration<S,H,V> & List<&2,D.Clause<S>>:
  match declaration:
    case Declaration{query,+clauses}:(Declaration{query,clauses},clauses)
# Build required component inspection from its operational binding.
# Derives read grant and clauses together; view preserves P while exposing V.
def read(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Declaration<S,I.Frame<S,Store,R,E>,V>:
  Declaration{Q.grant(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~B.family(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding),~Projection.Required{}),[D.Clause{Identity.key(~S,~P,B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)),D.Read{}}]}
# Build optional component inspection, preserving explicit absence for a
# live entity. Canonical lookup still rejects stale/foreign handles.
def optional(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Declaration<S,I.Frame<S,Store,R,E>,V>:
  Declaration{Q.grant(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~B.family(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding),~Projection.Optional{}),[D.Clause{Identity.key(~S,~P,B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)),D.Optional{}}]}
# Build a presence-plus-added filter using Inspector cursor visibility.
# Does not consume registered system lifecycle/event cursors during setup.
def added(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Declaration<S,I.Frame<S,Store,R,E>,V>:
  Declaration{Q.grant(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~B.family(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding),~Projection.Added{}),[D.Clause{Identity.key(~S,~P,B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)),D.Added{}}]}
# Build a presence-plus-changed filter relative to the Inspector cursor.
# Operational binding and descriptive clauses share one source of truth.
def changed(~S:Data,~Store:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> Store,~view:P -> P & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,P,V,Token,take,put,view>) -> Declaration<S,I.Frame<S,Store,R,E>,V>:
  Declaration{Q.grant(~S,~Store,~R,~E,~Rest,~P,~V,~Token,~take,~put,~view,~B.family(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding),~Projection.Changed{}),[D.Clause{Identity.key(~S,~P,B.identity(~S,~Store,~Rest,~P,~V,~Token,~take,~put,~view,binding)),D.Changed{}}]}
# Consume declaration to obtain its detached query description, with no
# component read, registration execution or cursor change.
def clauses(~S:Data,~H:Type,~V:Data,declaration:Declaration<S,H,V>) -> List<&2,D.Clause<S>>:
  match declaration:
    case Declaration{_,clauses}:clauses
def each_result(~S:Data,~H:Type,~V:Data,clauses:List<&2,D.Clause<S>>,result:H & List<&2,Rows.Row<S,V>>) -> H & (List<&2,Rows.Row<S,V>> & List<&2,D.Clause<S>>):
  match result:
    case (owner,rows):(owner,(rows,clauses))
# Execute the declared read-only enumeration, returning owner, detached rows
# and retained clauses. Uses the matching Inspector grant; no mutable payload
# alias or registered system reader ownership escapes.
def each(~S:Data,~H:Type,~V:Data,~declaration:Declaration<S,H,V>,owner:H) -> H & (List<&2,Rows.Row<S,V>> & List<&2,D.Clause<S>>):
  each_result(~S,~H,~V,clauses(~S,~H,~V,declaration),Q.each(~H,~S,~V,~query(~S,~H,~V,declaration),owner))
