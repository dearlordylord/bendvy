import Base
import ./schema.bend as S
import ./app.bend as A
import ./body.bend as B
import ./observe.bend as O
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-application.bend as App

def event(value:Exec.Observation<B.Error,String>) -> String:
  match value:
    case Exec.Ran{id,out}:U32.show(id) ++ "/ran/" ++ out
    case Exec.BodyFailed{id,error,out}:U32.show(id) ++ "/body-error/" ++ B.error(error) ++ "/" ++ out
    case Exec.Skipped{id}:U32.show(id) ++ "/skipped"
    case Exec.ConditionFailed{id,error}:U32.show(id) ++ "/condition-error/" ++ B.error(error)
    case Exec.ConditionRejected{id}:U32.show(id) ++ "/condition-refused"
    case Exec.AdmissionRejected{id}:U32.show(id) ++ "/admission-refused"
def report(value:App.Report<B.Error,String>) -> String:
  match value:
    case App.Finished{events}:"finished:" ++ List.show(&2,Exec.Observation<B.Error,String>,event,events)
    case App.Stopped{error,_}:"stopped:" ++ B.error(error)
    case App.Invalid{_}:"invalid"
def end(result:A.Application() & String) -> IO(Unit):
  match result:
    case (_,text):IO.print("no-change|" ++ text ++ "\n")
def last(result:A.Application() & App.Report<B.Error,String>) -> IO(Unit):
  match result:
    case (app,events):IO.bind(Unit,Unit,IO.print("no-change-result|" ++ report(events) ++ "\n"),_ => end(O.snapshot(app)))
def retried(result:A.Application() & String) -> IO(Unit):
  match result:
    case (app,text):IO.bind(Unit,Unit,IO.print("retry|" ++ text ++ "\n"),_ => IO.bind(A.Application() & App.Report<B.Error,String>,Unit,A.run(app),last))
def retry_result(result:A.Application() & App.Report<B.Error,String>) -> IO(Unit):
  match result:
    case (app,events):IO.bind(Unit,Unit,IO.print("retry-result|" ++ report(events) ++ "\n"),_ => retried(O.snapshot(app)))
def retry(result:A.Application() & String) -> IO(Unit):
  match result:
    case (app,_):IO.bind(A.Application() & App.Report<B.Error,String>,Unit,A.run(app),retry_result)
def failed(result:A.Application() & String) -> IO(Unit):
  match result:
    case (app,text):IO.bind(Unit,Unit,IO.print("failure|" ++ text ++ "\n"),_ => retry((O.retry(app),"")))
def first(result:A.Application() & App.Report<B.Error,String>) -> IO(Unit):
  match result:
    case (app,events):IO.bind(Unit,Unit,IO.print("failure-result|" ++ report(events) ++ "\n"),_ => failed(O.snapshot(app)))
def start(result:A.Application() & String) -> IO(Unit):
  match result:
    case (app,text):IO.bind(Unit,Unit,IO.print("initial|" ++ text ++ "\n"),_ => IO.bind(A.Application() & App.Report<B.Error,String>,Unit,A.run(app),first))
def defined(result:A.Definition) -> IO(Unit):
  match result:
    case A.DefinitionReady{app}:start(O.snapshot(app))
    case _:IO.die(Unit,1,"registration refused")
