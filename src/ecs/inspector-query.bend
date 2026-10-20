import Base
import entity-key.bend as Key
import inspector.bend as I
import inspector-query-projection.bend as Q
import world.bend as W
import component.bend as C
import column.bend as Col
import capabilities.bend as Cap

# Detached query results preserve the abstract owner and nominal entity schema.
# This adapter adds the four methods of pinned System.QueryHandle. It does not
# grant writes, construct a held mutable view, or choose foreign-instance policy.
# Detached lookup refusal: MissingEntity includes dead/stale/foreign handles;
# QueryMismatch means a live entity does not satisfy the declared selection.
# entityId is a key for diagnostics, not a World authority.
type LookupError is Data:
  MissingEntity{entityId:Key.Key}
  QueryMismatch{entityId:Key.Key}
# Cardinality refusal: NoEntities for zero matches, MultipleEntities with
# the actual Nat count for more than one. It carries no live payload owner.
type SingleError is Data:
  NoEntities{}
  MultipleEntities{count:Nat}
# Single-family read-only enumeration/lookup capability with one selection
# mode. Rows are detached Data; raw construction must bind all operations to
# the same family/mode. Runtime instance validation belongs to its outer wrapper.
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
# Enumerate selected detached rows while returning opaque owner H.
# Canonical grants preserve live-handle traversal order and expose no setters.
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
# Look up a target through the same declared selection as enumeration.
# Returns H with Done row, MissingEntity or QueryMismatch. Canonical lookup
# rejects stale/foreign handles before treating absence as optional membership.
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
# Return H and exactly one detached row, or NoEntities/MultipleEntities.
# Does not pick an arbitrary first row when the query matches multiple entities.
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
# Return H and None for zero matches, Some row for one, or MultipleEntities
# for more than one. Empty is a successful result, unlike single.
def single_optional(~H:Type,~S:Data,~V:Data,~cap:ReadQuery<H,S,V>,owner:H) -> H & Result<&2,&2,SingleError,Maybe<&2,Q.Row<S,V>>>:
  optional_observed(~H,~S,~V,each(~H,~S,~V,~cap,owner))

# Trusted setup binds enumeration and exact lookup to the same family/mode.
# Trusted setup binding enumeration and lookup to one component family/mode.
# Projection must return the affine payload owner alongside Data V. Does not
# execute a query or advance registered system cursors while constructing it.
def grant(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,Payload>,~put:Rest -> Col.Column<S,Payload> -> Store,~project:Payload -> Payload & V,~family:C.Family<S,Store,Rest,Payload,V,Token,take,put,project>,~mode:Q.Selection) -> ReadQuery<I.Frame<S,Store,R,E>,S,V>:
  ReadQuery{Q.read_query(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family,~mode),I.read_family(~S,~Store,~R,~E,~Rest,~Payload,~V,~Token,~take,~put,~project,~family),mode}

# Generic declaration composition; existing single-family API stays compatible.
# Detached heterogeneous projection paired with its schema-scoped entity
# handle. Does not contain a mutable view or an affine component owner.
type ProjectedRow<S:Data,V:Data> is Data:
  ProjectedRow{entity:W.Handle<S>,data:V}
# Trusted closed live-handle enumeration/validity operations for composed
# queries. Raw callbacks must correspond to the same runtime World and thread H;
# metadata or schema type alone is not a runtime validation check.
type WorldRead<-H:Type,-S:Data> is Type:
  WorldRead{handles:H -> H & List<&2,W.Handle<S>>,valid:H -> W.Handle<S> -> H & Bool}
# Read-only query over arbitrary declared projection shapes, with matching
# enumeration and target lookup. Owns operations, not a runtime World;
# canonical grants provide checked targets and detached values.
type ComposedReadQuery<-H:Type,-S:Data,-V:Data> is Type:
  ComposedReadQuery{each_composed:H -> H & List<&2,ProjectedRow<S,V>>,get_composed:H -> W.Handle<S> -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>}
