import Base
import selection.bend as D
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/inspector-query.bend as Errors

type Row<S:Data,V:Data> is Data:
  Row{entity:W.Handle<S>,data:V}
type WorldRead<-H:Type,-S:Data> is Type:
  WorldRead{handles:H -> H & List<&2,W.Handle<S>>,valid:H -> W.Handle<S> -> H & Bool}
type ReadQuery<-H:Type,-S:Data,-V:Data> is Type:
  ReadQuery{each:H -> H & List<&2,Row<S,V>>,get:H -> W.Handle<S> -> H & Result<&2,&2,Errors.LookupError,Row<S,V>>}
def handles_field(~H:Type,~S:Data,value:WorldRead<H,S>) -> H -> H & List<&2,W.Handle<S>>:
  match value:
    case WorldRead{handles,_}:handles
def valid_field(~H:Type,~S:Data,value:WorldRead<H,S>) -> H -> W.Handle<S> -> H & Bool:
  match value:
    case WorldRead{_,valid}:valid
def each_field(~H:Type,~S:Data,~V:Data,value:ReadQuery<H,S,V>) -> H -> H & List<&2,Row<S,V>>:
  match value:
    case ReadQuery{each,_}:each
def get_field(~H:Type,~S:Data,~V:Data,value:ReadQuery<H,S,V>) -> H -> W.Handle<S> -> H & Result<&2,&2,Errors.LookupError,Row<S,V>>:
  match value:
    case ReadQuery{_,get}:get
def each(~H:Type,~S:Data,~V:Data,~cap:ReadQuery<H,S,V>,owner:H) -> H & List<&2,Row<S,V>>:
  each_field(~H,~S,~V,cap)(owner)
def get(~H:Type,~S:Data,~V:Data,~cap:ReadQuery<H,S,V>,owner:H,target:W.Handle<S>) -> H & Result<&2,&2,Errors.LookupError,Row<S,V>>:
  get_field(~H,~S,~V,cap)(owner,target)
def single_rows(~S:Data,~V:Data,rows:List<&2,Row<S,V>>) -> Result<&2,&2,Errors.SingleError,Row<S,V>>:
  match rows:
    case []:Fail{Errors.NoEntities{}}
    case row <> []:Done{row}
    case _ <> _ <> rest:Fail{Errors.MultipleEntities{Nat.add(2n,List.length(&2,Row<S,V>,rest))}}
def single_observed(~H:Type,~S:Data,~V:Data,observed:H & List<&2,Row<S,V>>) -> H & Result<&2,&2,Errors.SingleError,Row<S,V>>:
  (owner,rows)=observed
  (owner,single_rows(~S,~V,rows))
def single(~H:Type,~S:Data,~V:Data,~cap:ReadQuery<H,S,V>,owner:H) -> H & Result<&2,&2,Errors.SingleError,Row<S,V>>:
  single_observed(~H,~S,~V,each(~H,~S,~V,~cap,owner))
def optional_rows(~S:Data,~V:Data,rows:List<&2,Row<S,V>>) -> Result<&2,&2,Errors.SingleError,Maybe<&2,Row<S,V>>>:
  match rows:
    case []:Done{None{}}
    case row <> []:Done{Some{row}}
    case _ <> _ <> rest:Fail{Errors.MultipleEntities{Nat.add(2n,List.length(&2,Row<S,V>,rest))}}
def optional_observed(~H:Type,~S:Data,~V:Data,observed:H & List<&2,Row<S,V>>) -> H & Result<&2,&2,Errors.SingleError,Maybe<&2,Row<S,V>>>:
  (owner,rows)=observed
  (owner,optional_rows(~S,~V,rows))
def single_optional(~H:Type,~S:Data,~V:Data,~cap:ReadQuery<H,S,V>,owner:H) -> H & Result<&2,&2,Errors.SingleError,Maybe<&2,Row<S,V>>>:
  optional_observed(~H,~S,~V,each(~H,~S,~V,~cap,owner))

# One declaration is used for both structural/lifecycle membership paths.
def lookup_projected(~H:Type,~S:Data,~V:Data,target:W.Handle<S>,observed:H & V) -> H & Result<&2,&2,Errors.LookupError,Row<S,V>>:
  (owner,value)=observed
  (owner,Done{Row{target,value}})
def mismatched(~H:Type,~S:Data,~V:Data,target:W.Handle<S>,owner:H) -> H & Result<&2,&2,Errors.LookupError,Row<S,V>>:
  match target:
    case W.Handle{_,id}:(owner,Fail{Errors.QueryMismatch{id}})
def missing(~H:Type,~S:Data,~V:Data,target:W.Handle<S>,owner:H) -> H & Result<&2,&2,Errors.LookupError,Row<S,V>>:
  match target:
    case W.Handle{_,id}:(owner,Fail{Errors.MissingEntity{id}})
