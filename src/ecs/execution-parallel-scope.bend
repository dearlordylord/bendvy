import Base
import ./execution-prepared.bend as Prep
import ./execution-lifecycle-notices.bend as Notice
import ./world.bend as W
import ./execution-state.bend as State
import ./execution-system.bend as Sys
import ./execution-reservation-task.bend as Effect
import ./execution-reservation-authority.bend as RuntimePermit
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./execution-parallel-system.bend as Task
import ./execution-parallel-schedule.bend as Ready
import ./dependency-executor.bend as Exec
import ./change-tick.bend as Tick


type RawPermit is Data:
  RawPermit{id:U32,allowed:Bool,tick:Tick.Tick}
def selected(+id:U32,ids:List<&2,U32>) -> Bool:
  match ids:
    case []:False{}
    case actual <> rest:Bool.or(U32.is_eq(id,actual),selected(id,rest))
def invocation(~Error:Data,~Out:Data,value:Sys.Completion<Error,Out>) -> Exec.Invocation<Error,Out>:
  match value:
    case Sys.Success{output}:Exec.Completed{output}
    case Sys.BodyError{error,output}:Exec.BodyError{error,output}
def meta_cursor(~Owner:Type,meta:Task.Meta<Owner>) -> Maybe<&2,Tick.Tick>:
  match meta:
    case Task.Meta{_,_,_,_,cursor}:cursor
def retick(~S:Data,~C:Type,~R:Type,scope:State.Scope<S,C,R>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>) -> State.Scope<S,C,R>:
  match scope:
    case State.Scope{store,resource,handles,_,_,+lifecycleView}:State.Scope{store,resource,handles,tick,prior,lifecycleView}
def trusted_entered(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,meta:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,local:Local,+id:U32,+allowed:Bool,result:W.World<S,WC,WR,E> & Tick.Tick) -> W.World<S,WC,WR,E> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,RawPermit>):
  match result:
    case (world,tick):(world,(Task.restored(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[RawPermit{id,allowed,tick}]))
def trusted_verified(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,meta:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,local:Local,id:U32,result:W.World<S,WC,WR,E> & Bool) -> W.World<S,WC,WR,E> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,RawPermit>):
  match result:
    case (world,+allowed):
      +supported = Bool.and(allowed,D.compilation_supported(~S,~WC,~C,~R,~Ops,Build.compile_framework(~S,~WC,~C,~R,~Ops,~declaration)))
      trusted_entered(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,meta,local,id,supported,Task.enter(~S,~WC,~WR,~E,supported,world))
def trusted_chosen(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,chosen:Bool,world:W.World<S,WC,WR,E>,+meta:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,local:Local) -> W.World<S,WC,WR,E> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,RawPermit>):
  match chosen meta:
    case False{} meta:(world,(Task.restored(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[]))
    case True{} Task.Meta{_,id,_,_,_}:trusted_verified(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,meta,local,id,Task.verify(~S,~WC,~WR,~E,~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,meta,world))
def meta_id(~Owner:Type,meta:Task.Meta<Owner>) -> U32:
  match meta:
    case Task.Meta{_,id,_,_,_}:id
def trusted_prepare_detached(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,ids:List<&2,U32>,world:W.World<S,WC,WR,E>,result:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>> & Local) -> W.World<S,WC,WR,E> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,RawPermit>):
  match result:
    case (+meta,local):trusted_chosen(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,selected(meta_id(~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,meta),ids),world,meta,local)
def trusted_prepare(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,ids:List<&2,U32>,world:W.World<S,WC,WR,E>,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>) -> W.World<S,WC,WR,E> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,RawPermit>):
  trusted_prepare_detached(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,ids,world,Task.detached(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,owner))
