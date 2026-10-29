import Base
import ./despawn.bend as D
import ./controls/positive.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-lifecycle.bend as Life
import ../../src/ecs/execution-system-lifecycle.bend as SystemLife
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/execution-condition-registry.bend as Reg
import ../../src/ecs/execution-condition-registry.bend as Prog
import ../../src/ecs/owner-product.bend as Product
import ../../test-fixtures/common/column-observation.bend as Observe

def World() -> Type:W.World<D.Schema,D.Store(),D.Resources(),Unit>
type Held is Type:Held{peer:D.Peer(),handler:D.Handler}
type Mode is Data:
  RestoreMode{}
  RebindMode{}
  ExhaustedMode{}
def metadata(world:World()) -> World() & String:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,+registrations,+next,+clock,lifecycle}:(W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock,lifecycle},"registrations=" ++ List.show(&2,W.RegistrationMeta,Observe.registration,registrations) ++ ";next=" ++ U32.show(next) ++ ";clock=" ++ Observe.clock(clock))
def exhausted(world:World()) -> World():
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,_,clock,lifecycle}:W.World{namespace,allocator,store,resource,events,pending,registrations,4294967295,clock,lifecycle}
def owner_metadata(owner:D.Author()) -> D.Author() & String:
  match owner:
    case Cmd.Owner{Sys.Owner{a,+id,c,d,+cursor,Local.Local{user,queue,+permission}}}:(Cmd.Owner{Sys.Owner{a,id,c,d,cursor,Local.Local{user,queue,permission}}},"owner=" ++ U32.show(id) ++ ":" ++ Tick.cursor_show(cursor) ++ ":" ++ D.permission_text(permission))
def quiet_author(author:D.Author()) -> D.Author():
  match author:
    case Cmd.Owner{Sys.Owner{a,b,c,d,cursor,Local.Local{D.AuthorLocal{capture,_},queue,permission}}}:Cmd.Owner{Sys.Owner{a,b,c,d,cursor,Local.Local{D.AuthorLocal{capture,False{}},queue,permission}}}
def quiet(app:D.Application()) -> D.Application():
  match app:
    case Schedule.Scheduled{DepApp.State{world,Product.Owner{author,peer},guards,handler,stateBindings},plan,bindings,rules,deferred}:Schedule.Scheduled{DepApp.State{world,Product.Owner{quiet_author(author),peer},guards,handler,stateBindings},plan,bindings,rules,deferred}
def finished(prefix:String,result:D.Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,report):D.pending_observed(prefix ++ ";final=" ++ D.report(report),D.exact_pending(app))
def rebuilt(prefix:String,result:D.Application() & Bool) -> IO(String):
  match result:
    case (Schedule.Scheduled{state,plan,bindings,rules,Schedule.Deferred{systems,settings,+history}},pending):IO.bind(D.Application() & DepApp.Report<String,Unit>,String,D.selected(True{},quiet(Schedule.Scheduled{state,plan,bindings,rules,Schedule.Deferred{systems,settings,history}})),result => IO.pure(String,finished(prefix ++ ";rebuilt-pending=" ++ Bool.pick(String,pending,"true","false") ++ ";rebuilt-history=" ++ List.show(&2,U32,U32.show,history),result)))
def ready(prefix:String,world:World(),author:D.Author(),held:Held) -> IO(String):
  match held:
    case Held{peer,handler}:rebuilt(prefix,D.exact_pending(Schedule.build(~D.Schema,~D.Left(),~Unit,~Unit,~Unit,~Unit,~D.resources(),~{==},~String,~Unit,~D.Author(),~D.Peer(),~D.left,~D.right,~Unit,~D.Handler,~Reg.empty_dispatch(~World(),~String),~Prog.empty(~World(),~String),~D.handle,~(name => True{}),world,Product.Owner{author,peer},Unit{},handler,[],[])))
def owner_ready_world(prefix:String,world:World(),held:Held,result:D.Author() & String) -> IO(String):
  match result:
    case (author,text):ready(prefix ++ ";" ++ text,world,author,held)
def owner_ready(prefix:String,author:D.Author(),held:Held,result:World() & String) -> IO(String):
  match result:
    case (world,text):owner_ready_world(prefix ++ ";" ++ text,world,held,owner_metadata(author))
