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
import ./execution-command-permission.bend as Permission
import ./execution-command-removed.bend as Removed
import ./execution-declaration.bend as D
import ./execution-state.bend as State

# Command owners have a distinct type, so an ordinary Sys.Owner leaf cannot
# silently omit their deferred inventory and publication operation.
def ScopedOps(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,H:Type) -> Type:
  Permission.Prepared<Ops(H,Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>)>
def Program(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type) -> Type:
  @-H:Type -> @-Q:Type -> @-commands:Local.Commands<Q,S,Layout.payload(layout,route)> -> @-B:Type -> @-builder:Build.Builder(~S,~C,~R,~H,~B) -> @-K:Type -> @-entity:Permission.Grant(~S,~layout,~Q,~K) -> B -> K -> B & (K & Ops(H,Q))
def program_for_buffer(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~H:Type,~B:Type,~builder:Build.Builder(~S,~C,~R,~H,~B),book:B) -> B & ScopedOps(~S,~layout,~route,~Ops,H):
  Permission.prepared(~layout,B,Ops(H,Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>),declaration(H,Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>,Local.canonical(~S,~(Layout.payload(layout,route)),~(Removed.Removed(layout))),B,builder,Permission.Book<layout>,Permission.grant(~S,~layout,~(Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>),~(Buffer.despawn(~S,~(Layout.payload(layout,route)),~(Removed.Removed(layout))))),book,Permission.fresh(~layout)))
def Body(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data) -> Type:
  @-H:Type -> @-Q:Type -> @-caps:Ops(H,Q) -> @-commands:Local.Commands<Q,S,Layout.payload(layout,route)> -> H -> Q -> User -> H & (Q & (User & Sys.Completion<Error,Out>))
def Captures(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~User:Type) -> Type:
  Local.Local<S,Layout.payload(layout,route),Removed.Removed(layout),User>
def prepared_permission(-Ops:Type,value:Permission.Prepared<Ops>) -> Permission.Permission:
  match value:
    case Permission.Prepared{permission,_}:permission
def declared_permission(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~declaration:Program(~S,~C,~R,~layout,~route,~Ops)) -> Permission.Permission:
  prepared_permission(Ops(State.Scope<S,C,R>,Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>),D.grants(~S,~C,~R,~ScopedOps(~S,~layout,~route,~Ops),Build.compile(~S,~C,~R,~ScopedOps(~S,~layout,~route,~Ops),~program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration))))
def runner(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~H:Type,~caps:ScopedOps(~S,~layout,~route,~Ops,H),scope:H,local:Captures(~S,~layout,~route,~User)) -> H & (Captures(~S,~layout,~route,~User) & Sys.Completion<Error,Out>):
  Local.invoke(~S,~(Layout.payload(layout,route)),~(Removed.Removed(layout)),~User,~Error,~Out,~Ops,~body,~H,~(Permission.ops_field(Ops(H,Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>),caps)),scope,local)
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
  wrapped(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,Task.define(~S,~C,~R,~E,~ScopedOps(~S,~layout,~route,~Ops),~Captures(~S,~layout,~route,~User),~Error,~Out,~program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),~runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),~(Layout.columns(~S,layout)),~WR,world,name,Local.fresh(~S,~(Layout.payload(layout,route)),~(Removed.Removed(layout)),~User,user,declared_permission(~S,~C,~R,~layout,~route,~Ops,~declaration))))

type Metadata is Data:
  Metadata{id:U32,component:String,permission:Permission.Permission}
def metadata(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),owner:Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Metadata:
  match owner:
    case Owner{Sys.Owner{namespace,+id,name,access,cursor,Local.Local{user,commands,+permission}}}:(Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,commands,permission}}},Metadata{id,Layout.key(layout,route),permission})

def pending_returned(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),meta:Task.Meta,user:User,permission:Permission.Permission,result:Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)> & Bool) -> Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool:
  match result:
    case (commands,pending):(Owner{Task.restored(~S,~C,~R,~E,~ScopedOps(~S,~layout,~route,~Ops),~Captures(~S,~layout,~route,~User),~Error,~Out,~program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),~runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),meta,Local.Local{user,commands,permission})},pending)
def pending(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),owner:Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool:
  match owner:
    case Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,commands,permission}}}:pending_returned(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,Task.Meta{namespace,id,name,access,cursor},user,permission,Buffer.pending(~S,~(Layout.payload(layout,route)),~(Removed.Removed(layout)),commands))
def published(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,meta:Task.Meta,user:User,permission:Permission.Permission,result:W.World<S,Layout.columns(~S,layout),WR,E> & Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>) -> W.World<S,Layout.columns(~S,layout),WR,E> & Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>:
  match result:
    case (world,commands):(world,Owner{Task.restored(~S,~C,~R,~E,~ScopedOps(~S,~layout,~route,~Ops),~Captures(~S,~layout,~route,~User),~Error,~Out,~program_for_buffer(~S,~C,~R,~layout,~route,~Ops,~declaration),~runner(~S,~layout,~route,~Ops,~User,~Error,~Out,~body),meta,Local.Local{user,commands,permission})})
def publication_verified(~S:Data,~WR:Type,~E:Data,~layout:Layout.Layout,coherent:Bool,result:W.World<S,Layout.columns(~S,layout),WR,E> & Bool) -> W.World<S,Layout.columns(~S,layout),WR,E> & Bool:
  match result:
    case (world,allowed):(world,Bool.and(coherent,allowed))
def publication_allowed(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,meta:Task.Meta,user:User,+permission:Permission.Permission,commands:Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>,tick:Tick.Tick,result:W.World<S,Layout.columns(~S,layout),WR,E> & Bool) -> W.World<S,Layout.columns(~S,layout),WR,E> & Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>:
  match result:
    case (world,False{}):published(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,meta,user,permission,(world,commands))
    case (world,True{}):published(~S,~C,~R,~E,~layout,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,meta,user,permission,Publication.apply_at(~S,~WR,~E,~layout,~route,~valid,permission,world,commands,tick))
def publish(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),~WR:Type,tick:Tick.Tick,world:W.World<S,Layout.columns(~S,layout),WR,E>,owner:Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> W.World<S,Layout.columns(~S,layout),WR,E> & Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>:
  match owner:
    case Owner{Sys.Owner{+namespace,+id,+name,+access,+cursor,Local.Local{user,commands,+permission}}}:publication_allowed(~S,~C,~R,~E,~layout,~route,~valid,~Ops,~User,~Error,~Out,~declaration,~body,~WR,Task.Meta{namespace,id,name,access,cursor},user,permission,commands,tick,publication_verified(~S,~WR,~E,~layout,Permission.agrees(permission,declared_permission(~S,~C,~R,~layout,~route,~Ops,~declaration)),Task.verify(~S,~(Layout.columns(~S,layout)),~WR,~E,Task.Meta{namespace,id,name,access,cursor},world)))

# Raw constructors are trusted administrative provisioning. Canonical admission
# validates the persisted cache against this owner's same closed declaration;
# no World payload is projected and no separately supplied catalog is consulted.
def permission_matches(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~Ops:Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~route,~Ops),~body:Body(~S,~layout,~route,~Ops,~User,~Error,~Out),owner:Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body>) -> Owner<S,C,R,E,layout,route,Ops,User,Error,Out,declaration,body> & Bool:
  match owner:
    case Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,commands,+permission}}}:(Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,commands,permission}}},Permission.agrees(permission,declared_permission(~S,~C,~R,~layout,~route,~Ops,~declaration)))
