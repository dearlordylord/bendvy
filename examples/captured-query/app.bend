import Base
import ../../src/ecs/ordinary-app-schema.bend as SchemaApp
import ./schema.bend as S
import ./body.bend as B
import ./payload.bend as P
import ../../src/ecs/ordinary-app-component.bend as Component
import ../../src/ecs/ordinary-app-capture-query.bend as Captured
import ../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../src/ecs/ordinary-app-run.bend as Entry
import ../../src/ecs/ordinary-app-composer.bend as Build
import ../../src/ecs/ordinary-app-records.bend as Leaf
import ../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../src/ecs/schedule-provision.bend as SP
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/execution-context.bend as Ctx
import ../../src/ecs/captured-schedule-composition.bend as Choice
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/component.bend as Cmp
import ../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../src/ecs/ordinary-app-execution.bend as Execution
import ../../src/ecs/capabilities.bend as Cap
def AuditOps(H:Type) -> Type:Cap.Read<H,P.Tree>
def Initial(~Schema:Data) -> Type:Exec.Registered<Schema,S.World(~Schema),Unit,Unit,Build.empty_observe(~S.World(~Schema)),Leaf.empty(~Schema),Unit,Exec.empty_plan(~Schema),Exec.empty_dispatch(~S.World(~Schema)),Exec.empty_provide(~Schema,~S.World(~Schema))>
def First(~Schema:Data) -> Type:Component.Application(~Schema,~S.Store(~Schema),~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World(~Schema)),~Leaf.empty(~Schema),~Unit,~Exec.empty_plan(~Schema),~Exec.empty_dispatch(~S.World(~Schema)),~Exec.empty_provide(~Schema,~S.World(~Schema)),~AuditOps,~Unit,~B.AuditError,~P.Tree,~Cmp.Access<P.Tree>,~B.audit_query(~Schema),~B.audit,~B.render)
def FirstOwners(~Schema:Data) -> Type:Component.execution_owners(~Schema,~S.Store(~Schema),~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World(~Schema)),~Leaf.empty(~Schema),~Unit,~Exec.empty_plan(~Schema),~Exec.empty_dispatch(~S.World(~Schema)),~Exec.empty_provide(~Schema,~S.World(~Schema)),~AuditOps,~Unit,~B.AuditError,~P.Tree,~Cmp.Access<P.Tree>,~B.audit_query(~Schema),~B.audit,~B.render)
def FirstRows(~Schema:Data) -> Data:Component.execution_rows(~Schema,~S.Store(~Schema),~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World(~Schema)),~Leaf.empty(~Schema),~Unit,~Exec.empty_plan(~Schema),~Exec.empty_dispatch(~S.World(~Schema)),~Exec.empty_provide(~Schema,~S.World(~Schema)),~AuditOps,~Unit,~B.AuditError,~P.Tree,~Cmp.Access<P.Tree>,~B.audit_query(~Schema),~B.audit,~B.render)
def FirstError() -> Data:Choice.Choice<Unit,Component.ExecutionError<B.AuditError>>
def first_observe(~Schema:Data) -> S.World(~Schema) -> S.World(~Schema) & DTO.Observation<FirstRows(~Schema)>:Component.execution_observe(~Schema,~S.Store(~Schema),~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World(~Schema)),~Leaf.empty(~Schema),~Unit,~Exec.empty_plan(~Schema),~Exec.empty_dispatch(~S.World(~Schema)),~Exec.empty_provide(~Schema,~S.World(~Schema)),~AuditOps,~Unit,~B.AuditError,~P.Tree,~Cmp.Access<P.Tree>,~B.audit_query(~Schema),~B.audit,~B.render)
def first_fold(~Schema:Data) -> FirstOwners(~Schema) -> FirstOwners(~Schema) & List<&2,Fields.Fields<Schema>>:Component.execution_fold(~Schema,~S.Store(~Schema),~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World(~Schema)),~Leaf.empty(~Schema),~Unit,~Exec.empty_plan(~Schema),~Exec.empty_dispatch(~S.World(~Schema)),~Exec.empty_provide(~Schema,~S.World(~Schema)),~AuditOps,~Unit,~B.AuditError,~P.Tree,~Cmp.Access<P.Tree>,~B.audit_query(~Schema),~B.audit,~B.render)
def first_plan(~Schema:Data) -> FirstOwners(~Schema) -> FirstOwners(~Schema) & SP.Plan<Schema>:Component.execution_plan(~Schema,~S.Store(~Schema),~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World(~Schema)),~Leaf.empty(~Schema),~Unit,~Exec.empty_plan(~Schema),~Exec.empty_dispatch(~S.World(~Schema)),~Exec.empty_provide(~Schema,~S.World(~Schema)),~AuditOps,~Unit,~B.AuditError,~P.Tree,~Cmp.Access<P.Tree>,~B.audit_query(~Schema),~B.audit,~B.render)
def first_dispatch(~Schema:Data) -> FirstOwners(~Schema) -> Ctx.Context<S.World(~Schema)> -> U32 -> FirstOwners(~Schema) & Sys.Outcome<Ctx.Context<S.World(~Schema)>,FirstError(),Unit>:Component.execution_dispatch(~Schema,~S.Store(~Schema),~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World(~Schema)),~Leaf.empty(~Schema),~Unit,~Exec.empty_plan(~Schema),~Exec.empty_dispatch(~S.World(~Schema)),~Exec.empty_provide(~Schema,~S.World(~Schema)),~AuditOps,~Unit,~B.AuditError,~P.Tree,~Cmp.Access<P.Tree>,~B.audit_query(~Schema),~B.audit,~B.render)
def first_provide(~Schema:Data) -> S.World(~Schema) -> S.World(~Schema) & List<&2,SP.Requirement<Schema>>:Component.execution_provide(~Schema,~S.Store(~Schema),~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World(~Schema)),~Leaf.empty(~Schema),~Unit,~Exec.empty_plan(~Schema),~Exec.empty_dispatch(~S.World(~Schema)),~Exec.empty_provide(~Schema,~S.World(~Schema)),~AuditOps,~Unit,~B.AuditError,~P.Tree,~Cmp.Access<P.Tree>,~B.audit_query(~Schema),~B.audit,~B.render)
def Registered(~Schema:Data) -> Type:Captured.Application(~Schema,~S.Store(~Schema),~Unit,~Unit,~FirstOwners(~Schema),~FirstRows(~Schema),~first_observe(~Schema),~first_fold(~Schema),~FirstError(),~first_plan(~Schema),~first_dispatch(~Schema),~first_provide(~Schema),~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body)
def Owners(~Schema:Data) -> Type:Captured.execution_owners(~Schema,~S.Store(~Schema),~Unit,~Unit,~FirstOwners(~Schema),~FirstRows(~Schema),~first_observe(~Schema),~first_fold(~Schema),~FirstError(),~first_plan(~Schema),~first_dispatch(~Schema),~first_provide(~Schema),~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body)
def Rows(~Schema:Data) -> Data:Captured.execution_rows(~Schema,~S.Store(~Schema),~Unit,~Unit,~FirstOwners(~Schema),~FirstRows(~Schema),~first_observe(~Schema),~first_fold(~Schema),~FirstError(),~first_plan(~Schema),~first_dispatch(~Schema),~first_provide(~Schema),~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body)
def ErrorType() -> Data:Choice.Choice<FirstError(),Captured.ExecutionError<B.Error>>
def observe(~Schema:Data) -> S.World(~Schema) -> S.World(~Schema) & DTO.Observation<Rows(~Schema)>:Captured.execution_observe(~Schema,~S.Store(~Schema),~Unit,~Unit,~FirstOwners(~Schema),~FirstRows(~Schema),~first_observe(~Schema),~first_fold(~Schema),~FirstError(),~first_plan(~Schema),~first_dispatch(~Schema),~first_provide(~Schema),~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body)
def fold(~Schema:Data) -> Owners(~Schema) -> Owners(~Schema) & List<&2,Fields.Fields<Schema>>:Captured.execution_fold(~Schema,~S.Store(~Schema),~Unit,~Unit,~FirstOwners(~Schema),~FirstRows(~Schema),~first_observe(~Schema),~first_fold(~Schema),~FirstError(),~first_plan(~Schema),~first_dispatch(~Schema),~first_provide(~Schema),~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body)
def plan(~Schema:Data) -> Owners(~Schema) -> Owners(~Schema) & SP.Plan<Schema>:Captured.execution_plan(~Schema,~S.Store(~Schema),~Unit,~Unit,~FirstOwners(~Schema),~FirstRows(~Schema),~first_observe(~Schema),~first_fold(~Schema),~FirstError(),~first_plan(~Schema),~first_dispatch(~Schema),~first_provide(~Schema),~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body)
def dispatch(~Schema:Data) -> Owners(~Schema) -> Ctx.Context<S.World(~Schema)> -> U32 -> Owners(~Schema) & Sys.Outcome<Ctx.Context<S.World(~Schema)>,ErrorType(),Unit>:Captured.execution_dispatch(~Schema,~S.Store(~Schema),~Unit,~Unit,~FirstOwners(~Schema),~FirstRows(~Schema),~first_observe(~Schema),~first_fold(~Schema),~FirstError(),~first_plan(~Schema),~first_dispatch(~Schema),~first_provide(~Schema),~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body)
def provide(~Schema:Data) -> S.World(~Schema) -> S.World(~Schema) & List<&2,SP.Requirement<Schema>>:Captured.execution_provide(~Schema,~S.Store(~Schema),~Unit,~Unit,~FirstOwners(~Schema),~FirstRows(~Schema),~first_observe(~Schema),~first_fold(~Schema),~FirstError(),~first_plan(~Schema),~first_dispatch(~Schema),~first_provide(~Schema),~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body)
def add_first(~Schema:Data,~Output:Type,done:First(~Schema) -> Output,failed:Initial(~Schema) -> Output,world:S.World(~Schema)) -> Output:
  Component.add(~Schema,~S.Store(~Schema),~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World(~Schema)),~Leaf.empty(~Schema),~Unit,~Exec.empty_plan(~Schema),~Exec.empty_dispatch(~S.World(~Schema)),~Exec.empty_provide(~Schema,~S.World(~Schema)),~AuditOps,~Unit,~B.AuditError,~P.Tree,~Cmp.Access<P.Tree>,~B.audit_query(~Schema),~B.audit,~B.render,~Output,done,failed,Exec.empty(~Schema,~S.World(~Schema),world),Unit{},"audit","audit")
