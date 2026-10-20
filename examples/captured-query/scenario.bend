import Base
import ./schema.bend as S
import ./body.bend as B
import ./app.bend as A
import ./observe.bend as Obs
import ./payload.bend as P
import ../../src/ecs/ordinary-app-run.bend as Entry
import ../../src/ecs/ordinary-app-schedule.bend as Single
import ../../src/ecs/ordinary-app-schema.bend as SchemaApp
import ../../src/ecs/ordinary-app-composer.bend as Build
import ../../src/ecs/ordinary-app-execution.bend as Exec
import ../../src/ecs/execution-trace.bend as Trace
import ../../src/ecs/schedule.bend as Sch
import ../../src/ecs/ordinary-app-capture-query.bend as Captured
import ../../src/ecs/ordinary-app-component.bend as Component
import ../../src/ecs/captured-schedule-composition.bend as Choice
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/world.bend as W

def with_world(~Schema:Data,~Out:Type,next:S.World(~Schema) -> String -> Out,result:S.World(~Schema) & String) -> Out:
  match result:
    case (world,text):next(world,text)
def with_owners(~Schema:Data,~Out:Type,next:A.Owners(~Schema) -> String -> Out,result:A.Owners(~Schema) & String) -> Out:
  match result:
    case (owners,text):next(owners,text)
def with_app(~Schema:Data,~Out:Type,next:A.Scheduled(~Schema) -> String -> Out,result:A.Scheduled(~Schema) & String) -> Out:
  match result:
    case (app,text):next(app,text)
def snapshot(~Schema:Data,value:A.Scheduled(~Schema)) -> A.Scheduled(~Schema) & String:
  match value:
    case Entry.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},selected,ns,name,steps,needs},execution}:
      with_world(~Schema,~(A.Scheduled(~Schema) & String),world=>wt=>with_owners(~Schema,~(A.Scheduled(~Schema) & String),owners=>ot=>(Entry.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},selected,ns,name,steps,needs},execution},wt ++ "|" ++ ot),Obs.owners(~Schema,owners)),S.observe(~Schema,world))
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered(" ++ name ++ ")"
    case Sch.Ran{id}:"Ran(" ++ U32.show(id) ++ ")"
    case Sch.Skipped{id}:"Skipped(" ++ U32.show(id) ++ ")"
    case Sch.Applied{}:"Applied"
def world_error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def captured_error(value:Captured.ExecutionError<B.Error>) -> String:
  match value:
    case Captured.CallbackFailure{Q.UserError{B.Deliberate{row}}}:"Captured.CallbackFailure.UserError.Deliberate:" ++ B.row(row)
    case Captured.CallbackFailure{Q.UserError{B.Missing{}}}:"Captured.CallbackFailure.UserError.Missing"
    case Captured.CallbackFailure{Q.AccessError{reason}}:"Captured.CallbackFailure.AccessError:" ++ world_error(reason)
    case Captured.RegistrationRefused{}:"Captured.RegistrationRefused"
def audit_error(value:Component.ExecutionError<B.AuditError>) -> String:
  match value:
    case Component.CallbackFailure{Q.UserError{B.AuditMissing{}}}:"Audit.CallbackFailure.UserError.AuditMissing"
    case Component.CallbackFailure{Q.AccessError{reason}}:"Audit.CallbackFailure.AccessError:" ++ world_error(reason)
    case Component.RegistrationRefused{}:"Audit.RegistrationRefused"
def prior_error(value:A.FirstError()) -> String:
  match value:
    case Choice.LeftError{Unit{}}:"Initial.Unit"
    case Choice.RightError{error}:audit_error(error)
def error(value:A.ErrorType()) -> String:
  match value:
    case Choice.LeftError{error}:prior_error(error)
    case Choice.RightError{error}:captured_error(error)
def completed(~Schema:Data,value:Single.RunResult<A.Scheduled(~Schema),Schema,A.ErrorType()>) -> A.Scheduled(~Schema) & String:
  match value:
    case Single.Finished{app,observations}:(app,"Finished:" ++ List.show(&2,Sch.Observation,observation,observations))
    case Single.Failed{app,reason,observations}:(app,"Failed:" ++ error(reason) ++ ":" ++ List.show(&2,Sch.Observation,observation,observations))
    case Single.Rejected{app}:(app,"UNEXPECTED_REJECTION")
    case Single.Missing{app,_}:(app,"UNEXPECTED_MISSING")
def executed(~Schema:Data,value:Exec.Run<A.Scheduled(~Schema),Schema,A.ErrorType()>) -> A.Scheduled(~Schema) & String:
  match value:
    case Exec.Run{result,Trace.Disabled{}}:completed(~Schema,result)
    case Exec.Run{result,Trace.BendvyReady{events}}:with_app(~Schema,~(A.Scheduled(~Schema) & String),app=>text=>(app,text ++ ":UNEXPECTED_TRACE:" ++ Nat.show(List.length(&2,Trace.TraceEvent<A.ErrorType()>,events))),completed(~Schema,result))
def step(~Schema:Data,label:String,old:String,app:A.Scheduled(~Schema)) -> A.Scheduled(~Schema) & String:
  with_app(~Schema,~(A.Scheduled(~Schema) & String),app=>result=>with_app(~Schema,~(A.Scheduled(~Schema) & String),app=>state=>(app,old ++ label ++ ":" ++ result ++ "|" ++ state ++ "\n"),snapshot(~Schema,app)),executed(~Schema,A.run(~Schema,app)))
def final_text(~Schema:Data,result:A.Scheduled(~Schema) & String) -> String:
  match result:
    case (_,text):text
def sequence(~Schema:Data,app:A.Scheduled(~Schema)) -> String:
  with_app(~Schema,~String,app=>initial=>with_app(~Schema,~String,app=>first=>with_app(~Schema,~String,app=>second=>final_text(~Schema,step(~Schema,"no-change",second,app)),step(~Schema,"retry",first,A.retry(~Schema,app))),step(~Schema,"failure","initial|" ++ initial ++ "\n",app)),snapshot(~Schema,app))
def attached(~Schema:Data,value:Single.Attachment<A.Registered(~Schema),A.Scheduled(~Schema)>) -> String:
  match value:
    case Single.Attached{app}:sequence(~Schema,app)
    case Single.Invalid{_}:"INVALID_APP\n"
def second_added(~Schema:Data,value:A.Registered(~Schema)) -> String:attached(~Schema,A.attach(~Schema,value))
def second_refused(~Schema:Data,value:A.First(~Schema),capture:P.Pack) -> String:"SECOND_REGISTRATION_REFUSED\n"
def first_added(~Schema:Data,value:A.First(~Schema)) -> String:A.add_second(~Schema,~String,second_added(~Schema),second_refused(~Schema),value)
def first_refused(~Schema:Data,value:A.Initial(~Schema)) -> String:"FIRST_REGISTRATION_REFUSED\n"
def start(~Schema:Data,world:S.World(~Schema)) -> String:A.add_first(~Schema,~String,first_added(~Schema),first_refused(~Schema),S.seed(~Schema,world))
