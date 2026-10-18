import Base
import motion.bend as F
import types.bend as T
import ../../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/ordinary-app-run.bend as EntryApp
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/ordinary-app-schema.bend as SchemaApp
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../src/ecs/ordinary-app-existing-execution.bend as Existing
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../src/ecs/ordinary-app-execution.bend as Execute
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/schema-fragments.bend as Fragment
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/execution-context.bend as Ctx
import ../../../../src/ecs/trace-facts.bend as Facts

type Audit is Data:
  Audit{values:List<&2,U32>,readsum:U32,updated:Nat}
type Status is Data:
  Succeeded{}
  Failed{error:Q.Error<Unit>}
  Rejected{cursor:U32}
type Shared is Type:
  Shared{audit:List<&2,Audit>,statuses:List<&2,Status>}
def Runtime() -> Type:F.Owner() & Shared
def Application() -> Type:EntryApp.Application<T.MotionSchema,F.Store(),F.Resources(),Nat,Runtime(),Unit,Build.empty_observe(~F.World()),fold,Q.Error<Unit>,plan,dispatch,provide>
def Registered() -> Type:Exec.Registered<T.MotionSchema,F.World(),Runtime(),Unit,Build.empty_observe(~F.World()),fold,Q.Error<Unit>,plan,dispatch,provide>
def Slot() -> Type:Single.Attachment<Registered(),Application()>
type State is Type:
  State{app:Slot()}
type View is Type:
  View{world:F.World(),owner:F.Owner(),audit:List<&2,Audit>,statuses:List<&2,Status>}
def total(values:List<&2,U32>) -> U32:
  match values:
    case []:0
    case head <> tail:U32.add(head,total(tail))
def catalogued(result:Fields.Token<F.Registry()> & Fields.Fields<T.MotionSchema>) -> F.Owner() & Fields.Fields<T.MotionSchema>:
  match result:
    case (token,+fields):(Fields.restore_component(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~(Unit & U32),~Q.Error<Unit>,~List<&2,U32>,~Ordinary.runner(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.Ops,~Unit,~Unit,~U32,~F.declaration(),~F.body),token,fields),fields)
def catalog(owner:F.Owner()) -> F.Owner() & Fields.Fields<T.MotionSchema>:catalogued(Fields.component(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~(Unit & U32),~Q.Error<Unit>,~List<&2,U32>,~Ordinary.runner(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.Ops,~Unit,~Unit,~U32,~F.declaration(),~F.body),owner))
def fold(value:Runtime()) -> Runtime() & List<&2,Fields.Fields<T.MotionSchema>>:Existing.fold(~T.MotionSchema,~F.Owner(),~Shared,~catalog,value)
def enabled(shared:Shared) -> Shared & Bool:(shared,True{})
def plan(value:Runtime()) -> Runtime() & SP.Plan<T.MotionSchema>:Existing.plan(~T.MotionSchema,~F.Owner(),~Shared,~catalog,~enabled,~[],value)
def provide(world:F.World()) -> F.World() & List<&2,SP.Requirement<T.MotionSchema>>:(world,[])
def completed(trace:Facts.State,shared:Shared,slot:String,clauses:List<&2,Decl.Clause<T.MotionSchema>>,result:Sys.RunResult<T.MotionSchema,F.Store(),F.Resources(),Nat,Unit & U32,Q.Error<Unit>,List<&2,U32>,Ordinary.runner(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.Ops,~Unit,~Unit,~U32,~F.declaration(),~F.body)>) -> F.Owner() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Q.Error<Unit>,Unit>):
  match shared result:
    case Shared{audit,statuses},Sys.Completed{registry,Sys.Succeeded{world,+values}}:(Ordinary.Owner{registry,slot,clauses},(Shared{List.append(&2,Audit,audit,[Audit{values,total(values),List.length(&2,U32,values)}]),List.append(&2,Status,statuses,[Succeeded{}])},Sys.Succeeded{Ctx.Context{world,trace},Unit{}}))
    case Shared{audit,statuses},Sys.Completed{registry,Sys.Failed{world,+error}}:(Ordinary.Owner{registry,slot,clauses},(Shared{audit,List.append(&2,Status,statuses,[Failed{error}])},Sys.Failed{Ctx.Context{world,trace},error}))
    case Shared{audit,statuses},Sys.RegistrationRejected{registry,world,(_,cursor)}:(Ordinary.Owner{registry,slot,clauses},(Shared{audit,List.append(&2,Status,statuses,[Rejected{cursor}])},Sys.Failed{Ctx.Context{world,trace},Q.UserError{Unit{}}}))
def ran(trace:Facts.State,shared:Shared,observed:Sys.RunResult<T.MotionSchema,F.Store(),F.Resources(),Nat,Unit & U32,Q.Error<Unit>,List<&2,U32>,Ordinary.runner(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.Ops,~Unit,~Unit,~U32,~F.declaration(),~F.body)> & (String & List<&2,Decl.Clause<T.MotionSchema>>)) -> F.Owner() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Q.Error<Unit>,Unit>):
  match observed:
    case (result,(slot,clauses)):completed(trace,shared,slot,clauses,result)
