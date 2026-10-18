import Base
import health-codec-values.bend as V
import health-domain.bend as D
import ../dense-runtime-v1/health.bend as F
import ../dense-runtime-v1/health-logical.bend as Logical
import ../dense-runtime-v1/health-observe.bend as O
import ../dense-runtime-v1/payload.bend as P
import ../dense-runtime-v1/types.bend as Types
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/ordinary-query-observable.bend as Observable
import ../../../../src/ecs/inspector-query.bend as IQ
import ../../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../../src/ecs/inspector.bend as Inspect
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/entity-key.bend as Key

def query() -> IQ.ComposedReadQuery<Logical.InspectFrame(),Types.HealthSchema,Logical.Value()>:
  Observable.inspect_query(~Types.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Logical.Frame(),~Logical.Ops(Logical.Frame()),~Logical.Value(),~Logical.declaration())
def lookup_done(observed:Logical.InspectFrame() & Result<&2,&2,IQ.LookupError,IQ.ProjectedRow<Types.HealthSchema,Logical.Value()>>) -> D.World() & U32:
  match observed:
    case (Inspect.Frame{world,_},Done{_}):(world,2)
    case (Inspect.Frame{world,_},Fail{IQ.MissingEntity{_}}):(world,0)
    case (Inspect.Frame{world,_},Fail{IQ.QueryMismatch{_}}):(world,1)
def lookup(world:D.World(),handle:Maybe<&2,W.Handle<Types.HealthSchema>>) -> D.World() & U32:
  match handle:
    case None{}:(world,0)
    case Some{handle}:lookup_done(IQ.get_composed(~Logical.InspectFrame(),~Types.HealthSchema,~Logical.Value(),~query(),Inspect.Frame{world,0},handle))
def stale_added(+handle:W.Handle<Types.HealthSchema>,seen:List<&2,D.Seen>,observed:D.World() & U32) -> D.World() & List<&2,D.Seen>:
  match observed:
    case (world,kind):(world,D.Seen{handle,kind} <> seen)
def stale_next(next:D.World()->List<&2,D.Seen>->D.World() & List<&2,D.Seen>,observed:D.World() & List<&2,D.Seen>) -> D.World() & List<&2,D.Seen>:
  match observed:
    case (world,seen):next(world,seen)
def stales(handles:List<&2,W.Handle<Types.HealthSchema>>,world:D.World(),seen:List<&2,D.Seen>) -> D.World() & List<&2,D.Seen>:
  match handles:
    case []:(world,List.reverse(&2,D.Seen,seen))
    case +handle <> rest:stale_next(w=>xs=>stales(rest,w,xs),stale_added(handle,seen,lookup(world,Some{handle})))
def ledger_projected(unit:Unit,observed:Types.HealthLedger & Types.LedgerView) -> F.Resources() & Types.LedgerView:
  match observed:
    case (ledger,value):(Product.Owner{ledger,unit},value)
def ledger_project(resource:F.Resources()) -> F.Resources() & Types.LedgerView:
  match resource:
    case Product.Owner{ledger,unit}:ledger_projected(unit,P.health_ledger_get(ledger))
def observed_after(owner:Array<U32>,+frame:D.Frame,rows:Logical.Rows(),ledger:Types.LedgerView,lookups:Types.Four,stale:List<&2,D.Seen>,before:V.World,observed:D.World() & V.World) -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>:
  match observed:
    case (world,after):Local.Succeeded{world,owner,D.Output{frame,Some{D.Boundary{frame,rows,ledger,lookups,stale,before,after}}}}
def observed_stales(owner:Array<U32>,frame:D.Frame,rows:Logical.Rows(),ledger:Types.LedgerView,lookups:Types.Four,before:V.World,observed:D.World() & List<&2,D.Seen>) -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>:
  match observed:
    case (world,stale):observed_after(owner,frame,rows,ledger,lookups,stale,before,V.world(world))
def foreign_done(owner:Array<U32>,frame:D.Frame,rows:Logical.Rows(),ledger:Types.LedgerView,pending:U32,target:U32,before:V.World,observed:D.World() & U32) -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>:
  match frame observed:
    case D.Frame{count,iteration,phase,t,p,f,+stale,reservations}, (world,foreign):observed_stales(owner,D.Frame{count,iteration,phase,t,p,f,stale,reservations},rows,ledger,Types.Four{pending,target,foreign,0},before,stales(stale,world,[]))