def trusted_invoked(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),meta:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,+id:U32,+tick:Tick.Tick,result:State.Scope<S,C,R> & (Local & Sys.Completion<Error,Out>)) -> State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (scope,(local,status)):(scope,(Task.restored(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,Task.completed_meta(~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,True{},tick,meta),local),[Ready.Completed{id,invocation(~Error,~Out,status)}]))
def trusted_allowed_compilation(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,State.Scope<S,C,R>),allowed:Bool,+tick:Tick.Tick,scope:State.Scope<S,C,R>,+meta:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,local:Local,+id:U32,compilation:D.Compilation<S,WC,C,R,Ops>) -> Effect.Task<S,Effect.Granted,State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>)>:
  match allowed compilation:
    case False{} _:Effect.TDone{(scope,(Task.restored(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[Ready.Completed{id,Exec.AdmissionRefused{}}]))}
    case True{} D.Unsupported{_,_,_}:Effect.TDone{(scope,(Task.restored(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[Ready.Completed{id,Exec.AdmissionRefused{}}]))}
    case True{} D.Supported{D.Declaration{_,_},_}:Sys.map(S,Effect.Granted,State.Scope<S,C,R> & (Local & Sys.Completion<Error,Out>),State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>),body(Effect.Granted,State.Scope<S,C,R>,compiledCaps,retick(~S,~C,~R,scope,tick,meta_cursor(~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,meta)),local),result => trusted_invoked(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,id,tick,result))
def trusted_allowed(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),allowed:Bool,+tick:Tick.Tick,scope:State.Scope<S,C,R>,+meta:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,local:Local,+id:U32) -> Effect.Task<S,Effect.Granted,State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>)>:
  trusted_allowed_compilation(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~D.trusted_construction_caps(~S,~WC,~C,~R,~Ops,Build.compile_framework(~S,~WC,~C,~R,~Ops,~declaration)),allowed,tick,scope,meta,local,id,Build.compile_framework(~S,~WC,~C,~R,~Ops,~declaration))

def permit_selected(found:Bool,permit:RawPermit,rest:Maybe<&2,RawPermit>) -> Maybe<&2,RawPermit>:
  match found:
    case True{}:Some{permit}
    case False{}:rest
def permit_id(permit:RawPermit) -> U32:
  match permit:
    case RawPermit{id,_,_}:id
def find(+id:U32,permits:List<&2,RawPermit>) -> Maybe<&2,RawPermit>:
  match permits:
    case []:None{}
    case +permit <> rest:permit_selected(U32.is_eq(id,permit_id(permit)),permit,find(id,rest))
def trusted_permitted(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),permit:Maybe<&2,RawPermit>,scope:State.Scope<S,C,R>,meta:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,local:Local) -> Effect.Task<S,Effect.Granted,State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>)>:
  match permit:
    case None{}:Effect.TDone{(scope,(Task.restored(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[]))}
    case Some{RawPermit{id,canRun,tick}}:trusted_allowed(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,canRun,tick,scope,meta,local,id)
def trusted_invoke_detached(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),permits:List<&2,RawPermit>,scope:State.Scope<S,C,R>,result:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>> & Local) -> Effect.Task<S,Effect.Granted,State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>)>:
  match result:
    case (+meta,local):trusted_permitted(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,find(meta_id(~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,meta),permits),scope,meta,local)
def trusted_invoke(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),permits:List<&2,RawPermit>,scope:State.Scope<S,C,R>,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Effect.Task<S,Effect.Granted,State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>)>:
  trusted_invoke_detached(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,permits,scope,Task.detached(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,owner))

# Trusted record adapters are used only by the whole-World preparation boundary.
def trusted_qualified_permits(~S:Data,~WC:Type,+namespace:U32,permits:List<&2,RawPermit>) -> List<&2,Prep.Permit<S,WC>>:
  match permits:
    case []:[]
    case RawPermit{id,allowed,tick} <> rest:Prep.Permit{namespace,id,allowed,tick} <> trusted_qualified_permits(~S,~WC,namespace,rest)
