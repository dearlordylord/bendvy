import Base
import ../consumer/lifecycle-runtime-v1/motion-domain.bend as D
import ../consumer/lifecycle-runtime-v1/motion-observation.bend as Observation
import ../consumer/lifecycle-runtime-v1/motion-registration.bend as Registration
import ../consumer/lifecycle-runtime-v1/motion-program.bend as Program
import ../consumer/lifecycle-runtime-v1/motion-codec-values.bend as V
import ../consumer/lifecycle-runtime-v1/motion-codec.bend as C
import ../consumer/lifecycle-runtime-v1/motion-buffer-stream.bend as Stream
import ../consumer/lifecycle-runtime-v1/motion-report-rope.bend as Rope
import ../consumer/dense-runtime-v1/motion.bend as F
import ../consumer/dense-runtime-v1/motion-observe.bend as Old
import ../consumer/dense-runtime-v1/types.bend as T
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/commands.bend as Cmd
import ../../../../src/ecs/transaction.bend as Tx

type Prepared is Type:
  Ready{prefix:Rope.Rope,iterations:U32,state:Program.State,seed:List<&2,W.Reservation<T.MotionSchema>>}
  Stopped{report:Rope.Rope}
def initial_state(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,iterations:U32,observed:Program.State & Rope.Rope) -> Prepared:
  match observed:
    case (state,view):Ready{C.join(prefix,view),iterations,state,seed}
def registration_stopped(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,foreign:D.World() & V.World,main:D.World() & V.World,rejected:Registration.RejectedOwners & Rope.Rope) -> Prepared:
  (foreign,sf)=foreign
  (world,sw)=main
  (owners,so)=rejected
  Stopped{C.cat([prefix,C.text("X"),C.u(0),C.world(sw),C.world(sf),so,C.text("!\n")])}
def registered(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,iterations:U32,foreign:D.World(),result:Registration.Registration) -> Prepared:
  match result:
    case Registration.Ready{world,owners}:initial_state(seed,prefix,iterations,C.state(Program.initial(world,foreign,owners)))
    case Registration.Stopped{world,owners}:registration_stopped(seed,prefix,V.world(foreign),V.world(world),C.rejected(owners))
def foreign_observed(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),foreign:W.Handle<T.MotionSchema>,observed:D.World() & V.World) -> Prepared:
  match observed:
    case (other,view):registered(seed,C.join(prefix,C.world(view)),iterations,other,Registration.run(world,count,foreign))
def bootstrap_stopped(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,primary:D.World() & V.World,foreign:D.World() & V.World) -> Prepared:
  (world,sw)=primary
  (other,sf)=foreign
  Stopped{C.cat([prefix,C.text("X"),C.u(1),C.world(sw),C.world(sf),C.text("!\n")])}
def foreign_checked(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),foreign:W.Handle<T.MotionSchema>,observed:D.World() & U32) -> Prepared:
  match observed:
    case (other,2):foreign_observed(seed,C.join(prefix,C.u(2)),count,iterations,world,foreign,V.world(other))
    case (other,kind):bootstrap_stopped(seed,C.join(prefix,C.u(kind)),V.world(world),V.world(other))
def foreign_live(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),+foreign:W.Handle<T.MotionSchema>,other:D.World()) -> Prepared:foreign_checked(seed,prefix,count,iterations,world,foreign,Observation.lookup(other,Some{foreign}))
def foreign_applied(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),reservation:W.Reservation<T.MotionSchema>,observed:D.World() & V.World) -> Prepared:
  match reservation observed:
    case W.Reserved{foreign}, (other,view):foreign_live(seed,C.join(prefix,C.world(view)),count,iterations,world,foreign,other)
    case reservation, (other,view):bootstrap_stopped(seed,C.cat([prefix,C.reservation(reservation),C.world(view)]),V.world(world),V.world(other))
def foreign_pending(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),reservation:W.Reservation<T.MotionSchema>,observed:D.World() & V.World) -> Prepared:
  match observed:
    case (other,view):foreign_applied(seed,C.join(prefix,C.world(view)),count,iterations,world,reservation,V.world(W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,other)))
def foreign_finished(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),+reservation:W.Reservation<T.MotionSchema>,result:Tx.Returned<D.World(),Unit>) -> Prepared:
  match result:
    case Tx.Returned{other,outcome}:foreign_pending(seed,C.cat([prefix,C.outcome(outcome),C.reservation(reservation)]),count,iterations,world,reservation,V.world(other))
def foreign_reserved(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),result:Tx.Tx<D.World(),Nat> & W.Reservation<T.MotionSchema>) -> Prepared:
  match result:
    case (tx,reservation):foreign_finished(seed,prefix,count,iterations,world,reservation,Cmd.tx_finish(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Unit,tx,Tx.Success{}))
def foreign_seed(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),foreign:D.World()) -> Prepared:foreign_reserved(seed,prefix,count,iterations,world,Cmd.tx_spawn(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~T.Position,~D.populate,Tx.begin(~D.World(),~Nat,foreign),T.Position{F.quad(999,1000,1001,1002),7}))
def main_applied(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,foreign:D.World(),observed:D.World() & V.World) -> Prepared:
  match observed:
    case (world,view):foreign_seed(seed,C.join(prefix,C.world(view)),count,iterations,world,foreign)
def main_pending(seed:List<&2,W.Reservation<T.MotionSchema>>,prefix:Rope.Rope,count:U32,iterations:U32,foreign:D.World(),observed:D.World() & V.World) -> Prepared:
  match observed:
    case (world,view):main_applied(seed,C.join(prefix,C.world(view)),count,iterations,foreign,V.world(W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,world)))
def main_seeded(+count:U32,+iterations:U32,foreign:D.World(),result:F.Seeded) -> Prepared:
  match result:
    case F.Seeded{world,+reservations,outcome}:main_pending(reservations,C.cat([C.text("LC2M"),C.u(count),C.u(iterations),C.outcome(outcome),C.list(~W.Reservation<T.MotionSchema>,~C.reservation,reservations)]),count,iterations,foreign,V.world(world))
def program(+count:U32,iterations:U32,world:D.World(),foreign:D.World()) -> Prepared:main_seeded(count,iterations,foreign,F.seed(count,world))
def refused(observed:F.Resources() & String) -> String:
  match observed:
    case (resource,text):"WorldCreationRefused|" ++ text ++ "\n\n"
def foreign_refused(world:D.World() & String,resource:F.Resources() & String) -> String:
  (world,sw)=world
  (resource,sr)=resource
  "ForeignWorldCreationRefused|primary={" ++ sw ++ "};resource={" ++ sr ++ "}\n\n"
def raw_error(count:U32,iterations:U32,text:String) -> IO(Unit):Rope.write(C.cat([C.text("LC2M"),C.u(count),C.u(iterations),C.text("X"),C.u(2),C.string(text),C.text("!\n")]))
