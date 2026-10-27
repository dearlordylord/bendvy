import Base
import ./controls/removed-positive.bend as Fixture
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-removed.bend as Removed
import ./controls/positive.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-registry-program.bend as Prog
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/deferred-command.bend as Deferred
import ../../test-fixtures/common/column-observation.bend as Observe

type Schema is Data:
  Schema{}
def layout() -> Layout.Layout:Layout.LayoutPair{Fixture.layout(),Layout.EmptyLayout{}}
def path() -> Layout.Route:Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}}
def Left() -> Type:Layout.columns(~Schema,Fixture.layout())
def Store() -> Type:Layout.columns(~Schema,layout())
def Resources() -> Type:Product.Owner<Unit,Unit>
def Ops(H:Type) -> Type:Unit
def CmdOps(H:Type,Q:Type) -> Type:Permission.EntityCommands<Q,Schema,layout()>
def author_granted(~H:Type,~Q:Type,~B:Type,~K:Type,book:B,result:K & CmdOps(H,Q)) -> B & (K & CmdOps(H,Q)):
  match result:
    case (permission,ops):(book,(permission,ops))
def author_declaration(~H:Type,~Q:Type,~commands:Local.Commands<Q,Schema,P.Token>,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Left(),~Unit,~H,~B),~K:Type,~entity:Permission.Grant(~Schema,~layout(),~Q,~K),book:B,permission:K) -> B & (K & CmdOps(H,Q)):
  author_granted(~H,~Q,~B,~K,book,entity(permission))
def peer_declaration(~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Unit,~Unit,~H,~B),book:B) -> B & Unit:
  (book,Unit{})
def peer_body(~H:Type,~caps:Unit,scope:H,token:Array<U32>) -> H & (Array<U32> & Sys.Completion<String,Unit>):
  (scope,(token,Sys.Success{Unit{}}))
type AuthorLocal is Type:
  AuthorLocal{capture:P.Capture<Schema>,enabled:Bool}
def author_returned(~H:Type,~Q:Type,enabled:Bool,result:H & (Q & (P.Capture<Schema> & Sys.Completion<String,Unit>))) -> H & (Q & (AuthorLocal & Sys.Completion<String,Unit>)):
  match result:
    case (scope,(queue,(capture,done))):(scope,(queue,(AuthorLocal{capture,enabled},done)))
def despawned(~H:Type,~Q:Type,~caps:CmdOps(H,Q),scope:H,queue:Q,capture:P.Capture<Schema>) -> H & (Q & (P.Capture<Schema> & Sys.Completion<String,Unit>)):
  match capture:
    case P.Capture{+handle}:P.authored(~Schema,~H,~Q,scope,Permission.despawn_field(~Q,~Schema,~layout(),caps)(queue,handle),handle)
def author_body(~H:Type,~Q:Type,~caps:CmdOps(H,Q),~commands:Local.Commands<Q,Schema,P.Token>,scope:H,queue:Q,local:AuthorLocal) -> H & (Q & (AuthorLocal & Sys.Completion<String,Unit>)):
  match local:
    case AuthorLocal{capture,True{}}:author_returned(~H,~Q,True{},despawned(~H,~Q,~caps,scope,queue,capture))
    case AuthorLocal{capture,False{}}:(scope,(queue,(AuthorLocal{capture,False{}},Sys.Success{Unit{}})))
def Author() -> Type:Cmd.Owner<Schema,Left(),Unit,Unit,layout(),path(),CmdOps,AuthorLocal,String,Unit,author_declaration,author_body>
def Peer() -> Type:Sys.Owner<Schema,Store(),Unit,Unit,Unit,Ops,Array<U32>,String,Unit,peer_declaration,peer_body>
def left(~F:Tree.Family(),~leaf:Tree.Leaf(~Schema,~Store(),~Left(),~Unit,~Unit,~String,~Unit,~F),~command:Tree.CommandLeaf(~Schema,~Store(),~Left(),~Unit,~Unit,~String,~Unit,~F),~join:Tree.Join(~F),owner:Author()) -> F(Author()):
  command(layout(),path(),{==},{==},CmdOps,AuthorLocal,author_declaration,author_body,owner)
