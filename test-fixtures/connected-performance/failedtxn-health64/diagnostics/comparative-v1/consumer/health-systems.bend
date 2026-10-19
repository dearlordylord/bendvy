import Base
import ../../../method/method.bend as Method
import ../method/capture-call.bend as Capture
import ../../../method/json.bend as J
import ../../../../../../src/ecs/execution-context.bend as Ctx
import ../../../../../../src/ecs/trace-facts.bend as Facts
import ../../../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../consumer/health.bend as F
import ../../../consumer/health-events.bend as E
import health-local.bend as L
import health-registration.bend as Reg
import ../../../consumer/health-publications.bend as Publications
import ../../../consumer/health-family.bend as Family
import health-dispose.bend as Dispose
import health-call.bend as Call
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/local.bend as Local
import ../../../../../../src/ecs/system.bend as Sys
import ../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../../../src/ecs/event-family-routing.bend as Route

type Frame is Data:
  Frame{first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>,iteration:U32,phase:U32,pendingA:Maybe<&2,W.Handle<T.HealthSchema>>,retryB:Maybe<&2,W.Handle<T.HealthSchema>>,failed:List<&2,W.Handle<T.HealthSchema>>,publicCalls:List<&2,J.Value>,method:Method.State}
type Owners is Type:
  Owners{registered:Reg.Owners,dispose:Dispose.Registry(),frame:Frame}
type Shared is Type:
  Shared{meta:L.Meta(),tick:Nat,frame:Frame}
def Owned() -> Type:(L.Instance() & L.Instance()) & (Publications.Provider() & Dispose.Registry())
def Runtime() -> Type:Owned() & Shared
def pack(value:Owners) -> Runtime():
  match value:
    case Owners{Reg.Owners{a,b,pub,meta,tick},dispose,frame}:(((a,b),(pub,dispose)),Shared{meta,tick,frame})
def unpack(value:Runtime()) -> Owners:
  match value:
    case (((a,b),(pub,dispose)),Shared{meta,tick,frame}):Owners{Reg.Owners{a,b,pub,meta,tick},dispose,frame}
def LocalResult() -> Type:L.Instance() & (Shared & Sys.Outcome<F.World(),Unit,Unit>)
def PubResult() -> Type:Publications.Provider() & (Shared & Sys.Outcome<F.World(),Unit,Unit>)
def DisposeResult() -> Type:Dispose.Registry() & (Shared & Sys.Outcome<F.World(),Unit,Unit>)
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
    case Frame{first,second,iteration,+phase,_,_,_,publicCalls,method}:L.Args{meta,tick,target(a,first,second),iteration,is_prime(phase),invocation_outcome(a,phase)}
def append_failed(old:List<&2,W.Handle<T.HealthSchema>>,handle:Maybe<&2,W.Handle<T.HealthSchema>>) -> List<&2,W.Handle<T.HealthSchema>>:
  match handle:
    case None{}:old
    case Some{handle}:List.append(&2,W.Handle<T.HealthSchema>,old,[handle])
def local_frame_call(a:Bool,frame:Frame,handle:Maybe<&2,W.Handle<T.HealthSchema>>) -> Frame:
  match a frame:
    case True{},Frame{first,second,iteration,phase,_,retry,failed,publicCalls,method}:Frame{first,second,iteration,phase,handle,retry,failed,publicCalls,method}
    case False{},Frame{first,second,iteration,1,pending,retry,failed,publicCalls,method}:Frame{first,second,iteration,1,pending,retry,append_failed(failed,handle),publicCalls,method}
    case False{},Frame{first,second,iteration,3,pending,_,failed,publicCalls,method}:Frame{first,second,iteration,3,pending,handle,failed,publicCalls,method}
    case False{},frame:frame
def status(value:L.Call) -> L.Call & Bool:
  match value:
    case L.ACall{+outcome,output}:(L.ACall{outcome,output},Tx.committed(~U32,outcome))
    case L.BCall{+state,error,output}:(L.BCall{state,error,output},U32.is_eq(state,0))
def called(status:L.Call & Bool) -> Bool & (L.Call & Maybe<&2,W.Handle<T.HealthSchema>>):
  match status:
    case (call,ok):(ok,Call.harvest(call))
def outcome(world:F.World(),ok:Bool) -> Sys.Outcome<F.World(),Unit,Unit>:
  match ok:
    case True{}:Sys.Succeeded{world,Unit{}}
    case False{}:Sys.Failed{world,Unit{}}
