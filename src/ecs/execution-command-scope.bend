import Base
import ./world.bend as W
import ./execution-system.bend as Sys
import ./execution-parallel-system.bend as Task
import ./execution-state.bend as State
import ./execution-builder.bend as Build
import ./execution-parallel-scope.bend as Scope
import ./execution-parallel-schedule.bend as Ready
import ./execution-command-system.bend as Cmd
import ./execution-composer-layout.bend as Layout
import ./change-tick.bend as Tick

# Closed adapters preserve the distinct command owner across scope invocation.
def prepared(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,result:W.World<S,WC,WR,E> & (Sys.Owner<S,C,R,E,Cmd.ScopedOps(~S,~layout,~route,~Ops),Cmd.Captures(~S,~layout,~route,~User),Error,Out,Cmd.program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),Cmd.runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body)> & List<&2,Scope.Permit>)) -> W.World<S,WC,WR,E> & (Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & List<&2,Scope.Permit>):
  match result:
    case (world,(system,permits)):(world,(Cmd.Owner{system},permits))
def prepare_actual(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,ids:List<&2,U32>,world:W.World<S,WC,WR,E>,owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> W.World<S,WC,WR,E> & (Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & List<&2,Scope.Permit>):
  match owner:
    case Cmd.Owner{system}:prepared(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,Scope.prepare(~S,~C,~R,~E,~Cmd.ScopedOps(~S,~layout,~route,~Ops),~Cmd.Captures(~S,~layout,~route,~User),~Error,~Out,~Cmd.program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),~Cmd.runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),~WC,~WR,ids,world,system))
def refused_permits(id:U32,selected:Bool) -> List<&2,Scope.Permit>:
  match selected:
    case False{}:[]
    case True{}:[Scope.Permit{id,False{},Tick.zero()}]
def prepare_checked(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,ids:List<&2,U32>,world:W.World<S,WC,WR,E>,result:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool) -> W.World<S,WC,WR,E> & (Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & List<&2,Scope.Permit>):
  match result:
    case (owner,True{}):prepare_actual(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,ids,world,owner)
    case (Cmd.Owner{Sys.Owner{namespace,+id,name,access,cursor,local}},False{}):(world,(Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,local}},refused_permits(id,Scope.selected(id,ids))))
def prepare(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,ids:List<&2,U32>,world:W.World<S,WC,WR,E>,owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> W.World<S,WC,WR,E> & (Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & List<&2,Scope.Permit>):
  prepare_checked(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,ids,world,Cmd.permission_matches(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,owner))
def invoked(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),result:State.Scope<S,C,R> & (Sys.Owner<S,C,R,E,Cmd.ScopedOps(~S,~layout,~route,~Ops),Cmd.Captures(~S,~layout,~route,~User),Error,Out,Cmd.program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),Cmd.runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body)> & List<&2,Ready.Completed<Error,Out>>)) -> State.Scope<S,C,R> & (Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (scope,(system,completed)):(scope,(Cmd.Owner{system},completed))
def invoke_actual(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),permits:List<&2,Scope.Permit>,scope:State.Scope<S,C,R>,owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> State.Scope<S,C,R> & (Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>):
  match owner:
    case Cmd.Owner{system}:invoked(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,Scope.invoke(~S,~C,~R,~E,~Cmd.ScopedOps(~S,~layout,~route,~Ops),~Cmd.Captures(~S,~layout,~route,~User),~Error,~Out,~Cmd.program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),~Cmd.runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),permits,scope,system))
def refuse_permits(permits:List<&2,Scope.Permit>) -> List<&2,Scope.Permit>:
  match permits:
    case []:[]
    case Scope.Permit{id,_,tick} <> rest:Scope.Permit{id,False{},tick} <> refuse_permits(rest)
def invoke_checked(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),permits:List<&2,Scope.Permit>,scope:State.Scope<S,C,R>,result:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool) -> State.Scope<S,C,R> & (Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>):
  match result:
    case (owner,True{}):invoke_actual(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,permits,scope,owner)
    case (owner,False{}):invoke_actual(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,refuse_permits(permits),scope,owner)
