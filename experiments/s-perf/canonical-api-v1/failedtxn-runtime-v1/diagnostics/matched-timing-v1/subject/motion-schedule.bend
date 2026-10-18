import Base
import ../method.bend as Method
import /tmp/bendvy-failedtxn-matched-method/src/ecs/world.bend as World
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import motion.bend as F
import events.bend as E
import motion-local.bend as L
import motion-systems.bend as S
import motion-grants.bend as Grants
import motion-dispose.bend as Dispose
import motion-publications.bend as Publications
import motion-parameters.bend as Parameters
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-app-existing-execution.bend as Existing
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-app-registration-fields.bend as Fields
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-app-execution-recipe.bend as Exec
import /tmp/bendvy-failedtxn-matched-method/src/ecs/captured-schedule-composition.bend as Identity
import /tmp/bendvy-failedtxn-matched-method/src/ecs/execution-context.bend as Ctx
import /tmp/bendvy-failedtxn-matched-method/src/ecs/system.bend as Sys
import /tmp/bendvy-failedtxn-matched-method/src/ecs/schedule.bend as Sch
import /tmp/bendvy-failedtxn-matched-method/src/ecs/schedule-provision.bend as SP
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-service-declaration.bend as Service

def Locals() -> Type:L.Instance() & L.Instance()
def Others() -> Type:Publications.Provider() & Dispose.Registry()
def local_fields(owner:L.Instance()) -> L.Instance() & Fields.Fields<T.MotionSchema>:
  Existing.local_fields(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~L.State,~L.Args,~Empty,~L.Returned,~L.runner,owner)
def pub_fields(owner:Publications.Provider()) -> Publications.Provider() & Fields.Fields<T.MotionSchema>:
  Existing.reader_fields(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~Publications.Invocation(),~Empty,~Publications.Envelope(),~Publications.runner(),~Parameters.ping_owner(),~Parameters.ping_parameter_type(),~Unit,owner)
def dispose_fields(owner:Dispose.Registry()) -> Dispose.Registry() & Fields.Fields<T.MotionSchema>:
  Existing.system_fields(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~List<&2,World.Handle<T.MotionSchema>>,~Empty,~Dispose.Output,~Dispose.runner,owner)
