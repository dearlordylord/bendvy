import Base
import core.bend as Core
import schema.bend as S
import ../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../src/ecs/ordinary-app-service-registration.bend as Service
import ../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/world.bend as W

def observed(namespace:U32,queryCursor:U32,serviceCursor:U32,value:S.World() & String) -> String:
  match value:
    case (W.World{actual,_,_,_,_,_,_,_,_},counter):"foreign-world=Rejected registration-world=" ++ U32.show(namespace) ++ " actual-world=" ++ U32.show(actual) ++ " query-cursor=" ++ U32.show(queryCursor) ++ " service-cursor=" ++ U32.show(serviceCursor) ++ " " ++ counter
def rejected(value:Schedule.Attachment<Core.Registered(),Core.Scheduled()>) -> String:
  match value:
    case Schedule.Invalid{Exec.Registered{Build.Registered{world,((_,Exec.Invocation{Leaf.Record{_,Fields.Fields{namespace,_,_,_,queryCursor,_,_,_}},_,_}),Service.Owner{Sys.Registry{_,_,_,_,serviceCursor},_}),_,_},_}}:observed(namespace,queryCursor,serviceCursor,Core.counter_world(world))
    case _:"ERROR: foreign App accepted"
def evaluate(original:Core.Registered(),world:S.World()) -> String:
  match original:
    case Exec.Registered{Build.Registered{_,owners,recipe,debug},execution}:rejected(Core.attach(Exec.Registered{Build.Registered{world,owners,recipe,debug},execution},True{}))