def right(~F:Tree.Family(),~leaf:Tree.Leaf(~Schema,~Store(),~Unit,~Unit,~Unit,~String,~Unit,~F),~command:Tree.CommandLeaf(~Schema,~Store(),~Unit,~Unit,~Unit,~String,~Unit,~F),~join:Tree.Join(~F),owner:Peer()) -> F(Peer()):
  leaf(Ops,Array<U32>,peer_declaration,peer_body,owner)
type Handler is Type:
  Handler{token:Array<U32>,errors:U32}
def handle(handler:Handler,error:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def Application() -> Type:Schedule.Scheduled<DepApp.Application<W.World<Schema,Store(),Resources(),Unit>,Product.Owner<Author(),Peer()>,Unit,Handler,String,Unit,Root.dispatch(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~Author(),~Peer(),~left,~right),Reg.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),handle>>
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
def entry(value:Buffer.Entry<Schema,P.Token>) -> String:
  match value:
    case Buffer.Entry{handle,incoming}:handle_text(handle) ++ ":" ++ maybe_token(incoming)
    case Buffer.Despawn{handle}:"despawn:" ++ handle_text(handle)
def receipt(value:Buffer.Receipt<Schema,P.Token,Removed.Removed(layout())>) -> String:
  match value:
    case Buffer.Applied{handle,previous}:"applied:" ++ handle_text(handle) ++ ":" ++ maybe_token(previous)
    case Buffer.Refused{handle,incoming}:"refused:" ++ handle_text(handle) ++ ":" ++ maybe_token(incoming)
    case Buffer.Despawned{handle,Product.Owner{removed,_}}:"despawned:" ++ handle_text(handle) ++ ":" ++ Fixture.receipt(removed)
    case Buffer.DespawnRefused{handle}:"despawn-refused:" ++ handle_text(handle)
def world(world:W.World<Schema,Store(),Resources(),Unit>) -> String:
  match world:
    case W.World{namespace,allocator,Product.Owner{Product.Owner{Layout.ColumnSlot{left},Layout.ColumnSlot{right}},_},_,events,pending,registrations,next,clock,lifecycle}:"namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ Observe.allocator(allocator) ++ "};left=" ++ Observe.capacity_done(~Schema,~Layout.Viewed<P.Token,U32>,~Fixture.token_project,Column.capacity(~Schema,~Layout.Viewed<P.Token,U32>,left)) ++ ";right=" ++ Observe.capacity_done(~Schema,~Layout.Viewed<Fixture.Other,U32>,~Fixture.other_project,Column.capacity(~Schema,~Layout.Viewed<Fixture.Other,U32>,right)) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";legacy-pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<Schema,Store(),Resources(),Unit>>,pending)) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Observe.registration,registrations) ++ ";next=" ++ U32.show(next) ++ ";clock=" ++ Observe.clock(clock)
def permission_text(value:Permission.Permission) -> String:
  match value:
    case Permission.FamilyOnly{}:"family"
    case Permission.EntityStructural{}:"entity"
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
    case Schedule.Scheduled{DepApp.Application{DepApp.State{owner,Product.Owner{Cmd.Owner{Sys.Owner{_,_,_,_,cursor,Local.Local{AuthorLocal{P.Capture{handle},_},Buffer.Buffer{pending,receipts},permission}}},Sys.Owner{_,_,_,_,peerCursor,peer}},_,Handler{handler,errors},_},_,_},_,Schedule.Deferred{_,_,unapplied}}:prefix ++ "|world=" ++ world(owner) ++ "|permission=" ++ permission_text(permission) ++ "|queue=" ++ List.show(&1,Buffer.Entry<Schema,P.Token>,entry,pending) ++ "|receipts=" ++ List.show(&1,Buffer.Receipt<Schema,P.Token,Removed.Removed(layout())>,receipt,receipts) ++ "|handle=" ++ handle_text(handle) ++ "|cursor=" ++ Tick.cursor_show(cursor) ++ "|peer=" ++ token_value(Array.get(U32,peer,0)) ++ ":" ++ Tick.cursor_show(peerCursor) ++ "|handler=" ++ token_value(Array.get(U32,handler,0)) ++ ":" ++ U32.show(errors) ++ "|unapplied=" ++ List.show(&2,U32,U32.show,unapplied)
