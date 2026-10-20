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
# One query declaration supplies operational grants and detached inspection
# from the same bindings. Declaration uses the ordinary evaluator; the
# PreparedDeclaration variant also supplies an enumeration callback. Raw
# constructors are trusted adapters. Payload owners never enter detached V.
type Declaration<-S:Data,-H:Type,-G:Type,-IH:Type,-V:Data> is Type:
  Declaration{operational:Unit -> N.Declaration<S,H,G>,inspection:Unit -> P.DeclaredSelection<IH,S,V>}
  PreparedDeclaration{operational:Unit -> N.Declaration<S,H,G>,inspection:Unit -> P.DeclaredSelection<IH,S,V>,enumerate:IH -> IH & List<&2,IQ.ProjectedRow<S,V>>}
# Consume the observable declaration and obtain its typed operational query.
# Does not enumerate rows or run a body; H remains the operational owner type.
def operational(~S:Data,~H:Type,~G:Type,~IH:Type,~V:Data,declaration:Declaration<S,H,G,IH,V>) -> N.Declaration<S,H,G>:
  match declaration:
    case Declaration{operational,_}:operational(Unit{})
    case PreparedDeclaration{operational,_,_}:operational(Unit{})
# Consume the declaration and obtain its detached read-only selection recipe.
# IH is separate from operational H; no write grant is transferred to inspection.
def inspection(~S:Data,~H:Type,~G:Type,~IH:Type,~V:Data,declaration:Declaration<S,H,G,IH,V>) -> P.DeclaredSelection<IH,S,V>:
  match declaration:
    case Declaration{_,inspection}:inspection(Unit{})
    case PreparedDeclaration{_,inspection,_}:inspection(Unit{})
# Return declaration-derived query clauses for access/debug descriptions.
# Consumes this declaration value, without inspecting or modifying a world.
def clauses(~S:Data,~H:Type,~G:Type,~IH:Type,~V:Data,declaration:Declaration<S,H,G,IH,V>) -> List<&2,N.Clause<S>>:
  N.clauses(~S,~H,~G,operational(~S,~H,~G,~IH,~V,declaration))

