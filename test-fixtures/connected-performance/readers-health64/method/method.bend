import Base
import json.bend as J
import actors.bend as A
import values.bend as V
import ../consumer/health-domain.bend as D
import ../consumer/health-systems.bend as S
import ../consumer/health-program.bend as P
import ../consumer/health-stream.bend as Stream
import ../consumer/health-reader.bend as Reader
import ../consumer/health-parameters.bend as Param
import ../consumer/health-logical.bend as Logical
import ../consumer/types.bend as T
import ../consumer/health-events.bend as E
import ../../../../src/ecs/reader-parameter.bend as RP
import ../../../../src/ecs/ordinary-reader-query-parameter.bend as QP
import ../../../../src/ecs/ordinary-reader-stream-parameter.bend as SP
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/relation-commands.bend as Notice
import ../../../../src/ecs/inspector-query.bend as IQ
import ../../../../src/ecs/inspector-query-projection.bend as Proj
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/entity-key.bend as Key

type Carriers is Data:
  Carriers{records:List<&2,J.Value>,actors:J.Value,valid:Bool}
def raw_entries(values:List<&2,A.Entry>,out:List<&2,J.Value>) -> J.Value:
  match values:
    case []:J.array(List.reverse(&2,J.Value,out))
    case A.Entry{W.Handle{namespace,Key.EntityKey{index,generation}},actor} <> rest:raw_entries(rest,J.object([J.Field{"actor",J.Number{actor}},J.Field{"namespace",V.u(namespace)},J.Field{"index",V.u(index)},J.Field{"generation",V.u(generation)}]) <> out)
def raw_map(value:A.Actors) -> J.Value:
  match value:
    case A.Actors{entries,_,_}:raw_entries(entries,[])
def ordinals(values:List<&2,A.Entry>,out:List<&2,J.Value>) -> J.Value:
  match values:
    case []:J.array(List.reverse(&2,J.Value,out))
    case A.Entry{_,ordinal} <> rest:ordinals(rest,J.Number{ordinal} <> out)
def seed_record(value:A.Actors) -> J.Value:
  match value:
    case A.Actors{entries,_,_}:J.object([J.Field{"kind",J.Text{"SeedActors"}},J.Field{"actors",ordinals(entries,[])}])
def filtered_rows(+actors:A.Actors,values:List<&2,IQ.ProjectedRow<T.HealthSchema,Proj.Product<Unit,Logical.Value()>>>,out:List<&2,J.Value>) -> J.Value:
  match values:
    case []:J.array(List.reverse(&2,J.Value,out))
    case IQ.ProjectedRow{raw,Proj.Product{_,value}} <> rest:filtered_rows(actors,rest,V.row(actors,IQ.ProjectedRow{raw,value}) <> out)
def event(actors:A.Actors,value:E.event_type()) -> J.Value:
  match value:
    case Notice.Original{E.Ping{code}}:J.object([J.Field{"code",V.u(code)}])
    case Notice.Original{E.Removed{raw}}:J.object([J.Field{"actor",A.reference(actors,raw)}])
    case Notice.Original{E.Despawned{raw}}:J.object([J.Field{"actor",A.reference(actors,raw)}])
    case _:J.object([J.Field{"kind",J.Text{"UnexpectedPublication"}}])
def event_values(+actors:A.Actors,values:List<&2,E.event_type()>,out:List<&2,J.Value>) -> J.Value:
  match values:
    case []:J.array(List.reverse(&2,J.Value,out))
    case head <> rest:event_values(actors,rest,event(actors,head) <> out)
def reading(actors:A.Actors,value:Ev.Reading<E.event_type()>) -> J.Value:
  match value:
    case Ev.Reading{values,lagged}:J.object([J.Field{"values",event_values(actors,values,[])},J.Field{"lagged",J.Boolean{lagged}}])
def values_only(actors:A.Actors,value:Ev.Reading<E.event_type()>) -> J.Value:
  match value:
    case Ev.Reading{values,_}:J.object([J.Field{"values",event_values(actors,values,[])}])
def who(value:U32) -> J.Value:
  match value:
    case 0:J.Text{"Fast"}
    case 1:J.Text{"Slow"}
    case value:J.object([J.Field{"kind",J.Text{"UnknownReader"}},J.Field{"value",V.u(value)}])
def phase(value:U32) -> J.Value:
  match value:
    case 0:J.Text{"Prime"}
    case 1:J.Text{"Read"}
    case 2:J.Text{"Drain"}
    case value:J.object([J.Field{"kind",J.Text{"UnknownPhase"}},J.Field{"value",V.u(value)}])
def iteration(value:U32,index:U32) -> J.Value:
  match value:
    case 1:V.u(index)
    case _:J.Null{}
def read_status(value:U32) -> J.Value:
  match value:
    case 0:J.object([J.Field{"kind",J.Text{"Success"}}])
    case value:J.object([J.Field{"kind",J.Text{"ReadRefusedOrFailed"}},J.Field{"code",V.u(value)}])
def read_record(+actors:A.Actors,status:U32,value:Reader.Read) -> J.Value:
  match value:
    case Reader.Read{Reader.Args{who_,+phase_,i},Param.PreparedView{RP.ViewPair{QP.Rows{rows},RP.ViewPair{QP.Rows{added},RP.ViewPair{QP.Rows{changed},RP.ViewPair{SP.EventView{ping},RP.ViewPair{SP.EventView{removed},SP.EventView{despawned}}}}}},_,_,_,_,_}}:J.object([J.Field{"kind",J.Text{"Read"}},J.Field{"who",who(who_)},J.Field{"phase",phase(phase_)},J.Field{"iteration",iteration(phase_,i)},J.Field{"rows",V.rows(actors,rows,[])},J.Field{"added",filtered_rows(actors,added,[])},J.Field{"changed",filtered_rows(actors,changed,[])},J.Field{"ping",reading(actors,ping)},J.Field{"removed",values_only(actors,removed)},J.Field{"despawned",values_only(actors,despawned)},J.Field{"status",read_status(status)}])
