import Base
import ../method/method.bend as Method
import ../../../../src/ecs/world.bend as World
import ../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import health.bend as F
import health-events.bend as E
import health-local.bend as L
import health-systems.bend as S
import health-grants.bend as Grants
import health-dispose.bend as Dispose
import health-publications.bend as Publications
import health-parameters.bend as Parameters
import ../../../../src/ecs/ordinary-app-existing-adoption.bend as Adoption
import ../../../../src/ecs/ordinary-app-existing-execution.bend as Existing
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../src/ecs/captured-schedule-composition.bend as Identity
import ../../../../src/ecs/execution-context.bend as Ctx
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/ordinary-service-declaration.bend as Service

def Locals() -> Type:L.Instance() & L.Instance()
def Others() -> Type:Publications.Provider() & Dispose.Registry()
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
def fold_a() -> (L.Instance() & S.Shared) -> (L.Instance() & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:Adoption.local_fold(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~L.State,~L.Args,~Empty,~L.Returned,~L.runner,~S.Shared)
def plan_a() -> (L.Instance() & S.Shared) -> (L.Instance() & S.Shared) & SP.Plan<T.HealthSchema>:Adoption.local_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~L.State,~L.Args,~Empty,~L.Returned,~L.runner,~S.Shared,~enabled_a,~[Grants.required()])
def dispatch_a() -> (L.Instance() & S.Shared) -> Ctx.Context<F.World()> -> U32 -> (L.Instance() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Adoption.local_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~L.State,~L.Args,~Empty,~L.Returned,~L.runner,~S.Shared,~Unit,~S.invoke_a,~Unit{})
def fold_b() -> (L.Instance() & S.Shared) -> (L.Instance() & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:Adoption.local_fold(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~L.State,~L.Args,~Empty,~L.Returned,~L.runner,~S.Shared)
def plan_b() -> (L.Instance() & S.Shared) -> (L.Instance() & S.Shared) & SP.Plan<T.HealthSchema>:Adoption.local_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~L.State,~L.Args,~Empty,~L.Returned,~L.runner,~S.Shared,~enabled_b,~[Grants.required()])
def dispatch_b() -> (L.Instance() & S.Shared) -> Ctx.Context<F.World()> -> U32 -> (L.Instance() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Adoption.local_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~L.State,~L.Args,~Empty,~L.Returned,~L.runner,~S.Shared,~Unit,~S.invoke_b,~Unit{})
def fold_pub() -> (Publications.Provider() & S.Shared) -> (Publications.Provider() & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:Adoption.reader_fold(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Publications.Invocation(),~Empty,~Publications.Envelope(),~Publications.runner(),~Parameters.ping_owner(),~Parameters.ping_parameter_type(),~Unit,~S.Shared)
def plan_pub() -> (Publications.Provider() & S.Shared) -> (Publications.Provider() & S.Shared) & SP.Plan<T.HealthSchema>:Adoption.reader_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Publications.Invocation(),~Empty,~Publications.Envelope(),~Publications.runner(),~Parameters.ping_owner(),~Parameters.ping_parameter_type(),~Unit,~S.Shared,~enabled_pub,~[])
def dispatch_pub() -> (Publications.Provider() & S.Shared) -> Ctx.Context<F.World()> -> U32 -> (Publications.Provider() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Adoption.reader_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Publications.Invocation(),~Empty,~Publications.Envelope(),~Publications.runner(),~Parameters.ping_owner(),~Parameters.ping_parameter_type(),~Unit,~S.Shared,~Unit,~S.invoke_pub,~Unit{})
def fold_dispose() -> (Dispose.Registry() & S.Shared) -> (Dispose.Registry() & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:Adoption.system_fold(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~List<&2,World.Handle<T.HealthSchema>>,~Empty,~Dispose.Output,~Dispose.runner,~S.Shared)
def plan_dispose() -> (Dispose.Registry() & S.Shared) -> (Dispose.Registry() & S.Shared) & SP.Plan<T.HealthSchema>:Adoption.system_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~List<&2,World.Handle<T.HealthSchema>>,~Empty,~Dispose.Output,~Dispose.runner,~S.Shared,~enabled_dispose,~[])
def dispatch_dispose() -> (Dispose.Registry() & S.Shared) -> Ctx.Context<F.World()> -> U32 -> (Dispose.Registry() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Adoption.system_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~List<&2,World.Handle<T.HealthSchema>>,~Empty,~Dispose.Output,~Dispose.runner,~S.Shared,~Unit,~S.invoke_dispose,~Unit{})
def fold_locals() -> ((L.Instance() & L.Instance()) & S.Shared) -> ((L.Instance() & L.Instance()) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:Existing.pair_fold(~T.HealthSchema,~L.Instance(),~L.Instance(),~S.Shared,~fold_a(),~fold_b())
def plan_locals() -> ((L.Instance() & L.Instance()) & S.Shared) -> ((L.Instance() & L.Instance()) & S.Shared) & SP.Plan<T.HealthSchema>:Existing.pair_plan(~T.HealthSchema,~L.Instance(),~L.Instance(),~S.Shared,~plan_a(),~plan_b())
def dispatch_locals() -> ((L.Instance() & L.Instance()) & S.Shared) -> Ctx.Context<F.World()> -> U32 -> ((L.Instance() & L.Instance()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.pair_dispatch(~T.HealthSchema,~F.World(),~L.Instance(),~L.Instance(),~S.Shared,~Unit,~fold_a(),~dispatch_a(),~dispatch_b())
def fold_others() -> ((Publications.Provider() & Dispose.Registry()) & S.Shared) -> ((Publications.Provider() & Dispose.Registry()) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:Existing.pair_fold(~T.HealthSchema,~Publications.Provider(),~Dispose.Registry(),~S.Shared,~fold_pub(),~fold_dispose())
def plan_others() -> ((Publications.Provider() & Dispose.Registry()) & S.Shared) -> ((Publications.Provider() & Dispose.Registry()) & S.Shared) & SP.Plan<T.HealthSchema>:Existing.pair_plan(~T.HealthSchema,~Publications.Provider(),~Dispose.Registry(),~S.Shared,~plan_pub(),~plan_dispose())
def dispatch_others() -> ((Publications.Provider() & Dispose.Registry()) & S.Shared) -> Ctx.Context<F.World()> -> U32 -> ((Publications.Provider() & Dispose.Registry()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.pair_dispatch(~T.HealthSchema,~F.World(),~Publications.Provider(),~Dispose.Registry(),~S.Shared,~Unit,~fold_pub(),~dispatch_pub(),~dispatch_dispose())
def fold_all() -> ((Locals() & Others()) & S.Shared) -> ((Locals() & Others()) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:Existing.pair_fold(~T.HealthSchema,~Locals(),~Others(),~S.Shared,~fold_locals(),~fold_others())
def plan_all() -> ((Locals() & Others()) & S.Shared) -> ((Locals() & Others()) & S.Shared) & SP.Plan<T.HealthSchema>:Existing.pair_plan(~T.HealthSchema,~Locals(),~Others(),~S.Shared,~plan_locals(),~plan_others())
def dispatch_all() -> ((Locals() & Others()) & S.Shared) -> Ctx.Context<F.World()> -> U32 -> ((Locals() & Others()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.pair_dispatch(~T.HealthSchema,~F.World(),~Locals(),~Others(),~S.Shared,~Unit,~fold_locals(),~dispatch_locals(),~dispatch_others())
def fold_function() -> S.Runtime() -> S.Runtime() & List<&2,Fields.Fields<T.HealthSchema>>:fold_all()
def plan_function() -> S.Runtime() -> S.Runtime() & SP.Plan<T.HealthSchema>:Existing.after(~T.HealthSchema,~S.Owned(),~S.Shared,~plan_all(),~enabled_barrier)
def dispatch_function() -> S.Runtime() -> Ctx.Context<F.World()> -> U32 -> S.Runtime() & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:dispatch_all()
def fold(value:S.Runtime()) -> S.Runtime() & List<&2,Fields.Fields<T.HealthSchema>>:fold_function()(value)
def ids(fields:List<&2,Fields.Fields<T.HealthSchema>>) -> List<&2,U32>:Identity.ids(Exec.identities(~T.HealthSchema,fields))
def provided(result:F.World() & List<&2,Service.Status<T.HealthSchema>>) -> F.World() & List<&2,SP.Requirement<T.HealthSchema>>:
  match result:
    case (world,statuses):(world,Service.available(~T.HealthSchema,statuses))
def provision(world:F.World()) -> F.World() & List<&2,SP.Requirement<T.HealthSchema>>:provided(Grants.scan(world))
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
