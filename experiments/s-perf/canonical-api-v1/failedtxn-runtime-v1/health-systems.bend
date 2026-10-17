import Base
import ../dense-runtime-v1/types.bend as T
import health.bend as F
import health-events.bend as E
import health-local.bend as L
import health-registration.bend as Reg
import health-reader.bend as Reader
import health-publications.bend as Publications
import health-family.bend as Family
import health-dispose.bend as Dispose
import health-call.bend as Call
import health-render.bend as Render
import health-reader-owner-observe.bend as RO
import health-runtime-observe.bend as RT
import health-observe.bend as O
import health-grants.bend as Grants
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../src/ecs/event-family-routing.bend as Route

type Frame is Data:
  Frame{first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>,iteration:U32,phase:U32,pendingA:Maybe<&2,W.Handle<T.HealthSchema>>,retryB:Maybe<&2,W.Handle<T.HealthSchema>>,failed:List<&2,W.Handle<T.HealthSchema>>,calls:List<&2,String>}
type Owners is Type:
  Owners{registered:Reg.Owners,dispose:Dispose.Registry(),frame:Frame}
def is_prime(phase:U32) -> Bool:U32.is_eq(phase,0)
def invocation_outcome(a:Bool,phase:U32) -> Tx.Outcome<U32>:
  match a phase:
    case False{}, 1:Tx.Failure{7}
    case _, _:Tx.Success{}
def target(a:Bool,first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>) -> W.Handle<T.HealthSchema>:
  match a:
    case True{}:first
    case False{}:second
def args(+a:Bool,meta:L.Meta(),tick:Nat,frame:Frame) -> L.Args:
  match frame:
    case Frame{first,second,iteration,+phase,_,_,_,_}:L.Args{meta,tick,target(a,first,second),iteration,is_prime(phase),invocation_outcome(a,phase)}
def id(instance:L.Instance()) -> L.Instance() & U32:
  match instance:
    case Local.Instance{namespace,+id,name,access,local}:(Local.Instance{namespace,id,name,access,local},id)
def append_failed(old:List<&2,W.Handle<T.HealthSchema>>,handle:Maybe<&2,W.Handle<T.HealthSchema>>) -> List<&2,W.Handle<T.HealthSchema>>:
  match handle:
    case None{}:old
    case Some{handle}:List.append(&2,W.Handle<T.HealthSchema>,old,[handle])
def frame_call(frame:Frame,_:Maybe<&2,W.Handle<T.HealthSchema>>,text:String) -> Frame:
  match frame:
    case Frame{first,second,iteration,phase,pending,retry,failed,calls}:Frame{first,second,iteration,phase,pending,retry,failed,List.append(&2,String,calls,[text])}
def local_frame_call(a:Bool,frame:Frame,handle:Maybe<&2,W.Handle<T.HealthSchema>>,text:String) -> Frame:
  match a frame:
    case True{}, Frame{first,second,iteration,phase,_,retry,failed,calls}:Frame{first,second,iteration,phase,handle,retry,failed,List.append(&2,String,calls,[text])}
    case False{}, Frame{first,second,iteration,1,pending,retry,failed,calls}:Frame{first,second,iteration,1,pending,retry,append_failed(failed,handle),List.append(&2,String,calls,[text])}
    case False{}, Frame{first,second,iteration,3,pending,_,failed,calls}:Frame{first,second,iteration,3,pending,handle,failed,List.append(&2,String,calls,[text])}
    case False{}, frame:frame_call(frame,handle,text)
def status(value:L.Call) -> L.Call & Bool:
  match value:
    case L.ACall{+outcome,output,facts}:(L.ACall{outcome,output,facts},Tx.committed(~U32,outcome))
    case L.BCall{+state,error,output}:(L.BCall{state,error,output},U32.is_eq(state,0))
def called(status:L.Call & Bool) -> Bool & (L.Call & Maybe<&2,W.Handle<T.HealthSchema>>):
  match status:
    case (call,ok):(ok,Call.harvest(call))
def outcome(world:F.World(),ok:Bool) -> Sys.Outcome<F.World(),Unit,Unit>:
  match ok:
    case True{}:Sys.Succeeded{world,Unit{}}
    case False{}:Sys.Failed{world,Unit{}}
def rebuilt(a:Bool,selected:L.Instance(),other:L.Instance(),publications:Publications.Provider(),meta:L.Meta(),tick:Nat) -> Reg.Owners:
  match a:
    case True{}:Reg.Owners{selected,other,publications,meta,tick}
    case False{}:Reg.Owners{other,selected,publications,meta,tick}
