import Base
import ../../../../src/ecs/ordinary-app-existing-adoption.bend as Adoption
import health.bend as F
import types.bend as T
import health-events.bend as E
import health-domain.bend as D
import health-systems.bend as S
import health-reader.bend as Reader
import health-parameters.bend as P
import ../../../../src/ecs/ordinary-app-existing-execution.bend as Existing
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../src/ecs/execution-context.bend as Ctx
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/system.bend as Sys

def A() -> Type:S.Instance() & S.Instance()
def B() -> Type:Reader.Provider() & Reader.Provider()
def C() -> Type:S.Instance() & B()
def local_fold(value:S.Instance() & S.Shared) -> (S.Instance() & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:Adoption.local_fold(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Array<U32>,~S.Args,~Unit,~D.Frame,~S.local_runner,~S.Shared)(value)
def reader_fold(value:Reader.Provider() & S.Shared) -> (Reader.Provider() & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:Adoption.reader_fold(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Reader.Invocation(),~Empty,~Reader.Envelope(),~Reader.runner(),~P.all_owner(),~P.all_parameter_type(),~Unit,~S.Shared)(value)
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
def spawn_plan(value:S.Instance() & S.Shared) -> (S.Instance() & S.Shared) & SP.Plan<T.HealthSchema>:Adoption.local_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Array<U32>,~S.Args,~Unit,~D.Frame,~S.local_runner,~S.Shared,~selected(~spawn_wanted),~[])(value)
def spawn_dispatch(value:S.Instance() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (S.Instance() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Adoption.local_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Array<U32>,~S.Args,~Unit,~D.Frame,~S.local_runner,~S.Shared,~Unit,~S.spawn_invoke,~Unit{})(value)(context)(id)
def update_plan(value:S.Instance() & S.Shared) -> (S.Instance() & S.Shared) & SP.Plan<T.HealthSchema>:Adoption.local_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Array<U32>,~S.Args,~Unit,~D.Frame,~S.local_runner,~S.Shared,~selected(~update_wanted),~[])(value)
def update_dispatch(value:S.Instance() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (S.Instance() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Adoption.local_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Array<U32>,~S.Args,~Unit,~D.Frame,~S.local_runner,~S.Shared,~Unit,~S.update_invoke,~Unit{})(value)(context)(id)
def dispose_plan(value:S.Instance() & S.Shared) -> (S.Instance() & S.Shared) & SP.Plan<T.HealthSchema>:Adoption.local_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Array<U32>,~S.Args,~Unit,~D.Frame,~S.local_runner,~S.Shared,~selected(~dispose_wanted),~[])(value)
def dispose_dispatch(value:S.Instance() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (S.Instance() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Adoption.local_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Array<U32>,~S.Args,~Unit,~D.Frame,~S.local_runner,~S.Shared,~Unit,~S.dispose_invoke,~Unit{})(value)(context)(id)
def fast_plan(value:Reader.Provider() & S.Shared) -> (Reader.Provider() & S.Shared) & SP.Plan<T.HealthSchema>:Adoption.reader_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Reader.Invocation(),~Empty,~Reader.Envelope(),~Reader.runner(),~P.all_owner(),~P.all_parameter_type(),~Unit,~S.Shared,~selected(~fast_wanted),~[])(value)
def fast_dispatch(value:Reader.Provider() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (Reader.Provider() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Adoption.reader_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Reader.Invocation(),~Empty,~Reader.Envelope(),~Reader.runner(),~P.all_owner(),~P.all_parameter_type(),~Unit,~S.Shared,~Unit,~S.fast_invoke,~Unit{})(value)(context)(id)
def slow_plan(value:Reader.Provider() & S.Shared) -> (Reader.Provider() & S.Shared) & SP.Plan<T.HealthSchema>:Adoption.reader_plan(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Reader.Invocation(),~Empty,~Reader.Envelope(),~Reader.runner(),~P.all_owner(),~P.all_parameter_type(),~Unit,~S.Shared,~selected(~slow_wanted),~[])(value)
def slow_dispatch(value:Reader.Provider() & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> (Reader.Provider() & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Adoption.reader_dispatch(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Reader.Invocation(),~Empty,~Reader.Envelope(),~Reader.runner(),~P.all_owner(),~P.all_parameter_type(),~Unit,~S.Shared,~Unit,~S.slow_invoke,~Unit{})(value)(context)(id)
def a_fold(value:(S.Instance() & S.Instance()) & S.Shared) -> ((S.Instance() & S.Instance()) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:Existing.pair_fold(~T.HealthSchema,~S.Instance(),~S.Instance(),~S.Shared,~local_fold,~local_fold,value)
def a_plan(value:(S.Instance() & S.Instance()) & S.Shared) -> ((S.Instance() & S.Instance()) & S.Shared) & SP.Plan<T.HealthSchema>:Existing.pair_plan(~T.HealthSchema,~S.Instance(),~S.Instance(),~S.Shared,~spawn_plan,~update_plan,value)
def a_dispatch(value:(S.Instance() & S.Instance()) & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> ((S.Instance() & S.Instance()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.pair_dispatch(~T.HealthSchema,~F.World(),~S.Instance(),~S.Instance(),~S.Shared,~Unit,~local_fold,~spawn_dispatch,~update_dispatch,value,context,id)
def b_fold(value:(Reader.Provider() & Reader.Provider()) & S.Shared) -> ((Reader.Provider() & Reader.Provider()) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:Existing.pair_fold(~T.HealthSchema,~Reader.Provider(),~Reader.Provider(),~S.Shared,~reader_fold,~reader_fold,value)
def b_plan(value:(Reader.Provider() & Reader.Provider()) & S.Shared) -> ((Reader.Provider() & Reader.Provider()) & S.Shared) & SP.Plan<T.HealthSchema>:Existing.pair_plan(~T.HealthSchema,~Reader.Provider(),~Reader.Provider(),~S.Shared,~fast_plan,~slow_plan,value)
def b_dispatch(value:(Reader.Provider() & Reader.Provider()) & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> ((Reader.Provider() & Reader.Provider()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.pair_dispatch(~T.HealthSchema,~F.World(),~Reader.Provider(),~Reader.Provider(),~S.Shared,~Unit,~reader_fold,~fast_dispatch,~slow_dispatch,value,context,id)
def c_fold(value:(S.Instance() & B()) & S.Shared) -> ((S.Instance() & B()) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:Existing.pair_fold(~T.HealthSchema,~S.Instance(),~B(),~S.Shared,~local_fold,~b_fold,value)
def c_plan(value:(S.Instance() & B()) & S.Shared) -> ((S.Instance() & B()) & S.Shared) & SP.Plan<T.HealthSchema>:Existing.pair_plan(~T.HealthSchema,~S.Instance(),~B(),~S.Shared,~dispose_plan,~b_plan,value)
def c_dispatch(value:(S.Instance() & B()) & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> ((S.Instance() & B()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.pair_dispatch(~T.HealthSchema,~F.World(),~S.Instance(),~B(),~S.Shared,~Unit,~local_fold,~dispose_dispatch,~b_dispatch,value,context,id)
def root_fold(value:(A() & C()) & S.Shared) -> ((A() & C()) & S.Shared) & List<&2,Fields.Fields<T.HealthSchema>>:Existing.pair_fold(~T.HealthSchema,~A(),~C(),~S.Shared,~a_fold,~c_fold,value)
def root_plan(value:(A() & C()) & S.Shared) -> ((A() & C()) & S.Shared) & SP.Plan<T.HealthSchema>:Existing.pair_plan(~T.HealthSchema,~A(),~C(),~S.Shared,~a_plan,~c_plan,value)
def root_dispatch(value:(A() & C()) & S.Shared,context:Ctx.Context<F.World()>,id:U32) -> ((A() & C()) & S.Shared) & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:Existing.pair_dispatch(~T.HealthSchema,~F.World(),~A(),~C(),~S.Shared,~Unit,~a_fold,~a_dispatch,~c_dispatch,value,context,id)
def fold(value:S.Runtime()) -> S.Runtime() & List<&2,Fields.Fields<T.HealthSchema>>:root_fold(value)
def plan(value:S.Runtime()) -> S.Runtime() & SP.Plan<T.HealthSchema>:Existing.after(~T.HealthSchema,~S.Owned(),~S.Shared,~root_plan,~selected(~barrier_wanted),value)
def dispatch(value:S.Runtime(),context:Ctx.Context<F.World()>,id:U32) -> S.Runtime() & Sys.Outcome<Ctx.Context<F.World()>,Unit,Unit>:root_dispatch(value,context,id)
def provision(world:F.World()) -> F.World() & List<&2,SP.Requirement<T.HealthSchema>>:(world,[])
