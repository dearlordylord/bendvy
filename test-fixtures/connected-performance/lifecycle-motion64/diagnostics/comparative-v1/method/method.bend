import Base
import ../../../../../../src/ecs/schedule.bend as Sch
import ../../../consumer/dense-runtime-v1/motion.bend as F
import ../../../method/json.bend as J
import ../../../method/actors.bend as A
import values.bend as V
import ../consumer/motion-domain.bend as D
import ../consumer/motion-systems.bend as S
import ../consumer/motion-program.bend as P
import ../consumer/motion-app.bend as App
import ../consumer/motion-observation.bend as O
import ../../../consumer/dense-runtime-v1/motion-logical.bend as Logical
import ../../../consumer/dense-runtime-v1/types.bend as T
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/entity-key.bend as Key

type Snapshot is Data:
  Snapshot{frame:D.Frame,boundaries:List<&2,D.Boundary>,calls:List<&2,S.Call>}
type Setup is Data:
  Setup{seed:List<&2,W.Reservation<T.MotionSchema>>,foreignRows:Logical.Rows(),foreignLedger:T.LedgerView}
type Carriers is Data:
  Carriers{common:List<&2,J.Value>,foreign:List<&2,J.Value>,actors:J.Value,public:J.Value,valid:Bool}
def snapshot(world:D.World(),runtime:S.Runtime(),_:Unit) -> D.World() & (S.Runtime() & Snapshot):
  match runtime:
    case (owners,S.Shared{+frame,digest,+boundaries,+calls,stage}):(world,((owners,S.Shared{frame,digest,boundaries,calls,stage}),Snapshot{frame,boundaries,calls}))
def setup_ledger(seed:List<&2,W.Reservation<T.MotionSchema>>,rows:Logical.Rows(),app:App.Slot(),ids:P.Ids,namespace:U32,logs:List<&2,P.Log>,status:P.Status,result:D.World() & T.LedgerView) -> P.State & Setup:
  match result:
    case (foreign,ledger):(P.State{app,foreign,ids,namespace,logs,status},Setup{seed,rows,ledger})
def setup_rows(seed:List<&2,W.Reservation<T.MotionSchema>>,app:App.Slot(),ids:P.Ids,namespace:U32,logs:List<&2,P.Log>,status:P.Status,result:D.World() & Logical.Rows()) -> P.State & Setup:
  match result:
    case (foreign,rows):setup_ledger(seed,rows,app,ids,namespace,logs,status,W.observe_resource(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~T.LedgerView,~O.ledger_project,foreign))
def setup(seed:List<&2,W.Reservation<T.MotionSchema>>,state:P.State) -> P.State & Setup:
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
    case D.Boundary{D.Frame{_,iteration,phase,target,current,_,_,reservations},rows,ledger,T.Four{currentKind,targetKind,_,_},stale}:J.object([J.Field{"kind",J.Text{"Boundary"}},J.Field{"iteration",V.u(iteration)},J.Field{"phase",V.u(phase)},J.Field{"target",V.handle(actors,target)},J.Field{"current",V.handle(actors,current)},J.Field{"reservations",V.reservations(actors,reservations,[])},J.Field{"rows",V.rows(actors,rows,[])},J.Field{"ledger",V.ledger(ledger)},J.Field{"currentKind",V.u(currentKind)},J.Field{"targetKind",V.u(targetKind)},J.Field{"stale",V.stales(actors,stale,[])}])
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
    case Some{D.Boundary{D.Frame{_,_,_,target,current,_,_,reservations},rows,ledger,_,stale}}:J.object([J.Field{"kind",J.Text{"Final"}},J.Field{"rows",V.rows(actors,rows,[])},J.Field{"ledger",V.ledger(ledger)},J.Field{"current",V.handle(actors,current)},J.Field{"target",V.handle(actors,target)},J.Field{"reservations",V.reservations(actors,reservations,[])},J.Field{"stale",V.stales(actors,stale,[])},J.Field{"status",V.status(status)}])
def merge(+actors:A.Actors,logs:List<&2,P.Log>,boundaries:List<&2,D.Boundary>,+iteration:Nat,+index:U32,out:List<&2,J.Value>) -> List<&2,J.Value>:
  match logs boundaries index:
    case [],_,_:List.reverse(&2,J.Value,out)
    case log <> rest,b <> bs,1:merge(actors,rest,bs,iteration,2,stage(iteration,1,log) <> boundary(actors,b) <> out)
    case log <> rest,b <> bs,3:merge(actors,rest,bs,iteration,4,stage(iteration,3,log) <> boundary(actors,b) <> out)
    case log <> rest,b <> bs,5:merge(actors,rest,bs,1n+iteration,0,stage(iteration,5,log) <> boundary(actors,b) <> out)
    case log <> rest,bs,index:merge(actors,rest,bs,iteration,U32.add(index,1),stage(iteration,index,log) <> out)
