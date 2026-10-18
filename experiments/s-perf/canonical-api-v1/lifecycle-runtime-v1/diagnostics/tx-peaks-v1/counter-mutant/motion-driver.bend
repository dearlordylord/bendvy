import Base
import tx-metrics.bend as Metrics
import metric-output.bend as MetricOut
import motion-domain.bend as D
import motion-observation.bend as Observation
import motion-registration.bend as Registration
import motion-program.bend as Program
import motion-codec-values.bend as V
import motion-codec.bend as C
import motion-buffer-stream.bend as Stream
import motion-report-rope.bend as Rope
import ../../../../dense-runtime-v1/motion.bend as F
import ../../../../dense-runtime-v1/motion-observe.bend as Old
import ../../../../dense-runtime-v1/types.bend as T
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/world-io.bend as WI
import ../../../../../../../src/ecs/commands.bend as Cmd
import ../../../../../../../src/ecs/transaction.bend as Tx

type Prepared is Type:
  Ready{prefix:Rope.Rope,iterations:U32,state:Program.State,samples:List<&2,Metrics.Sample>}
  Stopped{report:Rope.Rope,samples:List<&2,Metrics.Sample>}
def with_sample(sample:Metrics.Sample,value:Prepared) -> Prepared:
  match value:
    case Ready{prefix,iterations,state,samples}:Ready{prefix,iterations,state,sample <> samples}
    case Stopped{report,samples}:Stopped{report,sample <> samples}
def initial_state(prefix:Rope.Rope,iterations:U32,observed:Program.State & Rope.Rope) -> Prepared:
  match observed:
    case (state,view):Ready{C.join(prefix,view),iterations,state,[]}
def registration_stopped(prefix:Rope.Rope,foreign:D.World() & V.World,main:D.World() & V.World,rejected:Registration.RejectedOwners & Rope.Rope) -> Prepared:
  (foreign,sf)=foreign
  (world,sw)=main
  (owners,so)=rejected
  Stopped{C.cat([prefix,C.text("X"),C.u(0),C.world(sw),C.world(sf),so,C.text("!\n")]),[]}
def registered(prefix:Rope.Rope,iterations:U32,foreign:D.World(),result:Registration.Registration) -> Prepared:
  match result:
    case Registration.Ready{world,owners}:initial_state(prefix,iterations,C.state(Program.initial(world,foreign,owners)))
    case Registration.Stopped{world,owners}:registration_stopped(prefix,V.world(foreign),V.world(world),C.rejected(owners))
def foreign_observed(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),foreign:W.Handle<T.MotionSchema>,observed:D.World() & V.World) -> Prepared:
  match observed:
    case (other,view):registered(C.join(prefix,C.world(view)),iterations,other,Registration.run(world,count,foreign))
def bootstrap_stopped(prefix:Rope.Rope,primary:D.World() & V.World,foreign:D.World() & V.World) -> Prepared:
  (world,sw)=primary
  (other,sf)=foreign
  Stopped{C.cat([prefix,C.text("X"),C.u(1),C.world(sw),C.world(sf),C.text("!\n")]),[]}
def foreign_checked(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),foreign:W.Handle<T.MotionSchema>,observed:D.World() & U32) -> Prepared:
  match observed:
    case (other,2):foreign_observed(C.join(prefix,C.u(2)),count,iterations,world,foreign,V.world(other))
    case (other,kind):bootstrap_stopped(C.join(prefix,C.u(kind)),V.world(world),V.world(other))
def foreign_live(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),+foreign:W.Handle<T.MotionSchema>,other:D.World()) -> Prepared:foreign_checked(prefix,count,iterations,world,foreign,Observation.lookup(other,Some{foreign}))
def foreign_applied(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),reservation:W.Reservation<T.MotionSchema>,observed:D.World() & V.World) -> Prepared:
  match reservation observed:
    case W.Reserved{foreign}, (other,view):foreign_live(C.join(prefix,C.world(view)),count,iterations,world,foreign,other)
    case reservation, (other,view):bootstrap_stopped(C.cat([prefix,C.reservation(reservation),C.world(view)]),V.world(world),V.world(other))
def foreign_pending(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),reservation:W.Reservation<T.MotionSchema>,observed:D.World() & V.World) -> Prepared:
  match observed:
    case (other,view):foreign_applied(C.join(prefix,C.world(view)),count,iterations,world,reservation,V.world(W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,other)))
def foreign_finished(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),+reservation:W.Reservation<T.MotionSchema>,result:Tx.Returned<D.World(),Unit>) -> Prepared:
  match result:
    case Tx.Returned{other,outcome}:foreign_pending(C.cat([prefix,C.outcome(outcome),C.reservation(reservation)]),count,iterations,world,reservation,V.world(other))
def foreign_sampled(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),reservation:W.Reservation<T.MotionSchema>,observed:Tx.Tx<D.World(),Nat> & Metrics.Sample) -> Prepared:
  match observed:
    case (tx,sample):with_sample(sample,foreign_finished(prefix,count,iterations,world,reservation,Cmd.tx_finish(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Unit,tx,Tx.Success{})))