def composed_handles_field(~H:Type,~S:Data,value:WorldRead<H,S>) -> H -> H & List<&2,W.Handle<S>>:
  match value:
    case WorldRead{handles,_}:handles
def composed_valid_field(~H:Type,~S:Data,value:WorldRead<H,S>) -> H -> W.Handle<S> -> H & Bool:
  match value:
    case WorldRead{_,valid}:valid
def composed_each_field(~H:Type,~S:Data,~V:Data,value:ComposedReadQuery<H,S,V>) -> H -> H & List<&2,ProjectedRow<S,V>>:
  match value:
    case ComposedReadQuery{each_composed,_}:each_composed
def composed_get_field(~H:Type,~S:Data,~V:Data,value:ComposedReadQuery<H,S,V>) -> H -> W.Handle<S> -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  match value:
    case ComposedReadQuery{_,get_composed}:get_composed
# Enumerate matching projected rows, returning the opaque owner.
# Canonical enumeration preserves its World handle order and projection shape.
def each_composed(~H:Type,~S:Data,~V:Data,~cap:ComposedReadQuery<H,S,V>,owner:H) -> H & List<&2,ProjectedRow<S,V>>:
  composed_each_field(~H,~S,~V,cap)(owner)
# Return H with detached projection or MissingEntity/QueryMismatch.
# The canonical grant checks live target validity before selection/projection;
# no component write operation or payload owner is returned.
def get_composed(~H:Type,~S:Data,~V:Data,~cap:ComposedReadQuery<H,S,V>,owner:H,target:W.Handle<S>) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  composed_get_field(~H,~S,~V,cap)(owner,target)
def composed_single_rows(~S:Data,~V:Data,rows:List<&2,ProjectedRow<S,V>>) -> Result<&2,&2,SingleError,ProjectedRow<S,V>>:
  match rows:
    case []:Fail{NoEntities{}}
    case row <> []:Done{row}
    case _ <> _ <> rest:Fail{MultipleEntities{Nat.add(2n,List.length(&2,ProjectedRow<S,V>,rest))}}
def composed_single_observed(~H:Type,~S:Data,~V:Data,observed:H & List<&2,ProjectedRow<S,V>>) -> H & Result<&2,&2,SingleError,ProjectedRow<S,V>>:
  (owner,rows)=observed
  (owner,composed_single_rows(~S,~V,rows))
# Require exactly one composed row; zero yields NoEntities and multiple
# yields MultipleEntities with full count. Retains owner H on every result.
def single_composed(~H:Type,~S:Data,~V:Data,~cap:ComposedReadQuery<H,S,V>,owner:H) -> H & Result<&2,&2,SingleError,ProjectedRow<S,V>>:
  composed_single_observed(~H,~S,~V,each_composed(~H,~S,~V,~cap,owner))
def composed_optional_rows(~S:Data,~V:Data,rows:List<&2,ProjectedRow<S,V>>) -> Result<&2,&2,SingleError,Maybe<&2,ProjectedRow<S,V>>>:
  match rows:
    case []:Done{None{}}
    case row <> []:Done{Some{row}}
    case _ <> _ <> rest:Fail{MultipleEntities{Nat.add(2n,List.length(&2,ProjectedRow<S,V>,rest))}}
def composed_optional_observed(~H:Type,~S:Data,~V:Data,observed:H & List<&2,ProjectedRow<S,V>>) -> H & Result<&2,&2,SingleError,Maybe<&2,ProjectedRow<S,V>>>:
  (owner,rows)=observed
  (owner,composed_optional_rows(~S,~V,rows))
# Return None for zero composed rows or Some for exactly one; multiple
# matches return MultipleEntities. Retains H and never selects an arbitrary row.
def single_optional_composed(~H:Type,~S:Data,~V:Data,~cap:ComposedReadQuery<H,S,V>,owner:H) -> H & Result<&2,&2,SingleError,Maybe<&2,ProjectedRow<S,V>>>:
  composed_optional_observed(~H,~S,~V,each_composed(~H,~S,~V,~cap,owner))