def trusted_raw_permits(~S:Data,~WC:Type,permits:List<&2,Prep.Permit<S,WC>>) -> List<&2,RawPermit>:
  match permits:
    case []:[]
    case Prep.Permit{_,id,allowed,tick} <> rest:RawPermit{id,allowed,tick} <> trusted_raw_permits(~S,~WC,rest)
def trusted_qualified_result(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,+namespace:U32,result:W.World<S,WC,WR,E> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,RawPermit>)) -> W.World<S,WC,WR,E> & Prep.Prepared<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>:
  match result:
    case (world,(owner,permits)):(world,Prep.trusted_leaf(W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,namespace,owner,trusted_qualified_permits(~S,~WC,namespace,permits)))
def trusted_preparation_namespace(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,ids:List<&2,U32>,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,result:W.World<S,WC,WR,E> & U32) -> W.World<S,WC,WR,E> & Prep.Prepared<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>:
  match result:
    case (world,namespace):trusted_qualified_result(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,namespace,trusted_prepare(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,ids,world,owner))
def prepare(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,ids:List<&2,U32>,world:W.World<S,WC,WR,E>,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>) -> W.World<S,WC,WR,E> & Prep.Prepared<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>:
  trusted_preparation_namespace(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,ids,owner,W.namespace(~S,~WC,~WR,~E,world))
def trusted_qualified_invoked(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,namespace:U32,permits:List<&2,Prep.Permit<S,WC>>,provenance:Prep.Provenance<Prep.Permit<S,WC>>,result:State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>)) -> Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>:
  match result:
    case (scope,(owner,status)):Prep.Invoked{scope,Prep.Prepared{namespace,owner,permits,provenance},status}
def trusted_invocation_admitted(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,admission:Prep.Admission<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>) -> Effect.Task<S,Effect.Granted,Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>>:
  match admission:
    case Prep.AdmissionRefused{scope,prepared}:Effect.TDone{Prep.InvocationRefused{scope,prepared,[]}}
    case Prep.Admitted{scope,Prep.Prepared{namespace,owner,+permits,provenance}}:Sys.map(S,Effect.Granted,State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>),Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>,trusted_invoke(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,trusted_raw_permits(~S,~WC,permits),scope,owner),result => trusted_qualified_invoked(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,namespace,permits,provenance,result))
def invoke(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,scope:State.Scope<S,C,R>,prepared:Prep.Prepared<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>) -> Effect.Task<S,Effect.Granted,Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>>:
  match scope:
    case State.Scope{store,resource,handles,tick,prior,Notice.View{+namespace,+channels,+active}}:trusted_invocation_admitted(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,Prep.trusted_admit(State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,namespace,State.Scope{store,resource,handles,tick,prior,Notice.View{namespace,channels,active}},prepared))

def trusted_verified_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,meta:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,local:Local,id:U32,result:W.World<S,WC,WR,E> & Bool) -> W.World<S,WC,WR,E> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,RawPermit>):
  match result:
    case (world,+allowed):
      +supported = Bool.and(allowed,D.compilation_supported(~S,~WC,~C,~R,~Ops,Build.compile_framework_with_general(~S,~WC,~C,~R,~provider,~Ops,~declaration)))
      trusted_entered(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,meta,local,id,supported,Task.enter(~S,~WC,~WR,~E,supported,world))
def trusted_chosen_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,chosen:Bool,world:W.World<S,WC,WR,E>,+meta:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,local:Local) -> W.World<S,WC,WR,E> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,RawPermit>):
  match chosen meta:
    case False{} meta:(world,(Task.restored(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[]))
    case True{} Task.Meta{_,id,_,_,_}:trusted_verified_with_general(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~provider,~declaration,~body,~WR,meta,local,id,Task.verify(~S,~WC,~WR,~E,~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,meta,world))
def trusted_prepare_detached_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,ids:List<&2,U32>,world:W.World<S,WC,WR,E>,result:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>> & Local) -> W.World<S,WC,WR,E> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,RawPermit>):
  match result:
    case (+meta,local):trusted_chosen_with_general(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~provider,~declaration,~body,~WR,selected(meta_id(~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,meta),ids),world,meta,local)
