import Base
import health-audit.bend as Audit
import health-resources.bend as Resources
import ../../../../../../../src/ecs/ordinary-service-request.bend as Request
import ../../../../../../../src/ecs/schema-fragments.bend as Fragment
import health.bend as F
import ../../../../dense-runtime-v1/types.bend as T
import health-events.bend as E
import health-systems.bend as S
import health-schedule.bend as Schedule
import ../../../../../../../src/ecs/ordinary-app-run.bend as Entry
import ../../../../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../../../../src/ecs/ordinary-app-schema.bend as SchemaApp
import ../../../../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../../../../src/ecs/ordinary-app-existing-execution.bend as Existing
import ../../../../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../src/ecs/schedule-provision.bend as SP
import ../../../../../../../src/ecs/schedule.bend as Sch
import ../../../../../../../src/ecs/ordinary-app-execution.bend as Execute

def Application() -> Type:Entry.Application<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),S.Runtime(),Unit,Build.empty_observe(~F.World()),Schedule.fold,Unit,Schedule.plan,Schedule.dispatch,Schedule.provision>
def Registered() -> Type:Exec.Registered<T.HealthSchema,F.World(),S.Runtime(),Unit,Build.empty_observe(~F.World()),Schedule.fold,Unit,Schedule.plan,Schedule.dispatch,Schedule.provision>
def Slot() -> Type:Single.Attachment<Registered(),Application()>
def with_audit(entries:List<&2,Fragment.Entry<T.HealthSchema>>) -> List<&2,Fragment.Entry<T.HealthSchema>>:
  List.append(&2,Fragment.Entry<T.HealthSchema>,entries,[Request.declaration_entry(~T.HealthSchema,~Resources.Resources(),~Resources.Audit,~T.HealthLedger,~String,~Unit,~Audit.identity(),~Resources.take_audit,~Resources.put_audit,~Resources.record,Audit.declaration())])
def with_resources(entries:List<&2,Fragment.Entry<T.HealthSchema>>) -> Schema.Schema<T.HealthSchema,F.Store(),F.Resources()>:
  Schema.Schema{List.append(&2,Fragment.Entry<T.HealthSchema>,entries,with_audit(Schema.entries(~T.HealthSchema,~Unit,~T.HealthLedger,Schema.resource_schema(~T.HealthSchema,~T.HealthLedger,Schema.resource(~T.HealthSchema,~T.HealthLedger,"HealthLedger")))))}
def schema() -> Schema.Schema<T.HealthSchema,F.Store(),F.Resources()>:
  with_resources(List.append(&2,Fragment.Entry<T.HealthSchema>,Schema.entries(~T.HealthSchema,~Col.Column<T.HealthSchema,T.Vitals>,~Unit,Schema.component(~T.HealthSchema,~T.Vitals,F.main_identity())),List.append(&2,Fragment.Entry<T.HealthSchema>,Schema.entries(~T.HealthSchema,~Col.Column<T.HealthSchema,T.Armor>,~Unit,Schema.component(~T.HealthSchema,~T.Armor,F.aux_identity())),Schema.entries(~T.HealthSchema,~Col.Column<T.HealthSchema,T.Tracked>,~Unit,Schema.component(~T.HealthSchema,~T.Tracked,F.flag_identity())))))
def registered(world:F.World(),owners:S.Runtime()) -> Registered():
  Existing.registered(~T.HealthSchema,~F.World(),~S.Runtime(),~Schedule.fold,~Unit,~Schedule.plan,~Schedule.dispatch,~Schedule.provision,world,owners)
def create(world:F.World(),owners:S.Runtime()) -> Slot():
  Entry.attach(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~S.Runtime(),~Unit,~Build.empty_observe(~F.World()),~Schedule.fold,~Unit,~Schedule.plan,~Schedule.dispatch,~Schedule.provision,schema(),registered(world,owners),"FailedTxn/phase0",False{})
def replan(app:Application(),name:String) -> Slot():Entry.replan(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~S.Runtime(),~Unit,~Build.empty_observe(~F.World()),~Schedule.fold,~Unit,~Schedule.plan,~Schedule.dispatch,~Schedule.provision,app,name,False{})
def run(app:Application()) -> Execute.Run<Application(),T.HealthSchema,Unit>:Entry.run(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~S.Runtime(),~Unit,~Build.empty_observe(~F.World()),~Schedule.fold,~Unit,~Schedule.plan,~Schedule.dispatch,~Schedule.provision,app)
def update(~Args:Type,~modify:S.Runtime() -> Args -> S.Runtime(),app:Application(),args:Args) -> Application():Entry.update_owners(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~S.Runtime(),~Unit,~Build.empty_observe(~F.World()),~Schedule.fold,~Unit,~Schedule.plan,~Schedule.dispatch,~Schedule.provision,~Args,~modify,app,args)
def projected_live(~Value:Data,schema:Schema.Schema<T.HealthSchema,F.Store(),F.Resources()>,recipe:Tree.Recipe<F.World(),Unit,Build.empty_observe(~F.World())>,debug:Bool,plan:SP.Plan<T.HealthSchema>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<T.HealthSchema>>,result:F.World() & (S.Runtime() & Value)) -> Slot() & Value:
  match result:
    case (world,(owners,value)):(Single.Attached{Entry.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},Exec.Recipe{}}},value)
def projected_invalid(~Value:Data,recipe:Tree.Recipe<F.World(),Unit,Build.empty_observe(~F.World())>,debug:Bool,result:F.World() & (S.Runtime() & Value)) -> Slot() & Value:
  match result:
    case (world,(owners,value)):(Single.Invalid{Exec.Registered{Build.Registered{world,owners,recipe,debug},Exec.Recipe{}}},value)
def project(~Args:Type,~Value:Data,~observe:F.World() -> S.Runtime() -> Args -> F.World() & (S.Runtime() & Value),slot:Slot(),args:Args) -> Slot() & Value:
  match slot:
    case Single.Attached{Entry.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},_}}:projected_live(~Value,schema,recipe,debug,plan,namespace,name,steps,needs,observe(world,owners,args))
    case Single.Invalid{Exec.Registered{Build.Registered{world,owners,recipe,debug},_}}:projected_invalid(~Value,recipe,debug,observe(world,owners,args))
def describe(app:Application()) -> Application() & (U32 & (String & (List<&2,Sch.Step> & List<&2,SP.Requirement<T.HealthSchema>>))):
  match app:
    case Entry.Application{Single.Application{base,plan,+namespace,+name,+steps,+needs},execution}:(Entry.Application{Single.Application{base,plan,namespace,name,steps,needs},execution},(namespace,(name,(steps,needs))))
