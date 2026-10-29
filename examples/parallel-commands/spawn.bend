import Base
import ../../src/ecs/execution-lifetime-scope-description.bend as LinkedText
import ../../src/ecs/execution-reservation-task.bend as Effect
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-removed.bend as Removed
import ./controls/positive.bend as P
import ./controls/registered.bend as Registered
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/trace-world.bend as Trace
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/deferred-command.bend as Deferred
import ../../test-fixtures/common/column-observation.bend as Observe

type Schema is Data:
  Schema{}
type Parcel is Type:
  Parcel{owner:Array<String>}
def parcel_read(result:Array<String> & String) -> Parcel & String:
  match result:
    case (owner,value):(Parcel{owner},value)
def parcel_refresh(owner:Parcel) -> Parcel & String:
  match owner:
    case Parcel{owner}:parcel_read(Array.get(String,owner,0))
def local_layout() -> Layout.Layout:Layout.LayoutPair{Registered.layout(),Layout.LayoutLeaf{Parcel,String,parcel_refresh,"parcel",Policy.Ordinary{}}}
def layout() -> Layout.Layout:Layout.LayoutPair{local_layout(),Layout.EmptyLayout{}}
def path() -> Layout.Route:Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}}
def Left() -> Type:Layout.columns(~Schema,local_layout())
def Store() -> Type:Layout.columns(~Schema,layout())
def Resources() -> Type:Product.Owner<Unit,Unit>
def resources() -> Layout.Layout:Layout.LayoutPair{Layout.EmptyLayout{},Layout.EmptyLayout{}}
def Ops(Permit:Data,H:Type) -> Type:Unit
def CmdOps(Permit:Data,H:Type,Q:Type) -> Type:Permission.EntityCommands<Q,Schema,layout(),Permit>
def author_granted(~Permit:Data,~H:Type,~Q:Type,~B:Type,~K:Type,book:B,result:K & CmdOps(Permit,H,Q)) -> B & (K & CmdOps(Permit,H,Q)):
  match result:
    case (permission,caps):(book,(permission,caps))
def author_declaration(~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,Schema,P.Token>,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Left(),~Unit,~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~Schema,~layout(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~Schema,~resources(),~Q,~K),~scopes:Permission.ScopeGrant(~Schema,~resources(),~Q,~K),book:B,permission:K) -> B & (K & CmdOps(Permit,H,Q)):
  author_granted(~Permit,~H,~Q,~B,~K,book,Permission.entity(~Schema,~layout(),~Permit,~Q,~K,~entity,permission))

def peer_declaration(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Unit,~Unit,~Permit,~H,~B),book:B) -> B & Unit:
  (book,Unit{})
def peer_written(~H:Type,scope:H,result:Array<U32> & U32) -> H & (Array<U32> & Sys.Completion<String,Unit>):
  match result:
    case (token,_):(scope,(token,Sys.Success{Unit{}}))
def peer_seen(~H:Type,scope:H,result:Array<U32> & U32) -> H & (Array<U32> & Sys.Completion<String,Unit>):
  match result:
    case (token,value):peer_written(~H,scope,Array.swap(U32,token,0,U32.add(value,1)))
def peer_body_sync(~Permit:Data,~H:Type,~caps:Unit,scope:H,token:Array<U32>) -> H & (Array<U32> & Sys.Completion<String,Unit>):
  peer_seen(~H,scope,Array.get(U32,token,0))

def peer_body(~Permit:Data,~H:Type,~caps:Unit,scope:H,token:Array<U32>) -> Effect.Task<Schema,Permit,H & (Array<U32> & Sys.Completion<String,Unit>)>:
  Effect.TRun{_ => Effect.TDone{peer_body_sync(~Permit,~H,~caps,scope,token)}}

type AuthorLocal is Type:
  AuthorLocal{capture:P.Capture<Schema>,enabled:Bool,rejected:Maybe<&1,Removed.Removed(layout())>,reason:Maybe<&2,W.WorldError>}