# One declaration is used for both structural/lifecycle membership paths.
def composed_lookup_projected(~H:Type,~S:Data,~V:Data,target:W.Handle<S>,observed:H & V) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  (owner,value)=observed
  (owner,Done{ProjectedRow{target,value}})
def composed_mismatched(~H:Type,~S:Data,~V:Data,target:W.Handle<S>,owner:H) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  match target:
    case W.Handle{_,id}:(owner,Fail{QueryMismatch{id}})
def composed_missing(~H:Type,~S:Data,~V:Data,target:W.Handle<S>,owner:H) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  match target:
    case W.Handle{_,id}:(owner,Fail{MissingEntity{id}})
def composed_lookup_matched(~H:Type,~S:Data,~V:Data,project:H -> W.Handle<S> -> H & V,+target:W.Handle<S>,observed:H & Bool) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  match observed:
    case (owner,False{}):composed_mismatched(~H,~S,~V,target,owner)
    case (owner,True{}):composed_lookup_projected(~H,~S,~V,target,project(owner,target))
def composed_lookup_valid(~H:Type,~S:Data,~V:Data,matches:H -> W.Handle<S> -> H & Bool,project:H -> W.Handle<S> -> H & V,+target:W.Handle<S>,observed:H & Bool) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  match observed:
    case (owner,False{}):composed_missing(~H,~S,~V,target,owner)
    case (owner,True{}):composed_lookup_matched(~H,~S,~V,project,target,matches(owner,target))
def composed_lookup_target(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,~world:WorldRead<H,S>,owner:H,+target:W.Handle<S>) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  composed_lookup_valid(~H,~S,~V,Q.matches_field(~H,~S,~V,selection),Q.project_field(~H,~S,~V,selection),target,composed_valid_field(~H,~S,world)(owner,target))
def composed_lookup(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,~world:WorldRead<H,S>,owner:H,target:W.Handle<S>) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  composed_lookup_target(~H,~S,~V,~selection,~world,owner,target)

# Private recursive result ABI; public query authority and result types unchanged.
# Advanced scan accumulator result retaining H and detached projected rows.
# This carrier adds no target validation beyond the chosen scan/selection route.
type ScanResult<-H:Type,-S:Data,-V:Data> is Type:
  ScanResult{owner:H,rows:List<&2,ProjectedRow<S,V>>}
  ScanResultLink{next:ScanResult<H,S,V>}
def composed_unwrap_scan(~H:Type,~S:Data,~V:Data,result:ScanResult<H,S,V>) -> H & List<&2,ProjectedRow<S,V>>:
  match result:
    case ScanResult{owner,rows}:(owner,rows)
    case ScanResultLink{next}:composed_unwrap_scan(~H,~S,~V,next)

def composed_fold_projected(~H:Type,~S:Data,~V:Data,target:W.Handle<S>,rows:List<&2,ProjectedRow<S,V>>,observed:H & V) -> H & List<&2,ProjectedRow<S,V>>:
  (owner,value)=observed
  (owner,ProjectedRow{target,value} <> rows)
def composed_fold_matched(~H:Type,~S:Data,~V:Data,~project:H -> W.Handle<S> -> H & V,+target:W.Handle<S>,rows:List<&2,ProjectedRow<S,V>>,observed:H & Bool) -> H & List<&2,ProjectedRow<S,V>>:
  match observed:
    case (owner,False{}):(owner,rows)
    case (owner,True{}):composed_fold_projected(~H,~S,~V,target,rows,project(owner,target))
def composed_fold_step(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,acc:H & List<&2,ProjectedRow<S,V>>,+target:W.Handle<S>) -> H & List<&2,ProjectedRow<S,V>>:
  (owner,rows)=acc
  composed_fold_matched(~H,~S,~V,~Q.project_field(~H,~S,~V,selection),target,rows,Q.matches_field(~H,~S,~V,selection)(owner,target))
def composed_fold_done(~H:Type,~S:Data,~V:Data,observed:H & List<&2,ProjectedRow<S,V>>) -> ScanResult<H,S,V>:
  (owner,rows)=observed
  ScanResult{owner,List.reverse(&2,ProjectedRow<S,V>,rows)}
