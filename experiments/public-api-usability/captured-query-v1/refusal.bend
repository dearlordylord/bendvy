import Base
import ./schema.bend as S
import ./body.bend as B
import ./app.bend as A
import ./observe.bend as Obs
import ../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../src/ecs/ordinary-app-capture-query.bend as Captured
import ../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../src/ecs/world.bend as W

# Explicit trusted finite boundary input; this is not a history of 2^32 runs.
def at_limit(~Schema:Data,value:S.World(~Schema)) -> S.World(~Schema):
  match value:
    case W.World{ns,allocator,store,resource,events,pending,registrations,_,clock}:W.World{ns,allocator,store,resource,events,pending,registrations,4294967295,clock}
def limit_app(~Schema:Data,value:A.First(~Schema)) -> A.First(~Schema):
  match value:
    case Exec.Registered{Build.Registered{world,owners,recipe,debug},execution}:Exec.Registered{Build.Registered{at_limit(~Schema,world),owners,recipe,debug},execution}
def with_world(~Schema:Data,~Out:Type,next:S.World(~Schema) -> String -> Out,result:S.World(~Schema) & String) -> Out:
  match result:
    case (world,text):next(world,text)
def with_owner(~Schema:Data,~Out:Type,next:A.FirstOwners(~Schema) -> String -> Out,result:A.FirstOwners(~Schema) & String) -> Out:
  match result:
    case (owner,text):next(owner,text)
def prior(~Schema:Data,value:A.First(~Schema)) -> A.First(~Schema) & String:
  match value:
    case Exec.Registered{Build.Registered{world,owners,recipe,+debug},execution}:with_world(~Schema,~(A.First(~Schema) & String),world=>wt=>with_owner(~Schema,~(A.First(~Schema) & String),owners=>ot=>(Exec.Registered{Build.Registered{world,owners,recipe,debug},execution},wt ++ "|audit={" ++ ot ++ "}|debug=" ++ Bool.show(debug)),Obs.audit(~Schema,owners)),S.observe(~Schema,world))
def with_prior(~Schema:Data,~Out:Type,next:A.First(~Schema) -> String -> Out,result:A.First(~Schema) & String) -> Out:
  match result:
    case (app,text):next(app,text)
def with_pack(~Out:Type,next:P.Pack -> String -> Out,result:P.Pack & P.Observation) -> Out:
  match result:
    case (capture,view):next(capture,Obs.pack(view))
def refused(~Schema:Data,old:String,value:A.First(~Schema),capture:P.Pack) -> String:
  with_prior(~Schema,~String,app=>text=>with_pack(~String,_=>pack=>old ++ "after:Refused|" ++ text ++ "|capture=" ++ pack ++ "\n",P.project(capture)),prior(~Schema,value))
def unexpected(~Schema:Data,old:String,value:A.Registered(~Schema)) -> String:old ++ "UNEXPECTED_ADD_SUCCESS\n"
def checked_add(~Schema:Data,app:A.First(~Schema),+prefix:String,capture:P.Pack) -> String:
  Captured.add(~Schema,~S.Store(~Schema),~Unit,~Unit,~A.FirstOwners(~Schema),~A.FirstRows(~Schema),~A.first_observe(~Schema),~A.first_fold(~Schema),~A.FirstError(),~A.first_plan(~Schema),~A.first_dispatch(~Schema),~A.first_provide(~Schema),~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body,~String,unexpected(~Schema,prefix),refused(~Schema,prefix),app,B.Args{999},"refused-capture",capture)
def checked(~Schema:Data,app:A.First(~Schema),text:String) -> String:
  with_pack(~String,capture=>pack=>checked_add(~Schema,app,text ++ "|capture=" ++ pack ++ "\n",capture),P.project(P.initial(50)))
def first_added(~Schema:Data,value:A.First(~Schema)) -> String:
  with_prior(~Schema,~String,app=>text=>checked(~Schema,app,"Refusal\nbefore|" ++ text),prior(~Schema,limit_app(~Schema,value)))
def first_refused(~Schema:Data,value:A.Initial(~Schema)) -> String:"UNEXPECTED_FIRST_REFUSAL\n"