def invoke(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),permits:List<&2,Scope.Permit>,scope:State.Scope<S,C,R>,owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> State.Scope<S,C,R> & (Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & List<&2,Ready.Completed<Error,Out>>):
  invoke_checked(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,permits,scope,Cmd.permission_matches(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,owner))
def command_world(~S:Data,~WC:Type,~WR:Type,~E:Data,~layout:Layout.Layout,same:{WC == Layout.columns(~S,layout) : Type},world:W.World<S,WC,WR,E>) -> W.World<S,Layout.columns(~S,layout),WR,E>:
  %same : W.World<S,_,WR,E>
  world
def published(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,~same:{WC == Layout.columns(~S,layout) : Type},result:W.World<S,Layout.columns(~S,layout),WR,E> & Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> W.World<S,WC,WR,E> & Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>:
  %Equal.sym(Type,WC,Layout.columns(~S,layout),same) : W.World<S,_,WR,E> & Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>
  result
def pending_allowed(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,allowed:Bool) -> Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool:
  match allowed:
    case False{}:(owner,False{})
    case True{}:Cmd.pending(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,owner)
def pending_metadata(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),ids:List<&2,U32>,result:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Cmd.Metadata) -> Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool:
  match result:
    case (owner,Cmd.Metadata{id,_,_}):pending_allowed(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,owner,Scope.selected(id,ids))
def pending_selected(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),ids:List<&2,U32>,owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool:
  pending_metadata(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,ids,Cmd.metadata(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,owner))
def pending_coherent(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),ids:List<&2,U32>,result:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool) -> Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool:
  match result:
    case (owner,False{}):(owner,False{})
    case (owner,True{}):pending_selected(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,ids,owner)
def publish_selected(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},tick:Tick.Tick,world:W.World<S,WC,WR,E>,owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> W.World<S,WC,WR,E> & Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>:
  published(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,~same,Cmd.publish(~S,~C,~R,~E,~layout,~route,~valid,~Ops,~User,~Error,~Out,~declaration,~body,~WR,tick,command_world(~S,~WC,~WR,~E,~layout,same,world),owner))
def publish_allowed(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},tick:Tick.Tick,world:W.World<S,WC,WR,E>,owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,allowed:Bool) -> W.World<S,WC,WR,E> & Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>:
  match allowed:
    case False{}:(world,owner)
    case True{}:publish_selected(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,~same,~valid,tick,world,owner)
def publish_metadata(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},ids:List<&2,U32>,tick:Tick.Tick,world:W.World<S,WC,WR,E>,result:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Cmd.Metadata) -> W.World<S,WC,WR,E> & Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>:
  match result:
    case (owner,Cmd.Metadata{id,_,_}):publish_allowed(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,~same,~valid,tick,world,owner,Scope.selected(id,ids))
def publish(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},ids:List<&2,U32>,tick:Tick.Tick,world:W.World<S,WC,WR,E>,owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> W.World<S,WC,WR,E> & Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>:
  publish_metadata(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,~same,~valid,ids,tick,world,Cmd.metadata(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,owner))

# Applicability is checked before the barrier advances the World clock.
def pending_wrapped(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,world:W.World<S,WC,WR,E>,result:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool) -> W.World<S,WC,WR,E> & (Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool):
  (world,result)
def pending_verified(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,ids:List<&2,U32>,owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,result:W.World<S,WC,WR,E> & Bool) -> W.World<S,WC,WR,E> & (Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool):
  match result:
    case (world,False{}):(world,(owner,False{}))
    case (world,True{}):pending_wrapped(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,world,pending_coherent(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,ids,Cmd.permission_matches(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,owner)))
def pending(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,ids:List<&2,U32>,world:W.World<S,WC,WR,E>,owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> W.World<S,WC,WR,E> & (Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool):
  match owner:
    case Cmd.Owner{Sys.Owner{+namespace,+id,+name,+access,+cursor,local}}:pending_verified(~S,~WC,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,ids,Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,local}},Task.verify(~S,~WC,~WR,~E,Task.Meta{namespace,id,name,access,cursor},world))
