import Base
import metric-owner.bend as MO
import tx-metrics.bend as Metrics
import motion-domain.bend as D
import motion-systems.bend as S
import ../../../../dense-runtime-v1/motion.bend as F
import ../../../../dense-runtime-v1/types.bend as T
import ../../../../../../../src/ecs/ordinary-app-existing-execution.bend as Existing
import ../../../../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../../../../src/ecs/captured-schedule-composition.bend as Identity
import ../../../../../../../src/ecs/execution-context.bend as Ctx
import ../../../../../../../src/ecs/system.bend as Sys
import ../../../../../../../src/ecs/schedule-provision.bend as SP

def Left() -> Type:S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)
def Right() -> Type:S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)
def stage(shared:S.Shared) -> S.Shared & U32:
  match shared:
    case S.Shared{frame,digest,boundaries,calls,+stage}:(S.Shared{frame,digest,boundaries,calls,stage},stage)
def selected_select(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+value):(shared,U32.is_eq(value,0))
def enabled_select(shared:S.Shared) -> S.Shared & Bool:selected_select(stage(shared))
def fields_select(owner:S.Instance(~S.select_runner)) -> S.Instance(~S.select_runner) & Fields.Fields<T.MotionSchema>:
  Existing.local_fields(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~MO.Owner,~D.Frame,~Unit,~D.Output,~S.select_runner,owner)
