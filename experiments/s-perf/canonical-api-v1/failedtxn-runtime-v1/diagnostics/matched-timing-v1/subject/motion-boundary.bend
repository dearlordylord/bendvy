import Base
import report-doc.bend as Doc
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/payload.bend as P
import motion.bend as F
import events.bend as E
import motion-systems.bend as S
import motion-registration.bend as Reg
import motion-observe.bend as O
import motion-doc-world.bend as DW
import motion-render.bend as Render
import motion-owner-observe.bend as Owners
import /tmp/bendvy-failedtxn-matched-method/src/ecs/world.bend as W
import /tmp/bendvy-failedtxn-matched-method/src/ecs/component.bend as Cmp

type Boundary is Data:
  Boundary{iteration:U32,phase:String,before:Doc.Doc,rows:Doc.Doc,pending:String,failed:String,retry:String,allFailed:List<&2,String>,after:Doc.Doc,owners:String}
def lookup_result(result:F.World() & Cmp.Access<T.PositionView>) -> F.World() & String:
  match result:
    case (world,value):(world,Render.access(value))
def lookup(world:F.World(),handle:W.Handle<T.MotionSchema>) -> F.World() & String:
  lookup_result(Cmp.get(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,F.main_family(),world,handle))
def optional(world:F.World(),handle:Maybe<&2,W.Handle<T.MotionSchema>>) -> F.World() & String:
  match handle:
    case None{}:(world,"None")
    case Some{handle}:lookup(world,handle)
def recent_go(values:List<&2,W.Handle<T.MotionSchema>>,prior:Maybe<&2,W.Handle<T.MotionSchema>>) -> Maybe<&2,W.Handle<T.MotionSchema>>:
  match values:
    case []:prior
    case head <> rest:recent_go(rest,Some{head})
def failed_next(next:(F.World() & List<&2,String>) -> F.World() & List<&2,String>,values:List<&2,String>,observed:F.World() & String) -> F.World() & List<&2,String>:
  match observed:
    case (world,text):next((world,List.append(&2,String,values,[text])))
def all_failed(handles:List<&2,W.Handle<T.MotionSchema>>,state:F.World() & List<&2,String>) -> F.World() & List<&2,String>:
  match handles state:
    case [], state:state
    case +handle <> rest, (world,values):failed_next(state=>all_failed(rest,state),values,lookup(world,handle))
def final(iteration:U32,phase:String,before:Doc.Doc,rows:Doc.Doc,pending:String,failed:String,retry:String,all:List<&2,String>,owners:String,observed:F.World() & Doc.Doc) -> F.World() & Boundary:
  match observed:
    case (world,after):(world,Boundary{iteration,phase,before,rows,pending,failed,retry,all,after,owners})
def failed_all(iteration:U32,phase:String,before:Doc.Doc,rows:Doc.Doc,pending:String,failed:String,retry:String,owners:String,observed:F.World() & List<&2,String>) -> F.World() & Boundary:
  match observed:
    case (world,values):final(iteration,phase,before,rows,pending,failed,retry,values,owners,DW.world(world))
def retry_seen(iteration:U32,phase:String,before:Doc.Doc,rows:Doc.Doc,pending:String,failed:String,owners:String,handles:List<&2,W.Handle<T.MotionSchema>>,observed:F.World() & String) -> F.World() & Boundary:
  match observed:
    case (world,retry):failed_all(iteration,phase,before,rows,pending,failed,retry,owners,all_failed(handles,(world,[])))
def failed_seen(iteration:U32,phase:String,before:Doc.Doc,rows:Doc.Doc,pending:String,owners:String,retry:Maybe<&2,W.Handle<T.MotionSchema>>,handles:List<&2,W.Handle<T.MotionSchema>>,observed:F.World() & String) -> F.World() & Boundary:
  match observed:
    case (world,failed):retry_seen(iteration,phase,before,rows,pending,failed,owners,handles,optional(world,retry))
def pending_seen(iteration:U32,phase:String,before:Doc.Doc,rows:Doc.Doc,owners:String,retry:Maybe<&2,W.Handle<T.MotionSchema>>,+handles:List<&2,W.Handle<T.MotionSchema>>,observed:F.World() & String) -> F.World() & Boundary:
  match observed:
    case (world,pending):failed_seen(iteration,phase,before,rows,pending,owners,retry,handles,optional(world,recent_go(handles,None{})))
def rows_seen(phase:String,owners:String,frame:S.Frame,before:Doc.Doc,observed:F.World() & Doc.Doc) -> F.World() & Boundary:
  match frame observed:
    case S.Frame{_,_,iteration,_,pending,retry,handles,_}, (world,rows):pending_seen(iteration,phase,before,rows,owners,retry,handles,optional(world,pending))
def before_seen(phase:String,owners:String,frame:S.Frame,observed:F.World() & Doc.Doc) -> F.World() & Boundary:
  match observed:
    case (world,before):rows_seen(phase,owners,frame,before,DW.rows(world))
def run(phase:String,owners:String,frame:S.Frame,world:F.World()) -> F.World() & Boundary:before_seen(phase,owners,frame,DW.world(world))
def failed_doc(value:String) -> Doc.Doc:Doc.text(O.audit_effect(value))
def render(value:Boundary) -> Doc.Doc:
  match value:
    case Boundary{iteration,phase,before,rows,pending,failed,retry,all,after,owners}:Doc.concat([Doc.text("iteration="),Doc.text(U32.show(iteration)),Doc.text(";phase="),Doc.text(O.audit_effect(phase)),Doc.text(";before={"),before,Doc.text("};rows="),rows,Doc.text(";pending="),Doc.text(pending),Doc.text(";failed="),Doc.text(failed),Doc.text(";retry="),Doc.text(retry),Doc.text(";allFailed="),Doc.show(~String,~failed_doc,all),Doc.text(";after={"),after,Doc.text("};owners={"),Doc.text(owners),Doc.text("}")])
