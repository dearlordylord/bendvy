import Base
import ./forms.bend as Forms
import ./bootstrap.bend as Bootstrap
import ./registration.bend as Registration
import ./application.bend as Application
import ./observation.bend as Observe
import ./provisioning.bend as Provisioning
import ../../src/ecs/dependency-composer-program.bend as Scoped
import ../../src/ecs/dependency-plan.bend as Plan

def completed(prefix:String,result:Application.Application() & Application.Report()) -> String:
  match result:
    case (application,report):prefix ++ Observe.report(report) ++ "|" ++ Observe.application(application)
def missing(application:Application.Application()) -> IO(String):
  IO.bind(Application.Application() & Application.Report(),String,Application.run(application),result => IO.pure(String,completed("",result)))
def twice_returned(repeated:Bool,first:String,result:Application.Application() & Application.Report()) -> IO(String):
  match repeated result:
    case False{},(application,report):IO.pure(String,first ++ Observe.report(report) ++ "|" ++ Observe.application(application))
    case True{},(application,report):IO.bind(Application.Application() & Application.Report(),String,Application.run(application),result => IO.pure(String,completed(first ++ Observe.report(report) ++ "|",result)))
def first_returned(repeated:Bool,result:Application.Application() & Application.Report()) -> IO(String):
  match result:
    case (application,report):IO.bind(Application.Application() & Application.Report(),String,Application.run(Provisioning.extra(Provisioning.install(application))),result => twice_returned(repeated,Observe.report(report) ++ "|",result))
def provided(application:Application.Application()) -> IO(String):
  IO.bind(Application.Application() & Application.Report(),String,Application.run(application),result => first_returned(False{},result))
def repeated(application:Application.Application()) -> IO(String):
  IO.bind(Application.Application() & Application.Report(),String,Application.run(application),result => first_returned(True{},result))
def boot(finish:Application.Application() -> IO(String),result:Bootstrap.Outcome) -> IO(String):
  match result:
    case Bootstrap.Registered{Registration.Registered{application}}:finish(application)
    case result:IO.pure(String,Observe.bootstrap(result))
def invalid_groups() -> List<&2,Scoped.Nested>:
  [Scoped.Nested{[0],[Plan.Edge{1,3}]}]
def printed(prefix:String,action:IO(String),next:Unit -> IO(Unit)) -> IO(Unit):
  IO.bind(String,Unit,action,value => IO.bind(Unit,Unit,IO.print(prefix ++ value ++ "\n"),_ => next(Unit{})))
def main() -> IO(Unit):
  printed("missing=",boot(missing,Bootstrap.run(Application.groups())),_ => printed("provided=",boot(provided,Bootstrap.run(Application.groups())),_ => printed("repeated=",boot(repeated,Bootstrap.run(Application.groups())),_ => printed("invalid-nesting=",boot(missing,Bootstrap.run(invalid_groups())),_ => printed("optional-none=",boot(missing,Bootstrap.run_optional_none(Application.groups())),_ => IO.print("validation=" ++ Forms.validation() ++ "\nschema-collision=" ++ Forms.schema_refusal() ++ "\nnamespace-refusal=" ++ Forms.namespace_refusal()))))))
