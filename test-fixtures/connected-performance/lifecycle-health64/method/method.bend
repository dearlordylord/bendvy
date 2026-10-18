import Base
import ../consumer/dense-runtime-v1/health.bend as F
import ../../lifecycle-motion64/method/json.bend as J
import actors.bend as A
import values.bend as V
import ../consumer/lifecycle-runtime-v1/health-domain.bend as D
import ../consumer/lifecycle-runtime-v1/health-systems.bend as S
import ../consumer/lifecycle-runtime-v1/health-program.bend as P
import ../consumer/lifecycle-runtime-v1/health-app.bend as App
import ../consumer/lifecycle-runtime-v1/health-observation.bend as O
import ../consumer/dense-runtime-v1/health-logical.bend as Logical
import ../../lifecycle-motion64/consumer/dense-runtime-v1/types.bend as T
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/entity-key.bend as Key

type Snapshot is Data:
  Snapshot{frame:D.Frame,boundaries:List<&2,D.Boundary>}
type Setup is Data:
  Setup{seed:List<&2,W.Reservation<T.HealthSchema>>,foreignRows:Logical.Rows(),foreignLedger:T.LedgerView}
type Carriers is Data:
  Carriers{common:List<&2,J.Value>,foreign:List<&2,J.Value>,actors:J.Value,valid:Bool}
def snapshot(world:D.World(),runtime:S.Runtime(),_:Unit) -> D.World() & (S.Runtime() & Snapshot):
  match runtime:
    case (owners,S.Shared{+frame,digest,+boundaries,calls,stage}):(world,((owners,S.Shared{frame,digest,boundaries,calls,stage}),Snapshot{frame,boundaries}))
def setup_ledger(seed:List<&2,W.Reservation<T.HealthSchema>>,rows:Logical.Rows(),app:App.Slot(),ids:P.Ids,namespace:U32,logs:List<&2,P.Log>,status:P.Status,result:D.World() & T.LedgerView) -> P.State & Setup:
  match result:
    case (foreign,ledger):(P.State{app,foreign,ids,namespace,logs,status},Setup{seed,rows,ledger})
def setup_rows(seed:List<&2,W.Reservation<T.HealthSchema>>,app:App.Slot(),ids:P.Ids,namespace:U32,logs:List<&2,P.Log>,status:P.Status,result:D.World() & Logical.Rows()) -> P.State & Setup:
  match result:
    case (foreign,rows):setup_ledger(seed,rows,app,ids,namespace,logs,status,W.observe_resource(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~T.LedgerView,~O.ledger_project,foreign))
def setup(seed:List<&2,W.Reservation<T.HealthSchema>>,state:P.State) -> P.State & Setup:
  match state:
    case P.State{app,foreign,ids,namespace,logs,status}:setup_rows(seed,app,ids,namespace,logs,status,Logical.rows(foreign))
def raw_entries(values:List<&2,A.Entry>,out:List<&2,J.Value>) -> J.Value:
  match values:
    case []:J.array(List.reverse(&2,J.Value,out))
    case A.Entry{W.Handle{namespace,Key.EntityKey{index,generation}},actor} <> rest:raw_entries(rest,J.object([J.Field{"actor",J.Number{actor}},J.Field{"namespace",V.u(namespace)},J.Field{"index",V.u(index)},J.Field{"generation",V.u(generation)}]) <> out)
def raw_map(primary:A.Actors,foreign:A.Actors) -> J.Value:
  match primary foreign:
    case A.Actors{entries,_,_},_:raw_entries(entries,[])
def ordinals(values:List<&2,A.Entry>,out:List<&2,J.Value>) -> J.Value:
  match values:
    case []:J.array(List.reverse(&2,J.Value,out))
    case A.Entry{_,ordinal} <> rest:ordinals(rest,J.Number{ordinal} <> out)
def foreign_actor(value:A.Actors) -> J.Value:
  match value:
    case A.Actors{A.Entry{_,ordinal} <> [],_,_}:J.Number{ordinal}
    case _:J.object([J.Field{"kind",J.Text{"InvalidForeignMap"}}])
def seed_record(count:U32,seed:A.Actors,+foreign:A.Actors,rows:Logical.Rows(),ledger:T.LedgerView) -> J.Value:
  match seed:
    case A.Actors{entries,_,_}:J.object([J.Field{"kind",J.Text{"Seed"}},J.Field{"count",V.u(count)},J.Field{"actors",ordinals(entries,[])},J.Field{"foreign",J.object([J.Field{"actor",foreign_actor(foreign)},J.Field{"rows",V.rows(foreign,rows,[])},J.Field{"ledger",V.ledger(ledger)}])}])
def boundary(+actors:A.Actors,value:D.Boundary) -> J.Value:
  match value:
    case D.Boundary{D.Frame{_,iteration,phase,target,current,_,_,reservations},rows,ledger,T.Four{currentKind,targetKind,_,_},stale,_,_}:J.object([J.Field{"kind",J.Text{"Boundary"}},J.Field{"iteration",V.u(iteration)},J.Field{"phase",V.u(phase)},J.Field{"target",V.handle(actors,target)},J.Field{"current",V.handle(actors,current)},J.Field{"reservations",V.reservations(actors,reservations,[])},J.Field{"rows",V.rows(actors,rows,[])},J.Field{"ledger",V.ledger(ledger)},J.Field{"currentKind",V.u(currentKind)},J.Field{"targetKind",V.u(targetKind)},J.Field{"stale",V.stales(actors,stale,[])}])