# Declare required component read access and the matching detached inspection.
# The trusted binding fixes schema and storage lenses. view consumes/returns
# Payload and exposes Data V; operational results are Found/ComponentAbsent/
# MissingEntity, including stale/foreign rejection. No row is read at setup.
def read(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>,I.Frame<S,Store,R,E>,C.Access<V>>:
  Declaration{_=>(N.read(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(F.inspect_slot(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding,~Families.Required{}))}

# Declare required component read/write access with read-only inspection.
# Writes consume replacement Payload; failed sets record an error for enclosing
# Compose execution/rollback and do not return rejected input through the grant.
# Detached inspection exposes only V and never authorizes a write.
def write(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Write<Q.Frame<S,Store,R,E>,Payload,V>,I.Frame<S,Store,R,E>,C.Access<V>>:
  Declaration{_=>(N.write(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(F.inspect_slot(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding,~Families.Required{}))}

# Declare read access without requiring component presence on a live row.
# Operational and detached selections preserve absence explicitly; stale/foreign
# handles remain MissingEntity rather than matching as optional live rows.
def optional(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Read<Q.Frame<S,Store,R,E>,V>,I.Frame<S,Store,R,E>,C.Access<V>>:
  Declaration{_=>(N.optional(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(F.inspect_slot(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding,~Families.Optional{}))}

# Require presence without granting payload operations; detached projection
# contributes Unit. Combine with pair for additional independently granted data.
def with_component(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit,I.Frame<S,Store,R,E>,Unit>:
  Declaration{_=>(N.with_component(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(P.constrain(~I.Frame<S,Store,R,E>,~S,~Unit,~P.empty(~I.Frame<S,Store,R,E>,~S),~F.inspect_with(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding)))}

# Require absence without granting payload operations; detached projection
# contributes Unit. Structural membership changes at explicit barriers.
def without_component(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit,I.Frame<S,Store,R,E>,Unit>:
  Declaration{_=>(N.without_component(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(P.constrain(~I.Frame<S,Store,R,E>,~S,~Unit,~P.empty(~I.Frame<S,Store,R,E>,~S),~F.inspect_without(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding)))}

# Add a lifecycle filter without payload access; inspection uses its supplied
# cursor and operational execution uses the registered system cursor. Merely
# constructing or inspecting this declaration advances neither system cursor.
def added(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit,I.Frame<S,Store,R,E>,Unit>:
  Declaration{_=>(N.added(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(P.constrain(~I.Frame<S,Store,R,E>,~S,~Unit,~P.empty(~I.Frame<S,Store,R,E>,~S),~F.inspect_filter(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding,~Q.Added{})))}

# Add a changed-since-cursor filter without payload access. The operational
# and Inspector owners retain separate cursor authority; declaration construction
# and detached inspection do not consume registered system visibility.
def changed(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Unit,I.Frame<S,Store,R,E>,Unit>:
  Declaration{_=>(N.changed(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~take,~put)),_=>(P.constrain(~I.Frame<S,Store,R,E>,~S,~Unit,~P.empty(~I.Frame<S,Store,R,E>,~S),~F.inspect_filter(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding,~Q.Changed{})))}

# Compose conjunctive selections from the same schema and owner types.
# Operational grants retain (L & R), detached values Product<LV,RV>, and clause
# order is left then right. Nest pairs for arbitrary heterogeneous shapes.
# Example: examples/scheduled-health/registration.bend, query().
def pair(~S:Data,~H:Type,~L:Type,~R:Type,~IH:Type,~LV:Data,~RV:Data,~left:Declaration<S,H,L,IH,LV>,~right:Declaration<S,H,R,IH,RV>) -> Declaration<S,H,L & R,IH,P.Product<LV,RV>>:
  Declaration{_=>(N.pair(~S,~H,~L,~R,~operational(~S,~H,~L,~IH,~LV,left),~operational(~S,~H,~R,~IH,~RV,right))),_=>(P.pair(~IH,~S,~LV,~RV,~inspection(~S,~H,~L,~IH,~LV,left),~inspection(~S,~H,~R,~IH,~RV,right)))}
def prepared_query(~S:Data,~Store:Type,~R:Type,~E:Data,~V:Data,~selection:P.DeclaredSelection<I.Frame<S,Store,R,E>,S,V>,enumerate:I.Frame<S,Store,R,E> -> I.Frame<S,Store,R,E> & List<&2,IQ.ProjectedRow<S,V>>) -> IQ.ComposedReadQuery<I.Frame<S,Store,R,E>,S,V>:
  IQ.ComposedReadQuery{enumerate,owner=>target=>IQ.get_composed(~I.Frame<S,Store,R,E>,~S,~V,~IQ.grant_composed(~I.Frame<S,Store,R,E>,~S,~V,~selection,~IW.inspect_world(~S,~Store,~R,~E)),owner,target)}
def inspect_query_value(~S:Data,~Store:Type,~R:Type,~E:Data,~H:Type,~G:Type,~V:Data,~declaration:Declaration<S,H,G,I.Frame<S,Store,R,E>,V>,kind:Declaration<S,H,G,I.Frame<S,Store,R,E>,V>) -> IQ.ComposedReadQuery<I.Frame<S,Store,R,E>,S,V>:
  match kind:
    case Declaration{_,_}:IQ.grant_composed(~I.Frame<S,Store,R,E>,~S,~V,~inspection(~S,~H,~G,~I.Frame<S,Store,R,E>,~V,declaration),~IW.inspect_world(~S,~Store,~R,~E))
    case PreparedDeclaration{_,_,enumerate}:prepared_query(~S,~Store,~R,~E,~V,~inspection(~S,~H,~G,~I.Frame<S,Store,R,E>,~V,declaration),enumerate)
# Lower this observable declaration into an Inspector composed read query.
# Preserves prepared enumeration when present; supplies no write operations.
# Run it with the public Inspector owner, not a registered system owner, so
# detached observations do not consume system cursors or event retention.
def inspect_query(~S:Data,~Store:Type,~R:Type,~E:Data,~H:Type,~G:Type,~V:Data,~declaration:Declaration<S,H,G,I.Frame<S,Store,R,E>,V>) -> IQ.ComposedReadQuery<I.Frame<S,Store,R,E>,S,V>:
  inspect_query_value(~S,~Store,~R,~E,~H,~G,~V,~declaration,declaration)

# Declare write access plus a formatter for detached Data V in enabled debug.
# Formatter receives no Payload owner; transaction/refusal semantics match write.
# Inspection remains read-only even though the operational grant permits writes.
def write_displayed(~S:Data,~Store:Type,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~view:Payload -> Payload & V,~R:Type,~E:Data,~display:V -> String,~binding:B.Binding<S,Store,Rest,Payload,V,Token,take,put,view>) -> Declaration<S,Q.Frame<S,Store,R,E>,Cap.Write<Q.Frame<S,Store,R,E>,Payload,V>,I.Frame<S,Store,R,E>,C.Access<V>>:
  Declaration{_=>(N.write_displayed(~S,~Payload,~Store,~R,~E,~Rest,~V,~Token,~B.identity(~S,~Store,~Rest,~Payload,~V,~Token,~take,~put,~view,binding),~view,~display,~take,~put)),_=>(F.inspect_slot(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~view,~binding,~Families.Required{}))}
