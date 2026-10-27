import Base
import ../../src/ecs/execution-lifetime-scope-description.bend as LinkedText
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-removed.bend as Removed
import ./controls/positive.bend as P
import ./controls/registered.bend as Registered
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/dependency-plan.bend as Plan
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
def layout() -> Layout.Layout:Layout.LayoutPair{Registered.layout(),Layout.EmptyLayout{}}
def path() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def Left() -> Type:Layout.columns(~Schema,Registered.layout())
def Store() -> Type:Layout.columns(~Schema,layout())
def Resources() -> Type:Product.Owner<Unit,Unit>
def Ops(H:Type) -> Type:Unit
def CmdOps(H:Type,Q:Type) -> Type:Unit
def author_declaration(~H:Type,~Q:Type,~commands:Local.Commands<Q,Schema,P.Token>,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Left(),~Unit,~H,~B),~K:Type,~entity:Permission.Grant(~Schema,~layout(),~Q,~K),book:B,permission:K) -> B & (K & Unit):
  (book,(permission,Unit{}))
def peer_declaration(~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Unit,~Unit,~H,~B),book:B) -> B & Unit:
  (book,Unit{})
def peer_body(~H:Type,~caps:Unit,scope:H,token:Array<U32>) -> H & (Array<U32> & Sys.Completion<String,Unit>):
  (scope,(token,Sys.Success{Unit{}}))
type AuthorLocal is Type:
  AuthorLocal{capture:P.Capture<Schema>,enabled:Bool}
def author_returned(~H:Type,~Q:Type,enabled:Bool,result:H & (Q & (P.Capture<Schema> & Sys.Completion<String,Unit>))) -> H & (Q & (AuthorLocal & Sys.Completion<String,Unit>)):
  match result:
    case (scope,(queue,(capture,done))):(scope,(queue,(AuthorLocal{capture,enabled},done)))
def author_body(~H:Type,~Q:Type,~caps:Unit,~commands:Local.Commands<Q,Schema,P.Token>,scope:H,queue:Q,local:AuthorLocal) -> H & (Q & (AuthorLocal & Sys.Completion<String,Unit>)):
  match local:
    case AuthorLocal{P.Capture{+handle},True{}}:author_returned(~H,~Q,True{},P.body(~Schema,~H,~Q,~caps,~commands,scope,Local.remove_field(~Q,~Schema,~P.Token,commands)(queue,handle),P.Capture{handle}))
    case AuthorLocal{capture,False{}}:(scope,(queue,(AuthorLocal{capture,False{}},Sys.Success{Unit{}})))
def Author() -> Type:Cmd.Owner<Schema,Left(),Unit,Unit,layout(),path(),CmdOps,AuthorLocal,String,Unit,author_declaration,author_body>
def Peer() -> Type:Sys.Owner<Schema,Store(),Unit,Unit,Unit,Ops,Array<U32>,String,Unit,peer_declaration,peer_body>
def ReadOps(H:Type) -> Type:A.ComponentRead<Schema,H,U32>
def reader_selection(~H:Type,~B:Type,~read:Build.ComponentRead(~Schema,~Left(),~Unit,~H,~B),~write:Build.ComponentWrite(~Schema,~Left(),~Unit,~H,~B),~rread:Build.ResourceRead(~Schema,~Left(),~Unit,~H,~B),~rwrite:Build.ResourceWrite(~Schema,~Left(),~Unit,~H,~B),~query:Build.Query(~Schema,~Store(),~Left(),~Unit,~H,~B),~lifecycle:Build.Lifecycle(~Schema,~Store(),~Left(),~Unit,~H,~B),book:B) -> B & ReadOps(H):
  read(Registered.layout(),Layout.AtLeaf{},{==},{==},book)
def reader_declaration(~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Left(),~Unit,~H,~B),book:B) -> B & ReadOps(H):
  builder(ReadOps,reader_selection(~H,~B),book)
