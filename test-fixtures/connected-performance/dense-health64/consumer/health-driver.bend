import Base
import health.bend as F
import ../../dense-motion64/consumer/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import ../../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/ordinary-app-run.bend as EntryApp
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/ordinary-app-schema.bend as SchemaApp
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../src/ecs/ordinary-app-execution.bend as Execute
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/schema-fragments.bend as Fragment
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/execution-context.bend as Ctx

import health-logical.bend as Logical
import ../../../../src/ecs/ordinary-query-observable.bend as Observable
import ../../../../src/ecs/ordinary-app-component.bend as Component
import ../../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../src/ecs/inspector.bend as Inspector
import ../../../../src/ecs/captured-schedule-composition.bend as Choice

type Audit is Data:
  Audit{values:List<&2,U32>,readsum:U32,updated:Nat}
type Status is Data:
  Succeeded{}
  Failed{error:Q.Error<Unit>}
  Rejected{cursor:U32}
type Shared is Type:
  Shared{audit:List<&2,Audit>,statuses:List<&2,Status>}
def query() -> Observable.Declaration<T.HealthSchema,Q.Frame<T.HealthSchema,F.Store(),F.Resources(),Nat>,F.Ops(Q.Frame<T.HealthSchema,F.Store(),F.Resources(),Nat>),Inspector.Frame<T.HealthSchema,F.Store(),F.Resources(),Nat>,Logical.Value()>:
  Observable.Declaration{_=>F.declaration(),_=>Observable.inspection(~T.HealthSchema,~Logical.Frame(),~Logical.Ops(Logical.Frame()),~Logical.InspectFrame(),~Logical.Value(),Logical.declaration())}
def render(value:Logical.Value()) -> String:"Dense row"
def Registered() -> Type:Component.Application(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Unit,~Unit,~Build.empty_observe(~F.World()),~Leaf.empty(~T.HealthSchema),~Unit,~Exec.empty_plan(~T.HealthSchema),~Exec.empty_dispatch(~F.World()),~Exec.empty_provide(~T.HealthSchema,~F.World()),~F.Ops,~Unit,~Unit,~U32,~Logical.Value(),~query(),~F.body,~render)
def Runtime() -> Type:Component.execution_owners(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Unit,~Unit,~Build.empty_observe(~F.World()),~Leaf.empty(~T.HealthSchema),~Unit,~Exec.empty_plan(~T.HealthSchema),~Exec.empty_dispatch(~F.World()),~Exec.empty_provide(~T.HealthSchema,~F.World()),~F.Ops,~Unit,~Unit,~U32,~Logical.Value(),~query(),~F.body,~render)
def Rows() -> Data:Component.execution_rows(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Unit,~Unit,~Build.empty_observe(~F.World()),~Leaf.empty(~T.HealthSchema),~Unit,~Exec.empty_plan(~T.HealthSchema),~Exec.empty_dispatch(~F.World()),~Exec.empty_provide(~T.HealthSchema,~F.World()),~F.Ops,~Unit,~Unit,~U32,~Logical.Value(),~query(),~F.body,~render)
def ErrorType() -> Data:Choice.Choice<Unit,Component.ExecutionError<Unit>>
def observe() -> F.World() -> F.World() & DTO.Observation<Rows()>:Component.execution_observe(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Unit,~Unit,~Build.empty_observe(~F.World()),~Leaf.empty(~T.HealthSchema),~Unit,~Exec.empty_plan(~T.HealthSchema),~Exec.empty_dispatch(~F.World()),~Exec.empty_provide(~T.HealthSchema,~F.World()),~F.Ops,~Unit,~Unit,~U32,~Logical.Value(),~query(),~F.body,~render)
def fold() -> Runtime() -> Runtime() & List<&2,Fields.Fields<T.HealthSchema>>:Component.execution_fold(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Unit,~Unit,~Build.empty_observe(~F.World()),~Leaf.empty(~T.HealthSchema),~Unit,~Exec.empty_plan(~T.HealthSchema),~Exec.empty_dispatch(~F.World()),~Exec.empty_provide(~T.HealthSchema,~F.World()),~F.Ops,~Unit,~Unit,~U32,~Logical.Value(),~query(),~F.body,~render)
def plan() -> Runtime() -> Runtime() & SP.Plan<T.HealthSchema>:Component.execution_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Unit,~Unit,~Build.empty_observe(~F.World()),~Leaf.empty(~T.HealthSchema),~Unit,~Exec.empty_plan(~T.HealthSchema),~Exec.empty_dispatch(~F.World()),~Exec.empty_provide(~T.HealthSchema,~F.World()),~F.Ops,~Unit,~Unit,~U32,~Logical.Value(),~query(),~F.body,~render)
def dispatch() -> Runtime() -> Ctx.Context<F.World()> -> U32 -> Runtime() & Sys.Outcome<Ctx.Context<F.World()>,ErrorType(),Unit>:Component.execution_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Unit,~Unit,~Build.empty_observe(~F.World()),~Leaf.empty(~T.HealthSchema),~Unit,~Exec.empty_plan(~T.HealthSchema),~Exec.empty_dispatch(~F.World()),~Exec.empty_provide(~T.HealthSchema,~F.World()),~F.Ops,~Unit,~Unit,~U32,~Logical.Value(),~query(),~F.body,~render)
def provide() -> F.World() -> F.World() & List<&2,SP.Requirement<T.HealthSchema>>:Component.execution_provide(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Unit,~Unit,~Build.empty_observe(~F.World()),~Leaf.empty(~T.HealthSchema),~Unit,~Exec.empty_plan(~T.HealthSchema),~Exec.empty_dispatch(~F.World()),~Exec.empty_provide(~T.HealthSchema,~F.World()),~F.Ops,~Unit,~Unit,~U32,~Logical.Value(),~query(),~F.body,~render)
def Registry() -> Type:Sys.Registry<T.HealthSchema,F.Store(),F.Resources(),Nat,Unit & U32,Q.Error<Unit>,List<&2,U32>,Ordinary.observable_runner(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~F.Ops,~Unit,~Unit,~U32,~Logical.Value(),~query(),~F.body)>
def Owner() -> Type:Exec.Invocation<T.HealthSchema,Fields.Token<Registry()>,Unit,U32>
def Application() -> Type:EntryApp.Application<T.HealthSchema,F.Store(),F.Resources(),Nat,Runtime(),Rows(),observe(),fold(),ErrorType(),plan(),dispatch(),provide()>
def Slot() -> Type:Single.Attachment<Registered(),Application()>
type State is Type:
  State{app:Slot(),shared:Shared}