def add_second(~Schema:Data,~Output:Type,done:Registered(~Schema) -> Output,failed:First(~Schema) -> P.Pack -> Output,first:First(~Schema)) -> Output:
  Captured.add(~Schema,~S.Store(~Schema),~Unit,~Unit,~FirstOwners(~Schema),~FirstRows(~Schema),~first_observe(~Schema),~first_fold(~Schema),~FirstError(),~first_plan(~Schema),~first_dispatch(~Schema),~first_provide(~Schema),~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body,~Output,done,failed,first,B.Args{1},"captured-query",P.initial(1))
def Scheduled(~Schema:Data) -> Type:Entry.Application<Schema,S.Store(~Schema),Unit,Unit,Owners(~Schema),Rows(~Schema),observe(~Schema),fold(~Schema),ErrorType(),plan(~Schema),dispatch(~Schema),provide(~Schema)>
def attach(~Schema:Data,app:Registered(~Schema)) -> Schedule.Attachment<Registered(~Schema),Scheduled(~Schema)>:
  Entry.attach(~Schema,~S.Store(~Schema),~Unit,~Unit,~Owners(~Schema),~Rows(~Schema),~observe(~Schema),~fold(~Schema),~ErrorType(),~plan(~Schema),~dispatch(~Schema),~provide(~Schema),S.schema(~Schema),app,"captured-query",False{})
