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

import ../../../../src/ecs/execution-context.bend as Ctx
import ../../../../src/ecs/trace-facts.bend as Facts
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
type Shared is Type:
  Shared{meta:Mixed.State<T.MotionSchema,E.Publication,Family.Family,Unit>,tick:Nat,frame:D.Frame,phase:U32,locals:List<&2,LocalCall>,reads:List<&2,ReadCall>,stage:U32}
def Owned() -> Type:(Instance() & Instance()) & (Instance() & (Reader.Provider() & Reader.Provider()))
def Runtime() -> Type:Owned() & Shared
def pack(stage:U32,value:Owners) -> Runtime():
  match value:
    case Owners{spawn,update,dispose,fast,slow,meta,tick,frame,phase,_,locals,reads}:(((spawn,update),(dispose,(fast,slow))),Shared{meta,tick,frame,phase,locals,reads,stage})
def unpack(value:Runtime()) -> Owners & U32:
  match value:
    case (((Local.Instance{ns0,+id0,name0,access0,cap0},Local.Instance{ns1,+id1,name1,access1,cap1}),(Local.Instance{ns2,+id2,name2,access2,cap2},(O.Provider{Sys.Registry{ns3,+id3,name3,access3,cursor3},reader3,param3,decl3},O.Provider{Sys.Registry{ns4,+id4,name4,access4,cursor4},reader4,param4,decl4}))),Shared{meta,tick,frame,phase,locals,reads,stage}):(Owners{Local.Instance{ns0,id0,name0,access0,cap0},Local.Instance{ns1,id1,name1,access1,cap1},Local.Instance{ns2,id2,name2,access2,cap2},O.Provider{Sys.Registry{ns3,id3,name3,access3,cursor3},reader3,param3,decl3},O.Provider{Sys.Registry{ns4,id4,name4,access4,cursor4},reader4,param4,decl4},meta,tick,frame,phase,IDs{id0,id1,id2,id3,id4},locals,reads},stage)
def outcome(trace:Facts.State,world:F.World(),status:U32) -> Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:
  match status:
    case 0:Sys.Succeeded{Ctx.Context{world,trace},Unit{}}
    case _:Sys.Failed{Ctx.Context{world,trace},Unit{}}
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
def local_done(operation:U32,id:U32,trace:Facts.State,shared:Shared,result:LocalReturned) -> Instance() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):
  match shared result:
    case Shared{meta,tick,frame,phase,locals,reads,stage},LocalReturned{world,instance,+status,+returned}:(instance,(Shared{meta,tick,next_frame(frame,returned),phase,LocalCall{id,operation,status,returned} <> locals,reads,stage},outcome(trace,world,status)))
def local_actual(~operation:U32,shared:Shared,context:Ctx.Context<F.World()>,instance:Instance()) -> Instance() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):
  match shared context instance:
    case Shared{meta,tick,+frame,phase,locals,reads,stage},Ctx.Context{world,trace},Local.Instance{namespace,+id,name,access,capture}:local_done(operation,id,trace,Shared{meta,tick,frame,phase,locals,reads,stage},invoked(Local.Instance{namespace,id,name,access,capture},world,operation,frame))
def spawn_invoke(instance:Instance(),shared:Shared,context:Ctx.Context<F.World()>) -> Instance() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):local_actual(~0,shared,context,instance)
def update_invoke(instance:Instance(),shared:Shared,context:Ctx.Context<F.World()>) -> Instance() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):local_actual(~1,shared,context,instance)
def dispose_invoke(instance:Instance(),shared:Shared,context:Ctx.Context<F.World()>) -> Instance() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):local_actual(~2,shared,context,instance)
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
def reader_done(id:U32,trace:Facts.State,frame:D.Frame,phase:U32,locals:List<&2,LocalCall>,reads:List<&2,ReadCall>,stage:U32,result:ReaderReturned) -> Reader.Provider() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):
  match result:
    case ReaderReturned{Route.Runtime{world,meta,+tick},provider,+status,+output,before,after}:(provider,(Shared{meta,tick,frame,phase,locals,ReadCall{id,status,tick,output,before,after} <> reads,stage},outcome(trace,world,status)))
def reader_iteration(who:U32,id:U32,trace:Facts.State,provider:Reader.Provider(),meta:Mixed.State<T.MotionSchema,E.Publication,Family.Family,Unit>,tick:Nat,+phase:U32,locals:List<&2,LocalCall>,reads:List<&2,ReadCall>,stage:U32,world:F.World(),observed:D.Frame & U32) -> Reader.Provider() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):
  match observed:
    case (frame,i):reader_done(id,trace,frame,phase,locals,reads,stage,read_run(provider,Route.Runtime{world,meta,tick},Reader.Args{who,phase,i}))
def reader_actual(~who:U32,shared:Shared,context:Ctx.Context<F.World()>,provider:Reader.Provider()) -> Reader.Provider() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):
  match shared context provider:
    case Shared{meta,tick,frame,phase,locals,reads,stage},Ctx.Context{world,trace},O.Provider{Sys.Registry{namespace,+id,name,access,cursor},owner,param,decl}:reader_iteration(who,id,trace,O.Provider{Sys.Registry{namespace,id,name,access,cursor},owner,param,decl},meta,tick,phase,locals,reads,stage,world,iteration(frame))
def fast_invoke(provider:Reader.Provider(),shared:Shared,context:Ctx.Context<F.World()>) -> Reader.Provider() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):reader_actual(~0,shared,context,provider)
def slow_invoke(provider:Reader.Provider(),shared:Shared,context:Ctx.Context<F.World()>) -> Reader.Provider() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>):reader_actual(~1,shared,context,provider)
