import Base
import health-domain.bend as D
import health-systems.bend as S
import ../dense-runtime-v1/health.bend as F
import ../../../lifecycle-motion64/consumer/dense-runtime-v1/types.bend as T
import ../../../../../src/ecs/ordinary-app-existing-execution.bend as Existing
import ../../../../../src/ecs/ordinary-app-existing-adoption.bend as Adoption
import ../../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../../src/ecs/captured-schedule-composition.bend as Identity
import ../../../../../src/ecs/execution-context.bend as Ctx
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/schedule-provision.bend as SP

def Left() -> Type:S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)
def Right() -> Type:S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)
def stage(shared:S.Shared) -> S.Shared & U32:
  match shared:
    case S.Shared{frame,digest,boundaries,calls,+stage}:(S.Shared{frame,digest,boundaries,calls,stage},stage)
def selected_select(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+value):(shared,U32.is_eq(value,0))
def enabled_select(shared:S.Shared) -> S.Shared & Bool:selected_select(stage(shared))
def selected_reserve(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+value):(shared,U32.is_eq(value,0))
def enabled_reserve(shared:S.Shared) -> S.Shared & Bool:selected_reserve(stage(shared))
def selected_dispose(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+value):(shared,U32.is_eq(value,4))
def enabled_dispose(shared:S.Shared) -> S.Shared & Bool:selected_dispose(stage(shared))
def selected_observe(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+value):(shared,Bool.or(U32.is_eq(value,1),Bool.or(U32.is_eq(value,3),U32.is_eq(value,5))))
def enabled_observe(shared:S.Shared) -> S.Shared & Bool:selected_observe(stage(shared))
def selected_barrier(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+value):(shared,Bool.or(U32.is_eq(value,2),U32.is_eq(value,4)))
def enabled_barrier(shared:S.Shared) -> S.Shared & Bool:selected_barrier(stage(shared))
def fold_select() -> (S.Instance(~S.select_runner) & S.Shared) -> (S.Instance(~S.select_runner) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:
  Adoption.local_fold(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~S.select_runner,~S.Shared)
def plan_select() -> (S.Instance(~S.select_runner) & S.Shared) -> (S.Instance(~S.select_runner) & S.Shared) & SP.Plan<T.HealthSchema>:
  Adoption.local_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~S.select_runner,~S.Shared,~enabled_select,~[])
def dispatch_select() -> (S.Instance(~S.select_runner) & S.Shared) -> Ctx.Context<D.World()> -> U32 -> (S.Instance(~S.select_runner) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Adoption.local_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~S.select_runner,~S.Shared,~Unit,~S.invoke_select,~Unit{})
def fold_reserve() -> (S.Instance(~S.reserve_runner) & S.Shared) -> (S.Instance(~S.reserve_runner) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:
  Adoption.local_fold(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~S.reserve_runner,~S.Shared)
def plan_reserve() -> (S.Instance(~S.reserve_runner) & S.Shared) -> (S.Instance(~S.reserve_runner) & S.Shared) & SP.Plan<T.HealthSchema>:
  Adoption.local_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~S.reserve_runner,~S.Shared,~enabled_reserve,~[])
def dispatch_reserve() -> (S.Instance(~S.reserve_runner) & S.Shared) -> Ctx.Context<D.World()> -> U32 -> (S.Instance(~S.reserve_runner) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Adoption.local_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~S.reserve_runner,~S.Shared,~Unit,~S.invoke_reserve,~Unit{})
def fold_dispose() -> (S.Instance(~S.dispose_runner) & S.Shared) -> (S.Instance(~S.dispose_runner) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:
  Adoption.local_fold(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~S.dispose_runner,~S.Shared)
def plan_dispose() -> (S.Instance(~S.dispose_runner) & S.Shared) -> (S.Instance(~S.dispose_runner) & S.Shared) & SP.Plan<T.HealthSchema>:
  Adoption.local_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~S.dispose_runner,~S.Shared,~enabled_dispose,~[])
def dispatch_dispose() -> (S.Instance(~S.dispose_runner) & S.Shared) -> Ctx.Context<D.World()> -> U32 -> (S.Instance(~S.dispose_runner) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Adoption.local_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~S.dispose_runner,~S.Shared,~Unit,~S.invoke_dispose,~Unit{})
def fold_observe() -> (S.Instance(~S.observe_runner) & S.Shared) -> (S.Instance(~S.observe_runner) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:
  Adoption.local_fold(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~S.observe_runner,~S.Shared)
def plan_observe() -> (S.Instance(~S.observe_runner) & S.Shared) -> (S.Instance(~S.observe_runner) & S.Shared) & SP.Plan<T.HealthSchema>:
  Adoption.local_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~S.observe_runner,~S.Shared,~enabled_observe,~[])