def read(+actors:A.Actors,value:S.ReadCall) -> J.Value:
  match value:
    case S.ReadCall{_,status,_,Some{view},_,_}:read_record(actors,status,view)
    case S.ReadCall{id,status,_,None{},_,_}:J.object([J.Field{"kind",J.Text{"Read"}},J.Field{"id",V.u(id)},J.Field{"output",J.Null{}},J.Field{"status",read_status(status)}])
def accepted_read(yes:Bool,+actors:A.Actors,head:S.ReadCall,rest:List<&2,S.ReadCall>,out:List<&2,J.Value>) -> List<&2,S.ReadCall> & List<&2,J.Value>:
  match yes:
    case True{}:(rest,read(actors,head) <> out)
    case False{}:(head <> rest,out)
def read_step(actors:A.Actors,id:U32,reads:List<&2,S.ReadCall>,out:List<&2,J.Value>) -> List<&2,S.ReadCall> & List<&2,J.Value>:
  match reads:
    case []:([],out)
    case S.ReadCall{+rid,status,tick,output,before,after} <> rest:accepted_read(U32.is_eq(id,rid),actors,S.ReadCall{rid,status,tick,output,before,after},rest,out)
def steps_returned(next:List<&2,S.ReadCall> -> List<&2,J.Value> -> List<&2,S.ReadCall> & List<&2,J.Value>,result:List<&2,S.ReadCall> & List<&2,J.Value>) -> List<&2,S.ReadCall> & List<&2,J.Value>:
  match result:
    case (reads,out):next(reads,out)
def steps(+actors:A.Actors,values:List<&2,Sch.Step>,reads:List<&2,S.ReadCall>,out:List<&2,J.Value>) -> List<&2,S.ReadCall> & List<&2,J.Value>:
  match values:
    case []:(reads,out)
    case Sch.System{id,_} <> rest:steps_returned(rs=>xs=>steps(actors,rest,rs,xs),read_step(actors,id,reads,out))
    case _ <> rest:steps(actors,rest,reads,out)
def outcome(value:P.Status) -> J.Value:
  match value:
    case P.Complete{}:J.object([J.Field{"kind",J.Text{"Success"}}])
    case value:V.status(value)
def stage_iteration(stage:U32,i:Nat) -> J.Value:
  match stage:
    case 0:J.Null{}
    case 4:J.Null{}
    case _:J.Number{i}
def stage(index:U32,i:Nat,name:String,status:P.Status) -> J.Value:J.object([J.Field{"kind",J.Text{"Stage"}},J.Field{"stage",J.Text{name}},J.Field{"iteration",stage_iteration(index,i)},J.Field{"outcome",outcome(status)}])
def stage_record(remaining:List<&2,P.Log>,index:U32,i:Nat,name:String,status:P.Status) -> J.Value:
  match remaining:
    case []:stage(4,i,name,status)
    case _:stage(index,i,name,status)
def next_stage(index:U32,i:Nat) -> U32 & Nat:
  match index:
    case 0:(1,i)
    case 1:(2,i)
    case 2:(3,i)
    case 3:(1,1n+i)
    case _:(4,i)
def merged(next:List<&2,S.ReadCall> -> List<&2,J.Value> -> List<&2,J.Value>,value:J.Value,result:List<&2,S.ReadCall> & List<&2,J.Value>) -> List<&2,J.Value>:
  match result:
    case (reads,out):next(reads,value <> out)
def merge_after(next:U32 -> Nat -> List<&2,S.ReadCall> -> List<&2,J.Value> -> List<&2,J.Value>,pair:U32 & Nat,reads:List<&2,S.ReadCall>,out:List<&2,J.Value>) -> List<&2,J.Value>:
  match pair:
    case (index,i):next(index,i,reads,out)
def merge(+actors:A.Actors,logs:List<&2,P.Log>,+index:U32,+i:Nat,reads:List<&2,S.ReadCall>,out:List<&2,J.Value>) -> List<&2,J.Value>:
  match logs:
    case []:List.reverse(&2,J.Value,out)
    case P.Log{name,+steps_,status,_} <> +rest:merged(rs=>xs=>merge_after(st=>it=>rs=>xs=>merge(actors,rest,st,it,rs,xs),next_stage(index,i),rs,xs),stage_record(rest,index,i,name,status),steps(actors,steps_,reads,out))
def final(+actors:A.Actors,rows:Logical.Rows(),ledger:T.LedgerView,status:P.Status) -> J.Value:J.object([J.Field{"kind",J.Text{"Final"}},J.Field{"rows",V.rows(actors,rows,[])},J.Field{"ledger",V.ledger(ledger)},J.Field{"status",V.status(status)}])
def build(seed:List<&2,W.Reservation<T.HealthSchema>>,view:Stream.StateView,rows:Logical.Rows(),ledger:T.LedgerView) -> Carriers:
  match view:
    case Stream.StateView{_,+status,_,Stream.OwnerView{_,D.Frame{_,_,_,reservations,_},_,_,_,_,_,_,_,_,_,reads},logs}:
      +seedActors=A.from_seed(seed,A.empty())
      +actors=A.from_seed(reservations,seedActors)
      Carriers{List.append(&2,J.Value,[seed_record(seedActors)],List.append(&2,J.Value,merge(actors,logs,0,0n,reads,[]),[final(actors,rows,ledger,status)])),raw_map(actors),A.valid(actors)}
