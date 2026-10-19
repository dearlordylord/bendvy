import Base
import ../../../method/method.bend as Method
import ../method/capture-call.bend as Capture
import ../../../method/json.bend as J
import ../../../../../../src/ecs/execution-context.bend as Ctx
import ../../../../../../src/ecs/trace-facts.bend as Facts
import ../../../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../consumer/motion.bend as F
import ../../../consumer/events.bend as E
import motion-local.bend as L
import motion-registration.bend as Reg
import ../../../consumer/motion-publications.bend as Publications
import ../../../consumer/motion-family.bend as Family
import motion-dispose.bend as Dispose
import motion-call.bend as Call
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/local.bend as Local
import ../../../../../../src/ecs/system.bend as Sys
import ../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../../../src/ecs/event-family-routing.bend as Route

type Frame is Data:
  Frame{first:W.Handle<T.MotionSchema>,second:W.Handle<T.MotionSchema>,iteration:U32,phase:U32,pendingA:Maybe<&2,W.Handle<T.MotionSchema>>,retryB:Maybe<&2,W.Handle<T.MotionSchema>>,failed:List<&2,W.Handle<T.MotionSchema>>,method:Method.State}
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
def target(a:Bool,first:W.Handle<T.MotionSchema>,second:W.Handle<T.MotionSchema>) -> W.Handle<T.MotionSchema>:
  match a:
    case True{}:first
    case False{}:second
def args(+a:Bool,meta:L.Meta(),tick:Nat,frame:Frame) -> L.Args:
  match frame:
    case Frame{first,second,iteration,+phase,_,_,_,method}:L.Args{meta,tick,target(a,first,second),iteration,is_prime(phase),invocation_outcome(a,phase)}
def append_failed(old:List<&2,W.Handle<T.MotionSchema>>,handle:Maybe<&2,W.Handle<T.MotionSchema>>) -> List<&2,W.Handle<T.MotionSchema>>:
  match handle:
    case None{}:old
    case Some{handle}:List.append(&2,W.Handle<T.MotionSchema>,old,[handle])
def local_frame_call(a:Bool,frame:Frame,handle:Maybe<&2,W.Handle<T.MotionSchema>>) -> Frame:
  match a frame:
    case True{},Frame{first,second,iteration,phase,_,retry,failed,method}:Frame{first,second,iteration,phase,handle,retry,failed,method}
    case False{},Frame{first,second,iteration,1,pending,retry,failed,method}:Frame{first,second,iteration,1,pending,retry,append_failed(failed,handle),method}
    case False{},Frame{first,second,iteration,3,pending,_,failed,method}:Frame{first,second,iteration,3,pending,handle,failed,method}
    case False{},frame:frame
def status(value:L.Call) -> L.Call & Bool:
  match value:
    case L.ACall{+outcome,output}:(L.ACall{outcome,output},Tx.committed(~U32,outcome))
    case L.BCall{+state,error,output}:(L.BCall{state,error,output},U32.is_eq(state,0))
def called(status:L.Call & Bool) -> Bool & (L.Call & Maybe<&2,W.Handle<T.MotionSchema>>):
  match status:
    case (call,ok):(ok,Call.harvest(call))
def outcome(world:F.World(),ok:Bool) -> Sys.Outcome<F.World(),Unit,Unit>:
  match ok:
    case True{}:Sys.Succeeded{world,Unit{}}
    case False{}:Sys.Failed{world,Unit{}}
def local_captured(a:Bool,frame:Frame,meta:L.Meta(),tick:Nat,world:F.World(),ok:Bool,handle:Maybe<&2,W.Handle<T.MotionSchema>>,captured:L.Instance() & (L.Call & Method.State)) -> LocalResult():
  match frame captured:
    case Frame{first,second,i,phase,pending,retry,failed,_},(instance,(_,method)):(instance,(Shared{meta,tick,local_frame_call(a,Frame{first,second,i,phase,pending,retry,failed,method},handle)},outcome(world,ok)))
