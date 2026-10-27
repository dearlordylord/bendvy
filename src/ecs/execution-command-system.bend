import Base
import ./execution-reservation-task.bend as Effect
import ./execution-reservation-authority.bend as Request
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
import ./execution-relation-context.bend as Context

# Command owners have a distinct type, so an ordinary Sys.Owner leaf cannot
# silently omit their deferred inventory and publication operation.
def ScopedOps(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,Permit:Data,H:Type) -> Type:
  Permission.Prepared<Ops(Permit,H,Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>),S,resources>
def Program(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type) -> Type:
  @-Permit:Data -> @-H:Type -> @-Q:Type -> @-commands:Local.Commands<Q,S,Layout.payload(layout,route)> -> @-B:Type -> @-builder:Build.Builder(~S,~(Layout.columns(~S,layout)),~C,~R,~Permit,~H,~B) -> @-K:Type -> @-entity:Permission.Grant(~S,~layout,~Permit,~Q,~K) -> @-relations:Permission.RelationGrant(~S,~resources,~Q,~K) -> @-scopes:Permission.ScopeGrant(~S,~resources,~Q,~K) -> B -> K -> B & (K & Ops(Permit,H,Q))
def program_for_buffer(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S,~(Layout.columns(~S,layout)),~C,~R,~Permit,~H,~B),book:B) -> B & ScopedOps(~S,~layout,~resources,~route,~Ops,Permit,H):
  Permission.prepared(~S,~layout,~resources,B,Ops(Permit,H,Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>),declaration(Permit,H,Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>,Local.canonical(~S,~(Layout.payload(layout,route)),~(Removed.Removed(layout))),B,builder,Permission.Book<S,layout,resources>,Permission.grant(~S,~layout,~resources,~Permit,~(Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>),~(Buffer.despawn(~S,~(Layout.payload(layout,route)),~(Removed.Removed(layout)))),~(Buffer.spawn(~S,~(Layout.payload(layout,route)),~(Removed.Removed(layout)),~Permit,~token))),Permission.relation_grant(~S,~layout,~resources,~Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>,~Buffer.relation(~S,~Layout.payload(layout,route),~Removed.Removed(layout))),Permission.scope_grant(~S,~layout,~resources,~Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>,~Buffer.lifetime_scope(~S,~Layout.payload(layout,route),~Removed.Removed(layout))),book,Permission.fresh(~S,~layout,~resources)))
def Body(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data) -> Type:
  @-Permit:Data -> @-H:Type -> @-Q:Type -> @-caps:Ops(Permit,H,Q) -> @-commands:Local.Commands<Q,S,Layout.payload(layout,route)> -> H -> Q -> User -> Effect.Task<S,Permit,H & (Q & (User & Sys.Completion<Error,Out>))>
def Captures(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~User:Type) -> Type:
  Local.Local<S,Layout.payload(layout,route),Removed.Removed(layout),User>
def prepared_permission(~S:Data,~resources:Layout.Layout,-Ops:Type,value:Permission.Prepared<Ops,S,resources>) -> Permission.Permission:
  match value:
    case Permission.Prepared{permission,relations,_,_}:permission
type CheckedPermission<-S:Data,-resources:Layout.Layout> is Data:
  ReadyPermission{permission:Permission.Permission,relations:Permission.Relations<S,resources>}
  UnsupportedPermission{permission:Permission.Permission,relations:Permission.Relations<S,resources>}
def compiled_permission(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,value:D.Compilation<S,Layout.columns(~S,layout),C,R,ScopedOps(~S,~layout,~resources,~route,~Ops)>) -> CheckedPermission<S,resources>:
  match value:
    case D.Supported{D.Declaration{Permission.Prepared{permission,relations,_,_},_},_}:ReadyPermission{permission,relations}
    case D.Unsupported{Permission.Prepared{permission,relations,_,_},_,_}:UnsupportedPermission{permission,relations}
def inspect_permission(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,value:D.Compilation<S,Layout.columns(~S,layout),C,R,ScopedOps(~S,~layout,~resources,~route,~Ops)>) -> D.Compilation<S,Layout.columns(~S,layout),C,R,ScopedOps(~S,~layout,~resources,~route,~Ops)> & CheckedPermission<S,resources>:
  match value:
    case D.Supported{D.Declaration{Permission.Prepared{+permission,+relations,selection,ops},access},recipes}:(D.Supported{D.Declaration{Permission.Prepared{permission,relations,selection,ops},access},recipes},ReadyPermission{permission,relations})
    case D.Unsupported{Permission.Prepared{+permission,+relations,selection,ops},access,recipes}:(D.Unsupported{Permission.Prepared{permission,relations,selection,ops},access,recipes},UnsupportedPermission{permission,relations})