def foreign_record(actors:A.Actors,value:D.Boundary) -> J.Value:
  match value:
    case D.Boundary{D.Frame{_,iteration,phase,_,_,W.Handle{+namespace,Key.EntityKey{+index,+generation}},_,_},_,_,T.Four{_,_,kind,_},_}:J.object([J.Field{"kind",J.Text{"ForeignProbe"}},J.Field{"iteration",V.u(iteration)},J.Field{"phase",V.u(phase)},J.Field{"foreign",J.object([J.Field{"world",J.Text{"foreign"}},J.Field{"actor",A.reference(actors,W.Handle{namespace,Key.EntityKey{index,generation}})},J.Field{"namespace",V.u(namespace)},J.Field{"index",V.u(index)},J.Field{"generation",V.u(generation)}])},J.Field{"result",J.object([J.Field{"kind",J.Text{"LookupKind"}},J.Field{"value",V.u(kind)}])}])
def foreign_records(+actors:A.Actors,values:List<&2,D.Boundary>,out:List<&2,J.Value>) -> List<&2,J.Value>:
  match values:
    case []:List.reverse(&2,J.Value,out)
    case head <> rest:foreign_records(actors,rest,foreign_record(actors,head) <> out)
def raw_handle(value:W.Handle<T.MotionSchema>) -> J.Value:
  match value:
    case W.Handle{namespace,Key.EntityKey{index,generation}}:J.object([J.Field{"namespace",V.u(namespace)},J.Field{"index",V.u(index)},J.Field{"generation",V.u(generation)}])
def optional_raw(value:Maybe<&2,W.Handle<T.MotionSchema>>) -> J.Value:
  match value:
    case None{}:J.Null{}
    case Some{handle}:raw_handle(handle)
def raw_handles(values:List<&2,W.Handle<T.MotionSchema>>,out:List<&2,J.Value>) -> J.Value:
  match values:
    case []:J.array(List.reverse(&2,J.Value,out))
    case value <> rest:raw_handles(rest,raw_handle(value) <> out)
def world_error(value:W.WorldError) -> J.Value:
  match value:
    case W.MissingEntity{}:J.Text{"MissingEntity"}
    case W.CapacityExceeded{}:J.Text{"CapacityExceeded"}
    case W.NamespaceExhausted{}:J.Text{"NamespaceExhausted"}
    case W.SystemIdExhausted{}:J.Text{"SystemIdExhausted"}
def raw_reservation(value:W.Reservation<T.MotionSchema>) -> J.Value:
  match value:
    case W.Reserved{handle}:J.object([J.Field{"kind",J.Text{"Reserved"}},J.Field{"handle",raw_handle(handle)}])
    case W.ReservationRejected{error}:J.object([J.Field{"kind",J.Text{"ReservationRejected"}},J.Field{"error",world_error(error)}])
def raw_reservations(values:List<&2,W.Reservation<T.MotionSchema>>,out:List<&2,J.Value>) -> J.Value:
  match values:
    case []:J.array(List.reverse(&2,J.Value,out))
    case value <> rest:raw_reservations(rest,raw_reservation(value) <> out)
def public_frame(value:D.Frame) -> J.Value:
  match value:
    case D.Frame{count,iteration,phase,target,pending,foreign,stale,reservations}:J.object([J.Field{"count",V.u(count)},J.Field{"iteration",V.u(iteration)},J.Field{"phase",V.u(phase)},J.Field{"target",optional_raw(target)},J.Field{"pending",optional_raw(pending)},J.Field{"foreign",raw_handle(foreign)},J.Field{"stale",raw_handles(stale,[])},J.Field{"reservations",raw_reservations(reservations,[])}])
def boundary_details(value:D.Boundary) -> J.Value:
  match value:
    case D.Boundary{frame,_,_,lookups,_}:J.object([J.Field{"frame",public_frame(frame)},J.Field{"lookups",V.four(lookups)}])
def public_boundary(+actors:A.Actors,value:Maybe<&2,D.Boundary>) -> J.Value:
  match value:
    case None{}:J.Null{}
    case Some{+value}:J.object([J.Field{"common",boundary(actors,value)},J.Field{"details",boundary_details(value)}])
def public_output(+actors:A.Actors,value:Maybe<&2,D.Output>) -> J.Value:
  match value:
    case None{}:J.Null{}
    case Some{D.Output{frame,boundary}}:J.object([J.Field{"frame",public_frame(frame)},J.Field{"boundary",public_boundary(actors,boundary)}])
