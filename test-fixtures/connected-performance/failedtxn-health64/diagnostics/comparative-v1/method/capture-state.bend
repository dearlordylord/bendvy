import Base
import ../../../method/json.bend as J
import ../../../method/method.bend as M
import capture-call.bend as Call
import ../../../consumer/health.bend as F
import ../../../consumer/health-events.bend as E
import ../consumer/health-local.bend as L
import ../consumer/health-systems.bend as S
import ../../../consumer/health-publications.bend as Publications
import ../consumer/health-dispose.bend as Dispose
import ../../../consumer/health-resources.bend as R
import ../../../consumer/health-logical.bend as Logical
import ../consumer/health-boundary.bend as Boundary
import ../../../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/payload.bend as P
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/component.bend as Cmp

def resource(world:F.World()) -> F.World() & R.View:
  W.observe_resource(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~R.View,~R.observe,world)
def looked(+state:M.State,+handle:W.Handle<T.HealthSchema>,observed:F.World() & Cmp.Access<T.VitalsView>) -> F.World() & J.Value:
  match observed:
    case (world,value):(world,J.object([J.Field{"actor",M.reference(state,handle)},J.Field{"result",Call.write(value)}]))
def lookup(+state:M.State,world:F.World(),+handle:W.Handle<T.HealthSchema>) -> F.World() & J.Value:
  looked(state,handle,Cmp.get(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Vitals,~T.VitalsView,~T.VitalsToken,~F.take_main,~F.put_main,~P.vitals_get,F.main_family(),world,handle))
def optional(state:M.State,world:F.World(),handle:Maybe<&2,W.Handle<T.HealthSchema>>) -> F.World() & J.Value:
  match handle:
    case None{}:(world,J.Null{})
    case Some{handle}:lookup(state,world,handle)
def failed_next(next:(F.World() & List<&2,J.Value>) -> F.World() & List<&2,J.Value>,values:List<&2,J.Value>,observed:F.World() & J.Value) -> F.World() & List<&2,J.Value>:
  match observed:
    case (world,value):next((world,List.append(&2,J.Value,values,[value])))
def failed_all(+state:M.State,handles:List<&2,W.Handle<T.HealthSchema>>,input:F.World() & List<&2,J.Value>) -> F.World() & List<&2,J.Value>:
  match handles input:
    case [],input:input
    case handle <> rest,(world,values):failed_next(input=>failed_all(state,rest,input),values,lookup(state,world,handle))
def bind(~A:Data,~B:Type,next:F.World() -> A -> B,observed:F.World() & A) -> B:
  match observed:
    case (world,value):next(world,value)
def view_ledger(value:R.View) -> J.Value:
  match value:
    case R.View{ledger,_}:M.ledger(ledger)
def boundary(name:String,+frame:S.Frame,countA:U32,countB:U32,world:F.World()) -> F.World() & J.Value:
  match frame:
    case S.Frame{_,_,+i,_,pending,retry,+handles,publicCalls,+state}:
      bind(~Logical.Rows(),~(F.World() & J.Value),world=>rows=>
      bind(~R.View,~(F.World() & J.Value),world=>view=>
      bind(~J.Value,~(F.World() & J.Value),world=>pending=>
      bind(~J.Value,~(F.World() & J.Value),world=>last=>
      bind(~J.Value,~(F.World() & J.Value),world=>retry=>
      bind(~List<&2,J.Value>,~(F.World() & J.Value),world=>all=>
      (world,J.object([J.Field{"kind",J.Text{"Boundary"}},J.Field{"iteration",M.number(i)},J.Field{"phase",J.Text{name}},J.Field{"rows",J.array(M.rows(state,rows))},J.Field{"ledger",view_ledger(view)},J.Field{"pendingA",pending},J.Field{"latestFailed",last},J.Field{"retryB",retry},J.Field{"allFailed",J.array(all)},J.Field{"captures",M.capture_counts(countA,countB)}])),
      failed_all(state,handles,(world,[]))),optional(state,world,retry)),optional(state,world,Boundary.recent_go(handles,None{}))),optional(state,world,pending)),resource(world)),Logical.rows(world))
def subject_tail() -> Type:Publications.Provider() & Dispose.Registry()
def boundary_recorded(owners:S.Owned(),meta:L.Meta(),tick:Nat,frame:S.Frame,observed:F.World() & J.Value) -> F.World() & S.Runtime():
  match observed:
    case (world,record):(world,(owners,S.Shared{meta,tick,S.frame_method(frame,record)}))
def boundary_b(name:String,world:F.World(),a:L.Instance(),tail:subject_tail(),meta:L.Meta(),tick:Nat,+frame:S.Frame,countA:U32,observed:L.Instance() & U32) -> F.World() & S.Runtime():
  match observed:
    case (b,countB):boundary_recorded(((a,b),tail),meta,tick,frame,boundary(name,frame,countA,countB,world))
