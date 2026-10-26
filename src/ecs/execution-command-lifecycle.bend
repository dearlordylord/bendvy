import Base
import ./world.bend as W
import ./execution-system.bend as Sys
import ./execution-system-lifecycle.bend as Life
import ./execution-parallel-system.bend as Task
import ./execution-command-system.bend as Cmd
import ./execution-composer-layout.bend as Layout

# A detached command owner retains the same closed Program and actual Local,
# including permission, pending raw payloads and removed-owner receipts. Cache
# validation precedes metadata mutation; refusal returns that same actual owner.
type Rebinding<-World:Type,-Owner:Type> is Type:
  Rebound{world:World,owner:Owner}
  RebindRefused{world:World,detached:Life.Detached<Owner>}
def retired(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,result:Life.Retirement<W.World<S,Layout.columns(~S,layout),WR,E>,Cmd.System(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body)>) -> Life.Retirement<W.World<S,Layout.columns(~S,layout),WR,E>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>>:
  match result:
    case Life.Retired{world,Life.Detached{system}}:Life.Retired{world,Life.Detached{Cmd.Owner{system}}}
    case Life.RetirementRefused{world,system}:Life.RetirementRefused{world,Cmd.Owner{system}}
def retire_checked(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,world:W.World<S,Layout.columns(~S,layout),WR,E>,result:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool) -> Life.Retirement<W.World<S,Layout.columns(~S,layout),WR,E>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>>:
  match result:
    case (owner,False{}):Life.RetirementRefused{world,owner}
    case (Cmd.Owner{system},True{}):retired(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,Life.retire(~S,~C,~R,~E,~Cmd.ScopedOps(~S,~layout,~route,~Ops),~Cmd.Captures(~S,~layout,~route,~User),~Error,~Out,~Cmd.program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),~Cmd.runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),~(Layout.columns(~S,layout)),~WR,~E,system,world))
def retire(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,owner:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,world:W.World<S,Layout.columns(~S,layout),WR,E>) -> Life.Retirement<W.World<S,Layout.columns(~S,layout),WR,E>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>>:
  retire_checked(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,world,Cmd.permission_matches(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,owner))
def restored(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,result:Life.Restoration<W.World<S,Layout.columns(~S,layout),WR,E>,Cmd.System(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body)>) -> Life.Restoration<W.World<S,Layout.columns(~S,layout),WR,E>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>>:
  match result:
    case Life.Restored{world,system}:Life.Restored{world,Cmd.Owner{system}}
    case Life.RestorationRefused{world,Life.Detached{system}}:Life.RestorationRefused{world,Life.Detached{Cmd.Owner{system}}}
def restore_checked(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,world:W.World<S,Layout.columns(~S,layout),WR,E>,result:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool) -> Life.Restoration<W.World<S,Layout.columns(~S,layout),WR,E>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>>:
  match result:
    case (owner,False{}):Life.RestorationRefused{world,Life.Detached{owner}}
    case (Cmd.Owner{system},True{}):restored(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,Life.restore(~S,~C,~R,~E,~Cmd.ScopedOps(~S,~layout,~route,~Ops),~Cmd.Captures(~S,~layout,~route,~User),~Error,~Out,~Cmd.program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),~Cmd.runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),~(Layout.columns(~S,layout)),~WR,~E,Life.Detached{system},world))
def restore(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,detached:Life.Detached<Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>>,world:W.World<S,Layout.columns(~S,layout),WR,E>) -> Life.Restoration<W.World<S,Layout.columns(~S,layout),WR,E>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>>:
  match detached:
    case Life.Detached{owner}:restore_checked(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,world,Cmd.permission_matches(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,owner))
def rebound(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,meta:Task.Meta,result:Sys.Defined<W.World<S,Layout.columns(~S,layout),WR,E>,Cmd.System(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body),Cmd.Captures(~S,~layout,~route,~User)>) -> Rebinding<W.World<S,Layout.columns(~S,layout),WR,E>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>>:
  match result:
    case Sys.Defined{world,system}:Rebound{world,Cmd.Owner{system}}
    case Sys.DefinitionRefused{world,local}:RebindRefused{world,Life.Detached{Cmd.Owner{Task.restored(~S,~C,~R,~E,~Cmd.ScopedOps(~S,~layout,~route,~Ops),~Cmd.Captures(~S,~layout,~route,~User),~Error,~Out,~Cmd.program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),~Cmd.runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),meta,local)}}}
def rebind_detached(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,world:W.World<S,Layout.columns(~S,layout),WR,E>,name:String,result:Task.Meta & Cmd.Captures(~S,~layout,~route,~User)) -> Rebinding<W.World<S,Layout.columns(~S,layout),WR,E>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>>:
  match result:
    case (meta,local):rebound(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,meta,Task.define(~S,~C,~R,~E,~Cmd.ScopedOps(~S,~layout,~route,~Ops),~Cmd.Captures(~S,~layout,~route,~User),~Error,~Out,~Cmd.program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),~Cmd.runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),~(Layout.columns(~S,layout)),~WR,world,name,local))
def rebind_checked(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,world:W.World<S,Layout.columns(~S,layout),WR,E>,name:String,result:Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool) -> Rebinding<W.World<S,Layout.columns(~S,layout),WR,E>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>>:
  match result:
    case (owner,False{}):RebindRefused{world,Life.Detached{owner}}
    case (Cmd.Owner{system},True{}):rebind_detached(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,world,name,Task.detached(~S,~C,~R,~E,~Cmd.ScopedOps(~S,~layout,~route,~Ops),~Cmd.Captures(~S,~layout,~route,~User),~Error,~Out,~Cmd.program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),~Cmd.runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),system))
def rebind(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Cmd.Program(~S,~C,~R,~layout,~route,~Ops),~body:Cmd.Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,detached:Life.Detached<Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>>,world:W.World<S,Layout.columns(~S,layout),WR,E>,name:String) -> Rebinding<W.World<S,Layout.columns(~S,layout),WR,E>,Cmd.Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>>:
  match detached:
    case Life.Detached{owner}:rebind_checked(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,world,name,Cmd.permission_matches(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,owner))
