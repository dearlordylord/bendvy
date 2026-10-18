import Base
import json.bend as J
import method.bend as M
import capture-call.bend as Call
import subject/motion.bend as F
import subject/events.bend as E
import subject/motion-local.bend as L
import subject/motion-systems.bend as S
import subject/motion-registration.bend as Reg
import subject/motion-publications.bend as Publications
import subject/motion-dispose.bend as Dispose
import subject/motion-resources.bend as R
import subject/motion-logical.bend as Logical
import subject/motion-boundary.bend as Boundary
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/payload.bend as P
import /tmp/bendvy-failedtxn-matched-method/src/ecs/world.bend as W
import /tmp/bendvy-failedtxn-matched-method/src/ecs/component.bend as Cmp

def resource(world:F.World()) -> F.World() & R.View:
  W.observe_resource(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~R.View,~R.observe,world)
def looked(+state:M.State,+handle:W.Handle<T.MotionSchema>,observed:F.World() & Cmp.Access<T.PositionView>) -> F.World() & J.Value:
  match observed:
    case (world,value):(world,J.object([J.Field{"actor",M.reference(state,handle)},J.Field{"result",Call.write(value)}]))
def lookup(+state:M.State,world:F.World(),+handle:W.Handle<T.MotionSchema>) -> F.World() & J.Value:
  looked(state,handle,Cmp.get(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,F.main_family(),world,handle))
def optional(state:M.State,world:F.World(),handle:Maybe<&2,W.Handle<T.MotionSchema>>) -> F.World() & J.Value:
  match handle:
    case None{}:(world,J.Null{})
    case Some{handle}:lookup(state,world,handle)
def failed_next(next:(F.World() & List<&2,J.Value>) -> F.World() & List<&2,J.Value>,values:List<&2,J.Value>,observed:F.World() & J.Value) -> F.World() & List<&2,J.Value>:
  match observed:
    case (world,value):next((world,List.append(&2,J.Value,values,[value])))
def failed_all(+state:M.State,handles:List<&2,W.Handle<T.MotionSchema>>,input:F.World() & List<&2,J.Value>) -> F.World() & List<&2,J.Value>:
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
    case S.Frame{_,_,+i,_,pending,retry,+handles,_,+state}:
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