def local_captured(a:Bool,frame:Frame,meta:L.Meta(),tick:Nat,world:F.World(),ok:Bool,handle:Maybe<&2,W.Handle<T.HealthSchema>>,captured:L.Instance() & (L.Call & Method.State)) -> LocalResult():
  match frame captured:
    case Frame{first,second,i,phase,pending,retry,failed,publicCalls,_},(instance,(_,method)):(instance,(Shared{meta,tick,local_frame_call(a,Frame{first,second,i,phase,pending,retry,failed,publicCalls,method},handle)},outcome(world,ok)))
def local_capture_handle(+a:Bool,+frame:Frame,meta:L.Meta(),tick:Nat,world:F.World(),ok:Bool,call:L.Call,+handle:Maybe<&2,W.Handle<T.HealthSchema>>,instance:L.Instance()) -> LocalResult():
  match frame:
    case Frame{_,_,i,phase,_,_,_,publicCalls,method}:local_captured(a,frame,meta,tick,world,ok,handle,Capture.local(a,i,phase,method,handle,instance,call))
def local_capturing(a:Bool,frame:Frame,meta:L.Meta(),tick:Nat,world:F.World(),instance:L.Instance(),result:Bool & (L.Call & Maybe<&2,W.Handle<T.HealthSchema>>)) -> LocalResult():
  (ok,(call,handle))=result
  local_capture_handle(a,frame,meta,tick,world,ok,call,handle,instance)
def local_returned(a:Bool,frame:Frame,result:Local.Run<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),L.State,L.Args,Empty,L.Returned,L.runner>) -> LocalResult():
  match result:
    case Local.Completed{world,instance,Done{L.Returned{meta,tick,call}}}:local_capturing(a,frame,meta,tick,world,instance,called(status(call)))
    case Local.Completed{_,_,Fail{impossible}}:Empty.absurd(LocalResult(),impossible)
    case Local.Refused{world,instance,L.Args{meta,tick,_,_,_,_}}:(instance,(Shared{meta,tick,frame},Sys.Failed{world,Unit{}}))
def local_run(+a:Bool,instance:L.Instance(),shared:Shared,world:F.World()) -> LocalResult():
  match shared:
    case Shared{meta,tick,+frame}:local_returned(a,frame,Local.run(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~L.State,~L.Args,~Empty,~L.Returned,~L.runner,instance,world,args(a,meta,tick,frame)))
def frame_method(frame:Frame,record:J.Value) -> Frame:
  match frame:
    case Frame{first,second,i,phase,pending,retry,failed,publicCalls,method}:Frame{first,second,i,phase,pending,retry,failed,publicCalls,Method.append(method,record)}
def pub_context(frame:Frame,+status:U32,value:Maybe<&2,Publications.Read>,provider:Publications.Provider(),context:Family.Context()) -> PubResult():
  match context:
    case Route.Runtime{world,meta,tick}:(provider,(Shared{meta,tick,frame_method(frame,Capture.publication(status,value))},outcome(world,U32.is_eq(status,0))))
def pub_returned(frame:Frame,result:Publications.Run()) -> PubResult():
  match result:
    case Ordinary.RunCompleted{context,provider,output}:pub_context(frame,0,Some{output},provider,context)
    case Ordinary.RunFailed{context,provider,_,output}:pub_context(frame,1,Some{output},provider,context)
    case Ordinary.RunInvalidReader{context,provider}:pub_context(frame,2,None{},provider,context)
    case Ordinary.RunRegistrationRejected{context,provider,_}:pub_context(frame,3,None{},provider,context)
    case Ordinary.RunSkipped{context,provider}:pub_context(frame,4,None{},provider,context)
def pub_args(frame:Frame) -> Publications.Args:
  match frame:
    case Frame{_,_,iteration,phase,_,_,_,publicCalls,_}:Publications.Args{phase,iteration}
def pub_run(provider:Publications.Provider(),shared:Shared,world:F.World()) -> PubResult():
  match shared:
    case Shared{meta,tick,+frame}:pub_returned(frame,Publications.run(provider,Route.Runtime{world,meta,tick},pub_args(frame)))
def optional_handle(value:Maybe<&2,W.Handle<T.HealthSchema>>) -> List<&2,W.Handle<T.HealthSchema>>:
  match value:
    case None{}:[]
    case Some{value}:[value]
def transients(frame:Frame) -> List<&2,W.Handle<T.HealthSchema>>:
  match frame:
    case Frame{_,_,_,_,pending,retry,_,publicCalls,_}:List.append(&2,W.Handle<T.HealthSchema>,optional_handle(pending),optional_handle(retry))