def bundle() -> Removed.Removed(layout()):
  Product.Owner{Product.Owner{Some{P.Token{ALeaf{71}}},Some{Parcel{ALeaf{"parcel-payload"}}}},Unit{}}
def spawn_returned(~Permit:Data,~H:Type,~Q:Type,scope:H,prior:P.Capture<Schema>,result:Q & Buffer.SpawnAdmission<Schema,Removed.Removed(layout())>) -> Effect.Task<Schema,Permit,H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))>:
  match result:
    case (queue,Buffer.SpawnQueued{handle}):Effect.TDone{(scope,(queue,(AuthorLocal{P.Capture{handle},True{},None{},None{}},Sys.BodyError{"after-spawn",Unit{}})))}
    case (queue,Buffer.SpawnRejected{bundle,error}):Effect.TDone{(scope,(queue,(AuthorLocal{prior,True{},Some{bundle},Some{error}},Sys.BodyError{"reservation-refused",Unit{}})))}
def author_body(~Permit:Data,~H:Type,~Q:Type,~caps:CmdOps(Permit,H,Q),~commands:Local.Commands<Q,Schema,P.Token>,scope:H,queue:Q,local:AuthorLocal) -> Effect.Task<Schema,Permit,H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))>:
  match local:
    case AuthorLocal{capture,True{},Some{rejected},reason}:Effect.TDone{(scope,(queue,(AuthorLocal{capture,True{},Some{rejected},reason},Sys.BodyError{"reservation-still-refused",Unit{}})))}
    case AuthorLocal{capture,True{},None{},_}:Effect.bind(Schema,Permit,Q & Buffer.SpawnAdmission<Schema,Removed.Removed(layout())>,H & (Q & (AuthorLocal & Sys.Completion<String,Unit>)),Permission.spawn_field(~Q,~Schema,~layout(),~Permit,caps)(queue,bundle()),result => spawn_returned(~Permit,~H,~Q,scope,capture,result))
    case AuthorLocal{capture,False{},rejected,reason}:Effect.TDone{(scope,(queue,(AuthorLocal{capture,False{},rejected,reason},Sys.Success{Unit{}})))}

def Author() -> Type:Cmd.Owner<Schema,Left(),Unit,Unit,layout(),resources(),path(),CmdOps,AuthorLocal,String,Unit,author_declaration,author_body>
def Peer() -> Type:Sys.Owner<Schema,Store(),Unit,Unit,Unit,Ops,Array<U32>,String,Unit,Build.framework_program(~Schema,~Store(),~Unit,~Unit,~Ops,~peer_declaration),peer_body>
def left(~F:Tree.Family(),~leaf:Tree.Leaf(~Schema,~Store(),~Left(),~Unit,~Unit,~resources(),~String,~Unit,~F),~command:Tree.CommandLeaf(~Schema,~Store(),~Left(),~Unit,~Unit,~resources(),~String,~Unit,~F),~join:Tree.Join(~F),owner:Author()) -> F(Author()):
  command(layout(),path(),{==},{==},CmdOps,AuthorLocal,author_declaration,author_body,owner)
def right(~F:Tree.Family(),~leaf:Tree.Leaf(~Schema,~Store(),~Unit,~Unit,~Unit,~resources(),~String,~Unit,~F),~command:Tree.CommandLeaf(~Schema,~Store(),~Unit,~Unit,~Unit,~resources(),~String,~Unit,~F),~join:Tree.Join(~F),owner:Peer()) -> F(Peer()):
  leaf(Ops,Array<U32>,Build.framework_program(~Schema,~Store(),~Unit,~Unit,~Ops,~peer_declaration),peer_body,owner)
type Handler is Type:
  Handler{token:Array<U32>,errors:U32}