def boundary_a(name:String,world:F.World(),b:L.Instance(),tail:subject_tail(),meta:L.Meta(),tick:Nat,frame:S.Frame,observed:L.Instance() & U32) -> F.World() & S.Runtime():
  match observed:
    case (a,countA):boundary_b(name,world,a,tail,meta,tick,frame,countA,Call.instance_count(b))
def boundary_runtime(name:String,world:F.World(),runtime:S.Runtime()) -> F.World() & S.Runtime():
  match runtime:
    case (((a,b),tail),S.Shared{meta,tick,frame}):boundary_a(name,world,b,tail,meta,tick,frame,Call.instance_count(a))
def reverse_text(values:List<&2,String>,out:List<&2,J.Value>) -> List<&2,J.Value>:
  match values:
    case []:out
    case value <> rest:reverse_text(rest,J.Text{value} <> out)
def effects(value:R.AuditView) -> J.Value:
  match value:
    case R.Missing{}:J.object([J.Field{"kind",J.Text{"MissingAudit"}}])
    case R.RecordedView{values}:J.array(reverse_text(values,[]))
def final_record(state:M.State,rows:Logical.Rows(),view:R.View,countA:U32,countB:U32,status:J.Value) -> J.Value:
  match view:
    case R.View{ledger,audit}:J.object([J.Field{"kind",J.Text{"Final"}},J.Field{"rows",J.array(M.rows(state,rows))},J.Field{"ledger",M.ledger(ledger)},J.Field{"captures",M.capture_counts(countA,countB)},J.Field{"effects",effects(audit)},J.Field{"status",status}])
def final(world:F.World(),state:M.State,countA:U32,countB:U32,status:J.Value) -> F.World() & J.Value:
  bind(~Logical.Rows(),~(F.World() & J.Value),world=>rows=>
  bind(~R.View,~(F.World() & J.Value),world=>view=>
  (world,final_record(state,rows,view,countA,countB,status)),resource(world)),Logical.rows(world))
def frame_state(value:S.Frame) -> M.State:
  match value:
    case S.Frame{_,_,_,_,_,_,_,publicCalls,state}:state
def final_frame_state(first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>,i:U32,phase:U32,pending:Maybe<&2,W.Handle<T.HealthSchema>>,retry:Maybe<&2,W.Handle<T.HealthSchema>>,failed:List<&2,W.Handle<T.HealthSchema>>,publicCalls:List<&2,J.Value>,+state:M.State) -> S.Frame & M.State:
  (S.Frame{first,second,i,phase,pending,retry,failed,publicCalls,state},state)
def final_frame(frame:S.Frame,record:J.Value) -> S.Frame & M.State:
  match frame:
    case S.Frame{first,second,i,phase,pending,retry,failed,publicCalls,state}:final_frame_state(first,second,i,phase,pending,retry,failed,publicCalls,M.append(state,record))
def final_framed(world:F.World(),owners:S.Owned(),meta:L.Meta(),tick:Nat,value:S.Frame & M.State) -> F.World() & (S.Runtime() & M.State):
  match value:
    case (frame,state):(world,((owners,S.Shared{meta,tick,frame}),state))
def final_recorded(owners:S.Owned(),meta:L.Meta(),tick:Nat,frame:S.Frame,observed:F.World() & J.Value) -> F.World() & (S.Runtime() & M.State):
  match observed:
    case (world,record):final_framed(world,owners,meta,tick,final_frame(frame,record))
def final_b(status:J.Value,world:F.World(),a:L.Instance(),tail:subject_tail(),meta:L.Meta(),tick:Nat,+frame:S.Frame,countA:U32,observed:L.Instance() & U32) -> F.World() & (S.Runtime() & M.State):
  match observed:
    case (b,countB):final_recorded(((a,b),tail),meta,tick,frame,final(world,frame_state(frame),countA,countB,status))
def final_a(status:J.Value,world:F.World(),b:L.Instance(),tail:subject_tail(),meta:L.Meta(),tick:Nat,frame:S.Frame,observed:L.Instance() & U32) -> F.World() & (S.Runtime() & M.State):
  match observed:
    case (a,countA):final_b(status,world,a,tail,meta,tick,frame,countA,Call.instance_count(b))
def final_runtime(world:F.World(),runtime:S.Runtime(),status:J.Value) -> F.World() & (S.Runtime() & M.State):
  match runtime:
    case (((a,b),tail),S.Shared{meta,tick,frame}):final_a(status,world,b,tail,meta,tick,frame,Call.instance_count(a))