def lookup_matched(~H:Type,~S:Data,~V:Data,~selection:D.Selection<H,S,V>,+target:W.Handle<S>,observed:H & Bool) -> H & Result<&2,&2,Errors.LookupError,Row<S,V>>:
  match observed:
    case (owner,False{}):mismatched(~H,~S,~V,target,owner)
    case (owner,True{}):lookup_projected(~H,~S,~V,target,D.project_field(~H,~S,~V,selection)(owner,target))
def lookup_valid(~H:Type,~S:Data,~V:Data,~selection:D.Selection<H,S,V>,+target:W.Handle<S>,observed:H & Bool) -> H & Result<&2,&2,Errors.LookupError,Row<S,V>>:
  match observed:
    case (owner,False{}):missing(~H,~S,~V,target,owner)
    case (owner,True{}):lookup_matched(~H,~S,~V,~selection,target,D.matches_field(~H,~S,~V,selection)(owner,target))
def lookup_target(~H:Type,~S:Data,~V:Data,~selection:D.Selection<H,S,V>,~world:WorldRead<H,S>,owner:H,+target:W.Handle<S>) -> H & Result<&2,&2,Errors.LookupError,Row<S,V>>:
  lookup_valid(~H,~S,~V,~selection,target,valid_field(~H,~S,world)(owner,target))
def lookup(~H:Type,~S:Data,~V:Data,~selection:D.Selection<H,S,V>,~world:WorldRead<H,S>,owner:H,target:W.Handle<S>) -> H & Result<&2,&2,Errors.LookupError,Row<S,V>>:
  lookup_target(~H,~S,~V,~selection,~world,owner,target)

# Private recursive result ABI; public query authority and result types unchanged.
type ScanResult<-H:Type,-S:Data,-V:Data> is Type:
  ScanResult{owner:H,rows:List<&2,Row<S,V>>}
  ScanResultLink{next:ScanResult<H,S,V>}
def unwrap_scan(~H:Type,~S:Data,~V:Data,result:ScanResult<H,S,V>) -> H & List<&2,Row<S,V>>:
  match result:
    case ScanResult{owner,rows}:(owner,rows)
    case ScanResultLink{next}:unwrap_scan(~H,~S,~V,next)

def scan_projected(~H:Type,~S:Data,~V:Data,target:W.Handle<S>,rows:List<&2,Row<S,V>>,continue:H -> List<&2,Row<S,V>> -> ScanResult<H,S,V>,observed:H & V) -> ScanResult<H,S,V>:
  (owner,value)=observed
  continue(owner,Row{target,value} <> rows)
def scan_matched(~H:Type,~S:Data,~V:Data,~selection:D.Selection<H,S,V>,+target:W.Handle<S>,rows:List<&2,Row<S,V>>,continue:H -> List<&2,Row<S,V>> -> ScanResult<H,S,V>,observed:H & Bool) -> ScanResult<H,S,V>:
  match observed:
    case (owner,False{}):continue(owner,rows)
    case (owner,True{}):scan_projected(~H,~S,~V,target,rows,continue,D.project_field(~H,~S,~V,selection)(owner,target))
def scan(~H:Type,~S:Data,~V:Data,~selection:D.Selection<H,S,V>,targets:List<&2,W.Handle<S>>,owner:H,rows:List<&2,Row<S,V>>) -> ScanResult<H,S,V>:
  match targets:
    case []:ScanResult{owner,List.reverse(&2,Row<S,V>,rows)}
    case +target <> rest:scan_matched(~H,~S,~V,~selection,target,rows,(owner => rows => scan(~H,~S,~V,~selection,rest,owner,rows)),D.matches_field(~H,~S,~V,selection)(owner,target))
def scanned(~H:Type,~S:Data,~V:Data,~selection:D.Selection<H,S,V>,observed:H & List<&2,W.Handle<S>>) -> H & List<&2,Row<S,V>>:
  (owner,targets)=observed
  unwrap_scan(~H,~S,~V,scan(~H,~S,~V,~selection,targets,owner,[]))
def enumerate(~H:Type,~S:Data,~V:Data,~selection:D.Selection<H,S,V>,~world:WorldRead<H,S>,owner:H) -> H & List<&2,Row<S,V>>:
  scanned(~H,~S,~V,~selection,handles_field(~H,~S,world)(owner))
def grant(~H:Type,~S:Data,~V:Data,~selection:D.Selection<H,S,V>,~world:WorldRead<H,S>) -> ReadQuery<H,S,V>:
  ReadQuery{owner => enumerate(~H,~S,~V,~selection,~world,owner),owner => target => lookup(~H,~S,~V,~selection,~world,owner,target)}