def fold_select(value:S.Instance(~S.select_runner) & S.Shared) -> (S.Instance(~S.select_runner) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.fold(~T.MotionSchema,~S.Instance(~S.select_runner),~S.Shared,~fields_select,value)
def dispatch_select(value:S.Instance(~S.select_runner) & S.Shared,context:Ctx.Context<D.World()>,id:U32) -> (S.Instance(~S.select_runner) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Existing.dispatch(~T.MotionSchema,~D.World(),~S.Instance(~S.select_runner),~S.Shared,~Unit,~fields_select,~S.invoke_select,~Unit{},value,context,id)
def plan_select(value:S.Instance(~S.select_runner) & S.Shared) -> (S.Instance(~S.select_runner) & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.plan(~T.MotionSchema,~S.Instance(~S.select_runner),~S.Shared,~fields_select,~enabled_select,~[],value)
def selected_reserve(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+value):(shared,U32.is_eq(value,0))
def enabled_reserve(shared:S.Shared) -> S.Shared & Bool:selected_reserve(stage(shared))
def fields_reserve(owner:S.Instance(~S.reserve_runner)) -> S.Instance(~S.reserve_runner) & Fields.Fields<T.MotionSchema>:
  Existing.local_fields(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~MO.Owner,~D.Frame,~Unit,~D.Output,~S.reserve_runner,owner)
def fold_reserve(value:S.Instance(~S.reserve_runner) & S.Shared) -> (S.Instance(~S.reserve_runner) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.fold(~T.MotionSchema,~S.Instance(~S.reserve_runner),~S.Shared,~fields_reserve,value)
def dispatch_reserve(value:S.Instance(~S.reserve_runner) & S.Shared,context:Ctx.Context<D.World()>,id:U32) -> (S.Instance(~S.reserve_runner) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Existing.dispatch(~T.MotionSchema,~D.World(),~S.Instance(~S.reserve_runner),~S.Shared,~Unit,~fields_reserve,~S.invoke_reserve,~Unit{},value,context,id)
def plan_reserve(value:S.Instance(~S.reserve_runner) & S.Shared) -> (S.Instance(~S.reserve_runner) & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.plan(~T.MotionSchema,~S.Instance(~S.reserve_runner),~S.Shared,~fields_reserve,~enabled_reserve,~[],value)
def selected_dispose(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+value):(shared,U32.is_eq(value,4))
def enabled_dispose(shared:S.Shared) -> S.Shared & Bool:selected_dispose(stage(shared))
def fields_dispose(owner:S.Instance(~S.dispose_runner)) -> S.Instance(~S.dispose_runner) & Fields.Fields<T.MotionSchema>:
  Existing.local_fields(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~MO.Owner,~D.Frame,~Unit,~D.Output,~S.dispose_runner,owner)
def fold_dispose(value:S.Instance(~S.dispose_runner) & S.Shared) -> (S.Instance(~S.dispose_runner) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.fold(~T.MotionSchema,~S.Instance(~S.dispose_runner),~S.Shared,~fields_dispose,value)
def dispatch_dispose(value:S.Instance(~S.dispose_runner) & S.Shared,context:Ctx.Context<D.World()>,id:U32) -> (S.Instance(~S.dispose_runner) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Existing.dispatch(~T.MotionSchema,~D.World(),~S.Instance(~S.dispose_runner),~S.Shared,~Unit,~fields_dispose,~S.invoke_dispose,~Unit{},value,context,id)
def plan_dispose(value:S.Instance(~S.dispose_runner) & S.Shared) -> (S.Instance(~S.dispose_runner) & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.plan(~T.MotionSchema,~S.Instance(~S.dispose_runner),~S.Shared,~fields_dispose,~enabled_dispose,~[],value)
def selected_observe(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+value):(shared,Bool.or(U32.is_eq(value,1),Bool.or(U32.is_eq(value,3),U32.is_eq(value,5))))
def enabled_observe(shared:S.Shared) -> S.Shared & Bool:selected_observe(stage(shared))
def fields_observe(owner:S.Instance(~S.observe_runner)) -> S.Instance(~S.observe_runner) & Fields.Fields<T.MotionSchema>:
  Existing.local_fields(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~MO.Owner,~D.Frame,~Unit,~D.Output,~S.observe_runner,owner)
def fold_observe(value:S.Instance(~S.observe_runner) & S.Shared) -> (S.Instance(~S.observe_runner) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.fold(~T.MotionSchema,~S.Instance(~S.observe_runner),~S.Shared,~fields_observe,value)
def dispatch_observe(value:S.Instance(~S.observe_runner) & S.Shared,context:Ctx.Context<D.World()>,id:U32) -> (S.Instance(~S.observe_runner) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Existing.dispatch(~T.MotionSchema,~D.World(),~S.Instance(~S.observe_runner),~S.Shared,~Unit,~fields_observe,~S.invoke_observe,~Unit{},value,context,id)
def plan_observe(value:S.Instance(~S.observe_runner) & S.Shared) -> (S.Instance(~S.observe_runner) & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.plan(~T.MotionSchema,~S.Instance(~S.observe_runner),~S.Shared,~fields_observe,~enabled_observe,~[],value)
def selected_barrier(value:S.Shared & U32) -> S.Shared & Bool:
  match value:
    case (shared,+value):(shared,Bool.or(U32.is_eq(value,2),U32.is_eq(value,4)))
def enabled_barrier(shared:S.Shared) -> S.Shared & Bool:selected_barrier(stage(shared))
def fold_left(value:(S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)) & S.Shared) -> ((S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.pair_fold(~T.MotionSchema,~S.Instance(~S.select_runner),~S.Instance(~S.reserve_runner),~S.Shared,~fold_select,~fold_reserve,value)
def dispatch_left(value:(S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)) & S.Shared,context:Ctx.Context<D.World()>,id:U32) -> ((S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Existing.pair_dispatch(~T.MotionSchema,~D.World(),~S.Instance(~S.select_runner),~S.Instance(~S.reserve_runner),~S.Shared,~Unit,~fold_select,~dispatch_select,~dispatch_reserve,value,context,id)
def plan_left(value:(S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)) & S.Shared) -> ((S.Instance(~S.select_runner) & S.Instance(~S.reserve_runner)) & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.pair_plan(~T.MotionSchema,~S.Instance(~S.select_runner),~S.Instance(~S.reserve_runner),~S.Shared,~plan_select,~plan_reserve,value)
def fold_right(value:(S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)) & S.Shared) -> ((S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.pair_fold(~T.MotionSchema,~S.Instance(~S.dispose_runner),~S.Instance(~S.observe_runner),~S.Shared,~fold_dispose,~fold_observe,value)
def dispatch_right(value:(S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)) & S.Shared,context:Ctx.Context<D.World()>,id:U32) -> ((S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Existing.pair_dispatch(~T.MotionSchema,~D.World(),~S.Instance(~S.dispose_runner),~S.Instance(~S.observe_runner),~S.Shared,~Unit,~fold_dispose,~dispatch_dispose,~dispatch_observe,value,context,id)
def plan_right(value:(S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)) & S.Shared) -> ((S.Instance(~S.dispose_runner) & S.Instance(~S.observe_runner)) & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.pair_plan(~T.MotionSchema,~S.Instance(~S.dispose_runner),~S.Instance(~S.observe_runner),~S.Shared,~plan_dispose,~plan_observe,value)
def fold_all(value:(Left() & Right()) & S.Shared) -> ((Left() & Right()) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:
  Existing.pair_fold(~T.MotionSchema,~Left(),~Right(),~S.Shared,~fold_left,~fold_right,value)
def dispatch_all(value:(Left() & Right()) & S.Shared,context:Ctx.Context<D.World()>,id:U32) -> ((Left() & Right()) & S.Shared) & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:
  Existing.pair_dispatch(~T.MotionSchema,~D.World(),~Left(),~Right(),~S.Shared,~Unit,~fold_left,~dispatch_left,~dispatch_right,value,context,id)
def plan_all(value:(Left() & Right()) & S.Shared) -> ((Left() & Right()) & S.Shared) & SP.Plan<T.MotionSchema>:
  Existing.pair_plan(~T.MotionSchema,~Left(),~Right(),~S.Shared,~plan_left,~plan_right,value)
def fold(value:S.Runtime()) -> S.Runtime() & List<&2,Fields.Fields<T.MotionSchema>>:fold_all(value)
def dispatch(value:S.Runtime(),context:Ctx.Context<D.World()>,id:U32) -> S.Runtime() & Sys.Outcome<Ctx.Context<D.World()>,Unit,Unit>:dispatch_all(value,context,id)
def plan(value:S.Runtime()) -> S.Runtime() & SP.Plan<T.MotionSchema>:Existing.after(~T.MotionSchema,~S.Owned(),~S.Shared,~plan_all,~enabled_barrier,value)
def provision(world:D.World()) -> D.World() & List<&2,SP.Requirement<T.MotionSchema>>:(world,[])
def ids(fields:List<&2,Fields.Fields<T.MotionSchema>>) -> List<&2,U32>:Identity.ids(Exec.identities(~T.MotionSchema,fields))
