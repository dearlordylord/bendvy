import Base
import ./world.bend as W
import ./execution-state.bend as State
import ./execution-system.bend as Sys
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./execution-parallel-system.bend as Task
import ./execution-parallel-registration.bend as Part
import ./execution-parallel-schedule.bend as Ready
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec
import ./owner-product.bend as Product
import ./change-tick.bend as Tick

type Permit is Data:
  Permit{id:U32,allowed:Bool,tick:Tick.Tick}
def selected(+id:U32,ids:List<&2,U32>) -> Bool:
  match ids:
    case []:False{}
    case actual <> rest:Bool.or(U32.is_eq(id,actual),selected(id,rest))
def invocation(~Error:Data,~Out:Data,value:Sys.Completion<Error,Out>) -> Exec.Invocation<Error,Out>:
  match value:
    case Sys.Success{output}:Exec.Completed{output}
    case Sys.BodyError{error,output}:Exec.BodyError{error,output}
def retick(~S:Data,~C:Type,~R:Type,scope:State.Scope<S,C,R>,tick:Tick.Tick) -> State.Scope<S,C,R>:
  match scope:
    case State.Scope{store,resource,handles,_}:State.Scope{store,resource,handles,tick}
def entered(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WC:Type,~WR:Type,meta:Task.Meta,local:Local,+id:U32,+allowed:Bool,result:W.World<S,WC,WR,E> & Tick.Tick) -> W.World<S,WC,WR,E> & (Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Permit>):
  match result:
    case (world,tick):(world,(Task.restored(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[Permit{id,allowed,tick}]))
def verified(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WC:Type,~WR:Type,meta:Task.Meta,local:Local,id:U32,result:W.World<S,WC,WR,E> & Bool) -> W.World<S,WC,WR,E> & (Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Permit>):
  match result:
    case (world,+allowed):entered(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WC,~WR,meta,local,id,allowed,Task.enter(~S,~WC,~WR,~E,allowed,world))
def chosen(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WC:Type,~WR:Type,chosen:Bool,world:W.World<S,WC,WR,E>,+meta:Task.Meta,local:Local) -> W.World<S,WC,WR,E> & (Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Permit>):
  match chosen meta:
    case False{} meta:(world,(Task.restored(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[]))
    case True{} Task.Meta{_,id,_,_,_}:verified(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WC,~WR,meta,local,id,Task.verify(~S,~WC,~WR,~E,meta,world))
def meta_id(meta:Task.Meta) -> U32:
  match meta:
    case Task.Meta{_,id,_,_,_}:id
def prepare_detached(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WC:Type,~WR:Type,ids:List<&2,U32>,world:W.World<S,WC,WR,E>,result:Task.Meta & Local) -> W.World<S,WC,WR,E> & (Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Permit>):
  match result:
    case (+meta,local):chosen(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WC,~WR,selected(meta_id(meta),ids),world,meta,local)
def prepare(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),~WC:Type,~WR:Type,ids:List<&2,U32>,world:W.World<S,WC,WR,E>,owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>) -> W.World<S,WC,WR,E> & (Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Permit>):
  prepare_detached(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WC,~WR,ids,world,Task.detached(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,owner))
def invoked(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),meta:Task.Meta,+id:U32,+tick:Tick.Tick,result:State.Scope<S,C,R> & (Local & Sys.Completion<Error,Out>)) -> State.Scope<S,C,R> & (Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (scope,(local,status)):(scope,(Task.restored(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,Task.completed_meta(True{},tick,meta),local),[Ready.Completed{id,invocation(~Error,~Out,status)}]))
def allowed(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),allowed:Bool,+tick:Tick.Tick,scope:State.Scope<S,C,R>,meta:Task.Meta,local:Local,+id:U32) -> State.Scope<S,C,R> & (Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>):
  match allowed:
    case False{}:(scope,(Task.restored(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[Ready.Completed{id,Exec.AdmissionRefused{}}]))
    case True{}:invoked(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,id,tick,body(State.Scope<S,C,R>,D.grants(~S,~C,~R,~Ops,Build.compile(~S,~C,~R,~Ops,~declaration)),retick(~S,~C,~R,scope,tick),local))
def permit_selected(found:Bool,permit:Permit,rest:Maybe<&2,Permit>) -> Maybe<&2,Permit>:
  match found:
    case True{}:Some{permit}
    case False{}:rest
def permit_id(permit:Permit) -> U32:
  match permit:
    case Permit{id,_,_}:id
def find(+id:U32,permits:List<&2,Permit>) -> Maybe<&2,Permit>:
  match permits:
    case []:None{}
    case +permit <> rest:permit_selected(U32.is_eq(id,permit_id(permit)),permit,find(id,rest))
def permitted(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),permit:Maybe<&2,Permit>,scope:State.Scope<S,C,R>,meta:Task.Meta,local:Local) -> State.Scope<S,C,R> & (Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>):
  match permit:
    case None{}:(scope,(Task.restored(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,meta,local),[]))
    case Some{Permit{id,canRun,tick}}:allowed(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,canRun,tick,scope,meta,local,id)
def invoke_detached(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),permits:List<&2,Permit>,scope:State.Scope<S,C,R>,result:Task.Meta & Local) -> State.Scope<S,C,R> & (Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (+meta,local):permitted(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,find(meta_id(meta),permits),scope,meta,local)
def invoke(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:@-H:Type -> @-caps:Ops(H) -> H -> Local -> H & (Local & Sys.Completion<Error,Out>),permits:List<&2,Permit>,scope:State.Scope<S,C,R>,owner:Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body>) -> State.Scope<S,C,R> & (Sys.Owner<S,C,R,E,Ops,Local,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>):
  invoke_detached(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,permits,scope,Task.detached(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,owner))