def dispatch_observe() -> (S.Instance(~S.observe_runner) & S.Shared) -> Ctx.Context<D.World()> -> U32 -> (S.Instance(~S.observe_runner) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Adoption.local_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~S.observe_runner,~S.Shared,~Unit,~S.invoke_observe,~Unit{})
def fold_left() -> ((S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)) & S.Shared) -> ((S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:
  Existing.pair_fold(~T.HealthSchema,~S.Instance(~S.select_runner),~S.Instance(~S.reserve_runner),~S.Shared,~fold_select(),~fold_reserve())
def plan_left() -> ((S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)) & S.Shared) -> ((S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)) & S.Shared) & SP.Plan<T.HealthSchema>:
  Existing.pair_plan(~T.HealthSchema,~S.Instance(~S.select_runner),~S.Instance(~S.reserve_runner),~S.Shared,~plan_select(),~plan_reserve())
def dispatch_left() -> ((S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)) & S.Shared) -> Ctx.Context<D.World()> -> U32 -> ((S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Existing.pair_dispatch(~T.HealthSchema,~D.World(),~S.Instance(~S.select_runner),~S.Instance(~S.reserve_runner),~S.Shared,~Unit,~fold_select(),~dispatch_select(),~dispatch_reserve())
def fold_right() -> ((S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)) & S.Shared) -> ((S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:
  Existing.pair_fold(~T.HealthSchema,~S.Instance(~S.dispose_runner),~S.Instance(~S.observe_runner),~S.Shared,~fold_dispose(),~fold_observe())
def plan_right() -> ((S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)) & S.Shared) -> ((S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)) & S.Shared) & SP.Plan<T.HealthSchema>:
  Existing.pair_plan(~T.HealthSchema,~S.Instance(~S.dispose_runner),~S.Instance(~S.observe_runner),~S.Shared,~plan_dispose(),~plan_observe())
def dispatch_right() -> ((S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)) & S.Shared) -> Ctx.Context<D.World()> -> U32 -> ((S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Existing.pair_dispatch(~T.HealthSchema,~D.World(),~S.Instance(~S.dispose_runner),~S.Instance(~S.observe_runner),~S.Shared,~Unit,~fold_dispose(),~dispatch_dispose(),~dispatch_observe())
def fold_all() -> ((Left() & Right()) & S.Shared) -> ((Left() & Right()) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:
  Existing.pair_fold(~T.HealthSchema,~Left(),~Right(),~S.Shared,~fold_left(),~fold_right())
def plan_all() -> ((Left() & Right()) & S.Shared) -> ((Left() & Right()) & S.Shared) & SP.Plan<T.HealthSchema>:
  Existing.pair_plan(~T.HealthSchema,~Left(),~Right(),~S.Shared,~plan_left(),~plan_right())
def dispatch_all() -> ((Left() & Right()) & S.Shared) -> Ctx.Context<D.World()> -> U32 -> ((Left() & Right()) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Existing.pair_dispatch(~T.HealthSchema,~D.World(),~Left(),~Right(),~S.Shared,~Unit,~fold_left(),~dispatch_left(),~dispatch_right())
def fold_function() -> S.Runtime() -> S.Runtime() & List<&2,Fields.Fields<T.HealthSchema>>:fold_all()
def dispatch_function() -> S.Runtime() -> Ctx.Context<D.World()> -> U32 -> S.Runtime() & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:dispatch_all()
def plan_function() -> S.Runtime() -> S.Runtime() & SP.Plan<T.HealthSchema>:
  Existing.after(~T.HealthSchema,~S.Owned(),~S.Shared,~plan_all(),~enabled_barrier)
def fold(value:S.Runtime()) -> S.Runtime() & List<&2,Fields.Fields<T.HealthSchema>>:fold_function()(value)
def provision(world:D.World()) -> D.World() & List<&2,SP.Requirement<T.HealthSchema>>:(world,[])
def ids(fields:List<&2,Fields.Fields<T.HealthSchema>>) -> List<&2,U32>:Identity.ids(Exec.identities(~T.HealthSchema,fields))
