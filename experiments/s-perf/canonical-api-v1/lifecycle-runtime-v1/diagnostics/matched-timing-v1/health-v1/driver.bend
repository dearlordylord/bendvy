import Base
import /tmp/bendvy-lifecycle-health-matched-method/experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/health-domain.bend as D
import /tmp/bendvy-lifecycle-health-matched-method/experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/health-observation.bend as Observation
import /tmp/bendvy-lifecycle-health-matched-method/experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/health-registration.bend as Registration
import /tmp/bendvy-lifecycle-health-matched-method/experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/health-program.bend as Program
import /tmp/bendvy-lifecycle-health-matched-method/experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/health-codec-values.bend as V
import /tmp/bendvy-lifecycle-health-matched-method/experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/health-codec.bend as C
import /tmp/bendvy-lifecycle-health-matched-method/experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/health-buffer-stream.bend as Stream
import /tmp/bendvy-lifecycle-health-matched-method/experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/motion-report-rope.bend as Rope
import /tmp/bendvy-lifecycle-health-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/health.bend as F
import /tmp/bendvy-lifecycle-health-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/health-observe.bend as Old
import /tmp/bendvy-lifecycle-health-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import /tmp/bendvy-lifecycle-health-matched-method/src/ecs/world.bend as W
import /tmp/bendvy-lifecycle-health-matched-method/src/ecs/world-io.bend as WI
import /tmp/bendvy-lifecycle-health-matched-method/src/ecs/commands.bend as Cmd
import /tmp/bendvy-lifecycle-health-matched-method/src/ecs/transaction.bend as Tx

type Prepared is Type:
  Ready{prefix:Rope.Rope,iterations:U32,state:Program.State,seed:List<&2,W.Reservation<T.HealthSchema>>}
  Stopped{report:Rope.Rope}
def initial_state(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,iterations:U32,observed:Program.State & Rope.Rope) -> Prepared:
  match observed:
    case (state,view):Ready{C.join(prefix,view),iterations,state,seed}
def registration_stopped(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,foreign:D.World() & V.World,main:D.World() & V.World,rejected:Registration.RejectedOwners & Rope.Rope) -> Prepared:
  (foreign,sf)=foreign
  (world,sw)=main
  (owners,so)=rejected
  Stopped{C.cat([prefix,C.text("X"),C.u(0),C.world(sw),C.world(sf),so,C.text("!\n")])}
def registered(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,iterations:U32,foreign:D.World(),result:Registration.Registration) -> Prepared:
  match result:
    case Registration.Ready{world,owners}:initial_state(seed,prefix,iterations,C.state(Program.initial(world,foreign,owners)))
    case Registration.Stopped{world,owners}:registration_stopped(seed,prefix,V.world(foreign),V.world(world),C.rejected(owners))
def foreign_observed(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),foreign:W.Handle<T.HealthSchema>,observed:D.World() & V.World) -> Prepared:
  match observed:
    case (other,view):registered(seed,C.join(prefix,C.world(view)),iterations,other,Registration.run(world,count,foreign))
def bootstrap_stopped(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,primary:D.World() & V.World,foreign:D.World() & V.World) -> Prepared:
  (world,sw)=primary
  (other,sf)=foreign
  Stopped{C.cat([prefix,C.text("X"),C.u(1),C.world(sw),C.world(sf),C.text("!\n")])}
def foreign_checked(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),foreign:W.Handle<T.HealthSchema>,observed:D.World() & U32) -> Prepared:
  match observed:
    case (other,2):foreign_observed(seed,C.join(prefix,C.u(2)),count,iterations,world,foreign,V.world(other))
    case (other,kind):bootstrap_stopped(seed,C.join(prefix,C.u(kind)),V.world(world),V.world(other))
def foreign_live(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),+foreign:W.Handle<T.HealthSchema>,other:D.World()) -> Prepared:foreign_checked(seed,prefix,count,iterations,world,foreign,Observation.lookup(other,Some{foreign}))
def foreign_applied(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),reservation:W.Reservation<T.HealthSchema>,observed:D.World() & V.World) -> Prepared:
  match reservation observed:
    case W.Reserved{foreign}, (other,view):foreign_live(seed,C.join(prefix,C.world(view)),count,iterations,world,foreign,other)
    case reservation, (other,view):bootstrap_stopped(seed,C.cat([prefix,C.reservation(reservation),C.world(view)]),V.world(world),V.world(other))
def foreign_pending(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),reservation:W.Reservation<T.HealthSchema>,observed:D.World() & V.World) -> Prepared:
  match observed:
    case (other,view):foreign_applied(seed,C.join(prefix,C.world(view)),count,iterations,world,reservation,V.world(W.barrier(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,other)))
def foreign_finished(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),+reservation:W.Reservation<T.HealthSchema>,result:Tx.Returned<D.World(),Unit>) -> Prepared:
  match result:
    case Tx.Returned{other,outcome}:foreign_pending(seed,C.cat([prefix,C.outcome(outcome),C.reservation(reservation)]),count,iterations,world,reservation,V.world(other))
def foreign_reserved(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),result:Tx.Tx<D.World(),Nat> & W.Reservation<T.HealthSchema>) -> Prepared:
  match result:
    case (tx,reservation):foreign_finished(seed,prefix,count,iterations,world,reservation,Cmd.tx_finish(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Unit,tx,Tx.Success{}))
def foreign_seed(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),foreign:D.World()) -> Prepared:foreign_reserved(seed,prefix,count,iterations,world,Cmd.tx_spawn(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~T.Vitals,~D.populate,Tx.begin(~D.World(),~Nat,foreign),T.Vitals{F.quad(999,1000,1001,1002),9,2}))
def main_applied(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,foreign:D.World(),observed:D.World() & V.World) -> Prepared:
  match observed:
    case (world,view):foreign_seed(seed,C.join(prefix,C.world(view)),count,iterations,world,foreign)
def main_pending(seed:List<&2,W.Reservation<T.HealthSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,foreign:D.World(),observed:D.World() & V.World) -> Prepared:
  match observed:
    case (world,view):main_applied(seed,C.join(prefix,C.world(view)),count,iterations,foreign,V.world(W.barrier(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,world)))
def main_seeded(+count:U32,+iterations:U32,foreign:D.World(),result:F.Seeded) -> Prepared:
  match result:
    case F.Seeded{world,+reservations,outcome}:main_pending(reservations,C.cat([C.text("LC2H"),C.u(count),C.u(iterations),C.outcome(outcome),C.list(~W.Reservation<T.HealthSchema>,~C.reservation,reservations)]),count,iterations,foreign,V.world(world))
def program(+count:U32,iterations:U32,world:D.World(),foreign:D.World()) -> Prepared:main_seeded(count,iterations,foreign,F.seed(count,world))
def refused(observed:F.Resources() & String) -> String:
  match observed:
    case (resource,text):"WorldCreationRefused|" ++ text ++ "\n\n"
def foreign_refused(world:D.World() & String,resource:F.Resources() & String) -> String:
  (world,sw)=world
  (resource,sr)=resource
  "ForeignWorldCreationRefused|primary={" ++ sw ++ "};resource={" ++ sr ++ "}\n\n"
def raw_error(count:U32,iterations:U32,text:String) -> IO(Unit):Rope.write(C.cat([C.text("LC2H"),C.u(count),C.u(iterations),C.text("X"),C.u(2),C.string(text),C.text("!\n")]))