def local_logged(+a:Bool,other:L.Instance(),publications:Publications.Provider(),dispose:Dispose.Registry(),frame:Frame,meta:L.Meta(),tick:Nat,world:F.World(),before:String,after:L.Instance() & String,result:Bool & (L.Call & Maybe<&2,W.Handle<T.HealthSchema>>)) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  (instance,after)=after
  (ok,(call,handle))=result
  (Owners{rebuilt(a,instance,other,publications,meta,tick),dispose,local_frame_call(a,frame,handle,"beforeLocal={" ++ before ++ "};afterLocal={" ++ after ++ "};call={" ++ Render.call(call) ++ "}")},outcome(world,ok))
def local_returned(a:Bool,other:L.Instance(),publications:Publications.Provider(),dispose:Dispose.Registry(),frame:Frame,before:String,result:Local.Run<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),L.State,L.Args,Empty,L.Returned,L.runner>) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match result:
    case Local.Completed{world,instance,Done{L.Returned{meta,tick,call}}}:local_logged(a,other,publications,dispose,frame,meta,tick,world,before,Render.instance(instance),called(status(call)))
    case Local.Completed{_,_,Fail{impossible}}:Empty.absurd((Owners & Sys.Outcome<F.World(),Unit,Unit>),impossible)
    case Local.Refused{world,instance,L.Args{meta,tick,_,_,_,_}}:(Owners{rebuilt(a,instance,other,publications,meta,tick),dispose,frame_call(frame,None{},"LocalRefused")},Sys.Failed{world,Unit{}})
def local_observed(+a:Bool,other:L.Instance(),publications:Publications.Provider(),dispose:Dispose.Registry(),+frame:Frame,meta:L.Meta(),tick:Nat,world:F.World(),observed:L.Instance() & String) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match observed:
    case (instance,before):local_returned(a,other,publications,dispose,frame,before,Local.run(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~L.State,~L.Args,~Empty,~L.Returned,~L.runner,instance,world,args(a,meta,tick,frame)))
def local_run(a:Bool,owners:Owners,world:F.World()) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match a owners:
    case True{}, Owners{Reg.Owners{selected,other,publications,meta,tick},dispose,frame}:local_observed(True{},other,publications,dispose,frame,meta,tick,world,Render.instance(selected))
    case False{}, Owners{Reg.Owners{other,selected,publications,meta,tick},dispose,frame}:local_observed(False{},other,publications,dispose,frame,meta,tick,world,Render.instance(selected))

def publication_text(value:Publications.Read) -> String:
  match value:
    case Publications.Read{Publications.Args{phase,iteration},view}:"phase=" ++ U32.show(phase) ++ ";iteration=" ++ U32.show(iteration) ++ ";view={" ++ Render.ping_view(view) ++ "}"
def maybe_publication(value:Maybe<&2,Publications.Read>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:"Some{" ++ publication_text(value) ++ "}"
def pub_restored(a:L.Instance(),b:L.Instance(),dispose:Dispose.Registry(),frame:Frame,before:String,+status:U32,value:Maybe<&2,Publications.Read>,world:F.World(),meta:L.Meta(),tick:Nat,observed:Publications.Provider() & String) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match observed:
    case (publications,after):(Owners{Reg.Owners{a,b,publications,meta,tick},dispose,frame_call(frame,None{},"Publications{before={" ++ before ++ "};after={" ++ after ++ "};status=" ++ U32.show(status) ++ ";read=" ++ maybe_publication(value) ++ "}")},outcome(world,U32.is_eq(status,0)))
def pub_context(a:L.Instance(),b:L.Instance(),dispose:Dispose.Registry(),frame:Frame,before:String,+status:U32,value:Maybe<&2,Publications.Read>,provider:Publications.Provider(),context:Family.Context()) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match context:
    case Route.Runtime{world,meta,tick}:pub_restored(a,b,dispose,frame,before,status,value,world,meta,tick,RO.publications(provider))
def pub_returned(a:L.Instance(),b:L.Instance(),dispose:Dispose.Registry(),frame:Frame,before:String,result:Publications.Run()) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match result:
    case Ordinary.RunCompleted{context,provider,output}:pub_context(a,b,dispose,frame,before,0,Some{output},provider,context)
    case Ordinary.RunFailed{context,provider,_,output}:pub_context(a,b,dispose,frame,before,1,Some{output},provider,context)
    case Ordinary.RunInvalidReader{context,provider}:pub_context(a,b,dispose,frame,before,2,None{},provider,context)
    case Ordinary.RunRegistrationRejected{context,provider,_}:pub_context(a,b,dispose,frame,before,3,None{},provider,context)
    case Ordinary.RunSkipped{context,provider}:pub_context(a,b,dispose,frame,before,4,None{},provider,context)
def pub_args(frame:Frame) -> Publications.Args:
  match frame:
    case Frame{_,_,iteration,phase,_,_,_,_}:Publications.Args{phase,iteration}
def pub_observed(a:L.Instance(),b:L.Instance(),dispose:Dispose.Registry(),+frame:Frame,world:F.World(),meta:L.Meta(),tick:Nat,observed:Publications.Provider() & String) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match observed:
    case (provider,before):pub_returned(a,b,dispose,frame,before,Publications.run(provider,Route.Runtime{world,meta,tick},pub_args(frame)))
def pub_run(owners:Owners,world:F.World()) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match owners:
    case Owners{Reg.Owners{a,b,pub,meta,tick},dispose,frame}:pub_observed(a,b,dispose,frame,world,meta,tick,RO.publications(pub))
def optional_handle(value:Maybe<&2,W.Handle<T.HealthSchema>>) -> List<&2,W.Handle<T.HealthSchema>>:
  match value:
    case None{}:[]
    case Some{value}:[value]
def transients(frame:Frame) -> List<&2,W.Handle<T.HealthSchema>>:
  match frame:
    case Frame{_,_,_,_,pending,retry,_,_}:List.append(&2,W.Handle<T.HealthSchema>,optional_handle(pending),optional_handle(retry))
def world_status(value:W.Status) -> String:
  match value:
    case W.Accepted{}:"Accepted"
    case W.Rejected{reason}:"Rejected{" ++ O.error(reason) ++ "}"
def disposed(registered:Reg.Owners,frame:Frame,result:Sys.RunResult<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),List<&2,W.Handle<T.HealthSchema>>,Empty,Dispose.Output,Dispose.runner>) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,Dispose.Output{statuses,facts,_}}}:(Owners{registered,registry,frame_call(frame,None{},"Dispose{statuses=" ++ List.show(&2,W.Status,world_status,statuses) ++ ";facts={" ++ Render.facts(facts) ++ "}}")},Sys.Succeeded{world,Unit{}})
    case Sys.Completed{_,Sys.Failed{_,impossible}}:Empty.absurd((Owners & Sys.Outcome<F.World(),Unit,Unit>),impossible)
    case Sys.RegistrationRejected{registry,world,_}:(Owners{registered,registry,frame_call(frame,None{},"DisposeRegistrationRejected")},Sys.Failed{world,Unit{}})
