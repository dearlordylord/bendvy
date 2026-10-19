import Base
import ../../../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/payload.bend as P
import ../../../consumer/motion.bend as F
import ../../../consumer/events.bend as E
import motion-systems.bend as S
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/component.bend as Cmp

import ../../../method/json.bend as J
import ../../../method/method.bend as M
import ../method/capture-call.bend as Call
import ../../../consumer/motion-logical.bend as Logical
type Boundary is Data:
  Boundary{iteration:U32,phase:String,record:J.Value}
def lookup_result(+state:M.State,+handle:W.Handle<T.MotionSchema>,result:F.World() & Cmp.Access<T.PositionView>) -> F.World() & J.Value:
  match result:
    case (world,value):(world,J.object([J.Field{"actor",M.reference(state,handle)},J.Field{"result",Call.write(value)}]))
def lookup(state:M.State,world:F.World(),+handle:W.Handle<T.MotionSchema>) -> F.World() & J.Value:
  lookup_result(state,handle,Cmp.get(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,F.main_family(),world,handle))
def optional(state:M.State,world:F.World(),handle:Maybe<&2,W.Handle<T.MotionSchema>>) -> F.World() & J.Value:
  match handle:
    case None{}:(world,J.Null{})
    case Some{handle}:lookup(state,world,handle)
def recent_go(values:List<&2,W.Handle<T.MotionSchema>>,prior:Maybe<&2,W.Handle<T.MotionSchema>>) -> Maybe<&2,W.Handle<T.MotionSchema>>:
  match values:
    case []:prior
    case head <> rest:recent_go(rest,Some{head})
def failed_next(next:(F.World() & List<&2,J.Value>) -> F.World() & List<&2,J.Value>,values:List<&2,J.Value>,observed:F.World() & J.Value) -> F.World() & List<&2,J.Value>:
  match observed:
    case (world,text):next((world,List.append(&2,J.Value,values,[text])))
def all_failed(+state:M.State,handles:List<&2,W.Handle<T.MotionSchema>>,input:F.World() & List<&2,J.Value>) -> F.World() & List<&2,J.Value>:
  match handles input:
    case [], input:input
    case +handle <> rest, (world,values):failed_next(input=>all_failed(state,rest,input),values,lookup(state,world,handle))
def finish(+iteration:U32,+phase:String,+state:M.State,rows:Logical.Rows(),pending:J.Value,failed:J.Value,retry:J.Value,result:F.World() & List<&2,J.Value>) -> F.World() & Boundary:
  match result:
    case (world,all):(world,Boundary{iteration,phase,J.object([J.Field{"kind",J.Text{"PublicBoundary"}},J.Field{"iteration",M.number(iteration)},J.Field{"phase",J.Text{phase}},J.Field{"rows",J.array(M.rows(state,rows))},J.Field{"pendingA",pending},J.Field{"latestFailed",failed},J.Field{"retryB",retry},J.Field{"allFailed",J.array(all)}])})
def retry_seen(iteration:U32,phase:String,+state:M.State,rows:Logical.Rows(),pending:J.Value,failed:J.Value,handles:List<&2,W.Handle<T.MotionSchema>>,observed:F.World() & J.Value) -> F.World() & Boundary:
  match observed:
    case (world,retry):finish(iteration,phase,state,rows,pending,failed,retry,all_failed(state,handles,(world,[])))
def failed_seen(iteration:U32,phase:String,+state:M.State,rows:Logical.Rows(),pending:J.Value,retry:Maybe<&2,W.Handle<T.MotionSchema>>,handles:List<&2,W.Handle<T.MotionSchema>>,observed:F.World() & J.Value) -> F.World() & Boundary:
  match observed:
    case (world,failed):retry_seen(iteration,phase,state,rows,pending,failed,handles,optional(state,world,retry))
def pending_seen(iteration:U32,phase:String,+state:M.State,rows:Logical.Rows(),retry:Maybe<&2,W.Handle<T.MotionSchema>>,+handles:List<&2,W.Handle<T.MotionSchema>>,observed:F.World() & J.Value) -> F.World() & Boundary:
  match observed:
    case (world,pending):failed_seen(iteration,phase,state,rows,pending,retry,handles,optional(state,world,recent_go(handles,None{})))
def rows_seen(phase:String,frame:S.Frame,observed:F.World() & Logical.Rows()) -> F.World() & Boundary:
  match frame observed:
    case S.Frame{_,_,iteration,_,pending,retry,+handles,+method},(world,rows):pending_seen(iteration,phase,method,rows,retry,handles,optional(method,world,pending))
def run(phase:String,frame:S.Frame,world:F.World()) -> F.World() & Boundary:rows_seen(phase,frame,Logical.rows(world))