def target_done(owner:Array<U32>,frame:D.Frame,rows:Logical.Rows(),ledger:Types.LedgerView,pending:U32,before:V.World,observed:D.World() & U32) -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>:
  match frame observed:
    case D.Frame{count,iteration,phase,t,p,+f,stale,reservations}, (world,target):foreign_done(owner,D.Frame{count,iteration,phase,t,p,f,stale,reservations},rows,ledger,pending,target,before,lookup(world,Some{f}))
def pending_done(owner:Array<U32>,frame:D.Frame,rows:Logical.Rows(),ledger:Types.LedgerView,before:V.World,observed:D.World() & U32) -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>:
  match frame observed:
    case D.Frame{count,iteration,phase,+t,p,f,stale,reservations}, (world,pending):target_done(owner,D.Frame{count,iteration,phase,t,p,f,stale,reservations},rows,ledger,pending,before,lookup(world,t))
def ledger_done(owner:Array<U32>,frame:D.Frame,rows:Logical.Rows(),before:V.World,observed:D.World() & Types.LedgerView) -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>:
  match frame observed:
    case D.Frame{count,iteration,phase,t,+p,f,stale,reservations}, (world,ledger):pending_done(owner,D.Frame{count,iteration,phase,t,p,f,stale,reservations},rows,ledger,before,lookup(world,p))
def rows_done(owner:Array<U32>,frame:D.Frame,before:V.World,observed:D.World() & Logical.Rows()) -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>:
  match observed:
    case (world,rows):ledger_done(owner,frame,rows,before,W.observe_resource(~Types.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Types.LedgerView,~ledger_project,world))
def before_done(owner:Array<U32>,frame:D.Frame,observed:D.World() & V.World) -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>:
  match observed:
    case (world,text):rows_done(owner,frame,text,Logical.rows(world))
def run(world:D.World(),owner:Array<U32>,frame:D.Frame) -> Local.Outcome<D.World(),Array<U32>,Unit,D.Output>:before_done(owner,frame,V.world(world))

def mix(a:U32,b:U32) -> U32:U32.add(U32.mul(a,65599),b)
def four(seed:U32,value:Types.Four) -> U32:
  match value:
    case Types.Four{a,b,c,d}:mix(mix(mix(mix(seed,a),b),c),d)
def boolnum(value:Bool) -> U32:
  match value:
    case False{}:0
    case True{}:1
def main_hash(value:Cmp.Access<Types.VitalsView>) -> U32:
  match value:
    case Cmp.Found{Types.VitalsView{cells,reserve,class}}:mix(mix(four(1,cells),reserve),class)
    case _:0
def aux_hash(value:Cmp.Access<Types.ArmorView>) -> U32:
  match value:
    case Cmp.Found{Types.ArmorView{cells,grade}}:mix(four(1,cells),grade)
    case _:0
def flag_hash(value:Cmp.Access<Types.Tracked>) -> U32:
  match value:
    case Cmp.Found{Types.Tracked{group}}:mix(1,group)
    case _:0
def row_hash(value:IQ.ProjectedRow<Types.HealthSchema,Logical.Value()>) -> U32:
  match value:
    case IQ.ProjectedRow{W.Handle{namespace,key},Projection.Product{main,Projection.Product{aux,flag}}}:mix(mix(mix(mix(mix(1,namespace),Key.index(key)),main_hash(main)),aux_hash(aux)),flag_hash(flag))
def rows_hash(rows:Logical.Rows(),seed:U32) -> U32:
  match rows:
    case []:mix(seed,0)
    case head <> rest:rows_hash(rest,mix(seed,row_hash(head)))
def seen_hash(value:D.Seen) -> U32:
  match value:
    case D.Seen{W.Handle{namespace,key},kind}:mix(mix(mix(1,namespace),Key.index(key)),kind)
def stales_hash(values:List<&2,D.Seen>,seed:U32) -> U32:
  match values:
    case []:mix(seed,0)
    case head <> rest:stales_hash(rest,mix(seed,seen_hash(head)))
def ledger_hash(value:Types.LedgerView) -> U32:
  match value:
    case Types.LedgerView{cells,epoch}:mix(four(1,cells),epoch)
def hash(value:D.Boundary) -> U32:
  match value:
    case D.Boundary{D.Frame{_,iteration,phase,_,_,_,_,_},rows,ledger,lookups,stale,_,_}:mix(mix(mix(mix(mix(mix(1,iteration),phase),rows_hash(rows,1)),ledger_hash(ledger)),four(1,lookups)),stales_hash(stale,1))