def fold_a(value:L.Instance() & S.Shared) -> (L.Instance() & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.fold(~T.MotionSchema,~L.Instance(),~S.Shared,~local_fields,value)
def dispatch_a(value:L.Instance() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (L.Instance() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:
  Existing.dispatch(~T.MotionSchema,~F.World(),~L.Instance(),~S.Shared,~Unit,~local_fields,~S.invoke_a,~Unit{},value,context,id)
def fold_b(value:L.Instance() & S.Shared) -> (L.Instance() & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.fold(~T.MotionSchema,~L.Instance(),~S.Shared,~local_fields,value)
def dispatch_b(value:L.Instance() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (L.Instance() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:
  Existing.dispatch(~T.MotionSchema,~F.World(),~L.Instance(),~S.Shared,~Unit,~local_fields,~S.invoke_b,~Unit{},value,context,id)
def fold_pub(value:Publications.Provider() & S.Shared) -> (Publications.Provider() & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.fold(~T.MotionSchema,~Publications.Provider(),~S.Shared,~pub_fields,value)
def dispatch_pub(value:Publications.Provider() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (Publications.Provider() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:
  Existing.dispatch(~T.MotionSchema,~F.World(),~Publications.Provider(),~S.Shared,~Unit,~pub_fields,~S.invoke_pub,~Unit{},value,context,id)
def fold_dispose(value:Dispose.Registry() & S.Shared) -> (Dispose.Registry() & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.fold(~T.MotionSchema,~Dispose.Registry(),~S.Shared,~dispose_fields,value)
def dispatch_dispose(value:Dispose.Registry() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (Dispose.Registry() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:
  Existing.dispatch(~T.MotionSchema,~F.World(),~Dispose.Registry(),~S.Shared,~Unit,~dispose_fields,~S.invoke_dispose,~Unit{},value,context,id)
def fold_locals(value:(L.Instance() & L.Instance()) & S.Shared) -> ((L.Instance() & L.Instance()) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.pair_fold(~T.MotionSchema,~L.Instance(),~L.Instance(),~S.Shared,~fold_a,~fold_b,value)
def dispatch_locals(value:(L.Instance() & L.Instance()) & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> ((L.Instance() & L.Instance()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:
  Existing.pair_dispatch(~T.MotionSchema,~F.World(),~L.Instance(),~L.Instance(),~S.Shared,~Unit,~fold_a,~dispatch_a,~dispatch_b,value,context,id)
def fold_others(value:(Publications.Provider() & Dispose.Registry()) & S.Shared) -> ((Publications.Provider() & Dispose.Registry()) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.pair_fold(~T.MotionSchema,~Publications.Provider(),~Dispose.Registry(),~S.Shared,~fold_pub,~fold_dispose,value)
def dispatch_others(value:(Publications.Provider() & Dispose.Registry()) & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> ((Publications.Provider() & Dispose.Registry()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:
  Existing.pair_dispatch(~T.MotionSchema,~F.World(),~Publications.Provider(),~Dispose.Registry(),~S.Shared,~Unit,~fold_pub,~dispatch_pub,~dispatch_dispose,value,context,id)
def fold_all(value:(Locals() & Others()) & S.Shared) -> ((Locals() & Others()) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.pair_fold(~T.MotionSchema,~Locals(),~Others(),~S.Shared,~fold_locals,~fold_others,value)
def dispatch_all(value:(Locals() & Others()) & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> ((Locals() & Others()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:
  Existing.pair_dispatch(~T.MotionSchema,~F.World(),~Locals(),~Others(),~S.Shared,~Unit,~fold_locals,~dispatch_locals,~dispatch_others,value,context,id)
def selected(shared:S.Shared,phase:U32) -> S.Shared & U32:(shared,phase)
def phase(shared:S.Shared) -> S.Shared & U32:
  match shared:
    case S.Shared{meta,tick,S.Frame{first,second,iteration,+phase,pending,retry,failed,calls,method}}:selected(S.Shared{meta,tick,S.Frame{first,second,iteration,phase,pending,retry,failed,calls,method}},phase)
def selected_a(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+phase):(shared,U32.is_eq(phase,1))
def enabled_a(shared:S.Shared) -> S.Shared & Bool:selected_a(phase(shared))
def selected_b(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+phase):(shared,Bool.or(U32.is_eq(phase,0),Bool.or(U32.is_eq(phase,1),U32.is_eq(phase,3))))
def enabled_b(shared:S.Shared) -> S.Shared & Bool:selected_b(phase(shared))
def selected_pub(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+phase):(shared,Bool.or(U32.is_eq(phase,0),Bool.or(U32.is_eq(phase,2),U32.is_eq(phase,4))))
def enabled_pub(shared:S.Shared) -> S.Shared & Bool:selected_pub(phase(shared))
def selected_dispose(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+phase):(shared,U32.is_eq(phase,6))
def enabled_dispose(shared:S.Shared) -> S.Shared & Bool:selected_dispose(phase(shared))
def selected_barrier(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+phase):(shared,Bool.or(U32.is_eq(phase,5),U32.is_eq(phase,6)))
def enabled_barrier(shared:S.Shared) -> S.Shared & Bool:selected_barrier(phase(shared))
def plan_a(value:L.Instance() & S.Shared) -> (L.Instance() & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.plan(~T.MotionSchema,~L.Instance(),~S.Shared,~local_fields,~enabled_a,~[Grants.required()],value)
def plan_b(value:L.Instance() & S.Shared) -> (L.Instance() & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.plan(~T.MotionSchema,~L.Instance(),~S.Shared,~local_fields,~enabled_b,~[Grants.required()],value)
def plan_pub(value:Publications.Provider() & S.Shared) -> (Publications.Provider() & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.plan(~T.MotionSchema,~Publications.Provider(),~S.Shared,~pub_fields,~enabled_pub,~[],value)
def plan_dispose(value:Dispose.Registry() & S.Shared) -> (Dispose.Registry() & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.plan(~T.MotionSchema,~Dispose.Registry(),~S.Shared,~dispose_fields,~enabled_dispose,~[],value)
def plan_locals(value:(L.Instance() & L.Instance()) & S.Shared) -> ((L.Instance() & L.Instance()) & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.pair_plan(~T.MotionSchema,~L.Instance(),~L.Instance(),~S.Shared,~plan_a,~plan_b,value)
def plan_others(value:(Publications.Provider() & Dispose.Registry()) & S.Shared) -> ((Publications.Provider() & Dispose.Registry()) & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.pair_plan(~T.MotionSchema,~Publications.Provider(),~Dispose.Registry(),~S.Shared,~plan_pub,~plan_dispose,value)
def plan_all(value:(Locals() & Others()) & S.Shared) -> ((Locals() & Others()) & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.pair_plan(~T.MotionSchema,~Locals(),~Others(),~S.Shared,~plan_locals,~plan_others,value)
def plan(value:S.Runtime()) -> S.Runtime() & SP.Plan<T.MotionSchema>:
  Existing.after(~T.MotionSchema,~S.Owned(),~S.Shared,~plan_all,~enabled_barrier,value)
def fold(value:S.Runtime()) -> S.Runtime() & List<&2,Fields.Fields<T.MotionSchema>>:fold_all(value)
def dispatch(value:S.Runtime(),context:Ctx.Context<F.World()>,id:U32) -> S.Runtime() & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:dispatch_all(value,context,id)
def ids(fields:List<&2,Fields.Fields<T.MotionSchema>>) -> List<&2,U32>:Identity.ids(Exec.identities(~T.MotionSchema,fields))
def provided(result:F.World() & List<&2,Service.Status<T.MotionSchema>>) -> F.World() & List<&2,SP.Requirement<T.MotionSchema>>:
  match result:
    case (world,statuses):(world,Service.available(~T.MotionSchema,statuses))
def provision(world:F.World()) -> F.World() & List<&2,SP.Requirement<T.MotionSchema>>:provided(Grants.scan(world))
def step_text(value:Sch.Step) -> String:
  match value:
    case Sch.System{id,condition}:"System{" ++ U32.show(id) ++ ";" ++ U32.show(condition) ++ "}"
    case Sch.Phase{name}:"Phase{" ++ name ++ "}"
    case Sch.Barrier{}:"Barrier"
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered{" ++ name ++ "}"
    case Sch.Ran{id}:"Ran{" ++ U32.show(id) ++ "}"
    case Sch.Skipped{id}:"Skipped{" ++ U32.show(id) ++ "}"
    case Sch.Applied{}:"Applied"