# Static construction projection only. Ordinary barriers retain and inspect the
# actual Compilation; they never invoke this projection on its affine caps.
def construction_selection(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,value:D.Compilation<S,Layout.columns(~S,layout),C,R,ScopedOps(~S,~layout,~resources,~route,~Ops)>) -> Permission.Selection<S,resources>:
  match value:
    case D.Supported{D.Declaration{Permission.Prepared{_,_,selection,_},_},_}:selection
    case D.Unsupported{Permission.Prepared{_,_,selection,_},_,_}:selection
def declared_permission(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops)) -> CheckedPermission<S,resources>:
  compiled_permission(~S,~C,~R,~layout,~resources,~route,~Ops,Build.compile_framework(~S,~(Layout.columns(~S,layout)),~C,~R,~ScopedOps(~S,~layout,~resources,~route,~Ops),~program_for_buffer(~S,~C,~R,~layout,~resources,~route,~Ops,~declaration)))
def checked_permission_agrees(~S:Data,~resources:Layout.Layout,permission:Permission.Permission,checked:CheckedPermission<S,resources>) -> Bool:
  match checked:
    case ReadyPermission{expected,_}:Permission.agrees(permission,expected)
    case UnsupportedPermission{_,_}:False{}
def checked_relations(~S:Data,~resources:Layout.Layout,checked:CheckedPermission<S,resources>) -> Permission.Relations<S,resources>:
  match checked:
    case ReadyPermission{_,relations}:relations
    case UnsupportedPermission{_,relations}:relations
def checked_deferred_descriptions(~S:Data,~resources:Layout.Layout,checked:CheckedPermission<S,resources>) -> List<&2,Permission.DeferredRelation<S>>:
  Permission.deferred_descriptions(~S,~resources,checked_relations(~S,~resources,checked))

def runner(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out),~Permit:Data,~H:Type,~caps:ScopedOps(~S,~layout,~resources,~route,~Ops,Permit,H),scope:H,local:Captures(~S,~layout,~resources,~route,~User)) -> Effect.Task<S,Permit,H & (Captures(~S,~layout,~resources,~route,~User) & Sys.Completion<Error,Out>)>:
  Local.invoke(~S,~(Layout.payload(layout,route)),~(Removed.Removed(layout)),~Permit,~User,~Error,~Out,~Ops,~body,~H,~(Permission.ops_field(Ops(Permit,H,Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>),S,resources,caps)),scope,local)
def System(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),~body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out)) -> Type:
  Sys.Owner<S,Layout.columns(~S,layout),C,R,E,ScopedOps(~S,~layout,~resources,~route,~Ops),Captures(~S,~layout,~resources,~route,~User),Error,Out,program_for_buffer(~S,~C,~R,~layout,~resources,~route,~Ops,~declaration),runner(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out,~body)>
type Owner<-S:Data,-C:Type,-R:Type,-E:Data,-layout:Layout.Layout,-resources:Layout.Layout,-route:Layout.Route,-Ops:Data -> Type -> Type -> Type,-User:Type,-Error:Data,-Out:Data,-declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),-body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out)> is Type:
  Owner{system:Sys.Owner<S,Layout.columns(~S,layout),C,R,E,ScopedOps(~S,~layout,~resources,~route,~Ops),Captures(~S,~layout,~resources,~route,~User),Error,Out,program_for_buffer(~S,~C,~R,~layout,~resources,~route,~Ops,~declaration),runner(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out,~body)>}
def wrapped(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),~body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out),~WR:Type,result:Sys.Defined<W.World<S,Layout.columns(~S,layout),WR,E>,Sys.Owner<S,Layout.columns(~S,layout),C,R,E,ScopedOps(~S,~layout,~resources,~route,~Ops),Captures(~S,~layout,~resources,~route,~User),Error,Out,program_for_buffer(~S,~C,~R,~layout,~resources,~route,~Ops,~declaration),runner(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out,~body)>,Captures(~S,~layout,~resources,~route,~User)>) -> Sys.Defined<W.World<S,Layout.columns(~S,layout),WR,E>,Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body>,Captures(~S,~layout,~resources,~route,~User)>:
  match result:
    case Sys.Defined{world,system}:Sys.Defined{world,Owner{system}}
    case Sys.DefinitionRefused{world,local}:Sys.DefinitionRefused{world,local}