# Engine scan adapter over supplied targets and a reversed row accumulator.
# Canonical callers supply live targets and an empty initial accumulator.
# This helper does not independently validate arbitrary handles; prefer
# each_composed on a canonical composed grant for application inspection.
def composed_scan(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,targets:List<&2,W.Handle<S>>,owner:H,rows:List<&2,ProjectedRow<S,V>>) -> ScanResult<H,S,V>:
  composed_fold_done(~H,~S,~V,List.foldl(~&2,~W.Handle<S>,~(H & List<&2,ProjectedRow<S,V>>),~(acc => target => composed_fold_step(~H,~S,~V,~selection,acc,target)),targets,(owner,rows)))
def composed_scanned(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,observed:H & List<&2,W.Handle<S>>) -> H & List<&2,ProjectedRow<S,V>>:
  (owner,targets)=observed
  composed_unwrap_scan(~H,~S,~V,composed_scan(~H,~S,~V,~selection,targets,owner,[]))
def composed_enumerate(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,~world:WorldRead<H,S>,owner:H) -> H & List<&2,ProjectedRow<S,V>>:
  composed_scanned(~H,~S,~V,~selection,composed_handles_field(~H,~S,world)(owner))
# Trusted constructor combining matching WorldRead and declared selection.
# Target lookup validates before matching/projecting; enumeration uses the
# supplied live-handle route. Callbacks must preserve owner correspondence.
# Source-level composition: ordinary-query-observable.inspect_query.
def grant_composed(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,~world:WorldRead<H,S>) -> ComposedReadQuery<H,S,V>:
  ComposedReadQuery{owner => composed_enumerate(~H,~S,~V,~selection,~world,owner),owner => target => composed_lookup(~H,~S,~V,~selection,~world,owner,target)}

# Runtime-data composed relation path. Static component authority remains a
# DeclaredSelection Type, while a Data relation argument is shared by the
# query's enumeration and lookup closures. The two static relation workers
# preserve the existing short-circuit and projection order without storing or
# duplicating affine closures.
def composed_runtime_match_right(~H:Type,~S:Data,~A:Data,~Arg:Data,~relation_matches:Arg -> H -> W.Handle<S> -> H & Bool,+target:W.Handle<S>,argument:Arg,observed:H & Bool) -> H & Bool:
  match observed:
    case (owner,False{}):(owner,False{})
    case (owner,True{}):relation_matches(argument,owner,target)
def composed_runtime_matches_target(~H:Type,~S:Data,~A:Data,~Arg:Data,~component:Q.DeclaredSelection<H,S,A>,~relation_matches:Arg -> H -> W.Handle<S> -> H & Bool,+target:W.Handle<S>,argument:Arg,owner:H) -> H & Bool:
  composed_runtime_match_right(~H,~S,~A,~Arg,~relation_matches,target,argument,Q.matches_field(~H,~S,~A,component)(owner,target))
def composed_runtime_projected_right(~H:Type,~A:Data,~B:Data,left:A,observed:H & B) -> H & Q.Product<A,B>:
  (owner,right)=observed
  (owner,Q.Product{left,right})
def composed_runtime_projected_left(~H:Type,~S:Data,~A:Data,~B:Data,~Arg:Data,~relation_project:Arg -> H -> W.Handle<S> -> H & B,+target:W.Handle<S>,argument:Arg,observed:H & A) -> H & Q.Product<A,B>:
  (owner,left)=observed
  composed_runtime_projected_right(~H,~A,~B,left,relation_project(argument,owner,target))
def composed_runtime_project(~H:Type,~S:Data,~A:Data,~B:Data,~Arg:Data,~component:Q.DeclaredSelection<H,S,A>,~relation_project:Arg -> H -> W.Handle<S> -> H & B,+target:W.Handle<S>,argument:Arg,owner:H) -> H & Q.Product<A,B>:
  composed_runtime_projected_left(~H,~S,~A,~B,~Arg,~relation_project,target,argument,Q.project_field(~H,~S,~A,component)(owner,target))
