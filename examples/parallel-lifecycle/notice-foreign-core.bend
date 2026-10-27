import Base
import ./notice-scenario-core.bend as Core
import ./notice-readers.bend as Readers
import ./notice-writer.bend as Writer
import ../parallel-query/declarations.bend as D
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-system-lifecycle.bend as Lifecycle
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-registry-program.bend as Prog
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/change-tick.bend as Tick

def S() -> Data:Core.First
def Runtime() -> Type:W.World<S(),Core.Store(~S()),Core.Resources(~S()),Unit>
def Author() -> Type:Core.Author(~S(),~Query.Parallel{})
def Peer() -> Type:Core.Peer(~S())
def Application() -> Type:Core.Application(~S(),~Query.Parallel{})
type Snapshot is Type:
  Snapshot{world:Runtime(),author:Author(),peer:Peer(),handler:Core.Handler,reports:String}
def captured(prefix:String,app:Application()) -> Snapshot:
  match app:
    case Schedule.Scheduled{App.Application{App.State{world,Product.Owner{author,peer},_,handler,_},_,_},_,_}:Snapshot{world,author,peer,handler,prefix}
def completed(remaining:Nat,prefix:String,result:Application() & App.Report<String,String>) -> Snapshot:
  match remaining result:
    case 0n, (app,report):captured(prefix ++ Core.report(~S(),report),app)
    case 1n+rest, (app,report):completed(rest,prefix ++ Core.report(~S(),report) ++ ";",Core.selected(~S(),~Query.Parallel{},True{},app))
def identity(value:Lifecycle.Identity) -> String:
  match value:
    case Lifecycle.Identity{namespace,id,name,access,cursor}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ Tick.cursor_show(cursor)
def handler(value:Core.Handler) -> String:
  match value:
    case Core.Handler{token,errors}:Core.token_value(~S(),Array.get(U32,token,0)) ++ ":" ++ U32.show(errors)
def author(value:Author()) -> String:
  match value:
    case Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{Writer.User{token,runs,handles},Buffer.Buffer{pending,receipts},_}}}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ Tick.cursor_show(cursor) ++ ";user=" ++ Core.token_value(~S(),Array.get(U32,token,0)) ++ ":" ++ U32.show(runs) ++ ";handles=" ++ List.show(&2,W.Handle<S()>,Core.handle_text(~S()),handles) ++ ";pending=" ++ List.show(&2,Core.Record,Core.record_text(~S()),Core.entries(~S(),pending)) ++ ";receipts=" ++ List.show(&2,Core.Record,Core.record_text(~S()),Core.receipt_records(~S(),receipts))
type RetainedA is Type:
  RetainedA{world:Runtime(),author:Author(),handler:Core.Handler,reports:String,identity:Lifecycle.Identity}
type RetainedB is Type:
  RetainedB{identity:Lifecycle.Identity,local:Readers.Captures<S()>,reports:String}
def observed(left:RetainedA,old:RetainedB,result:Application() & App.Report<String,String>) -> String:
  match left old result:
    case RetainedA{world,writer,errors,reports,retired} RetainedB{oldIdentity,oldLocal,oldReport}, (app,report):"A={world=" ++ Core.notice_world(~S(),world) ++ ";author=" ++ author(writer) ++ ";handler=" ++ handler(errors) ++ ";reports=" ++ reports ++ ";retired=" ++ identity(retired) ++ "};B-retired={identity=" ++ identity(oldIdentity) ++ ";local=" ++ Readers.observed(~S(),oldLocal) ++ ";reports=" ++ oldReport ++ "};B-rebound={" ++ Core.observed(~S(),~Query.Parallel{},Core.report(~S(),report),app) ++ "}"
