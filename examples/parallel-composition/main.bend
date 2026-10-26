import Base
import ./forms.bend as Forms
import ./bootstrap.bend as Bootstrap
import ./application.bend as Application
import ./observation.bend as Observe
import ./provisioning.bend as Provisioning
import ../../src/ecs/execution-composer-app.bend as Compose
import ../../src/ecs/dependency-composer-program.bend as Scoped
import ../../src/ecs/dependency-plan.bend as Plan

def completed(prefix:String,result:Application.Application() & Compose.CompositionReport<String,String>) -> String:
  match result:
    case (application,report):prefix ++ Observe.report(report) ++ "|" ++ Observe.application(application)
def missing(application:Application.Application()) -> String:completed("",Application.run(application))
def twice_returned(repeated:Bool,first:String,result:Application.Application() & Compose.CompositionReport<String,String>) -> String:
  match repeated result:
    case False{},(application,report):first ++ Observe.report(report) ++ "|" ++ Observe.application(application)
    case True{},(application,report):completed(first ++ Observe.report(report) ++ "|",Application.run(application))
def first_returned(repeated:Bool,result:Application.Application() & Compose.CompositionReport<String,String>) -> String:
  match result:
    case (application,report):twice_returned(repeated,Observe.report(report) ++ "|",Application.run(Provisioning.extra(Provisioning.install(application))))
def provided(application:Application.Application()) -> String:first_returned(False{},Application.run(application))
def repeated(application:Application.Application()) -> String:first_returned(True{},Application.run(application))
def invalid_groups() -> List<&2,Scoped.Nested>:
  [Scoped.Nested{[0],[Plan.Edge{1,3}]}]
def main() -> IO(Unit):
  IO.print("missing=" ++ Bootstrap.run(~missing,Application.groups()) ++ "\nprovided=" ++ Bootstrap.run(~provided,Application.groups()) ++ "\nrepeated=" ++ Bootstrap.run(~repeated,Application.groups()) ++ "\ninvalid-nesting=" ++ Bootstrap.run(~missing,invalid_groups()) ++ "\noptional-none=" ++ Bootstrap.run_optional_none(~missing,Application.groups()) ++ "\nvalidation=" ++ Forms.validation() ++ "\nschema-collision=" ++ Forms.schema_refusal() ++ "\nnamespace-refusal=" ++ Forms.namespace_refusal())