def local_capture_handle(+a:Bool,+frame:Frame,meta:L.Meta(),tick:Nat,world:F.World(),ok:Bool,call:L.Call,+handle:Maybe<&2,W.Handle<T.MotionSchema>>,instance:L.Instance()) -> LocalResult():
  match frame:
    case Frame{_,_,i,phase,_,_,_,method}:local_captured(a,frame,meta,tick,world,ok,handle,Capture.local(a,i,phase,method,handle,instance,call))
def local_capturing(a:Bool,frame:Frame,meta:L.Meta(),tick:Nat,world:F.World(),instance:L.Instance(),result:Bool & (L.Call & Maybe<&2,W.Handle<T.MotionSchema>>)) -> LocalResult():
  (ok,(call,handle))=result
  local_capture_handle(a,frame,meta,tick,world,ok,call,handle,instance)
def local_returned(a:Bool,frame:Frame,result:Local.Run<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),L.State,L.Args,Empty,L.Returned,L.runner>) -> LocalResult():
  match result:
    case Local.Completed{world,instance,Done{L.Returned{meta,tick,call}}}:local_capturing(a,frame,meta,tick,world,instance,called(status(call)))
    case Local.Completed{_,_,Fail{impossible}}:Empty.absurd(LocalResult(),impossible)
    case Local.Refused{world,instance,L.Args{meta,tick,_,_,_,_}}:(instance,(Shared{meta,tick,frame},Sys.Failed{world,Unit{}}))
def local_run(+a:Bool,instance:L.Instance(),shared:Shared,world:F.World()) -> LocalResult():
  match shared:
    case Shared{meta,tick,+frame}:local_returned(a,frame,Local.run(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~L.State,~L.Args,~Empty,~L.Returned,~L.runner,instance,world,args(a,meta,tick,frame)))
def frame_method(frame:Frame,record:J.Value) -> Frame:
  match frame:
    case Frame{first,second,i,phase,pending,retry,failed,method}:Frame{first,second,i,phase,pending,retry,failed,Method.append(method,record)}
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
    case Frame{_,_,iteration,phase,_,_,_,_}:Publications.Args{phase,iteration}
def pub_run(provider:Publications.Provider(),shared:Shared,world:F.World()) -> PubResult():
  match shared:
    case Shared{meta,tick,+frame}:pub_returned(frame,Publications.run(provider,Route.Runtime{world,meta,tick},pub_args(frame)))
def optional_handle(value:Maybe<&2,W.Handle<T.MotionSchema>>) -> List<&2,W.Handle<T.MotionSchema>>:
  match value:
    case None{}:[]
    case Some{value}:[value]
def transients(frame:Frame) -> List<&2,W.Handle<T.MotionSchema>>:
  match frame:
    case Frame{_,_,_,_,pending,retry,_,_}:List.append(&2,W.Handle<T.MotionSchema>,optional_handle(pending),optional_handle(retry))
def disposed(meta:L.Meta(),tick:Nat,frame:Frame,result:Sys.RunResult<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),List<&2,W.Handle<T.MotionSchema>>,Empty,Dispose.Output,Dispose.runner>) -> DisposeResult():
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,_}}:(registry,(Shared{meta,tick,frame},Sys.Succeeded{world,Unit{}}))
    case Sys.Completed{_,Sys.Failed{_,impossible}}:Empty.absurd(DisposeResult(),impossible)
    case Sys.RegistrationRejected{registry,world,_}:(registry,(Shared{meta,tick,frame},Sys.Failed{world,Unit{}}))
def dispose_run(dispose:Dispose.Registry(),shared:Shared,world:F.World()) -> DisposeResult():
  match shared:
    case Shared{meta,tick,+frame}:disposed(meta,tick,frame,Sys.run(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~List<&2,W.Handle<T.MotionSchema>>,~Empty,~Dispose.Output,~Dispose.runner,dispose,world,transients(frame)))
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