def rebound(left:RetainedA,old:RetainedB,writer:Author(),errors:Core.Handler,result:Sys.Defined<Runtime(),Peer(),Readers.Captures<S()>>) -> String:
  match result:
    case Sys.Defined{world,reader}:observed(left,old,Core.selected(~S(),~Query.Parallel{},True{},Schedule.build(~S(),~Core.Left(~S()),~Unit,~D.Resources(~S()),~Unit,~Unit,~String,~String,~Author(),~Peer(),~Core.left(~S(),~Query.Parallel{}),~Core.right(~S()),~Unit,~Core.Handler,~Reg.empty_dispatch(~Runtime(),~String,~Bool),~Prog.empty(~Runtime(),~String,~Bool),~Core.handle(~S()),~(name => True{}),world,Product.Owner{writer,reader},Unit{},errors,[Plan.Edge{1,3}],[])))
    case Sys.DefinitionRefused{_,_}:"ERROR: B fresh registration"
def b_released(left:RetainedA,local:Readers.Captures<S()>,world:Runtime(),writer:Author(),errors:Core.Handler,reports:String,released:Lifecycle.Released<Readers.Captures<S()>>) -> String:
  match released:
    case Lifecycle.Released{retired,old}:rebound(left,RetainedB{retired,old,reports},writer,errors,Task.define(~S(),~Core.Store(~S()),~Unit,~Unit,~Unit,~Core.PeerOps(~S()),~Readers.Captures<S()>,~String,~String,~Core.peer_declaration(~S()),~Core.peer_body(~S()),~Core.Resources(~S()),world,"foreign-reader",local))
def b_retired(left:RetainedA,local:Readers.Captures<S()>,writer:Author(),errors:Core.Handler,reports:String,result:Lifecycle.Retirement<Runtime(),Peer()>) -> String:
  match result:
    case Lifecycle.Retired{world,detached}:b_released(left,local,world,writer,errors,reports,Lifecycle.release(~S(),~Core.Store(~S()),~Unit,~Unit,~Unit,~Core.PeerOps(~S()),~Readers.Captures<S()>,~String,~String,~Core.peer_declaration(~S()),~Core.peer_body(~S()),detached))
    case Lifecycle.RetirementRefused{_,_}:"ERROR: B retire"
def a_released(world:Runtime(),writer:Author(),errors:Core.Handler,reports:String,right:Snapshot,released:Lifecycle.Released<Readers.Captures<S()>>) -> String:
  match right released:
    case Snapshot{other,otherWriter,otherPeer,otherErrors,otherReport} Lifecycle.Released{retired,local}:b_retired(RetainedA{world,writer,errors,reports,retired},local,otherWriter,otherErrors,otherReport,Lifecycle.retire(~S(),~Core.Store(~S()),~Unit,~Unit,~Unit,~Core.PeerOps(~S()),~Readers.Captures<S()>,~String,~String,~Core.peer_declaration(~S()),~Core.peer_body(~S()),~Core.Resources(~S()),~Unit,otherPeer,other))
def a_retired(writer:Author(),errors:Core.Handler,reports:String,right:Snapshot,result:Lifecycle.Retirement<Runtime(),Peer()>) -> String:
  match result:
    case Lifecycle.Retired{world,detached}:a_released(world,writer,errors,reports,right,Lifecycle.release(~S(),~Core.Store(~S()),~Unit,~Unit,~Unit,~Core.PeerOps(~S()),~Readers.Captures<S()>,~String,~String,~Core.peer_declaration(~S()),~Core.peer_body(~S()),detached))
    case Lifecycle.RetirementRefused{_,_}:"ERROR: A retire"
def transfer(left:Snapshot,right:Snapshot) -> String:
  match left:
    case Snapshot{world,writer,peer,errors,reports}:a_retired(writer,errors,reports,right,Lifecycle.retire(~S(),~Core.Store(~S()),~Unit,~Unit,~Unit,~Core.PeerOps(~S()),~Readers.Captures<S()>,~String,~String,~Core.peer_declaration(~S()),~Core.peer_body(~S()),~Core.Resources(~S()),~Unit,peer,world))
def run(left:Core.Setup<S(),Query.Parallel{}>,right:Core.Setup<S(),Query.Parallel{}>) -> String:
  match left right:
    case Core.Ready{first} Core.Ready{second}:transfer(completed(1n,"",Core.selected(~S(),~Query.Parallel{},True{},first)),completed(0n,"",Core.selected(~S(),~Query.Parallel{},True{},second)))
    case _ _:"ERROR: setup"
