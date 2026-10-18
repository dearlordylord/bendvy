import Base
import motion-audit.bend as Audit
import motion-resources.bend as Resources
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-service-request.bend as Request
import /tmp/bendvy-failedtxn-matched-method/src/ecs/schema-fragments.bend as Fragment
import motion.bend as F
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import events.bend as E
import motion-systems.bend as S
import motion-schedule.bend as Schedule
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-app-run.bend as Entry
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-app-schedule.bend as Single
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-app-schema.bend as SchemaApp
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-app-composer.bend as Build
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-app-execution-recipe.bend as Exec
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-app-existing-execution.bend as Existing
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-app-recipe.bend as Tree
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-schema.bend as Schema
import /tmp/bendvy-failedtxn-matched-method/src/ecs/column.bend as Col
import /tmp/bendvy-failedtxn-matched-method/src/ecs/schedule-provision.bend as SP
import /tmp/bendvy-failedtxn-matched-method/src/ecs/schedule.bend as Sch
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-app-execution.bend as Execute

def Application() -> Type:Entry.Application<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),S.Runtime(),Unit,Build.empty_observe(~F.World()),Schedule.fold,Unit,Schedule.plan,Schedule.dispatch,Schedule.provision>
def Registered() -> Type:Exec.Registered<T.MotionSchema,F.World(),S.Runtime(),Unit,Build.empty_observe(~F.World()),Schedule.fold,Unit,Schedule.plan,Schedule.dispatch,Schedule.provision>
def Slot() -> Type:Single.Attachment<Registered(),Application()>
def with_audit(entries:List<&2,Fragment.Entry<T.MotionSchema>>) -> List<&2,Fragment.Entry<T.MotionSchema>>:
  List.append(&2,Fragment.Entry<T.MotionSchema>,entries,[Request.declaration_entry(~T.MotionSchema,~Resources.Resources(),~Resources.Audit,~T.MotionLedger,~String,~Unit,~Audit.identity(),~Resources.take_audit,~Resources.put_audit,~Resources.record,Audit.declaration())])
def with_resources(entries:List<&2,Fragment.Entry<T.MotionSchema>>) -> Schema.Schema<T.MotionSchema,F.Store(),F.Resources()>:
  Schema.Schema{List.append(&2,Fragment.Entry<T.MotionSchema>,entries,with_audit(Schema.entries(~T.MotionSchema,~Unit,~T.MotionLedger,Schema.resource_schema(~T.MotionSchema,~T.MotionLedger,Schema.resource(~T.MotionSchema,~T.MotionLedger,"MotionLedger")))))}
def schema() -> Schema.Schema<T.MotionSchema,F.Store(),F.Resources()>:
  with_resources(List.append(&2,Fragment.Entry<T.MotionSchema>,Schema.entries(~T.MotionSchema,~Col.Column<T.MotionSchema,T.Position>,~Unit,Schema.component(~T.MotionSchema,~T.Position,F.main_identity())),List.append(&2,Fragment.Entry<T.MotionSchema>,Schema.entries(~T.MotionSchema,~Col.Column<T.MotionSchema,T.Velocity>,~Unit,Schema.component(~T.MotionSchema,~T.Velocity,F.aux_identity())),Schema.entries(~T.MotionSchema,~Col.Column<T.MotionSchema,T.Selected>,~Unit,Schema.component(~T.MotionSchema,~T.Selected,F.flag_identity())))))
def registered(world:F.World(),owners:S.Runtime()) -> Registered():
  Existing.registered(~T.MotionSchema,~F.World(),~S.Runtime(),~Schedule.fold,~Unit,~Schedule.plan,~Schedule.dispatch,~Schedule.provision,world,owners)
def create(world:F.World(),owners:S.Runtime()) -> Slot():
  Entry.attach(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~S.Runtime(),~Unit,~Build.empty_observe(~F.World()),~Schedule.fold,~Unit,~Schedule.plan,~Schedule.dispatch,~Schedule.provision,schema(),registered(world,owners),"FailedTxn/phase0",False{})
def replan(app:Application(),name:String) -> Slot():Entry.replan(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~S.Runtime(),~Unit,~Build.empty_observe(~F.World()),~Schedule.fold,~Unit,~Schedule.plan,~Schedule.dispatch,~Schedule.provision,app,name,False{})
def run(app:Application()) -> Execute.Run<Application(),T.MotionSchema,Unit>:Entry.run(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~S.Runtime(),~Unit,~Build.empty_observe(~F.World()),~Schedule.fold,~Unit,~Schedule.plan,~Schedule.dispatch,~Schedule.provision,app)
def update(~Args:Type,~modify:S.Runtime() -> Args -> S.Runtime(),app:Application(),args:Args) -> Application():Entry.update_owners(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~S.Runtime(),~Unit,~Build.empty_observe(~F.World()),~Schedule.fold,~Unit,~Schedule.plan,~Schedule.dispatch,~Schedule.provision,~Args,~modify,app,args)
def projected_live(~Value:Data,schema:Schema.Schema<T.MotionSchema,F.Store(),F.Resources()>,recipe:Tree.Recipe<F.World(),Unit,Build.empty_observe(~F.World())>,debug:Bool,plan:SP.Plan<T.MotionSchema>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<T.MotionSchema>>,result:F.World() & (S.Runtime() & Value)) -> Slot() & Value:
  match result:
    case (world,(owners,value)):(Single.Attached{Entry.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},Exec.Recipe{}}},value)
def projected_invalid(~Value:Data,recipe:Tree.Recipe<F.World(),Unit,Build.empty_observe(~F.World())>,debug:Bool,result:F.World() & (S.Runtime() & Value)) -> Slot() & Value:
  match result:
    case (world,(owners,value)):(Single.Invalid{Exec.Registered{Build.Registered{world,owners,recipe,debug},Exec.Recipe{}}},value)
def project(~Args:Type,~Value:Data,~observe:F.World() -> S.Runtime() -> Args -> F.World() & (S.Runtime() & Value),slot:Slot(),args:Args) -> Slot() & Value:
  match slot:
    case Single.Attached{Entry.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},_}}:projected_live(~Value,schema,recipe,debug,plan,namespace,name,steps,needs,observe(world,owners,args))
    case Single.Invalid{Exec.Registered{Build.Registered{world,owners,recipe,debug},_}}:projected_invalid(~Value,recipe,debug,observe(world,owners,args))
def describe(app:Application()) -> Application() & (U32 & (String & (List<&2,Sch.Step> & List<&2,SP.Requirement<T.MotionSchema>>))):
  match app:
    case Entry.Application{Single.Application{base,plan,+namespace,+name,+steps,+needs},execution}:(Entry.Application{Single.Application{base,plan,namespace,name,steps,needs},execution},(namespace,(name,(steps,needs))))