def handle(handler:Handler,error:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def Application() -> Type:Schedule.Scheduled<DepApp.State<W.World<Schema,Store(),Resources(),Unit>,Product.Owner<Author(),Peer()>,Unit,Handler>>

def token_value(result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def token(owner:P.Token) -> String:
  match owner:
    case P.Token{owner}:token_value(Array.get(U32,owner,0))
def maybe_token(owner:Maybe<&1,P.Token>) -> String:
  match owner:
    case None{}:"none"
    case Some{owner}:token(owner)
def handle_text(value:W.Handle<Schema>) -> String:
  match value:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Observe.key(key)
def parcel_value(result:Array<String> & String) -> String:
  match result:
    case (_,value):value
def parcel(owner:Parcel) -> String:
  match owner:
    case Parcel{owner}:parcel_value(Array.get(String,owner,0))
def maybe_parcel(owner:Maybe<&1,Parcel>) -> String:
  match owner:
    case None{}:"none"
    case Some{owner}:parcel(owner)
def bundle_text(owner:Removed.Removed(layout())) -> String:
  match owner:
    case Product.Owner{Product.Owner{tokenOwner,parcelOwner},_}:"token=" ++ maybe_token(tokenOwner) ++ ",parcel=" ++ maybe_parcel(parcelOwner)
def rejected_text(owner:Maybe<&1,Removed.Removed(layout())>) -> String:
  match owner:
    case None{}:"none"
    case Some{owner}:bundle_text(owner)
def rejection_text(reason:Maybe<&2,W.WorldError>) -> String:
  match reason:
    case None{}:"none"
    case Some{error}:Trace.error(error)
def entry(value:Buffer.Entry<Schema,P.Token,Removed.Removed(layout())>) -> String:
  match value:
    case Buffer.Entry{handle,incoming}:handle_text(handle) ++ ":" ++ maybe_token(incoming)
    case Buffer.Despawn{handle}:"despawn:" ++ handle_text(handle)
    case Buffer.Spawn{handle,incoming}:"spawn:" ++ handle_text(handle) ++ ":" ++ bundle_text(incoming)
    case Buffer.Relation{_,_}:"relation"
    case Buffer.LifetimeScope{_,_}:"lifetime-scope"
def spawn_reason(reason:Bundle.Refusal) -> String:
  match reason:
    case Bundle.InvalidPending{error}:"pending:" ++ Trace.error(error)
    case Bundle.PermissionDenied{}:"permission"
    case Bundle.DuplicateFamily{}:"duplicate-family"
    case Bundle.PhysicalIndex{}:"physical-index"
    case Bundle.MalformedColumn{key}:"malformed:" ++ key
    case Bundle.OccupiedFamily{key}:"occupied:" ++ key
def receipt(value:Buffer.Receipt<Schema,P.Token,Removed.Removed(layout())>) -> String:
  match value:
    case Buffer.Applied{handle,previous}:"applied:" ++ handle_text(handle) ++ ":" ++ maybe_token(previous)
    case Buffer.Refused{handle,incoming}:"refused:" ++ handle_text(handle) ++ ":" ++ maybe_token(incoming)
    case Buffer.Despawned{handle,removed}:"despawned:" ++ handle_text(handle) ++ ":" ++ bundle_text(removed)
    case Buffer.DespawnRefused{handle}:"despawn-refused:" ++ handle_text(handle)
    case Buffer.LinkedDespawn{handle,status,_,_}:"linked-despawn:" ++ handle_text(handle) ++ ":" ++ LinkedText.linked_status(status)
    case Buffer.Spawned{handle,previous}:"spawned:" ++ handle_text(handle) ++ ":" ++ bundle_text(previous)
    case Buffer.SpawnRefused{handle,incoming,reason}:"spawn-refused:" ++ handle_text(handle) ++ ":" ++ bundle_text(incoming) ++ ":" ++ spawn_reason(reason)
    case Buffer.RelationPublished{_,_}:"relation-published"
    case Buffer.RelationUndeclared{_,_}:"relation-undeclared"
    case Buffer.ScopePublished{_,_,status,_,_}:"scope-published:" ++ LinkedText.status(status)
    case Buffer.ScopeStoreApplied{_,_,_}:"scope-store-applied"
def viewed_result(+cache:U32,result:Array<U32> & U32) -> Layout.Viewed<P.Token,U32> & String:
  match result:
    case (owner,+value):(Layout.Viewed{P.Token{owner},cache},U32.show(value) ++ "/cache=" ++ U32.show(cache))
def viewed(value:Layout.Viewed<P.Token,U32>) -> Layout.Viewed<P.Token,U32> & String:
  match value:
    case Layout.Viewed{P.Token{owner},cache}:viewed_result(cache,Array.get(U32,owner,0))
def parcel_viewed_result(+cache:String,result:Array<String> & String) -> Layout.Viewed<Parcel,String> & String:
  match result:
    case (owner,value):(Layout.Viewed{Parcel{owner},cache},value ++ "/cache=" ++ cache)
def parcel_viewed(value:Layout.Viewed<Parcel,String>) -> Layout.Viewed<Parcel,String> & String:
  match value:
    case Layout.Viewed{Parcel{owner},cache}:parcel_viewed_result(cache,Array.get(String,owner,0))
def world(world:W.World<Schema,Store(),Resources(),Unit>) -> String:
  match world:
    case W.World{namespace,allocator,Product.Owner{Product.Owner{Layout.ColumnSlot{column},Layout.ColumnSlot{other}},_},_,events,pending,registrations,next,clock,lifecycle}:"namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ Observe.allocator(allocator) ++ "};column=" ++ Observe.capacity_done(~Schema,~Layout.Viewed<P.Token,U32>,~viewed,Column.capacity(~Schema,~Layout.Viewed<P.Token,U32>,column)) ++ ";parcel=" ++ Observe.capacity_done(~Schema,~Layout.Viewed<Parcel,String>,~parcel_viewed,Column.capacity(~Schema,~Layout.Viewed<Parcel,String>,other)) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";legacy-pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<Schema,Store(),Resources(),Unit>>,pending)) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Observe.registration,registrations) ++ ";next=" ++ U32.show(next) ++ ";clock=" ++ Observe.clock(clock)
