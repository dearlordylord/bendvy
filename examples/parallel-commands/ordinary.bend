import Base
import ./controls/positive.bend as P
import ./controls/registered.bend as Registered
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
def layout() -> Layout.Layout:Layout.LayoutPair{Registered.layout(),Layout.EmptyLayout{}}
def path() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def Left() -> Type:Layout.columns(~Schema,Registered.layout())
def Store() -> Type:Layout.columns(~Schema,layout())
def Resources() -> Type:Product.Owner<Unit,Unit>
def Ops(H:Type) -> Type:Unit
def author_declaration(~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Left(),~Unit,~H,~B),book:B) -> B & Unit:
  (book,Unit{})
def peer_declaration(~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Unit,~Unit,~H,~B),book:B) -> B & Unit:
  (book,Unit{})
def peer_body(~H:Type,~caps:Unit,scope:H,token:Array<U32>) -> H & (Array<U32> & Sys.Completion<String,Unit>):
  (scope,(token,Sys.Success{Unit{}}))
def Author() -> Type:Cmd.Owner<Schema,Left(),Unit,Unit,layout(),path(),Ops,P.Capture<Schema>,String,Unit,author_declaration,P.body(~Schema)>
def Peer() -> Type:Sys.Owner<Schema,Unit,Unit,Unit,Ops,Array<U32>,String,Unit,peer_declaration,peer_body>
def left(~F:Tree.Family(),~leaf:Tree.Leaf(~Schema,~Store(),~Left(),~Unit,~Unit,~String,~Unit,~F),~command:Tree.CommandLeaf(~Schema,~Store(),~Left(),~Unit,~Unit,~String,~Unit,~F),~join:Tree.Join(~F),owner:Author()) -> F(Author()):
  command(layout(),path(),{==},{==},Ops,P.Capture<Schema>,author_declaration,P.body(~Schema),owner)
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
def receipt(value:Buffer.Receipt<Schema,P.Token>) -> String:
  match value:
    case Buffer.Applied{handle,previous}:"applied:" ++ handle_text(handle) ++ ":" ++ maybe_token(previous)
    case Buffer.Refused{handle,incoming}:"refused:" ++ handle_text(handle) ++ ":" ++ maybe_token(incoming)
def viewed_result(+cache:U32,result:Array<U32> & U32) -> Layout.Viewed<P.Token,U32> & String:
  match result:
    case (owner,+value):(Layout.Viewed{P.Token{owner},cache},U32.show(value) ++ "/cache=" ++ U32.show(cache))
def viewed(value:Layout.Viewed<P.Token,U32>) -> Layout.Viewed<P.Token,U32> & String:
  match value:
    case Layout.Viewed{P.Token{owner},cache}:viewed_result(cache,Array.get(U32,owner,0))
def world(world:W.World<Schema,Store(),Resources(),Unit>) -> String:
  match world:
    case W.World{namespace,allocator,Product.Owner{Layout.ColumnSlot{column},_},_,events,pending,registrations,next,clock}:"namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ Observe.allocator(allocator) ++ "};column=" ++ Observe.capacity_done(~Schema,~Layout.Viewed<P.Token,U32>,~viewed,Column.capacity(~Schema,~Layout.Viewed<P.Token,U32>,column)) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";legacy-pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<Schema,Store(),Resources(),Unit>>,pending)) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Observe.registration,registrations) ++ ";next=" ++ U32.show(next) ++ ";clock=" ++ Observe.clock(clock)
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
    case Schedule.Scheduled{DepApp.Application{DepApp.State{owner,Product.Owner{Cmd.Owner{Sys.Owner{_,_,_,_,cursor,Local.Local{P.Capture{handle},Buffer.Buffer{pending,receipts}}}},Sys.Owner{_,_,_,_,peerCursor,peer}},_,Handler{handler,errors},_},_,_},_,Schedule.Deferred{_,_,unapplied}}:prefix ++ "|world=" ++ world(owner) ++ "|queue=" ++ List.show(&1,Buffer.Entry<Schema,P.Token>,entry,pending) ++ "|receipts=" ++ List.show(&1,Buffer.Receipt<Schema,P.Token>,receipt,receipts) ++ "|handle=" ++ handle_text(handle) ++ "|cursor=" ++ Tick.cursor_show(cursor) ++ "|peer=" ++ token_value(Array.get(U32,peer,0)) ++ ":" ++ Tick.cursor_show(peerCursor) ++ "|handler=" ++ token_value(Array.get(U32,handler,0)) ++ ":" ++ U32.show(errors) ++ "|unapplied=" ++ List.show(&2,U32,U32.show,unapplied)