def run(~Schema:Data,app:Scheduled(~Schema)) -> Execution.Run<Scheduled(~Schema),Schema,ErrorType()>:
  Entry.run(~Schema,~S.Store(~Schema),~Unit,~Unit,~Owners(~Schema),~Rows(~Schema),~observe(~Schema),~fold(~Schema),~ErrorType(),~plan(~Schema),~dispatch(~Schema),~provide(~Schema),app)
def retry_owners(~Schema:Data,value:Owners(~Schema),args:B.Args) -> Owners(~Schema):
  match value:
    case (prior,invocation):(prior,Captured.with_arguments(~Schema,~S.Store(~Schema),~Unit,~Unit,~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body,invocation,args))
# A completed error consumes the lifecycle run tick as in Bevy. Retry therefore
# supplies a new component-change input instead of rewinding the reader cursor.
def requeue_for_retry(~Schema:Data,app:Scheduled(~Schema)) -> Scheduled(~Schema):
  match app:
    case Entry.Application{Schedule.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},selected,ns,name,steps,needs},execution}:Entry.Application{Schedule.Application{SchemaApp.Application{schema,Build.Registered{S.refresh(~Schema,world),owners,recipe,debug}},selected,ns,name,steps,needs},execution}
def retry(~Schema:Data,app:Scheduled(~Schema)) -> Scheduled(~Schema):
  requeue_for_retry(~Schema,Entry.update_owners(~Schema,~S.Store(~Schema),~Unit,~Unit,~Owners(~Schema),~Rows(~Schema),~observe(~Schema),~fold(~Schema),~ErrorType(),~plan(~Schema),~dispatch(~Schema),~provide(~Schema),~B.Args,~retry_owners(~Schema),app,B.Args{999}))
