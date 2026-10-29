import Base
import ./visibility.bend as V
import ./controls/positive.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/owner-product.bend as Product

def World() -> Type:W.World<V.Schema,V.Store(),V.Resources(),Unit>
# Trusted fixture provisioning swaps actual owners to exercise namespace refusal.
# The same affine Factory creates both Worlds; no namespaces are fabricated.
def exchange(app:V.Application(),replacement:World()) -> V.Application() & World():
  match app:
    case Schedule.Scheduled{DepApp.State{world,owners,guards,handler,stateBindings},plan,bindings,rules,deferred}:(Schedule.Scheduled{DepApp.State{replacement,owners,guards,handler,stateBindings},plan,bindings,rules,deferred},world)
def final_enabled(app:V.Application()) -> V.Application():
  match app:
    case Schedule.Scheduled{state,plan,bindings,rules,Schedule.Deferred{systems,_,history}}:Schedule.Scheduled{state,plan,bindings,rules,Schedule.Deferred{systems,Settings.Settings{False{},True{},[],[]},history}}
def author_quiet(owner:V.Author()) -> V.Author():
  match owner:
    case Cmd.Owner{Sys.Owner{a,b,c,d,cursor,Local.Local{V.AuthorLocal{capture,_},queue,permission}}}:Cmd.Owner{Sys.Owner{a,b,c,d,cursor,Local.Local{V.AuthorLocal{capture,False{}},queue,permission}}}
def quiet(app:V.Application()) -> V.Application():
  match app:
    case Schedule.Scheduled{DepApp.State{world,Product.Owner{Product.Owner{author,reader},peer},guards,handler,stateBindings},plan,bindings,rules,deferred}:Schedule.Scheduled{DepApp.State{world,Product.Owner{Product.Owner{author_quiet(author),reader},peer},guards,handler,stateBindings},plan,bindings,rules,deferred}
def finished(prefix:String,result:V.Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,report):V.pending_observed(prefix ++ ";retry=" ++ V.report(report),V.exact_pending(app))
def restored(prefix:String,result:V.Application() & World()) -> IO(String):
  match result:
    case (app,foreign):IO.bind(V.Application() & DepApp.Report<String,Unit>,String,V.selected(True{},quiet(app)),result => IO.pure(String,finished(prefix ++ "|foreign=" ++ V.world(foreign),result)))
def pending_checked(original:World(),prefix:String,result:V.Application() & Bool) -> IO(String):
  match result:
    case (app,pending):restored(prefix ++ ";foreign-pending=" ++ Bool.pick(String,pending,"true","false"),exchange(app,original))
def refused(original:World(),prefix:String,result:V.Application() & DepApp.Report<String,Unit>) -> IO(String):
  match result:
    case (app,report):pending_checked(original,prefix ++ ";foreign-run=" ++ V.report(report),V.exact_pending(app))
def replaced(prefix:String,result:V.Application() & World()) -> IO(String):
  match result:
    case (app,original):IO.bind(V.Application() & DepApp.Report<String,Unit>,String,V.selected(True{},final_enabled(app)),result => refused(original,prefix,result))
def queued(foreign:World(),result:V.Application() & DepApp.Report<String,Unit>) -> IO(String):
  match result:
    case (app,report):replaced("initial=" ++ V.report(report),exchange(app,foreign))
def setup(foreign:World(),result:V.Setup) -> IO(String):
  match result:
    case V.SetupReady{app}:IO.bind(V.Application() & DepApp.Report<String,Unit>,String,V.selected(True{},app),result => queued(foreign,result))
    case V.SetupFailed{message}:IO.pure(String,message)
def created(result:W.Creation<V.Schema,V.Store(),V.Resources(),Unit>) -> IO(String):
  match result:
    case W.Created{factory,foreign}:setup(foreign,V.created(Settings.Settings{False{},False{},[],[]},True{},True{},W.create(~V.Schema,~V.Store(),~V.Resources(),~Unit,~V.empty,factory,Product.Owner{Unit{},Unit{}})))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR: foreign creation")
def main() -> IO(Unit):
  IO.bind(String,Unit,created(W.create(~V.Schema,~V.Store(),~V.Resources(),~Unit,~V.empty,W.factory(),Product.Owner{Unit{},Unit{}})),IO.print)
