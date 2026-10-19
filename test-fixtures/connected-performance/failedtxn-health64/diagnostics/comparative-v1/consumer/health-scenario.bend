import Base
import ../../../method/method.bend as Method
import ../../../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../consumer/health.bend as F
import ../../../consumer/health-events.bend as E
import health-registration.bend as Reg
import health-dispose.bend as Dispose
import health-systems.bend as S
import health-program.bend as Program
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/system.bend as Sys
import ../../../../../../src/ecs/ordinary-declaration.bend as Identity

type Prepared is Type:
  Prepared{state:Program.State}
  PreparationFailed{stage:U32}
def primed(world:F.World(),owners:Reg.Owners,dispose:Dispose.Registry(),first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>,method:Method.State,namespace:U32) -> Prepared:
  Prepared{Program.run_phase(0,Program.start(world,S.Owners{owners,dispose,S.Frame{first,second,0,0,None{},None{},[],[],method}},namespace))}
def named(method:Method.State,owners:Reg.Owners,dispose:Dispose.Registry(),first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>,observed:F.World() & U32) -> Prepared:
  match observed:
    case (world,ns):primed(world,owners,dispose,first,second,method,ns)
def dispose_registered(method:Method.State,owners:Reg.Owners,first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>,value:Sys.RegistrationResult<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),List<&2,W.Handle<T.HealthSchema>>,Empty,Dispose.Output,Dispose.runner>) -> Prepared:
  match value:
    case Sys.Registered{world,registry}:named(method,owners,registry,first,second,W.namespace(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world))
    case Sys.RegistrationFailed{_}:PreparationFailed{5}
def setup(method:Method.State,first:W.Handle<T.HealthSchema>,second:W.Handle<T.HealthSchema>,value:Reg.Registration) -> Prepared:
  match value:
    case Reg.Ready{world,owners}:dispose_registered(method,owners,first,second,Sys.register(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~List<&2,W.Handle<T.HealthSchema>>,~Empty,~Dispose.Output,~Dispose.runner,world,"FailedTxn/DisposeTransient",[Identity.key(~T.HealthSchema,~T.Vitals,F.main_identity()),Identity.key(~T.HealthSchema,~T.Armor,F.aux_identity()),Identity.key(~T.HealthSchema,~T.Tracked,F.flag_identity())]))
    case Reg.Stopped{_,stage,_,_,_,_}:PreparationFailed{stage}
def targets(world:F.World(),+reservations:List<&2,W.Reservation<T.HealthSchema>>) -> Prepared:
  match reservations:
    case W.Reserved{first} <> W.Reserved{second} <> _:setup(Method.start(reservations),first,second,Reg.run(world))
    case _:PreparationFailed{0}
def seeded(value:F.Seeded) -> Prepared:
  match value:
    case F.Seeded{world,reservations,_}:targets(W.barrier(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),world),reservations)
def prepare(count:U32,_:U32,world:F.World()) -> Prepared:seeded(F.seed(count,world))