def restored(prefix:String,held:Held,result:SystemLife.Restoration<World(),D.Author()>) -> IO(String):
  match result:
    case SystemLife.Restored{world,owner}:owner_ready(prefix ++ ";restore=ok",owner,held,metadata(world))
    case SystemLife.RestorationRefused{_,_}:IO.pure(String,"ERROR: restore refused")
def rebound(prefix:String,held:Held,result:Life.Rebinding<World(),D.Author()>) -> IO(String):
  match result:
    case Life.Rebound{world,owner}:owner_ready(prefix ++ ";rebind=ok",owner,held,metadata(world))
    case Life.RebindRefused{_,_}:IO.pure(String,"ERROR: rebind refused")
def rebind_refused(prefix:String,held:Held,result:Life.Rebinding<World(),D.Author()>) -> IO(String):
  match result:
    case Life.Rebound{_,_}:IO.pure(String,"ERROR: exhausted rebind succeeded")
    case Life.RebindRefused{world,detached}:restored(prefix ++ ";rebind=refused",held,Life.restore(~D.Schema,~D.Left(),~Unit,~Unit,~D.layout(),~D.resources(),~D.path(),~D.CmdOps,~D.AuthorLocal,~String,~Unit,~D.author_declaration,~D.author_body,~D.Resources(),detached,world))
def retired_metadata(mode:Mode,prefix:String,held:Held,detached:SystemLife.Detached<D.Author()>,result:World() & String) -> IO(String):
  match mode result:
    case RestoreMode{}, (world,text):restored(prefix ++ ";retired:" ++ text,held,Life.restore(~D.Schema,~D.Left(),~Unit,~Unit,~D.layout(),~D.resources(),~D.path(),~D.CmdOps,~D.AuthorLocal,~String,~Unit,~D.author_declaration,~D.author_body,~D.Resources(),detached,world))
    case RebindMode{}, (world,text):rebound(prefix ++ ";retired:" ++ text,held,Life.rebind(~D.Schema,~D.Left(),~Unit,~Unit,~D.layout(),~D.resources(),~D.path(),~D.CmdOps,~D.AuthorLocal,~String,~Unit,~D.author_declaration,~D.author_body,~D.Resources(),detached,world,"rebound"))
    case ExhaustedMode{}, (world,text):rebind_refused(prefix ++ ";retired:" ++ text,held,Life.rebind(~D.Schema,~D.Left(),~Unit,~Unit,~D.layout(),~D.resources(),~D.path(),~D.CmdOps,~D.AuthorLocal,~String,~Unit,~D.author_declaration,~D.author_body,~D.Resources(),detached,exhausted(world),"rebound"))
def retired(mode:Mode,prefix:String,held:Held,result:SystemLife.Retirement<World(),D.Author()>) -> IO(String):
  match result:
    case SystemLife.Retired{world,detached}:retired_metadata(mode,prefix,held,detached,metadata(world))
    case SystemLife.RetirementRefused{world,owner}:owner_ready(prefix ++ ";retire=refused",owner,held,metadata(world))
def queued(mode:Mode,result:D.Application() & DepApp.Report<String,Unit>) -> IO(String):
  match result:
    case (Schedule.Scheduled{DepApp.State{world,Product.Owner{author,peer},_,handler,_},_,_,_,_},report):retired(mode,"initial=" ++ D.report(report),Held{peer,handler},Life.retire(~D.Schema,~D.Left(),~Unit,~Unit,~D.layout(),~D.resources(),~D.path(),~D.CmdOps,~D.AuthorLocal,~String,~Unit,~D.author_declaration,~D.author_body,~D.Resources(),author,world))
def setup(mode:Mode,result:D.Setup) -> IO(String):
  match result:
    case D.SetupReady{app}:IO.bind(D.Application() & DepApp.Report<String,Unit>,String,D.selected(True{},app),result => queued(mode,result))
    case D.SetupFailed{message}:IO.pure(String,message)
def run(mode:Mode,valid:Bool) -> IO(String):
  setup(mode,D.setup(Settings.Settings{False{},False{},[],[]},valid,True{}))
def main() -> IO(Unit):
  IO.bind(String,Unit,run(RestoreMode{},True{}),restored => IO.bind(String,Unit,run(RebindMode{},True{}),rebound => IO.bind(String,Unit,run(ExhaustedMode{},True{}),refused => IO.bind(String,Unit,run(RestoreMode{},False{}),mismatch => IO.print("restore=" ++ restored ++ "\nrebind=" ++ rebound ++ "\nrebind-refused=" ++ refused ++ "\ncache-mismatch=" ++ mismatch)))))