type View is Type:
  View{world:F.World(),owner:Owner(),audit:List<&2,Audit>,statuses:List<&2,Status>}
type Defined is Type:
  Defined{state:State}
  Refused{world:F.World()}
def total(values:List<&2,U32>) -> U32:
  match values:
    case []:0
    case head <> tail:U32.add(head,total(tail))
def schema() -> Schema.Schema<T.HealthSchema,F.Store(),F.Resources()>:
  Schema.Schema{List.append(&2,Fragment.Entry<T.HealthSchema>,Schema.entries(~T.HealthSchema,~Col.Column<T.HealthSchema,T.Vitals>,~Unit,Schema.component(~T.HealthSchema,~T.Vitals,F.main_identity())),List.append(&2,Fragment.Entry<T.HealthSchema>,Schema.entries(~T.HealthSchema,~Col.Column<T.HealthSchema,T.Armor>,~Unit,Schema.component(~T.HealthSchema,~T.Armor,F.aux_identity())),List.append(&2,Fragment.Entry<T.HealthSchema>,Schema.entries(~T.HealthSchema,~Col.Column<T.HealthSchema,T.Tracked>,~Unit,Schema.component(~T.HealthSchema,~T.Tracked,F.flag_identity())),Schema.entries(~T.HealthSchema,~Unit,~T.HealthLedger,Schema.resource_schema(~T.HealthSchema,~T.HealthLedger,F.ledger_identity())))))}
def attached(app:Registered()) -> Defined:Defined{State{EntryApp.attach(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Runtime(),~Rows(),~observe(),~fold(),~ErrorType(),~plan(),~dispatch(),~provide(),schema(),app,"Dense",False{}),Shared{[],[]}}}
def refused(value:Exec.Registered<T.HealthSchema,F.World(),Unit,Unit,Build.empty_observe(~F.World()),Leaf.empty(~T.HealthSchema),Unit,Exec.empty_plan(~T.HealthSchema),Exec.empty_dispatch(~F.World()),Exec.empty_provide(~T.HealthSchema,~F.World())>) -> Defined:
  match value:
    case Exec.Registered{Build.Registered{world,_,_,_},_}:Refused{world}