def trusted_prepare_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,ids:List<&2,U32>,world:W.World<S,WC,WR,E>,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>) -> W.World<S,WC,WR,E> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,RawPermit>):
  trusted_prepare_detached_with_general(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~provider,~declaration,~body,~WR,ids,world,Task.detached(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,owner))
def trusted_allowed_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),allowed:Bool,+tick:Tick.Tick,scope:State.Scope<S,C,R>,+meta:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,local:Local,+id:U32) -> Effect.Task<S,Effect.Granted,State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>)>:
  trusted_allowed_compilation(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~D.trusted_construction_caps(~S,~WC,~C,~R,~Ops,Build.compile_framework_with_general(~S,~WC,~C,~R,~provider,~Ops,~declaration)),allowed,tick,scope,meta,local,id,Build.compile_framework_with_general(~S,~WC,~C,~R,~provider,~Ops,~declaration))

def trusted_permitted_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),permit:Maybe<&2,RawPermit>,scope:State.Scope<S,C,R>,meta:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,local:Local) -> Effect.Task<S,Effect.Granted,State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>)>:
  match permit:
    case None{}:Effect.TDone{(scope,(Task.restored(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[]))}
    case Some{RawPermit{id,canRun,tick}}:trusted_allowed_with_general(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~provider,~declaration,~body,canRun,tick,scope,meta,local,id)
def trusted_invoke_detached_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),permits:List<&2,RawPermit>,scope:State.Scope<S,C,R>,result:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>> & Local) -> Effect.Task<S,Effect.Granted,State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>)>:
  match result:
    case (+meta,local):trusted_permitted_with_general(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~provider,~declaration,~body,find(meta_id(~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,meta),permits),scope,meta,local)
def trusted_invoke_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),permits:List<&2,RawPermit>,scope:State.Scope<S,C,R>,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Effect.Task<S,Effect.Granted,State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>)>:
  trusted_invoke_detached_with_general(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~provider,~declaration,~body,permits,scope,Task.detached(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,owner))

# Trusted record adapters are used only by the whole-World preparation boundary.
def trusted_preparation_namespace_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,ids:List<&2,U32>,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,result:W.World<S,WC,WR,E> & U32) -> W.World<S,WC,WR,E> & Prep.Prepared<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>:
  match result:
    case (world,namespace):trusted_qualified_result(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,namespace,trusted_prepare_with_general(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~provider,~declaration,~body,~WR,ids,world,owner))
def prepare_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,ids:List<&2,U32>,world:W.World<S,WC,WR,E>,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>) -> W.World<S,WC,WR,E> & Prep.Prepared<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>:
  trusted_preparation_namespace_with_general(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~provider,~declaration,~body,~WR,ids,owner,W.namespace(~S,~WC,~WR,~E,world))
def trusted_invocation_admitted_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,admission:Prep.Admission<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>) -> Effect.Task<S,Effect.Granted,Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>>:
  match admission:
    case Prep.AdmissionRefused{scope,prepared}:Effect.TDone{Prep.InvocationRefused{scope,prepared,[]}}
    case Prep.Admitted{scope,Prep.Prepared{namespace,owner,+permits,provenance}}:Sys.map(S,Effect.Granted,State.Scope<S,C,R> & (Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>),Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>,trusted_invoke_with_general(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~provider,~declaration,~body,trusted_raw_permits(~S,~WC,permits),scope,owner),result => trusted_qualified_invoked(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,namespace,permits,provenance,result))
def invoke_with_general(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~provider:Build.GeneralProvider(~S,~WC,~C,~R),~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,scope:State.Scope<S,C,R>,prepared:Prep.Prepared<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>) -> Effect.Task<S,Effect.Granted,Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>>:
  match scope:
    case State.Scope{store,resource,handles,tick,prior,Notice.View{+namespace,+channels,+active}}:trusted_invocation_admitted_with_general(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~provider,~declaration,~body,~WR,Prep.trusted_admit(State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,namespace,State.Scope{store,resource,handles,tick,prior,Notice.View{namespace,channels,active}},prepared))