def guard_selection(~H:Type,~B:Type,~read:Build.ComponentRead(~Schema,~Store(),~Resources(),~H,~B),~write:Build.ComponentWrite(~Schema,~Store(),~Resources(),~H,~B),~rread:Build.ResourceRead(~Schema,~Store(),~Resources(),~H,~B),~rwrite:Build.ResourceWrite(~Schema,~Store(),~Resources(),~H,~B),~query:Build.Query(~Schema,~Store(),~Store(),~Resources(),~H,~B),~lifecycle:Build.Lifecycle(~Schema,~Store(),~Store(),~Resources(),~H,~B),book:B) -> B & ReadOps(H):
  read(layout(),path(),{==},{==},book)
def guard_declaration(~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Store(),~Resources(),~H,~B),book:B) -> B & ReadOps(H):
  builder(ReadOps,guard_selection(~H,~B),book)
type Seen is Type:
  Seen{token:Array<U32>,runs:U32,handle:W.Handle<Schema>,last:Maybe<&2,U32>}
def ready_value(value:Maybe<&2,U32>) -> Bool:
  match value:
    case None{}:False{}
    case Some{value}:U32.is_eq(value,71)
def reader_returned(~H:Type,token:Array<U32>,runs:U32,handle:W.Handle<Schema>,result:H & Maybe<&2,U32>) -> H & (Seen & Sys.Completion<String,Unit>):
  match result:
    case (scope,value):(scope,(Seen{token,U32.add(runs,1),handle,value},Sys.Success{Unit{}}))
def reader_body(~H:Type,~caps:ReadOps(H),scope:H,local:Seen) -> H & (Seen & Sys.Completion<String,Unit>):
  match local:
    case Seen{token,runs,+handle,_}:reader_returned(~H,token,runs,handle,A.component_read_field(~Schema,~H,~U32,caps)(scope,handle))
def guard_returned(~H:Type,token:Array<U32>,runs:U32,handle:W.Handle<Schema>,result:H & Maybe<&2,U32>) -> H & (Seen & Sys.Completion<String,Bool>):
  match result:
    case (scope,+value):(scope,(Seen{token,U32.add(runs,1),handle,value},Sys.Success{ready_value(value)}))
def guard_body(~H:Type,~caps:ReadOps(H),scope:H,local:Seen) -> H & (Seen & Sys.Completion<String,Bool>):
  match local:
    case Seen{token,runs,+handle,_}:guard_returned(~H,token,runs,handle,A.component_read_field(~Schema,~H,~U32,caps)(scope,handle))
def Reader() -> Type:Sys.Owner<Schema,Store(),Left(),Unit,Unit,ReadOps,Seen,String,Unit,reader_declaration,reader_body>
def Guard() -> Type:Sys.Owner<Schema,Store(),Store(),Resources(),Unit,ReadOps,Seen,String,Bool,guard_declaration,guard_body>
def LeftTree() -> Type:Product.Owner<Author(),Reader()>
def left(~F:Tree.Family(),~leaf:Tree.Leaf(~Schema,~Store(),~Left(),~Unit,~Unit,~String,~Unit,~F),~command:Tree.CommandLeaf(~Schema,~Store(),~Left(),~Unit,~Unit,~String,~Unit,~F),~join:Tree.Join(~F),owners:LeftTree()) -> F(LeftTree()):
  match owners:
    case Product.Owner{author,reader}:join(Author(),Reader(),command(layout(),path(),{==},{==},CmdOps,AuthorLocal,author_declaration,author_body,author),leaf(ReadOps,Seen,reader_declaration,reader_body,reader))
def right(~F:Tree.Family(),~leaf:Tree.Leaf(~Schema,~Store(),~Unit,~Unit,~Unit,~String,~Unit,~F),~command:Tree.CommandLeaf(~Schema,~Store(),~Unit,~Unit,~Unit,~String,~Unit,~F),~join:Tree.Join(~F),owner:Peer()) -> F(Peer()):
  leaf(Ops,Array<U32>,peer_declaration,peer_body,owner)
type Handler is Type:
  Handler{token:Array<U32>,errors:U32}