def pending_observed(prefix:String,result:Application() & Bool) -> String:
  match result:
    case (application,pending):observed(prefix ++ ";exact-pending=" ++ Bool.pick(String,pending,"true","false"),application)
def selected(native:Bool,app:Application()) -> Application() & DepApp.Report<String,Unit>:
  match native:
    case False{}:Schedule.run_serial(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~Author(),~Peer(),~left,~right,~Unit,~Handler,~Reg.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~Prog.empty(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~handle,app)
    case True{}:Schedule.run_native(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~Author(),~Peer(),~left,~right,~Unit,~Handler,~Reg.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~Prog.empty(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~handle,app)
def exact_pending(app:Application()) -> Application() & Bool:
  Schedule.pending(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~Author(),~Peer(),~left,~right,~Unit,~Handler,~Reg.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~Prog.empty(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~handle,app)
def second(native:Bool,prefix:String,result:Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,done):pending_observed(prefix ++ ";" ++ report(done),exact_pending(app))
def first(+native:Bool,result:Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,done):second(native,report(done),selected(native,app))
type Setup is Type:
  SetupReady{application:Application()}
  SetupFailed{message:String}
def built(settings:Settings.Settings,+native:Bool,world:W.World<Schema,Store(),Resources(),Unit>,author:Author(),peer:Peer()) -> Setup:
  SetupReady{Schedule.configure(~(DepApp.Application<W.World<Schema,Store(),Resources(),Unit>,Product.Owner<Author(),Peer()>,Unit,Handler,String,Unit,Root.dispatch(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~Author(),~Peer(),~left,~right),Reg.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),handle>),settings,Schedule.build(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~Author(),~Peer(),~left,~right,~Unit,~Handler,~Reg.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~Prog.empty(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~handle,~(name => True{}),world,Product.Owner{author,peer},Unit{},Handler{ALeaf{901},0},[],[]))}
def peer_defined(settings:Settings.Settings,native:Bool,author:Author(),result:Sys.Defined<W.World<Schema,Store(),Resources(),Unit>,Peer(),Array<U32>>) -> Setup:
  match result:
    case Sys.Defined{world,peer}:built(settings,native,world,author,peer)
    case Sys.DefinitionRefused{_,_}:SetupFailed{"ERROR: peer definition"}
def author_defined(settings:Settings.Settings,native:Bool,result:Sys.Defined<W.World<Schema,Store(),Resources(),Unit>,Author(),Cmd.Captures(~Schema,~layout(),~path(),~AuthorLocal)>) -> Setup:
  match result:
    case Sys.Defined{world,author}:peer_defined(settings,native,author,Task.define(~Schema,~Store(),~Unit,~Unit,~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_declaration,~peer_body,~Resources(),world,"peer",ALeaf{801}))
    case Sys.DefinitionRefused{_,_}:SetupFailed{"ERROR: author definition"}
def cache_selected(valid:Bool,owner:Author()) -> Author():
  match valid owner:
    case True{} owner:owner
    case False{} Cmd.Owner{Sys.Owner{a,b,c,d,cursor,Local.Local{user,queue,_}}}:Cmd.Owner{Sys.Owner{a,b,c,d,cursor,Local.Local{user,queue,Permission.FamilyOnly{}}}}
def cache_defined(valid:Bool,result:Sys.Defined<W.World<Schema,Store(),Resources(),Unit>,Author(),Cmd.Captures(~Schema,~layout(),~path(),~AuthorLocal)>) -> Sys.Defined<W.World<Schema,Store(),Resources(),Unit>,Author(),Cmd.Captures(~Schema,~layout(),~path(),~AuthorLocal)>:
  match result:
    case Sys.Defined{world,owner}:Sys.Defined{world,cache_selected(valid,owner)}
    case Sys.DefinitionRefused{world,local}:Sys.DefinitionRefused{world,local}
def activated(settings:Settings.Settings,enabled:Bool,native:Bool,handle:W.Handle<Schema>,result:W.World<Schema,Store(),Resources(),Unit> & W.Status) -> Setup:
  match result:
    case (world,W.Accepted{}):author_defined(settings,native,cache_defined(enabled,Cmd.define(~Schema,~Left(),~Unit,~Unit,~layout(),~path(),~{==},~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~Resources(),world,"author",AuthorLocal{P.Capture{handle},True{}})))
    case (_,_):SetupFailed{"ERROR: activation"}
def reserved(settings:Settings.Settings,enabled:Bool,native:Bool,result:W.World<Schema,Store(),Resources(),Unit> & W.Reservation<Schema>) -> Setup:
  match result:
    case (world,W.Reserved{+handle}):activated(settings,enabled,native,handle,W.activate(~Schema,~Store(),~Resources(),~Unit,world,handle))
    case (_,_):SetupFailed{"ERROR: reservation"}
def token_column(result:Column.SwapOutcome<Schema,Layout.Viewed<P.Token,U32>>) -> Column.Column<Schema,Layout.Viewed<P.Token,U32>>:
  match result:
    case Column.Accepted{column,_}:column
    case Column.Rejected{column,_}:column
def other_column(result:Column.SwapOutcome<Schema,Layout.Viewed<Fixture.Other,U32>>) -> Column.Column<Schema,Layout.Viewed<Fixture.Other,U32>>:
  match result:
    case Column.Accepted{column,_}:column
    case Column.Rejected{column,_}:column
def empty(_:Unit) -> Store():
  Product.Owner{Product.Owner{Layout.ColumnSlot{token_column(Column.swap(~Schema,~(Layout.Viewed<P.Token,U32>),Column.empty(~Schema,~(Layout.Viewed<P.Token,U32>)),0,Some{Layout.initialize(Fixture.layout(),Layout.InLeft{Layout.AtLeaf{}},P.Token{ALeaf{71}})}))},Layout.ColumnSlot{other_column(Column.swap(~Schema,~(Layout.Viewed<Fixture.Other,U32>),Column.empty(~Schema,~(Layout.Viewed<Fixture.Other,U32>)),0,Some{Layout.initialize(Fixture.layout(),Layout.InRight{Layout.AtLeaf{}},Fixture.Other{ALeaf{80}})}))}},Unit{}}
def created(settings:Settings.Settings,enabled:Bool,native:Bool,result:W.Creation<Schema,Store(),Resources(),Unit>) -> Setup:
  match result:
    case W.Created{_,world}:reserved(settings,enabled,native,W.reserve_id(~Schema,~Store(),~Resources(),~Unit,world))
    case W.CreateRejected{_,_}:SetupFailed{"ERROR: creation"}
def setup(settings:Settings.Settings,enabled:Bool,native:Bool) -> Setup:
  created(settings,enabled,native,W.create(~Schema,~Store(),~Resources(),~Unit,~empty,W.factory(),Product.Owner{Unit{},Unit{}}))
def setup_run(+native:Bool,result:Setup) -> String:
  match result:
    case SetupReady{app}:first(native,selected(native,app))
    case SetupFailed{message}:message
def run(settings:Settings.Settings,enabled:Bool,+native:Bool) -> String:
  setup_run(native,setup(settings,enabled,native))
def main() -> IO(Unit):
  IO.print("native-final=" ++ run(Settings.defaults(),True{},True{}) ++ "\nnative-retained=" ++ run(Settings.Settings{True{},False{},[],[]},True{},True{}) ++ "\nnative-cache-mismatch=" ++ run(Settings.defaults(),False{},True{}) ++ "\nserial-final=" ++ run(Settings.defaults(),True{},False{}))