def second(prefix:String,result:Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,done):observed(prefix ++ ";" ++ report(done),app)
def first(result:Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,done):second(report(done),Schedule.run_serial(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~Author(),~Peer(),~left,~right,~Unit,~Handler,~Reg.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~Prog.empty(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~handle,app))
def built(settings:Settings.Settings,world:W.World<Schema,Store(),Resources(),Unit>,author:Author(),peer:Peer()) -> String:
  first(Schedule.run_serial(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~Author(),~Peer(),~left,~right,~Unit,~Handler,~Reg.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~Prog.empty(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~handle,Schedule.configure(~(DepApp.Application<W.World<Schema,Store(),Resources(),Unit>,Product.Owner<Author(),Peer()>,Unit,Handler,String,Unit,Root.dispatch(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~Author(),~Peer(),~left,~right),Reg.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),handle>),settings,Schedule.build(~Schema,~Left(),~Unit,~Unit,~Unit,~Unit,~String,~Unit,~Author(),~Peer(),~left,~right,~Unit,~Handler,~Reg.empty_dispatch(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~Prog.empty(~W.World<Schema,Store(),Resources(),Unit>,~String,~Bool),~handle,~(name => True{}),world,Product.Owner{author,peer},Unit{},Handler{ALeaf{901},0},[],[]))))
def peer_defined(settings:Settings.Settings,author:Author(),result:Sys.Defined<W.World<Schema,Store(),Resources(),Unit>,Peer(),Array<U32>>) -> String:
  match result:
    case Sys.Defined{world,peer}:built(settings,world,author,peer)
    case Sys.DefinitionRefused{_,_}:"ERROR: peer definition"
def author_defined(settings:Settings.Settings,result:Sys.Defined<W.World<Schema,Store(),Resources(),Unit>,Author(),Cmd.Captures(~Schema,~layout(),~path(),~P.Capture<Schema>)>) -> String:
  match result:
    case Sys.Defined{world,author}:peer_defined(settings,author,Task.define(~Schema,~Unit,~Unit,~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_declaration,~peer_body,~Store(),~Resources(),world,"peer",ALeaf{801}))
    case Sys.DefinitionRefused{_,_}:"ERROR: author definition"
def activated(settings:Settings.Settings,handle:W.Handle<Schema>,result:W.World<Schema,Store(),Resources(),Unit> & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):author_defined(settings,Cmd.define(~Schema,~Left(),~Unit,~Unit,~layout(),~path(),~{==},~Ops,~P.Capture<Schema>,~String,~Unit,~author_declaration,~P.body(~Schema),~Resources(),world,"author",P.Capture{handle}))
    case (_,_):"ERROR: activation"
def reserved(settings:Settings.Settings,result:W.World<Schema,Store(),Resources(),Unit> & W.Reservation<Schema>) -> String:
  match result:
    case (world,W.Reserved{+handle}):activated(settings,handle,W.activate(~Schema,~Store(),~Resources(),~Unit,world,handle))
    case (_,_):"ERROR: reservation"
def column(result:Column.SwapOutcome<Schema,Layout.Viewed<P.Token,U32>>) -> Column.Column<Schema,Layout.Viewed<P.Token,U32>>:
  match result:
    case Column.Accepted{column,_}:column
    case Column.Rejected{column,_}:column
def empty(_:Unit) -> Store():
  Product.Owner{Layout.ColumnSlot{column(Column.swap(~Schema,~Layout.Viewed<P.Token,U32>,Column.empty(~Schema,~Layout.Viewed<P.Token,U32>),1,Some{Layout.Viewed{P.Token{ALeaf{1}},1}}))},Unit{}}
def created(settings:Settings.Settings,result:W.Creation<Schema,Store(),Resources(),Unit>) -> String:
  match result:
    case W.Created{_,world}:reserved(settings,W.reserve_id(~Schema,~Store(),~Resources(),~Unit,world))
    case W.CreateRejected{_,_}:"ERROR: creation"
def run(settings:Settings.Settings) -> String:
  created(settings,W.create(~Schema,~Store(),~Resources(),~Unit,~empty,W.factory(),Product.Owner{Unit{},Unit{}}))
def main() -> IO(Unit):
  IO.print("final=" ++ run(Settings.defaults()) ++ "\nretained=" ++ run(Settings.Settings{True{},False{},[],[]}))