def handle(handler:Handler,error:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def Application() -> Type:Schedule.Scheduled<DepApp.Application<W.World<Schema,Store(),Resources(),Unit>,Product.Owner<LeftTree(),Peer()>,Guard(),Handler,String,Unit,Root.dispatch(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~LeftTree(),~Peer(),~left,~right),Reg.leaf_dispatch(~Schema,~Store(),~Resources(),~Unit,~ReadOps,~Seen,~String,~Bool,~guard_declaration,~guard_body),handle>>
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
    case Buffer.Despawned{handle,Product.Owner{removed,_}}:"despawned:" ++ handle_text(handle) ++ ":" ++ maybe_token(removed)
    case Buffer.DespawnRefused{handle}:"despawn-refused:" ++ handle_text(handle)
    case Buffer.LinkedDespawn{handle,status,_,_}:"linked-despawn:" ++ handle_text(handle) ++ ":" ++ LinkedText.linked_status(status)
def viewed_result(+cache:U32,result:Array<U32> & U32) -> Layout.Viewed<P.Token,U32> & String:
  match result:
    case (owner,+value):(Layout.Viewed{P.Token{owner},cache},U32.show(value) ++ "/cache=" ++ U32.show(cache))
def viewed(value:Layout.Viewed<P.Token,U32>) -> Layout.Viewed<P.Token,U32> & String:
  match value:
    case Layout.Viewed{P.Token{owner},cache}:viewed_result(cache,Array.get(U32,owner,0))
def world(world:W.World<Schema,Store(),Resources(),Unit>) -> String:
  match world:
    case W.World{namespace,allocator,Product.Owner{Layout.ColumnSlot{column},_},_,events,pending,registrations,next,clock,lifecycle}:"namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ Observe.allocator(allocator) ++ "};column=" ++ Observe.capacity_done(~Schema,~Layout.Viewed<P.Token,U32>,~viewed,Column.capacity(~Schema,~Layout.Viewed<P.Token,U32>,column)) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";legacy-pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<Schema,Store(),Resources(),Unit>>,pending)) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Observe.registration,registrations) ++ ";next=" ++ U32.show(next) ++ ";clock=" ++ Observe.clock(clock)
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
def seen_value(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"never"
    case Some{value}:U32.show(value)
def seen(value:Seen) -> String:
  match value:
    case Seen{token,runs,handle,last}:token_value(Array.get(U32,token,0)) ++ ":" ++ U32.show(runs) ++ ":" ++ handle_text(handle) ++ ":" ++ seen_value(last)
def observed(prefix:String,application:Application()) -> String:
  match application:
    case Schedule.Scheduled{DepApp.Application{DepApp.State{owner,Product.Owner{Product.Owner{Cmd.Owner{Sys.Owner{_,_,_,_,cursor,Local.Local{AuthorLocal{P.Capture{handle},_},Buffer.Buffer{pending,receipts},_}}},Sys.Owner{_,_,_,_,readerCursor,reader}},Sys.Owner{_,_,_,_,peerCursor,peer}},Sys.Owner{_,_,_,_,guardCursor,guard},Handler{handler,errors},_},_,_},_,Schedule.Deferred{_,_,unapplied}}:prefix ++ "|world=" ++ world(owner) ++ "|queue=" ++ List.show(&1,Buffer.Entry<Schema,P.Token>,entry,pending) ++ "|receipts=" ++ List.show(&1,Buffer.Receipt<Schema,P.Token,Removed.Removed(layout())>,receipt,receipts) ++ "|handle=" ++ handle_text(handle) ++ "|cursor=" ++ Tick.cursor_show(cursor) ++ "|reader=" ++ seen(reader) ++ ":" ++ Tick.cursor_show(readerCursor) ++ "|guard=" ++ seen(guard) ++ ":" ++ Tick.cursor_show(guardCursor) ++ "|peer=" ++ token_value(Array.get(U32,peer,0)) ++ ":" ++ Tick.cursor_show(peerCursor) ++ "|handler=" ++ token_value(Array.get(U32,handler,0)) ++ ":" ++ U32.show(errors) ++ "|unapplied=" ++ List.show(&2,U32,U32.show,unapplied)
def pending_observed(prefix:String,result:Application() & Bool) -> String:
  match result:
    case (application,pending):observed(prefix ++ ";exact-pending=" ++ Bool.pick(String,pending,"true","false"),application)
def selected(native:Bool,app:Application()) -> Application() & DepApp.Report<String,Unit>:
  match native:
    case False{}:Schedule.run_serial(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~LeftTree(),~Peer(),~left,~right,~Guard(),~Handler,~Reg.leaf_dispatch(~Schema,~Store(),~Resources(),~Unit,~ReadOps,~Seen,~String,~Bool,~guard_declaration,~guard_body),~Prog.leaf(~Schema,~Store(),~Resources(),~Unit,~ReadOps,~Seen,~String,~Bool,~guard_declaration,~guard_body),~handle,app)
    case True{}:Schedule.run_native(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~LeftTree(),~Peer(),~left,~right,~Guard(),~Handler,~Reg.leaf_dispatch(~Schema,~Store(),~Resources(),~Unit,~ReadOps,~Seen,~String,~Bool,~guard_declaration,~guard_body),~Prog.leaf(~Schema,~Store(),~Resources(),~Unit,~ReadOps,~Seen,~String,~Bool,~guard_declaration,~guard_body),~handle,app)
def exact_pending(app:Application()) -> Application() & Bool:
  Schedule.pending(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~LeftTree(),~Peer(),~left,~right,~Guard(),~Handler,~Reg.leaf_dispatch(~Schema,~Store(),~Resources(),~Unit,~ReadOps,~Seen,~String,~Bool,~guard_declaration,~guard_body),~Prog.leaf(~Schema,~Store(),~Resources(),~Unit,~ReadOps,~Seen,~String,~Bool,~guard_declaration,~guard_body),~handle,app)
def second(native:Bool,prefix:String,result:Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,done):pending_observed(prefix ++ ";" ++ report(done),exact_pending(app))
def first(+native:Bool,result:Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,done):second(native,report(done),selected(native,app))
type Setup is Type:
  SetupReady{application:Application()}
  SetupFailed{message:String}
def built(settings:Settings.Settings,+native:Bool,world:W.World<Schema,Store(),Resources(),Unit>,author:Author(),reader:Reader(),peer:Peer(),guard:Guard()) -> Setup:
  SetupReady{Schedule.configure(~(DepApp.Application<W.World<Schema,Store(),Resources(),Unit>,Product.Owner<LeftTree(),Peer()>,Guard(),Handler,String,Unit,Root.dispatch(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~LeftTree(),~Peer(),~left,~right),Reg.leaf_dispatch(~Schema,~Store(),~Resources(),~Unit,~ReadOps,~Seen,~String,~Bool,~guard_declaration,~guard_body),handle>),settings,Schedule.build(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~LeftTree(),~Peer(),~left,~right,~Guard(),~Handler,~Reg.leaf_dispatch(~Schema,~Store(),~Resources(),~Unit,~ReadOps,~Seen,~String,~Bool,~guard_declaration,~guard_body),~Prog.leaf(~Schema,~Store(),~Resources(),~Unit,~ReadOps,~Seen,~String,~Bool,~guard_declaration,~guard_body),~handle,~(name => True{}),world,Product.Owner{Product.Owner{author,reader},peer},guard,Handler{ALeaf{901},0},[Plan.Edge{1,2}],[DepApp.Binding{2,4}]))}
def guard_defined(settings:Settings.Settings,native:Bool,author:Author(),reader:Reader(),peer:Peer(),result:Sys.Defined<W.World<Schema,Store(),Resources(),Unit>,Guard(),Seen>) -> Setup:
  match result:
    case Sys.Defined{world,guard}:built(settings,native,world,author,reader,peer,guard)
    case Sys.DefinitionRefused{_,_}:SetupFailed{"ERROR: guard definition"}
def peer_defined(settings:Settings.Settings,native:Bool,handle:W.Handle<Schema>,author:Author(),reader:Reader(),result:Sys.Defined<W.World<Schema,Store(),Resources(),Unit>,Peer(),Array<U32>>) -> Setup:
  match result:
    case Sys.Defined{world,peer}:guard_defined(settings,native,author,reader,peer,Sys.define(~Schema,~Store(),~Resources(),~Unit,~ReadOps,~Seen,~String,~Bool,~guard_declaration,~guard_body,world,"guard",Seen{ALeaf{601},0,handle,None{}}))
    case Sys.DefinitionRefused{_,_}:SetupFailed{"ERROR: peer definition"}
def reader_defined(settings:Settings.Settings,native:Bool,handle:W.Handle<Schema>,author:Author(),result:Sys.Defined<W.World<Schema,Store(),Resources(),Unit>,Reader(),Seen>) -> Setup:
  match result:
    case Sys.Defined{world,reader}:peer_defined(settings,native,handle,author,reader,Task.define(~Schema,~Store(),~Unit,~Unit,~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_declaration,~peer_body,~Resources(),world,"peer",ALeaf{801}))
    case Sys.DefinitionRefused{_,_}:SetupFailed{"ERROR: reader definition"}
def author_defined(settings:Settings.Settings,native:Bool,+handle:W.Handle<Schema>,result:Sys.Defined<W.World<Schema,Store(),Resources(),Unit>,Author(),Cmd.Captures(~Schema,~layout(),~path(),~AuthorLocal)>) -> Setup:
  match result:
    case Sys.Defined{world,author}:reader_defined(settings,native,handle,author,Task.define(~Schema,~Store(),~Left(),~Unit,~Unit,~ReadOps,~Seen,~String,~Unit,~reader_declaration,~reader_body,~Resources(),world,"reader",Seen{ALeaf{501},0,handle,None{}}))
    case Sys.DefinitionRefused{_,_}:SetupFailed{"ERROR: author definition"}
def activated(settings:Settings.Settings,enabled:Bool,native:Bool,+handle:W.Handle<Schema>,result:W.World<Schema,Store(),Resources(),Unit> & W.Status) -> Setup:
  match result:
    case (world,W.Accepted{}):author_defined(settings,native,handle,Cmd.define(~Schema,~Left(),~Unit,~Unit,~layout(),~path(),~{==},~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~Resources(),world,"author",AuthorLocal{P.Capture{handle},enabled}))
    case (_,_):SetupFailed{"ERROR: activation"}
def reserved(settings:Settings.Settings,enabled:Bool,native:Bool,result:W.World<Schema,Store(),Resources(),Unit> & W.Reservation<Schema>) -> Setup:
  match result:
    case (world,W.Reserved{+handle}):activated(settings,enabled,native,handle,W.activate(~Schema,~Store(),~Resources(),~Unit,world,handle))
    case (_,_):SetupFailed{"ERROR: reservation"}
def column(result:Column.SwapOutcome<Schema,Layout.Viewed<P.Token,U32>>) -> Column.Column<Schema,Layout.Viewed<P.Token,U32>>:
  match result:
    case Column.Accepted{column,_}:column
    case Column.Rejected{column,_}:column
def empty(_:Unit) -> Store():
  Product.Owner{Layout.ColumnSlot{column(Column.swap(~Schema,~Layout.Viewed<P.Token,U32>,Column.empty(~Schema,~Layout.Viewed<P.Token,U32>),0,Some{Layout.Viewed{P.Token{ALeaf{1}},1}}))},Unit{}}
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
  IO.print("native-auto=" ++ run(Settings.defaults(),True{},True{}) ++ "\nnative-ignored=" ++ run(Settings.Settings{True{},True{},[Plan.Edge{1,2}],[]},True{},True{}) ++ "\nnative-explicit=" ++ run(Settings.Settings{False{},True{},[Plan.Edge{1,2}],[Settings.Explicit{2,None{}}]},True{},True{}) ++ "\nnative-disabled=" ++ run(Settings.Settings{False{},True{},[],[]},True{},True{}) ++ "\nnative-finaloff=" ++ run(Settings.Settings{True{},False{},[Plan.Edge{1,2}],[]},True{},True{}) ++ "\nserial-auto=" ++ run(Settings.defaults(),True{},False{}))