def invoke(owner:F.Owner(),shared:Shared,context:Ctx.Context<F.World()>) -> F.Owner() & (Shared & Sys.Outcome<Ctx.Context<F.World()>,Q.Error<Unit>,Unit>):
  match context:
    case Ctx.Context{world,trace}:ran(trace,shared,Ordinary.run(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.Ops,~Unit,~Unit,~U32,~F.declaration(),~F.body,owner,world,Unit{}))
def dispatch(value:Runtime(),context:Ctx.Context<F.World()>,id:U32) -> Runtime() & Sys.Outcome<Ctx.Context<F.World()>,Q.Error<Unit>,Unit>:Existing.dispatch(~T.MotionSchema,~F.World(),~F.Owner(),~Shared,~Q.Error<Unit>,~catalog,~invoke,~Q.UserError{Unit{}},value,context,id)
def schema() -> Schema.Schema<T.MotionSchema,F.Store(),F.Resources()>:
  Schema.Schema{List.append(&2,Fragment.Entry<T.MotionSchema>,Schema.entries(~T.MotionSchema,~Col.Column<T.MotionSchema,T.Position>,~Unit,Schema.component(~T.MotionSchema,~T.Position,F.main_identity())),List.append(&2,Fragment.Entry<T.MotionSchema>,Schema.entries(~T.MotionSchema,~Col.Column<T.MotionSchema,T.Velocity>,~Unit,Schema.component(~T.MotionSchema,~T.Velocity,F.aux_identity())),List.append(&2,Fragment.Entry<T.MotionSchema>,Schema.entries(~T.MotionSchema,~Col.Column<T.MotionSchema,T.Selected>,~Unit,Schema.component(~T.MotionSchema,~T.Selected,F.flag_identity())),Schema.entries(~T.MotionSchema,~Unit,~T.MotionLedger,Schema.resource_schema(~T.MotionSchema,~T.MotionLedger,F.ledger_identity())))))}
def start(world:F.World(),owner:F.Owner()) -> State:State{EntryApp.attach(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Runtime(),~Unit,~Build.empty_observe(~F.World()),~fold,~Q.Error<Unit>,~plan,~dispatch,~provide,schema(),Existing.registered(~T.MotionSchema,~F.World(),~Runtime(),~fold,~Q.Error<Unit>,~plan,~dispatch,~provide,world,(owner,Shared{[],[]})),"Dense",False{})}
def returned(result:Single.RunResult<Application(),T.MotionSchema,Q.Error<Unit>>) -> State:
  match result:
    case Single.Finished{app,_}:State{Single.Attached{app}}
    case Single.Failed{app,_,_}:State{Single.Attached{app}}
    case Single.Rejected{app}:State{Single.Attached{app}}
    case Single.Missing{app,_}:State{Single.Attached{app}}
def executed(result:Execute.Run<Application(),T.MotionSchema,Q.Error<Unit>>) -> State:
  match result:
    case Execute.Run{result,_}:returned(result)
def step(state:State) -> State:
  match state:
    case State{Single.Attached{app}}:executed(EntryApp.run(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Runtime(),~Unit,~Build.empty_observe(~F.World()),~fold,~Q.Error<Unit>,~plan,~dispatch,~provide,app))
    case state:state
def loops(fuel:Nat,state:State) -> State:
  match fuel:
    case 0n:state
    case 1n+rest:loops(rest,step(state))
def live_view(schema:Schema.Schema<T.MotionSchema,F.Store(),F.Resources()>,recipe:Tree.Recipe<F.World(),Unit,Build.empty_observe(~F.World())>,debug:Bool,plan:SP.Plan<T.MotionSchema>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<T.MotionSchema>>,result:View & String) -> State & String:
  match result:
    case (View{world,owner,audit,statuses},text):(State{Single.Attached{EntryApp.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,(owner,Shared{audit,statuses}),recipe,debug}},plan,namespace,name,steps,needs},Exec.Recipe{}}}},text)
def invalid_view(recipe:Tree.Recipe<F.World(),Unit,Build.empty_observe(~F.World())>,debug:Bool,result:View & String) -> State & String:
  match result:
    case (View{world,owner,audit,statuses},text):(State{Single.Invalid{Exec.Registered{Build.Registered{world,(owner,Shared{audit,statuses}),recipe,debug},Exec.Recipe{}}}},text)
def inspect(~observe:View -> View & String,state:State) -> State & String:
  match state:
    case State{Single.Attached{EntryApp.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,(owner,Shared{audit,statuses}),recipe,debug}},plan,namespace,name,steps,needs},_}}}:live_view(schema,recipe,debug,plan,namespace,name,steps,needs,observe(View{world,owner,audit,statuses}))
    case State{Single.Invalid{Exec.Registered{Build.Registered{world,(owner,Shared{audit,statuses}),recipe,debug},_}}}:invalid_view(recipe,debug,observe(View{world,owner,audit,statuses}))
