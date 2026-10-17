import Base
import health-domain.bend as D
import health-observation.bend as Observation
import health-registration.bend as Registration
import health-program.bend as Program
import health-codec-values.bend as V
import health-codec.bend as C
import health-buffer-stream.bend as Stream
import motion-report-rope.bend as Rope
import ../dense-runtime-v1/health.bend as F
import ../dense-runtime-v1/health-observe.bend as Old
import ../dense-runtime-v1/types.bend as T
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/commands.bend as Cmd
import ../../../../src/ecs/transaction.bend as Tx

type Prepared is Type:
  Ready{prefix:Rope.Rope,iterations:U32,state:Program.State}
  Stopped{report:Rope.Rope}
def initial_state(prefix:Rope.Rope,iterations:U32,observed:Program.State & Rope.Rope) -> Prepared:
  match observed:
    case (state,view):Ready{C.join(prefix,view),iterations,state}
def registration_stopped(prefix:Rope.Rope,foreign:D.World() & V.World,main:D.World() & V.World,rejected:Registration.RejectedOwners & Rope.Rope) -> Prepared:
  (foreign,sf)=foreign
  (world,sw)=main
  (owners,so)=rejected
  Stopped{C.cat([prefix,C.text("X"),C.u(0),C.world(sw),C.world(sf),so,C.text("!\n")])}
def registered(prefix:Rope.Rope,iterations:U32,foreign:D.World(),result:Registration.Registration) -> Prepared:
  match result:
    case Registration.Ready{world,owners}:initial_state(prefix,iterations,C.state(Program.initial(world,foreign,owners)))
    case Registration.Stopped{world,owners}:registration_stopped(prefix,V.world(foreign),V.world(world),C.rejected(owners))
def foreign_observed(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),foreign:W.Handle<T.HealthSchema>,observed:D.World() & V.World) -> Prepared:
  match observed:
    case (other,view):registered(C.join(prefix,C.world(view)),iterations,other,Registration.run(world,count,foreign))
def bootstrap_stopped(prefix:Rope.Rope,primary:D.World() & V.World,foreign:D.World() & V.World) -> Prepared:
  (world,sw)=primary
  (other,sf)=foreign
  Stopped{C.cat([prefix,C.text("X"),C.u(1),C.world(sw),C.world(sf),C.text("!\n")])}
def foreign_checked(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),foreign:W.Handle<T.HealthSchema>,observed:D.World() & U32) -> Prepared:
  match observed:
    case (other,2):foreign_observed(C.join(prefix,C.u(2)),count,iterations,world,foreign,V.world(other))
    case (other,kind):bootstrap_stopped(C.join(prefix,C.u(kind)),V.world(world),V.world(other))
def foreign_live(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),+foreign:W.Handle<T.HealthSchema>,other:D.World()) -> Prepared:foreign_checked(prefix,count,iterations,world,foreign,Observation.lookup(other,Some{foreign}))
def foreign_applied(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),reservation:W.Reservation<T.HealthSchema>,observed:D.World() & V.World) -> Prepared:
  match reservation observed:
    case W.Reserved{foreign}, (other,view):foreign_live(C.join(prefix,C.world(view)),count,iterations,world,foreign,other)
    case reservation, (other,view):bootstrap_stopped(C.cat([prefix,C.reservation(reservation),C.world(view)]),V.world(world),V.world(other))
def foreign_pending(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),reservation:W.Reservation<T.HealthSchema>,observed:D.World() & V.World) -> Prepared:
  match observed:
    case (other,view):foreign_applied(C.join(prefix,C.world(view)),count,iterations,world,reservation,V.world(W.barrier(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,other)))
def foreign_finished(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),+reservation:W.Reservation<T.HealthSchema>,result:Tx.Returned<D.World(),Unit>) -> Prepared:
  match result:
    case Tx.Returned{other,outcome}:foreign_pending(C.cat([prefix,C.outcome(outcome),C.reservation(reservation)]),count,iterations,world,reservation,V.world(other))