def event(value:Exec.Observation<String,Unit>) -> String:
  match value:
    case Exec.Ran{id,_}:"ran:" ++ U32.show(id)
    case Exec.BodyFailed{id,error,_}:"error:" ++ U32.show(id) ++ ":" ++ error
    case Exec.Skipped{id}:"skip:" ++ U32.show(id)
    case Exec.AdmissionRejected{id}:"refused:" ++ U32.show(id)
    case Exec.ConditionFailed{id,error}:"condition-error:" ++ U32.show(id) ++ ":" ++ error
    case Exec.ConditionRejected{id}:"condition-refused:" ++ U32.show(id)
def report(value:DepApp.Report<String,Unit>) -> String:
  match value:
    case DepApp.Finished{events}:List.show(&2,Exec.Observation<String,Unit>,event,events)
    case DepApp.Stopped{_,events}:"stopped:" ++ List.show(&2,Exec.Observation<String,Unit>,event,events)
    case DepApp.Invalid{_}:"invalid"
def observed(prefix:String,application:Application()) -> String:
  match application:
    case Schedule.Scheduled{DepApp.State{owner,Product.Owner{Cmd.Owner{Sys.Owner{_,_,_,_,cursor,Local.Local{AuthorLocal{P.Capture{handle},_,rejected,reason},Buffer.Buffer{pending,receipts},_}}},Sys.Owner{_,_,_,_,peerCursor,peer}},_,Handler{handler,errors},_},_,_,_,Schedule.Deferred{_,_,unapplied}}:prefix ++ "|world=" ++ world(owner) ++ "|queue=" ++ List.show(&1,Buffer.Entry<Schema,P.Token,Removed.Removed(layout())>,entry,pending) ++ "|receipts=" ++ List.show(&1,Buffer.Receipt<Schema,P.Token,Removed.Removed(layout())>,receipt,receipts) ++ "|rejected=" ++ rejected_text(rejected) ++ ":" ++ rejection_text(reason) ++ "|handle=" ++ handle_text(handle) ++ "|cursor=" ++ Tick.cursor_show(cursor) ++ "|peer=" ++ token_value(Array.get(U32,peer,0)) ++ ":" ++ Tick.cursor_show(peerCursor) ++ "|handler=" ++ token_value(Array.get(U32,handler,0)) ++ ":" ++ U32.show(errors) ++ "|unapplied=" ++ List.show(&2,U32,U32.show,unapplied)