def operation(value:D.Operation) -> J.Value:
  match value:
    case D.Select{}:J.Text{"Select"}
    case D.Reserve{}:J.Text{"Reserve"}
    case D.Dispose{}:J.Text{"Dispose"}
    case D.Observe{}:J.Text{"Observe"}
def call_status(value:S.CallStatus) -> J.Value:
  match value:
    case S.Succeeded{}:J.Text{"Succeeded"}
    case S.Failed{}:J.Text{"Failed"}
    case S.Refused{}:J.Text{"Refused"}
def public_call(actors:A.Actors,value:S.Call) -> J.Value:
  match value:
    case S.Call{op,id,status,output}:J.object([J.Field{"operation",operation(op)},J.Field{"id",V.u(id)},J.Field{"status",call_status(status)},J.Field{"output",public_output(actors,output)}])
def public_calls(+actors:A.Actors,values:List<&2,S.Call>,out:List<&2,J.Value>) -> J.Value:
  match values:
    case []:J.array(List.reverse(&2,J.Value,out))
    case value <> rest:public_calls(actors,rest,public_call(actors,value) <> out)
def schedule_step(value:Sch.Step) -> J.Value:
  match value:
    case Sch.System{id,condition}:J.object([J.Field{"kind",J.Text{"System"}},J.Field{"id",V.u(id)},J.Field{"condition",V.u(condition)}])
    case Sch.Phase{name}:J.object([J.Field{"kind",J.Text{"Phase"}},J.Field{"name",J.Text{name}}])
    case Sch.Barrier{}:J.object([J.Field{"kind",J.Text{"Barrier"}}])
def schedule_observation(value:Sch.Observation) -> J.Value:
  match value:
    case Sch.Entered{name}:J.object([J.Field{"kind",J.Text{"Entered"}},J.Field{"name",J.Text{name}}])
    case Sch.Ran{id}:J.object([J.Field{"kind",J.Text{"Ran"}},J.Field{"id",V.u(id)}])
    case Sch.Skipped{id}:J.object([J.Field{"kind",J.Text{"Skipped"}},J.Field{"id",V.u(id)}])
    case Sch.Applied{}:J.object([J.Field{"kind",J.Text{"Applied"}}])
def projected(~X:Data,~f:X -> J.Value,values:List<&2,X>,out:List<&2,J.Value>) -> J.Value:
  match values:
    case []:J.array(List.reverse(&2,J.Value,out))
    case value <> rest:projected(~X,~f,rest,f(value) <> out)
def observations(value:Maybe<&2,List<&2,Sch.Observation>>) -> J.Value:
  match value:
    case None{}:J.Null{}
    case Some{values}:projected(~Sch.Observation,~schedule_observation,values,[])
def public_schedule(value:P.Log) -> J.Value:
  match value:
    case P.Log{name,steps,status,obs}:J.object([J.Field{"name",J.Text{name}},J.Field{"steps",projected(~Sch.Step,~schedule_step,steps,[])},J.Field{"status",V.status(status)},J.Field{"observations",observations(obs)}])
def public_record(actors:A.Actors,calls:List<&2,S.Call>,logs:List<&2,P.Log>) -> J.Value:J.object([J.Field{"calls",public_calls(actors,calls,[])},J.Field{"schedules",projected(~P.Log,~public_schedule,logs,[])}])
def build(setup:Setup,+status:P.Status,+logs:List<&2,P.Log>,snapshot:Snapshot) -> Carriers:
  match setup snapshot:
    case Setup{+seed,rows,ledger},Snapshot{D.Frame{count,_,_,_,_,+foreign,_,+reservations},+boundaries,calls}:
      +seedActors=A.from_seed(seed,A.empty())
      +actors=A.from_seed(reservations,seedActors)
      +foreignActors=A.add(foreign,A.empty())
      Carriers{List.append(&2,J.Value,[seed_record(count,seedActors,foreignActors,rows,ledger)],List.append(&2,J.Value,merge(actors,logs,boundaries,0n,0,[]),[final(actors,status,last(boundaries,None{}))])),foreign_records(foreignActors,boundaries,[]),raw_map(actors,foreignActors),public_record(actors,calls,logs),Bool.and(A.valid(actors),A.valid(foreignActors))}
def collected(setup:Setup,foreign:D.World(),ids:P.Ids,namespace:U32,+logs:List<&2,P.Log>,+status:P.Status,result:App.Slot() & Snapshot) -> P.State & Carriers:
  match result:
    case (app,snapshot):(P.State{app,foreign,ids,namespace,logs,status},build(setup,status,logs,snapshot))
def collect(setup:Setup,state:P.State) -> P.State & Carriers:
  match state:
    case P.State{app,foreign,ids,namespace,logs,status}:collected(setup,foreign,ids,namespace,logs,status,App.project(~Unit,~Snapshot,~snapshot,app,Unit{}))