def composed_runtime_scan_projected(~H:Type,~S:Data,~A:Data,~B:Data,+target:W.Handle<S>,rows:List<&2,ProjectedRow<S,Q.Product<A,B>>>,continue:H -> List<&2,ProjectedRow<S,Q.Product<A,B>>> -> ScanResult<H,S,Q.Product<A,B>>,observed:H & Q.Product<A,B>) -> ScanResult<H,S,Q.Product<A,B>>:
  (owner,value)=observed
  continue(owner,ProjectedRow{target,value} <> rows)
def composed_runtime_scan_matched(~H:Type,~S:Data,~A:Data,~B:Data,~Arg:Data,~component:Q.DeclaredSelection<H,S,A>,~relation_matches:Arg -> H -> W.Handle<S> -> H & Bool,~relation_project:Arg -> H -> W.Handle<S> -> H & B,+target:W.Handle<S>,rows:List<&2,ProjectedRow<S,Q.Product<A,B>>>,continue:H -> List<&2,ProjectedRow<S,Q.Product<A,B>>> -> ScanResult<H,S,Q.Product<A,B>>,argument:Arg,observed:H & Bool) -> ScanResult<H,S,Q.Product<A,B>>:
  match observed:
    case (owner,False{}):continue(owner,rows)
    case (owner,True{}):composed_runtime_scan_projected(~H,~S,~A,~B,target,rows,continue,composed_runtime_project(~H,~S,~A,~B,~Arg,~component,~relation_project,target,argument,owner))
def composed_runtime_scan(~H:Type,~S:Data,~A:Data,~B:Data,~Arg:Data,~component:Q.DeclaredSelection<H,S,A>,~relation_matches:Arg -> H -> W.Handle<S> -> H & Bool,~relation_project:Arg -> H -> W.Handle<S> -> H & B,targets:List<&2,W.Handle<S>>,+argument:Arg,owner:H,rows:List<&2,ProjectedRow<S,Q.Product<A,B>>>) -> ScanResult<H,S,Q.Product<A,B>>:
  match targets:
    case []:ScanResult{owner,List.reverse(&2,ProjectedRow<S,Q.Product<A,B>>,rows)}
    case +target <> rest:composed_runtime_scan_matched(~H,~S,~A,~B,~Arg,~component,~relation_matches,~relation_project,target,rows,(owner => rows => composed_runtime_scan(~H,~S,~A,~B,~Arg,~component,~relation_matches,~relation_project,rest,argument,owner,rows)),argument,composed_runtime_matches_target(~H,~S,~A,~Arg,~component,~relation_matches,target,argument,owner))
def composed_runtime_scanned(~H:Type,~S:Data,~A:Data,~B:Data,~Arg:Data,~component:Q.DeclaredSelection<H,S,A>,~relation_matches:Arg -> H -> W.Handle<S> -> H & Bool,~relation_project:Arg -> H -> W.Handle<S> -> H & B,observed:H & List<&2,W.Handle<S>>,+argument:Arg) -> H & List<&2,ProjectedRow<S,Q.Product<A,B>>>:
  (owner,targets)=observed
  composed_unwrap_scan(~H,~S,~Q.Product<A,B>,composed_runtime_scan(~H,~S,~A,~B,~Arg,~component,~relation_matches,~relation_project,targets,argument,owner,[]))
def composed_runtime_enumerate(~H:Type,~S:Data,~A:Data,~B:Data,~Arg:Data,~component:Q.DeclaredSelection<H,S,A>,~relation_matches:Arg -> H -> W.Handle<S> -> H & Bool,~relation_project:Arg -> H -> W.Handle<S> -> H & B,~world:WorldRead<H,S>,argument:Arg,owner:H) -> H & List<&2,ProjectedRow<S,Q.Product<A,B>>>:
  composed_runtime_scanned(~H,~S,~A,~B,~Arg,~component,~relation_matches,~relation_project,composed_handles_field(~H,~S,world)(owner),argument)