def pending_observed(prefix:String,result:Application() & Bool) -> String:
  match result:
    case (application,pending):observed(prefix ++ ";exact-pending=" ++ Bool.pick(String,pending,"true","false"),application)
def selected(native:Bool,app:Application()) -> IO(Application() & DepApp.Report<String,Unit>):
  match native:
    case False{}:Schedule.run_serial(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~resources(),~{==},~String,~Unit,~Author(),~Peer(),~left,~right,~Unit,~Handler,~Conditions.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String),~Conditions.empty(~W.World<Schema,Store(),Resources(),Unit>,~String),~handle,app)
    case True{}:Schedule.run_native(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~resources(),~{==},~String,~Unit,~Author(),~Peer(),~left,~right,~Unit,~Handler,~Conditions.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String),~Conditions.empty(~W.World<Schema,Store(),Resources(),Unit>,~String),~handle,app)
def second(native:Bool,prefix:String,result:Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,done):pending_observed(prefix ++ ";" ++ report(done),Schedule.pending(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~resources(),~{==},~String,~Unit,~Author(),~Peer(),~left,~right,~Unit,~Handler,~Conditions.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String),~Conditions.empty(~W.World<Schema,Store(),Resources(),Unit>,~String),~handle,app))
def first(+native:Bool,result:Application() & DepApp.Report<String,Unit>) -> IO(String):
  match result:
    case (app,done):IO.bind(Application() & DepApp.Report<String,Unit>,String,selected(native,app),result => IO.pure(String,second(native,report(done),result)))
def built(settings:Settings.Settings,+native:Bool,world:W.World<Schema,Store(),Resources(),Unit>,author:Author(),peer:Peer()) -> IO(String):
  IO.bind(Application() & DepApp.Report<String,Unit>,String,selected(native,Schedule.configure(~(DepApp.State<W.World<Schema,Store(),Resources(),Unit>,Product.Owner<Author(),Peer()>,Unit,Handler>),settings,Schedule.build(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~resources(),~{==},~String,~Unit,~Author(),~Peer(),~left,~right,~Unit,~Handler,~Conditions.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String),~Conditions.empty(~W.World<Schema,Store(),Resources(),Unit>,~String),~handle,~(name => True{}),world,Product.Owner{author,peer},Unit{},Handler{ALeaf{901},0},[],[]))),result => first(native,result))

def peer_defined(settings:Settings.Settings,native:Bool,author:Author(),result:Sys.Defined<W.World<Schema,Store(),Resources(),Unit>,Peer(),Array<U32>>) -> IO(String):
  match result:
    case Sys.Defined{world,peer}:built(settings,native,world,author,peer)
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"ERROR: peer definition")
def author_defined(settings:Settings.Settings,native:Bool,result:Sys.Defined<W.World<Schema,Store(),Resources(),Unit>,Author(),Cmd.Captures(~Schema,~layout(),~resources(),~path(),~AuthorLocal)>) -> IO(String):
  match result:
    case Sys.Defined{world,author}:peer_defined(settings,native,author,Task.define(~Schema,~Store(),~Unit,~Unit,~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_declaration,~peer_body,~Resources(),world,"peer",ALeaf{801}))
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"ERROR: author definition")
def activated(settings:Settings.Settings,enabled:Bool,native:Bool,handle:W.Handle<Schema>,result:W.World<Schema,Store(),Resources(),Unit> & W.Status) -> IO(String):
  match result:
    case (world,W.Accepted{}):author_defined(settings,native,Cmd.define(~Schema,~Left(),~Unit,~Unit,~layout(),~resources(),~path(),~{==},~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~Resources(),world,"author",AuthorLocal{P.Capture{handle},enabled,None{},None{}}))
    case (_,_):IO.pure(String,"ERROR: activation")
