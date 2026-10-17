import Base
import ../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../src/ecs/ordinary-app-records.bend as Records
import local-fixture.bend as F
import ../../../src/ecs/ordinary-app-local-fields.bend as LocalApp
import ../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../src/ecs/captured-schedule-composition.bend as Choice

def printed(next:F.Application() -> String,label:String,local:String,value:F.Application() & U32) -> String:
  match value:
    case (app,resource):label ++ " resource=" ++ U32.show(resource) ++ " local=" ++ local ++ next(app)
def observed(next:F.Application() -> String,label:String,value:F.Application() & String) -> String:
  match value:
    case (app,local):printed(next,label,local,F.resource(app))
def retried(value:Execution.Run<F.Application(),F.S,Choice.Choice<Unit,LocalApp.ExecutionError<F.Error>>>) -> String:
  match value:
    case Execution.Run{Schedule.Finished{app,_},_}:observed(_ => "","retried",F.observed(app))
    case _:"ERROR: retry"
def retry(app:F.Application()) -> String:
  "\n" ++ retried(F.run(app))
def failed(value:Execution.Run<F.Application(),F.S,Choice.Choice<Unit,LocalApp.ExecutionError<F.Error>>>) -> String:
  match value:
    case Execution.Run{Schedule.Failed{app,Choice.RightError{LocalApp.CallbackFailure{F.ExpectedFailure{}}},_},_}:observed(retry,"failed",F.observed(app))
    case _:"ERROR: expected failure"
def attached(value:Schedule.Attachment<F.Registered(),F.Application()>) -> String:
  match value:
    case Schedule.Attached{app}:failed(F.run(app))
    case _:"ERROR: attach"
def registered(value:LocalApp.Appended<Exec.Registered<F.S,F.World(),Unit,Unit,Build.empty_observe(~F.World()),Records.empty(~F.S),Unit,Exec.empty_plan(~F.S),Exec.empty_dispatch(~F.World()),Exec.empty_provide(~F.S,~F.World())>,F.Registered(),Array<U32>>) -> String:
  match value:
    case LocalApp.Appended{app}:attached(F.attach(app))
    case _:"ERROR: registration"
def start(world:F.World()) -> String:
  registered(F.register(world))
