import Base
import ../../../../dense-runtime-v1/types.bend as T
import ../../../../dense-runtime-v1/payload.bend as P
import health.bend as F
import health-events.bend as E
import health-systems.bend as S
import health-registration.bend as Reg
import health-observe.bend as O
import health-render.bend as Render
import health-owner-observe.bend as Owners
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/component.bend as Cmp

type Boundary is Data:
  Boundary{iteration:U32,phase:String,before:String,rows:String,pending:String,failed:String,retry:String,allFailed:List<&2,String>,after:String,owners:String}
def lookup_result(result:F.World() & Cmp.Access<T.VitalsView>) -> F.World() & String:
  match result:
    case (world,value):(world,Render.access(value))
def lookup(world:F.World(),handle:W.Handle<T.HealthSchema>) -> F.World() & String:
  lookup_result(Cmp.get(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.Rest(),~T.Vitals,~T.VitalsView,~T.VitalsToken,~F.take_main,~F.put_main,~P.vitals_get,F.main_family(),world,handle))
def optional(world:F.World(),handle:Maybe<&2,W.Handle<T.HealthSchema>>) -> F.World() & String:
  match handle:
    case None{}:(world,"None")
    case Some{handle}:lookup(world,handle)
def recent_go(values:List<&2,W.Handle<T.HealthSchema>>,prior:Maybe<&2,W.Handle<T.HealthSchema>>) -> Maybe<&2,W.Handle<T.HealthSchema>>:
  match values:
    case []:prior
    case head <> rest:recent_go(rest,Some{head})
def failed_next(next:(F.World() & List<&2,String>) -> F.World() & List<&2,String>,values:List<&2,String>,observed:F.World() & String) -> F.World() & List<&2,String>:
  match observed:
    case (world,text):next((world,List.append(&2,String,values,[text])))
def all_failed(handles:List<&2,W.Handle<T.HealthSchema>>,state:F.World() & List<&2,String>) -> F.World() & List<&2,String>:
  match handles state:
    case [], state:state
    case +handle <> rest, (world,values):failed_next(state=>all_failed(rest,state),values,lookup(world,handle))
def final(iteration:U32,phase:String,before:String,rows:String,pending:String,failed:String,retry:String,all:List<&2,String>,owners:String,observed:F.World() & String) -> F.World() & Boundary:
  match observed:
    case (world,after):(world,Boundary{iteration,phase,before,rows,pending,failed,retry,all,after,owners})
def failed_all(iteration:U32,phase:String,before:String,rows:String,pending:String,failed:String,retry:String,owners:String,observed:F.World() & List<&2,String>) -> F.World() & Boundary:
  match observed:
    case (world,values):final(iteration,phase,before,rows,pending,failed,retry,values,owners,O.world(world))
def retry_seen(iteration:U32,phase:String,before:String,rows:String,pending:String,failed:String,owners:String,handles:List<&2,W.Handle<T.HealthSchema>>,observed:F.World() & String) -> F.World() & Boundary:
  match observed:
    case (world,retry):failed_all(iteration,phase,before,rows,pending,failed,retry,owners,all_failed(handles,(world,[])))
def failed_seen(iteration:U32,phase:String,before:String,rows:String,pending:String,owners:String,retry:Maybe<&2,W.Handle<T.HealthSchema>>,handles:List<&2,W.Handle<T.HealthSchema>>,observed:F.World() & String) -> F.World() & Boundary:
  match observed:
    case (world,failed):retry_seen(iteration,phase,before,rows,pending,failed,owners,handles,optional(world,retry))
def pending_seen(iteration:U32,phase:String,before:String,rows:String,owners:String,retry:Maybe<&2,W.Handle<T.HealthSchema>>,+handles:List<&2,W.Handle<T.HealthSchema>>,observed:F.World() & String) -> F.World() & Boundary:
  match observed:
    case (world,pending):failed_seen(iteration,phase,before,rows,pending,owners,retry,handles,optional(world,recent_go(handles,None{})))
def rows_seen(phase:String,owners:String,frame:S.Frame,before:String,observed:F.World() & String) -> F.World() & Boundary:
  match frame observed:
    case S.Frame{_,_,iteration,_,pending,retry,handles,_}, (world,rows):pending_seen(iteration,phase,before,rows,owners,retry,handles,optional(world,pending))
def before_seen(phase:String,owners:String,frame:S.Frame,observed:F.World() & String) -> F.World() & Boundary:
  match observed:
    case (world,before):rows_seen(phase,owners,frame,before,O.rows(world))
def run(phase:String,owners:String,frame:S.Frame,world:F.World()) -> F.World() & Boundary:before_seen(phase,owners,frame,O.world(world))
def render(value:Boundary) -> String:
  match value:
    case Boundary{iteration,phase,before,rows,pending,failed,retry,all,after,owners}:"iteration=" ++ U32.show(iteration) ++ ";phase=" ++ O.audit_effect(phase) ++ ";before={" ++ before ++ "};rows=" ++ rows ++ ";pending=" ++ pending ++ ";failed=" ++ failed ++ ";retry=" ++ retry ++ ";allFailed=" ++ List.show(&2,String,O.audit_effect,all) ++ ";after={" ++ after ++ "};owners={" ++ owners ++ "}"
