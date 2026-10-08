import Base
import ./normal-bootstrap.bend as Bootstrap
import ./normal-application.bend as Application
import ./canonical-app.bend as App
import ./normal-values.bend as Game
import ./normal-registered-observation.bend as Registered
import ./normal-duplicate-control.bend as Duplicate
import ./normal-controls-render.bend as Render

def duplicate(value:Duplicate.Observed) -> String:
  match value:
    case Duplicate.Rejected{left,right,observation}:Render.duplicate(observation)
    case other:"duplicate-was-accepted"
def registered(value:Registered.Observed) -> String:
  match value:
    case Registered.Succeeded{world,app,instance,observation}:Render.registered(observation)++"\n"++duplicate(Duplicate.run(ALeaf{17},Game.Clock{ALeaf{23}}))
    case other:"registered-dispatch-refused"
def prepared(value:Application.Prepared) -> String:
  match value:
    case Application.Prepared{world,app}:registered(Registered.run(world,app))
    case other:"registration-or-schedule-refused"
def started(value:Bootstrap.Started) -> IO(Unit):
  match value:
    case Bootstrap.Started{value}:IO.print(prepared(value))
    case other:IO.print("bootstrap-refused")
def main() -> IO(Unit):
  IO.bind(Bootstrap.Started,Unit,Bootstrap.start(App.Enabled{}),started)
