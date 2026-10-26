import Base
import ./world.bend as W
import ./execution-system.bend as Sys
import ./execution-builder.bend as Build
import ./execution-parallel-system.bend as Task
import ./execution-composer-layout.bend as Layout
import ./execution-command-local.bend as Local

# Command owners have a distinct type, so an ordinary Sys.Owner leaf cannot
# silently omit their deferred inventory and publication operation.
def Body(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type,~User:Type,~Error:Data,~Out:Data) -> Type:
  @-H:Type -> @-Q:Type -> @-caps:Ops(H) -> @-commands:Local.Commands<Q,S,Layout.payload(layout,route)> -> H -> Q -> User -> H & (Q & (User & Sys.Completion<Error,Out>))
def Captures(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~User:Type) -> Type:
  Local.Local<S,Layout.payload(layout,route),User>
def runner(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type,~User:Type,~Error:Data,~Out:Data,~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~H:Type,~caps:Ops(H),scope:H,local:Captures(~S,~layout,~route,~User)) -> H & (Captures(~S,~layout,~route,~User) & Sys.Completion<Error,Out>):
  Local.invoke(~S,~(Layout.payload(layout,route)),~User,~Error,~Out,~Ops,~body,~H,~caps,scope,local)
type Owner<-S:Data,-C:Type,-R:Type,-E:Data,-layout:Layout.Layout,-route:Layout.Route,-Ops:Type -> Type,-User:Type,-Error:Data,-Out:Data,-declaration:Build.Program(~S,~C,~R,~Ops),-body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out)> is Type:
  Owner{system:Sys.Owner<S,C,R,E,Ops,Captures(~S,~layout,~route,~User),Error,Out,declaration,runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body)>}
def wrapped(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,result:Sys.Defined<W.World<S,Layout.columns(~S,layout),WR,E>,Sys.Owner<S,C,R,E,Ops,Captures(~S,~layout,~route,~User),Error,Out,declaration,runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body)>,Captures(~S,~layout,~route,~User)>) -> Sys.Defined<W.World<S,Layout.columns(~S,layout),WR,E>,Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,Captures(~S,~layout,~route,~User)>:
  match result:
    case Sys.Defined{world,system}:Sys.Defined{world,Owner{system}}
    case Sys.DefinitionRefused{world,local}:Sys.DefinitionRefused{world,local}

# The full command schema fixes the inserted payload type and destination.
# C/R describe the physical gameplay scope, which may be one root-cut branch;
# registration always uses the actual complete World and its single allocator.
def define(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,world:W.World<S,Layout.columns(~S,layout),WR,E>,name:String,user:User) -> Sys.Defined<W.World<S,Layout.columns(~S,layout),WR,E>,Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,Captures(~S,~layout,~route,~User)>:
  wrapped(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,Task.define(~S,~C,~R,~E,~Ops,~Captures(~S,~layout,~route,~User),~Error,~Out,~declaration,~runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),~(Layout.columns(~S,layout)),~WR,world,name,Local.fresh(~S,~(Layout.payload(layout,route)),~User,user)))

type Metadata is Data:
  Metadata{id:U32,component:String}
def metadata(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~R,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),owner:Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Metadata:
  match owner:
    case Owner{Sys.Owner{namespace,+id,name,access,cursor,local}}:(Owner{Sys.Owner{namespace,id,name,access,cursor,local}},Metadata{id,Layout.key(layout,route)})
