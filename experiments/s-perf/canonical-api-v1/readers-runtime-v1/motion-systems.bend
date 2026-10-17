import Base
import motion-report-doc.bend as Doc
import motion-reader-observe.bend as RO
import motion.bend as F
import types.bend as T
import events.bend as E
import motion-domain.bend as D
import motion-family.bend as Family
import motion-reader.bend as Reader
import motion-parameters.bend as P
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../src/ecs/ordinary-reader-system.bend as O

type Args is Data:
  Args{operation:U32,frame:D.Frame}
def local_runner(world:F.World(),capture:Array<U32>,args:Args) -> Local.Outcome<F.World(),Array<U32>,Unit,D.Frame>:
  match args:
    case Args{0,frame}:D.spawn(world,capture,frame)
    case Args{1,frame}:D.update(world,capture,frame)
    case Args{_,frame}:D.dispose(world,capture,frame)
def Instance() -> Type:Local.Instance<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),Array<U32>,Args,Unit,D.Frame,local_runner>
type IDs is Data:
  IDs{spawn:U32,update:U32,dispose:U32,fast:U32,slow:U32}
type LocalCall is Data:
  LocalCall{id:U32,operation:U32,status:U32,frame:Maybe<&2,D.Frame>}
type ReadCall is Data:
  ReadCall{id:U32,status:U32,tick:Nat,output:Maybe<&2,Reader.Read>,before:Doc.Doc,after:Doc.Doc}
type Owners is Type:
  Owners{spawn:Instance(),update:Instance(),dispose:Instance(),fast:Reader.Provider(),slow:Reader.Provider(),meta:Mixed.State<T.MotionSchema,E.Publication,Family.Family,Unit>,tick:Nat,frame:D.Frame,phase:U32,ids:IDs,locals:List<&2,LocalCall>,reads:List<&2,ReadCall>}
def outcome(world:F.World(),status:U32) -> Sys.Outcome<F.World(),Unit,Unit>:
  match status:
    case 0:Sys.Succeeded{world,Unit{}}
    case _:Sys.Failed{world,Unit{}}
type LocalReturned is Type:
  LocalReturned{world:F.World(),instance:Instance(),status:U32,frame:Maybe<&2,D.Frame>}
def local_returned(result:Local.Run<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),Array<U32>,Args,Unit,D.Frame,local_runner>) -> LocalReturned:
  match result:
    case Local.Completed{world,owner,Done{frame}}:LocalReturned{world,owner,0,Some{frame}}
    case Local.Completed{world,owner,Fail{_}}:LocalReturned{world,owner,1,None{}}
    case Local.Refused{world,owner,_}:LocalReturned{world,owner,2,None{}}
def invoked(instance:Instance(),world:F.World(),operation:U32,frame:D.Frame) -> LocalReturned:
  local_returned(Local.run(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~Array<U32>,~Args,~Unit,~D.Frame,~local_runner,instance,world,Args{operation,D.fresh_frame(frame)}))
def next_frame(old:D.Frame,returned:Maybe<&2,D.Frame>) -> D.Frame:
  match returned:
    case None{}:old
    case Some{frame}:frame
def spawn_returned(update:Instance(),dispose:Instance(),fast:Reader.Provider(),slow:Reader.Provider(),meta:Mixed.State<T.MotionSchema,E.Publication,Family.Family,Unit>,tick:Nat,frame:D.Frame,+phase:U32,ids:IDs,locals:List<&2,LocalCall>,reads:List<&2,ReadCall>,+id:U32,result:LocalReturned) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match result:
    case LocalReturned{world,instance,+status,+returned}:(Owners{instance,update,dispose,fast,slow,meta,tick,next_frame(frame,returned),phase,ids,LocalCall{id,0,status,returned} <> locals,reads},outcome(world,status))