# The full command schema fixes the inserted payload type and destination.
# C/R describe the physical gameplay scope, which may be one root-cut branch;
# registration always uses the actual complete World and its single allocator.
def define_checked(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),~body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out),~WR:Type,world:W.World<S,Layout.columns(~S,layout),WR,E>,name:String,user:User,checked:CheckedPermission<S,resources>) -> Sys.Defined<W.World<S,Layout.columns(~S,layout),WR,E>,Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body>,Captures(~S,~layout,~resources,~route,~User)>:
  match checked:
    case UnsupportedPermission{permission,relations}:Sys.DefinitionRefused{world,Local.fresh(~S,~(Layout.payload(layout,route)),~(Removed.Removed(layout)),~User,user,permission)}
    case ReadyPermission{permission,relations}:wrapped(~S,~C,~R,~E,~layout,~resources,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,Task.define_framework(~S,~(Layout.columns(~S,layout)),~C,~R,~E,~ScopedOps(~S,~layout,~resources,~route,~Ops),~Captures(~S,~layout,~resources,~route,~User),~Error,~Out,~program_for_buffer(~S,~C,~R,~layout,~resources,~route,~Ops,~declaration),~runner(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out,~body),~WR,world,name,Local.fresh(~S,~(Layout.payload(layout,route)),~(Removed.Removed(layout)),~User,user,permission)))
def define(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),~body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out),~WR:Type,world:W.World<S,Layout.columns(~S,layout),WR,E>,name:String,user:User) -> Sys.Defined<W.World<S,Layout.columns(~S,layout),WR,E>,Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body>,Captures(~S,~layout,~resources,~route,~User)>:
  define_checked(~S,~C,~R,~E,~layout,~resources,~route,~valid,~Ops,~User,~Error,~Out,~declaration,~body,~WR,world,name,user,declared_permission(~S,~C,~R,~layout,~resources,~route,~Ops,~declaration))

type Metadata is Data:
  Metadata{id:U32,component:String,permission:Permission.Permission}
def metadata(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),~body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out),owner:Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body>) -> Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body> & Metadata:
  match owner:
    case Owner{Sys.Owner{namespace,+id,name,access,cursor,Local.Local{user,commands,+permission}}}:(Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,commands,permission}}},Metadata{id,Layout.key(layout,route),permission})

def pending_returned(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),~body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out),meta:Task.Meta<System(~S,~C,~R,~E,~layout,~resources,~route,~Ops,~User,~Error,~Out,~declaration,~body)>,user:User,permission:Permission.Permission,result:Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)> & Bool) -> Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body> & Bool:
  match result:
    case (commands,pending):(Owner{Task.restored(~S,~(Layout.columns(~S,layout)),~C,~R,~E,~ScopedOps(~S,~layout,~resources,~route,~Ops),~Captures(~S,~layout,~resources,~route,~User),~Error,~Out,~program_for_buffer(~S,~C,~R,~layout,~resources,~route,~Ops,~declaration),~runner(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out,~body),meta,Local.Local{user,commands,permission})},pending)
def pending(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),~body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out),owner:Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body>) -> Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body> & Bool:
  match owner:
    case Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,commands,permission}}}:pending_returned(~S,~C,~R,~E,~layout,~resources,~route,~Ops,~User,~Error,~Out,~declaration,~body,Task.Meta{namespace,id,name,access,cursor},user,permission,Buffer.pending(~S,~(Layout.payload(layout,route)),~(Removed.Removed(layout)),commands))
def published(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),~body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out),~WR:Type,meta:Task.Meta<System(~S,~C,~R,~E,~layout,~resources,~route,~Ops,~User,~Error,~Out,~declaration,~body)>,user:User,permission:Permission.Permission,result:W.World<S,Layout.columns(~S,layout),WR,E> & Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>) -> W.World<S,Layout.columns(~S,layout),WR,E> & Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body>:
  match result:
    case (world,commands):(world,Owner{Task.restored(~S,~(Layout.columns(~S,layout)),~C,~R,~E,~ScopedOps(~S,~layout,~resources,~route,~Ops),~Captures(~S,~layout,~resources,~route,~User),~Error,~Out,~program_for_buffer(~S,~C,~R,~layout,~resources,~route,~Ops,~declaration),~runner(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out,~body),meta,Local.Local{user,commands,permission})})
def publication_verified(~S:Data,~WR:Type,~E:Data,~layout:Layout.Layout,coherent:Bool,result:W.World<S,Layout.columns(~S,layout),WR,E> & Bool) -> W.World<S,Layout.columns(~S,layout),WR,E> & Bool:
  match result:
    case (world,allowed):(world,Bool.and(coherent,allowed))
