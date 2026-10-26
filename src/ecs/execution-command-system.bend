import Base
import ./world.bend as W
import ./execution-system.bend as Sys
import ./execution-builder.bend as Build
import ./execution-parallel-system.bend as Task
import ./execution-composer-layout.bend as Layout
import ./execution-command-local.bend as Local
import ./execution-command-buffer.bend as Buffer
import ./execution-command-publication.bend as Publication
import ./change-tick.bend as Tick

# Command owners have a distinct type, so an ordinary Sys.Owner leaf cannot
# silently omit their deferred inventory and publication operation.
def ScopedOps(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,H:Type) -> Type:
  Ops(H,Buffer.Buffer<S,Layout.payload(layout,route)>)
def Program(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type) -> Type:
  @-H:Type -> @-Q:Type -> @-commands:Local.Commands<Q,S,Layout.payload(layout,route)> -> @-B:Type -> @-builder:Build.Builder(~S,~C,~R,~H,~B) -> B -> B & Ops(H,Q)
def program_for_buffer(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~H:Type,~B:Type,~builder:Build.Builder(~S,~C,~R,~H,~B),book:B) -> B & ScopedOps(~S,~layout,~route,~Ops,H):
  declaration(H,Buffer.Buffer<S,Layout.payload(layout,route)>,Local.canonical(~S,~(Layout.payload(layout,route))),B,builder,book)
def Body(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data) -> Type:
  @-H:Type -> @-Q:Type -> @-caps:Ops(H,Q) -> @-commands:Local.Commands<Q,S,Layout.payload(layout,route)> -> H -> Q -> User -> H & (Q & (User & Sys.Completion<Error,Out>))
def Captures(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~User:Type) -> Type:
  Local.Local<S,Layout.payload(layout,route),User>
def runner(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~H:Type,~caps:Ops(H,Buffer.Buffer<S,Layout.payload(layout,route)>),scope:H,local:Captures(~S,~layout,~route,~User)) -> H & (Captures(~S,~layout,~route,~User) & Sys.Completion<Error,Out>):
  Local.invoke(~S,~(Layout.payload(layout,route)),~User,~Error,~Out,~Ops,~body,~H,~caps,scope,local)
type Owner<-S:Data,-C:Type,-R:Type,-E:Data,-layout:Layout.Layout,-route:Layout.Route,-Ops:Type -> Type -> Type,-User:Type,-Error:Data,-Out:Data,-declaration:Program(~S,~C,~R,~layout,~route,~Ops),-body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out)> is Type:
  Owner{system:Sys.Owner<S,C,R,E,ScopedOps(~S,~layout,~route,~Ops),Captures(~S,~layout,~route,~User),Error,Out,program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body)>}
def wrapped(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,result:Sys.Defined<W.World<S,Layout.columns(~S,layout),WR,E>,Sys.Owner<S,C,R,E,ScopedOps(~S,~layout,~route,~Ops),Captures(~S,~layout,~route,~User),Error,Out,program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body)>,Captures(~S,~layout,~route,~User)>) -> Sys.Defined<W.World<S,Layout.columns(~S,layout),WR,E>,Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,Captures(~S,~layout,~route,~User)>:
  match result:
    case Sys.Defined{world,system}:Sys.Defined{world,Owner{system}}
    case Sys.DefinitionRefused{world,local}:Sys.DefinitionRefused{world,local}

# The full command schema fixes the inserted payload type and destination.
# C/R describe the physical gameplay scope, which may be one root-cut branch;
# registration always uses the actual complete World and its single allocator.
def define(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,world:W.World<S,Layout.columns(~S,layout),WR,E>,name:String,user:User) -> Sys.Defined<W.World<S,Layout.columns(~S,layout),WR,E>,Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>,Captures(~S,~layout,~route,~User)>:
  wrapped(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,Task.define(~S,~C,~R,~E,~ScopedOps(~S,~layout,~route,~Ops),~Captures(~S,~layout,~route,~User),~Error,~Out,~program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),~runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),~(Layout.columns(~S,layout)),~WR,world,name,Local.fresh(~S,~(Layout.payload(layout,route)),~User,user)))

type Metadata is Data:
  Metadata{id:U32,component:String}
def metadata(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),owner:Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Metadata:
  match owner:
    case Owner{Sys.Owner{namespace,+id,name,access,cursor,local}}:(Owner{Sys.Owner{namespace,id,name,access,cursor,local}},Metadata{id,Layout.key(layout,route)})

def pending_returned(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),meta:Task.Meta,user:User,result:Buffer.Buffer<S,Layout.payload(layout,route)> & Bool) -> Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool:
  match result:
    case (commands,pending):(Owner{Task.restored(~S,~C,~R,~E,~ScopedOps(~S,~layout,~route,~Ops),~Captures(~S,~layout,~route,~User),~Error,~Out,~program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),~runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),meta,Local.Local{user,commands})},pending)
def pending(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),owner:Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool:
  match owner:
    case Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,commands}}}:pending_returned(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,Task.Meta{namespace,id,name,access,cursor},user,Buffer.pending(~S,~(Layout.payload(layout,route)),commands))
def published(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,meta:Task.Meta,user:User,result:W.World<S,Layout.columns(~S,layout),WR,E> & Buffer.Buffer<S,Layout.payload(layout,route)>) -> W.World<S,Layout.columns(~S,layout),WR,E> & Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>:
  match result:
    case (world,commands):(world,Owner{Task.restored(~S,~C,~R,~E,~ScopedOps(~S,~layout,~route,~Ops),~Captures(~S,~layout,~route,~User),~Error,~Out,~program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),~runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),meta,Local.Local{user,commands})})
def publication_allowed(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,meta:Task.Meta,user:User,commands:Buffer.Buffer<S,Layout.payload(layout,route)>,tick:Tick.Tick,result:W.World<S,Layout.columns(~S,layout),WR,E> & Bool) -> W.World<S,Layout.columns(~S,layout),WR,E> & Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>:
  match result:
    case (world,False{}):published(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,meta,user,(world,commands))
    case (world,True{}):published(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,meta,user,Publication.apply_at(~S,~WR,~E,~layout,~route,~valid,world,commands,tick))
def publish(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,tick:Tick.Tick,world:W.World<S,Layout.columns(~S,layout),WR,E>,owner:Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> W.World<S,Layout.columns(~S,layout),WR,E> & Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>:
  match owner:
    case Owner{Sys.Owner{+namespace,+id,+name,+access,+cursor,Local.Local{user,commands}}}:publication_allowed(~S,~C,~R,~E,~layout,~route,~valid,~Ops,~User,~Error,~Out,~declaration,~body,~WR,Task.Meta{namespace,id,name,access,cursor},user,commands,tick,Task.verify(~S,~(Layout.columns(~S,layout)),~WR,~E,Task.Meta{namespace,id,name,access,cursor},world))