def spawn_run(owners:Owners,world:F.World(),id:U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match owners:
    case Owners{spawn,update,dispose,fast,slow,meta,tick,+frame,phase,ids,locals,reads}:spawn_returned(update,dispose,fast,slow,meta,tick,frame,phase,ids,locals,reads,id,invoked(spawn,world,0,frame))
def update_returned(spawn:Instance(),dispose:Instance(),fast:Reader.Provider(),slow:Reader.Provider(),meta:Mixed.State<T.MotionSchema,E.Publication,Family.Family,Unit>,tick:Nat,frame:D.Frame,+phase:U32,ids:IDs,locals:List<&2,LocalCall>,reads:List<&2,ReadCall>,+id:U32,result:LocalReturned) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match result:
    case LocalReturned{world,instance,+status,+returned}:(Owners{spawn,instance,dispose,fast,slow,meta,tick,next_frame(frame,returned),phase,ids,LocalCall{id,1,status,returned} <> locals,reads},outcome(world,status))
def update_run(owners:Owners,world:F.World(),id:U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match owners:
    case Owners{spawn,update,dispose,fast,slow,meta,tick,+frame,phase,ids,locals,reads}:update_returned(spawn,dispose,fast,slow,meta,tick,frame,phase,ids,locals,reads,id,invoked(update,world,1,frame))
def dispose_returned(spawn:Instance(),update:Instance(),fast:Reader.Provider(),slow:Reader.Provider(),meta:Mixed.State<T.MotionSchema,E.Publication,Family.Family,Unit>,tick:Nat,frame:D.Frame,+phase:U32,ids:IDs,locals:List<&2,LocalCall>,reads:List<&2,ReadCall>,+id:U32,result:LocalReturned) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match result:
    case LocalReturned{world,instance,+status,+returned}:(Owners{spawn,update,instance,fast,slow,meta,tick,next_frame(frame,returned),phase,ids,LocalCall{id,2,status,returned} <> locals,reads},outcome(world,status))
def dispose_run(owners:Owners,world:F.World(),id:U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match owners:
    case Owners{spawn,update,dispose,fast,slow,meta,tick,+frame,phase,ids,locals,reads}:dispose_returned(spawn,update,fast,slow,meta,tick,frame,phase,ids,locals,reads,id,invoked(dispose,world,2,frame))
type ReaderReturned is Type:
  ReaderReturned{context:Family.Context(),provider:Reader.Provider(),status:U32,output:Maybe<&2,Reader.Read>,before:Doc.Doc,after:Doc.Doc}
def reader_captured(before:Doc.Doc,status:U32,output:Maybe<&2,Reader.Read>,observedProvider:Reader.Provider() & String,observedContext:Family.Context() & Doc.Doc) -> ReaderReturned:
  (provider,sp)=observedProvider
  (context,sc)=observedContext
  ReaderReturned{context,provider,status,output,before,Doc.concat([Doc.text("provider={" ++ sp ++ "};context={"),sc,Doc.text("}")])}
def reader_returned(before:Doc.Doc,result:Reader.Run()) -> ReaderReturned:
  match result:
    case O.RunCompleted{context,provider,output}:reader_captured(before,0,Some{output},RO.provider(provider),RO.doc_context(context))
    case O.RunFailed{context,provider,_,output}:reader_captured(before,1,Some{output},RO.provider(provider),RO.doc_context(context))
    case O.RunInvalidReader{context,provider}:reader_captured(before,2,None{},RO.provider(provider),RO.doc_context(context))
    case O.RunRegistrationRejected{context,provider,_}:reader_captured(before,3,None{},RO.provider(provider),RO.doc_context(context))
    case O.RunSkipped{context,provider}:reader_captured(before,4,None{},RO.provider(provider),RO.doc_context(context))
def read_observed(args:Reader.Args,observedProvider:Reader.Provider() & String,observedContext:Family.Context() & Doc.Doc) -> ReaderReturned:
  (provider,sp)=observedProvider
  (context,sc)=observedContext
  reader_returned(Doc.concat([Doc.text("provider={" ++ sp ++ "};context={"),sc,Doc.text("}")]),Reader.run(provider,context,args))
def read_run(provider:Reader.Provider(),context:Family.Context(),args:Reader.Args) -> ReaderReturned:read_observed(args,RO.provider(provider),RO.doc_context(context))
def iteration(frame:D.Frame) -> D.Frame & U32:
  match frame:
    case D.Frame{count,+i,transient,reservations,facts}:(D.Frame{count,i,transient,reservations,facts},i)
def fast_returned(spawn:Instance(),update:Instance(),dispose:Instance(),slow:Reader.Provider(),frame:D.Frame,+phase:U32,ids:IDs,locals:List<&2,LocalCall>,reads:List<&2,ReadCall>,+id:U32,result:ReaderReturned) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match result:
    case ReaderReturned{Route.Runtime{world,meta,+tick},provider,+status,+output,before,after}:(Owners{spawn,update,dispose,provider,slow,meta,tick,frame,phase,ids,locals,ReadCall{id,status,tick,output,before,after} <> reads},outcome(world,status))
def fast_iteration(spawn:Instance(),update:Instance(),dispose:Instance(),fast:Reader.Provider(),slow:Reader.Provider(),meta:Mixed.State<T.MotionSchema,E.Publication,Family.Family,Unit>,tick:Nat,+phase:U32,ids:IDs,locals:List<&2,LocalCall>,reads:List<&2,ReadCall>,world:F.World(),id:U32,observed:D.Frame & U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match observed:
    case (frame,i):fast_returned(spawn,update,dispose,slow,frame,phase,ids,locals,reads,id,read_run(fast,Route.Runtime{world,meta,tick},Reader.Args{0,phase,i}))
def fast_run(owners:Owners,world:F.World(),id:U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match owners:
    case Owners{spawn,update,dispose,fast,slow,meta,tick,+frame,phase,ids,locals,reads}:fast_iteration(spawn,update,dispose,fast,slow,meta,tick,phase,ids,locals,reads,world,id,iteration(frame))
def slow_returned(spawn:Instance(),update:Instance(),dispose:Instance(),fast:Reader.Provider(),frame:D.Frame,+phase:U32,ids:IDs,locals:List<&2,LocalCall>,reads:List<&2,ReadCall>,+id:U32,result:ReaderReturned) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match result:
    case ReaderReturned{Route.Runtime{world,meta,+tick},provider,+status,+output,before,after}:(Owners{spawn,update,dispose,fast,provider,meta,tick,frame,phase,ids,locals,ReadCall{id,status,tick,output,before,after} <> reads},outcome(world,status))
def slow_iteration(spawn:Instance(),update:Instance(),dispose:Instance(),fast:Reader.Provider(),slow:Reader.Provider(),meta:Mixed.State<T.MotionSchema,E.Publication,Family.Family,Unit>,tick:Nat,+phase:U32,ids:IDs,locals:List<&2,LocalCall>,reads:List<&2,ReadCall>,world:F.World(),id:U32,observed:D.Frame & U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match observed:
    case (frame,i):slow_returned(spawn,update,dispose,fast,frame,phase,ids,locals,reads,id,read_run(slow,Route.Runtime{world,meta,tick},Reader.Args{1,phase,i}))
def slow_run(owners:Owners,world:F.World(),id:U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match owners:
    case Owners{spawn,update,dispose,fast,slow,meta,tick,+frame,phase,ids,locals,reads}:slow_iteration(spawn,update,dispose,fast,slow,meta,tick,phase,ids,locals,reads,world,id,iteration(frame))
def dispatch_slow(allowed:Bool,owners:Owners,world:F.World(),+wanted:U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match allowed:
    case True{}:slow_run(owners,world,wanted)
    case False{}:(owners,Sys.Failed{world,Unit{}})
def dispatch_fast(allowed:Bool,owners:Owners,world:F.World(),+wanted:U32,slow:U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match allowed:
    case True{}:fast_run(owners,world,wanted)
    case False{}:dispatch_slow(U32.is_eq(wanted,slow),owners,world,wanted)
def dispatch_dispose(allowed:Bool,owners:Owners,world:F.World(),+wanted:U32,fast:U32,slow:U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match allowed:
    case True{}:dispose_run(owners,world,wanted)
    case False{}:dispatch_fast(U32.is_eq(wanted,fast),owners,world,wanted,slow)
def dispatch_update(allowed:Bool,owners:Owners,world:F.World(),+wanted:U32,dispose:U32,fast:U32,slow:U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match allowed:
    case True{}:update_run(owners,world,wanted)
    case False{}:dispatch_dispose(U32.is_eq(wanted,dispose),owners,world,wanted,fast,slow)
def dispatch_spawn(allowed:Bool,owners:Owners,world:F.World(),+wanted:U32,update:U32,dispose:U32,fast:U32,slow:U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match allowed:
    case True{}:spawn_run(owners,world,wanted)
    case False{}:dispatch_update(U32.is_eq(wanted,update),owners,world,wanted,dispose,fast,slow)
def dispatch_ids(owners:Owners,world:F.World(),+wanted:U32,ids:IDs) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match ids:
    case IDs{spawn,update,dispose,fast,slow}:dispatch_spawn(U32.is_eq(wanted,spawn),owners,world,wanted,update,dispose,fast,slow)
def run(owners:Owners,world:F.World(),wanted:U32) -> Owners & Sys.Outcome<F.World(),Unit,Unit>:
  match owners:
    case Owners{spawn,update,dispose,fast,slow,meta,tick,frame,phase,+ids,locals,reads}:dispatch_ids(Owners{spawn,update,dispose,fast,slow,meta,tick,frame,phase,ids,locals,reads},world,wanted,ids)
