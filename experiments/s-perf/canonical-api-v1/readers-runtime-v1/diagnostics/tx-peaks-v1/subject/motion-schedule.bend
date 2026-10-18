import Base
import motion.bend as F
import types.bend as T
import events.bend as E
import motion-domain.bend as D
import motion-systems.bend as S
import motion-reader.bend as Reader
import motion-parameters.bend as P
import ../../../../../../../src/ecs/ordinary-app-existing-execution.bend as Existing
import ../../../../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../../../../src/ecs/execution-context.bend as Ctx
import ../../../../../../../src/ecs/schedule-provision.bend as SP
import ../../../../../../../src/ecs/system.bend as Sys

def A() -> Type:S.Instance() & S.Instance()
def B() -> Type:Reader.Provider() & Reader.Provider()
def C() -> Type:S.Instance() & B()
def local_catalog(value:S.Instance()) -> S.Instance() & Fields.Fields<T.MotionSchema>:Existing.local_fields(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~Array<U32>,~S.Args,~Unit,~D.Frame,~S.local_runner,value)
def reader_catalog(value:Reader.Provider()) -> Reader.Provider() & Fields.Fields<T.MotionSchema>:Existing.reader_fields(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~Reader.Invocation(),~Empty,~Reader.Envelope(),~Reader.runner(),~P.all_owner(),~P.all_parameter_type(),~Unit,value)
def local_fold(value:S.Instance() & S.Shared) -> (S.Instance() & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:Existing.fold(~T.MotionSchema,~S.Instance(),~S.Shared,~local_catalog,value)
def reader_fold(value:Reader.Provider() & S.Shared) -> (Reader.Provider() & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:Existing.fold(~T.MotionSchema,~Reader.Provider(),~S.Shared,~reader_catalog,value)
def spawn_wanted(stage:U32,_:D.Frame) -> Bool:U32.is_eq(stage,1)
def update_wanted(stage:U32,_:D.Frame) -> Bool:U32.is_eq(stage,2)
def dispose_wanted(stage:U32,_:D.Frame) -> Bool:U32.is_eq(stage,3)
def fast_wanted(stage:U32,_:D.Frame) -> Bool:
  match stage:
    case 0:True{}
    case 2:True{}
    case _:False{}
def slow_wanted(stage:U32,frame:D.Frame) -> Bool:
  match stage frame:
    case 0 _:True{}
    case 2 D.Frame{_,i,_,_,_}:U32.is_eq(U32.mod(i,4),3)
    case _ _:False{}
def barrier_wanted(stage:U32,_:D.Frame) -> Bool:
  match stage:
    case 1:True{}
    case 3:True{}
    case _:False{}
def selected(~test:U32 -> D.Frame -> Bool,value:S.Shared) -> S.Shared & Bool:
  match value:
    case S.Shared{meta,tick,+frame,phase,locals,reads,+stage}:(S.Shared{meta,tick,frame,phase,locals,reads,stage},test(stage,frame))
def spawn_plan(value:S.Instance() & S.Shared) -> (S.Instance() & S.Shared) & SP.Plan<T.MotionSchema>:Existing.plan(~T.MotionSchema,~S.Instance(),~S.Shared,~local_catalog,~selected(~spawn_wanted),~[],value)
def spawn_dispatch(value:S.Instance() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (S.Instance() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.dispatch(~T.MotionSchema,~F.World(),~S.Instance(),~S.Shared,~Unit,~local_catalog,~S.spawn_invoke,~Unit{},value,context,id)
def update_plan(value:S.Instance() & S.Shared) -> (S.Instance() & S.Shared) & SP.Plan<T.MotionSchema>:Existing.plan(~T.MotionSchema,~S.Instance(),~S.Shared,~local_catalog,~selected(~update_wanted),~[],value)
def update_dispatch(value:S.Instance() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (S.Instance() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.dispatch(~T.MotionSchema,~F.World(),~S.Instance(),~S.Shared,~Unit,~local_catalog,~S.update_invoke,~Unit{},value,context,id)
def dispose_plan(value:S.Instance() & S.Shared) -> (S.Instance() & S.Shared) & SP.Plan<T.MotionSchema>:Existing.plan(~T.MotionSchema,~S.Instance(),~S.Shared,~local_catalog,~selected(~dispose_wanted),~[],value)
def dispose_dispatch(value:S.Instance() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (S.Instance() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.dispatch(~T.MotionSchema,~F.World(),~S.Instance(),~S.Shared,~Unit,~local_catalog,~S.dispose_invoke,~Unit{},value,context,id)
def fast_plan(value:Reader.Provider() & S.Shared) -> (Reader.Provider() & S.Shared) & SP.Plan<T.MotionSchema>:Existing.plan(~T.MotionSchema,~Reader.Provider(),~S.Shared,~reader_catalog,~selected(~fast_wanted),~[],value)
def fast_dispatch(value:Reader.Provider() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (Reader.Provider() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.dispatch(~T.MotionSchema,~F.World(),~Reader.Provider(),~S.Shared,~Unit,~reader_catalog,~S.fast_invoke,~Unit{},value,context,id)
def slow_plan(value:Reader.Provider() & S.Shared) -> (Reader.Provider() & S.Shared) & SP.Plan<T.MotionSchema>:Existing.plan(~T.MotionSchema,~Reader.Provider(),~S.Shared,~reader_catalog,~selected(~slow_wanted),~[],value)
def slow_dispatch(value:Reader.Provider() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (Reader.Provider() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.dispatch(~T.MotionSchema,~F.World(),~Reader.Provider(),~S.Shared,~Unit,~reader_catalog,~S.slow_invoke,~Unit{},value,context,id)
def a_fold(value:(S.Instance() & S.Instance()) & S.Shared) -> ((S.Instance() & S.Instance()) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:Existing.pair_fold(~T.MotionSchema,~S.Instance(),~S.Instance(),~S.Shared,~local_fold,~local_fold,value)
def a_plan(value:(S.Instance() & S.Instance()) & S.Shared) -> ((S.Instance() & S.Instance()) & S.Shared) & SP.Plan<T.MotionSchema>:Existing.pair_plan(~T.MotionSchema,~S.Instance(),~S.Instance(),~S.Shared,~spawn_plan,~update_plan,value)
def a_dispatch(value:(S.Instance() & S.Instance()) & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> ((S.Instance() & S.Instance()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.pair_dispatch(~T.MotionSchema,~F.World(),~S.Instance(),~S.Instance(),~S.Shared,~Unit,~local_fold,~spawn_dispatch,~update_dispatch,value,context,id)
def b_fold(value:(Reader.Provider() & Reader.Provider()) & S.Shared) -> ((Reader.Provider() & Reader.Provider()) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:Existing.pair_fold(~T.MotionSchema,~Reader.Provider(),~Reader.Provider(),~S.Shared,~reader_fold,~reader_fold,value)
def b_plan(value:(Reader.Provider() & Reader.Provider()) & S.Shared) -> ((Reader.Provider() & Reader.Provider()) & S.Shared) & SP.Plan<T.MotionSchema>:Existing.pair_plan(~T.MotionSchema,~Reader.Provider(),~Reader.Provider(),~S.Shared,~fast_plan,~slow_plan,value)
def b_dispatch(value:(Reader.Provider() & Reader.Provider()) & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> ((Reader.Provider() & Reader.Provider()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.pair_dispatch(~T.MotionSchema,~F.World(),~Reader.Provider(),~Reader.Provider(),~S.Shared,~Unit,~reader_fold,~fast_dispatch,~slow_dispatch,value,context,id)
def c_fold(value:(S.Instance() & B()) & S.Shared) -> ((S.Instance() & B()) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:Existing.pair_fold(~T.MotionSchema,~S.Instance(),~B(),~S.Shared,~local_fold,~b_fold,value)
def c_plan(value:(S.Instance() & B()) & S.Shared) -> ((S.Instance() & B()) & S.Shared) & SP.Plan<T.MotionSchema>:Existing.pair_plan(~T.MotionSchema,~S.Instance(),~B(),~S.Shared,~dispose_plan,~b_plan,value)
def c_dispatch(value:(S.Instance() & B()) & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> ((S.Instance() & B()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.pair_dispatch(~T.MotionSchema,~F.World(),~S.Instance(),~B(),~S.Shared,~Unit,~local_fold,~dispose_dispatch,~b_dispatch,value,context,id)
def root_fold(value:(A() & C()) & S.Shared) -> ((A() & C()) & S.Shared) & List<&2,Fields.Fields<T.MotionSchema>>:Existing.pair_fold(~T.MotionSchema,~A(),~C(),~S.Shared,~a_fold,~c_fold,value)
def root_plan(value:(A() & C()) & S.Shared) -> ((A() & C()) & S.Shared) & SP.Plan<T.MotionSchema>:Existing.pair_plan(~T.MotionSchema,~A(),~C(),~S.Shared,~a_plan,~c_plan,value)
def root_dispatch(value:(A() & C()) & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> ((A() & C()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.pair_dispatch(~T.MotionSchema,~F.World(),~A(),~C(),~S.Shared,~Unit,~a_fold,~a_dispatch,~c_dispatch,value,context,id)
def fold(value:S.Runtime()) -> S.Runtime() & List<&2,Fields.Fields<T.MotionSchema>>:root_fold(value)
def plan(value:S.Runtime()) -> S.Runtime() & SP.Plan<T.MotionSchema>:Existing.after(~T.MotionSchema,~S.Owned(),~S.Shared,~root_plan,~selected(~barrier_wanted),value)
def dispatch(value:S.Runtime(),context:Ctx.Context<F.World()>,id:U32) -> S.Runtime() & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:root_dispatch(value,context,id)
def provision(world:F.World()) -> F.World() & List<&2,SP.Requirement<T.MotionSchema>>:(world,[])