def outcome(value:P.Status) -> J.Value:
  match value:
    case P.Complete{}:J.object([J.Field{"kind",J.Text{"Success"}}])
    case value:V.status(value)
def stage(+iteration:Nat,+index:U32,value:P.Log) -> J.Value:
  match value:
    case P.Log{_,_,status,_}:J.object([J.Field{"kind",J.Text{"Stage"}},J.Field{"iteration",J.Number{iteration}},J.Field{"stage",V.u(index)},J.Field{"outcome",outcome(status)}])
def last(values:List<&2,D.Boundary>,current:Maybe<&2,D.Boundary>) -> Maybe<&2,D.Boundary>:
  match values:
    case []:current
    case head <> rest:last(rest,Some{head})
def final(+actors:A.Actors,status:P.Status,value:Maybe<&2,D.Boundary>) -> J.Value:
  match value:
    case None{}:J.object([J.Field{"kind",J.Text{"Final"}},J.Field{"boundary",J.Null{}},J.Field{"status",V.status(status)}])
    case Some{D.Boundary{D.Frame{_,_,_,target,current,_,_,reservations},rows,ledger,_,stale,_,_}}:J.object([J.Field{"kind",J.Text{"Final"}},J.Field{"rows",V.rows(actors,rows,[])},J.Field{"ledger",V.ledger(ledger)},J.Field{"current",V.handle(actors,current)},J.Field{"target",V.handle(actors,target)},J.Field{"reservations",V.reservations(actors,reservations,[])},J.Field{"stale",V.stales(actors,stale,[])},J.Field{"status",V.status(status)}])
def merge(+actors:A.Actors,logs:List<&2,P.Log>,boundaries:List<&2,D.Boundary>,+iteration:Nat,+index:U32,out:List<&2,J.Value>) -> List<&2,J.Value>:
  match logs boundaries index:
    case [],_,_:List.reverse(&2,J.Value,out)
    case log <> rest,b <> bs,1:merge(actors,rest,bs,iteration,2,stage(iteration,1,log) <> boundary(actors,b) <> out)
    case log <> rest,b <> bs,3:merge(actors,rest,bs,iteration,4,stage(iteration,3,log) <> boundary(actors,b) <> out)
    case log <> rest,b <> bs,5:merge(actors,rest,bs,1n+iteration,0,stage(iteration,5,log) <> boundary(actors,b) <> out)
    case log <> rest,bs,index:merge(actors,rest,bs,iteration,U32.add(index,1),stage(iteration,index,log) <> out)
def foreign_record(actors:A.Actors,value:D.Boundary) -> J.Value:
  match value:
    case D.Boundary{D.Frame{_,iteration,phase,_,_,W.Handle{+namespace,Key.EntityKey{+index,+generation}},_,_},_,_,T.Four{_,_,kind,_},_,_,_}:J.object([J.Field{"kind",J.Text{"ForeignProbe"}},J.Field{"iteration",V.u(iteration)},J.Field{"phase",V.u(phase)},J.Field{"foreign",J.object([J.Field{"world",J.Text{"foreign"}},J.Field{"actor",A.reference(actors,W.Handle{namespace,Key.EntityKey{index,generation}})},J.Field{"namespace",V.u(namespace)},J.Field{"index",V.u(index)},J.Field{"generation",V.u(generation)}])},J.Field{"result",J.object([J.Field{"kind",J.Text{"LookupKind"}},J.Field{"value",V.u(kind)}])}])
def foreign_records(+actors:A.Actors,values:List<&2,D.Boundary>,out:List<&2,J.Value>) -> List<&2,J.Value>:
  match values:
    case []:List.reverse(&2,J.Value,out)
    case head <> rest:foreign_records(actors,rest,foreign_record(actors,head) <> out)
def build(setup:Setup,+status:P.Status,+logs:List<&2,P.Log>,snapshot:Snapshot) -> Carriers:
  match setup snapshot:
    case Setup{+seed,rows,ledger},Snapshot{D.Frame{count,_,_,_,_,+foreign,_,+reservations},+boundaries}:
      +seedActors=A.from_seed(seed,A.empty())
      +actors=A.from_seed(reservations,seedActors)
      +foreignActors=A.add(foreign,A.empty())
      Carriers{List.append(&2,J.Value,[seed_record(count,seedActors,foreignActors,rows,ledger)],List.append(&2,J.Value,merge(actors,logs,boundaries,0n,0,[]),[final(actors,status,last(boundaries,None{}))])),foreign_records(foreignActors,boundaries,[]),raw_map(actors,foreignActors),Bool.and(A.valid(actors),A.valid(foreignActors))}
def collected(setup:Setup,foreign:D.World(),ids:P.Ids,namespace:U32,+logs:List<&2,P.Log>,+status:P.Status,result:App.Slot() & Snapshot) -> P.State & Carriers:
  match result:
    case (app,snapshot):(P.State{app,foreign,ids,namespace,logs,status},build(setup,status,logs,snapshot))
def collect(setup:Setup,state:P.State) -> P.State & Carriers:
  match state:
    case P.State{app,foreign,ids,namespace,logs,status}:collected(setup,foreign,ids,namespace,logs,status,App.project(~Unit,~Snapshot,~snapshot,app,Unit{}))