def reserved(settings:Settings.Settings,enabled:Bool,native:Bool,result:W.World<Schema,Store(),Resources(),Unit> & W.Reservation<Schema>) -> IO(String):
  match result:
    case (world,W.Reserved{+handle}):activated(settings,enabled,native,handle,W.activate(~Schema,~Store(),~Resources(),~Unit,world,handle))
    case (_,_):IO.pure(String,"ERROR: reservation")
def column(result:Column.SwapOutcome<Schema,Layout.Viewed<P.Token,U32>>) -> Column.Column<Schema,Layout.Viewed<P.Token,U32>>:
  match result:
    case Column.Accepted{column,_}:column
    case Column.Rejected{column,_}:column
def parcel_column(result:Column.SwapOutcome<Schema,Layout.Viewed<Parcel,String>>) -> Column.Column<Schema,Layout.Viewed<Parcel,String>>:
  match result:
    case Column.Accepted{column,_}:column
    case Column.Rejected{column,_}:column
def empty(_:Unit) -> Store():
  Product.Owner{Product.Owner{Layout.ColumnSlot{column(Column.swap(~Schema,~Layout.Viewed<P.Token,U32>,Column.empty(~Schema,~Layout.Viewed<P.Token,U32>),0,Some{Layout.Viewed{P.Token{ALeaf{1}},1}}))},Layout.ColumnSlot{parcel_column(Column.swap(~Schema,~Layout.Viewed<Parcel,String>,Column.empty(~Schema,~Layout.Viewed<Parcel,String>),0,Some{Layout.Viewed{Parcel{ALeaf{"initial-parcel"}},"initial-parcel"}}))}},Unit{}}
# World.create admits actual seed columns. Occupancy at the next physical
# slot is refused at publication; the allocator/handle are never forged.
def collision(_:Unit) -> Store():
  Product.Owner{Product.Owner{Layout.ColumnSlot{column(Column.swap(~Schema,~Layout.Viewed<P.Token,U32>,Column.empty(~Schema,~Layout.Viewed<P.Token,U32>),1,Some{Layout.Viewed{P.Token{ALeaf{99}},99}}))},Layout.ColumnSlot{Column.empty(~Schema,~Layout.Viewed<Parcel,String>)}},Unit{}}

def created(settings:Settings.Settings,enabled:Bool,native:Bool,result:W.Creation<Schema,Store(),Resources(),Unit>) -> IO(String):
  match result:
    case W.Created{_,world}:reserved(settings,enabled,native,W.reserve_id(~Schema,~Store(),~Resources(),~Unit,world))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR: creation")
def run(settings:Settings.Settings,colliding:Bool,native:Bool) -> IO(String):
  match colliding:
    case False{}:created(settings,True{},native,W.create(~Schema,~Store(),~Resources(),~Unit,~empty,W.factory(),Product.Owner{Unit{},Unit{}}))
    case True{}:created(settings,True{},native,W.create(~Schema,~Store(),~Resources(),~Unit,~collision,W.factory(),Product.Owner{Unit{},Unit{}}))
def printed(result:String) -> IO(Unit):IO.print(result)
def main() -> IO(Unit):
  IO.bind(String,Unit,run(Settings.defaults(),False{},True{}),a => IO.bind(String,Unit,run(Settings.Settings{True{},False{},[],[]},False{},True{}),b => IO.bind(String,Unit,run(Settings.defaults(),True{},True{}),c => IO.bind(String,Unit,run(Settings.defaults(),False{},False{}),d => printed("native-spawn=" ++ a ++ "\nnative-retained=" ++ b ++ "\nnative-collision=" ++ c ++ "\nserial-spawn=" ++ d)))))