def composed_runtime_lookup_selected(~H:Type,~S:Data,~A:Data,~B:Data,~Arg:Data,~component:Q.DeclaredSelection<H,S,A>,~relation_project:Arg -> H -> W.Handle<S> -> H & B,+target:W.Handle<S>,argument:Arg,observed:H & Bool) -> H & Result<&2,&2,LookupError,ProjectedRow<S,Q.Product<A,B>>>:
  match observed:
    case (owner,False{}):composed_mismatched(~H,~S,~Q.Product<A,B>,target,owner)
    case (owner,True{}):composed_lookup_projected(~H,~S,~Q.Product<A,B>,target,composed_runtime_project(~H,~S,~A,~B,~Arg,~component,~relation_project,target,argument,owner))
def composed_runtime_lookup_valid(~H:Type,~S:Data,~A:Data,~B:Data,~Arg:Data,~component:Q.DeclaredSelection<H,S,A>,~relation_matches:Arg -> H -> W.Handle<S> -> H & Bool,~relation_project:Arg -> H -> W.Handle<S> -> H & B,+target:W.Handle<S>,+argument:Arg,observed:H & Bool) -> H & Result<&2,&2,LookupError,ProjectedRow<S,Q.Product<A,B>>>:
  match observed:
    case (owner,False{}):composed_missing(~H,~S,~Q.Product<A,B>,target,owner)
    case (owner,True{}):composed_runtime_lookup_selected(~H,~S,~A,~B,~Arg,~component,~relation_project,target,argument,composed_runtime_matches_target(~H,~S,~A,~Arg,~component,~relation_matches,target,argument,owner))
def composed_runtime_lookup_target(~H:Type,~S:Data,~A:Data,~B:Data,~Arg:Data,~component:Q.DeclaredSelection<H,S,A>,~relation_matches:Arg -> H -> W.Handle<S> -> H & Bool,~relation_project:Arg -> H -> W.Handle<S> -> H & B,~world:WorldRead<H,S>,owner:H,+target:W.Handle<S>,argument:Arg) -> H & Result<&2,&2,LookupError,ProjectedRow<S,Q.Product<A,B>>>:
  composed_runtime_lookup_valid(~H,~S,~A,~B,~Arg,~component,~relation_matches,~relation_project,target,argument,composed_valid_field(~H,~S,world)(owner,target))
def composed_runtime_lookup(~H:Type,~S:Data,~A:Data,~B:Data,~Arg:Data,~component:Q.DeclaredSelection<H,S,A>,~relation_matches:Arg -> H -> W.Handle<S> -> H & Bool,~relation_project:Arg -> H -> W.Handle<S> -> H & B,~world:WorldRead<H,S>,owner:H,target:W.Handle<S>,argument:Arg) -> H & Result<&2,&2,LookupError,ProjectedRow<S,Q.Product<A,B>>>:
  composed_runtime_lookup_target(~H,~S,~A,~B,~Arg,~component,~relation_matches,~relation_project,~world,owner,target,argument)
# Advanced composed query adding a runtime argument/relation selection to
# the component projection. Retains H while combining detached results; trusted
# World and selection callbacks must refer to the same runtime. Does not
# register a reader, consume a system cursor or expose mutation authority.
def grant_composed_runtime(~H:Type,~S:Data,~A:Data,~B:Data,~Arg:Data,~component:Q.DeclaredSelection<H,S,A>,~world:WorldRead<H,S>,~relation_matches:Arg -> H -> W.Handle<S> -> H & Bool,~relation_project:Arg -> H -> W.Handle<S> -> H & B,+argument:Arg) -> ComposedReadQuery<H,S,Q.Product<A,B>>:
  ComposedReadQuery{owner => composed_runtime_enumerate(~H,~S,~A,~B,~Arg,~component,~relation_matches,~relation_project,~world,argument,owner),owner => target => composed_runtime_lookup(~H,~S,~A,~B,~Arg,~component,~relation_matches,~relation_project,~world,owner,target,argument)}