def foreign_reserved(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),result:Tx.Tx<D.World(),Nat> & W.Reservation<T.MotionSchema>) -> Prepared:
  match result:
    case (tx,reservation):foreign_sampled(prefix,count,iterations,world,reservation,Metrics.observe(~D.World(),~Nat,"foreign-seed",tx))
def foreign_seed(prefix:Rope.Rope,count:U32,iterations:U32,world:D.World(),foreign:D.World()) -> Prepared:foreign_reserved(prefix,count,iterations,world,Cmd.tx_spawn(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~T.Position,~D.populate,Tx.begin(~D.World(),~Nat,foreign),T.Position{F.quad(999,1000,1001,1002),7}))
def main_applied(prefix:Rope.Rope,count:U32,iterations:U32,foreign:D.World(),observed:D.World() & V.World) -> Prepared:
  match observed:
    case (world,view):foreign_seed(C.join(prefix,C.world(view)),count,iterations,world,foreign)
def main_pending(prefix:Rope.Rope,count:U32,iterations:U32,foreign:D.World(),observed:D.World() & V.World) -> Prepared:
  match observed:
    case (world,view):main_applied(C.join(prefix,C.world(view)),count,iterations,foreign,V.world(W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,world)))
def main_seeded(+count:U32,+iterations:U32,foreign:D.World(),result:F.Seeded) -> Prepared:
  match result:
    case F.Seeded{world,reservations,outcome}:main_pending(C.cat([C.text("LC2M"),C.u(count),C.u(iterations),C.outcome(outcome),C.list(~W.Reservation<T.MotionSchema>,~C.reservation,reservations)]),count,iterations,foreign,V.world(world))
def main_sampled(count:U32,iterations:U32,foreign:D.World(),reservations:List<&2,W.Reservation<T.MotionSchema>>,observed:Tx.Tx<D.World(),Nat> & Metrics.Sample) -> Prepared:
  match observed:
    case (tx,sample):with_sample(sample,main_seeded(count,iterations,foreign,F.seeded(reservations,Cmd.tx_finish(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Unit,tx,Tx.Success{}))))
def main_reserved(count:U32,iterations:U32,foreign:D.World(),reserved:F.Reserved) -> Prepared:
  match reserved:
    case F.Reserved{tx,reservations}:main_sampled(count,iterations,foreign,reservations,Metrics.observe(~D.World(),~Nat,"main-seed",tx))
def program(+count:U32,iterations:U32,world:D.World(),foreign:D.World()) -> Prepared:main_reserved(count,iterations,foreign,F.seed_rows(U32.to_nat(count),0,F.Reserved{Tx.begin(~D.World(),~Nat,world),[]}))
def refused(observed:F.Resources() & String) -> String:
  match observed:
    case (resource,text):"WorldCreationRefused|" ++ text ++ "\n\n"
def foreign_refused(world:D.World() & String,resource:F.Resources() & String) -> String:
  (world,sw)=world
  (resource,sr)=resource
  "ForeignWorldCreationRefused|primary={" ++ sw ++ "};resource={" ++ sr ++ "}\n\n"
def raw_error(count:U32,iterations:U32,text:String) -> IO(Unit):Rope.write(C.cat([C.text("LC2M"),C.u(count),C.u(iterations),C.text("X"),C.u(2),C.string(text),C.text("!\n")]))
def formatted(path:String,seeds:List<&2,Metrics.Sample>,observed:Program.State & Stream.StateView) -> IO(Unit):
  match observed:
    case (state,view):
      samples=List.append(&2,Metrics.Sample,seeds,Program.finish_samples(state))
      IO.bind(Unit,Unit,Stream.write_body(view),_=>IO.bind(Unit,Unit,IO.write("!\n"),_=>MetricOut.write(path,samples)))
def loops_done(path:String,seeds:List<&2,Metrics.Sample>,state:Program.State) -> IO(Unit):IO.bind(Unit,Unit,IO.write("T"),_=>formatted(path,seeds,Stream.state(state)))
def prepared(path:String,value:Prepared) -> IO(Unit):
  match value:
    case Ready{prefix,iterations,state,seeds}:IO.bind(Unit,Unit,Rope.write(prefix),_=>loops_done(path,seeds,Program.loops(U32.to_nat(iterations),state)))
    case Stopped{report,seeds}:IO.bind(Unit,Unit,Rope.write(report),_=>MetricOut.write(path,seeds))
def foreign_created(path:String,count:U32,iterations:U32,world:D.World(),result:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat>) -> IO(Unit):
  match result:
    case WI.Created{foreign}:prepared(path,program(count,iterations,world,foreign))
    case WI.Refused{resource}:raw_error(count,iterations,foreign_refused(Old.world(world),Old.resources(resource)))
def primary_created(path:String,count:U32,iterations:U32,result:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat>) -> IO(Unit):
  match result:
    case WI.Created{world}:IO.bind(WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat>,Unit,WI.create(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.empty,F.initial_resources()),created=>foreign_created(path,count,iterations,world,created))
    case WI.Refused{resource}:raw_error(count,iterations,refused(Old.resources(resource)))
def run(count:U32,iterations:U32,path:String) -> IO(Unit):IO.bind(WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat>,Unit,WI.create(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.empty,F.initial_resources()),primary_created(path,count,iterations))
