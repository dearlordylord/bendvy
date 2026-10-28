import Base
import ./scene.bend as Scene
import ./generalized-observation.bend as Snapshot
import ./actor.bend as Actor
import ./generalized-application.bend as Application
import ./generalized-initialize.bend as Initialize
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/world.bend as W

def observed(result:Application.Bound(~Scene.Schema) & String,next:Application.Bound(~Scene.Schema) -> IO(Unit),report:Context.RunReport<App.Report<String,String>>,label:String) -> IO(Unit):
  match result:
    case (bound,text):IO.bind(Unit,Unit,IO.print(label ++ Snapshot.run_report(~Scene.Schema,report) ++ "|" ++ text),_ => next(bound))
def finished(_:Application.Bound(~Scene.Schema)) -> IO(Unit):IO.pure(Unit,Unit{})
def third(result:Application.Bound(~Scene.Schema) & Context.RunReport<App.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,report):observed(Snapshot.snapshot(~Scene.Schema,bound),finished,report,"generalized/third-final/")
def run_third(bound:Application.Bound(~Scene.Schema)) -> IO(Unit):
  IO.bind(Application.Bound(~Scene.Schema) & Context.RunReport<App.Report<String,String>>,Unit,Application.run(~Scene.Schema,Application.configure(~Scene.Schema,True{},bound)),third)
def second(result:Application.Bound(~Scene.Schema) & Context.RunReport<App.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,report):observed(Snapshot.snapshot(~Scene.Schema,bound),run_third,report,"generalized/second-retained/")
def run_second(bound:Application.Bound(~Scene.Schema)) -> IO(Unit):
  IO.bind(Application.Bound(~Scene.Schema) & Context.RunReport<App.Report<String,String>>,Unit,Application.run(~Scene.Schema,Application.configure(~Scene.Schema,False{},bound)),second)
def first(result:Application.Bound(~Scene.Schema) & Context.RunReport<App.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,report):observed(Snapshot.snapshot(~Scene.Schema,bound),run_second,report,"generalized/first-final/")
def initialized(value:Initialize.Initialization<Scene.Schema>) -> IO(Unit):
  match value:
    case Initialize.InitializationReady{_,bound}:IO.bind(Application.Bound(~Scene.Schema) & Context.RunReport<App.Report<String,String>>,Unit,Application.run(~Scene.Schema,Application.configure(~Scene.Schema,True{},bound)),first)
    case _:IO.print("retained-initialization-refusal")
def main() -> IO(Unit):
  initialized(Initialize.create(~Scene.Schema,W.factory(),Actor.Session{401},Actor.Session{601}))