def foreign_reserved(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),result:Tx.Tx<D.World(),Nat> & W.Reservation<T.HealthSchema>) -> Prepared:
  match result:
    case (tx,reservation):foreign_finished(prefix,count,iterations,world,reservation,Cmd.tx_finish(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Unit,tx,Tx.Success{}))
def foreign_seed(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),foreign:D.World()) -> Prepared:foreign_reserved(prefix,count,iterations,world,Cmd.tx_spawn(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~T.Vitals,~D.populate,Tx.begin(~D.World(),~Nat,foreign),T.Vitals{F.quad(999,1000,1001,1002),9,2}))
def main_applied(prefix:Rope.Rope,count:U32,iterations:U32,foreign:D.World(),observed:D.World() & V.World) -> Prepared:
  match observed:
    case (world,view):foreign_seed(C.join(prefix,C.world(view)),count,iterations,world,foreign)
def main_pending(prefix:Rope.Rope,count:U32,iterations:U32,foreign:D.World(),observed:D.World() & V.World) -> Prepared:
  match observed:
    case (world,view):main_applied(C.join(prefix,C.world(view)),count,iterations,foreign,V.world(W.barrier(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,world)))
def main_seeded(+count:U32,+iterations:U32,foreign:D.World(),result:F.Seeded) -> Prepared:
  match result:
    case F.Seeded{world,reservations,outcome}:main_pending(C.cat([C.text("LC2H"),C.u(count),C.u(iterations),C.outcome(outcome),C.list(~W.Reservation<T.HealthSchema>,~C.reservation,reservations)]),count,iterations,foreign,V.world(world))
def program(+count:U32,iterations:U32,world:D.World(),foreign:D.World()) -> Prepared:main_seeded(count,iterations,foreign,F.seed(count,world))
def refused(observed:F.Resources() & String) -> String:
  match observed:
    case (resource,text):"WorldCreationRefused|" ++ text ++ "\n\n"
def foreign_refused(world:D.World() & String,resource:F.Resources() & String) -> String:
  (world,sw)=world
  (resource,sr)=resource
  "ForeignWorldCreationRefused|primary={" ++ sw ++ "};resource={" ++ sr ++ "}\n\n"
def raw_error(count:U32,iterations:U32,text:String) -> IO(Unit):Rope.write(C.cat([C.text("LC2H"),C.u(count),C.u(iterations),C.text("X"),C.u(2),C.string(text),C.text("!\n")]))
def formatted(observed:Program.State & Stream.StateView) -> IO(Unit):
  match observed:
    case (state,view):IO.bind(Unit,Unit,Stream.write_body(view),_=>IO.write("!\n"))
def loops_done(state:Program.State) -> IO(Unit):IO.bind(Unit,Unit,IO.write("T"),_=>formatted(Stream.state(state)))
def prepared(value:Prepared) -> IO(Unit):
  match value:
    case Ready{prefix,iterations,state}:IO.bind(Unit,Unit,Rope.write(prefix),_=>loops_done(Program.loops(U32.to_nat(iterations),state)))
    case Stopped{report}:Rope.write(report)
def foreign_created(count:U32,iterations:U32,world:D.World(),result:WI.Creation<T.HealthSchema,F.Store(),F.Resources(),Nat>) -> IO(Unit):
  match result:
    case WI.Created{foreign}:prepared(program(count,iterations,world,foreign))
    case WI.Refused{resource}:raw_error(count,iterations,foreign_refused(Old.world(world),Old.resources(resource)))
def primary_created(count:U32,iterations:U32,result:WI.Creation<T.HealthSchema,F.Store(),F.Resources(),Nat>) -> IO(Unit):
  match result:
    case WI.Created{world}:IO.bind(WI.Creation<T.HealthSchema,F.Store(),F.Resources(),Nat>,Unit,WI.create(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~F.empty,F.initial_resources()),created=>foreign_created(count,iterations,world,created))
    case WI.Refused{resource}:raw_error(count,iterations,refused(Old.resources(resource)))
def run(count:U32,iterations:U32) -> IO(Unit):IO.bind(WI.Creation<T.HealthSchema,F.Store(),F.Resources(),Nat>,Unit,WI.create(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~F.empty,F.initial_resources()),primary_created(count,iterations))