def command_status(value:W.Status) -> J.Value:
  match value:
    case W.Accepted{}:J.object([J.Field{"kind",J.Text{"Accepted"}}])
    case W.Rejected{error}:J.object([J.Field{"kind",J.Text{"Rejected"}},J.Field{"error",Capture.world_error(error)}])
def dispose_outcome(value:Tx.Outcome<Unit>) -> J.Value:
  match value:
    case Tx.Success{}:J.object([J.Field{"kind",J.Text{"Success"}}])
    case Tx.Failure{_}:J.object([J.Field{"kind",J.Text{"Failure"}},J.Field{"value",J.Null{}}])
def disposed_frame(frame:Frame,statuses:List<&2,W.Status>,result:Tx.Outcome<Unit>) -> Frame:
  match frame:
    case Frame{first,second,+iteration,phase,pending,retry,failed,publicCalls,method}:Frame{first,second,iteration,phase,pending,retry,failed,List.append(&2,J.Value,publicCalls,[J.object([J.Field{"kind",J.Text{"DisposePublic"}},J.Field{"iteration",Method.number(iteration)},J.Field{"statuses",J.array(Method.values(~W.Status,~command_status,statuses))},J.Field{"outcome",dispose_outcome(result)}])]),method}
def disposed(meta:L.Meta(),tick:Nat,frame:Frame,result:Sys.RunResult<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),List<&2,W.Handle<T.HealthSchema>>,Empty,Dispose.Output,Dispose.runner>) -> DisposeResult():
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,Dispose.Output{statuses,outcome}}}:(registry,(Shared{meta,tick,disposed_frame(frame,statuses,outcome)},Sys.Succeeded{world,Unit{}}))
    case Sys.Completed{_,Sys.Failed{_,impossible}}:Empty.absurd(DisposeResult(),impossible)
    case Sys.RegistrationRejected{registry,world,_}:(registry,(Shared{meta,tick,frame},Sys.Failed{world,Unit{}}))
def dispose_run(dispose:Dispose.Registry(),shared:Shared,world:F.World()) -> DisposeResult():
  match shared:
    case Shared{meta,tick,+frame}:disposed(meta,tick,frame,Sys.run(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~List<&2,W.Handle<T.HealthSchema>>,~Empty,~Dispose.Output,~Dispose.runner,dispose,world,transients(frame)))
def contextual(~Owned:Type,trace:Facts.State,result:Owned & (Shared & Sys.Outcome<F.World(),Unit,Unit>)) -> Owned & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):
  match result:
    case (owner,(shared,Sys.Succeeded{world,output})):(owner,(shared,Sys.Succeeded{Ctx.Context{world,trace},output}))
    case (owner,(shared,Sys.Failed{world,error})):(owner,(shared,Sys.Failed{Ctx.Context{world,trace},error}))
def invoke_a(owner:L.Instance(),shared:Shared,context:Ctx.Context<F.World()>) -> L.Instance() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):
  match context:
    case Ctx.Context{world,trace}:contextual(~L.Instance(),trace,local_run(True{},owner,shared,world))
def invoke_b(owner:L.Instance(),shared:Shared,context:Ctx.Context<F.World()>) -> L.Instance() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):
  match context:
    case Ctx.Context{world,trace}:contextual(~L.Instance(),trace,local_run(False{},owner,shared,world))
def invoke_pub(owner:Publications.Provider(),shared:Shared,context:Ctx.Context<F.World()>) -> Publications.Provider() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):
  match context:
    case Ctx.Context{world,trace}:contextual(~Publications.Provider(),trace,pub_run(owner,shared,world))
def invoke_dispose(owner:Dispose.Registry(),shared:Shared,context:Ctx.Context<F.World()>) -> Dispose.Registry() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):
  match context:
    case Ctx.Context{world,trace}:contextual(~Dispose.Registry(),trace,dispose_run(owner,shared,world))
def frame_public_calls(frame:Frame) -> Frame & List<&2,J.Value>:
  match frame:
    case Frame{first,second,iteration,phase,pending,retry,failed,+publicCalls,method}:(Frame{first,second,iteration,phase,pending,retry,failed,publicCalls,method},publicCalls)
def public_calls_returned(owned:Owned(),meta:L.Meta(),tick:Nat,value:Frame & List<&2,J.Value>) -> Runtime() & List<&2,J.Value>:
  match value:
    case (frame,calls):((owned,Shared{meta,tick,frame}),calls)
def public_calls(value:Runtime()) -> Runtime() & List<&2,J.Value>:
  match value:
    case (owned,Shared{meta,tick,frame}):public_calls_returned(owned,meta,tick,frame_public_calls(frame))