def compiled_entered(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,+namespace:U32,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,id:U32,result:W.World<S,WC,WR,E> & Tick.Tick) -> Prep.Preparation<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>:
  match result:
    case (world,tick):Prep.PreparationReady{world,Prep.trusted_leaf(W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,namespace,owner,[Prep.Permit{namespace,id,True{},tick}])}

def compiled_verified(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,namespace:U32,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,id:U32,result:W.World<S,WC,WR,E> & Bool) -> Prep.Preparation<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>:
  match result:
    case (world,False{}):Prep.PreparationRefused{world,Prep.Inventory{owner,Prep.Unprepared{}}}
    case (world,True{}):compiled_entered(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,namespace,owner,id,W.enter_run(~S,~WC,~WR,~E,world))

def compiled_chosen(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,chosen:Bool,namespace:U32,+meta:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,local:Local,world:W.World<S,WC,WR,E>) -> Prep.Preparation<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>:
  match chosen meta:
    case False{} meta:Prep.PreparationReady{world,Prep.trusted_leaf(W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,namespace,Task.restored(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[])}
    case True{} Task.Meta{_,id,_,_,_}:compiled_verified(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,namespace,Task.restored(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),id,Task.verify(~S,~WC,~WR,~E,~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,meta,world))
def compiled_namespace(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,ids:List<&2,U32>,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,result:W.World<S,WC,WR,E> & U32) -> Prep.Preparation<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>:
  match owner result:
    case Sys.Owner{on,+id,name,access,cursor,local}, (world,namespace):compiled_chosen(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,selected(id,ids),namespace,Task.Meta{on,id,name,access,cursor},local,world)

def prepare_with_compilation(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,compilation:D.Compilation<S,WC,C,R,Ops>,ids:List<&2,U32>,world:W.World<S,WC,WR,E>,owner:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>) -> D.Compilation<S,WC,C,R,Ops> & Prep.Preparation<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>:
  match compilation:
    case D.Unsupported{caps,access,recipes}:(D.Unsupported{caps,access,recipes},Prep.PreparationRefused{world,Prep.Inventory{owner,Prep.Unprepared{}}})
    case D.Supported{compiledDeclaration,recipes}:(D.Supported{compiledDeclaration,recipes},compiled_namespace(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,ids,owner,W.namespace(~S,~WC,~WR,~E,world)))


def compiled_permit(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,~compiledCaps:Ops(Effect.Granted,State.Scope<S,C,R>),grant:RuntimePermit.Grant,+namespace:U32,permits:List<&2,Prep.Permit<S,WC>>,provenance:Prep.Provenance<Prep.Permit<S,WC>>,permit:Maybe<&2,RawPermit>,scope:State.Scope<S,C,R>,+meta:Task.Meta<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,local:Local) -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>>:
  match permit:
    case None{}:Effect.TDone{trusted_qualified_invoked(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,namespace,permits,provenance,(scope,(Task.restored(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[])))}
    case Some{RawPermit{id,False{},tick}}:Effect.TDone{trusted_qualified_invoked(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,namespace,permits,provenance,(scope,(Task.restored(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[Ready.Completed{id,Exec.AdmissionRefused{}}])))}
    case Some{RawPermit{+id,True{},+tick}}:Sys.map(S,RuntimePermit.Permit,State.Scope<S,C,R> & (Local & Sys.Completion<Error,Out>),Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>,Effect.qualify(S,State.Scope<S,C,R> & (Local & Sys.Completion<Error,Out>),RuntimePermit.Context{namespace,id,grant},body(Effect.Granted,State.Scope<S,C,R>,compiledCaps,retick(~S,~C,~R,scope,tick,meta_cursor(~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,meta)),local)),result => trusted_qualified_invoked(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,namespace,permits,provenance,trusted_invoked(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,id,tick,result)))

def compiled_admitted(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,~compiledCaps:Ops(Effect.Granted,State.Scope<S,C,R>),grant:RuntimePermit.Grant,admission:Prep.Admission<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>) -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>>:
  match admission:
    case Prep.AdmissionRefused{scope,prepared}:Effect.TDone{Prep.InvocationRefused{scope,prepared,[]}}
    case Prep.Admitted{scope,Prep.Prepared{namespace,Sys.Owner{on,+id,name,access,cursor,local},+permits,provenance}}:compiled_permit(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,~compiledCaps,grant,namespace,permits,provenance,find(id,trusted_raw_permits(~S,~WC,permits)),scope,Task.Meta{on,id,name,access,cursor},local)

def compiled_invoke(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,~compiledCaps:Ops(Effect.Granted,State.Scope<S,C,R>),grant:RuntimePermit.Grant,scope:State.Scope<S,C,R>,prepared:Prep.Prepared<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>) -> Effect.Task<S,RuntimePermit.Permit,Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>>:
  match scope:
    case State.Scope{store,resource,handles,tick,prior,Notice.View{+namespace,+channels,+active}}:compiled_admitted(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,~compiledCaps,grant,Prep.trusted_admit(State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,namespace,State.Scope{store,resource,handles,tick,prior,Notice.View{namespace,channels,active}},prepared))

# Framework hooks inspect the accepted caps once and restore the same inventory.
def no_structural(~Caps:Type,caps:Caps) -> Caps & RuntimePermit.Grant:
  (caps,RuntimePermit.NoStructural{})
type CompiledBinding<-Compilation:Type,-Owner:Type> is Type:
  CompiledBinding{compilation:Compilation,owner:Owner}
def restore_binding(~Compilation:Type,~Owner:Type,binding:CompiledBinding<Compilation,Owner>) -> Owner:
  match binding:
    case CompiledBinding{_,owner}:owner

def compiled_granted(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,~compiledCaps:Ops(Effect.Granted,State.Scope<S,C,R>),access:List<&2,D.Access>,recipes:D.Recipes<S,WC>,granted:Ops(Effect.Granted,State.Scope<S,C,R>) & RuntimePermit.Grant,scope:State.Scope<S,C,R>,prepared:Prep.Prepared<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>) -> Effect.Task<S,RuntimePermit.Permit,D.Compilation<S,WC,C,R,Ops> & Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>>:
  match granted:
    case (caps,grant):Sys.map(S,RuntimePermit.Permit,Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>,D.Compilation<S,WC,C,R,Ops> & Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>,compiled_invoke(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,~compiledCaps,grant,scope,prepared),result => (D.Supported{D.Declaration{caps,access},recipes},result))

def invoke_with_compilation(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,~compiledCaps:Ops(Effect.Granted,State.Scope<S,C,R>),~grant_of_caps:Ops(Effect.Granted,State.Scope<S,C,R>) -> Ops(Effect.Granted,State.Scope<S,C,R>) & RuntimePermit.Grant,compilation:D.Compilation<S,WC,C,R,Ops>,scope:State.Scope<S,C,R>,prepared:Prep.Prepared<W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>>) -> Effect.Task<S,RuntimePermit.Permit,D.Compilation<S,WC,C,R,Ops> & Prep.Invocation<State.Scope<S,C,R>,W.World<S,WC,WR,E>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Prep.Permit<S,WC>,List<&2,Ready.Completed<Error,Out>>>>:
  match compilation:
    case D.Unsupported{caps,access,recipes}:Effect.TDone{(D.Unsupported{caps,access,recipes},Prep.InvocationRefused{scope,prepared,[]})}
    case D.Supported{D.Declaration{caps,access},recipes}:compiled_granted(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,~compiledCaps,access,recipes,grant_of_caps(caps),scope,prepared)
