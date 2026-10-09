import Base
import inspector.bend as I
import inspector-query-projection.bend as Q
import world.bend as W
import component.bend as C
import column.bend as Col
import capabilities.bend as Cap

# Detached query results preserve the abstract owner and nominal entity schema.
# This adapter adds the four methods of pinned System.QueryHandle. It does not
# grant writes, construct a held mutable view, or choose foreign-instance policy.
type LookupError is Data:
  MissingEntity{entityId:U32}
  QueryMismatch{entityId:U32}
type SingleError is Data:
  NoEntities{}
  MultipleEntities{count:Nat}
type ReadQuery<-H:Type,-S:Data,-V:Data> is Type:
  ReadQuery{rows:Cap.ValueRead<H,List<&2,Q.Row<S,V>>>,lookup:I.Lookup<H,S,V>,selection:Q.Selection}

def rows_field(~H:Type,~S:Data,~V:Data,cap:ReadQuery<H,S,V>) -> Cap.ValueRead<H,List<&2,Q.Row<S,V>>>:
  match cap:
    case ReadQuery{rows,_,_}:rows
def lookup_field(~H:Type,~S:Data,~V:Data,cap:ReadQuery<H,S,V>) -> I.Lookup<H,S,V>:
  match cap:
    case ReadQuery{_,lookup,_}:lookup
def selection_field(~H:Type,~S:Data,~V:Data,cap:ReadQuery<H,S,V>) -> Q.Selection:
  match cap:
    case ReadQuery{_,_,selection}:selection
def each(~H:Type,~S:Data,~V:Data,~cap:ReadQuery<H,S,V>,owner:H) -> H & List<&2,Q.Row<S,V>>:
  Cap.value_read(~H,~List<&2,Q.Row<S,V>>,~rows_field(~H,~S,~V,cap),owner)

def selected(~S:Data,~V:Data,accepted:Bool,+target:W.Handle<S>,value:I.Value<V>) -> Result<&2,&2,LookupError,Q.Row<S,V>>:
  match accepted target:
    case True{} target:Done{Q.Row{target,value}}
    case False{} W.Handle{_,id}:Fail{QueryMismatch{id}}
def resolved(~S:Data,~V:Data,selection:Q.Selection,+target:W.Handle<S>,value:I.Value<V>) -> Result<&2,&2,LookupError,Q.Row<S,V>>:
  match target value:
    case W.Handle{_,id} I.Value{C.MissingEntity{},_,_}:Fail{MissingEntity{id}}
    case target +value:selected(~S,~V,Q.accepts(~V,selection,value),target,value)
def got(~H:Type,~S:Data,~V:Data,selection:Q.Selection,target:W.Handle<S>,result:H & I.Value<V>) -> H & Result<&2,&2,LookupError,Q.Row<S,V>>:
  (owner,value)=result
  (owner,resolved(~S,~V,selection,target,value))
def get(~H:Type,~S:Data,~V:Data,~cap:ReadQuery<H,S,V>,owner:H,+target:W.Handle<S>) -> H & Result<&2,&2,LookupError,Q.Row<S,V>>:
  got(~H,~S,~V,selection_field(~H,~S,~V,cap),target,I.lookup(~H,~S,~V,~lookup_field(~H,~S,~V,cap),owner,target))

def single_rows(~S:Data,~V:Data,rows:List<&2,Q.Row<S,V>>) -> Result<&2,&2,SingleError,Q.Row<S,V>>:
  match rows:
    case []:Fail{NoEntities{}}
    case row <> []:Done{row}
    case _ <> _ <> rest:Fail{MultipleEntities{Nat.add(2n,List.length(&2,Q.Row<S,V>,rest))}}
def single_observed(~H:Type,~S:Data,~V:Data,result:H & List<&2,Q.Row<S,V>>) -> H & Result<&2,&2,SingleError,Q.Row<S,V>>:
  (owner,rows)=result
  (owner,single_rows(~S,~V,rows))
def single(~H:Type,~S:Data,~V:Data,~cap:ReadQuery<H,S,V>,owner:H) -> H & Result<&2,&2,SingleError,Q.Row<S,V>>:
  single_observed(~H,~S,~V,each(~H,~S,~V,~cap,owner))
def optional_rows(~S:Data,~V:Data,rows:List<&2,Q.Row<S,V>>) -> Result<&2,&2,SingleError,Maybe<&2,Q.Row<S,V>>>:
  match rows:
    case []:Done{None{}}
    case row <> []:Done{Some{row}}
    case _ <> _ <> rest:Fail{MultipleEntities{Nat.add(2n,List.length(&2,Q.Row<S,V>,rest))}}
def optional_observed(~H:Type,~S:Data,~V:Data,result:H & List<&2,Q.Row<S,V>>) -> H & Result<&2,&2,SingleError,Maybe<&2,Q.Row<S,V>>>:
  (owner,rows)=result
  (owner,optional_rows(~S,~V,rows))
def single_optional(~H:Type,~S:Data,~V:Data,~cap:ReadQuery<H,S,V>,owner:H) -> H & Result<&2,&2,SingleError,Maybe<&2,Q.Row<S,V>>>:
  optional_observed(~H,~S,~V,each(~H,~S,~V,~cap,owner))

# Trusted setup binds enumeration and exact lookup to the same family/mode.
def grant(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:Q.Selection) -> ReadQuery<I.Frame<S,Store,R,E>,S,V>:
  ReadQuery{Q.read_query(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,~mode),I.read_family(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family),mode}
