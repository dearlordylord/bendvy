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

# Generic declaration composition; existing single-family API stays compatible.
type ProjectedRow<S:Data,V:Data> is Data:
  ProjectedRow{entity:W.Handle<S>,data:V}
type WorldRead<-H:Type,-S:Data> is Type:
  WorldRead{handles:H -> H & List<&2,W.Handle<S>>,valid:H -> W.Handle<S> -> H & Bool}
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
def each_composed(~H:Type,~S:Data,~V:Data,~cap:ComposedReadQuery<H,S,V>,owner:H) -> H & List<&2,ProjectedRow<S,V>>:
  composed_each_field(~H,~S,~V,cap)(owner)
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
def composed_lookup_matched(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,+target:W.Handle<S>,observed:H & Bool) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  match observed:
    case (owner,False{}):composed_mismatched(~H,~S,~V,target,owner)
    case (owner,True{}):composed_lookup_projected(~H,~S,~V,target,Q.project_field(~H,~S,~V,selection)(owner,target))
def composed_lookup_valid(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,+target:W.Handle<S>,observed:H & Bool) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  match observed:
    case (owner,False{}):composed_missing(~H,~S,~V,target,owner)
    case (owner,True{}):composed_lookup_matched(~H,~S,~V,~selection,target,Q.matches_field(~H,~S,~V,selection)(owner,target))
def lookup_runtime_matched(~H:Type,~S:Data,~V:Data,project:H -> H & V,+target:W.Handle<S>,observed:H & Bool) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  match observed:
    case (owner,False{}):composed_mismatched(~H,~S,~V,target,owner)
    case (owner,True{}):composed_lookup_projected(~H,~S,~V,target,project(owner))
def lookup_runtime_valid(~H:Type,~S:Data,~V:Data,next:H -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>,+target:W.Handle<S>,observed:H & Bool) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  match observed:
    case (owner,False{}):composed_missing(~H,~S,~V,target,owner)
    case (owner,True{}):next(owner)
def composed_lookup_target(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,~world:WorldRead<H,S>,owner:H,+target:W.Handle<S>) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  lookup_runtime_valid(~H,~S,~V,(owner => lookup_runtime_matched(~H,~S,~V,(owner => Q.project_field(~H,~S,~V,selection)(owner,target)),target,Q.matches_field(~H,~S,~V,selection)(owner,target))),target,composed_valid_field(~H,~S,world)(owner,target))
def composed_lookup(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,~world:WorldRead<H,S>,owner:H,target:W.Handle<S>) -> H & Result<&2,&2,LookupError,ProjectedRow<S,V>>:
  composed_lookup_target(~H,~S,~V,~selection,~world,owner,target)

# Private recursive result ABI; public query authority and result types unchanged.
type ScanResult<-H:Type,-S:Data,-V:Data> is Type:
  ScanResult{owner:H,rows:List<&2,ProjectedRow<S,V>>}
  ScanResultLink{next:ScanResult<H,S,V>}
def composed_unwrap_scan(~H:Type,~S:Data,~V:Data,result:ScanResult<H,S,V>) -> H & List<&2,ProjectedRow<S,V>>:
  match result:
    case ScanResult{owner,rows}:(owner,rows)
    case ScanResultLink{next}:composed_unwrap_scan(~H,~S,~V,next)

def composed_scan_projected(~H:Type,~S:Data,~V:Data,target:W.Handle<S>,rows:List<&2,ProjectedRow<S,V>>,continue:H -> List<&2,ProjectedRow<S,V>> -> ScanResult<H,S,V>,observed:H & V) -> ScanResult<H,S,V>:
  (owner,value)=observed
  continue(owner,ProjectedRow{target,value} <> rows)
def composed_scan_matched(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,+target:W.Handle<S>,rows:List<&2,ProjectedRow<S,V>>,continue:H -> List<&2,ProjectedRow<S,V>> -> ScanResult<H,S,V>,observed:H & Bool) -> ScanResult<H,S,V>:
  match observed:
    case (owner,False{}):continue(owner,rows)
    case (owner,True{}):composed_scan_projected(~H,~S,~V,target,rows,continue,Q.project_field(~H,~S,~V,selection)(owner,target))
def composed_scan(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,targets:List<&2,W.Handle<S>>,owner:H,rows:List<&2,ProjectedRow<S,V>>) -> ScanResult<H,S,V>:
  match targets:
    case []:ScanResult{owner,List.reverse(&2,ProjectedRow<S,V>,rows)}
    case +target <> rest:composed_scan_matched(~H,~S,~V,~selection,target,rows,(owner => rows => composed_scan(~H,~S,~V,~selection,rest,owner,rows)),Q.matches_field(~H,~S,~V,selection)(owner,target))

def pair_scan_projected(~H:Type,~S:Data,~V:Data,target:W.Handle<S>,rows:List<&2,ProjectedRow<S,V>>,continue:H -> List<&2,ProjectedRow<S,V>> -> H & List<&2,ProjectedRow<S,V>>,observed:H & V) -> H & List<&2,ProjectedRow<S,V>>:
  (owner,value)=observed
  continue(owner,ProjectedRow{target,value} <> rows)
def pair_scan_matched(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,+target:W.Handle<S>,rows:List<&2,ProjectedRow<S,V>>,continue:H -> List<&2,ProjectedRow<S,V>> -> H & List<&2,ProjectedRow<S,V>>,observed:H & Bool) -> H & List<&2,ProjectedRow<S,V>>:
  match observed:
    case (owner,False{}):continue(owner,rows)
    case (owner,True{}):pair_scan_projected(~H,~S,~V,target,rows,continue,Q.project_field(~H,~S,~V,selection)(owner,target))
def pair_scan(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,targets:List<&2,W.Handle<S>>,owner:H,rows:List<&2,ProjectedRow<S,V>>) -> H & List<&2,ProjectedRow<S,V>>:
  match targets:
    case []:(owner,List.reverse(&2,ProjectedRow<S,V>,rows))
    case +target <> rest:pair_scan_matched(~H,~S,~V,~selection,target,rows,(owner => rows => pair_scan(~H,~S,~V,~selection,rest,owner,rows)),Q.matches_field(~H,~S,~V,selection)(owner,target))

def composed_scanned(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,observed:H & List<&2,W.Handle<S>>) -> H & List<&2,ProjectedRow<S,V>>:
  (owner,targets)=observed
  pair_scan(~H,~S,~V,~selection,targets,owner,[])
def composed_enumerate(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,~world:WorldRead<H,S>,owner:H) -> H & List<&2,ProjectedRow<S,V>>:
  composed_scanned(~H,~S,~V,~selection,composed_handles_field(~H,~S,world)(owner))
def grant_composed(~H:Type,~S:Data,~V:Data,~selection:Q.DeclaredSelection<H,S,V>,~world:WorldRead<H,S>) -> ComposedReadQuery<H,S,V>:
  ComposedReadQuery{owner => composed_enumerate(~H,~S,~V,~selection,~world,owner),owner => target => composed_lookup(~H,~S,~V,~selection,~world,owner,target)}