def publication_authorized(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),~body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out),~WR:Type,~sameWR:{WR == Layout.resources(~S,resources) : Type},~relations:Permission.Relations<S,resources>,~selection:Permission.Selection<S,resources>,+context:Context.Context<S,WR,resources,sameWR>,meta:Task.Meta<System(~S,~C,~R,~E,~layout,~resources,~route,~Ops,~User,~Error,~Out,~declaration,~body)>,user:User,+permission:Permission.Permission,+checked:CheckedPermission<S,resources>,commands:Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>,tick:Tick.Tick,result:W.World<S,Layout.columns(~S,layout),WR,E> & Bool) -> W.World<S,Layout.columns(~S,layout),WR,E> & Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body>:
  match result:
    case (world,False{}):published(~S,~C,~R,~E,~layout,~resources,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,meta,user,permission,(world,commands))
    case (world,True{}):published(~S,~C,~R,~E,~layout,~resources,~route,~Ops,~User,~Error,~Out,~declaration,~body,~WR,meta,user,permission,Publication.apply_at(~S,~WR,~E,~layout,~route,~valid,~resources,~sameWR,~selection,~relations,context,permission,world,commands,tick))
def publication_allowed(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),~body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out),~WR:Type,~sameWR:{WR == Layout.resources(~S,resources) : Type},~relations:Permission.Relations<S,resources>,~selection:Permission.Selection<S,resources>,+context:Context.Context<S,WR,resources,sameWR>,meta:Task.Meta<System(~S,~C,~R,~E,~layout,~resources,~route,~Ops,~User,~Error,~Out,~declaration,~body)>,user:User,+permission:Permission.Permission,+checked:CheckedPermission<S,resources>,commands:Buffer.Buffer<S,Layout.payload(layout,route),Removed.Removed(layout)>,tick:Tick.Tick,result:W.World<S,Layout.columns(~S,layout),WR,E> & Bool) -> W.World<S,Layout.columns(~S,layout),WR,E> & Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body>:
  publication_authorized(~S,~C,~R,~E,~layout,~resources,~route,~valid,~Ops,~User,~Error,~Out,~declaration,~body,~WR,~sameWR,~relations,~selection,context,meta,user,permission,checked,commands,tick,publication_verified(~S,~WR,~E,~layout,Bool.and(checked_permission_agrees(~S,~resources,permission,checked),Permission.relations_agree(~S,~resources,relations,checked_relations(~S,~resources,checked))),result))
def publish(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),~body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out),~WR:Type,~sameWR:{WR == Layout.resources(~S,resources) : Type},~relations:Permission.Relations<S,resources>,~selection:Permission.Selection<S,resources>,checked:CheckedPermission<S,resources>,tick:Tick.Tick,world:W.World<S,Layout.columns(~S,layout),WR,E>,owner:Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body>) -> W.World<S,Layout.columns(~S,layout),WR,E> & Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body>:
  match owner:
    case Owner{Sys.Owner{+namespace,+id,+name,+access,+cursor,Local.Local{user,commands,+permission}}}:publication_allowed(~S,~C,~R,~E,~layout,~resources,~route,~valid,~Ops,~User,~Error,~Out,~declaration,~body,~WR,~sameWR,~relations,~selection,Context.Context{namespace},Task.Meta{namespace,id,name,access,cursor},user,permission,checked,commands,tick,Task.verify(~S,~(Layout.columns(~S,layout)),~WR,~E,~System(~S,~C,~R,~E,~layout,~resources,~route,~Ops,~User,~Error,~Out,~declaration,~body),Task.Meta{namespace,id,name,access,cursor},world))

# Raw constructors are trusted administrative provisioning. Canonical admission
# validates the persisted cache against this owner's same closed declaration;
# no World payload is projected and no separately supplied catalog is consulted.
def permission_matches(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,~User:Type,~Error:Data,~Out:Data,~declaration:Program(~S,~C,~R,~layout,~resources,~route,~Ops),~body:Body(~S,~layout,~resources,~route,~Ops,~User,~Error,~Out),checked:CheckedPermission<S,resources>,owner:Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body>) -> Owner<S,C,R,E,layout,resources,route,Ops,User,Error,Out,declaration,body> & Bool:
  match owner:
    case Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,commands,+permission}}}:(Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,commands,permission}}},checked_permission_agrees(~S,~resources,permission,checked))

# Read the permission from the same accepted compilation's actual caps, then
# return those caps unchanged. This is a fixed framework adapter, not a body
# supplied permission callback or a second declaration compilation.
def grant_of_caps(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout,~route:Layout.Route,~Ops:Data -> Type -> Type -> Type,~H:Type,caps:ScopedOps(~S,~layout,~resources,~route,~Ops,Effect.Granted,H)) -> ScopedOps(~S,~layout,~resources,~route,~Ops,Effect.Granted,H) & Request.Grant:
  match caps:
    case Permission.Prepared{Permission.FamilyOnly{},relations,selection,ops}:(Permission.Prepared{Permission.FamilyOnly{},relations,selection,ops},Request.NoStructural{})
    case Permission.Prepared{Permission.EntityStructural{},relations,selection,ops}:(Permission.Prepared{Permission.EntityStructural{},relations,selection,ops},Request.Structural{})