def dispose_run(owners:Owners,world:F.World()) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match owners:
    case Owners{registered,dispose,+frame}:disposed(registered,frame,Sys.run(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~List<&2,W.Handle<T.HealthSchema>>,~Empty,~Dispose.Output,~Dispose.runner,dispose,world,transients(frame)))

def dispatch_dispose_selected(selected:Bool,owners:Owners,world:F.World()) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match selected:
    case True{}:dispose_run(owners,world)
    case False{}:(owners,Sys.Failed{world,Unit{}})
def dispatch_dispose(target:U32,owners:Owners,world:F.World()) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match owners:
    case Owners{registered,Sys.Registry{ns,+id,name,access,cursor},frame}:dispatch_dispose_selected(U32.is_eq(target,id),Owners{registered,Sys.Registry{ns,id,name,access,cursor},frame},world)
def dispatch_pub_selected(selected:Bool,target:U32,owners:Owners,world:F.World()) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match selected:
    case True{}:pub_run(owners,world)
    case False{}:dispatch_dispose(target,owners,world)
def dispatch_pub(+target:U32,owners:Owners,world:F.World()) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match owners:
    case Owners{Reg.Owners{a,b,Ordinary.Provider{Sys.Registry{ns,+id,name,access,cursor},owner,param,decl},meta,tick},dispose,frame}:dispatch_pub_selected(U32.is_eq(target,id),target,Owners{Reg.Owners{a,b,Ordinary.Provider{Sys.Registry{ns,id,name,access,cursor},owner,param,decl},meta,tick},dispose,frame},world)
def dispatch_b_selected(selected:Bool,target:U32,owners:Owners,world:F.World()) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match selected:
    case True{}:local_run(False{},owners,world)
    case False{}:dispatch_pub(target,owners,world)
def dispatch_b(+target:U32,owners:Owners,world:F.World()) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match owners:
    case Owners{Reg.Owners{a,Local.Instance{ns,+id,name,access,local},pub,meta,tick},dispose,frame}:dispatch_b_selected(U32.is_eq(target,id),target,Owners{Reg.Owners{a,Local.Instance{ns,id,name,access,local},pub,meta,tick},dispose,frame},world)
def dispatch_a_selected(selected:Bool,target:U32,owners:Owners,world:F.World()) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match selected:
    case True{}:local_run(True{},owners,world)
    case False{}:dispatch_b(target,owners,world)
def dispatch(owners:Owners,world:F.World(),+target:U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match owners:
    case Owners{Reg.Owners{Local.Instance{ns,+id,name,access,local},b,pub,meta,tick},dispose,frame}:dispatch_a_selected(U32.is_eq(target,id),target,Owners{Reg.Owners{Local.Instance{ns,id,name,access,local},b,pub,meta,tick},dispose,frame},world)
def condition(world:F.World(),_:U32) -> F.World() & Bool:(world,True{})
