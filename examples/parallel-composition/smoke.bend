import Base
import ./bootstrap.bend as Bootstrap
import ./application.bend as Application
import ./feature-motion.bend as Motion
import ./feature-labels.bend as Labels
import ../../src/ecs/execution-composer-app.bend as Compose
import ../../src/ecs/dependency-application.bend as Dep
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/execution-system.bend as Sys

def event(value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,out}:U32.show(id) ++ ":ran:" ++ out
    case Exec.BodyFailed{id,error,out}:U32.show(id) ++ ":error:" ++ error ++ ":" ++ out
    case Exec.ConditionFailed{id,error}:U32.show(id) ++ ":missing:" ++ error
    case Exec.Skipped{id}:U32.show(id) ++ ":skipped"
    case Exec.ConditionRejected{id}:U32.show(id) ++ ":condition-refused"
    case Exec.AdmissionRejected{id}:U32.show(id) ++ ":admission-refused"
def report(value:Compose.CompositionReport<String,String>) -> String:
  match value:
    case Compose.CompositionRan{Dep.Finished{events}}:List.show(&2,Exec.Observation<String,String>,event,events)
    case _:"unexpected-report"
def finished(result:Application.Application() & Compose.CompositionReport<String,String>) -> String:
  match result:
    case (Compose.Composed{Dep.Application{Dep.State{_,Reg.Product{Reg.Product{Sys.Owner{_,_,_,_,_,Motion.Local{_,a,_}},Sys.Owner{_,_,_,_,_,Motion.Local{_,b,_}},_},Reg.Product{Sys.Owner{_,_,_,_,_,Labels.Local{_,c,_}},Sys.Owner{_,_,_,_,_,Labels.Local{_,d,_}},_},_},_,_,_},_,_},_,_},done):report(done) ++ ";locals=" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d)
def finish(application:Application.Application()) -> String:finished(Application.run(application))
def main() -> IO(Unit):IO.print(Bootstrap.run(~finish,Application.groups()))