def define(world:F.World()) -> Defined:Component.add(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Unit,~Unit,~Build.empty_observe(~F.World()),~Leaf.empty(~T.HealthSchema),~Unit,~Exec.empty_plan(~T.HealthSchema),~Exec.empty_dispatch(~F.World()),~Exec.empty_provide(~T.HealthSchema,~F.World()),~F.Ops,~Unit,~Unit,~U32,~Logical.Value(),~query(),~F.body,~render,~Defined,attached,refused,Exec.empty(~T.HealthSchema,~F.World(),world),Unit{},"BenchUpdate","dense64")
def live_view(~Output:Data,schema:Schema.Schema<T.HealthSchema,F.Store(),F.Resources()>,recipe:Tree.Recipe<F.World(),Rows(),observe()>,debug:Bool,plan:SP.Plan<T.HealthSchema>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<T.HealthSchema>>,result:View & Output) -> State & Output:
  match result:
    case (View{world,owner,audit,statuses},text):(State{Single.Attached{EntryApp.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,(Unit{},owner),recipe,debug}},plan,namespace,name,steps,needs},Exec.Recipe{}}},Shared{audit,statuses}},text)
def invalid_view(~Output:Data,recipe:Tree.Recipe<F.World(),Rows(),observe()>,debug:Bool,result:View & Output) -> State & Output:
  match result:
    case (View{world,owner,audit,statuses},text):(State{Single.Invalid{Exec.Registered{Build.Registered{world,(Unit{},owner),recipe,debug},Exec.Recipe{}}},Shared{audit,statuses}},text)
def inspect(~Output:Data,project:View -> View & Output,state:State) -> State & Output:
  match state:
    case State{Single.Attached{EntryApp.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,(_,owner),recipe,debug}},plan,namespace,name,steps,needs},_}},Shared{audit,statuses}}:live_view(~Output,schema,recipe,debug,plan,namespace,name,steps,needs,project(View{world,owner,audit,statuses}))
    case State{Single.Invalid{Exec.Registered{Build.Registered{world,(_,owner),recipe,debug},_}},Shared{audit,statuses}}:invalid_view(~Output,recipe,debug,project(View{world,owner,audit,statuses}))
def success_view(value:View) -> View & Unit:
  match value:
    case View{world,Exec.Invocation{record,args,+outputs},audit,statuses}:(View{world,Exec.Invocation{record,args,outputs},List.append(&2,Audit,audit,[Audit{outputs,total(outputs),List.length(&2,U32,outputs)}]),List.append(&2,Status,statuses,[Succeeded{}])},Unit{})
def failed_view(error:Q.Error<Unit>,value:View) -> View & Unit:
  match value:
    case View{world,owner,audit,statuses}:(View{world,owner,audit,List.append(&2,Status,statuses,[Failed{error}])},Unit{})
def field_cursor(fields:Fields.Fields<T.HealthSchema>) -> U32:
  match fields:
    case Fields.Fields{_,_,_,_,cursor,_,_,_}:cursor
def rejected_view(value:View) -> View & Unit:
  match value:
    case View{world,Exec.Invocation{Leaf.Record{token,+fields},args,outputs},audit,statuses}:(View{world,Exec.Invocation{Leaf.Record{token,fields},args,outputs},audit,List.append(&2,Status,statuses,[Rejected{field_cursor(fields)}])},Unit{})
def error_view(error:ErrorType(),value:View) -> View & Unit:
  match error:
    case Choice.LeftError{_}:failed_view(Q.UserError{Unit{}},value)
    case Choice.RightError{Component.CallbackFailure{error}}:failed_view(error,value)
    case Choice.RightError{Component.RegistrationRefused{}}:rejected_view(value)
def finished_state(result:State & Unit) -> State:
  match result:
    case (state,_):state
def returned(shared:Shared,result:Single.RunResult<Application(),T.HealthSchema,ErrorType()>) -> State:
  match result:
    case Single.Finished{app,_}:finished_state(inspect(~Unit,success_view,State{Single.Attached{app},shared}))
    case Single.Failed{app,error,_}:finished_state(inspect(~Unit,error_view(error),State{Single.Attached{app},shared}))
    case Single.Rejected{app}:State{Single.Attached{app},shared}
    case Single.Missing{app,_}:State{Single.Attached{app},shared}
def executed(shared:Shared,result:Execute.Run<Application(),T.HealthSchema,ErrorType()>) -> State:
  match result:
    case Execute.Run{result,_}:returned(shared,result)
def step(state:State) -> State:
  match state:
    case State{Single.Attached{app},shared}:executed(shared,EntryApp.run(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Runtime(),~Rows(),~observe(),~fold(),~ErrorType(),~plan(),~dispatch(),~provide(),app))
    case state:state
def loops(fuel:Nat,state:State) -> State:
  match fuel:
    case 0n:state
    case 1n+rest:loops(rest,step(state))
